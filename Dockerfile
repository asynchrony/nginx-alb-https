FROM jwilder/nginx-proxy

COPY default_location /etc/nginx/vhost.d/

EXPOSE 80