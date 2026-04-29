#!/usr/bin/env bash
set -euo pipefail

# dart2js + local canvaskit: stable, universally supported, no CDN dependency,
# no SharedArrayBuffer / COEP headers required.
flutter build web --release --no-web-resources-cdn

python3 - <<'PYEOF'
import re, json

with open('build/web/flutter_bootstrap.js', 'r') as f:
    content = f.read()

# Remove deprecated service worker registration and add .catch() so any
# Dart main() exception surfaces in the browser console instead of silently
# freezing the HTML splash screen.
content = re.sub(
    r'_flutter\.loader\.load\(\{[^}]*serviceWorkerSettings[^}]*\}[^)]*\)',
    '_flutter.loader.load({})',
    content,
    flags=re.DOTALL,
)
content = re.sub(
    r'(_flutter\.loader\.load\([^)]*\));',
    r'\1.catch(function(e){console.error("Flutter failed to load:",e);});',
    content,
)

with open('build/web/flutter_bootstrap.js', 'w') as f:
    f.write(content)

print('flutter_bootstrap.js patched.')
PYEOF

# Remove redundant flutter.js (inlined into flutter_bootstrap.js)
rm -f build/web/flutter.js

# Copy _redirects so Netlify serves index.html for every SPA route
cp web/_redirects build/web/_redirects

echo "Build complete and patched."
