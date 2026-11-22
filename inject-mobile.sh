#!/bin/sh
# 在官方 aiwork-server 镜像的 dist/index.html 注入移动端修复 CSS。
# 基于官方 docker_main 镜像，只改静态 HTML 的样式，不动后端逻辑与任何页面结构。
set -eu

HTML=/app/dist/index.html
[ -f "$HTML" ] || { echo "index.html not found"; exit 1; }

python3 - "$HTML" <<'PYEOF'
import sys
path = sys.argv[1]
html = open(path, encoding='utf-8').read()
if '/* MOBILE-FIX-INJECTED */' in html:
    print('already injected'); sys.exit(0)

css = r'''/* MOBILE-FIX-INJECTED */
<style>
@media (max-width: 767px) {
  /* 1. 顶部操作按钮组：允许换行，不再撑破整页（原来 7 个按钮一行撑到 518px） */
  .mb-5.flex.items-end.justify-between { flex-wrap: wrap !important; }
  .mb-5.flex.items-end.justify-between .flex.items-center.gap-2 {
    flex-wrap: wrap !important;
    width: 100% !important;
    max-width: 100% !important;
    overflow: visible !important;
  }
  .mb-5.flex.items-end.justify-between .btn-outline {
    padding-left: .55rem !important;
    padding-right: .55rem !important;
    font-size: 12px !important;
  }

  /* 2. 表格卡片：表格在卡片内部横向滚动，不再把整个页面撑宽。
        用户可在卡片区域内左右滑动查看所有列，页面本身不再横向滚动。 */
  .card.overflow-hidden { overflow-x: auto !important; -webkit-overflow-scrolling: touch; }

  /* 3. 通用：窄屏下的 flex 行允许换行，避免其它页面按钮组同类问题 */
  .flex.items-center.gap-2 { flex-wrap: wrap; }
}
</style>
'''
html = html.replace('</head>', css + '\n</head>', 1)
open(path, 'w', encoding='utf-8').write(html)
print('injected mobile CSS into', path)
PYEOF
