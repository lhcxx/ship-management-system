using Dapper;
using ShipManagement.Core.DTOs;
using ShipManagement.Core.Interfaces;
using ShipManagement.Infrastructure.Data;
using System.Data;

namespace ShipManagement.Infrastructure.Repositories;

public class CrewRepository : ICrewRepository
{
    private readonly DapperContext _context;

    public CrewRepository(DapperContext context)
    {
        _context = context;
    }

    public async Task<PagedCrewListDto> GetCrewListAsync(CrewListRequestDto request)
    {
        using var connection = _context.CreateConnection();
        
        var parameters = new DynamicParameters();
        parameters.Add("@ShipCode", request.ShipCode);
        parameters.Add("@AsOfDate", request.AsOfDate ?? DateTime.UtcNow.Date);
        parameters.Add("@PageNumber", request.PageNumber);
        parameters.Add("@PageSize", request.PageSize);
        parameters.Add("@SortColumn", request.SortColumn);
        parameters.Add("@SortDirection", request.SortDirection);
        parameters.Add("@SearchTerm", string.IsNullOrWhiteSpace(request.SearchTerm) ? null : request.SearchTerm);

        var result = await connection.QueryAsync<CrewListItemDto>(
            "dbo.usp_GetCrewList",
            parameters,
            commandType: CommandType.StoredProcedure
        );

        var crewList = result.ToList();
        
        if (!crewList.Any())
        {
            return new PagedCrewListDto
            {
                Crew = new List<CrewListItemDto>(),
                TotalRecords = 0,
                TotalPages = 0,
                CurrentPage = request.PageNumber,
                PageSize = request.PageSize
            };
        }

        var firstItem = crewList.First();
        
        // The stored procedure returns TotalRecords, TotalPages, etc. in each row
        // We need to use dynamic to access these properties
        var dynamicResult = await connection.QueryAsync<dynamic>(
            "dbo.usp_GetCrewList",
            parameters,
            commandType: CommandType.StoredProcedure
        );
        
        var dynamicList = dynamicResult.ToList();
        var firstDynamic = dynamicList.FirstOrDefault();

        return new PagedCrewListDto
        {
            Crew = crewList,
            TotalRecords = firstDynamic?.TotalRecords != null ? (int)firstDynamic.TotalRecords : 0,
            TotalPages = firstDynamic?.TotalPages != null ? (int)firstDynamic.TotalPages : 0,
            CurrentPage = firstDynamic?.CurrentPage != null ? (int)firstDynamic.CurrentPage : request.PageNumber,
            PageSize = firstDynamic?.PageSize != null ? (int)firstDynamic.PageSize : request.PageSize
        };
    }
}
