Feature:

  Scenario: Create new customer profile via Service API

    * def getHeader = call read('classpath:shared/get-services-access-token.feature')
    * def headers = getHeader.headers

    * def getPE = call read('classpath:shared/javascript/getValidPE.js')

    * print "Reserve Customer CIF"
    * def cifPayload =
    """
    {
      "phone": '#(getPE.phoneNumber)',
      "email": '#(getPE.email)',
      "applicationId": "c2f3rvt37233gr3b6y65yb4569tcnu349g"
    }
    """

    * def mobileNumber = cifPayload.phone
    * def username = mobileNumber.substring(mobileNumber.lastIndexOf('+') + 1)

    Given url serviceCustomerUrl
    And path '/customer-profile/v1/customers/reserve-customer-id'
    And headers headers
    When request cifPayload
    And method POST
    Then status 200
    And def cif = get response.cif
# wait introduced to avoid frequent failures
    * def sleep = function(millis){ java.lang.Thread.sleep(millis) }
    * eval sleep(10000)
    * def l1Access = call read('classpath:shared/get-ciam-l1-token.feature') { username: '#(username)' }
    * def l1AccessToken = get l1Access.accessToken
    * def guid = get l1Access.guid
    * def accessCode = RandomUtils.randomNumber(6)

    * print "Update access code using lvl1"
    * def getHeader = call read('classpath:shared/get-gateway-headers.feature')
    * def headers = getHeader.headers
    * def givenName = RandomUtils.randomFirstName()
    * def familyName = RandomUtils.randomLastName()
    * def middleName = RandomUtils.randomFirstName()
    * def fullName = givenName  +" "+ middleName + " " + familyName
    * def preferredName = fullName
    * print fullName
    # Get random Occupation id
    * def occupations = read('classpath:shared/Data/Occupation.json')
    * def listLength = occupations[Math.floor(Math.random()*occupations.length)];
    * print listLength
    * def occupationId = listLength.OccupationId
    * print occupationId
    * def occupation = listLength.Description
    * def taxfileNumber = RandomUtils.randomTaxFileNumber()
    * print taxfileNumber
    * print occupation
    * def accessPayload =
    """
    {
      "operations": [
        {
          "operation": "add",
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

    * print "Create New Customer Profile"
    * json addresses = TestDataUtils.generateAddressForCustomer()
    * def createPayload =
    """
    {
      "contactChannel": [
        {
          "currentPhone": '#(getPE.phoneNumber)',
          "currentEmail": '#(getPE.email)'
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
          "identificationNumber": "",
          "countryOfTaxResidence": "",
          "residenceDate": ""
        }
      ],
      "externalIds": [],
      "termsAndConditions": [
        {
          "versionId": "VERSION 1.2",
          "dateOfApproval": "20191206"
        }
      ],
      "preferredName": '#(givenName)',
      "givenName": '#(givenName)',
      "familyName": '#(familyName)',
      "middleName": '#(middleName)',
      "fullName": '#(fullName)',
      "gender": "F",
      "shortName": "#(fullName)",
      "dateOfBirth": '#(RandomUtils.getRandomBirthDate())',
      "taxFileNumber": '#(RandomUtils.randomTaxFileNumber())',
      "tfnExemptionId": "",
      "tfnExemptionCodeDesc": "",
      "tfnStatus": "PROVIDED",
      "customerResidency": "AU",
      "customerCitizenship": "AU",
      "occupationId": "#(occupationId)",
      "occupation": "#(occupation)",
      "countryOfResidenceOfTaxPurpose": "AU"
    }
    """

    Given url serviceCustomerUrl
    And path '/customer-profile/v1/customers/' + cif
    And headers headers
    When request createPayload
    And method PUT
    Then status 200

    * print "Update cif*************"
    * def statusPayload =
    """
    {
      "operations": [
        {
          "operation": "replace",
          "field": "temenos_cif",
          "value": '#(cif)'
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
