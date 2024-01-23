# Start from the official Swift image
FROM swift:5.9.2

# Set working directory in Docker
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . .

# Compile the project
RUN swift build
CMD swift test