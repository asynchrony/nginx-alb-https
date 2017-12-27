echo "Fixing up default_location file with health check url: $HEALTH_CHECK_URL"
sed -i "s!HEALTH_CHECK_URL!$HEALTH_CHECK_URL!g" /etc/nginx/vhost.d/default_location

echo "Starting up NGINX"
forego start -r