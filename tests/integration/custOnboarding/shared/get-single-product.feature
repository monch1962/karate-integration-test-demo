Feature:

  Background:
    * def getHeader = call read('classpath:shared/get-gateway-access-token.feature')
    * def headers = getHeader.headers

  Scenario: Get a single product with category
    * def parameters = {category: '#(category)', index: '#(index)'}
    * print parameters
    Given url baseUrl
    And path '/product-subscription/v1/products'
    And headers headers
    And header category = parameters.category
    When method GET
    Then status 200
    * def selectedProduct = response[parameters.index]


