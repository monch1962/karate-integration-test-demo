Feature:

	Background:
		* def getHeader = call read('classpath:shared/get-gateway-headers.feature')
		* def headers = getHeader.headers

	Scenario:

		* def addMoney = call read('classpath:shared/add-money.feature') {Amount: '10', AccountID: '#(sourceAccount1)'}
		* def sleep = function(millis){ java.lang.Thread.sleep(millis) }
		* eval sleep(10000)

		* print 'Create Internal transaction'
		* def paymentPayload =
	"""
	{
	  "source": {
		"accountNumber": "#(sourceAccount1)",
		"arrangementId": '#(arrangementId)',
		"accountBSB": "#(bsb)"
	  },
	  "destination": {
		"type": "INTERNAL",
		"accountNumber": '#(destAccount2)'
	  },
	  "amount": 1.01,
	  "description": '#(RandomUtils.randomText().substring(0,5))'
	}
	"""

		Given url baseUrl
		And path '/customer-payments/v1/initiate'
		And headers headers
		And header Authorization = accountl2Token
		When request paymentPayload
		And method POST
		Then status 200
		* def transactionId = response.transactionId
		And match response ==
		"""
		{
  			"transactionId": "#present",
  			"executionDate": "#present",
  			"paymentType": "INTERNAL"
		}
		"""