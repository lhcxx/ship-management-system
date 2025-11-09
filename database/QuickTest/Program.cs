using System;
using Microsoft.Data.SqlClient;
using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;
using System.IO;

namespace QuickTest
{
    class Program
    {
        static async Task Main(string[] args)
        {
            // Load configuration
            var configuration = new ConfigurationBuilder()
                .SetBasePath(Directory.GetCurrentDirectory())
                .AddJsonFile("appsettings.json", optional: false, reloadOnChange: true)
                .AddEnvironmentVariables()
                .Build();

            var connectionString = configuration.GetConnectionString("DefaultConnection")
                ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found in appsettings.json");

            Console.WriteLine("Checking database state...\n");

            using (var connection = new SqlConnection(connectionString))
            {
                await connection.OpenAsync();

                // Check CrewRanks
                using (var cmd = new SqlCommand("SELECT COUNT(*) FROM CrewRanks", connection))
                {
                    var count = await cmd.ExecuteScalarAsync();
                    Console.WriteLine($"CrewRanks: {count} records");
                }

                // Check Ships
                using (var cmd = new SqlCommand("SELECT COUNT(*) FROM Ships", connection))
                {
                    var count = await cmd.ExecuteScalarAsync();
                    Console.WriteLine($"Ships: {count} records");
                }

                // Check CrewMembers
                using (var cmd = new SqlCommand("SELECT COUNT(*) FROM CrewMembers", connection))
                {
                    var count = await cmd.ExecuteScalarAsync();
                    Console.WriteLine($"CrewMembers: {count} records");
                }

                // Check CrewServiceHistory
                using (var cmd = new SqlCommand("SELECT COUNT(*) FROM CrewServiceHistory", connection))
                {
                    var count = await cmd.ExecuteScalarAsync();
                    Console.WriteLine($"CrewServiceHistory: {count} records");
                }

                // Check specific crew
                Console.WriteLine("\nChecking CREW001-CREW020...");
                using (var cmd = new SqlCommand("SELECT CrewId FROM CrewMembers WHERE CrewId BETWEEN 'CREW001' AND 'CREW020' ORDER BY CrewId", connection))
                using (var reader = await cmd.ExecuteReaderAsync())
                {
                    int foundCount = 0;
                    while (await reader.ReadAsync())
                    {
                        foundCount++;
                        if (foundCount <= 5) // Show first 5
                            Console.WriteLine($"  {reader["CrewId"]}");
                    }
                    Console.WriteLine($"Found {foundCount} crew members");
                }

                // Check RankId 1
                Console.WriteLine("\nChecking RankId 1...");
                using (var cmd = new SqlCommand("SELECT RankId, RankName FROM CrewRanks WHERE RankId = 1", connection))
                using (var reader = await cmd.ExecuteReaderAsync())
                {
                    if (await reader.ReadAsync())
                    {
                        Console.WriteLine($"  RankId={reader["RankId"]}, RankName={reader["RankName"]}");
                    }
                    else
                    {
                        Console.WriteLine("  NOT FOUND!");
                    }
                }

                // Try a simple insert
                Console.WriteLine("\nTesting a simple insert...");
                try
                {
                    using (var cmd = new SqlCommand(@"
                        INSERT INTO dbo.CrewServiceHistory (CrewId, ShipCode, RankId, SignOnDate, SignOffDate, EndOfContractDate) 
                        VALUES ('CREW001', 'SHIP01', 1, '2025-04-05', NULL, '2025-07-05')", connection))
                    {
                        await cmd.ExecuteNonQueryAsync();
                        Console.WriteLine("  ✓ Insert successful!");
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"  ✗ Insert failed: {ex.Message}");
                }
            }
        }
    }
}
