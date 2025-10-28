# Use a lightweight Node.js image
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy dependency files first (for better layer caching)
COPY package*.json ./

# Install dependencies
RUN npm install --production

# Copy application source code
COPY . .

# Expose the application port
EXPOSE 8080

# Start the app
CMD ["npm", "start"]
