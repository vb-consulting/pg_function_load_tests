import { check } from "k6";
import http from "k6/http";
import { textSummary } from 'https://jslib.k6.io/k6-summary/0.0.2/index.js';

const stamp = __ENV.STAMP.trim();
const tag = __ENV.TAG.trim();
const records = Number(__ENV.RECORDS.trim() || "10")
const duration = __ENV.DURATION.trim() || "60s";
const target = Number(__ENV.TARGET.trim() || "100");
const port = __ENV.PORT.trim();
const path = __ENV.REQ_PATH ? __ENV.REQ_PATH.trim() : (tag.indexOf('postgrest') != -1 ? '/rpc/test_func_v1' : '/api/test-data');

const url = 'http://' +  tag + ':' + port + path + "?" + 
    Object.entries({
        _records: records,
        _text_param: 'ABCDEFGHIJKLMNOPRSTUVWXYZ',
        _int_param: 1234567890,
        _ts_param: new Date('2014-12-31').toISOString(),
        _bool_param: true
    })
    .map(([key, value]) => `${key}=${encodeURIComponent(value)}`)
    .join('&');

// define configuration
export const options = {
    // define thresholds
    thresholds: {
        http_req_failed: [{ threshold: "rate<0.01", abortOnFail: true }], // availability threshold for error rate
        http_req_duration: ["p(99)<1000"], // Latency threshold for percentile
    },
    // define scenarios
    scenarios: {
        breaking: {
            executor: "ramping-vus",
            stages: [
                { duration: duration, target: target },
            ],
        },
    },
};

export default function () {
    const res = http.get(url);
    check(res, {
        [`${tag} status is 200`]: (r) => r.status === 200,
        [`${tag} response is JSON`]: (r) => r.headers['Content-Type'] && r.headers['Content-Type'].includes('application/json'),
        [`${tag} response has data`]: (r) => r.body && JSON.parse(r.body).length > 0,
        [`${tag} response data has all fields`]: (r) => {
            let d = JSON.parse(r.body)[0];
            return d.id1 && d.foo1 && d.bar1 && d.datetime1 && d.id2 && d.foo2 && d.bar2 && d.datetime2 && d.long_foo_bar && d.is_foobar;
        }
    });
}

export function handleSummary(data) {
    const fileTag = `${tag}_${records}rec_${duration}vus_${target}`;
    const reqs = data.metrics.http_reqs.values.count;
    const reqsPerSec = data.metrics.http_reqs.values.rate.toFixed(2) + "/s";
    const reqsDuration = data.metrics.iteration_duration.values.avg.toFixed(2) + "ms";
    const failedReqs = data.metrics.http_req_failed.values.passes;
    return {
        [`/results/${stamp}/${fileTag}_summary.txt`]: textSummary(data, { indent: ' ', enableColors: false }),
        //[`/results/${stamp}/${fileTag}_summary.json`]: JSON.stringify(data, null, 2),
        [`/results/${stamp}/${fileTag}.md`]: `|${tag}|${target}|${duration}|${records}|${reqs}|${reqsPerSec}|${reqsDuration}|${failedReqs}|[summary](/${stamp}/${fileTag}_summary.txt)|`,
    }
}
