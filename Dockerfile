FROM nginx:alpine
LABEL maintainer="rk satish <sonierk@gmail.com>"

COPY website /website
COPY nginx.conf /etc/nginx/nginx.conf


