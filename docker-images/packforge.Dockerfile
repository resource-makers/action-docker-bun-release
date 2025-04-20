# Stage 1: Install dependencies and build the application
FROM oven/bun:latest AS builder

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and bun.lockb to leverage Docker's cache
COPY package.json bun.lockb ./

# Install dependencies
RUN bun install

# Copy the rest of the application code
COPY . .

# Build the Next.js application
RUN bun run build

# Stage 2: Set up the production environment
FROM oven/bun:latest AS runner

# Set the working directory
WORKDIR /app

# Copy the built application from the builder stage
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public

# Set environment variables
ENV NODE_ENV=production
ENV PORT=3000
ENV HOSTNAME="0.0.0.0"
ENV NEXT_TELEMETRY_DISABLED=1

# Expose the application port
EXPOSE 3000

# Run the Next.js application
CMD ["bun", "server.js"]