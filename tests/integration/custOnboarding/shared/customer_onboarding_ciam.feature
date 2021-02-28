Feature:
#In progress----
  Scenario: Customer Onboarding in CIAM
	# Pre-requisite: Parameters to be passed - Username, access code, device ID and Temenos_cif

    * print "Initiate OTP and Verify OTP"
    * def l1Token =  call read('classpath:shared/get-ciam-l1-token.feature') {username: '#(username)'}
    * def lvl1accessToken = l1Token.accessToken
    * def guid = l1Token.guid

    * print "Update access code"
    * def getHeader = call read('classpath:shared/get-gateway-access-token.feature')
    * def headers = getHeader.headers
    * def accessPayload =
    """
    {
      "operations": [
        {
          "operation": "add",
          "field": "access_code",
          "value": '#(access_code)'
        }
      ]
    }
    """

    * url baseUrl
    * path '/customerIdentity/v1.0/' + guid
    * headers headers
    * header Authorization = 'Bearer ' + lvl1accessToken
    * request accessPayload
    * method PATCH
    * status 200

    * print "Get system token"
    * def systemTokenResponse =  call read('classpath:shared/get-ciam-trusted-token.feature')
    * def systemToken = systemTokenResponse.accessToken

    * print "Update temenos cif"
    * def cifPayload =
	  """
	  {
        "operations": [
                {
            "operation": "add",
            "field": "temenos_cif",
            "value": "#(temenos_cif)"
                 }
            ]
      }
	  """
    * url baseUrl
    * path '/customerIdentity/v1.0/' + guid
    * headers headers
    * header Authorization = 'Bearer ' + systemToken
    * request cifPayload
    * method PATCH
    * status 200

    * print "Get Lvl2 token from "credentials_type"="mobileAccessCode with lvl1 token for registering a device and logging in"

    * def getL2Response = call read('classpath:shared/get-ciam-l2-token-using-l1-token.feature') {username: '#(username)', "access_code":'#(access_code)', "device_id":'#(device_id)'}
    * def l2accessToken = get getL2Response.access_token


    * print "Get Identity"
    * url baseUrl
    * path '/customeridentity/v1.0/' + guid
    * headers headers
    * header Authorization = 'Bearer ' + l2access_token
    * method GET
    * status 200
    * print response
