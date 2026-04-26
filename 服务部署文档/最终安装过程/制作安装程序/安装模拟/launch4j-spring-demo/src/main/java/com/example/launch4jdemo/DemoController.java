package com.example.launch4jdemo;

import java.time.OffsetDateTime;
import java.util.Map;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class DemoController {

  @GetMapping("/")
  public Map<String, Object> index() {
    return Map.of(
        "app", "launch4j-spring-demo",
        "message", "Hello from Spring Boot packaged by Launch4j",
        "time", OffsetDateTime.now().toString());

  }

  @GetMapping("/ping")
  public Map<String, Object> ping() {
    return Map.of("status", "ok");
  }
}
