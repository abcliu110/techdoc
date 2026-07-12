package com.lowcode.app.selfcheck;

import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/selfcheck/prefix")
class PrefixedMappingController {

  @PostMapping("/submit")
  String submit() {
    return "ok";
  }
}
