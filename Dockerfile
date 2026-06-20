# Use an official Python runtime as a parent image
FROM python:3.11-slim-bullseye

# Set the working directory in the container
WORKDIR /MoneyPrinterTurbo
RUN chmod 777 /MoneyPrinterTurbo
ENV PYTHONPATH="/MoneyPrinterTurbo"

# Install system dependencies (default Debian mirrors — reliable on Railway/US).
RUN apt-get update && apt-get install -y --no-install-recommends \
        git \
        bash \
        imagemagick \
        ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# Allow ImageMagick to read/write the temp files MoviePy needs for captions.
RUN sed -i '/<policy domain="path" rights="none" pattern="@\*"/d' /etc/ImageMagick-6/policy.xml || true

# Install Python dependencies first to leverage Docker layer caching.
COPY requirements.txt ./
RUN pip install --no-cache-dir --retries 3 --timeout 120 -r requirements.txt

# Copy the rest of the codebase.
COPY . .

EXPOSE 8501

# Generate config.toml from Railway env vars, then launch the Streamlit UI on $PORT.
CMD ["bash", "/MoneyPrinterTurbo/entrypoint.sh"]
