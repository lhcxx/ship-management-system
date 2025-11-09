using ShipManagement.Core.DTOs;

namespace ShipManagement.Core.Interfaces;

public interface IFinancialRepository
{
    Task<IEnumerable<FinancialReportLineDto>> GetFinancialReportAsync(string shipCode, string period, bool isSummary);
}
