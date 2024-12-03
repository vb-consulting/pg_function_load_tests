create
    or
    replace procedure test_handler(request omni_httpd.http_request, outcome inout omni_httpd.http_outcome)
    language plpgsql as
$$
declare
   params text[];
   num_records int;
   text_param text;
   int_param int;
   ts_param timestamp;
   bool_param bool;
   response json;
begin
    if request.method = 'GET' and request.path = '/api/test-data' then
	params := omni_web.parse_query_string(request.query_string);
	num_records := coalesce(omni_web.param_get(params, '_records'), '0')::int;
	text_param := coalesce(omni_web.param_get(params, '_text_param'), '');
	int_param := coalesce(omni_web.param_get(params, '_int_param'), '0')::int;
	ts_param := omni_web.param_get(params, '_ts_param')::timestamp;
	bool_param := coalesce(omni_web.param_get(params, '_bool_param'), 'false')::bool;

	select json_agg(to_json((test_func_v1)))
	    into response
            from public.test_func_v1(num_records, text_param, int_param, ts_param, bool_param);

	outcome := omni_httpd.http_response(response);
    end if;
end;
$$;

create or replace function omni_httpd.handler(int, omni_httpd.http_request) returns omni_httpd.http_outcome
    security definer
    language plpgsql
as
$$
declare
    req     omni_httpd.http_request;
    outcome omni_httpd.http_outcome;
begin
    req := $2;
    call test_handler(req, outcome);
    return outcome;
end;
$$;
