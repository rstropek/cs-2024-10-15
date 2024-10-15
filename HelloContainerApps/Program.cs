using Azure.Monitor.OpenTelemetry.AspNetCore;
using Microsoft.Data.SqlClient;

var builder = WebApplication.CreateSlimBuilder(args);
builder.Services.AddHttpClient();
builder.Services.AddOpenTelemetry().UseAzureMonitor();
var app = builder.Build();

app.MapGet("/ping", () => "pong2");
app.MapGet("/king", () => "kong2");

app.MapGet("/exception", () => {
    if (Random.Shared.Next(10) > 5)
    {
        throw new Exception("Random exception");
    }

    return "ok";
});

app.MapGet("/pokemon", async (HttpClient client) => {
    var response = await client.GetFromJsonAsync<Pokemon>("https://pokeapi.co/api/v2/pokemon/ditto");
    return response!.Name;
});

app.MapGet("/sql", async (IConfiguration configuration) => {
    using var connection = new SqlConnection(configuration.GetConnectionString("SqlConnection"));
    await connection.OpenAsync();
    var command = connection.CreateCommand();
    command.CommandText = "SELECT 1 AS result";
    var result = await command.ExecuteScalarAsync();
    return result;
});

app.Run();

record Pokemon(string Name);
