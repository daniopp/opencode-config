# GitHub MCP Server

## Opzione 1: Remote Server (consigliata)

GitHub offre un endpoint MCP ufficiale remoto. Non richiede installazione locale.

```jsonc
{
  "mcp": {
    "github": {
      "type": "remote",
      "url": "https://api.githubcopilot.com/mcp/",
      "enabled": true
    }
  }
}
```

Per autenticarsi:
```bash
opencode mcp auth github
```

## Opzione 2: Binario locale compilato da Go

Se preferisci non dipendere dall'endpoint remoto:

```bash
git clone https://github.com/github/github-mcp-server.git
cd github-mcp-server
go build -o github-mcp-server cmd/github-mcp-server/main.go
sudo mv github-mcp-server /usr/local/bin/
```

Config:
```jsonc
{
  "mcp": {
    "github": {
      "type": "local",
      "command": ["/usr/local/bin/github-mcp-server", "stdio"],
      "enabled": true,
      "environment": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_xxx"
      }
    }
  }
}
```

## Note

- `@github/github-mcp-server` NON esiste su npm - non usare `npx`
- Il PAT deve avere scope: `repo`, `read:user`
- Per il remote server l'auth avviene via OAuth (opencode mcp auth github)
