Feature: Update Identity
	Background:
		* def getHeader = call read('classpath:shared/get-gateway-headers.feature')
		* def headers = getHeader.headers
		* set headers.Ocp-Apim-Subscription-Key = ocpKeyTC
		* def wait = function(pause) { java.lang.Thread.sleep(pause) }
	Scenario: Update Identity Status
		* print "Get Customer Phone Number"
		* configure charset = null
		* def getTrustedToken = call read('classpath:shared/get-ciam-trusted-token.feature')
		* def accessToken = get getTrustedToken.accessToken
		* def l1Access = call read('classpath:shared/get-ciam-l1-token.feature') { username: '#(username)' }
		* def l1AccessToken = get l1Access.accessToken
		* def guid = get l1Access.guid
		* print "Update access code using lvl1"
		* def getHeader = call read('classpath:shared/get-gateway-headers.feature')
		* def headers = getHeader.headers
		* def accessPayload =
    """
    {
      "operations": [
        {
          "operation": "replace",
          "field": "access_code",
          "value": '#(accessCode)'
        }
      ]
    }
    """
		Given url baseUrl
		And path '/customerIdentity/v1.0/' + guid
		And headers headers
		And header Authorization = 'Bearer ' + l1AccessToken
		When request accessPayload
		And method PATCH
		Then status 200
		* print "Update Status"
		* def statusPayload =
    """
    {
      "operations": [
        {
          "operation": "replace",
          "field": "temenos_cif",
          "value": '#(customerId)'
        }
      ]
    }
    """
		Given url baseUrl
		And path '/customerIdentity/v1.0/' + guid
		And headers headers
		And header Ocp-Apim-Subscription-Key = ocpKeyTC
#	And header Authorization = 'Bearer ' + accessToken
		When request statusPayload
		And method PATCH
		Then status 200