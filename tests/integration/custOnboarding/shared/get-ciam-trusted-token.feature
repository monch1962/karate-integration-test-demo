Feature:

  Scenario: Get Trusted Client token

	* def getHeader = call read('classpath:shared/get-gateway-headers.feature')
	* def headers = getHeader.headers

	* def requestPayload =
	"""
	{
	  "client_id": '#(VMAAPIGateway)',
	  "client_secret":'#(clientSecretTrustedClient)',
	  "credentials_type": '#(trustedClient)'
	}
	"""

	* url baseUrl
	* path '/customeridentity/v1.0/token'
	* headers headers
	* request requestPayload
	* method POST
	* status 200
	* def accessToken = get response.access_token