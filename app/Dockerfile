# Use official lightweight Python image
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir flask boto3


# Copy app code
COPY . .

# Expose port and run
EXPOSE 5000
CMD ["python", "app.py"]
CMD ["python", "metrics.py"]