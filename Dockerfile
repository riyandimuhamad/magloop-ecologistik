# Stage 1: Build Flutter Web
FROM ghcr.io/cirruslabs/flutter:stable AS build-env

# Set working directory
WORKDIR /app

# Copy project files
COPY . .

# Run flutter build web
RUN flutter pub get
RUN flutter build web --release

# Stage 2: Serve with Nginx
FROM nginx:stable-alpine

# Copy built web files from stage 1
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Custom Nginx config to support Cloud Run (Port 8080)
RUN printf "server {\n  listen 8080;\n  location / {\n    root /usr/share/nginx/html;\n    index index.html;\n    try_files \$uri \$uri/ /index.html;\n  }\n}\n" > /etc/nginx/conf.d/default.conf

# Expose port 8080
EXPOSE 8080

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
