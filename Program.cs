using System.Text.Json;
using Microsoft.AspNetCore.Mvc;

var builder = WebApplication.CreateBuilder(args);

// Bind to 0.0.0.0 and use PORT from environment (for Render)
builder.WebHost.UseUrls("http://0.0.0.0:" + Environment.GetEnvironmentVariable("PORT") ?? "5000");

var app = builder.Build();

// Endpoint para activar licencia
app.MapGet("/activate", ([FromQuery] string key, [FromQuery] string hwid) =>
{
    var licenses = LoadLicenses();
    if (licenses.TryGetValue(key, out var license) && !license.Used)
    {
        license.Used = true;
        license.HWID = hwid;
        SaveLicenses(licenses);
        return Results.Ok("TokenValido");
    }
    return Results.BadRequest("Clave inválida");
});

app.Run();

Dictionary<string, License> LoadLicenses()
{
    if (File.Exists("licenses.json"))
    {
        return JsonSerializer.Deserialize<Dictionary<string, License>>(File.ReadAllText("licenses.json")) ?? new();
    }
    return new();
}

void SaveLicenses(Dictionary<string, License> licenses)
{
    File.WriteAllText("licenses.json", JsonSerializer.Serialize(licenses));
}

class License
{
    public bool Used { get; set; }
    public string HWID { get; set; } = string.Empty;
}