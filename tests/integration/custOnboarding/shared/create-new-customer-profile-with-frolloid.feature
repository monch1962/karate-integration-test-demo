Feature:

  Scenario: Create new customer profile via Service API

    * def getHeader = call read('classpath:shared/get-services-access-token.feature')
    * def headers = getHeader.headers

    * print "Reserve Customer CIF"
    * def cifPayload =
    """
    {
      "phone": '#(username)',
      "email": '#(RandomUtils.randomEmail())',
      "applicationId": "c2f3rvt37233gr3b6y65yb4569tcnu349g"
    }
    """
    Given url serviceCustomerUrl
    And path '/customer-profile/v1/customers/reserve-customer-id'
    And headers headers
    When request cifPayload
    And method POST
    Then status 200
    And def cif = get response.cif

    * print "Create New Customer Profile"
    * json addresses = TestDataUtils.generateAddressForCustomer()
    * def createPayload =
    """
    {
      "contactChannel": [
        {
          "currentPhone": '#(username)',
          "currentEmail": '#(RandomUtils.randomEmail())'
        }
      ],
      "addresses": '#(addresses)',
      "legalDocs": [
        {
          "legalId": "ABC112241"
        }
      ],
      "tins": [
        {
          "identificationNumber": "12345678914",
          "countryOfTaxResidence": "RU",
          "residenceDate": "20060115"
        }
      ],
      "externalIds": [
        {
          "systemId": "PAYID",
          "customerId": '#(RandomUtils.randomNumber(9))'
        }
      ],
      "termsAndConditions": [
        {
          "versionId": "VERSION 1.2",
          "dateOfApproval": "20191206"
        }
      ],
      "preferredName": '#(RandomUtils.randomName())',
      "givenName": '#(RandomUtils.randomFirstName())',
      "familyName": '#(RandomUtils.randomLastName())',
      "middleName": '#(RandomUtils.randomName())',
      "fullName": "string",
      "gender": "F",
      "shortName": "string",
      "dateOfBirth": "2000-03-31",
      "customerResidency": "AU",
      "customerCitizenship": "AU",
      "occupationId": "string",
      "occupation": "string",
      "taxFileNumber": "string",
      "tfnExemptionId": "333333333",
      "tfnExemptionCodeDesc": "string",
      "tfnStatus": "PROVIDED",
      "countryOfResidenceOfTaxPurpose": "AU"
    }
    """

    Given url serviceCustomerUrl
    And path '/customer-profile/v1/customers/' + cif
    And headers headers
    When request createPayload
    And method PUT
    Then status 200
