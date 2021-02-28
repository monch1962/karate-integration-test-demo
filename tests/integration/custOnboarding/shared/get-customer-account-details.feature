Feature:

  Background:

	* def getHeader = call read('classpath:shared/get-gateway-headers.feature')
	* def headers = getHeader.headers
	* configure readTimeout = 100000

	Scenario:

	  Given url baseUrl
	  And path '/customer-accounts/v1/account-details'
	  And headers headers
	  And header Authorization = 'Bearer ' + token
	  When method GET
	  Then status 200
	  * def account = get response