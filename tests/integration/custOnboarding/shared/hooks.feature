@ignore
Feature: Hooks implementation
  @afterScenario
  Scenario:
    * print 'about to end SCENARIO:'
    * print '> feature name:  ', caller.featureFileName
    * print '> scenario name: ', caller.scenarioName

  @afterFeature
  Scenario:
    * print 'about to end FEATURE: ', caller.featureFileName