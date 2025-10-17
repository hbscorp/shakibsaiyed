FROM python:3.12-slim AS base

WORKDIR /app

COPY resources/requirements.txt ./requirements.txt
COPY src ./src

RUN groupadd -r appuser && useradd -r -g appuser -m appuser \
 && chown -R appuser:appuser /app && chmod -R 755 /app

USER appuser

FROM base AS builder

RUN pip install --no-cache-dir --user -r /app/requirements.txt

FROM base

COPY --from=builder /home/appuser/.local /home/appuser/.local

ENV PATH=/home/appuser/.local/bin:$PATH PYTHONPATH=/app/src

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD python - <<'PY' || exit 1
from urllib.request import urlopen
try:
    urlopen('http://localhost:5000/health').read(); print('ok')
except Exception as e:
    print(e); raise
PY

EXPOSE 5000

ENTRYPOINT ["gunicorn", "--workers", "4", "--bind", "0.0.0.0:5000", "service.app:create_app()"]
