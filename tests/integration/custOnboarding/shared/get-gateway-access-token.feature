Feature:

  Scenario: Generate access token

    * def createCP = call read('classpath:shared/create-new-customer-profile.feature')
    * def customerId = createCP.cif
    * def mobileNumber = createCP.cifPayload.phone
#    * def customerId = "116166"
#    * def mobileNumber = "61440223097"
    * def username = mobileNumber.substring(mobileNumber.lastIndexOf('+') + 1)
    * def accessCode = createCP.accessCode
#    * def accessCode = RandomUtils.randomNumber(6)
#    * def ui = call read('classpath:shared/update-identity-in-ciam.feature') { customerId: '#(customerId)', username: '#(username)', accessCode: '#(accessCode)' }
    * def getToken = call read('classpath:shared/get-ciam-l3-token.feature') { username: '#(username)', access_code: '#(accessCode)', device_id: '#(username)' }
    * def l3_token = 'Bearer ' + getToken.accessToken
    * def l2_token = 'Bearer ' + getToken.lvl2accessToken
    * def guid = get getToken.guid

    * def headers =
    """
    {
      "Request-Id": '#(RandomUtils.randomUUID())',
      "Timestamp": '#(RandomUtils.getCurrentDate())',
      "Sending-System-Version": 'v1.0',
      "Sending-System-Id": "REF001",
      "Initiating-System-Id": "MOBILE",
      "Initiating-System-Version": "v1.0",
      "Accept": '#(contentType)',
      "Content-Type": '#(contentType)',
      "Ocp-Apim-Subscription-Key": '#(ocpKey)',
      "Trusteer-Session-Id": '#(RandomUtils.randomUUID())',
      "Interaction-Id": '#(RandomUtils.randomUUID())',
      "Authorization": '#(l3_token)',
      "Ocp-Apim-Trace": "True"
    }
    """