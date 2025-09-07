FROM node:22.19-alpine AS deps
WORKDIR /app
COPY package*.json ./

RUN npm ci --omit=dev

# ---
FROM node:22.19-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production

COPY --from=deps /app/node_modules ./node_modules

COPY server.js ./

RUN adduser -D app
USER app

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1

CMD ["node", "server.js"]