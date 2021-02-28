@FORM_ORCHESTRATION
Feature: Verify integration flow of Product Subscription for selecting a product

  Background:
    * def getHeader = call read('classpath:shared/get-gateway-access-token.feature')
    * def headers = getHeader.headers
    * def productSubscriptionData = 'classpath:features/a4-form-orchestration-v1/data/'
    * def formBody = read(productSubscriptionData +'productSelection.json')


  @GatewayAPI @A4.2 @NOVOCO-1761 @SIT @NOVOCO-1761.3 @ignore
  Scenario Outline: Verify the flow for Product Subscription with select product for single account with type Primary and Joint
    * def customerId = '<cif>'
    * def Authorisation = 'Bearer ' + Helper.jwtBuilder(customerId)
    * def email = RandomUtils.randomEmail()
    * def mobileNumber = RandomUtils.randomMobileNumber()
    * def firstName = RandomUtils.randomFirstName()
    * def lastName = RandomUtils.randomLastName()

    #Get Products action
    Given url baseUrl
    And path '/product-subscription/v1/products'
    And headers headers
    And header category = '<category>'
    When method GET
    Then status 200

    #Setting products
    * def currentProduct = get response[<productIndex>]
    * set formBody.formBody.application.selectedProduct.virtualProductId = currentProduct.virtualProductId
    * set formBody.formBody.application.selectedProduct.virtualProductName = currentProduct.virtualProductName
    * set formBody.formBody.application.selectedProduct.title = currentProduct.title
    * set formBody.formBody.application.selectedProduct.description = currentProduct.description
    * set formBody.formBody.application.selectedProduct.learnMore = currentProduct.learnMore
    * set formBody.formBody.application.selectedProduct.tcLink = currentProduct.tcLink
    * set formBody.formBody.application.selectedProduct.tcVersion = currentProduct.tcVersion
    * set formBody.formBody.application.selectedProduct.products = currentProduct.products

    #Initiate form
    Given url baseUrl
    And path '/forms-orchestration/v1/form/vma-onboard-mobile'
    And headers headers
    And method GET
    When status 200
    And match $.formStatus == 'Opened'

    * set formBody.instance = $.requestKey
    * set formBody.formBody.sfmData.systemProfile.revisionNumber = $.formBody.sfmData.systemProfile.revisionNumber
    * set formBody.formBody.sfmData.systemProfile.trackingCode = $.formBody.sfmData.systemProfile.trackingCode
    * set formBody.formBody.application.hasJointApplicant = <hasJoint>
    * set formBody.formBody.application.applicant.applicantType = '<applicantType>'
    * set formBody.formBody.application.applicant.emailAddress = email
    * set formBody.formBody.application.applicant.mobileNumber = mobileNumber
    * set formBody.formBody.application.applicant.firstName = firstName
    * set formBody.formBody.application.applicant.lastName = lastName

    # Single product select
    Given url baseUrl
    And path '/forms-orchestration/v1/form'
    And headers headers
    And request formBody
    And method PUT
    When status 200

    # product cifLookup
    * set formBody.formBody.journeyData.currentPage = 'products'
    * set formBody.formBody.journeyData.currentPageAction = 'cifLookup'
    Given url baseUrl
    And path '/forms-orchestration/v1/form/'
    And headers headers
    And header Authorization = Authorisation
    And request formBody
    And method PUT
    When status 200
    Then match $.data.executionStatus == 'SUCCESS'
    And match $.data.response.verificationResult == '<verifiedStatus>'
    And match responseCookies contains {JSESSIONID: '#notnull'}
    * print responseCookies

    # product selectProducts
    * set formBody.formBody.journeyData.currentPage = 'products'
    * set formBody.formBody.journeyData.currentPageAction = 'selectProduct'
    Given url baseUrl
    And path '/forms-orchestration/v1/form/'
    And headers headers
    And header Authorization = Authorisation
    And request formBody
    And method PUT
    When status 200
    Then match $.data.executionStatus == 'SUCCESS'
    And match $.data.response.productEligibilityStatus == <eligibilityStatus>

    Examples:
      | cif    | hasJoint | applicantType | category | productIndex | eligibilityStatus | verifiedStatus |
      | 111430 | false    | Primary       | SAVE     | 0            | false             | UNVERIFIED     |
      | 111429 | false    | Primary       | SAVE     | 0            | false             | UNVERIFIED     |
      | 111429 | true     | Joint         | SAVE     | 1            | true              | UNVERIFIED     |
      | 111429 | false    | Primary       | SPEND    | 0            | true              | UNVERIFIED     |
      | 111429 | true     | Joint         | SPEND    | 1            | true              | UNVERIFIED     |
      | 111421 | false    | Primary       | SAVE     | 0            | false             | VERIFIED       |
      | 111421 | false    | Primary       | SAVE     | 1            | true              | VERIFIED       |
      | 111421 | true     | Joint         | SPEND    | 0            | false             | VERIFIED       |
      | 111421 | true     | Joint         | SPEND    | 1            | false             | VERIFIED       |
      | 111444 | false    | Primary       | SAVE     | 0            | true              | VERIFIED       |
      | 111444 | true     | Joint         | SAVE     | 1            | true              | VERIFIED       |
      | 111445 | false    | Primary       | SPEND    | 0            | true              | VERIFIED       |
      | 111445 | true     | Joint         | SPEND    | 1            | true              | VERIFIED       |
