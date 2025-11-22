FROM python:3.12-slim

RUN apt-get update && apt-get install -y apache2-utils && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy scripts first
COPY make-data.py /app/
COPY generate-votes.sh /app/

# Generate data files at build time
RUN python3 make-data.py

# Set permissions
RUN chmod +x generate-votes.sh
RUN chmod 644 posta postb  # Readable by all

RUN useradd -m senddata
RUN chown -R senddata:senddata /app

# Switch to non-root user
USER senddata

CMD ["./generate-votes.sh"]