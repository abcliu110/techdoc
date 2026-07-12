package com.lowcode.app;

import static com.tngtech.archunit.lang.syntax.ArchRuleDefinition.classes;
import static com.tngtech.archunit.lang.syntax.ArchRuleDefinition.methods;
import static com.tngtech.archunit.lang.syntax.ArchRuleDefinition.noClasses;
import static com.tngtech.archunit.lang.syntax.ArchRuleDefinition.noMethods;

import com.tngtech.archunit.core.domain.JavaClasses;
import com.tngtech.archunit.core.domain.JavaClass;
import com.tngtech.archunit.core.domain.JavaConstructorCall;
import com.tngtech.archunit.core.domain.JavaFieldAccess;
import com.tngtech.archunit.core.importer.ClassFileImporter;
import com.tngtech.archunit.core.importer.ImportOption;
import com.tngtech.archunit.base.DescribedPredicate;
import com.tngtech.archunit.lang.ArchCondition;
import com.tngtech.archunit.lang.ArchRule;
import com.tngtech.archunit.lang.ConditionEvents;
import com.tngtech.archunit.lang.SimpleConditionEvent;
import org.junit.jupiter.api.Test;
import org.springframework.transaction.annotation.Transactional;

class ArchitectureRulesTest {

  private final JavaClasses classes =
      new ClassFileImporter()
          .withImportOption(ImportOption.Predefined.DO_NOT_INCLUDE_TESTS)
          .importPackages("com.lowcode");

  @Test
  void controllers_shouldNotAccessMappers() {
    ArchRule rule =
        noClasses()
            .that()
            .resideInAPackage("..api..")
            .should()
            .dependOnClassesThat()
            .resideInAPackage("..dao..");

    rule.check(classes);
  }

  @Test
  void entities_shouldNotBeUsedByApiMethods() {
    DescribedPredicate<JavaClass> entityReturnType =
        new DescribedPredicate<>("raw return type ending with Entity") {
          @Override
          public boolean test(JavaClass input) {
            return input.getSimpleName().endsWith("Entity");
          }
        };

    ArchRule rule =
        noMethods()
            .that()
            .areDeclaredInClassesThat()
            .resideInAPackage("..api..")
            .should()
            .haveRawReturnType(entityReturnType);

    rule.check(classes);
  }

  @Test
  void supportPackages_shouldStayInsideTheirModule() {
    ArchRule rule =
        classes()
            .that()
            .resideInAPackage("com.lowcode.(*)..support..")
            .should()
            .onlyBeAccessed()
            .byClassesThat()
            .resideInAnyPackage("com.lowcode.$1..")
            .allowEmptyShould(true);

    rule.check(classes);
  }

  @Test
  void onlyExpressionModuleMayDependOnAviator() {
    ArchRule rule =
        noClasses()
            .that()
            .resideOutsideOfPackage("com.lowcode.expression..")
            .should()
            .dependOnClassesThat()
            .resideInAnyPackage("com.googlecode.aviator..");

    rule.check(classes);
  }

  @Test
  void transactionalShouldOnlyBeDeclaredInServiceLayer() {
    ArchRule rule =
        methods()
            .that()
            .areAnnotatedWith(Transactional.class)
            .should()
            .beDeclaredInClassesThat()
            .resideInAPackage("..service..")
            .allowEmptyShould(true);

    rule.check(classes);
  }

  @Test
  void runtimeDynamicSql_shouldOnlyBeAssembledInSqlAssembler() {
    ArchRule rule =
        noClasses()
            .that()
            .resideInAPackage("com.lowcode.runtime.data..")
            .and()
            .doNotHaveSimpleName("DynamicSqlAssembler")
            .should(new ArchCondition<>("access SQL text constants outside DynamicSqlAssembler") {
              @Override
              public void check(JavaClass item, ConditionEvents events) {
                for (JavaFieldAccess access : item.getFieldAccessesFromSelf()) {
                  if (access.getTarget().getFullName().contains("DynamicSqlAssembler")) {
                    continue;
                  }
                  String target = access.getTarget().getName().toLowerCase();
                  if (target.contains("sql")) {
                    events.add(SimpleConditionEvent.violated(
                        item,
                        item.getName() + " accesses possible SQL field " + access.getTarget().getFullName()));
                  }
                }
              }
            })
            .allowEmptyShould(true);

    rule.check(classes);
  }

  @Test
  void appLayer_shouldNotInstantiateHiddenInMemoryImplementations() {
    ArchRule rule =
        noClasses()
            .that()
            .resideInAPackage("com.lowcode.app..")
            .should(new ArchCondition<>("instantiate in-memory implementations from app layer") {
              @Override
              public void check(JavaClass item, ConditionEvents events) {
                for (JavaConstructorCall call : item.getConstructorCallsFromSelf()) {
                  JavaClass owner = call.getTargetOwner();
                  if (owner.getSimpleName().startsWith("InMemory")) {
                    events.add(SimpleConditionEvent.violated(
                        item,
                        item.getName() + " instantiates hidden in-memory type " + owner.getName()));
                  }
                }
              }
            })
            .allowEmptyShould(true);

    rule.check(classes);
  }
}
