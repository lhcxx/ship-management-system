using System;
using Microsoft.Data.SqlClient;
using System.IO;
using System.Threading.Tasks;

namespace DatabaseInitializer
{
    class Program
    {
        private const string ConnectionString = "Server=tcp:sqlshipmasys.database.windows.net,1433;Initial Catalog=ship;Persist Security Info=False;User ID=ship;Password=sys2026!;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;";

        static async Task Main(string[] args)
        {
            Console.WriteLine("==========================================");
            Console.WriteLine("Azure SQL Database Initialization");
            Console.WriteLine("==========================================");
            Console.WriteLine();

            try
            {
                // Test connection
                Console.WriteLine("Testing connection to Azure SQL Server...");
                using (var connection = new SqlConnection(ConnectionString))
                {
                    await connection.OpenAsync();
                    Console.WriteLine("✓ Connection successful!");
                    Console.WriteLine($"Database: {connection.Database}");
                    Console.WriteLine($"Server Version: {connection.ServerVersion}");
                    Console.WriteLine();
                }

                // Execute SQL files in order
                var scriptFiles = new[]
                {
                    ("00_CleanupData.sql", "Cleaning up existing data"),
                    ("01_CreateTables.sql", "Creating database schema (tables)"),
                    ("02_InsertSampleData.sql", "Inserting sample data (ships, users, crew)"),
                    ("03_InsertBudgetAndTransactions.sql", "Inserting financial data (budget and transactions)"),
                    ("04_CreateStoredProcedures.sql", "Creating stored procedures")
                };

                for (int i = 0; i < scriptFiles.Length; i++)
                {
                    var (file, description) = scriptFiles[i];
                    Console.WriteLine($"Step {i + 1}/{scriptFiles.Length}: {description}...");
                    
                    if (!await ExecuteSqlFile(file))
                    {
                        Console.WriteLine($"✗ Failed: {description}");
                        return;
                    }
                    
                    Console.WriteLine($"✓ Success: {description}");
                    Console.WriteLine();
                }

                // Display summary
                Console.WriteLine("==========================================");
                Console.WriteLine("✓ Azure SQL Database Initialization Complete!");
                Console.WriteLine("==========================================");
                Console.WriteLine();

                await DisplayDatabaseSummary();

                Console.WriteLine();
                Console.WriteLine("You can now run the API with: dotnet run");
                Console.WriteLine("The API will connect to: sqlshipmasys.database.windows.net");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"ERROR: {ex.Message}");
                Console.WriteLine($"Type: {ex.GetType().Name}");
                if (ex.InnerException != null)
                {
                    Console.WriteLine($"Inner Exception: {ex.InnerException.Message}");
                }
                Console.WriteLine($"Stack Trace: {ex.StackTrace}");
                Console.WriteLine();
                Console.WriteLine("Please check:");
                Console.WriteLine("  1. Your IP address is allowed in Azure SQL firewall rules");
                Console.WriteLine("  2. Connection string is correct");
                Console.WriteLine("  3. Database credentials are valid");
            }
        }

        static async Task<bool> ExecuteSqlFile(string filename)
        {
            try
            {
                // Look for SQL files in the parent directory
                var parentDir = Directory.GetParent(Directory.GetCurrentDirectory())?.FullName;
                var scriptPath = Path.Combine(parentDir ?? Directory.GetCurrentDirectory(), filename);
                
                if (!File.Exists(scriptPath))
                {
                    Console.WriteLine($"ERROR: File not found - {scriptPath}");
                    return false;
                }

                var sql = await File.ReadAllTextAsync(scriptPath);
                
                // Split by GO statements (SQL Server batch separator) - handle different line endings
                var batches = System.Text.RegularExpressions.Regex.Split(
                    sql, 
                    @"^\s*GO\s*$", 
                    System.Text.RegularExpressions.RegexOptions.Multiline | 
                    System.Text.RegularExpressions.RegexOptions.IgnoreCase
                );

                using (var connection = new SqlConnection(ConnectionString))
                {
                    await connection.OpenAsync();

                    int batchNumber = 0;
                    foreach (var batch in batches)
                    {
                        batchNumber++;
                        var trimmedBatch = batch.Trim();
                        if (string.IsNullOrWhiteSpace(trimmedBatch))
                            continue;

                        // Skip comments-only batches
                        var lines = trimmedBatch.Split('\n');
                        var hasCode = lines.Any(l => {
                            var trimmed = l.Trim();
                            return !string.IsNullOrWhiteSpace(trimmed) && 
                                   !trimmed.StartsWith("--") && 
                                   !trimmed.StartsWith("/*") &&
                                   !trimmed.StartsWith("*");
                        });
                        
                        if (!hasCode)
                            continue;

                        using (var command = new SqlCommand(trimmedBatch, connection))
                        {
                            command.CommandTimeout = 120; // 2 minutes timeout
                            try
                            {
                                await command.ExecuteNonQueryAsync();
                            }
                            catch (SqlException ex)
                            {
                                // Ignore specific non-critical errors
                                var canIgnore = 
                                    ex.Message.Contains("already exists") || 
                                    ex.Message.Contains("There is already an object") ||
                                    ex.Message.Contains("Cannot drop") ||
                                    ex.Message.Contains("Cannot find the object") ||  // Object doesn't exist when creating index
                                    ex.Message.Contains("does not exist") ||
                                    (ex.Number == 3701) ||  // Cannot drop object because it does not exist
                                    (ex.Number == 1088);    // Cannot find object (index creation before table)
                                
                                if (!canIgnore)
                                {
                                    Console.WriteLine($"\nSQL Error (#{ex.Number}): {ex.Message}");
                                    Console.WriteLine($"Procedure: {ex.Procedure}");
                                    Console.WriteLine($"Line Number: {ex.LineNumber}");
                                    Console.WriteLine($"State: {ex.State}");
                                    var preview = trimmedBatch.Length > 500 ? 
                                        trimmedBatch.Substring(0, 500) + "..." : 
                                        trimmedBatch;
                                    Console.WriteLine($"\nBatch preview:\n{preview}\n");
                                    return false;
                                }
                                // Silently ignore these errors (they're expected on first run)
                            }
                        }
                    }
                }

                return true;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"ERROR executing {filename}: {ex.Message}");
                return false;
            }
        }

        static async Task DisplayDatabaseSummary()
        {
            Console.WriteLine("Database Summary:");
            Console.WriteLine("------------------------------------------");

            var queries = new[]
            {
                "SELECT COUNT(*) FROM Ships",
                "SELECT COUNT(*) FROM Users",
                "SELECT COUNT(*) FROM CrewMembers",
                "SELECT COUNT(*) FROM CrewRanks",
                "SELECT COUNT(*) FROM ChartOfAccounts",
                "SELECT COUNT(*) FROM BudgetData",
                "SELECT COUNT(*) FROM AccountTransactions"
            };

            var tableNames = new[] { "Ships", "Users", "CrewMembers", "CrewRanks", 
                "ChartOfAccounts", "BudgetData", "AccountTransactions" };

            using (var connection = new SqlConnection(ConnectionString))
            {
                await connection.OpenAsync();

                for (int i = 0; i < queries.Length; i++)
                {
                    try
                    {
                        using (var command = new SqlCommand(queries[i], connection))
                        {
                            var count = await command.ExecuteScalarAsync();
                            Console.WriteLine($"  {tableNames[i],-25}: {count,6} records");
                        }
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine($"  {tableNames[i],-25}: Error ({ex.Message})");
                    }
                }
            }

            Console.WriteLine("------------------------------------------");
        }
    }
}
