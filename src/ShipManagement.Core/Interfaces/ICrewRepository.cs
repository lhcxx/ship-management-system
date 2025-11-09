using ShipManagement.Core.DTOs;

namespace ShipManagement.Core.Interfaces;

public interface ICrewRepository
{
    Task<PagedCrewListDto> GetCrewListAsync(CrewListRequestDto request);
}
