@ignore
Feature: Hooks implementation

  @afterScenario
  Scenario:
    * print '#(input)'
    * print '> scenario name: ', caller.scenarioName
    * def projectId = '1922'
    * def baseUrlQTest = 'https://qdigital.qtestnet.com/api/v3/projects/'+projectId+'/test-runs'
    * def token = '196223cc-1966-4729-89dd-12e4e16e34ba'
    * def automationTestCycleId = '81216'

    #==================================
    # Get Test Case ID
    * def scenarioName = caller.scenarioName
    * def testCaseId = TestDataUtils.extractTestCaseID(scenarioName)
    * print 'Test case id: --->' + testCaseId

    #=================================
    #Generate Execution End time
    * def getExecutionEndTime = TestDataUtils.getCurrentDateTime()
    * print 'Execution End time: ' + getExecutionEndTime
    * def getExecutionStarTime = TestDataUtils.getStartDate()
    * print 'Execution Start time: ' + getExecutionStarTime

    #==================================
    # Generating body of test run and test cycle
    * def testRunBody = read('classpath:shared/hooks/test-run.json')
    * set testRunBody.test_case.id = testCaseId
    * set testRunBody.name = scenarioName

    * def testLogBody = read('classpath:shared/hooks/test-log.json')
    * def testCaseLogCheck =
    """
    function(s){
      if(s) {
        return 602;
      } else {
        return 601;
      }
    }
    """
    * def testCaseResult = call testCaseLogCheck caller.errorMessage
    * print 'Execution end date: ' + end_date
    * set testLogBody.status.id = testCaseResult
    * set testLogBody.exe_start_date = getExecutionStarTime
    * set testLogBody.exe_end_date = getExecutionEndTime

    * print testCaseResult

    #==============================
    # Create test run
    Given url baseUrlQTest
    And param parentId = '81216'
    And param parentType = 'test-cycle'
    And header Content-Type = 'application/json'
    And header Authorization = 'Bearer ' + token
    When request testRunBody
    And method POST
    * def testRunId = $.id

    #============================
    # Create test log
    Given url baseUrlQTest
    And path testRunId
    And path 'test-logs'
    And header Content-Type = 'application/json'
    And header Authorization = 'Bearer ' + token
    When request testLogBody
    And method POST


  @afterFeature
  Scenario:
    * print 'about to end FEATURE: ', caller.featureFileName