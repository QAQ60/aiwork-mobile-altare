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
  /* 1. 顶部操作按钮组：允许换行，不再撑破整页 */
  .mb-5.flex.items-end.justify-between { flex-wrap: wrap !important; }
  .mb-5.flex.items-end.justify-between .flex.items-center.gap-2 {
    flex-wrap: wrap !important; width: 100% !important;
    max-width: 100% !important; overflow: visible !important;
  }
  .mb-5.flex.items-end.justify-between .btn-outline {
    padding-left: .55rem !important; padding-right: .55rem !important; font-size: 12px !important;
  }

  /* 2. 表格在卡片内部横向滚动，不再撑宽整页 */
  .card.overflow-hidden { overflow-x: auto !important; -webkit-overflow-scrolling: touch; }

  /* 3. grid/flex 子项允许收缩，修复环境配置页 464px 撑宽 */
  .grid > *, .gridcard, [class*="grid-cols"] > * { min-width: 0 !important; }
  .card.p-4 { min-width: 0 !important; max-width: 100% !important; }
  .rounded-lg.bg-slate-50, .rounded-lg.bg-zinc-900 { min-width: 0 !important; max-width: 100% !important; }
  input[type="range"] { max-width: 100% !important; }

  /* 4. 通用 flex 行换行 */
  .flex.items-center.gap-2 { flex-wrap: wrap; }

  /* 5. 弹窗（帮助等）：限制最大高度 + 内容可上下滚动，修复"上下滑不了" */
  .fixed.inset-0.z-50 { overflow-y: auto !important; -webkit-overflow-scrolling: touch; align-items: flex-start !important; }
  .fixed.inset-0.z-50 > .card,
  .fixed.inset-0.z-50 .card.relative {
    max-height: calc(100dvh - 2rem) !important;
    overflow-y: auto !important;
    -webkit-overflow-scrolling: touch;
  }

  /* 6. 资源调度页 grid-cols-12 手机上改单列，模型 ID 不再被挤成半宽 */
  .grid.grid-cols-12 { display: flex !important; flex-direction: column !important; }
  .grid.grid-cols-12 > * { width: 100% !important; max-width: 100% !important; }
  .col-span-6, [class*="col-span-"] { width: 100% !important; max-width: 100% !important; }

  /* 7. 积分看板账号/分组下拉浮层定位溢出屏幕左侧，改为左对齐 */
  .absolute.right-0.z-30 { left: 0 !important; right: auto !important; }
}
</style>
CSSEOF

awk '
  /<\/head>/ {
    while ((getline line < "/mobile-fix.css") > 0) print line
    close("/mobile-fix.css")
  }
  { print }
' "$HTML" > /tmp/index.new && mv /tmp/index.new "$HTML"

rm -f /mobile-fix.css
grep -q 'MOBILE-FIX-INJECTED' "$HTML" && echo "injected ok" || { echo "injection failed"; exit 1; }
