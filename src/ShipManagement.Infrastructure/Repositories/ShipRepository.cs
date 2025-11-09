using Dapper;
using ShipManagement.Core.Entities;
using ShipManagement.Core.Interfaces;
using ShipManagement.Infrastructure.Data;

namespace ShipManagement.Infrastructure.Repositories;

public class ShipRepository : IShipRepository
{
    private readonly DapperContext _context;

    public ShipRepository(DapperContext context)
    {
        _context = context;
    }

    public async Task<Ship?> GetByCodeAsync(string shipCode)
    {
        using var connection = _context.CreateConnection();
        var sql = "SELECT * FROM Ships WHERE ShipCode = @ShipCode";
        return await connection.QueryFirstOrDefaultAsync<Ship>(sql, new { ShipCode = shipCode });
    }

    public async Task<IEnumerable<Ship>> GetAllAsync()
    {
        using var connection = _context.CreateConnection();
        var sql = "SELECT * FROM Ships ORDER BY ShipName";
        return await connection.QueryAsync<Ship>(sql);
    }

    public async Task<IEnumerable<Ship>> GetActiveShipsAsync()
    {
        using var connection = _context.CreateConnection();
        var sql = "SELECT * FROM Ships WHERE Status = 'Active' ORDER BY ShipName";
        return await connection.QueryAsync<Ship>(sql);
    }

    public async Task<int> CreateAsync(Ship ship)
    {
        using var connection = _context.CreateConnection();
        var sql = @"
            INSERT INTO Ships (ShipCode, ShipName, FiscalYearCode, Status, CreatedAt, UpdatedAt)
            VALUES (@ShipCode, @ShipName, @FiscalYearCode, @Status, GETUTCDATE(), GETUTCDATE())";
        
        return await connection.ExecuteAsync(sql, ship);
    }

    public async Task<int> UpdateAsync(Ship ship)
    {
        using var connection = _context.CreateConnection();
        var sql = @"
            UPDATE Ships 
            SET ShipName = @ShipName,
                FiscalYearCode = @FiscalYearCode,
                Status = @Status,
                UpdatedAt = GETUTCDATE()
            WHERE ShipCode = @ShipCode";
        
        return await connection.ExecuteAsync(sql, ship);
    }
}
