using Microsoft.AspNetCore.Mvc;
using ShipManagement.Core.DTOs;
using ShipManagement.Core.Interfaces;

namespace ShipManagement.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class CrewController : ControllerBase
{
    private readonly ICrewRepository _crewRepository;
    private readonly ILogger<CrewController> _logger;

    public CrewController(ICrewRepository crewRepository, ILogger<CrewController> logger)
    {
        _crewRepository = crewRepository;
        _logger = logger;
    }

    /// <summary>
    /// Get crew list for a ship with pagination, sorting, and searching
    /// </summary>
    [HttpGet]
    [ProducesResponseType(typeof(PagedCrewListDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<ActionResult<PagedCrewListDto>> GetCrewList([FromQuery] CrewListRequestDto request)
    {
        try
        {
            if (string.IsNullOrWhiteSpace(request.ShipCode))
                return BadRequest("Ship code is required");

            if (request.PageNumber < 1)
                request.PageNumber = 1;

            if (request.PageSize < 1 || request.PageSize > 100)
                request.PageSize = 20;

            var result = await _crewRepository.GetCrewListAsync(request);
            
            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving crew list for ship {ShipCode}", request.ShipCode);
            return StatusCode(500, "An error occurred while retrieving the crew list");
        }
    }
}
