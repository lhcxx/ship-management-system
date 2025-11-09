using System;
using Microsoft.Data.SqlClient;

var cs = "Server=tcp:sqlshipmasys.database.windows.net,1433;Initial Catalog=ship;User ID=ship;Password=sys2026!;Encrypt=True;TrustServerCertificate=False;";
using var conn = new SqlConnection(cs);
conn.Open();
using var cmd = new SqlCommand("SELECT COUNT(*) FROM CrewServiceHistory", conn);
Console.WriteLine($"CrewServiceHistory records: {cmd.ExecuteScalar()}");

// Check if CREW001 already exists
cmd.CommandText = "SELECT COUNT(*) FROM CrewServiceHistory WHERE CrewId='CREW001'";
Console.WriteLine($"CREW001 records: {cmd.ExecuteScalar()}");
