using Dapper;
using ShipManagement.Core.Entities;
using ShipManagement.Core.DTOs;
using ShipManagement.Core.Interfaces;
using ShipManagement.Infrastructure.Data;

namespace ShipManagement.Infrastructure.Repositories;

public class UserRepository : IUserRepository
{
    private readonly DapperContext _context;

    public UserRepository(DapperContext context)
    {
        _context = context;
    }

    public async Task<User?> GetByIdAsync(int userId)
    {
        using var connection = _context.CreateConnection();
        var sql = "SELECT * FROM Users WHERE UserId = @UserId";
        return await connection.QueryFirstOrDefaultAsync<User>(sql, new { UserId = userId });
    }

    public async Task<IEnumerable<User>> GetAllAsync()
    {
        using var connection = _context.CreateConnection();
        var sql = "SELECT * FROM Users ORDER BY UserName";
        return await connection.QueryAsync<User>(sql);
    }

    public async Task<int> CreateAsync(User user)
    {
        using var connection = _context.CreateConnection();
        var sql = @"
            INSERT INTO Users (UserName, Email, Role, CreatedAt, UpdatedAt)
            VALUES (@UserName, @Email, @Role, GETUTCDATE(), GETUTCDATE());
            SELECT CAST(SCOPE_IDENTITY() AS INT);";
        
        return await connection.ExecuteScalarAsync<int>(sql, user);
    }

    public async Task<UserShipDto?> GetUserWithShipsAsync(int userId)
    {
        using var connection = _context.CreateConnection();
        
        var sql = @"
            SELECT u.UserId, u.UserName, u.Email, u.Role
            FROM Users u
            WHERE u.UserId = @UserId;

            SELECT s.ShipCode, s.ShipName, s.FiscalYearCode, s.Status
            FROM Ships s
            INNER JOIN UserShipAssignments usa ON s.ShipCode = usa.ShipCode
            WHERE usa.UserId = @UserId
            ORDER BY s.ShipName;";

        using var multi = await connection.QueryMultipleAsync(sql, new { UserId = userId });
        
        var user = await multi.ReadFirstOrDefaultAsync<UserDto>();
        if (user == null) return null;

        var ships = (await multi.ReadAsync<ShipDto>()).ToList();

        return new UserShipDto
        {
            UserId = user.UserId,
            UserName = user.UserName,
            Ships = ships
        };
    }

    public async Task<IEnumerable<Ship>> GetUserShipsAsync(int userId)
    {
        using var connection = _context.CreateConnection();
        var sql = @"
            SELECT s.*
            FROM Ships s
            INNER JOIN UserShipAssignments usa ON s.ShipCode = usa.ShipCode
            WHERE usa.UserId = @UserId
            ORDER BY s.ShipName";
        
        return await connection.QueryAsync<Ship>(sql, new { UserId = userId });
    }

    public async Task<int> AssignShipToUserAsync(int userId, string shipCode)
    {
        using var connection = _context.CreateConnection();
        var sql = @"
            IF NOT EXISTS (SELECT 1 FROM UserShipAssignments WHERE UserId = @UserId AND ShipCode = @ShipCode)
            BEGIN
                INSERT INTO UserShipAssignments (UserId, ShipCode)
                VALUES (@UserId, @ShipCode)
            END";
        
        return await connection.ExecuteAsync(sql, new { UserId = userId, ShipCode = shipCode });
    }

    public async Task<int> RemoveShipFromUserAsync(int userId, string shipCode)
    {
        using var connection = _context.CreateConnection();
        var sql = @"
            DELETE FROM UserShipAssignments 
            WHERE UserId = @UserId AND ShipCode = @ShipCode";
        
        return await connection.ExecuteAsync(sql, new { UserId = userId, ShipCode = shipCode });
    }
}
