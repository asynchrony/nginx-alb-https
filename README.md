# nginx-alb-https
Redirect AWS ALB HTTP requests to HTTPS. Any request that are using HTTPS will be passed through to the other containers.

Uses jwilder/nginx-proxy:
https://github.com/jwilder/nginx-proxy

## Usage
Start the Nginx container:
```
❯ docker run --name nginx -d -p 80:80 -v /var/run/docker.sock:/tmp/docker.sock:ro nginx
```
Then start any other containers you wish to proxy:
```
❯ docker run -d -e VIRTUAL_HOST=<Hostname to be routed> <docker image> 
```