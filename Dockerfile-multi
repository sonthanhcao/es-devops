# Stage 1: Build and Test
FROM node:20-slim AS build

WORKDIR /starter

# Set environment variable
ARG NODE_ENV=development
ENV NODE_ENV=${NODE_ENV}

# Copy environment file and application code
COPY .env.example .env.example
COPY . .

# Install PM2 globally
RUN npm install pm2 -g

# Install dependencies based on the environment
RUN echo "NODE_ENV=$NODE_ENV" && \
    if [ "$NODE_ENV" = "production" ]; then \
        npm install --omit=dev; \
    else \
        npm install; \
    fi

# Run tests
RUN npm test

# Stage 2: Production
FROM node:20-slim AS production

WORKDIR /starter

# Set environment variable
ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}

# Copy environment file and application code
COPY .env.example .env.example
COPY --from=build /starter .  # Copy from the build stage

# Install PM2 globally
RUN npm install pm2 -g

# Install production dependencies only
RUN npm install --omit=dev

# Change ownership of the application files to the node user
RUN chown -R node:node /starter

# Switch to the node user
USER node

# Start the application using PM2
CMD ["pm2-runtime", "app.js"]

# Expose the application port
EXPOSE 8080
