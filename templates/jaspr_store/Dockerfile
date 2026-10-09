# syntax=docker/dockerfile:1

# ---- build stage -----------------------------------------------------------
# Pinned: Jaspr's build pipeline is coupled to specific build_runner /
# build_web_compilers versions (see README "Version pinning").
FROM dart:3.12 AS build
WORKDIR /src

# Build-time configuration is compiled into the binary (--dart-define).
ARG SITE_URL=http://localhost:8080
ARG APP_ENV=production

COPY pubspec.yaml pubspec.lock ./
RUN dart pub get
RUN dart pub global activate jaspr_cli 0.23.4
ENV PATH="$PATH:/root/.pub-cache/bin"

COPY . .
RUN dart pub get --offline
# Produces build/jaspr/app (AOT-compiled server) and build/jaspr/web (assets + island JS).
RUN jaspr build --dart-define=APP_ENV=${APP_ENV} --dart-define=SITE_URL=${SITE_URL}

# ---- runtime stage ---------------------------------------------------------
# The AOT executable needs glibc but nothing else; slim Debian keeps it small.
FROM debian:bookworm-slim
RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates \
 && rm -rf /var/lib/apt/lists/* \
 && useradd --system --uid 10001 --no-create-home app
WORKDIR /app
# `web/` must sit next to the executable: Jaspr serves static files from it.
COPY --from=build /src/build/jaspr/app /app/app
COPY --from=build /src/build/jaspr/web /app/web
USER app

# Cloud Run / Fly / Render inject PORT at runtime; the server reads it.
ENV PORT=8080
# Set these at deploy time (see README):
#   SITE_URL     public origin, e.g. https://shop.example   (canonical URLs, sitemap, JSON-LD)
#   CART_SECRET  32+ random characters, stable across restarts
EXPOSE 8080
# Health check: configure your platform to probe GET /healthz (200 "ok").
CMD ["/app/app"]
