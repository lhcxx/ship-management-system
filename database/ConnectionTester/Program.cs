using System;
using Microsoft.Data.SqlClient;
using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;
using System.IO;

namespace ConnectionTester
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

            Console.WriteLine("==========================================");
            Console.WriteLine("Azure SQL Server Connection Test");
            Console.WriteLine("==========================================");
            Console.WriteLine();

            Console.WriteLine($"Server: sqlshipmasys.database.windows.net");
            Console.WriteLine($"Database: ship");
            Console.WriteLine($"User: ship");
            Console.WriteLine();

            // Get current IP
            Console.WriteLine("Detecting your current IP address...");
            try
            {
                using var httpClient = new System.Net.Http.HttpClient();
                var ip = await httpClient.GetStringAsync("https://api.ipify.org");
                Console.WriteLine($"Your IP: {ip}");
                Console.WriteLine();
                Console.WriteLine($"⚠️  Make sure this IP is added to Azure SQL Server firewall!");
                Console.WriteLine();
            }
            catch
            {
                Console.WriteLine("Could not detect IP address");
                Console.WriteLine();
            }

            Console.WriteLine("Testing connection...");
            Console.WriteLine();

            try
            {
                using (var connection = new SqlConnection(connectionString))
                {
                    await connection.OpenAsync();
                    
                    Console.WriteLine("✅ CONNECTION SUCCESSFUL!");
                    Console.WriteLine();
                    Console.WriteLine($"Database: {connection.Database}");
                    Console.WriteLine($"Server Version: {connection.ServerVersion}");
                    Console.WriteLine($"State: {connection.State}");
                    Console.WriteLine();

                    // Test a simple query
                    Console.WriteLine("Running test query...");
                    using (var command = new SqlCommand("SELECT @@VERSION AS Version", connection))
                    {
                        var version = await command.ExecuteScalarAsync();
                        Console.WriteLine($"SQL Server: {version}");
                    }
                    
                    Console.WriteLine();
                    Console.WriteLine("==========================================");
                    Console.WriteLine("🎉 Ready to initialize database!");
                    Console.WriteLine("==========================================");
                    Console.WriteLine();
                    Console.WriteLine("Next steps:");
                    Console.WriteLine("  1. Run: cd ../DatabaseInitializer && dotnet run");
                    Console.WriteLine("  2. Wait for database initialization to complete");
                    Console.WriteLine("  3. Run the API: cd ../../src/ShipManagement.API && dotnet run");
                }
            }
            catch (SqlException ex)
            {
                Console.WriteLine("❌ CONNECTION FAILED");
                Console.WriteLine();
                Console.WriteLine($"Error: {ex.Message}");
                Console.WriteLine();

                if (ex.Message.Contains("is not allowed to access"))
                {
                    Console.WriteLine("═══════════════════════════════════════════");
                    Console.WriteLine("ACTION REQUIRED: Add Firewall Rule");
                    Console.WriteLine("═══════════════════════════════════════════");
                    Console.WriteLine();
                    Console.WriteLine("Your IP address is not allowed to access the server.");
                    Console.WriteLine();
                    Console.WriteLine("To fix this:");
                    Console.WriteLine();
                    Console.WriteLine("1. Go to Azure Portal: https://portal.azure.com");
                    Console.WriteLine("2. Navigate to: SQL servers → sqlshipmasys");
                    Console.WriteLine("3. Click: Networking (or Firewalls and virtual networks)");
                    Console.WriteLine("4. Click: + Add client IP");
                    Console.WriteLine("5. Click: Save");
                    Console.WriteLine("6. Wait 1-2 minutes, then run this test again");
                    Console.WriteLine();
                    Console.WriteLine("Alternative: Use Azure CLI");
                    Console.WriteLine("----------------------------");
                    
                    try
                    {
                        using var httpClient = new System.Net.Http.HttpClient();
                        var ip = await httpClient.GetStringAsync("https://api.ipify.org");
                        Console.WriteLine($"az sql server firewall-rule create \\");
                        Console.WriteLine($"  --resource-group YOUR_RESOURCE_GROUP \\");
                        Console.WriteLine($"  --server sqlshipmasys \\");
                        Console.WriteLine($"  --name MyDevMachine \\");
                        Console.WriteLine($"  --start-ip-address {ip} \\");
                        Console.WriteLine($"  --end-ip-address {ip}");
                    }
                    catch
                    {
                        Console.WriteLine("Could not generate CLI command (IP detection failed)");
                    }
                    
                    Console.WriteLine();
                    Console.WriteLine("See AZURE_SETUP.md for detailed instructions.");
                }
                else if (ex.Message.Contains("Login failed"))
                {
                    Console.WriteLine("Wrong username or password.");
                    Console.WriteLine("Please verify the credentials in the connection string.");
                }
                else
                {
                    Console.WriteLine("Please check:");
                    Console.WriteLine("  - Server name: sqlshipmasys.database.windows.net");
                    Console.WriteLine("  - Database exists: ship");
                    Console.WriteLine("  - Credentials are correct");
                    Console.WriteLine("  - Internet connection");
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine("❌ UNEXPECTED ERROR");
                Console.WriteLine();
                Console.WriteLine($"Error: {ex.Message}");
                Console.WriteLine($"Type: {ex.GetType().Name}");
            }
        }
    }
}
