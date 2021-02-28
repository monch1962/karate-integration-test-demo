Feature:

  Background:
	* def getHeader = call read('classpath:shared/get-gateway-headers.feature')
	* def headers = getHeader.headers

  Scenario:

	Given url baseUrl
	And path '/cards/v1/cards'
	And headers headers
	And header Authorization = "Bearer " + token
	When method GET
	Then status 200
	* def cards = get response.debitCardDetails