# Deno Application

- deno 1.40.2
- oak 12.6.1
- postgres 0.17.0

Note: Deno Application has been excluded from testing because for some reason K6 request duplicates host and port name and I end up with this error:

deno-app-v1.40.2-1  | [uncaught application error]: TypeError - The server request URL of "http://deno-app-v1.40.2:3102http://deno-app-v1.40.2:3102/api/test-data?_records=10&_text_param=ABCDEFGHIJKLMNOPRSTUVWXYZ&_int_param=1234567890&_ts_param=2014-12-31T00%3A00%3A00.000Z&_bool_param=true" 