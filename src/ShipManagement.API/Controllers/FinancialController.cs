using Microsoft.AspNetCore.Mvc;
using ShipManagement.Core.DTOs;
using ShipManagement.Core.Interfaces;

namespace ShipManagement.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class FinancialController : ControllerBase
{
    private readonly IFinancialRepository _financialRepository;
    private readonly ILogger<FinancialController> _logger;

    public FinancialController(IFinancialRepository financialRepository, ILogger<FinancialController> logger)
    {
        _financialRepository = financialRepository;
        _logger = logger;
    }

    /// <summary>
    /// Get financial report for a ship and period
    /// </summary>
    [HttpGet("report")]
    [ProducesResponseType(typeof(IEnumerable<FinancialReportLineDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<ActionResult<IEnumerable<FinancialReportLineDto>>> GetFinancialReport([FromQuery] FinancialReportRequestDto request)
    {
        try
        {
            if (string.IsNullOrWhiteSpace(request.ShipCode))
                return BadRequest("Ship code is required");

            if (string.IsNullOrWhiteSpace(request.Period))
                return BadRequest("Period is required");

            // Validate period format (YYYY-MM)
            if (request.Period.Length != 7 || !request.Period.Contains('-'))
                return BadRequest("Period must be in YYYY-MM format");

            var result = await _financialRepository.GetFinancialReportAsync(
                request.ShipCode, 
                request.Period, 
                request.IsSummary);
            
            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving financial report for ship {ShipCode}, period {Period}", 
                request.ShipCode, request.Period);
            return StatusCode(500, "An error occurred while retrieving the financial report");
        }
    }

    /// <summary>
    /// Get financial report summary for a ship and period
    /// </summary>
    [HttpGet("report/summary")]
    [ProducesResponseType(typeof(IEnumerable<FinancialReportLineDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<ActionResult<IEnumerable<FinancialReportLineDto>>> GetFinancialReportSummary(
        [FromQuery] string shipCode, 
        [FromQuery] string period)
    {
        try
        {
            if (string.IsNullOrWhiteSpace(shipCode))
                return BadRequest("Ship code is required");

            if (string.IsNullOrWhiteSpace(period))
                return BadRequest("Period is required");

            var request = new FinancialReportRequestDto
            {
                ShipCode = shipCode,
                Period = period,
                IsSummary = true
            };

            return await GetFinancialReport(request);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving financial summary for ship {ShipCode}, period {Period}", 
                shipCode, period);
            return StatusCode(500, "An error occurred while retrieving the financial summary");
        }
    }

    /// <summary>
    /// Get detailed financial report for a ship and period
    /// </summary>
    [HttpGet("report/detail")]
    [ProducesResponseType(typeof(IEnumerable<FinancialReportLineDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<ActionResult<IEnumerable<FinancialReportLineDto>>> GetFinancialReportDetail(
        [FromQuery] string shipCode, 
        [FromQuery] string period)
    {
        try
        {
            if (string.IsNullOrWhiteSpace(shipCode))
                return BadRequest("Ship code is required");

            if (string.IsNullOrWhiteSpace(period))
                return BadRequest("Period is required");

            var request = new FinancialReportRequestDto
            {
                ShipCode = shipCode,
                Period = period,
                IsSummary = false
            };

            return await GetFinancialReport(request);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving financial detail for ship {ShipCode}, period {Period}", 
                shipCode, period);
            return StatusCode(500, "An error occurred while retrieving the financial detail");
        }
    }
}
