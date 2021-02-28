Feature:

  Scenario: Get Customer Profile Details

	* def getHeader = call read('classpath:shared/get-gateway-headers.feature')
	* def headers = getHeader.headers

	Given url baseUrl
	And path '/customer-profile/v1/customers'
	And headers headers
	And header Authorization = token
	When method GET
	Then status 200
	* def details = get response
	* def findFrollo = karate.jsonPath(details, "$.externalIds[?(@.systemId=='FROLLO')]")
	* def frolloId = findFrollo[0].customerId