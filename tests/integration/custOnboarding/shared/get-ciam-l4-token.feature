Feature:

  Scenario: Get Level 4 token
#	  Steps:
#  1. reserve_cif
#  2. Generate L1
#  3. update access code
#  4. create customer
#  5. update temenos_cif
#  5. Generate L2 using L1 from step 2
	  # Note: Step 1 to 5 to be done in the test feature file
#  6. Generate L3 using L2 from step 5 -initiate/Verify OTP
#  7. update SQA using L3
#  8. Get SQA using l2
#  9. Verify SQA using L2 to get L3
#  10. Initiate-verify otp using l3 to get L4

    * def getHeader = call read('classpath:shared/get-gateway-headers.feature')
    * def headers = getHeader.headers

    * print 'Get L3 using initiate/verify OTP'
    * url baseUrl
    * path '/customeridentity/v1.0/otp/trigger'
    * headers headers
    * header Authorization = 'Bearer ' + l2token
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
    * header Authorization = 'Bearer ' + l2token
    * request getTokenPayload
    * method POST
    * status 200
    * print "Getting level 3 tokens"
    * print "------------------------"
    * def l3token = get response.access_token

    * print 'Update SQA'

    * def requestBody =
    """
    {
     "answers": {
        "Which one is your Favourite app?": #(RandomUtils.randomText()),
        "What is your favourite food?": #(RandomUtils.randomText())
      }
     }
    """
    * def SQA = requestBody.answers

    Given url baseUrl
    And path 'customerIdentity/v1.0/' + guid + '/challenge'
    And headers headers
    And header Authorization = 'Bearer '+ l3token
    And header X-VMA-Query = 'username=' + username
    And request requestBody
    When method PUT
    Then status 204

    * print 'Get SQA'

    Given url baseUrl
    And path 'customerIdentity/v1.0/challenge'
    And headers headers
    And header Authorization = 'Bearer '+ l2token
    And header X-VMA-Query = 'username=' + guid
    When method GET
    Then status 200
    * def trackToken = response.track_token

    * print 'Verify SQA'

    * def requestBody =
    """
    {
     "answers": #(SQA),
     "track_token": #(trackToken)
    }
    """

    Given url baseUrl
    And path 'customerIdentity/v1.0/challenge/verify'
    And headers headers
    And header Authorization = 'Bearer '+ l2token
    And request requestBody
    When method POST
    Then status 200
    * def l3accessToken = response.access_token

    * print "Initiate step up OTP for L4"
    * url baseUrl
    * path '/customeridentity/v1.0/otp/trigger'
    * headers headers
    * header Authorization = 'Bearer '+ l3accessToken
    * request { "username": '#(guid)' }
    * method POST
    * status 200
    * def track_token = get response.track_token

    * print "Get Level 4 Token"
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
    * header Authorization = 'Bearer '+ l3accessToken
    * request getTokenPayload
    * method POST
    * status 200
    * print "Getting level 4 tokens"
    * print "------------------------"
    * def accessToken = get response.access_token
    * def refreshToken = get response.refresh_token
    * def guid = get response.user
