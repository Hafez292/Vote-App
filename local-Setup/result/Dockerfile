FROM node:18-slim

WORKDIR /app

# Copy package files first (cache optimization)
COPY package.json package-lock.json ./

# Install dependencies as root
RUN npm install --production

# Copy the rest of the application
COPY . .

# Create non-root user
RUN useradd -m result && chown -R result:result /app

USER result

EXPOSE 8081

CMD ["node", "server.js"]
