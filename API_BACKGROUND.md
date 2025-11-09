# API 后台运行指南

## 当前状态

✅ **API 正在后台运行**
- 监听端口：**5050**
- 访问地址：http://localhost:5050
- 日志文件：`/tmp/shipapi.log`
- 进程 ID：可通过 `ps aux | grep dotnet` 查看

## 启动 API（后台运行）

```bash
cd /Users/ricky/source/ship-management-system/src/ShipManagement.API

# 在后台启动 API
nohup dotnet run --urls "http://localhost:5050" > /tmp/shipapi.log 2>&1 &

# 查看启动状态
tail -f /tmp/shipapi.log
```

## 管理 API 进程

### 查看运行状态
```bash
# 检查端口是否在监听
lsof -i :5050

# 查看进程
ps aux | grep "dotnet.*ShipManagement"
```

### 查看日志
```bash
# 实时查看日志
tail -f /tmp/shipapi.log

# 查看最后20行
tail -20 /tmp/shipapi.log
```

### 停止 API
```bash
# 方法1：通过进程名
pkill -f "dotnet.*ShipManagement"

# 方法2：通过进程ID（先用 ps aux 查找PID）
kill <PID>

# 方法3：强制停止
killall -9 dotnet
```

### 重启 API
```bash
# 停止旧进程
pkill -f "dotnet.*ShipManagement"

# 等待2秒
sleep 2

# 重新启动
cd /Users/ricky/source/ship-management-system/src/ShipManagement.API
nohup dotnet run --urls "http://localhost:5050" > /tmp/shipapi.log 2>&1 &
```

## 测试 API

### 使用 curl

```bash
# 1. 获取所有船舶
curl http://localhost:5050/api/ships

# 2. 获取活跃船舶
curl http://localhost:5050/api/ships/active

# 3. 获取船员列表（分页）
curl "http://localhost:5050/api/crew?shipCode=SHIP01&pageNumber=1&pageSize=10"

# 4. 搜索船员
curl "http://localhost:5050/api/crew?shipCode=SHIP01&searchTerm=John&pageSize=10"

# 5. 获取财务报表详情
curl "http://localhost:5050/api/financial/report/detail?shipCode=SHIP01&period=2025-01"

# 6. 获取财务报表汇总
curl "http://localhost:5050/api/financial/report/summary?shipCode=SHIP01&period=2025-01"

# 7. 获取所有用户
curl http://localhost:5050/api/users

# 8. 创建新船舶
curl -X POST http://localhost:5050/api/ships \
  -H "Content-Type: application/json" \
  -d '{
    "shipCode": "SHIP99",
    "shipName": "Test Ship",
    "fiscalYearCode": "0112",
    "status": "Active"
  }'
```

### 使用浏览器

直接访问：**http://localhost:5050**

这会打开 Swagger UI，可以交互式测试所有 API 端点。

### 使用 Python
```python
import requests

# 获取船舶列表
response = requests.get('http://localhost:5050/api/ships')
ships = response.json()
print(f"共 {len(ships)} 艘船")

# 获取船员列表
response = requests.get('http://localhost:5050/api/crew', params={
    'shipCode': 'SHIP01',
    'pageSize': 10
})
crew_data = response.json()
print(f"船员总数: {crew_data['totalRecords']}")
```

## 测试结果示例

### ✅ 测试1: 获取所有船舶
```
共 5 艘船
  - SHIP03: Black Pearl (Active)
  - SHIP01: Flying Dutchman (Active)
  - SHIP05: HMS Endeavour (Inactive)
  - SHIP04: Queen Anne's Revenge (Active)
  - SHIP02: Thousand Sunny (Active)
```

### ✅ 测试2: 获取船员列表（分页）
```
总记录数: 20, 当前页: 1/4
船员列表:
  1. Soka Philip - Master (Relief Due)
  2. John Masterbear - Chief Officer (Relief Due)
  3. Michael Chen - Second Officer (Relief Due)
  4. Robert Johnson - Third Officer (Onboard)
  5. Masteros Philip - Chief Engineer (Relief Due)
```

### ✅ 测试3: 财务报表详情
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

## 常见问题

### 端口被占用
如果端口5050被占用，可以使用其他端口：
```bash
dotnet run --urls "http://localhost:5051"
```

### API 无响应
1. 检查进程是否运行：`ps aux | grep dotnet`
2. 查看日志：`tail -50 /tmp/shipapi.log`
3. 检查防火墙设置

### 数据库连接错误
检查 `appsettings.json` 中的连接字符串是否正确：
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=tcp:sqlshipmasys.database.windows.net,1433;..."
  }
}
```

## 生产环境部署

对于生产环境，建议使用：
- **systemd** (Linux)
- **launchd** (macOS)
- **Docker** (推荐)

### 使用 Docker Compose
```bash
docker-compose up -d
```

这会在后台启动 API 和 SQL Server。

---

**当前 API 正在运行，可以直接使用！** 🚀
