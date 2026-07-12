package com.lowcode.metamodel.domain.service;

/** License 运行时上下文。 */
public record LicenseRuntimeContext(
    boolean licensed,
    boolean expired,
    boolean degraded,
    boolean offlineFileCorrupted,
    boolean internetReachable,
    boolean privateDeployment) {}
