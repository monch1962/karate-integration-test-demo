@A16_CUSTOMER_ACCOUNTS_V1
Feature: Get Accounts
# Test Data: Existing Customer in T24 and CIAM with accounts created in T24
  Background:
    * def getHeader = call read('classpath:shared/get-gateway-access-token.feature')
    * def headers = getHeader.headers
    * def token = get getHeader.l3_token
    * def customerId = get getHeader.customerId
    * def newAccount = call read('classpath:shared/create-new-customer-account.feature') { token: '#(token)', customerId: '#(customerId)' }
    * def accountId = get newAccount.arrangementId
    * configure charset = null

  @GatewayAPI @A16.1 @NOVOAM-602 @NOVOAM-602.1 @TST @Smoke @SIT
  Scenario: Get all Accounts of a Customer

    * def owner =
    """
    {
      "partyRole": '#string',
      "givenName": '#string',
      "familyName": '#string',
      "middleName": '##string',
      "partyId": '#string'
    }
    """

    * def account =
    """
     {
      "isDataFromCache": '#boolean',
      "postingRestriction": '#number',
      "accountHolders": '#[] owner',
      "providerType": #number,
      "lastUpdated": "#string",
      "accountId": "#string",
      "pfmAccountId": ##number,
      "provider": "#string",
      "arrangementId": "#string",
      "accountType": "#string",
      "displayName": "#string",
      "isClosed": #boolean,
      "productCategory": "#string",
      "productName": "#string",
      "accountNumber": "#string",
      "bsbNumber": "#string",
      "currentBalance": #number,
      "availableBalance": #number,
      "lockedBalance": #number
    }
    """

    Given url baseUrl
    And path '/customer-accounts/v1/accounts'
    And headers headers
    When method GET
    Then status 200
    And match each response.accounts == account
    And match response.netBalance.balance == '#number'
    And match response.netBalance.isDataFromCache == '#boolean'
    And match response.netBalance.lastUpdated == '##string'

  @GatewayAPI @A16.1 @NOVOAM-602 @NOVOAM-602.2 @TST @SIT
  Scenario Outline: Verify get all accounts of a customer unsuccessfully with invalid header - no <selectedHeader>

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
    And path '/reference-data/v1/transaction-categories'
    And headers headers
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

  @GatewayAPI @A16.1 @NOVOAM-602 @NOVOAM-602.3 @TST @SIT
  Scenario: Get all Accounts of a Customer

    * def owner =
    """
    {
      "partyRole": '#string',
      "givenName": '#string',
      "familyName": '#string',
      "middleName": '##string',
      "partyId": '#string'
    }
    """

    * def account =
    """
     {
      "isDataFromCache": '#boolean',
      "postingRestriction": '#number',
      "accountHolders": '#[] owner',
      "providerType": #number,
      "lastUpdated": "#string",
      "accountId": "#string",
      "pfmAccountId": ##number,
      "pfmIncluded": '##boolean',
      "provider": "#string",
      "arrangementId": "#string",
      "accountType": "#string",
      "displayName": "#string",
      "isClosed": #boolean,
      "productCategory": "#string",
      "productName": "#string",
      "accountNumber": "#string",
      "bsbNumber": "#string",
      "currentBalance": #number,
      "availableBalance": #number,
      "lockedBalance": #number
    }
    """

    * def methodSum =
    """
     function(arrays) {
      var total = 0;
      for(var i in arrays) { total += arrays[i]; }
      return total;
     }
    """

    Given url baseUrl
    And path '/customer-accounts/v1/accounts'
    And headers headers
    And header includeLimits = true
    And header includePFM = true
    When method GET
    Then status 200
    And match each response.accounts == account
    And match $.netBalance.balance == '#number'
    And match $.netBalance.isDataFromCache == '#boolean'
    And match $.netBalance.lastUpdated == '##string'
    * def balances = karate.jsonPath(response, "$..availableBalance")
    * def finalBalance = methodSum(balances)
    * match $.netBalance.balance == finalBalance
