namespace ShipManagement.Core.DTOs;

public class FinancialReportLineDto
{
    public string COADescription { get; set; } = string.Empty;
    public string AccountNumber { get; set; } = string.Empty;
    public decimal PeriodActual { get; set; }
    public decimal PeriodBudget { get; set; }
    public decimal PeriodVariance { get; set; }
    public decimal YTDActual { get; set; }
    public decimal YTDBudget { get; set; }
    public decimal YTDVariance { get; set; }
}

public class FinancialReportRequestDto
{
    public string ShipCode { get; set; } = string.Empty;
    public string Period { get; set; } = string.Empty; // Format: YYYY-MM
    public bool IsSummary { get; set; } = false;
}
