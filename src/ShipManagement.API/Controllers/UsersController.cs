using Microsoft.AspNetCore.Mvc;
using ShipManagement.Core.DTOs;
using ShipManagement.Core.Entities;
using ShipManagement.Core.Interfaces;

namespace ShipManagement.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class UsersController : ControllerBase
{
    private readonly IUserRepository _userRepository;
    private readonly ILogger<UsersController> _logger;

    public UsersController(IUserRepository userRepository, ILogger<UsersController> logger)
    {
        _userRepository = userRepository;
        _logger = logger;
    }

    /// <summary>
    /// Get all users
    /// </summary>
    [HttpGet]
    [ProducesResponseType(typeof(IEnumerable<User>), StatusCodes.Status200OK)]
    public async Task<ActionResult<IEnumerable<User>>> GetAll()
    {
        try
        {
            var users = await _userRepository.GetAllAsync();
            return Ok(users);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving users");
            return StatusCode(500, "An error occurred while retrieving users");
        }
    }

    /// <summary>
    /// Get user by ID
    /// </summary>
    [HttpGet("{userId:int}")]
    [ProducesResponseType(typeof(User), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<ActionResult<User>> GetById(int userId)
    {
        try
        {
            var user = await _userRepository.GetByIdAsync(userId);
            
            if (user == null)
                return NotFound($"User with ID {userId} not found");

            return Ok(user);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving user {UserId}", userId);
            return StatusCode(500, "An error occurred while retrieving the user");
        }
    }

    /// <summary>
    /// Create a new user
    /// </summary>
    [HttpPost]
    [ProducesResponseType(typeof(User), StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<ActionResult<User>> Create([FromBody] CreateUserDto createUserDto)
    {
        try
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var user = new User
            {
                UserName = createUserDto.UserName,
                Email = createUserDto.Email,
                Role = createUserDto.Role
            };

            var userId = await _userRepository.CreateAsync(user);
            user.UserId = userId;
            
            return CreatedAtAction(nameof(GetById), new { userId = user.UserId }, user);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error creating user");
            return StatusCode(500, "An error occurred while creating the user");
        }
    }

    /// <summary>
    /// Get user with assigned ships
    /// </summary>
    [HttpGet("{userId:int}/ships")]
    [ProducesResponseType(typeof(UserShipDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<ActionResult<UserShipDto>> GetUserWithShips(int userId)
    {
        try
        {
            var userShips = await _userRepository.GetUserWithShipsAsync(userId);
            
            if (userShips == null)
                return NotFound($"User with ID {userId} not found");

            return Ok(userShips);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving user ships for {UserId}", userId);
            return StatusCode(500, "An error occurred while retrieving user ships");
        }
    }

    /// <summary>
    /// Assign a ship to a user
    /// </summary>
    [HttpPost("{userId:int}/ships")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> AssignShip(int userId, [FromBody] string shipCode)
    {
        try
        {
            if (string.IsNullOrWhiteSpace(shipCode))
                return BadRequest("Ship code is required");

            // Verify user exists
            var user = await _userRepository.GetByIdAsync(userId);
            if (user == null)
                return NotFound($"User with ID {userId} not found");

            await _userRepository.AssignShipToUserAsync(userId, shipCode);
            
            return NoContent();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error assigning ship to user {UserId}", userId);
            return StatusCode(500, "An error occurred while assigning the ship");
        }
    }

    /// <summary>
    /// Remove a ship from a user
    /// </summary>
    [HttpDelete("{userId:int}/ships/{shipCode}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> RemoveShip(int userId, string shipCode)
    {
        try
        {
            var user = await _userRepository.GetByIdAsync(userId);
            if (user == null)
                return NotFound($"User with ID {userId} not found");

            await _userRepository.RemoveShipFromUserAsync(userId, shipCode);
            
            return NoContent();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error removing ship from user {UserId}", userId);
            return StatusCode(500, "An error occurred while removing the ship");
        }
    }
}
