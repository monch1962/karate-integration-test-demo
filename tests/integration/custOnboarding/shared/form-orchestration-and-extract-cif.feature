
Feature: Form Orchestration and extract cif
	#Note: This can be used in SIT only due to TJM environment constraints

	Background:
		* def getHeader = call read('classpath:shared/get-gateway-headers.feature')
		* def headers = getHeader.headers
		* def formOrchResponse = call read('classpath:features/a4-form-orchestration-v1/form-orchestration.feature')
		* def guid = get formOrchResponse.guid
		* def sleep = function(millis){ java.lang.Thread.sleep(millis) }
		* eval sleep(10000)

	Scenario: Form Orchestration and extract cif

		* print 'Extract Cif through Get identity*******************'

		* set headers.Ocp-Apim-Subscription-Key = ocpKeyTC

		Given url baseUrl
		And path 'customerIdentity/v1.0/' + guid
		And headers headers
		When method GET
		Then status 200
		* def cif = response.temenos_cif
		* def mobileNumber = response.username

		* print "The temenos-cif is: " + cif
		* print "The mobile number is: " + mobileNumber







