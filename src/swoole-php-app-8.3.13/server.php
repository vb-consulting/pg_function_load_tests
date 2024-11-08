<?php
// server.php
use Swoole\HTTP\Server;
use Swoole\HTTP\Request;
use Swoole\HTTP\Response;

$server = new Server("0.0.0.0", 3103);

// Configure server
$server->set([
    'worker_num' => 4,
    'max_request' => 10000,
    'enable_coroutine' => true,
    'tcp_fastopen' => true,
]);
// Add server start callback
$server->on('start', function ($server) {
    echo "Swoole http server is started at http://0.0.0.0:3103\n";
});

// Create PDO pool
$pool = new \Swoole\Database\PDOPool(
    (new \Swoole\Database\PDOConfig())
        ->withHost(getenv('DB_HOST'))
        ->withPort(5432)
        ->withDbName(getenv('DB_NAME'))
        ->withUsername(getenv('DB_USER'))
        ->withPassword(getenv('DB_PASSWORD'))
        ->withDriver('pgsql')
);

$server->on('request', function (Request $request, Response $response) use ($pool) {
    // Parse request path
    $requestPath = parse_url($request->server['request_uri'], PHP_URL_PATH);
    
    if ($requestPath !== '/api/test-data' || $request->server['request_method'] !== 'GET') {
        $response->status(404);
        $response->header('Content-Type', 'application/json');
        $response->end(json_encode(['error' => 'Not Found']));
        return;
    }

    try {
        // Validate required parameters
        $requiredParams = ['_records', '_text_param', '_int_param', '_ts_param', '_bool_param'];
        $missingParams = array_filter($requiredParams, fn($param) => !isset($request->get[$param]));
        
        if (!empty($missingParams)) {
            $response->status(400);
            $response->header('Content-Type', 'application/json');
            $response->end(json_encode([
                'error' => 'Missing required parameters',
                'missing' => $missingParams
            ]));
            return;
        }

        // Get connection from pool
        $pdo = $pool->get();
        
        // Prepare and execute query
        $stmt = $pdo->prepare(
            'SELECT id1, foo1, bar1, datetime1, id2, foo2, bar2, datetime2, long_foo_bar, is_foobar 
             FROM public.test_func_v1(:records, :text, :int, :ts::timestamp, :bool)'
        );
        
        $stmt->bindValue(':records', (int) $request->get['_records'], PDO::PARAM_INT);
        $stmt->bindValue(':text', $request->get['_text_param'], PDO::PARAM_STR);
        $stmt->bindValue(':int', (int) $request->get['_int_param'], PDO::PARAM_INT);
        $stmt->bindValue(':ts', $request->get['_ts_param'], PDO::PARAM_STR);
        $stmt->bindValue(':bool', strtolower($request->get['_bool_param']) === 'true', PDO::PARAM_BOOL);
        
        $stmt->execute();
        $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        // Return connection to pool
        $pool->put($pdo);

        // Send response
        $response->header('Content-Type', 'application/json');
        $response->header('Access-Control-Allow-Origin', '*');
        $response->end(json_encode($results));

    } catch (Throwable $e) {
        $response->status(500);
        $response->header('Content-Type', 'application/json');
        $response->end(json_encode(['error' => $e->getMessage()]));
    }
});

$server->start();
