from rest_framework.decorators import api_view
from rest_framework.response import Response
from django.db import connection
from datetime import datetime

@api_view(['GET'])
def get_test_data(request):
    # Get parameters from query string with defaults
    num_records = int(request.GET.get('p_records'))
    text_param = request.GET.get('p_text_param')
    int_param = int(request.GET.get('p_int_param'))
    ts_param = request.GET.get('p_ts_param')
    bool_param = request.GET.get('p_bool_param').lower() == 'true'
    
    with connection.cursor() as cursor:
        cursor.execute(
            """
            select id1, foo1, bar1, datetime1, id2, foo2, bar2, datetime2, long_foo_bar, is_foobar from test_func_v1(
                %s, %s, %s, %s::timestamp, %s
            )
            """,
            [num_records, text_param, int_param, ts_param, bool_param]
        )
        columns = [col[0] for col in cursor.description]
        results = [
            dict(zip(columns, row))
            for row in cursor.fetchall()
        ]
    
    return Response(results)
