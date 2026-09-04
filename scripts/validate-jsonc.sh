#!/bin/bash
# Validate JSONC syntax
for file in *.jsonc; do
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
        " 2>&1
        if [ $? -ne 0 ]; then
            echo "❌ Invalid JSONC: $file"
            exit 1
        fi
        echo "✅ Valid JSONC: $file"
    fi
done
