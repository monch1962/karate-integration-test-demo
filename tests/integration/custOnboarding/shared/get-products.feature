Feature:

  Background:
    * def getHeader = call read('classpath:shared/get-gateway-headers.feature')
    * def headers = getHeader.headers

  Scenario: Get all products list

    Given url baseUrl
    And path '/product-subscription/v1/products'
    And headers headers
    When method GET
    Then status 200
    And def products = response

