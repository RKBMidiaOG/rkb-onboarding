FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
COPY index.html /usr/share/nginx/html/conectar/index.html
EXPOSE 80
