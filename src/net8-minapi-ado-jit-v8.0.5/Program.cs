using Microsoft.AspNetCore.Mvc;
using Npgsql;

Console.WriteLine(System.Runtime.InteropServices.RuntimeInformation.FrameworkDescription);
Console.WriteLine($"Npgsql: {System.Reflection.Assembly.GetAssembly(typeof(NpgsqlConnection))?.GetName()?.Version?.ToString()}");

var builder = WebApplication.CreateSlimBuilder(args);
builder.WebHost.UseUrls("http://0.0.0.0:5005");
builder.Logging.SetMinimumLevel(LogLevel.Warning);
builder.Services.AddScoped(sp =>
{
    var connection = new NpgsqlConnection("Host=postgres;Port=5432;Username=testuser;Password=testpass;Database=testdb");
    connection.Open();
    return connection;
});
var app = builder.Build();

app.MapGet("/api/test-data", TestData.Get);

app.Run();

public static class TestData
{
    public static async IAsyncEnumerable<Result> Get(
        NpgsqlConnection connection,
        [FromQuery] int _records,
        [FromQuery] string _text_param,
        [FromQuery] int _int_param,
        [FromQuery] DateTime _ts_param,
        [FromQuery] bool _bool_param)
    {
        using var command = connection.CreateCommand();
        command.CommandText =
            """
            SELECT id1, foo1, bar1, datetime1, id2, foo2, bar2, datetime2, long_foo_bar, is_foobar
            FROM public.test_func_v1($1, $2, $3, $4::timestamp, $5)
            """;
        command.Parameters.Add(new() { Value = _records });
        command.Parameters.Add(new() { Value = _text_param });
        command.Parameters.Add(new() { Value = _int_param });
        command.Parameters.Add(new() { Value = _ts_param });
        command.Parameters.Add(new() { Value = _bool_param });

        using var reader = await command.ExecuteReaderAsync();
        while (await reader.ReadAsync())
        {
            yield return new Result
            {
                id1 = reader.GetInt32(0),
                foo1 = reader.IsDBNull(1) ? null : reader.GetString(1),
                bar1 = reader.IsDBNull(2) ? null : reader.GetString(2),
                datetime1 = reader.GetDateTime(3),
                id2 = reader.GetInt32(4),
                foo2 = reader.IsDBNull(5) ? null : reader.GetString(5),
                bar2 = reader.IsDBNull(6) ? null : reader.GetString(6),
                datetime2 = reader.GetDateTime(7),
                long_foo_bar = reader.IsDBNull(8) ? null : reader.GetString(8),
                is_foobar = reader.GetBoolean(9)
            };
        }
    }
}

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
