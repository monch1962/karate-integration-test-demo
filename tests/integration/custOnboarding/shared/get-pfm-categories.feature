Feature: Get Category

  Background:
	* def getHeader = call read('classpath:shared/get-gateway-access-token.feature')
	* def headers = getHeader.headers

  Scenario: Get budgets by Category for user's spending report

	* def query =
	"""
	{
	  "period": '#(period)',
	  "fromDate": '#(fromDate)'
	}
	"""

	Given url baseUrl
	And path '/customers-pfm/v1/category'
	And headers headers
	And header Authorization = 'Bearer ' + token
	When params query
	And method GET
	Then status 200
	And def categoryList = response