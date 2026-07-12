package com.lowcode.app.selfcheck;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
class DirectMappingController {

  @GetMapping("/api/selfcheck/direct/ping")
  String ping() {
    return "ok";
  }
}
