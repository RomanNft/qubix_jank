# Use the official PostgreSQL image
FROM postgres:latest

# Set environment variables for PostgreSQL
ENV POSTGRES_DB=facebook
ENV POSTGRES_USER=postgres
ENV POSTGRES_PASSWORD=123456

# Expose the PostgreSQL port
EXPOSE 5432
