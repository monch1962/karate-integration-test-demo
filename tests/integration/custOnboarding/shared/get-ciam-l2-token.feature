Feature:

  Scenario: Get Level 2 token

	* def getHeader = call read('classpath:shared/get-gateway-headers.feature')
	* def headers = getHeader.headers

	* print "Get Lvl2 token from "credentials_type"="mobileAccessCode""
	* def lvl2RequestBody =
	  """
	  {
      "client_id": '#(VMAMobileApp)',
      "client_secret":'#(clientSecretMAC)',
      "username":'#(username)',
      "access_code":'#(access_code)',
      "credentials_type": '#(mobileAccessCode)',
      "device_id":'#(device_id)',
      "device_name":"onboarding",
      "device_alias":"onboarding",
      "device_platform":"onboarding"
    }
	  """

	  
	* url baseUrl
	* path '/customeridentity/v1.0/token'
	* headers headers
	* request lvl2RequestBody
	* method POST
	* status 200
	* print "Getting level 2 tokens"
	* print "-------------------------"
	* print response
	* def accessToken = get response.access_token
	* def refreshToken = get response.refresh_token
	* def guid = get response.user

