Feature:

  Scenario: Get Level 1 token

	* def getHeader = call read('classpath:shared/get-gateway-headers.feature')
	* def headers = getHeader.headers

	* print "Initiate OTP"
	* url baseUrl
	* path '/customeridentity/v1.0/otp/trigger'
	* headers headers
	* request { "username": #(username) }
	* method POST
	* status 200
	* def track_token = get response.track_token

	* print "Verify OTP"
	* def verifyOtpPayload =
    """
    {
      "otp": "111111",
      "track_token": '#(track_token)',
      "username": '#(username)'
    }
    """

	* url baseUrl
	* path '/customerIdentity/v1.0/otp/verify'
	* headers headers
	* request verifyOtpPayload
	* method POST
	* status 200
	* def accessToken = get response.access_token
	* def refreshToken = get response.refresh_token
	* def guid = get response.user