Feature:
   Background:
	# Given url 'http://10.110.52.43:8443/VMAirisR19/api/v1.0.0/party/vma/individualCustomer/'
	* def baseurlvalue = T24baseUrl
	* print baseurlvalue

	Scenario: Get Customer Profile from T24


		Given url T24baseUrl
		And path customerId
		When method GET
		Then status 200
		* def details = get response