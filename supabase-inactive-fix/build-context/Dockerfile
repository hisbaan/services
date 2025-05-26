FROM python:3.13-alpine

# Install cron and git
RUN apk add --no-cache dcron git

WORKDIR /app

# Clone git repo
RUN git clone https://github.com/travisvn/supabase-inactive-fix.git .

# Copy external files into the image
COPY config.json /app/config.json
COPY crontab.txt /etc/crontabs/root

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Create log directory for cron
RUN mkdir -p /var/log/cron && touch /var/log/cron/cron.log

# Create entrypoint script
RUN echo '#!/bin/sh' > /entrypoint.sh && \
    echo 'crond -b -l 8 && tail -f /var/log/cron/cron.log' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

# Run entrypoint script
CMD ["/entrypoint.sh"]
