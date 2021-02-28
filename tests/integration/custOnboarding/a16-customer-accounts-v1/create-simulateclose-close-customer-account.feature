@A16_CUSTOMER_ACCOUNTS_V1
Feature: Create, Simulate-close and close Customer Accounts

	Background:
		* def getHeader = call read('classpath:shared/get-gateway-access-token.feature')
		* def headers = getHeader.headers
		* def l2token = getHeader.l2_token
		* def customerId = getHeader.customerId
		* def wait = function(pause) { java.lang.Thread.sleep(pause) }
		* configure readTimeout = 60000
		* def simulateAccountCloseResponse =
	"""
	   {
       	"productId": "#present",
  		"arrangementId": "#(arrangementId)",
  		"accountNumber": "#present",
  		"accountType": "#present",
  		"accountBSB": "#present",
  		"accountName": "#present",
  		"accountBothToSign": #boolean,
  		"accountOtherSavingsAccount": #boolean,
  		"hasOtherSavingsAccount": #boolean,
  		"isLastAccount": #boolean,
  		"accountLastTransactionAccount": #boolean,
 	 	"accountPendingTransactions": #boolean,
  		"accountOutstandingBalanceFinalAmount": #number,
  		"accountOverdrawn": #boolean,
  		"accountAvailableBalance": #number,
  		"accountJointAccount": #boolean,
  		"accountPendingTransaction": #boolean,
  		"accountOutstandingBalance": #boolean,
  		"accountOutstandingInterest": #number,
  		"accountOutstandingCharge": #number,
  		"accountScheduledPayment": #boolean
		}
	"""
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
	  "productId": "VMA.BONUS.SAVER",
	  "channel": "MOBILE",
	  "payIdList": [],
	  "sourceCode": "",
	  "promoCode": "",
	  "offerCode": ""
	}
	"""


	@GatewayAPI @A16.9 @A16.8 @A16.4 @TST @SIT
	Scenario: Verify Create , simulate close and close Customer Account
#Test Data - Customer in T24 and CIAM with account created and no money in the account

		* print "Create Customer Account"
		Given url baseUrl
		And path '/customer-accounts/v1/accounts'
		And headers headers
		When request createPayload
		And method POST
		Then status 200
		And match response == { "arrangementId": "#string" }
		* def arrangementId = response.arrangementId

		* print "Get Customer Account"
		Given url baseUrl
		And path '/customer-accounts/v1/accounts'
		And headers headers
		When method GET
		Then status 200
		And match response.accounts[0].accountHolders[0].partyId == customerId
		* def customerName = response.accounts[0].accountHolders[0].givenName + " " + response.accounts[0].accountHolders[0].familyName

		* print "Simulate Close Account"
		Given url baseUrl
		And path '/customer-accounts/v1/account-close-simulate/'+ arrangementId
		And headers headers
		And header Authorization = l2token
		And request {}
		When method POST
		Then status 200
		And match response == simulateAccountCloseResponse
		* def accountNumber = response.accountNumber
		* def accountBSB = response.accountBSB

		* print "Close Account for "accountOutstandingBalanceFinalAmount": 0.0"
		* def closeAccountrequestBody =
	  """
	   {
  		"arrangementId": #(arrangementId),
  		"customerName": #(customerName),
  		"isPayOffRequired": false,
  		"payOffAccount": {
    	"type": "INTERNAL",
    	"amount": 0,
    	"destination": {
      	"accountNumber": #(accountNumber),
      	"accountBSB": #(accountBSB),
      	"customerName": #(customerName)
    	}
  		},
  		"closureReason": "Close Account"
		}
	  """
		Given url baseUrl
		And path '/customer-accounts/v1/account-close'
		And headers headers
		And header Authorization = l2token
		And request closeAccountrequestBody
		When method POST
		Then status 200

	@GatewayAPI @A16.9 @A16.8 @A16.4.2 @TST @SIT
	Scenario: Verify Create , simulate close and close Customer Account with outstanding balance
#Test Data - Customer in T24 and CIAM with account created and money in the account

		* print "Create Customer Account"
		Given url baseUrl
		And path '/customer-accounts/v1/accounts'
		And headers headers
		When request createPayload
		And method POST
		Then status 200
		And match response == { "arrangementId": "#string" }
		* def arrangementId = response.arrangementId

		* print "Get Customer Account"
		Given url baseUrl
		And path '/customer-accounts/v1/accounts'
		And headers headers
		When method GET
		Then status 200
		And match response.accounts[0].accountHolders[0].partyId == customerId
		* def customerName = response.accounts[0].accountHolders[0].givenName + " " + response.accounts[0].accountHolders[0].familyName
		* def AccountID = response.accounts[0].accountId

		* print "Add money"
		* def addMoney = call read('classpath:shared/add-money.feature') {Amount: '10', AccountID: '#(AccountID)'}
		* def sleep = function(millis){ java.lang.Thread.sleep(millis) }
		* eval sleep(10000)

		* print "Simulate Close Account"
		Given url baseUrl
		And path '/customer-accounts/v1/account-close-simulate/'+ arrangementId
		And headers headers
		And header Authorization = l2token
		And request {}
		When method POST
		Then status 200
		And match response == simulateAccountCloseResponse
		* def accountNumber = response.accountNumber
		* def accountBSB = response.accountBSB

		* print "Close Account for "accountOutstandingBalanceFinalAmount"> 0.0"
		* def closeAccountrequestBody =
	  """
	   {
  		"arrangementId": #(arrangementId),
  		"customerName": #(customerName),
  		"isPayOffRequired": false,
  		"payOffAccount": {
    	"type": "INTERNAL",
    	"amount": 0,
    	"destination": {
      	"accountNumber": #(accountNumber),
      	"accountBSB": #(accountBSB),
      	"customerName": #(customerName)
    	}
  		},
  		"closureReason": "Close Account"
		}
	  """
		Given url baseUrl
		And path '/customer-accounts/v1/account-close'
		And headers headers
		And header Authorization = l2token
		And request closeAccountrequestBody
		When method POST
		Then status 400
		And match response ==
		"""
		{
  			"code": "#present",
  			"message": "Error occurred while attempting to communicate with Temenos system. Check if the input parameters are valid",
  			"supportReferenceId": "#present",
  			"timestamp": "#present"
		}
		"""

	@GatewayAPI @A16.9 @A16.8 @A16.4.3 @TST @Smoke @SIT
	Scenario: Verify Create , simulate close and close Customer Account for Joint Account
#Test Data - Customer in T24 and CIAM with Joint account created and no money in the account
		* def createCP = call read('classpath:shared/create-new-customer-profile.feature')
		* def customerId2 = get createCP.cif

		* def createJointAccount = call read('classpath:shared/create-new-joint-account.feature') {token: '#(l2token)', customerId1: '#(customerId)', customerId2: '#(customerId2)'}
		* def arrangementId = get createJointAccount.arrangementId

		* print "Get Customer Account"
		Given url baseUrl
		And path '/customer-accounts/v1/accounts'
		And headers headers
		When method GET
		Then status 200
		And match response.accounts[0].accountHolders[0].partyId == customerId
		* def customerName = response.accounts[0].accountHolders[0].givenName + " " + response.accounts[0].accountHolders[0].familyName
		* def AccountID = response.accounts[0].accountId

		* print "Simulate Close Account"
		Given url baseUrl
		And path '/customer-accounts/v1/account-close-simulate/'+ arrangementId
		And headers headers
		And header Authorization = l2token
		And request {}
		When method POST
		Then status 200
		And match response == simulateAccountCloseResponse
		* def accountNumber = response.accountNumber
		* def accountBSB = response.accountBSB

		* print "Close Account for Joint Account"
		* def closeAccountrequestBody =
	  """
	   {
  		"arrangementId": #(arrangementId),
  		"customerName": #(customerName),
  		"isPayOffRequired": false,
  		"payOffAccount": {
    	"type": "INTERNAL",
    	"amount": 0,
    	"destination": {
      	"accountNumber": #(accountNumber),
      	"accountBSB": #(accountBSB),
      	"customerName": #(customerName)
    	}
  		},
  		"closureReason": "Close Account"
		}
	  """
		Given url baseUrl
		And path '/customer-accounts/v1/account-close'
		And headers headers
		And header Authorization = l2token
		And request closeAccountrequestBody
		When method POST
		Then status 200

	@GatewayAPI @A16.9 @A16.8 @A16.4.4 @TST @SIT
	Scenario: Verify Create , simulate close and close Customer Account for Account with transactions
#Test Data - Customer in T24 and CIAM with 2 accounts created and transaction done

		* print "Create Accounts"
		* def createAccount = call read('classpath:shared/create-new-customer-account.feature') {token: '#(l2token)', customerId: '#(customerId)'}
		* def createSavingsAccount = call read('classpath:shared/create-new-customer-account-savings.feature') {token: '#(l2token)', customerId: '#(customerId)'}

		* print "Get Customer Account"
		Given url baseUrl
		And path '/customer-accounts/v1/accounts'
		And headers headers
		When method GET
		Then status 200
		And match response.accounts[0].accountHolders[0].partyId == customerId
		* def customerName = response.accounts[0].accountHolders[0].givenName + " " + response.accounts[0].accountHolders[0].familyName
		* def sourceAccount1 = response.accounts[0].accountId
		* def destAccount2 = response.accounts[1].accountId
		* def bsb = response.accounts[0].bsbNumber
		* def arrangementId = response.accounts[0].arrangementId

		* print "Create Transaction"
		* def createTransaction = call read('classpath:shared/create-internal-transaction.feature') {accountl2Token: '#(l2token)', customerId: '#(customerId)', 'AccountID': '#(sourceAccount1)', 'sourceAccount1': '#(sourceAccount1)', 'arrangementId': '#(arrangementId)', 'bsb': '#(bsb)', 'destAccount2':'#(destAccount2)'}
		* def sleep = function(millis){ java.lang.Thread.sleep(millis) }
		* eval sleep(10000)

		* print "Simulate Close Account"
		Given url baseUrl
		And path '/customer-accounts/v1/account-close-simulate/'+ arrangementId
		And headers headers
		And header Authorization = l2token
		And request {}
		When method POST
		Then status 200
		And match response == simulateAccountCloseResponse
		* def accountNumber = response.accountNumber
		* def accountBSB = response.accountBSB

		* print "Close Account for Accounts with transactions"
		* def closeAccountrequestBody =
	  """
	   {
  		"arrangementId": #(arrangementId),
  		"customerName": #(customerName),
  		"isPayOffRequired": false,
  		"payOffAccount": {
    	"type": "INTERNAL",
    	"amount": 0,
    	"destination": {
      	"accountNumber": #(accountNumber),
      	"accountBSB": #(accountBSB),
      	"customerName": #(customerName)
    	}
  		},
  		"closureReason": "Close Account"
		}
	  """
		Given url baseUrl
		And path '/customer-accounts/v1/account-close'
		And headers headers
		And header Authorization = l2token
		And request closeAccountrequestBody
		When method POST
		Then status 400
		And match response ==
		"""
		{
  			"code": "#present",
  			"message": "Error occurred while attempting to communicate with Temenos system. Check if the input parameters are valid",
  			"supportReferenceId": "#present",
  			"timestamp": "#present"
		}
		"""