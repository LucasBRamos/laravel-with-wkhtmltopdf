###
# Ambientum
#
# Repository:    PHP
# Image:         PHP-FPM + Nginx
# Version:       7.3.x
# Strategy:      PHP From PHP-Alpine Repository (CODECASTS) + Official Nginx
# Base distro:   Alpine 3.9
#
# Inspired by official PHP images.
#
FROM ambientum/php:7.4

# Repository/Image Maintainer
LABEL maintainer="Lucas Ramos <lucasramos53@gmail.om>"

# Reset user to root to allow software install
USER root

# Copy nginx and entry script
COPY nginx.conf /etc/nginx/nginx.conf
COPY ssl.conf /etc/nginx/ssl.conf
COPY sites /etc/nginx/sites
COPY start.sh  /home/start.sh

# Install nginx from dotdeb (already enabled on base image)
RUN echo "Installing Nginx" && \
    apk add --update nginx openssl && \
    rm -rf /tmp/* /var/tmp/* /usr/share/doc/* && \
    echo "Fixing permissions" && \
    mkdir /var/tmp/nginx && \
    mkdir /var/run/nginx && \
#    mkdir /home/ssl && \
    chown -R ambientum:ambientum /home/ssl && \
    chown -R ambientum:ambientum /var/tmp/nginx && \
    chown -R ambientum:ambientum /var/run/nginx && \
    chown -R ambientum:ambientum /var/log/nginx && \
    chown -R ambientum:ambientum /var/lib/nginx && \
    chmod +x /home/start.sh && \
    chown -R ambientum:ambientum /home/ambientum

RUN apk add --no-cache \
    xvfb \
    # Additionnal dependencies for better rendering
    ttf-freefont \
    fontconfig \
    dbus \
    && \
    # Install wkhtmltopdf from `testing` repository
    apk add qt5-qtbase-dev \
    wkhtmltopdf \
    --no-cache \
    --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ \
    --allow-untrusted \
    && \
    # Wrapper for xvfb
    mv /usr/bin/wkhtmltopdf /usr/bin/wkhtmltopdf-origin && \
    echo $'#!/usr/bin/env sh\n\
Xvfb :0 -screen 0 1024x768x24 -ac +extension GLX +render -noreset & \n\
DISPLAY=:0.0 wkhtmltopdf-origin $@ \n\
killall Xvfb\
' > /usr/bin/wkhtmltopdf && \
    chmod +x /usr/bin/wkhtmltopdf

RUN apk add nodejs

# Define the running user
USER ambientum

# Pre generate some SSL
# YOU SHOULD REPLACE WITH YOUR OWN CERT.
RUN openssl req -x509 -nodes -days 3650 \
   -newkey rsa:2048 -keyout /home/ssl/nginx.key \
   -out /home/ssl/nginx.crt -subj "/C=AM/ST=Ambientum/L=Ambientum/O=Ambientum/CN=*.dev" && \
   openssl dhparam -out /home/ssl/dhparam.pem 2048

# Application directory
WORKDIR "/var/www/app"

# Expose webserver port
EXPOSE 8080

# Starts a single shell script that puts php-fpm as a daemon and nginx on foreground
CMD ["/home/start.sh"]
