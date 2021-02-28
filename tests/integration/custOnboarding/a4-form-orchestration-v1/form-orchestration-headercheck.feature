@FORM_ORCHESTRATION
Feature: Header Validation

  Background:
    * def getHeader = call read('classpath:shared/get-gateway-headers.feature')
    * def headers = getHeader.headers

  @GatewayAPI @A4.1 @4.2 @A4.3 @NOVOCO-1121 @SIT
  Scenario Outline: Header validation

    * print 'Header Validation'

    Given url baseUrl
    And path 'forms-orchestration/v1/form/vma-onboard-mobile'
    And header Request-Id = <Request-Id>
    And header Timestamp =  <Timestamp>
    And header Sending-System-Version =  <Sending-System-Version>
    And header Sending-System-Id = <Sending-System-Id>
    And header Initiating-System-Id = <Initiating-System-Id>
    And header Initiating-System-Version = <Initiating-System-Version>
    And header Accept = <Accept>
    And header Content-Type = <Content-Type>
    And header Ocp-Apim-Subscription-Key = <Ocp-Apim-Subscription-Key>
    When method GET
    Then status <status_Code>
    And match response == <expectedResponse>

    Examples:
      | Request-Id               | Timestamp                    | Initiating-System-Id | Initiating-System-Version | Sending-System-Version | Sending-System-Id | Ocp-Apim-Subscription-Key | Accept      | Content-Type | expectedResponse                                                                                                                             | status_Code |
      | RandomUtils.randomUUID() | RandomUtils.getCurrentDate() | 'REF001'             | ' '                       | 'v1.0'                 | 'REF001'          | ocpKey                    | contentType | contentType  | {"code": "SPVAL0004","message": "Header Validation Failed","supportReferenceId": "#string","timestamp": "#string"}                           | 400         |
      | ' '                      | RandomUtils.getCurrentDate() | 'REF001'             | 'v1.0'                    | 'v1.0'                 | 'REF001'          | ocpKey                    | contentType | contentType  | {"code": "SPVAL0004","message": "Header Validation Failed","supportReferenceId": "#string","timestamp": "#string"}                           | 400         |
      | RandomUtils.randomUUID() | ' '                          | 'REF001'             | 'v1.0'                    | 'v1.0'                 | 'REF001'          | ocpKey                    | contentType | contentType  | {"code": "SPVAL0004","message": "Header Validation Failed","supportReferenceId": "#string","timestamp": "#string"}                           | 400         |
      | RandomUtils.randomUUID() | RandomUtils.getCurrentDate() | ' '                  | 'v1.0'                    | 'v1.0'                 | 'REF001'          | ocpKey                    | contentType | contentType  | {"code": "SPVAL0004","message": "Header Validation Failed","supportReferenceId": "#string","timestamp": "#string"}                           | 400         |
      | RandomUtils.randomUUID() | RandomUtils.getCurrentDate() | 'REF001'             | 'v1.0'                    | ' '                    | 'REF001'          | ocpKey                    | contentType | contentType  | {"code": "SPVAL0004","message": "Header Validation Failed","supportReferenceId": "#string","timestamp": "#string"}                           | 400         |
      | RandomUtils.randomUUID() | RandomUtils.getCurrentDate() | 'REF001'             | 'v1.0'                    | 'v1.0'                 | ' '               | ocpKey                    | contentType | contentType  | {"code": "SPVAL0004","message": "Header Validation Failed","supportReferenceId": "#string","timestamp": "#string"}                           | 400         |
      | RandomUtils.randomUUID() | RandomUtils.getCurrentDate() | 'REF001'             | 'v1.0'                    | 'v1.0'                 | 'REF001'          | ' '                       | contentType | contentType  | {"statusCode": 401,"message": "Access denied due to invalid subscription key. Make sure to provide a valid key for an active subscription."} | 401         |


