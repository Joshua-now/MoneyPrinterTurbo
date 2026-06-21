#!/usr/bin/env bash
# Railway entrypoint for MoneyPrinterTurbo.
# Builds config.toml from environment variables (keys live in Railway, not in the repo),
# then launches the Streamlit web UI on Railway's assigned $PORT.
set -e

CONFIG=/MoneyPrinterTurbo/config.toml
OPENAI_BASE_URL="${OPENAI_BASE_URL:-https://api.groq.com/openai/v1}"
OPENAI_MODEL="${OPENAI_MODEL:-llama-3.3-70b-versatile}"

# Pexels key -> the array form MoneyPrinterTurbo expects.
if [ -n "${PEXELS_API_KEY:-}" ]; then
  PEXELS_LINE="pexels_api_keys = [\"${PEXELS_API_KEY}\"]"
else
  PEXELS_LINE="pexels_api_keys = []"
fi

cat > "$CONFIG" <<EOF
[app]
video_source = "pexels"
hide_config = false
${PEXELS_LINE}
pixabay_api_keys = []
llm_provider = "openai"
openai_api_key = "${OPENAI_API_KEY:-}"
openai_base_url = "${OPENAI_BASE_URL}"
openai_model_name = "${OPENAI_MODEL}"
subtitle_provider = "edge"
endpoint = ""
material_directory = ""
enable_redis = false
redis_host = "localhost"
redis_port = 6379
redis_db = 0
redis_password = ""
max_concurrent_tasks = 3

[whisper]
model_size = "large-v3"
device = "CPU"
compute_type = "int8"

[proxy]

[azure]
speech_key = ""
speech_region = ""

[siliconflow]
api_key = ""

[ui]
hide_log = false
EOF

echo "[entrypoint] config.toml written (llm=openai, base=${OPENAI_BASE_URL}, model=${OPENAI_MODEL})"

exec uvicorn app.asgi:app --host 0.0.0.0 --port $PORT
