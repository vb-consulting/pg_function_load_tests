using Npgsql;
using NpgsqlRest;

Console.WriteLine(System.Runtime.InteropServices.RuntimeInformation.FrameworkDescription);
Console.WriteLine($"Npgsql:     {System.Reflection.Assembly.GetAssembly(typeof(NpgsqlConnection))?.GetName()?.Version?.ToString()}");
Console.WriteLine($"NpgsqlRest  {System.Reflection.Assembly.GetAssembly(typeof(NpgsqlRestOptions))?.GetName()?.Version?.ToString()}");

var builder = WebApplication.CreateSlimBuilder(args);
builder.WebHost.UseUrls("http://0.0.0.0:5001");
builder.Logging.SetMinimumLevel(LogLevel.Warning);
var app = builder.Build();

app.UseNpgsqlRest(new NpgsqlRestOptions
{
    ConnectionString = "Host=postgres;Port=5432;Username=testuser;Password=testpass;Database=testdb",
    NameConverter = url => url,
    RequiresAuthorization = false,
    LogEndpointCreatedInfo = true,
    LogAnnotationSetInfo = false,
    LogConnectionNoticeEvents = false,
});
app.Run();
