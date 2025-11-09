using Microsoft.AspNetCore.Mvc;
using ShipManagement.Core.DTOs;
using ShipManagement.Core.Entities;
using ShipManagement.Core.Interfaces;

namespace ShipManagement.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ShipsController : ControllerBase
{
    private readonly IShipRepository _shipRepository;
    private readonly ILogger<ShipsController> _logger;

    public ShipsController(IShipRepository shipRepository, ILogger<ShipsController> logger)
    {
        _shipRepository = shipRepository;
        _logger = logger;
    }

    /// <summary>
    /// Get all ships
    /// </summary>
    [HttpGet]
    [ProducesResponseType(typeof(IEnumerable<Ship>), StatusCodes.Status200OK)]
    public async Task<ActionResult<IEnumerable<Ship>>> GetAll()
    {
        try
        {
            var ships = await _shipRepository.GetAllAsync();
            return Ok(ships);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving all ships");
            return StatusCode(500, "An error occurred while retrieving ships");
        }
    }

    /// <summary>
    /// Get active ships only
    /// </summary>
    [HttpGet("active")]
    [ProducesResponseType(typeof(IEnumerable<Ship>), StatusCodes.Status200OK)]
    public async Task<ActionResult<IEnumerable<Ship>>> GetActiveShips()
    {
        try
        {
            var ships = await _shipRepository.GetActiveShipsAsync();
            return Ok(ships);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving active ships");
            return StatusCode(500, "An error occurred while retrieving active ships");
        }
    }

    /// <summary>
    /// Get ship by code
    /// </summary>
    [HttpGet("{shipCode}")]
    [ProducesResponseType(typeof(Ship), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<ActionResult<Ship>> GetByCode(string shipCode)
    {
        try
        {
            var ship = await _shipRepository.GetByCodeAsync(shipCode);
            
            if (ship == null)
                return NotFound($"Ship with code '{shipCode}' not found");

            return Ok(ship);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving ship {ShipCode}", shipCode);
            return StatusCode(500, "An error occurred while retrieving the ship");
        }
    }

    /// <summary>
    /// Create a new ship
    /// </summary>
    [HttpPost]
    [ProducesResponseType(typeof(Ship), StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<ActionResult<Ship>> Create([FromBody] CreateShipDto createShipDto)
    {
        try
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            // Validate fiscal year code format (MMDD)
            if (createShipDto.FiscalYearCode.Length != 4 || !int.TryParse(createShipDto.FiscalYearCode, out _))
                return BadRequest("FiscalYearCode must be 4 digits in MMDD format");

            var ship = new Ship
            {
                ShipCode = createShipDto.ShipCode,
                ShipName = createShipDto.ShipName,
                FiscalYearCode = createShipDto.FiscalYearCode,
                Status = createShipDto.Status
            };

            await _shipRepository.CreateAsync(ship);
            
            return CreatedAtAction(nameof(GetByCode), new { shipCode = ship.ShipCode }, ship);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error creating ship");
            return StatusCode(500, "An error occurred while creating the ship");
        }
    }

    /// <summary>
    /// Update an existing ship
    /// </summary>
    [HttpPut("{shipCode}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> Update(string shipCode, [FromBody] CreateShipDto updateShipDto)
    {
        try
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var existing = await _shipRepository.GetByCodeAsync(shipCode);
            if (existing == null)
                return NotFound($"Ship with code '{shipCode}' not found");

            existing.ShipName = updateShipDto.ShipName;
            existing.FiscalYearCode = updateShipDto.FiscalYearCode;
            existing.Status = updateShipDto.Status;

            await _shipRepository.UpdateAsync(existing);
            
            return NoContent();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating ship {ShipCode}", shipCode);
            return StatusCode(500, "An error occurred while updating the ship");
        }
    }
}
