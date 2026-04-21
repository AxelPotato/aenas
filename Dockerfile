FROM python:3.9-slim

# 1. Install system dependencies (libespeak-dev is crucial for the C-extension)
RUN apt-get update && apt-get install -y \
    ffmpeg \
    espeak \
    libespeak-dev \
    build-essential \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 2. Time-travel the build tools: Pin setuptools to a version that still has distutils
RUN pip install --no-cache-dir --upgrade pip
RUN pip install --no-cache-dir "setuptools<60" wheel==0.38.4

# 3. Install the exact numpy version Aeneas expects, plus Cython
RUN pip install --no-cache-dir numpy==1.23.5 Cython==0.29.36

# 4. Compile Aeneas from source using the downgraded tools
RUN pip install --no-cache-dir --no-build-isolation aeneas==1.7.3

# 5. Copy the rest of your requirements and install them
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 6. Copy the API script
COPY main.py .

# Expose API port
EXPOSE 8000

# Start the FastAPI server
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
