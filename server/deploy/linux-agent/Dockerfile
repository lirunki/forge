FROM python:3.12-slim-bookworm

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    FORGE_AGENT_HOST=0.0.0.0 \
    FORGE_AGENT_PORT=8787 \
    FORGE_AGENT_WORKSPACE=/workspace \
    FORGE_AGENT_FSROOT=/workspace/fs \
    FORGE_AGENT_HOME=/workspace/home \
    FORGE_AGENT_TMPDIR=/tmp \
    FORGE_AGENT_JOB_UID=10000 \
    FORGE_AGENT_JOB_GID=10000

RUN apt-get update \
    && apt-get install -y --no-install-recommends bash ca-certificates curl dpkg git jq nodejs npm passwd \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd --gid 10000 forgeagent \
    && useradd --uid 10000 --gid 10000 --home-dir /workspace/home --shell /bin/bash --no-create-home forgeagent \
    && mkdir -p /app /workspace/fs /workspace/home \
    && chown -R 10000:10000 /workspace

# Termux-compatible `pkg` front-end: jobs run as an unprivileged UID under a
# read-only root filesystem, so `pkg` resolves Debian packages with apt and
# extracts them into the per-user writable prefix ($HOME/.local) with PATH
# wrappers — the same user-space model Termux uses, so self-installing apps
# (e.g. `pkg install -y ffmpeg`) work without system-root writes.
COPY pkg /usr/local/bin/pkg
COPY linux_agent.py /app/linux_agent.py

EXPOSE 8787
USER 0:0
ENTRYPOINT ["python", "/app/linux_agent.py"]
