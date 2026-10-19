FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
COPY index.html /usr/share/nginx/html/coexistencia/index.html
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY gerar-config.sh /docker-entrypoint.d/40-gerar-config.sh
RUN chmod +x /docker-entrypoint.d/40-gerar-config.sh
EXPOSE 80
