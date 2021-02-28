@CUSTOMER_PROFILE_V1
Feature: Get Customer Profile

  Background:
    * def getHeader = call read('classpath:shared/get-gateway-access-token.feature')
    * def headers = getHeader.headers

  @GatewayAPI @A15.1 @NOVOCUP-640 @NOVOCUP-640.1 @TST @Smoke @SIT
  Scenario: Verify Get Customer Profile successfully

    * def expectedResponse =
    """
    {
      "customerId": '#(getHeader.customerId)',
      "mnemonic": "##string",
      "firstName": "##string",
      "middleName": "##string",
      "lastName": "##string",
      "preferredName": "##string",
      "fullName": "##string",
      "dateOfBirth": "##string",
      "mobileNumber": "##string",
      "email": "##string",
      "emailVerificationStatus": "##string",
      "tfnStatus": "##string",
      "customerStatus": "##string",
      "countryOfResidenceOfTaxPurpose": "##string",
      "tfnExemptionId": "##string",
      "tfnExemptionCodeDesc": "##string",
      "language": "##string",
      "externalIds": #[],
      "tins": #[],
      "addresses": [
        {
          "addressType": "##string",
          "buildingName": "##string",
          "subdwelling": "##string",
          "streetNumber": "##string",
          "streetName": "##string",
          "streetType": "##string",
          "suburb": "##string",
          "state": "##string",
          "postcode": "##string",
          "country": "##string"
        },
        {
          "addressType": "##string",
          "buildingName": "##string",
          "subdwelling": "##string",
          "streetNumber": "##string",
          "streetName": "##string",
          "streetType": "##string",
          "suburb": "##string",
          "state": "##string",
          "postcode": "##string",
          "country": "##string"
        }
      ]
    }
    """

    Given url baseUrl
    And path '/customer-profile/v1/customers'
    And headers headers
    When method GET
    Then status 200
    And match response contains expectedResponse

  @GatewayAPI @A15.1 @NOVOCUP-640 @NOVOCUP-640.2 @TST @SIT
  Scenario: Verify Get Customer Profile with invalid token
    * def token = 'invalidToken'

    Given url baseUrl
    And path '/customer-profile/v1/customers'
    And headers headers
    And header Authorization = 'Bearer ' + token
    When method GET
    Then status 403
    And match response ==
    """
    {
      "code": "#string",
      "message": "#string",
      "supportReferenceId": "#string",
      "timestamp": "#string"
    }
    """

  @GatewayAPI @A15.1 @NOVOCUP-640 @NOVOCUP-640.3 @TST @SIT
  Scenario Outline: Verify get customer profile unsuccessfully with invalid header - no <selectedHeader>

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
    And path '/customer-profile/v1/customers'
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