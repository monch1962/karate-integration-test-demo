@A16_CUSTOMER_ACCOUNTS_V1
Feature: Update account preferences

  Background:
    * def getHeader = call read('classpath:shared/get-gateway-access-token.feature')
    * def headers = get getHeader.headers
    * def token = get getHeader.l3_token
    * def customerId = get getHeader.customerId
    * configure charset = null

    * def newAccount = call read('classpath:shared/create-new-customer-account.feature') { token: '#(token)', customerId: '#(customerId)' }
    * def arrangementId = get newAccount.arrangementId
    * print arrangementId
    * def accountId = get newAccount.account
    * print accountId

  @GatewayAPI @A16.5 @NOVOAM-605 @NOVOAM-605.1 @TST @Smoke @SIT
  Scenario: Update Customer Account Preferences - Update Account name

    * def updatePayload =
    """
    {
      "accountType": "VMA.BUNDLE.SAVER",
      "accountName": "VMA SAVER 123"
    }
    """

    * def expectedResponse =
    """
    {
      "accountType": "VMA.BUNDLE.SAVER",
      "accountName": "VMA SAVER 123",
    }
    """

    Given url baseUrl
    And path '/customer-accounts/v1/account-preferences/' + arrangementId
    And headers headers
    And request updatePayload
    When method PATCH
    Then status 200
    And match response == expectedResponse

  @GatewayAPI @A16.5 @NOVOAM-605 @NOVOAM-605.2 @TST @SIT
  Scenario: Update Customer Account Preferences - Update roundUpCap

    * def updatePayload =
    """
    {
      "accountType": "VMA.BUNDLE.SAVER",
       "roundUpArrangementId": "#(accountId)",
      "roundUpCap": "1"
    }
    """

    * def expectedResponse =
    """
    {
      "roundUpArrangementId": "#(accountId)",
      "roundUpCap": "1"
    }
    """

    Given url baseUrl
    And path '/customer-accounts/v1/account-preferences/' + arrangementId
    And headers headers
    And request updatePayload
    When method PATCH
    Then status 200
    And match response == expectedResponse

  @GatewayAPI @A16.5 @NOVOAM-605 @NOVOAM-605.3 @TST @SIT
  Scenario Outline: Update Customer Account Preferences - Invalid mandatory values

    * def updatePayload =
    """
    {
      "accountType": "<accountType>",
      "roundUpArrangementId": "<roundUpArrangementId>",
      "roundUpCap": "1"
    }
    """

    * def expectedResponse =
    """
    {
      "code": "#string",
      "message": "<message>",
      "supportReferenceId": "#string",
      "timestamp": "#string"
    }
    """
    Given url baseUrl
    And path '/customer-accounts/v1/account-preferences/' + arrangementId
    And headers headers
    And request updatePayload
    When method PATCH
    Then status 400
    And match response == expectedResponse

    Examples:
      | accountType      | roundUpArrangementId | message                     |
      | VMA.BUNDLE.SAVE  | 1000000066           | MISSING AA.PRODUCT - RECORD |
      | VMA.BUNDLE.SAVER | 1000000065           | ID IN FILE MISSING          |

  @GatewayAPI @A16.5 @NOVOAM-605 @NOVOAM-605.4 @TST @SIT
  Scenario: Update Customer Account Preferences - Invalid arrangementId of account of customer

    * def arrangementId = 'AA19280Q3RX'

    * def updatePayload =
    """
    {
      "accountType": "VMA.BUNDLE.SAVER",
      "roundUpArrangementId": "1000000066",
      "roundUpCap": "1"
    }
    """

    * def errorMessage = "Invalid Id Character(s)"

    Given url baseUrl
    And path '/customer-accounts/v1/account-preferences/' + arrangementId
    And headers headers
    And request updatePayload
    When method PATCH
    Then status 400
    And match response.message contains errorMessage

  @GatewayAPI @A16.5 @NOVOAM-605 @NOVOAM-605.5 @TST @SIT
  Scenario Outline: Verify missing validation headers for Update Account Preference - A16.5

    * def updatePayload =
    """
    {
      "accountType": "<accountType>",
      "roundUpArrangementId": "<roundUpArrangementId>",
      "roundUpCap": "1"
    }
    """

    * def expectedResponse =
    """
    {
      "code": "SPVAL0004",
      "message": "Header Validation Failed",
      "supportReferenceId": '#present',
      "timestamp": '#present'
    }
    """

    Given url baseUrl
    And path '/customer-accounts/v1/account-preferences/' + arrangementId
    And header Request-Id = "<Request-Id>"
    And header Timestamp = "<Timestamp>"
    And header Sending-System-Version = "<Sending-System-Version>"
    And header Request-Id = "<Sending-System-Id>"
    And header Initiating-System-Id = "<Initiating-System-Id>"
    And header Initiating-System-Version = "<Initiating-System-Version>"
    And header Accept = "<Accept>"
    And header Content-Type = "<Content-Type>"
    And header Ocp-Apim-Subscription-Key = ocpKey
    And request updatePayload
    When method PATCH
    Then assert responseStatus == 400
    And match response == expectedResponse

    Examples:
      | Request-Id | Timestamp            | Sending-System-Version | Sending-System-Id | Initiating-System-Id | Initiating-System-Version | Accept          | Content-Type    |
      |            | 2020-03-06T10:45:00Z | 1                      | 1                 | 1                    | 1                         | contentype/json | contentype/json |
      | 1          |                      | 1                      | 1                 | 1                    | 1                         | contentype/json | contentype/json |
      | 1          | 2020-03-06T10:45:00Z |                        | 1                 | 1                    | 1                         | contentype/json | contentype/json |
      | 1          | 2020-03-06T10:45:00Z | 1                      |                   | 1                    | 1                         | contentype/json | contentype/json |
      | 1          | 2020-03-06T10:45:00Z | 1                      | 1                 |                      | 1                         | contentype/json | contentype/json |
      | 1          | 2020-03-06T10:45:00Z | 1                      | 1                 | 1                    |                           | contentype/json | contentype/json |
      | 1          | 2020-03-06T10:45:00Z | 1                      | 1                 | 1                    | 1                         |                 | contentype/json |
      | 1          | 2020-03-06T10:45:00Z | 1                      | 1                 | 1                    | 1                         | contentype/json |                 |

  @GatewayAPI @A16.5 @NOVOAM-605 @NOVOAM-605.6 @TST @SIT
  Scenario: Update Customer Account Preferences - Missing OCP Key

    * def errorMessage = 'Access denied due to missing subscription key. Make sure to include subscription key when making requests to an API.'
    * def updatePayload =
    """
    {
      "accountType": "VMA.BUNDLE.SAVER",
      "roundUpArrangementId": "1000000066",
      "roundUpCap": "1"
    }
    """
    * remove headers.Ocp-Apim-Subscription-Key

    Given url baseUrl
    And path '/customer-accounts/v1/account-preferences/' + arrangementId
    And headers headers
    And request updatePayload
    When method PATCH
    Then status 401
    And match response.message == errorMessage