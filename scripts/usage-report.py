#!/usr/bin/env python3
"""usage-report.py - report di consumi token e costo da opencode.db (SQLite, read-only).

Python 3 stdlib only. Legge ~/.local/share/opencode/opencode.db in sola lettura
(?mode=ro) e produce:
  - summary: totali globali + breakdown per modello, agente e progetto
  - export : ledger CSV persistente (upsert per session_id, idempotente)
  - sessions: elenco delle sessioni recenti

Comandi:
  summary  [--days N] [--since YYYY-MM-DD] [--until YYYY-MM-DD]
           [--project S] [--model S] [--agent S] [--format text|json] [--db PATH]
  export   [--out PATH] [--db PATH]
  sessions [--limit N] [--days N] [--since YYYY-MM-DD] [--until YYYY-MM-DD]
           [--project S] [--model S] [--agent S] [--db PATH]
"""

import argparse
import csv
import json
import sqlite3
import sys
from datetime import datetime, timedelta
from pathlib import Path

DB_DEFAULT = Path("~/.local/share/opencode/opencode.db").expanduser()
LEDGER_DEFAULT = Path("~/.local/share/opencode/usage/ledger.csv").expanduser()

TOKEN_COLUMNS = [
    "tokens_input",
    "tokens_output",
    "tokens_reasoning",
    "tokens_cache_read",
    "tokens_cache_write",
]

LEDGER_COLUMNS = [
    "session_id",
    "time_created_iso",
    "time_updated_iso",
    "project",
    "model",
    "agent",
    "tokens_input",
    "tokens_output",
    "tokens_reasoning",
    "tokens_cache_read",
    "tokens_cache_write",
    "cost_usd",
]


def connect(db_path):
    """Connessione SQLite SOLO read-only (mode=ro)."""
    uri = "file:{}?mode=ro".format(db_path)
    conn = sqlite3.connect(uri, uri=True)
    conn.row_factory = sqlite3.Row
    return conn


def parse_model(raw):
    """Normalizza la stringa JSON del modello in 'providerID/id'.

    Fallback: stringa raw se il JSON non parsea o non contiene campi utili.
    """
    if raw is None:
        return "unknown"
    text = str(raw).strip()
    if not text:
        return "unknown"
    try:
        data = json.loads(text)
    except (json.JSONDecodeError, ValueError):
        return text
    if not isinstance(data, dict):
        return text
    provider = data.get("providerID") or data.get("provider") or ""
    model_id = data.get("id") or ""
    if provider and model_id:
        return "{}/{}".format(provider, model_id)
    if model_id:
        return model_id
    return text


def project_name(worktree, project_name_value, project_id):
    """Nome progetto: basename del worktree, fallback name, id, 'unknown'."""
    if worktree and str(worktree) not in ("", "/"):
        name = Path(str(worktree)).name
        if name:
            return name
    if project_name_value:
        return str(project_name_value)
    if project_id:
        return str(project_id)
    return "unknown"


def build_time_filters(args):
    """Ritorna (where_clauses, params) per i filtri temporali (epoch ms)."""
    where = []
    params = []
    if args.days is not None:
        since = datetime.now() - timedelta(days=args.days)
        where.append("s.time_created >= ?")
        params.append(int(since.timestamp() * 1000))
    if args.since:
        since = datetime.fromisoformat(args.since)
        where.append("s.time_created >= ?")
        params.append(int(since.timestamp() * 1000))
    if args.until:
        until = datetime.fromisoformat(args.until) + timedelta(days=1)
        where.append("s.time_created < ?")
        params.append(int(until.timestamp() * 1000))
    return where, params


def load_sessions(conn, args, apply_filters=True):
    """Carica e normalizza le sessioni dal DB (mai in scrittura)."""
    where, params = [], []
    if apply_filters:
        where, params = build_time_filters(args)

    query = """
        SELECT s.id, s.project_id, s.cost, s.tokens_input, s.tokens_output,
               s.tokens_reasoning, s.tokens_cache_read, s.tokens_cache_write,
               s.model, s.agent, s.time_created, s.time_updated,
               p.worktree, p.name AS project_name
        FROM session s
        LEFT JOIN project p ON p.id = s.project_id
    """
    if where:
        query += " WHERE " + " AND ".join(where)
    query += " ORDER BY s.time_created DESC"

    sessions = []
    for row in conn.execute(query, params).fetchall():
        model = parse_model(row["model"])
        agent = str(row["agent"] or "").strip() or "unknown"
        project = project_name(row["worktree"], row["project_name"], row["project_id"])
        sessions.append(
            {
                "session_id": str(row["id"]),
                "project": project,
                "cost": float(row["cost"] or 0.0),
                "tokens_input": int(row["tokens_input"] or 0),
                "tokens_output": int(row["tokens_output"] or 0),
                "tokens_reasoning": int(row["tokens_reasoning"] or 0),
                "tokens_cache_read": int(row["tokens_cache_read"] or 0),
                "tokens_cache_write": int(row["tokens_cache_write"] or 0),
                "model": model,
                "agent": agent,
                "time_created": int(row["time_created"] or 0),
                "time_updated": int(row["time_updated"] or 0),
            }
        )

    if apply_filters:
        if args.project:
            needle = args.project.lower()
            sessions = [s for s in sessions if needle in s["project"].lower()]
        if args.model:
            needle = args.model.lower()
            sessions = [s for s in sessions if needle in s["model"].lower()]
        if args.agent:
            needle = args.agent.lower()
            sessions = [s for s in sessions if needle in s["agent"].lower()]

    return sessions


def build_report(sessions):
    """Aggregazioni condivise tra output testo e JSON."""
    total = {
        "sessions": len(sessions),
        "cost_usd": round(sum(s["cost"] for s in sessions), 2),
    }
    for col in TOKEN_COLUMNS:
        total[col] = sum(s[col] for s in sessions)
    total["tokens_total"] = sum(total[c] for c in TOKEN_COLUMNS)

    def breakdown(key):
        groups = {}
        for s in sessions:
            groups.setdefault(s[key], []).append(s)
        items = []
        for name, group in groups.items():
            item = {
                "name": name,
                "sessions": len(group),
                "cost_usd": round(sum(x["cost"] for x in group), 2),
            }
            for col in TOKEN_COLUMNS:
                item[col] = sum(x[col] for x in group)
            item["tokens_total"] = sum(item[c] for c in TOKEN_COLUMNS)
            items.append(item)
        items.sort(key=lambda i: i["cost_usd"], reverse=True)
        return items

    return {
        "total": total,
        "by_model": breakdown("model"),
        "by_agent": breakdown("agent"),
        "by_project": breakdown("project"),
    }


def _print_table(headers, rows):
    """Stampa righe allineate in colonne (headers + rows di stringhe)."""
    widths = [len(h) for h in headers]
    for r in rows:
        for i, cell in enumerate(r):
            widths[i] = max(widths[i], len(cell))
    print("  " + "  ".join(h.ljust(w) for h, w in zip(headers, widths)))
    for r in rows:
        cells = []
        for i, cell in enumerate(r):
            cells.append(cell.rjust(widths[i]) if i > 0 else cell.ljust(widths[i]))
        print("  " + "  ".join(cells))


def print_summary_text(report):
    total = report["total"]
    label_width = max(len(c) for c in ["sessions"] + TOKEN_COLUMNS + ["cost_usd"])
    print("Totale globale")
    print("  {}: {}".format("sessions".ljust(label_width), format(total["sessions"], ",")))
    for col in TOKEN_COLUMNS:
        print("  {}: {}".format(col.ljust(label_width), format(total[col], ",")))
    print("  {}: {}".format("cost_usd".ljust(label_width), format(total["cost_usd"], ".2f")))
    print()

    for label, rows in (
        ("Per modello", report["by_model"]),
        ("Per agente", report["by_agent"]),
        ("Per progetto", report["by_project"]),
    ):
        print(label)
        if not rows:
            print("  (nessuna sessione)")
            print()
            continue
        table_rows = [
            (r["name"], format(r["sessions"], ","), format(r["tokens_total"], ","), format(r["cost_usd"], ".2f"))
            for r in rows
        ]
        _print_table(["Nome", "Sessioni", "Token", "Costo USD"], table_rows)
        print()


def print_sessions(sessions, limit):
    rows = sessions[:limit] if limit else sessions
    if not rows:
        print("Nessuna sessione.")
        return
    table_rows = []
    for s in rows:
        created = datetime.fromtimestamp(s["time_created"] / 1000.0).strftime("%Y-%m-%d %H:%M") if s["time_created"] else "-"
        tokens = sum(s[c] for c in TOKEN_COLUMNS)
        table_rows.append(
            (
                s["session_id"][:8],
                created,
                s["project"],
                s["model"],
                s["agent"],
                format(tokens, ","),
                format(s["cost"], ".2f"),
            )
        )
    _print_table(
        ["ID", "Data", "Progetto", "Modello", "Agente", "Token", "Costo USD"],
        table_rows,
    )


def export_ledger(sessions, out_path):
    """Upsert del ledger CSV: per session_id, l'ultima versione vince."""
    out_path.parent.mkdir(parents=True, exist_ok=True)

    existing = {}
    if out_path.exists():
        with open(out_path, newline="", encoding="utf-8") as fh:
            reader = csv.DictReader(fh)
            for row in reader:
                if row.get("session_id"):
                    existing[row["session_id"]] = row

    for s in sessions:
        existing[s["session_id"]] = {
            "session_id": s["session_id"],
            "time_created_iso": datetime.fromtimestamp(s["time_created"] / 1000.0).isoformat(timespec="seconds")
            if s["time_created"]
            else "",
            "time_updated_iso": datetime.fromtimestamp(s["time_updated"] / 1000.0).isoformat(timespec="seconds")
            if s["time_updated"]
            else "",
            "project": s["project"],
            "model": s["model"],
            "agent": s["agent"],
            "tokens_input": str(s["tokens_input"]),
            "tokens_output": str(s["tokens_output"]),
            "tokens_reasoning": str(s["tokens_reasoning"]),
            "tokens_cache_read": str(s["tokens_cache_read"]),
            "tokens_cache_write": str(s["tokens_cache_write"]),
            "cost_usd": format(s["cost"], ".2f"),
        }

    rows = list(existing.values())
    rows.sort(key=lambda r: (r["time_created_iso"], r["session_id"]))

    with open(out_path, "w", newline="", encoding="utf-8") as fh:
        writer = csv.DictWriter(fh, fieldnames=LEDGER_COLUMNS)
        writer.writeheader()
        writer.writerows(rows)

    print("Ledger aggiornato: {} ({} sessioni)".format(out_path, len(rows)))


def positive_int(value):
    """Tipo argparse: intero >= 1 (usato da --top)."""
    n = int(value)
    if n < 1:
        raise argparse.ArgumentTypeError("deve essere un intero >= 1")
    return n


def build_parser():
    parser = argparse.ArgumentParser(
        prog="usage-report.py",
        description="Report consumi token e costo da opencode.db (read-only).",
    )
    sub = parser.add_subparsers(dest="command", required=True)

    common = argparse.ArgumentParser(add_help=False)
    common.add_argument("--db", default=str(DB_DEFAULT), help="Percorso DB opencode (default: ~/.local/share/opencode/opencode.db)")

    filters = argparse.ArgumentParser(add_help=False)
    filters.add_argument("--days", type=int, default=None, help="Ultimi N giorni (default: tutto)")
    filters.add_argument("--since", default=None, help="Dal giorno YYYY-MM-DD (incluso)")
    filters.add_argument("--until", default=None, help="Fino al giorno YYYY-MM-DD (incluso)")
    filters.add_argument("--project", default=None, help="Substring case-insensitive sul progetto")
    filters.add_argument("--model", default=None, help="Substring case-insensitive sul modello normalizzato")
    filters.add_argument("--agent", default=None, help="Substring case-insensitive sull'agente")

    p_summary = sub.add_parser("summary", parents=[common, filters], help="Totali globali e breakdown")
    p_summary.add_argument("--format", choices=["text", "json"], default="text", help="Formato output (default: text)")
    p_summary.add_argument("--top", type=positive_int, default=None, help="Limita ogni breakdown ai primi N elementi per costo")

    p_export = sub.add_parser("export", parents=[common], help="Upsert ledger CSV")
    p_export.add_argument("--out", default=str(LEDGER_DEFAULT), help="Percorso ledger CSV (default: ~/.local/share/opencode/usage/ledger.csv)")

    p_sessions = sub.add_parser("sessions", parents=[common, filters], help="Elenca sessioni recenti")
    p_sessions.add_argument("--limit", type=int, default=10, help="Numero massimo di sessioni (default: 10)")

    return parser


def main(argv=None):
    args = build_parser().parse_args(argv)
    conn = connect(Path(args.db).expanduser())
    try:
        if args.command == "summary":
            report = build_report(load_sessions(conn, args))
            if args.top is not None:
                for key in ("by_model", "by_agent", "by_project"):
                    report[key] = report[key][:args.top]
            if args.format == "json":
                print(json.dumps(report, indent=2, ensure_ascii=False))
            else:
                print_summary_text(report)
        elif args.command == "export":
            sessions = load_sessions(conn, args, apply_filters=False)
            export_ledger(sessions, Path(args.out).expanduser())
        elif args.command == "sessions":
            print_sessions(load_sessions(conn, args), args.limit)
    finally:
        conn.close()
    return 0


if __name__ == "__main__":
    sys.exit(main())