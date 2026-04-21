FROM python:3.9-slim

# Install system dependencies required by Aeneas
RUN apt-get update && apt-get install -y \
    ffmpeg \
    espeak \
    build-essential \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Aeneas strictly requires numpy to be installed first
RUN pip install --no-cache-dir numpy==1.23.5

# Copy requirements and install
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the API script
COPY main.py .

# Expose API port
EXPOSE 8009

# Start the FastAPI server
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8009"]
