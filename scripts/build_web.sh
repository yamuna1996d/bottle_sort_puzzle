#!/usr/bin/env bash
set -euo pipefail

flutter build web --release --wasm

python3 - <<'PYEOF'
import re, json

with open('build/web/flutter_bootstrap.js', 'r') as f:
    content = f.read()

# Fix 1: Replace deprecated Intl.v8BreakIterator check with Intl.Segmenter
content = content.replace(
    'typeof Intl.v8BreakIterator<"u"&&typeof Intl.Segmenter<"u"',
    'typeof Intl.Segmenter<"u"'
)

# Fix 2: Remove deprecated service worker registration
content = re.sub(
    r'_flutter\.loader\.load\(\{\s*serviceWorkerSettings:\s*\{[^}]*\}\s*\}\);',
    '_flutter.loader.load({});',
    content
)

# Fix 3: Remove dart2js fallback + force local canvaskit (prevents gstatic CDN load
# being blocked by Cross-Origin-Embedder-Policy: require-corp on Netlify)
match = re.search(r'_flutter\.buildConfig = ({.*?});', content)
if match:
    config = json.loads(match.group(1))
    config['builds'] = [b for b in config['builds'] if b.get('compileTarget') != 'dart2js']
    config['useLocalCanvasKit'] = True
    content = content[:match.start()] + '_flutter.buildConfig = ' + json.dumps(config) + ';' + content[match.end():]

with open('build/web/flutter_bootstrap.js', 'w') as f:
    f.write(content)

print('flutter_bootstrap.js patched.')
PYEOF

# Fix 4: Remove redundant flutter.js (content already inlined in flutter_bootstrap.js)
rm -f build/web/flutter.js

# Fix 5: Remove dart2js fallback bundle (not needed when wasm-only)
rm -f build/web/main.dart.js

# Fix 6: Remove unused canvaskit variants and debug symbol files
# Keep: skwasm (Chrome/Edge) + skwasm_heavy (Firefox/Safari)
rm -rf build/web/canvaskit/canvaskit.js \
       build/web/canvaskit/canvaskit.js.symbols \
       build/web/canvaskit/canvaskit.wasm \
       build/web/canvaskit/chromium \
       build/web/canvaskit/skwasm.js.symbols \
       build/web/canvaskit/skwasm_heavy.js.symbols \
       build/web/canvaskit/wimp.js \
       build/web/canvaskit/wimp.js.symbols \
       build/web/canvaskit/wimp.wasm

echo "Build complete and patched."
