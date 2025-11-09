namespace ShipManagement.Core.DTOs;

public class CrewListItemDto
{
    public string RankName { get; set; } = string.Empty;
    public string CrewId { get; set; } = string.Empty;
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public int Age { get; set; }
    public string Nationality { get; set; } = string.Empty;
    public DateTime SignOnDate { get; set; }
    public string SignOnDateFormatted { get; set; } = string.Empty;
    public string Status { get; set; } = string.Empty;
}

public class PagedCrewListDto
{
    public List<CrewListItemDto> Crew { get; set; } = new();
    public int TotalRecords { get; set; }
    public int TotalPages { get; set; }
    public int CurrentPage { get; set; }
    public int PageSize { get; set; }
}

public class CrewListRequestDto
{
    public string ShipCode { get; set; } = string.Empty;
    public DateTime? AsOfDate { get; set; }
    public int PageNumber { get; set; } = 1;
    public int PageSize { get; set; } = 20;
    public string SortColumn { get; set; } = "RankName";
    public string SortDirection { get; set; } = "ASC";
    public string? SearchTerm { get; set; }
}
