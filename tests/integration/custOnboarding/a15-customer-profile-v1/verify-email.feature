@CUSTOMER_PROFILE_V1
Feature: Get Customer Profile

  Background:
	* def getHeader = call read('classpath:shared/get-gateway-access-token.feature')
	* def headers = getHeader.headers

  @GatewayAPI @A15.4 @A2.22 @NOVOCUP-713.1 @TST @Smoke @SIT
  Scenario: Verify Customer Profile email verification

	* print "Generate short token"

	* def guid = get getHeader.guid
	* def type = "email"

	Given url baseUrl
	And path '/customerIdentity/v1.0/' + guid + '/generate-short-code/' + type
	And headers headers
	When method GET
	Then status 200
	And def shortToken = get response.token

	* print "Validate Email"

	* def getHeader = call read('classpath:shared/get-gateway-headers.feature')
	* def headers = getHeader.headers
	* configure followRedirects = false
	Given url baseUrl
	And path '/verify-email/v1/' + guid
	And headers headers
	When param token = shortToken
	And method GET
	Then status 301
	And match responseHeaders contains
	"""
	{
	  "Location": [https://virginmoney.com.au/virgin-money-app/webview/email-confirmation]
	}
	"""

	@GatewayAPI @A15.4 @NOVOCUP-713.2 @TST @SIT
  Scenario: Verify Customer Profile email with invalid token

	* print "Generate short token"
	* def guid1 = get getHeader.guid

	* def getHeader = call read('classpath:shared/get-gateway-access-token.feature')
	* def headers = getHeader.headers
	* def guid2 = get getHeader.guid
	* def type = "email"

	Given url baseUrl
	And path '/customerIdentity/v1.0/' + guid2 + '/generate-short-code/' + type
	And headers headers
	When method GET
	Then status 200
	And def shortToken = get response.token


	* print "Validate Email"

	* def getHeader = call read('classpath:shared/get-gateway-headers.feature')
	* def headers = getHeader.headers
	* configure followRedirects = false
	Given url baseUrl
	And path '/verify-email/v1/' + guid1
	And headers headers
	When param token = shortToken
	And method GET
	Then status 301
	And match responseHeaders contains
	"""
	{
	  "Location": [https://virginmoney.com.au/virgin-money-app/webview/email-confirmation-error]
	}
	"""