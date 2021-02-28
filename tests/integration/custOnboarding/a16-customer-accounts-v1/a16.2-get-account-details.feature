@A16_CUSTOMER_ACCOUNTS_V1
Feature: Get Account Details

  Background:
    * configure charset = null

  @GatewayAPI @A16.2 @NOVOAM-603 @NOVOAM-603.1 @TST @Smoke @SIT
  Scenario: Get account details from an account

    * def getHeader = call read('classpath:shared/get-gateway-access-token.feature')
    * def headers = get getHeader.headers
    * def token = get getHeader.l3_token
    * def customerId = get getHeader.customerId

    * def newAccount = call read('classpath:shared/create-new-customer-account.feature') { token: '#(token)', customerId: '#(customerId)' }
    * def accountId = get newAccount.arrangementId
    * def owner =
    """
    {
      givenName: '#string',
      middleName: '##string',
      familyName: '#string',
      partyRole: '#string',
      partyId: '#string'
    }
    """

    * def alternateId = {alternateId: '##string', alternateIdType: '#string'}
    * def roundUp = { roundUpCap: '#string'}
    * def payId = '##string'

    * def expectedResponse =
    """
    {
      "accountDetails": {
        "accountProvider": '#string',
        "accountId": '#string',
        "arrangementId": '#string',
        "accountStatus": '#string',
        "creationDate": '#string',
        "displayName": '#string',
        "bsb": '#string',
        "payId": '##[] payId',
        "accountHolders": '#[] owner',
        "roundUpLinkedSavingsAccount": {},
        "roundUp": '##[] roundUp',
        "postingRestrictions": [],
        "alternateIds": '#[] alternateId',
        "products": {
          "productId": '#string',
          "productDescription": '#string'
        },
        "balance": {
          "currentBalance": '#number',
          "availableBalance": '#number',
          "lockedBalance": '#number'
        },
        "numberOfWithdrawals": '#number',
        "numberOfDeposits": '#number',
        "accountNumber": '#string'
      },
      "interestDetails": {
        "qualifiedBonusThisMonth": '#boolean',
        "qualifedBonusNextMonth": '#boolean',
        "interestRate": '#number',
        "bonusInterestRate": '#number',
        "interestYearToDate": '#number',
        "previousYearInterestYearToDate": '#number',
        "interestMonthly": '#number',
        "staticLimit": '#number'
      },
      "goal": '##[]'
    }
    """

    Given url baseUrl
    And path '/customer-accounts/v1/account-details'
    And headers headers
    And header accountIdentifier = accountId
    When method GET
    Then status 200
    And match response == expectedResponse

  @GatewayAPI @A16.2 @NOVOAM-603 @NOVOAM-603.2 @TST @SIT
  Scenario Outline: Verify Get Account Details unsuccessfully with invalid header - no <selectedHeader>
    * def getHeader = call read('classpath:shared/get-gateway-headers.feature')
    * def headers = getHeader.headers
    * def filename = 'data-'+karate.env+'.json'
    * print filename
    * def testData = read('classpath:features/a16-customer-accounts-v1/testdata/' + filename + '')
    * def customerId = testData.getaccountDetails.customerId
    * def username = testData.getaccountDetails.username
    * def accessCode = testData.getaccountDetails.accessCode
    * def lvl2Response = callonce read('classpath:shared/get-ciam-l2-token-using-l1-token.feature') { username: '#(username)', access_code: '#(accessCode)', device_id: '#(username)' }
    * def accessToken = get lvl2Response.accessToken
    * def getAccount = call read('classpath:shared/get-customer-account.feature') {token: '#(accessToken)'}
    * def accountDetails = get getAccount.account.accounts[0]
    * def accIdentifier = accountDetails.arrangementId

    * def headerErrorResponse =
    """
    {
      "code": "SPVAL0004",
      "message": "Header Validation Failed",
      "supportReferenceId": "#string",
      "timestamp": "#string"
    }
    """
    * def noOCPResponse =
    """
    {
      "statusCode": 401,
      "message": "Access denied due to missing subscription key. Make sure to include subscription key when making requests to an API."
    }
    """
    * remove <selectedHeader>

    Given url baseUrl
    And path '/customer-accounts/v1/account-details'
    And headers headers
    And header accountIdentifier = accIdentifier
    When method GET
    Then status <status>
    And match response == <expectedResponse>

    Examples:
      | selectedHeader                    | status | expectedResponse    |
      | headers.Request-Id                | 400    | headerErrorResponse |
      | headers.Timestamp                 | 400    | headerErrorResponse |
      | headers.Sending-System-Version    | 400    | headerErrorResponse |
      | headers.Sending-System-Id         | 400    | headerErrorResponse |
      | headers.Initiating-System-Id      | 400    | headerErrorResponse |
      | headers.Initiating-System-Version | 400    | headerErrorResponse |
      | headers.Ocp-Apim-Subscription-Key | 401    | noOCPResponse       |