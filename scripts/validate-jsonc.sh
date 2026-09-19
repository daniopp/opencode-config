#!/bin/bash
# Validate JSONC syntax
# Uso:
#   scripts/validate-jsonc.sh              valida tutti i *.jsonc della directory corrente
#   scripts/validate-jsonc.sh <file>...    valida i file indicati (usato dal pre-commit hook)
set -euo pipefail

if [ $# -gt 0 ]; then
    FILES=("$@")
else
    FILES=(*.jsonc)
fi

for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        node -e "
            const fs = require('fs');
            let s = fs.readFileSync('$file', 'utf8');
            s = s.split('\n').map(l => {
                let inStr = false;
                for (let i = 0; i < l.length; i++) {
                    const c = l[i];
                    if (c === '\"' && l[i-1] !== '\\\\') inStr = !inStr;
                    if (c === '/' && l[i+1] === '/' && !inStr) { l = l.slice(0, i); break; }
                }
                return l;
            }).join('\n');
            s = s.replace(/,\s*([}\]])/g, '\$1');
            JSON.parse(s);
        " 2>&1 || {
            echo "❌ Invalid JSONC: $file" >&2
            exit 1
        }
        echo "✅ Valid JSONC: $file"
    fi
done