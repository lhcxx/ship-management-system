using ShipManagement.Core.DTOs;
using Xunit;

namespace ShipManagement.Tests.DTOs;

public class FinancialReportRequestDtoTests
{
    [Fact]
    public void FinancialReportRequestDto_ShouldInitializeWithDefaults()
    {
        // Arrange & Act
        var request = new FinancialReportRequestDto();

        // Assert
        Assert.False(request.IsSummary);
        Assert.NotNull(request.ShipCode);
        Assert.NotNull(request.Period);
    }

    [Theory]
    [InlineData("SHIP01", "2025-01", false)]
    [InlineData("SHIP02", "2024-12", true)]
    public void FinancialReportRequestDto_ShouldSetPropertiesCorrectly(string shipCode, string period, bool isSummary)
    {
        // Arrange & Act
        var request = new FinancialReportRequestDto
        {
            ShipCode = shipCode,
            Period = period,
            IsSummary = isSummary
        };

        // Assert
        Assert.Equal(shipCode, request.ShipCode);
        Assert.Equal(period, request.Period);
        Assert.Equal(isSummary, request.IsSummary);
    }

    [Fact]
    public void FinancialReportLineDto_ShouldCalculateVariances()
    {
        // Arrange
        var reportLine = new FinancialReportLineDto
        {
            COADescription = "Test Account",
            AccountNumber = "7000000",
            PeriodActual = 1200m,
            PeriodBudget = 1000m,
            YTDActual = 12000m,
            YTDBudget = 10000m
        };

        // Act
        reportLine.PeriodVariance = reportLine.PeriodActual - reportLine.PeriodBudget;
        reportLine.YTDVariance = reportLine.YTDActual - reportLine.YTDBudget;

        // Assert
        Assert.Equal(200m, reportLine.PeriodVariance);
        Assert.Equal(2000m, reportLine.YTDVariance);
    }
}
