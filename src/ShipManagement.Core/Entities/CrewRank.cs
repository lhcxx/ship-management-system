namespace ShipManagement.Core.Entities;

public class CrewRank
{
    public int RankId { get; set; }
    public string RankName { get; set; } = string.Empty;
    public int RankOrder { get; set; }
    public string? Department { get; set; }
    public DateTime CreatedAt { get; set; }
}
