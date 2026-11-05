# --- Stage 1: Prune monorepo ---
FROM node:20-alpine AS builder
RUN apk add --no-libc-dev libc6-compat
WORKDIR /app
RUN corepack enable
RUN npm install -g turbo
COPY . .
# Extract only what is needed for api-gateway
RUN turbo prune --scope=api-gateway --docker

# --- Stage 2: Install dependencies & Build ---
FROM node:20-alpine AS installer
RUN apk add --no-libc-dev libc6-compat
WORKDIR /app

# Copy lock files and manifests
COPY .gitignore .gitignore
COPY --from=builder /app/out/json/ .
COPY --from=builder /app/out/pnpm-lock.yaml ./pnpm-lock.yaml
COPY --from=builder /app/out/pnpm-workspace.yaml ./pnpm-workspace.yaml

# Enable Corepack for pnpm (version pinned by packageManager in package.json)
RUN corepack enable

# Install dependencies
RUN pnpm install --frozen-lockfile

# Copy source code and build
COPY --from=builder /app/out/full/ .
COPY turbo.json turbo.json

RUN pnpm turbo build --filter=api-gateway...

# pnpm keeps dependencies in per-package node_modules, so create a
# self-contained production bundle of api-gateway for the runner stage
RUN pnpm --filter=api-gateway deploy --legacy --prod /prod/api-gateway

# --- Stage 3: Runner ---
FROM node:20-alpine AS runner
WORKDIR /app

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nestjs
USER nestjs

COPY --from=installer /app/apps/api-gateway/dist ./dist
COPY --from=installer /prod/api-gateway/package.json ./package.json
COPY --from=installer /prod/api-gateway/node_modules ./node_modules

EXPOSE 3000

CMD ["node", "dist/main.js"]