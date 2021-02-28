@CUSTOMER_PROFILE_V1
Feature: Update Customer Profile

  Background:
    * def getHeader = call read('classpath:shared/get-gateway-access-token.feature')
    * def headers = getHeader.headers
    * def wait = function(pause) { java.lang.Thread.sleep(pause) }
    * configure readTimeout = 300000
    * configure connectTimeout = 300000

  @GatewayAPI @A15.2 @NOVOCUP-639.1 @TST @Smoke @SIT
  Scenario: Verify Update Customer Profile - Update customer addresses

    * json addresses = TestDataUtils.generateAddressForCustomer()

    * print "Update Customer details"
    * configure charset = null
    * def updatePayload =
    """
    {
      "addresses": '#(addresses)'
    }
    """

    Given url baseUrl
    And path '/customer-profile/v1/customers'
    And headers headers
    When request updatePayload
    And method PATCH
    Then status 200
    And match response == { "isDuplicate": false }

    * print "Verify updated addresses details"
    Given url baseUrl
    And path '/customer-profile/v1/customers'
    And headers headers
    When method GET
    Then status 200
    And match response contains updatePayload


  @GatewayAPI @A15.2 @NOVOCUP-759 @TST @SIT @ignore
  Scenario: Verify Update Customer Profile - Update ofiBSB

    * def customerId = get getHeader.customerId
    * def token = get getHeader.l3_token
    * def customerAccount = call read('classpath:shared/create-new-customer-account.feature') { customerId: '#(customerId)', token: '#(token)' }
    * def account = customerAccount.accountDetails
    * print account

    * print "Update Customer details"
    * configure charset = null
    * def updatePayload =
    """
    {
      "ofiBsb": '#(account.bsbNumber)',
      "ofiAccountNumber": '#(account.accountNumber)',
      "consent": '#(RandomUtils.randomText())'
    }
    """

    Given url baseUrl
    And path '/customer-profile/v1/customers'
    And headers headers
    When request updatePayload
    And method PATCH
    Then status 200
    And match response == { "isDuplicate": false }

# Pending confirmation for ofi would return in GET Profile
#    * print "Verify updated addresses details"
#    Given url baseUrl
#    And path '/customer-profile/v1/customers'
#    And headers headers
#    And header Authorization = 'Bearer ' + token
#    When method GET
#    Then status 200
#    And match response contains updatePayload

  @GatewayAPI @A15.2 @NOVOCUP-639.2 @TST @SIT
  Scenario: Verify Update Customer Profile - Update Preferred Name

    * def preferredName = RandomUtils.randomName()

    * print "Update Customer details"
    * configure charset = null
    * def updatePayload =
    """
    {
      "preferredName": '#(preferredName)'
    }
    """

    Given url baseUrl
    And path '/customer-profile/v1/customers'
    And headers headers
    When request updatePayload
    And method PATCH
    Then status 200
    And match response == { "isDuplicate": false }

    * print "Verify updated preferred name"
    Given url baseUrl
    And path '/customer-profile/v1/customers'
    And headers headers
    When method GET
    Then status 200
    And match response contains updatePayload

  @GatewayAPI @A15.2 @NOVOCUP-639.6 @TST @SIT
  Scenario: Verify Update Customer Profile - Update TFN

    * print "Update Customer details"
    * configure charset = null
    * def updatePayload =
    """
    {
      "taxFileNumber": '#(RandomUtils.randomNumber(10))',
      "tfnExemptionId": "333333333"
    }
    """

    Given url baseUrl
    And path '/customer-profile/v1/customers'
    And headers headers
    When request updatePayload
    And method PATCH
    Then status 200
    And match response == { "isDuplicate": false }

    * print "Verify updated TFN"
    Given url baseUrl
    And path '/customer-profile/v1/customers'
    And headers headers
    When method GET
    Then status 200
    And match response contains
    """
    {
      "tfnStatus": "PROVIDED",
      "tfnExemptionId": '#(updatePayload.tfnExemptionId)'
    }
    """

  @GatewayAPI @A15.2 @NOVOCUP-639.3 @TST @SIT
  Scenario: Verify Update Customer Profile - Update TINs

    * print "Update Customer details"
    * def updatePayload =
    """
    {
      "tins": [
        {
          "countryOfTaxResidence": "AI",
          "identificationNumber": "12345678914",
          "tinExemptionId": "000000001",
          "exemptionConfirmation": "NO"
        }
      ]
    }
    """

    Given url baseUrl
    And path '/customer-profile/v1/customers'
    And headers headers
    When request updatePayload
    And method PATCH
    Then status 200
    And match response == { "isDuplicate": false }

  @GatewayAPI @A15.2 @NOVOCUP-639.4 @TST @SIT
  Scenario: Verify Update Customer Profile - Update Phone and Email

    * print "Get existing Phone and Email"
    Given url baseUrl
    And path '/customer-profile/v1/customers'
    And headers headers
    When method GET
    Then status 200
    And def currentPhone = get response.mobileNumber
    And def currentEmail = get response.email

    * print "Update Customer details"
    * def updatePayload =
    """
    {
      "contactChannel": [
        {
          "updatedCountryCode": "61",
          "updatedLocalNumber": "",
          "updatedPhone": '#(RandomUtils.randomMobileNumber())',
          "updatedEmail": '#(RandomUtils.randomEmail())'
        }
      ]
    }
    """

    Given url baseUrl
    And path '/customer-profile/v1/customers'
    And headers headers
    When request updatePayload
    And method PATCH
    Then status 200
    And match response == { "isDuplicate": false }

    * print "Verify updated mobile and email"
    Given url baseUrl
    And path '/customer-profile/v1/customers'
    And headers headers
    When method GET
    Then status 200
    And match response contains
    """
    {
      "mobileNumber": '#(updatePayload.contactChannel[0].updatedPhone)',
      "email": '#(updatePayload.contactChannel[0].updatedEmail)'
    }
    """

  @GatewayAPI @A15.2 @NOVOCUP-667 @TST @SIT
  Scenario: Verify Update Customer Profile - Update Phone only

    * print "Get existing Phone and Email"
    Given url baseUrl
    And path '/customer-profile/v1/customers'
    And headers headers
    When method GET
    Then status 200
    And def currentPhone = get response.mobileNumber
    And def currentEmail = get response.email

    * print "Update Customer Phone"
    * def updatePayload =
    """
    {
      "contactChannel": [
        {
          "currentEmail": '#(currentEmail)',
          "updatedPhone": '#(RandomUtils.randomMobileNumber())'
        }
      ]
    }
    """

    Given url baseUrl
    And path '/customer-profile/v1/customers'
    And headers headers
    When request updatePayload
    And method PATCH
    Then status 200
    And match response == { "isDuplicate": false }

    * print "Verify updated mobile and email"
    Given url baseUrl
    And path '/customer-profile/v1/customers'
    And headers headers
    When method GET
    Then status 200
    And match response contains
    """
    {
      "mobileNumber": '#(updatePayload.contactChannel[0].updatedPhone)',
      "email": '#(currentEmail)'
    }
    """

  @GatewayAPI @A15.2 @NOVOCUP-667.2 @TST @SIT
  Scenario: Verify Update Customer Profile - Update Email only

    * print "Get existing Phone and Email"
    Given url baseUrl
    And path '/customer-profile/v1/customers'
    And headers headers
    When method GET
    Then status 200
    And def currentPhone = get response.mobileNumber
    And def currentEmail = get response.email

    * print "Update Customer Email"
    * def updatePayload =
    """
    {
      "contactChannel": [
        {
          "currentPhone": '#(currentPhone)',
          "updatedEmail": '#(RandomUtils.randomEmail())'
        }
      ]
    }
    """

    Given url baseUrl
    And path '/customer-profile/v1/customers'
    And headers headers
    When request updatePayload
    And method PATCH
    Then status 200
    And match response == { "isDuplicate": false }

    * print "Verify updated mobile and email"
    Given url baseUrl
    And path '/customer-profile/v1/customers'
    And headers headers
    When method GET
    Then status 200
    And match response contains
    """
    {
      "mobileNumber": '#(currentPhone)',
      "email": '#(updatePayload.contactChannel[0].updatedEmail)'
    }
    """

  @GatewayAPI @A15.2 @NOVOCUP-667.3 @TST @SIT
  Scenario: Verify Update Customer Profile - with current details

    * print "Get existing Phone and Email"
    Given url baseUrl
    And path '/customer-profile/v1/customers'
    And headers headers
    When method GET
    Then status 200
    And def currentPhone = get response.mobileNumber
    And def currentEmail = get response.email

    * print "Update Customer Email"
    * def updatePayload =
    """
    {
      "contactChannel": [
        {
          "updatedPhone": '#(currentPhone)',
          "updatedEmail": '#(currentEmail)'
        }
      ]
    }
    """

    Given url baseUrl
    And path '/customer-profile/v1/customers'
    And headers headers
    When request updatePayload
    And method PATCH
    Then status 200
    And match response == { "isDuplicate": true }

    * print "Verify updated mobile and email"
    Given url baseUrl
    And path '/customer-profile/v1/customers'
    And headers headers
    When method GET
    Then status 200
    And match response contains
    """
    {
      "mobileNumber": '#(currentPhone)',
      "email": '#(currentEmail)'
    }
    """

  @GatewayAPI @A15.2 @NOVOCUP-639.5 @TST @SIT
  Scenario: Verify Update Customer Profile - Update with duplicated Phone and Email

    * print "Get Phone and Email from other existing Customer"

    Given url baseUrl
    And path '/customer-profile/v1/customers'
    And headers headers
    When method GET
    Then status 200
    And def existingPhone = get response.mobileNumber
    And def existingEmail = get response.email

    * print "Get Phone and Email from current Customer"
    * def createCP = call read('classpath:shared/get-gateway-access-token.feature')
    * def newHeaders = get createCP.headers

    Given url baseUrl
    And path '/customer-profile/v1/customers'
    And headers newHeaders
    When method GET
    Then status 200
    And def currentCustPhone = get response.mobileNumber
    And def currentCustEmail = get response.email

    * print "Update current Customer details"
    * configure charset = null
    * def updatePayload =
    """
    {
      "contactChannel": [
        {
          "updatedPhone": '#(existingPhone)',
          "updatedEmail": '#(existingEmail)'
        }
      ]
    }
    """

    Given url baseUrl
    And path '/customer-profile/v1/customers'
    And headers newHeaders
    When request updatePayload
    And method PATCH
    Then status 200
    And match response == { "isDuplicate": true }

    * print "Verify current Customer Phone and Email is not changed"
    Given url baseUrl
    And path '/customer-profile/v1/customers'
    And headers newHeaders
    When method GET
    Then status 200
    And match response.mobileNumber == currentCustPhone
    And match response.email == currentCustEmail

  @GatewayAPI @A15.2 @NOVOCUP-639.0 @TST @SIT
  Scenario: Verify Update Customer Profile - Update customer names

    * print "Update Customer details"

    * def updatePayload =
    """
    {
      "givenName": '#(RandomUtils.randomFirstName())',
      "familyName": '#(RandomUtils.randomLastName())',
      "middleName": '#(RandomUtils.randomFirstName())',
      "fullName": '#(RandomUtils.randomName())',
      "shortName": '#(RandomUtils.randomFirstName())'
    }
    """

    Given url baseUrl
    And path '/customer-profile/v1/customers'
    And headers headers
    When request updatePayload
    And method PATCH
    Then status 200
    And match response == { "isDuplicate": false }

    * print "Verify updated addresses details"
    Given url baseUrl
    And path '/customer-profile/v1/customers'
    And headers headers
    When method GET
    Then status 200
    And match response contains
    """
    {
      "firstName": '#(updatePayload.givenName)',
      "middleName": '#(updatePayload.middleName)',
      "lastName": '#(updatePayload.familyName)',
      "fullName": '#(updatePayload.fullName)'
    }
    """