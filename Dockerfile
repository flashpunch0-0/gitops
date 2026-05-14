# Stage 1: Builder
FROM python:3.12-alpine as builder
# Alpine requires build dependencies for packages like psycopg2 or other C-extensions
RUN apk add --no-cache gcc musl-dev postgresql-dev python3-dev
WORKDIR /app
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# Stage 2: Final Runtime
FROM python:3.12-alpine
WORKDIR /app

# Install runtime dependencies (like libpq for PostgreSQL support)
RUN apk add --no-cache libpq

# Copy only the installed packages from builder
COPY --from=builder /root/.local /root/.local
COPY . .

# SHIELD: Create and use a non-root user for security (Checkov requirement)
RUN adduser -D myuser && chown -R myuser:myuser /app
USER myuser

ENV PATH=/root/.local/bin:$PATH
EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]