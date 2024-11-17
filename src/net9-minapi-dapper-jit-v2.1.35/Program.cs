using Dapper;
using Microsoft.AspNetCore.Mvc;
using Npgsql;

Console.WriteLine(System.Runtime.InteropServices.RuntimeInformation.FrameworkDescription);
Console.WriteLine($"Npgsql:      {System.Reflection.Assembly.GetAssembly(typeof(NpgsqlConnection))?.GetName()?.Version?.ToString()}");
Console.WriteLine($"Dapper:      {System.Reflection.Assembly.GetAssembly(typeof(SqlMapper))?.GetName()?.Version?.ToString()}");

var builder = WebApplication.CreateSlimBuilder(args);
builder.WebHost.UseUrls("http://0.0.0.0:5503");
builder.Logging.SetMinimumLevel(LogLevel.Warning);
builder.Services.AddScoped(sp =>
{
    var connection = new NpgsqlConnection("Host=postgres;Port=5432;Username=testuser;Password=testpass;Database=testdb");
    connection.Open();
    return connection;
});
var app = builder.Build();

app.MapGet("/api/test-data", async (
    NpgsqlConnection connection,
    [FromQuery] int _records,
    [FromQuery] string _text_param,
    [FromQuery] int _int_param,
    [FromQuery] DateTime _ts_param,
    [FromQuery] bool _bool_param) => await connection.QueryAsync<Result>(
        """
        SELECT id1, foo1, bar1, datetime1, id2, foo2, bar2, datetime2, long_foo_bar, is_foobar
        FROM public.test_func_v1(@_records, @_text_param, @_int_param, @_ts_param::timestamp, @_bool_param)
        """, new
        {
            _records,
            _text_param,
            _int_param,
            _ts_param,
            _bool_param
        }));


app.Run();

public class Result
{
    public int id1 { get; set; }
    public string? foo1 { get; set; }
    public string? bar1 { get; set; }
    public DateTime datetime1 { get; set; }
    public int id2 { get; set; }
    public string? foo2 { get; set; }
    public string? bar2 { get; set; }
    public DateTime datetime2 { get; set; }
    public string? long_foo_bar { get; set; }
    public bool is_foobar { get; set; }
}
