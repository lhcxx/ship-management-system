namespace ShipManagement.Core.Entities;

public class Ship
{
    public string ShipCode { get; set; } = string.Empty;
    public string ShipName { get; set; } = string.Empty;
    public string FiscalYearCode { get; set; } = string.Empty;
    public string Status { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
}
