FROM ghcr.io/smart-open/traeworkassistant:docker_main

# 注入移动端修复 CSS（只改 dist/index.html，不动后端）
COPY inject-mobile.sh /tmp/inject-mobile.sh
RUN chmod +x /tmp/inject-mobile.sh && /tmp/inject-mobile.sh && rm -f /tmp/inject-mobile.sh
