# Azure SQL Server Setup Guide

## Connection Information

- **Server**: `sqlshipmasys.database.windows.net`
- **Database**: `ship`
- **Username**: `ship`
- **Password**: `sys2026!`
- **Port**: `1433`

## Current Status

✅ API configured to use Azure SQL Server  
✅ Database initialization tool created  
⚠️  **Firewall rule needed for your IP address**

## Required Action: Add Firewall Rule

### Your Current IP Address
```
124.79.30.209
```

### Option 1: Using Azure Portal (Recommended)

1. **Open Azure Portal**
   - Go to https://portal.azure.com
   - Sign in with your Azure account

2. **Navigate to SQL Server**
   - Search for "SQL servers" in the top search bar
   - Click on your server: `sqlshipmasys`

3. **Add Firewall Rule**
   - In the left menu, click "Networking" (or "Firewalls and virtual networks")
   - Click "+ Add client IP" button
   - Or manually add a rule:
     - **Rule name**: `MyDevMachine` (or any name)
     - **Start IP**: `124.79.30.209`
     - **End IP**: `124.79.30.209`
   - Click "Save"
   - Wait 1-2 minutes for the rule to take effect

### Option 2: Using Azure CLI

```bash
# Login to Azure
az login

# Add firewall rule
az sql server firewall-rule create \
  --resource-group YOUR_RESOURCE_GROUP \
  --server sqlshipmasys \
  --name MyDevMachine \
  --start-ip-address 124.79.30.209 \
  --end-ip-address 124.79.30.209
```

### Option 3: Using PowerShell

```powershell
# Login to Azure
Connect-AzAccount

# Add firewall rule
New-AzSqlServerFirewallRule `
  -ResourceGroupName "YOUR_RESOURCE_GROUP" `
  -ServerName "sqlshipmasys" `
  -FirewallRuleName "MyDevMachine" `
  -StartIpAddress "124.79.30.209" `
  -EndIpAddress "124.79.30.209"
```

## After Adding Firewall Rule

### Step 1: Initialize Database

Run the database initialization tool:

```bash
cd /Users/ricky/source/ship-management-system/database/DatabaseInitializer
dotnet run
```

This will:
- ✅ Test connection to Azure SQL Server
- ✅ Create all tables (9 tables)
- ✅ Insert sample data (100+ crew, 5 ships)
- ✅ Insert financial data (2 years of budget and transactions)
- ✅ Create stored procedures (3 SPs + 4 functions)
- ✅ Display summary of inserted records

Expected output:
```
==========================================
Azure SQL Database Initialization
==========================================

Testing connection to Azure SQL Server...
✓ Connection successful!
Database: ship
Server Version: 15.00.xxxx

Step 1/4: Creating database schema (tables)...
✓ Success: Creating database schema (tables)

Step 2/4: Inserting sample data (ships, users, crew)...
✓ Success: Inserting sample data (ships, users, crew)

Step 3/4: Inserting financial data (budget and transactions)...
✓ Success: Inserting financial data (budget and transactions)

Step 4/4: Creating stored procedures...
✓ Success: Creating stored procedures

==========================================
✓ Azure SQL Database Initialization Complete!
==========================================

Database Summary:
------------------------------------------
  Ships                    :      5 records
  Users                    :      5 records
  CrewMembers              :    100 records
  CrewRanks                :     18 records
  ChartOfAccounts          :     50 records
  BudgetData               :    XXX records
  AccountTransactions      :    XXX records
------------------------------------------

You can now run the API with: dotnet run
The API will connect to: sqlshipmasys.database.windows.net
```

### Step 2: Run the API

```bash
cd /Users/ricky/source/ship-management-system/src/ShipManagement.API
dotnet run
```

### Step 3: Test the API

Open your browser and navigate to:
- **Swagger UI**: http://localhost:5000 (or the URL shown in console)

Or use curl:

```bash
# Get all ships
curl http://localhost:5000/api/ships

# Get crew list
curl "http://localhost:5000/api/crew?shipCode=SHIP01&pageNumber=1&pageSize=10"

# Get financial report
curl "http://localhost:5000/api/financial/report/detail?shipCode=SHIP01&period=2025-01"
```

## Troubleshooting

### Error: "Client with IP address is not allowed to access the server"

**Solution**: Add your IP address to Azure SQL Server firewall rules (see above)

### Error: "Cannot open server 'sqlshipmasys' requested by the login"

**Causes**:
1. Firewall rule not added
2. Firewall rule not yet effective (wait 1-2 minutes)
3. Your IP address changed (re-add the new IP)

**Check your current IP**:
```bash
curl ifconfig.me
```

### Error: "Login failed for user 'ship'"

**Solution**: Verify the password in connection string is correct: `sys2026!`

### Connection Timeout

**Solution**: 
1. Check if Azure SQL Server is running
2. Verify the server name: `sqlshipmasys.database.windows.net`
3. Check your internet connection

## Database Management

### Using Azure Data Studio (Recommended)

1. Download from: https://docs.microsoft.com/sql/azure-data-studio/download
2. Create a new connection:
   - **Server**: `sqlshipmasys.database.windows.net`
   - **Authentication type**: SQL Login
   - **User name**: `ship`
   - **Password**: `sys2026!`
   - **Database**: `ship`
   - **Encrypt**: True

### Using SQL Server Management Studio (SSMS)

1. Download from: https://aka.ms/ssmsfullsetup
2. Connect with the same credentials as above

### Using sqlcmd (Command Line)

```bash
# Install sqlcmd (macOS)
brew install microsoft/mssql-release/mssql-tools18

# Connect to database
sqlcmd -S sqlshipmasys.database.windows.net -d ship -U ship -P 'sys2026!' -N

# Run a query
1> SELECT COUNT(*) FROM Ships;
2> GO
```

## Security Best Practices

⚠️ **Important**: The connection string contains credentials in plain text.

For production:

1. **Use Azure Key Vault**
   ```json
   {
     "ConnectionStrings": {
       "DefaultConnection": "@Microsoft.KeyVault(SecretUri=https://your-vault.vault.azure.net/secrets/SqlConnectionString)"
     }
   }
   ```

2. **Use Managed Identity**
   - Enable Managed Identity on your App Service
   - Grant SQL Server permissions to the Managed Identity
   - Remove username/password from connection string

3. **Use Environment Variables**
   ```bash
   export SQL_PASSWORD="sys2026!"
   ```
   
   Then in code:
   ```csharp
   var password = Environment.GetEnvironmentVariable("SQL_PASSWORD");
   ```

4. **Restrict IP Access**
   - Only allow specific IP addresses in firewall rules
   - Use Azure Virtual Network for production deployments

## Cost Management

Azure SQL Database charges by:
- **DTU/vCore**: Compute resources
- **Storage**: Database size
- **Backup**: Automated backups

To minimize costs during development:
- Use the lowest tier (Basic or S0)
- Delete the database when not in use
- Use serverless tier for on-demand scaling

## Next Steps

After successful database initialization:

1. ✅ Test all API endpoints via Swagger
2. ✅ Run unit tests: `dotnet test`
3. ✅ Deploy to Azure App Service (optional)
4. ✅ Set up CI/CD pipeline (optional)
5. ✅ Monitor database performance in Azure Portal

---

**Need Help?**

If you encounter any issues:
1. Check the error message carefully
2. Verify firewall rules in Azure Portal
3. Test connection using Azure Data Studio
4. Check database logs in Azure Portal

**Happy Coding! 🚢☁️**
