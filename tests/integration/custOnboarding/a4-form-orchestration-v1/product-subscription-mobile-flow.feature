Feature: Verify integration flow of Product Subscription for selecting a product

  Background:
    * def getHeader = call read('classpath:shared/get-gateway-headers.feature')
    * def headers = getHeader.headers
    * def orchestrationLocation = 'classpath:features/a4-form-orchestration-v1/'
    * def formBody = read(orchestrationLocation +'data/initialFormUnverified.json')

  # This scenario cannot be achieved as it requires manual intervention from TJM to provide challenge answer
  @GatewayAPI @A4.2 @SIT @Mobile @ignore
  Scenario: Verify the flow for Product Subscription single applicant
    * def category = call read('classpath:shared/get-categories.feature')
    * def customerId = '111454'
    * def Authorisation = 'Bearer ' + Helper.jwtBuilder(customerId)
    * def email = RandomUtils.randomEmail()
    * def mobileNumber = RandomUtils.randomMobileNumber()
    * def firstName = RandomUtils.randomFirstName()
    * def lastName = RandomUtils.randomLastName()

    #data driven here
    * def products = call read('classpath:shared/get-single-product.feature') { category: 'SAVE', index: '0' }

    # initiate form
    Given url baseUrl
    And path '/forms-orchestration/v1/form/vma-onboard-mobile'
    And headers headers
    And method GET
    When status 200
    And match $.formStatus == 'Opened'

    * set formBody.instance = response.requestKey
    * set formBody.formBody.sfmData.systemProfile.revisionNumber = $.formBody.sfmData.systemProfile.revisionNumber
    * set formBody.formBody.sfmData.systemProfile.trackingCode = $.formBody.sfmData.systemProfile.trackingCode

    # initiate for cifLookup
    * set formBody.formBody.application.selectedProduct.virtualProductId = products.selectedProduct.virtualProductId
    * set formBody.formBody.application.selectedProduct.virtualProductName = products.selectedProduct.virtualProductName
    * set formBody.formBody.application.selectedProduct.title = products.selectedProduct.title
    * set formBody.formBody.application.selectedProduct.description = products.selectedProduct.description
    * set formBody.formBody.application.selectedProduct.learnMore = products.selectedProduct.learnMore
    * set formBody.formBody.application.selectedProduct.tcLink = products.selectedProduct.tcLink
    * set formBody.formBody.application.selectedProduct.tcVersion = products.selectedProduct.tcVersion
    * set formBody.formBody.application.selectedProduct.products = products.selectedProduct.products

    # form action
    * set formBody.formBody.journeyData.currentPage = 'products'
    * set formBody.formBody.journeyData.currentPageAction = 'cifLookup'
    * print formBody.instance

    # cif lookup
    Given url baseUrl
    And path '/forms-orchestration/v1/form/'
    And headers headers
    And header Authorization = Authorisation
    And request formBody
    And method PUT
    When status 200
    Then match $.data.executionStatus == 'SUCCESS'
    And match $.data.actionName == 'cifLookup'
    And match $.data.response.verificationResult == 'UNVERIFIED'

    # setting Last Name, First Name, Mobile number
    * set formBody.formBody.application.applicant.emailAddress = email
    * set formBody.formBody.application.applicant.lastName = lastName
    * set formBody.formBody.application.applicant.firstName = firstName
    * set formBody.formBody.application.applicant.mobileNumber = mobileNumber
    * set formBody.formBody.journeyData = ""
    * print formBody
    Given url baseUrl
    And path '/forms-orchestration/v1/form/'
    And headers headers
    And header Authorization = Authorisation
    And request formBody
    And method PUT
    When status 200
