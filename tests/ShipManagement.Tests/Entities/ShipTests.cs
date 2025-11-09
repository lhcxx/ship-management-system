using ShipManagement.Core.Entities;
using Xunit;

namespace ShipManagement.Tests.Entities;

public class ShipTests
{
    [Fact]
    public void Ship_ShouldInitializeWithDefaultValues()
    {
        // Arrange & Act
        var ship = new Ship();

        // Assert
        Assert.NotNull(ship.ShipCode);
        Assert.NotNull(ship.ShipName);
        Assert.NotNull(ship.FiscalYearCode);
        Assert.NotNull(ship.Status);
    }

    [Theory]
    [InlineData("SHIP01", "Test Ship", "0112", "Active")]
    [InlineData("SHIP02", "Another Ship", "0403", "Inactive")]
    public void Ship_ShouldSetPropertiesCorrectly(string code, string name, string fiscalYear, string status)
    {
        // Arrange & Act
        var ship = new Ship
        {
            ShipCode = code,
            ShipName = name,
            FiscalYearCode = fiscalYear,
            Status = status
        };

        // Assert
        Assert.Equal(code, ship.ShipCode);
        Assert.Equal(name, ship.ShipName);
        Assert.Equal(fiscalYear, ship.FiscalYearCode);
        Assert.Equal(status, ship.Status);
    }
}
