#!/bin/sh
# 在官方 aiwork-server 镜像的 dist/index.html 注入移动端修复 CSS。
# 纯 shell + awk（运行级 debian-slim 无 python）。
set -eu

HTML=/app/dist/index.html
[ -f "$HTML" ] || { echo "index.html not found"; exit 1; }
grep -q 'MOBILE-FIX-INJECTED' "$HTML" && { echo 'already injected'; exit 0; }

cat > /mobile-fix.css <<'CSSEOF'
<style>
/* MOBILE-FIX-INJECTED */
@media (max-width: 767px) {
  .mb-5.flex.items-end.justify-between { flex-wrap: wrap !important; }
  .mb-5.flex.items-end.justify-between .flex.items-center.gap-2 {
    flex-wrap: wrap !important; width: 100% !important;
    max-width: 100% !important; overflow: visible !important;
  }
  .mb-5.flex.items-end.justify-between .btn-outline {
    padding-left: .55rem !important; padding-right: .55rem !important; font-size: 12px !important;
  }
  .card.overflow-hidden { overflow-x: auto !important; -webkit-overflow-scrolling: touch; }
  .flex.items-center.gap-2 { flex-wrap: wrap; }
}
</style>
CSSEOF

# 遇到 </head> 行之前，先把 CSS 文件内容整个打印出来
awk '
  /<\/head>/ {
    while ((getline line < "/mobile-fix.css") > 0) print line
    close("/mobile-fix.css")
  }
  { print }
' "$HTML" > /tmp/index.new && mv /tmp/index.new "$HTML"

rm -f /mobile-fix.css
grep -q 'MOBILE-FIX-INJECTED' "$HTML" && echo "injected ok" || { echo "injection failed"; exit 1; }
