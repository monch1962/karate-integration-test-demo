Feature:

  Background:
    * def getHeader = call read('classpath:shared/get-gateway-headers.feature')
    * def headers = getHeader.headers

  Scenario:

    * def createPayload =
	"""
    {
    	"name": "#(RandomUtils.randomText().substring(0,5))",
    	"category": "BPAY",
    	"billerCode": "#(BPAYCRN)",
    	"crn": "#(BPAYBillerCode)"
    }
	"""

    Given url baseUrl
    And path 'address-book/v1/payees'
    And headers headers
    And header Authorization = token
    When request createPayload
    And method POST
    Then status 200
    And def beneID = response.id
