using Dapper;
using ShipManagement.Core.DTOs;
using ShipManagement.Core.Interfaces;
using ShipManagement.Infrastructure.Data;
using System.Data;

namespace ShipManagement.Infrastructure.Repositories;

public class FinancialRepository : IFinancialRepository
{
    private readonly DapperContext _context;

    public FinancialRepository(DapperContext context)
    {
        _context = context;
    }

    public async Task<IEnumerable<FinancialReportLineDto>> GetFinancialReportAsync(
        string shipCode, 
        string period, 
        bool isSummary)
    {
        using var connection = _context.CreateConnection();
        
        var parameters = new DynamicParameters();
        parameters.Add("@ShipCode", shipCode);
        parameters.Add("@Period", period);

        var storedProcedure = isSummary 
            ? "dbo.usp_GetFinancialReportSummary" 
            : "dbo.usp_GetFinancialReportDetail";

        var result = await connection.QueryAsync<FinancialReportLineDto>(
            storedProcedure,
            parameters,
            commandType: CommandType.StoredProcedure
        );

        return result;
    }
}
