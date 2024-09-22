FROM node:20-slim
LABEL org.opencontainers.image.source https://github.com/sonthanhcao/es-devops
WORKDIR /starter
ARG NODE_ENV=development
ENV NODE_ENV=${NODE_ENV}

COPY .env.example /starter/.env.example
COPY . /starter

RUN npm install pm2 -g
RUN echo "NODE_ENV=$NODE_ENV"
RUN if [ "$NODE_ENV" = "production" ]; then \
    npm install --omit=dev; \
    else \
    npm install; \
    fi

# Change ownership of the application files to the node user
RUN chown -R node:node /starter

# Switch to the node user
USER node

CMD ["pm2-runtime", "app.js"]

EXPOSE 8080