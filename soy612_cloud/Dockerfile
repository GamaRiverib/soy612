# syntax=docker/dockerfile:1

# ---- deps: instala TODAS las dependencias (incluye devDependencies para compilar) ----
FROM node:24-alpine AS deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci

# ---- build: compila TypeScript -> dist/ ----
FROM node:24-alpine AS build
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npm run build

# ---- prod-deps: solo dependencias de producción, para una imagen final delgada ----
FROM node:24-alpine AS prod-deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --omit=dev

# ---- runtime: imagen final mínima, usuario sin privilegios ----
FROM node:24-alpine AS runtime
WORKDIR /app
ENV NODE_ENV=production
RUN addgroup -S soy612 && adduser -S soy612 -G soy612
COPY --from=prod-deps /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist
COPY package.json ./
USER soy612

# Cloud Run inyecta PORT (por defecto 8080); ver src/main.ts.
EXPOSE 8080
CMD ["node", "dist/main.js"]
