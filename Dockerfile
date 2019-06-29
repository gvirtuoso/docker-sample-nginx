# Base image
FROM nginx

# Copying files to image
COPY content /usr/share/nginx/html

# Restricting port exposing
EXPOSE 80
