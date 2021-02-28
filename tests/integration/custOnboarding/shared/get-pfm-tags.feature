Feature: Get Tags

  Background:
	* def getHeader = call read('classpath:shared/get-gateway-access-token.feature')
	* def headers = getHeader.headers

  Scenario:

	* def query =
	"""
	{
	  "period": '#(period)',
	  "fromDate": '#(fromDate)'
	}
	"""

	Given url baseUrl
	And path '/customers-pfm/v1/tag'
	And headers headers
	And header Authorization = 'Bearer ' + token
	When params query
	And method GET
	Then status 200
	And def tagList = response