namespace ShipManagement.Core.DTOs;

public class UserDto
{
    public int UserId { get; set; }
    public string UserName { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string Role { get; set; } = string.Empty;
}

public class CreateUserDto
{
    public string UserName { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string Role { get; set; } = string.Empty;
}

public class UserShipDto
{
    public int UserId { get; set; }
    public string UserName { get; set; } = string.Empty;
    public List<ShipDto> Ships { get; set; } = new();
}

public class AssignShipToUserDto
{
    public int UserId { get; set; }
    public string ShipCode { get; set; } = string.Empty;
}
