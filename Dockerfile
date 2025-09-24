# Use official Python base image
FROM python:3.11-slim

# Set workdir
WORKDIR /app

# Install dependencies
COPY app/requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy application
COPY app/ ./

# Expose port
EXPOSE 8080

# Run app
CMD ["python", "app.py"]
