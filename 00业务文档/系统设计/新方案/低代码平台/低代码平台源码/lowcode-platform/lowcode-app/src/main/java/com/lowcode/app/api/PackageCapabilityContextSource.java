package com.lowcode.app.api;

import com.lowcode.metamodel.domain.service.PackageManifestValidationContext;

/**
 * Supplies server-trusted package capability context for package precheck and marketplace lifecycle.
 */
interface PackageCapabilityContextSource {

  PackageManifestValidationContext resolve(String tenantId);
}
