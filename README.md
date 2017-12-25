# nginx-alb-https
Redirect AWS ALB HTTP requests to HTTPS. Any request that are using HTTPS will be passed through to the other containers.

Uses jwilder/nginx-proxy:
https://github.com/jwilder/nginx-proxy

## AWS Health Check URL
By default, any requests sent to `/api/v[0-9]+/health-?check$` will not be redirected to HTTPS. This is so AWS ALB health-checks can occur properly. This URL can be overridden by passing in the `HEALTH_CHECK_URL` when starting the image. Regex and non-regex locations can both be used.

This continer assumes that your ALB forwards 443 `and` 80 to a single port in your target group. You are not required to expose port 443. By not exposing port 443 directly from your web application, you are letting Nginx proxy all requests to your application.

## Usage
Start the Nginx container:
```
❯ docker run --name nginx -d \
    -e HEALTH_CHECK_URL=<URL that the ALB must access for health checks>
    -p <port ALB forwards to>:80 \
    -v /var/run/docker.sock:/tmp/docker.sock:ro \
    nginx-alb-https
```

Then start any other containers you wish to proxy:
```
❯ docker run -d -e VIRTUAL_HOST=<Hostname to be routed> <docker image> 
```