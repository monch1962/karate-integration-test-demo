Feature:

  Background:
	* def getHeader = call read('classpath:shared/get-gateway-headers.feature')
	* def headers = getHeader.headers

  Scenario:

	* def createPayload =
	"""
	{
	  "customers":[
		{
		  "customerId": '#(customerId)',
		  "termsAndConditions":[
			{
			  "versionId": "1.1.0",
			  "dateOfApproval": "2020-01-14"
			}
		  ]
		}
	  ],
	  "productId": "VMA.TRANSAC.ACCOUNT",
	  "channel": "MOBILE",
	  "payIdList": [],
	  "sourceCode": "",
	  "promoCode": "",
	  "offerCode": ""
	}
	"""

	Given url baseUrl
	And path '/customer-accounts/v1/accounts'
	And headers headers
	And header Authorization = token
	When request createPayload
	And method POST
	Then status 200
	And match response == { "arrangementId": "#string" }
	And def arrangementId = get response.arrangementId

	* print "Get Customer Account"
	Given url baseUrl
	And path '/customer-accounts/v1/accounts'
	And headers headers
	And header Authorization = token
	When method GET
	Then status 200
	And def findAccount = karate.jsonPath(response, "$.accounts[?(@.arrangementId=='" + arrangementId + "')]")
	* def accountDetails = get findAccount[0]
	* def accountId = karate.jsonPath(response, "$..accountId")
	* def account = get accountId[0]
	* print accountId
	* print account
