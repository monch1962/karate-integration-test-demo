Feature:

  Scenario: Get Level 2 token

	* def getHeader = call read('classpath:shared/get-gateway-headers.feature')
	* def headers = getHeader.headers
	* def l1Token =  call read('classpath:shared/get-ciam-l1-token.feature') {username: '#(username)'}
	* def lvl1accessToken = l1Token.accessToken
	* def wait = function(pause) { java.lang.Thread.sleep(pause) }
#	* eval wait(10000)

	* print "Get Lvl2 token from mobileAccessCode with lvl1 token for registering a device and logging in"
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
    * header Authorization = 'Bearer ' + lvl1accessToken
	* request lvl2RequestBody
	* method POST
	* status 200
	 * print "Getting level 2 tokens"
	* print "-------------------------"
	* def accessToken = get response.access_token
	* def refreshToken = get response.refresh_token
	* def guid = get response.user

