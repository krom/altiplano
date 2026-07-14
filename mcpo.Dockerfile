FROM ghcr.io/open-webui/mcpo:main
# Install uv (for uvx) system-wide
RUN apt-get update && apt-get install -y curl && \
    curl -LsSf https://astral.sh/uv/install.sh | env UV_INSTALL_DIR=/usr/local/bin sh && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
WORKDIR /home/mcpo
# Pin HOME explicitly: the compose "user: 1000:1000" UID has no /etc/passwd
# entry, so $HOME would otherwise resolve to "/" and uv/uvx would try to
# write outside /home/mcpo.
ENV HOME=/home/mcpo
ENV UV_CACHE_DIR=/home/mcpo/.cache/uv
ENV PATH=/home/mcpo/.local/bin:$PATH
# Ensure the cache dir is writable regardless of which UID runs the container
# (e.g. docker-compose "user: 1000:1000" while the image builds as root)
RUN mkdir -p "$UV_CACHE_DIR" && chmod -R 777 /home/mcpo
# Build from local source instead of pulling altiplano from PyPI
COPY --chown=1000:1000 . /home/mcpo/altiplano-src
RUN uv tool install /home/mcpo/altiplano-src && chmod -R 777 /home/mcpo
# Expose mcpo API port
EXPOSE 8000
# MCPO_API_KEY: optional API key used to secure the mcpo endpoint
ENV MCPO_API_KEY=""
# VIKUNJA_URL: Vikunja instance API base URL, e.g. https://your-vikunja-instance.com/api/v1
ENV VIKUNJA_URL=""
# VIKUNJA_API_TOKEN: Vikunja API token (tk_...) or JWT (eyJ...)
ENV VIKUNJA_API_TOKEN=""
# Optional: DEBUG logging (true/false)
ENV DEBUG="false"
# Optional: LOG_LEVEL (error, warn, info, debug)
ENV LOG_LEVEL="info"
# Optional: rate limiting settings
ENV RATE_LIMIT_ENABLED="true"
ENV RATE_LIMIT_PER_MINUTE="60"
ENV RATE_LIMIT_PER_HOUR="1000"
# Default: run mcpo wrapping the locally built altiplano; pass --api-key when MCPO_API_KEY is set
ENTRYPOINT ["/bin/sh", "-c", "exec mcpo --port 8000 ${MCPO_API_KEY:+--api-key \"$MCPO_API_KEY\"} -- altiplano"]
