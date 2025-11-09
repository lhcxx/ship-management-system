namespace ShipManagement.Core.DTOs;

public class ShipDto
{
    public string ShipCode { get; set; } = string.Empty;
    public string ShipName { get; set; } = string.Empty;
    public string FiscalYearCode { get; set; } = string.Empty;
    public string Status { get; set; } = string.Empty;
}

public class CreateShipDto
{
    public string ShipCode { get; set; } = string.Empty;
    public string ShipName { get; set; } = string.Empty;
    public string FiscalYearCode { get; set; } = string.Empty;
    public string Status { get; set; } = "Active";
}
