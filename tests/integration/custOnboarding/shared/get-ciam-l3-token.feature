Feature:

  Scenario: Get Level 3 token

	* def getHeader = call read('classpath:shared/get-gateway-headers.feature')
	* def headers = getHeader.headers
	* def lvl2TokenResponse = call read('classpath:shared/get-ciam-l2-token-using-l1-token.feature') {username: '#(username)', "access_code":'#(access_code)', "device_id":'#(device_id)'}
	* def lvl2accessToken = get lvl2TokenResponse.accessToken
	* def guid = get lvl2TokenResponse.guid

	* print "Initiate step up OTP"
	* url baseUrl
	* path '/customeridentity/v1.0/otp/trigger'
	* headers headers
	* header Authorization = 'Bearer ' + lvl2accessToken
	* request { "username": '#(guid)' }
	* method POST
	* status 200
	* def track_token = get response.track_token

	* print "Get Level 3 Token"
	* def getTokenPayload =
    """
    {
      "otp": "111111",
      "track_token": '#(track_token)',
      "username": '#(guid)'
    }
    """

	* url baseUrl
	* path '/customerIdentity/v1.0/otp/verify'
	* headers headers
	* header Authorization = 'Bearer ' + lvl2accessToken
	* request getTokenPayload
	* method POST
	* status 200
	* print "Getting level 3 tokens"
	* print "------------------------"
	* def accessToken = get response.access_token
	* def refreshToken = get response.refresh_token
	* def guid = get response.user
