FROM python:3.9-slim

# Install system dependencies required by Aeneas
RUN apt-get update && apt-get install -y \
    ffmpeg \
    espeak \
    build-essential \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 1. Upgrade core build tools first
RUN pip install --no-cache-dir --upgrade pip setuptools wheel

# 2. Install numpy independently so it exists in the system
RUN pip install --no-cache-dir numpy==1.23.5

# Copy requirements
COPY requirements.txt .

# 3. CRITICAL FIX: Add --no-build-isolation so Aeneas can see numpy during its installation
RUN pip install --no-cache-dir --no-build-isolation -r requirements.txt

# Copy the API script
COPY main.py .

# Expose API port
EXPOSE 8000

# Start the FastAPI server
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
