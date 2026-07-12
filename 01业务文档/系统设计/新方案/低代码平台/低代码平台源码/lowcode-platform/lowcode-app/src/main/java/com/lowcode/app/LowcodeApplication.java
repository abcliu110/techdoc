package com.lowcode.app;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * 模块化单体的 Spring Boot 装配入口。
 *
 * <p>app 模块只承担装配边界。业务逻辑必须留在各自归属模块里，这样后续如果部署边界变化，M0 的模块化单体决策仍然可逆。
 */
@SpringBootApplication(scanBasePackages = "com.lowcode")
public class LowcodeApplication {

  public static void main(String[] args) {
    SpringApplication.run(LowcodeApplication.class, args);
  }
}
