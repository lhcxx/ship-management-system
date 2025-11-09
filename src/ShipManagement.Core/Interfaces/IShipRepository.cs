using ShipManagement.Core.Entities;

namespace ShipManagement.Core.Interfaces;

public interface IShipRepository
{
    Task<Ship?> GetByCodeAsync(string shipCode);
    Task<IEnumerable<Ship>> GetAllAsync();
    Task<IEnumerable<Ship>> GetActiveShipsAsync();
    Task<int> CreateAsync(Ship ship);
    Task<int> UpdateAsync(Ship ship);
}
