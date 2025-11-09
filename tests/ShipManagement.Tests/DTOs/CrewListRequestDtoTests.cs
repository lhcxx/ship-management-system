using ShipManagement.Core.DTOs;
using Xunit;

namespace ShipManagement.Tests.DTOs;

public class CrewListRequestDtoTests
{
    [Fact]
    public void CrewListRequestDto_ShouldHaveDefaultValues()
    {
        // Arrange & Act
        var request = new CrewListRequestDto();

        // Assert
        Assert.Equal(1, request.PageNumber);
        Assert.Equal(20, request.PageSize);
        Assert.Equal("RankName", request.SortColumn);
        Assert.Equal("ASC", request.SortDirection);
    }

    [Fact]
    public void CrewListRequestDto_ShouldAllowCustomValues()
    {
        // Arrange & Act
        var request = new CrewListRequestDto
        {
            ShipCode = "SHIP01",
            PageNumber = 2,
            PageSize = 50,
            SortColumn = "CrewId",
            SortDirection = "DESC",
            SearchTerm = "John",
            AsOfDate = new DateTime(2025, 1, 1)
        };

        // Assert
        Assert.Equal("SHIP01", request.ShipCode);
        Assert.Equal(2, request.PageNumber);
        Assert.Equal(50, request.PageSize);
        Assert.Equal("CrewId", request.SortColumn);
        Assert.Equal("DESC", request.SortDirection);
        Assert.Equal("John", request.SearchTerm);
        Assert.Equal(new DateTime(2025, 1, 1), request.AsOfDate);
    }
}
