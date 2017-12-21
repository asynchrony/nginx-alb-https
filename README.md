# nginx-alb-https
Redirect AWS ALB HTTP requests to HTTPS. Any request that are using HTTPS will be passed through to the other containers.

This continer assumes that your ALB forwards 443 `and` 80 to a single port in your target group. You are not required to expose port 443.

Uses jwilder/nginx-proxy:
https://github.com/jwilder/nginx-proxy

## Usage
Start the Nginx container:
```
❯ docker run --name nginx -d -p <port ALB forwards to>:80 -v /var/run/docker.sock:/tmp/docker.sock:ro ss
```

Then start any other containers you wish to proxy:
```
❯ docker run -d -e VIRTUAL_HOST=<Hostname to be routed> <docker image> 
```