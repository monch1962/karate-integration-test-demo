@CUSTOMER_PROFILE_V1
Feature: Get Customer Profile

  Background:
	* def getHeader = call read('classpath:shared/get-gateway-access-token.feature')
	* def headers = getHeader.headers

  @GatewayAPI @A15.3 @NOVOCUP-680 @TST @Smoke @SIT
  Scenario: Verify Trigger Customer Profile email verification

	* def guid = get getHeader.guid
	* def type = "email"

	* print "Trigger Email Verification"
	Given url baseUrl
	And path '/customer-profile/v1/communication-event/' + guid
	And headers headers
	When request {}
	When method POST
	Then status 200
	And match response == {}

  @GatewayAPI @A15.1 @NOVOCUP-680 @TST @SIT
  Scenario Outline: Verify trigger customer email verification unsuccessfully with invalid header - no <selectedHeader>

	* def guid = get getHeader.guid
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
	And path '/customer-profile/v1/communication-event/' + guid
	And headers headers
	When request {}
	When method POST
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