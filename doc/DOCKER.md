# Docker Deployment Guide

## 🐳 Docker Configuration

This project includes Docker and Docker Compose configurations for easy deployment and development.

## Prerequisites

### Install Docker Desktop

**macOS:**
1. Visit https://www.docker.com/products/docker-desktop
2. Download Docker Desktop for Mac (choose Apple Silicon or Intel based on your Mac)
3. Install by dragging to Applications folder
4. Start Docker Desktop

**Windows:**
1. Visit https://www.docker.com/products/docker-desktop
2. Download Docker Desktop for Windows
3. Run installer
4. Restart computer if prompted

**Linux:**
```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

**Verify Installation:**
```bash
docker --version
docker compose version
```

## 📦 What's Included

### Services

The `docker-compose.yml` defines two services:

**1. sqlserver**
- Image: `mcr.microsoft.com/mssql/server:2022-latest`
- Port: 1433
- Environment:
  - `ACCEPT_EULA=Y`
  - `SA_PASSWORD=YourStrong@Passw0rd`
- Volume: `sqldata` for data persistence
- Health check: Ensures database is ready before starting API

**2. api**
- Built from `Dockerfile`
- Port: 5000
- Depends on: sqlserver
- Environment:
  - Connection string configured for Docker network
- Waits for database health check before starting

### Docker Network

Services communicate via a Docker network:
- Service name `sqlserver` is the hostname
- API connects to `sqlserver:1433`

## 🚀 Quick Start

### Start All Services

```bash
# From project root
docker compose up --build
```

This will:
1. ✅ Build the .NET API image
2. ✅ Pull SQL Server 2022 image
3. ✅ Start SQL Server container
4. ✅ Wait for database to be ready
5. ✅ Start API container
6. ✅ Initialize database with sample data

**Access Points:**
- API: http://localhost:5000
- Swagger UI: http://localhost:5000
- SQL Server: localhost:1433
  - Username: `sa`
  - Password: `YourStrong@Passw0rd`

### Start in Background (Detached Mode)

```bash
docker compose up -d --build
```

### View Logs

```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f api
docker compose logs -f sqlserver

# Last 50 lines
docker compose logs --tail=50 api
```

### Stop Services

```bash
# Stop containers (keeps data)
docker compose stop

# Stop and remove containers (keeps data)
docker compose down

# Stop and remove everything including volumes (DELETES DATA)
docker compose down -v
```

## 🔧 Advanced Usage

### Rebuild API Only

```bash
docker compose up -d --build api
```

### Access Database

**Using Docker exec:**
```bash
docker compose exec sqlserver /opt/mssql-tools/bin/sqlcmd \
  -S localhost -U sa -P 'YourStrong@Passw0rd' \
  -Q "SELECT COUNT(*) FROM ShipManagementDB.dbo.Ships"
```

**Using Azure Data Studio or SSMS:**
- Server: `localhost,1433`
- Username: `sa`
- Password: `YourStrong@Passw0rd`
- Database: `ShipManagementDB`

### View Container Status

```bash
# List running containers
docker compose ps

# Detailed information
docker compose ps -a
```

### Restart Services

```bash
# Restart all services
docker compose restart

# Restart specific service
docker compose restart api
```

### Scale Services (if needed)

```bash
# Run multiple API instances (requires load balancer)
docker compose up -d --scale api=3
```

## 🛠 Customization

### Change Port Mappings

Edit `docker-compose.yml`:

```yaml
services:
  api:
    ports:
      - "8080:8080"  # Change to your preferred port
```

### Change SA Password

Edit `docker-compose.yml`:

```yaml
services:
  sqlserver:
    environment:
      - SA_PASSWORD=YourNewPassword123!
```

**Important:** Also update in API environment:
```yaml
services:
  api:
    environment:
      - ConnectionStrings__DefaultConnection=Server=sqlserver;Database=ShipManagementDB;User Id=sa;Password=YourNewPassword123!;TrustServerCertificate=True
```

### Use Different SQL Server Version

Edit `docker-compose.yml`:

```yaml
services:
  sqlserver:
    image: mcr.microsoft.com/mssql/server:2019-latest
    # or
    image: mcr.microsoft.com/mssql/server:2017-latest
```

### Add Environment Variables

Create `.env` file in project root:

```env
SA_PASSWORD=YourStrong@Passw0rd
API_PORT=5000
SQL_PORT=1433
```

Update `docker-compose.yml`:
```yaml
services:
  sqlserver:
    environment:
      - SA_PASSWORD=${SA_PASSWORD}
```

## 📊 Database Initialization

### Automatic Initialization

The Docker setup automatically initializes the database when first started:

1. SQL Server container starts
2. Health check waits for SQL Server to be ready
3. API container starts
4. Database initialization runs on first connection

### Manual Initialization

If you need to reinitialize:

```bash
# Connect to SQL Server container
docker compose exec sqlserver /opt/mssql-tools/bin/sqlcmd \
  -S localhost -U sa -P 'YourStrong@Passw0rd'

# In sqlcmd prompt:
1> USE ShipManagementDB;
2> GO
3> -- Run your SQL commands
```

Or copy SQL files into container:

```bash
# Copy SQL files
docker compose cp database/01_CreateTables.sql sqlserver:/tmp/

# Execute
docker compose exec sqlserver /opt/mssql-tools/bin/sqlcmd \
  -S localhost -U sa -P 'YourStrong@Passw0rd' \
  -i /tmp/01_CreateTables.sql
```

## 🔍 Monitoring and Health Checks

### Check Service Health

```bash
# View health status
docker compose ps

# Inspect specific service
docker inspect ship-management-system-sqlserver-1 | grep -A 10 Health
```

### API Health Endpoint

```bash
curl http://localhost:5000/health
```

### Database Health Check

The SQL Server health check runs:
```bash
/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $SA_PASSWORD -Q "SELECT 1"
```


### Optimize Docker Build

The Dockerfile uses multi-stage builds:
- **Stage 1 (build)**: Builds the application
- **Stage 2 (runtime)**: Minimal runtime image

### Volume Performance

Already optimized:
- Named volume `sqldata` for database persistence
- No unnecessary bind mounts

### Resource Limits

Add resource limits if needed:

```yaml
services:
  api:
    deploy:
      resources:
        limits:
          cpus: '1'
          memory: 512M
```

## 🔐 Security Best Practices

### Production Deployment

**1. Use Secrets:**
```yaml
services:
  sqlserver:
    secrets:
      - sa_password
secrets:
  sa_password:
    external: true
```

**2. Use Environment Files:**
```bash
# Create .env.production
echo "SA_PASSWORD=ProductionPassword123!" > .env.production

# Use it
docker compose --env-file .env.production up
```

**3. Don't Expose SQL Server:**
```yaml
services:
  sqlserver:
    # Remove ports section for production
    # Only API can access via Docker network
```

**4. Use HTTPS:**
Configure SSL certificates for production API

**5. Update Regularly:**
```bash
docker compose pull
docker compose up -d --build
```

## 📚 Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [SQL Server on Docker](https://hub.docker.com/_/microsoft-mssql-server)
- [.NET on Docker](https://hub.docker.com/_/microsoft-dotnet)

## 🆘 Getting Help

If you encounter issues:

1. Check logs: `docker compose logs`
2. Check container status: `docker compose ps`
3. Verify health checks: `docker inspect <container-id>`
4. Review this troubleshooting section
5. Check Docker Desktop resources allocation

---

**Quick Commands Reference:**

```bash
# Start
docker compose up -d --build

# Stop
docker compose down

# Logs
docker compose logs -f

# Status
docker compose ps

# Rebuild
docker compose build --no-cache

# Clean restart
docker compose down && docker compose up --build
```
