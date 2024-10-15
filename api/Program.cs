using Azure.Monitor.OpenTelemetry.AspNetCore;

var builder = WebApplication.CreateSlimBuilder(args);
builder.Services.AddOpenTelemetry().UseAzureMonitor();
var app = builder.Build();

app.MapGet("/ping", () => "pong");

app.Run();
