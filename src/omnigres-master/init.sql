create function public.test_func_v1(
    _records int,
    _text_param text,
    _int_param int,
    _ts_param timestamp,
    _bool_param bool
) 
returns table(
    id1 int, 
    foo1 text, 
    bar1 text, 
    datetime1 timestamp, 
    id2 int, 
    foo2 text, 
    bar2 text, 
    datetime2 timestamp,
    long_foo_bar text, 
    is_foobar bool
)
stable
language sql
as
$$
select
    i + _int_param as id1,
    'foo' || '_' || _text_param || '_' || i::text as foo1,
    'bar' || i::text as bar1,
    (_ts_param::date) + (i::text || ' days')::interval as datetime1,
    i+1 + _int_param as id2,
    'foo' || '_' || _text_param || '_' || (i+1)::text as foo2,
    'bar' || '_' || _text_param || '_' || (i+1)::text as bar2,
    (_ts_param::date) + ((i+1)::text || ' days')::interval as datetime2,
    'long_foo_bar_' || '_' || _text_param || '_' || (i+2)::text as long_foo_bar, 
    (i % 2)::boolean and _bool_param as is_foobar
from
    generate_series(1, _records) as i
$$;

comment on function public.test_func_v1(int, text, int, timestamp, bool) is 'HTTP GET /api/test-data';

show max_connections;