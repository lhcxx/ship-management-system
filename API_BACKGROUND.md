# API Background Running Guide

## Current Status

✅ **API is running in the background**
- Listening on port: **5050**
- Access URL: http://localhost:5050
- Log file: `/tmp/shipapi.log`
- Process ID: Check with `ps aux | grep dotnet`

## Starting the API (Background Mode)

```bash
cd /Users/ricky/source/ship-management-system/src/ShipManagement.API

# Start API in background
nohup dotnet run --urls "http://localhost:5050" > /tmp/shipapi.log 2>&1 &

# View startup status
tail -f /tmp/shipapi.log
```

## Managing the API Process

### Check Running Status
```bash
# Check if port is listening
lsof -i :5050

# View process
ps aux | grep "dotnet.*ShipManagement"
```

### View Logs
```bash
# Real-time log viewing
tail -f /tmp/shipapi.log

# View last 20 lines
tail -20 /tmp/shipapi.log
```

### Stop API
```bash
# Method 1: By process name
pkill -f "dotnet.*ShipManagement"

# Method 2: By process ID (find PID with ps aux first)
kill <PID>

# Method 3: Force stop
killall -9 dotnet
```

### Restart API
```bash
# Stop old process
pkill -f "dotnet.*ShipManagement"

# Wait 2 seconds
sleep 2

# Restart
cd /Users/ricky/source/ship-management-system/src/ShipManagement.API
nohup dotnet run --urls "http://localhost:5050" > /tmp/shipapi.log 2>&1 &
```

## Testing the API

### Using curl

```bash
# 1. Get all ships
curl http://localhost:5050/api/ships

# 2. Get active ships
curl http://localhost:5050/api/ships/active

# 3. Get crew list (paginated)
curl "http://localhost:5050/api/crew?shipCode=SHIP01&pageNumber=1&pageSize=10"

# 4. Search crew
curl "http://localhost:5050/api/crew?shipCode=SHIP01&searchTerm=John&pageSize=10"

# 5. Get financial report details
curl "http://localhost:5050/api/financial/report/detail?shipCode=SHIP01&period=2025-01"

# 6. Get financial report summary
curl "http://localhost:5050/api/financial/report/summary?shipCode=SHIP01&period=2025-01"

# 7. Get all users
curl http://localhost:5050/api/users

# 8. Create new ship
curl -X POST http://localhost:5050/api/ships \
  -H "Content-Type: application/json" \
  -d '{
    "shipCode": "SHIP99",
    "shipName": "Test Ship",
    "fiscalYearCode": "0112",
    "status": "Active"
  }'
```

### Using Browser

Visit directly: **http://localhost:5050**

This will open Swagger UI where you can interactively test all API endpoints.

### Using Python
```python
import requests

# Get ship list
response = requests.get('http://localhost:5050/api/ships')
ships = response.json()
print(f"Total ships: {len(ships)}")

# Get crew list
response = requests.get('http://localhost:5050/api/crew', params={
    'shipCode': 'SHIP01',
    'pageSize': 10
})
crew_data = response.json()
print(f"Total crew: {crew_data['totalRecords']}")
```

## Sample Test Results

### ✅ Test 1: Get All Ships
```
Total 5 ships:
  - SHIP03: Black Pearl (Active)
  - SHIP01: Flying Dutchman (Active)
  - SHIP05: HMS Endeavour (Inactive)
  - SHIP04: Queen Anne's Revenge (Active)
  - SHIP02: Thousand Sunny (Active)
```

### ✅ Test 2: Get Crew List (Paginated)
```
Total records: 20, Current page: 1/4
Crew list:
  1. Soka Philip - Master (Relief Due)
  2. John Masterbear - Chief Officer (Relief Due)
  3. Michael Chen - Second Officer (Relief Due)
  4. Robert Johnson - Third Officer (Onboard)
  5. Masteros Philip - Chief Engineer (Relief Due)
```

### ✅ Test 3: Financial Report Details
```json
[
  {
    "coaDescription": "HEAVY FUEL OIL",
    "accountNumber": "5110000",
    "periodActual": 26060.00,
    "periodBudget": 26200.00,
    "periodVariance": -140.00,
    "ytdActual": 26060.00,
    "ytdBudget": 26200.00,
    "ytdVariance": -140.00
  }
]
```

## Common Issues

### Port Already in Use
If port 5050 is occupied, use a different port:
```bash
dotnet run --urls "http://localhost:5051"
```

### API Not Responding
1. Check if process is running: `ps aux | grep dotnet`
2. View logs: `tail -50 /tmp/shipapi.log`
3. Check firewall settings

### Database Connection Error
Verify the connection string in `appsettings.json` is correct:
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=tcp:sqlshipmasys.database.windows.net,1433;..."
  }
}
```

## Production Deployment

For production environments, it's recommended to use:
- **systemd** (Linux)
- **launchd** (macOS)
- **Docker** (Recommended)

### Using Docker Compose
```bash
docker-compose up -d
```

This starts both the API and SQL Server in the background.

---

**The API is currently running and ready to use!** 🚀

