Feature:

  Scenario: Duplicate Check

    * def getHeader = call read('classpath:shared/get-services-access-token.feature')
    * def headers = getHeader.headers

    * def phone = RandomUtils.randomMobileNumber()
    * def email = RandomUtils.randomEmail()

    Given url serviceCustomerUrl
    And path '/customer-profile/v1/customers/duplicate-check'
    And headers headers
    And header phone = phone
    And header email = email
    When method GET
    Then status 200
    And def status = get responseStatus
    And def isDuplicate = get response.isDuplicate
    * print isDuplicate