package com.example.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.sql.Timestamp;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.List;
import java.util.Map;

@RestController
public class TestController {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @GetMapping("/api/test-data")
    public ResponseEntity<?> getTestData(
            @RequestParam("_records") Integer numRecords,
            @RequestParam("_text_param") String textParam,
            @RequestParam("_int_param") Integer intParam,
            @RequestParam("_ts_param") String tsParam,
            @RequestParam("_bool_param") Boolean boolParam) {
        
        try {
            // Convert ISO-8601 string to Timestamp
            Instant instant = Instant.parse(tsParam);
            LocalDateTime localDateTime = LocalDateTime.ofInstant(instant, ZoneId.systemDefault());
            Timestamp timestamp = Timestamp.valueOf(localDateTime);

            String sql = """
                SELECT id1, foo1, bar1, datetime1, id2, foo2, bar2, datetime2, 
                       long_foo_bar, is_foobar 
                FROM public.test_func_v1(?, ?, ?, ?::timestamp, ?)
                """;
            
            List<Map<String, Object>> result = jdbcTemplate.queryForList(
                sql,
                numRecords,
                textParam,
                intParam,
                timestamp,
                boolParam
            );
            
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            return ResponseEntity
                .status(500)
                .body(Map.of("error", e.getMessage()));
        }
    }
}