# =========================
# Stage 1 - Build Angular
# =========================
FROM node:22-alpine AS build

# Set working directory
WORKDIR /app

# Copy package files first (for caching)
COPY package*.json ./

# Install dependencies (faster & clean for CI/CD)
RUN npm ci

# Copy remaining source code
COPY . .

# Build Angular app for production
RUN npm run build -- --configuration production


# =========================
# Stage 2 - Nginx
# =========================
FROM nginx:alpine

# Remove default nginx config
RUN rm /etc/nginx/conf.d/default.conf

# Copy Angular build output (Angular 17+ uses browser folder)
COPY --from=build /app/dist/manojportfolio/browser /usr/share/nginx/html

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port
EXPOSE 80

# Run nginx in foreground
CMD ["nginx", "-g", "daemon off;"]