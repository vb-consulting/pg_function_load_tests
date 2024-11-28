using Npgsql;
using NpgsqlRest;

Console.WriteLine(System.Runtime.InteropServices.RuntimeInformation.FrameworkDescription);
Console.WriteLine($"Npgsql:     {System.Reflection.Assembly.GetAssembly(typeof(NpgsqlConnection))?.GetName()?.Version?.ToString()}");
Console.WriteLine($"NpgsqlRest  {System.Reflection.Assembly.GetAssembly(typeof(NpgsqlRestOptions))?.GetName()?.Version?.ToString()}");

var builder = WebApplication.CreateSlimBuilder(args);
builder.WebHost.UseUrls("http://0.0.0.0:5507");
builder.Logging.SetMinimumLevel(LogLevel.Warning);
var app = builder.Build();

await using var dataSource = new NpgsqlDataSourceBuilder("Host=postgres;Port=5432;Username=testuser;Password=testpass;Database=testdb").Build();
app.UseNpgsqlRest(new NpgsqlRestOptions
{
    DataSource = dataSource,
    ServiceProviderMode = ServiceProviderObject.None,
    NameConverter = url => url,
    RequiresAuthorization = false,
    LogEndpointCreatedInfo = true,
    LogAnnotationSetInfo = false,
    LogConnectionNoticeEvents = false,
});
app.Run();
