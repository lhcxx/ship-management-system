# Configuration Guide

## Overview

This project uses centralized configuration management to avoid hardcoding sensitive information like database connection strings. All projects read configuration from `appsettings.json` files, and Docker uses environment variables.

## Configuration Files

### 1. API Project Configuration

**Location**: `src/ShipManagement.API/appsettings.json`

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=tcp:yourserver.database.windows.net,1433;Initial Catalog=ship;User ID=username;Password=password;Encrypt=True;TrustServerCertificate=False;"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*"
}
```

### 2. Database Tools Configuration

All database tools (`DatabaseInitializer`, `ConnectionTester`, `QuickTest`) share the same configuration structure.

**Locations**:
- `database/DatabaseInitializer/appsettings.json`
- `database/ConnectionTester/appsettings.json`
- `database/QuickTest/appsettings.json`

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=tcp:sqlshipmasys.database.windows.net,1433;Initial Catalog=ship;User ID=ship-admin;Password=YOUR_PASSWORD_HERE;Encrypt=True;TrustServerCertificate=False;"
  }
}
```

**Important**: Replace `YOUR_PASSWORD_HERE` with your actual database password.

### 3. Docker Configuration

**Location**: `.env` (create from `.env.example`)

```bash
# Copy the example file
cp .env.example .env

# Edit with your values
nano .env
```

**Example `.env` file**:
```env
SA_PASSWORD=YourStrong@Passw0rd
DB_NAME=ShipManagementDB
API_PORT=5000
SQL_PORT=1433
```

The `docker-compose.yml` automatically reads these variables.

## Setup Instructions

### First-Time Setup

1. **Configure API Connection String**

```bash
cd src/ShipManagement.API
# Edit appsettings.json with your database details
nano appsettings.json
```

2. **Configure Database Tools**

```bash
# Update DatabaseInitializer
cd database/DatabaseInitializer
nano appsettings.json

# Update ConnectionTester
cd ../ConnectionTester
nano appsettings.json

# Update QuickTest
cd ../QuickTest
nano appsettings.json
```

3. **Configure Docker (Optional)**

```bash
# Create .env from template
cp .env.example .env

# Edit with your values
nano .env
```

### Using Database Initialization Scripts

The database initialization scripts (`init-db.sh` / `init-db.bat`) automatically use environment variables or prompt for password:

```bash
# Set environment variables (optional)
export DB_SERVER="sqlshipmasys.database.windows.net"
export DB_NAME="ship"
export DB_USER="ship"
export DB_PASSWORD="yourpassword"

# Run the script
cd database
./init-db.sh
```

The script will:
- Auto-detect if you're using Azure SQL or Local SQL Server
- Use appropriate connection options
- Prompt for password if not set
- Test connection before initialization
- Ask if you want to cleanup existing data

### Using Azure SQL Server

For Azure SQL Server, use this connection string format:

```
Server=tcp:yourserver.database.windows.net,1433;
Initial Catalog=yourdatabase;
Persist Security Info=False;
User ID=yourusername;
Password=yourpassword;
MultipleActiveResultSets=False;
Encrypt=True;
TrustServerCertificate=False;
Connection Timeout=30;
```

**Configuration example**:
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=tcp:sqlshipmasys.database.windows.net,1433;Initial Catalog=ship;User ID=ship-admin;Password=YourPassword123!;Encrypt=True;TrustServerCertificate=False;"
  }
}
```

### Using Local SQL Server

For local SQL Server, use this connection string format:

```
Server=localhost,1433;
Database=ShipManagementDB;
User Id=sa;
Password=yourpassword;
TrustServerCertificate=True;
MultipleActiveResultSets=true
```

**Configuration example**:
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost,1433;Database=ShipManagementDB;User Id=sa;Password=YourStrong@Passw0rd;TrustServerCertificate=True;"
  }
}
```

## Security Best Practices

### ⚠️ Never Commit Sensitive Data

The following files contain sensitive information and should **NEVER** be committed:

- `appsettings.json` (with real passwords)
- `.env` (with real passwords)
- Any file with actual connection strings

### ✅ Use .gitignore

The project includes a `.gitignore` that excludes:
```gitignore
appsettings.json
appsettings.*.json
.env
*.user
```

### ✅ Use Templates

Always commit template files with placeholder values:
- `appsettings.example.json`
- `.env.example`

### ✅ Use Azure Key Vault (Production)

For production, consider using Azure Key Vault:

```bash
# Install package
dotnet add package Azure.Extensions.AspNetCore.Configuration.Secrets

# In Program.cs
builder.Configuration.AddAzureKeyVault(
    new Uri($"https://{keyVaultName}.vault.azure.net/"),
    new DefaultAzureCredential()
);
```

## Configuration by Environment

### Development
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost,1433;Database=ShipManagementDB;..."
  }
}
```

### Staging/Production
Use environment variables or Azure App Configuration:

```bash
# Set environment variable
export ConnectionStrings__DefaultConnection="Server=prod-server..."

# Or use Azure App Service Configuration
# Set in Azure Portal > App Service > Configuration > Application settings
```

## Troubleshooting

### Connection String Not Found

**Error**: `Connection string 'DefaultConnection' not found`

**Solution**:
1. Ensure `appsettings.json` exists in the project directory
2. Check the connection string key is exactly `DefaultConnection`
3. Verify the file is being copied to output directory

### Invalid Connection String

**Error**: `A network-related or instance-specific error occurred`

**Solution**:
1. Verify server address and port
2. Check firewall allows connection
3. Validate username and password
4. For Azure SQL, ensure your IP is whitelisted

### Permission Denied

**Error**: `Login failed for user`

**Solution**:
1. Verify username and password are correct
2. Check user has necessary database permissions
3. For Azure SQL, verify user exists in the database

## Quick Reference

### Connection String Parameters

| Parameter | Description | Example |
|-----------|-------------|---------|
| `Server` | Database server address | `tcp:server.database.windows.net,1433` |
| `Database` / `Initial Catalog` | Database name | `ship` or `ShipManagementDB` |
| `User ID` / `User Id` | Username | `sa` or `ship-admin` |
| `Password` | Password | `YourPassword123!` |
| `Encrypt` | Use encryption | `True` (Azure) or `False` (local) |
| `TrustServerCertificate` | Trust self-signed cert | `False` (Azure) or `True` (local) |
| `MultipleActiveResultSets` | MARS enabled | `True` or `False` |
| `Connection Timeout` | Timeout in seconds | `30` |

### Configuration Hierarchy

Environment variables override appsettings.json:

```
Environment Variables  (highest priority)
    ↓
appsettings.{Environment}.json
    ↓
appsettings.json  (lowest priority)
```

---

**Important**: Always update your `appsettings.json` files with real credentials before running the applications. Never commit files containing real passwords to version control.
