# nginx-alb-https
Redirect AWS ALB HTTP requests to HTTPS. Any request that are using HTTPS will be passed through to the other containers.

Uses jwilder/nginx-proxy:
https://github.com/jwilder/nginx-proxy

## AWS Health Check URL
By default, any requests sent to `/api/v[0-9]+/health-?check$` will not be redirected to HTTPS. This is so AWS ALB health-checks can occur properly. This URL can be overridden by passing in the `HEALTH_CHECK_URL` when starting the image. Regex and non-regex locations can both be used.

This continer assumes that your ALB forwards 443 *and* 80 to a single port in your target group. You are not required to expose port 443. By not exposing port 443 directly from your web application, you are letting Nginx proxy all requests to your application.

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
❯ docker run -d -e VIRTUAL_HOST=<Internal EC2 IP Address>,<Any other hostnames you wish to use> <docker image> 
```
Note that you `MUST` use the internal EC2 IP address as one of your hostnames. This is because AWS Health checks are done via internal IP address. If you do not put your instances internal IP, all of your health-checks will fail with 503 status codes.

This can be done in CoreOS by getting the private IP from the metadata service, and setting the VIRTUAL_HOST variable. The variable must be set in this manner because you cannot execute code in `Environment` lines

```
ExecStartPre=/usr/bin/bash -c "/usr/bin/systemctl set-environment VIRTUAL_HOST=dev-auth.*,dev-auth-internal.*,$(curl http://169.254.169.254/latest/meta-data/local-ipv4)"

ExecStart=/usr/bin/docker run --name %p -e VIRTUAL_HOST -e ASPNETCORE_ENVIRONMENT $DOCKER_IMAGE
```

You can also make use of the CoreOS metadata service to get this variable, in which case your docker run command would look something like:
```
ExecStart=/usr/bin/docker run --name %p -e VIRTUAL_HOST=$VIRTUAL_HOST,$COREOS_EC2_IPV4_LOCAL -e ASPNETCORE_ENVIRONMENT $DOCKER_IMAGE
```

CoreOS Metadata: https://coreos.com/ignition/docs/latest/metadata.html

Example CoreOS UnitFile for a service being proxied by this container. This example uses the CoreOS metadata service to retrieve the private IP address.
```
[Unit]
Description=This is service is responsible for granting api tokens
After=docker.service <nginx-redirect.service> coreos-metadata.service
Requires=docker.service <nginx-redirect.service> coreos-metadata.service

[Service]
EnvironmentFile=/run/metadata/coreos
Environment=DOCKER_IMAGE=${local.auth_service_repository}:${var.auth_service_version}
Environment=VIRTUAL_HOST=${local.host_name}.*,${local.host_name}-internal.*
Restart=always
ExecStartPre=-/usr/bin/docker kill %p
ExecStartPre=/bin/bash -c 'eval $(docker run asynchrony/docker-aws aws ecr get-login --registry-ids 207418138085 --region us-east-1 --no-include-email)'
ExecStartPre=-/usr/bin/docker rm %p
ExecStartPre=/usr/bin/docker pull $DOCKER_IMAGE
ExecStart=/usr/bin/docker run --name %p \
    -e VIRTUAL_HOST=$${VIRTUAL_HOST},$${COREOS_EC2_IPV4_LOCAL} \
    $DOCKER_IMAGE
ExecStop=/usr/bin/docker stop %p

[Install]
WantedBy=multi-user.target
```