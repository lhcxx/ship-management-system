using ShipManagement.Core.Entities;
using ShipManagement.Core.DTOs;

namespace ShipManagement.Core.Interfaces;

public interface IUserRepository
{
    Task<User?> GetByIdAsync(int userId);
    Task<IEnumerable<User>> GetAllAsync();
    Task<int> CreateAsync(User user);
    Task<UserShipDto?> GetUserWithShipsAsync(int userId);
    Task<IEnumerable<Ship>> GetUserShipsAsync(int userId);
    Task<int> AssignShipToUserAsync(int userId, string shipCode);
    Task<int> RemoveShipFromUserAsync(int userId, string shipCode);
}
