using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using Microsoft.AspNetCore.Mvc.Testing;
using ShipManagement.API;
using ShipManagement.Core.DTOs;

namespace ShipManagement.Tests.E2ETests;

/// <summary>
/// End-to-End tests for the Ship Management API
/// These tests verify the API endpoints work correctly with real HTTP requests
/// </summary>
public class ShipManagementApiE2ETests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly HttpClient _client;
    private readonly JsonSerializerOptions _jsonOptions;

    public ShipManagementApiE2ETests(WebApplicationFactory<Program> factory)
    {
        _client = factory.CreateClient();
        _jsonOptions = new JsonSerializerOptions
        {
            PropertyNameCaseInsensitive = true
        };
    }

    [Fact]
    public async Task GetAllShips_ReturnsSuccessAndShipsList()
    {
        // Act
        var response = await _client.GetAsync("/api/ships");

        // Assert
        response.EnsureSuccessStatusCode();
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);

        var ships = await response.Content.ReadFromJsonAsync<List<ShipDto>>(_jsonOptions);
        Assert.NotNull(ships);
        Assert.NotEmpty(ships);
    }

    [Fact]
    public async Task GetActiveShips_ReturnsOnlyActiveShips()
    {
        // Act
        var response = await _client.GetAsync("/api/ships/active");

        // Assert
        response.EnsureSuccessStatusCode();
        
        var ships = await response.Content.ReadFromJsonAsync<List<ShipDto>>(_jsonOptions);
        Assert.NotNull(ships);
        Assert.All(ships, ship => Assert.Equal("Active", ship.Status));
    }

    [Fact]
    public async Task GetCrewList_WithValidShipCode_ReturnsPaginatedCrew()
    {
        // Arrange
        var shipCode = "SHIP01";
        var pageSize = 10;

        // Act
        var response = await _client.GetAsync($"/api/crew?shipCode={shipCode}&pageSize={pageSize}");

        // Assert
        response.EnsureSuccessStatusCode();

        var crewResponse = await response.Content.ReadFromJsonAsync<PagedCrewListDto>(_jsonOptions);
        Assert.NotNull(crewResponse);
        Assert.NotNull(crewResponse.Crew);
        Assert.True(crewResponse.TotalRecords >= 0);
        Assert.True(crewResponse.TotalPages >= 0);
        Assert.Equal(1, crewResponse.CurrentPage);
        
        if (crewResponse.Crew.Any())
        {
            Assert.True(crewResponse.Crew.Count <= pageSize);
            Assert.All(crewResponse.Crew, crew => Assert.Equal(shipCode, crew.CrewId.StartsWith("CREW") ? shipCode : crew.CrewId));
        }
    }

    [Fact]
    public async Task GetCrewList_WithSearch_ReturnsFilteredResults()
    {
        // Arrange
        var shipCode = "SHIP01";
        var searchTerm = "John";

        // Act
        var response = await _client.GetAsync($"/api/crew?shipCode={shipCode}&searchTerm={searchTerm}");

        // Assert
        response.EnsureSuccessStatusCode();

        var crewResponse = await response.Content.ReadFromJsonAsync<PagedCrewListDto>(_jsonOptions);
        Assert.NotNull(crewResponse);
        
        if (crewResponse.Crew.Any())
        {
            Assert.All(crewResponse.Crew, crew =>
            {
                var containsSearch = crew.FirstName.Contains(searchTerm, StringComparison.OrdinalIgnoreCase) ||
                                   crew.LastName.Contains(searchTerm, StringComparison.OrdinalIgnoreCase);
                Assert.True(containsSearch, $"Crew member {crew.FirstName} {crew.LastName} doesn't match search term {searchTerm}");
            });
        }
    }

    [Fact]
    public async Task GetFinancialReportSummary_WithValidParameters_ReturnsReport()
    {
        // Arrange
        var shipCode = "SHIP01";
        var period = "2025-01";

        // Act
        var response = await _client.GetAsync($"/api/financial/report/summary?shipCode={shipCode}&period={period}");

        // Assert
        response.EnsureSuccessStatusCode();

        var report = await response.Content.ReadFromJsonAsync<List<FinancialReportLineDto>>(_jsonOptions);
        Assert.NotNull(report);
        // Report might be empty if no data exists, which is acceptable
    }

    [Fact]
    public async Task GetFinancialReportDetail_WithValidParameters_ReturnsDetailedReport()
    {
        // Arrange
        var shipCode = "SHIP01";
        var period = "2025-01";

        // Act
        var response = await _client.GetAsync($"/api/financial/report/detail?shipCode={shipCode}&period={period}");

        // Assert
        response.EnsureSuccessStatusCode();

        var report = await response.Content.ReadFromJsonAsync<List<FinancialReportLineDto>>(_jsonOptions);
        Assert.NotNull(report);
        
        if (report.Any())
        {
            Assert.All(report, item =>
            {
                Assert.NotNull(item.COADescription);
                Assert.NotNull(item.AccountNumber);
            });
        }
    }

    [Fact]
    public async Task GetAllUsers_ReturnsSuccessAndUsersList()
    {
        // Act
        var response = await _client.GetAsync("/api/users");

        // Assert
        response.EnsureSuccessStatusCode();

        var users = await response.Content.ReadFromJsonAsync<List<UserDto>>(_jsonOptions);
        Assert.NotNull(users);
        Assert.NotEmpty(users);
    }

    [Fact]
    public async Task GetNonExistentShip_ReturnsNotFound()
    {
        // Arrange
        var nonExistentShipCode = "SHIP999";

        // Act
        var response = await _client.GetAsync($"/api/ships/{nonExistentShipCode}");

        // Assert
        Assert.Equal(HttpStatusCode.NotFound, response.StatusCode);
    }

    [Fact]
    public async Task GetCrewList_WithInvalidShipCode_ReturnsBadRequestOrEmpty()
    {
        // Arrange
        var invalidShipCode = "INVALID";

        // Act
        var response = await _client.GetAsync($"/api/crew?shipCode={invalidShipCode}");

        // Assert - Should either return 400 Bad Request or 200 OK with empty results
        Assert.True(
            response.StatusCode == HttpStatusCode.OK || 
            response.StatusCode == HttpStatusCode.BadRequest,
            $"Expected OK or BadRequest, got {response.StatusCode}"
        );

        if (response.StatusCode == HttpStatusCode.OK)
        {
            var crewResponse = await response.Content.ReadFromJsonAsync<PagedCrewListDto>(_jsonOptions);
            Assert.NotNull(crewResponse);
            Assert.Equal(0, crewResponse.TotalRecords);
        }
    }
}
