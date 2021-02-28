@A16_CUSTOMER_ACCOUNTS_V1
Feature: Get Interim statements
# Test Data: Existing Customer in T24 and CIAM with account created in T24
  Background:

    * configure charset = null

  @GatewayAPI @A16.3 @NOVOST-75.1 @TST @Smoke @SIT
  Scenario: Get Interim Statements
    * def getHeader = call read('classpath:shared/get-gateway-access-token.feature')
    * def headers = getHeader.headers
    * def token = get getHeader.l3_token
    * def customerId = get getHeader.customerId
    * def newAccount = call read('classpath:shared/create-new-customer-account.feature') { token: '#(token)', customerId: '#(customerId)' }
    * def arrangementId = get newAccount.arrangementId

    * def requestBody =
    """
    {
      "arrangementId": "#(arrangementId)",
      "productId": "VMA.TRANSAC.ACCOUNT"
    }
    """

    Given url baseUrl
    And path '/customer-accounts/v1/statement'
    And headers headers
    And request requestBody
    When method POST
    Then status 200
    And match response ==
    """
     {
      "statementStartDate": "#present",
      "statementEndDate": "#present"
      }
    """

  @GatewayAPI @A16.3 @NOVOST-75.2 @TST @SIT
  Scenario Outline: Verify get interim statements with invalid header
    * print "Verify get interim statements with invalid header "

    * def getHeader = call read('classpath:shared/get-gateway-headers.feature')
    * def headers = getHeader.headers
#    * def customerId = "127544"
#    * def username = "61440589387"
#    * def accessCode = "612604"
    * def filename = 'data-'+karate.env+'.json'
    * print filename
    * def testData = read('classpath:features/a16-customer-accounts-v1/testdata/' + filename + '')
    * def customerId = testData.interimStatement.customerId
    * def username = testData.interimStatement.username
    * def accessCode = testData.interimStatement.accessCode
    * def lvl3Response = callonce read('classpath:shared/get-ciam-l3-token.feature') { username: '#(username)', access_code: '#(accessCode)', device_id: '#(username)' }
    * def accessToken = get lvl3Response.accessToken
    * def l2accessToken = lvl3Response.lvl2accessToken
    * def getAccount = callonce read('classpath:shared/get-customer-account.feature') {token: '#(l2accessToken)'}
    * def accountDetails = get getAccount.account.accounts[0]
    * def arrangementId = accountDetails.arrangementId
    * def requestBody =
    """
    {
      "arrangementId": "#(arrangementId)",
      "productId": "VMA.TRANSAC.ACCOUNT"
    }
    """

    Given url baseUrl
    And path '/customer-accounts/v1/statement'
    And headers headers
    And header Authorization = 'Bearer ' + accessToken
    And header Request-Id = <Request-Id>
    And header Timestamp =  <Timestamp>
    And header Sending-System-Version =  <Sending-System-Version>
    And header Sending-System-Id = <Sending-System-Id>
    And header Initiating-System-Id = <Initiating-System-Id>
    And header Initiating-System-Version = <Initiating-System-Version>
    And header Accept = <Accept>
    And header Content-Type = <Content-Type>
    And header Ocp-Apim-Subscription-Key = <Ocp-Apim-Subscription-Key>
    And request requestBody
    When method POST
    Then status <status_Code>
    And match response == <expectedResponse>

    Examples:
      | Request-Id               | Timestamp                    | Initiating-System-Id | Initiating-System-Version | Sending-System-Version | Sending-System-Id | Ocp-Apim-Subscription-Key | Accept      | Content-Type | expectedResponse                                                                                   | status_Code |
      | RandomUtils.randomUUID() | RandomUtils.getCurrentDate() | 'REF001'             | ' '                       | 'v1.0'                 | 'REF001'          | ocpKey                    | contentType | contentType  | {"code": "SPVAL0004","message": "#present","supportReferenceId": "#string","timestamp": "#string"} | 400         |
      | ' '                      | RandomUtils.getCurrentDate() | 'REF001'             | 'v1.0'                    | 'v1.0'                 | 'REF001'          | ocpKey                    | contentType | contentType  | {"code": "SPVAL0004","message": "#present","supportReferenceId": "#string","timestamp": "#string"} | 400         |
      | RandomUtils.randomUUID() | ' '                          | 'REF001'             | 'v1.0'                    | 'v1.0'                 | 'REF001'          | ocpKey                    | contentType | contentType  | {"code": "SPVAL0004","message": "#present","supportReferenceId": "#string","timestamp": "#string"} | 400         |
      | RandomUtils.randomUUID() | RandomUtils.getCurrentDate() | ' '                  | 'v1.0'                    | 'v1.0'                 | 'REF001'          | ocpKey                    | contentType | contentType  | {"code": "SPVAL0004","message": "#present","supportReferenceId": "#string","timestamp": "#string"} | 400         |
      | RandomUtils.randomUUID() | RandomUtils.getCurrentDate() | 'REF001'             | 'v1.0'                    | ' '                    | 'REF001'          | ocpKey                    | contentType | contentType  | {"code": "SPVAL0004","message": "#present","supportReferenceId": "#string","timestamp": "#string"} | 400         |
      | RandomUtils.randomUUID() | RandomUtils.getCurrentDate() | 'REF001'             | 'v1.0'                    | 'v1.0'                 | ' '               | ocpKey                    | contentType | contentType  | {"code": "SPVAL0004","message": "#present","supportReferenceId": "#string","timestamp": "#string"} | 400         |
      | RandomUtils.randomUUID() | RandomUtils.getCurrentDate() | 'REF001'             | 'v1.0'                    | 'v1.0'                 | 'REF001'          | ' '                       | contentType | contentType  | {"statusCode": 401,"message": "#present"}                                                          | 401         |
