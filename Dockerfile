FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
COPY index.html /usr/share/nginx/html/coexistencia/index.html
EXPOSE 80
