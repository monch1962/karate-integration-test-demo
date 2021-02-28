@FORM_ORCHESTRATION
Feature: Verify integration flow of Product Subscription

  Background:
    * def getHeader = call read('classpath:shared/get-gateway-access-token.feature')
    * def headers = getHeader.headers
    * def productSubscriptionData = 'classpath:features/a4-form-orchestration-v1/data/'
    * def formBody = read(productSubscriptionData +'jointSecondApplicant.json')


  @GatewayAPI @A4.2 @NOVOCO-1761 @SIT @NOVOCO-1761.2 @ignore
  Scenario Outline: Verify the flow for Product Subscription for second joint applicant
    * def customerId = '<cif>'
    * def Authorisation = 'Bearer ' + Helper.jwtBuilder(customerId)
    * def email = RandomUtils.randomEmail()
    * def mobileNumber = RandomUtils.randomMobileNumber()
    * def firstName = RandomUtils.randomFirstName()
    * def lastName = RandomUtils.randomLastName()
    * def gender = RandomUtils.randomGender()
    * def jointApplicantFullName = RandomUtils.randomName()
    * def jointApplicantMobile = RandomUtils.randomMobileNumber()
    * def saveChallengeAnswer = "MORGAN|JONES|1981-01-04"

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
    And header TrackingCode = '<trackingCode>'
    And header saveChallengeAnswer = "MORGAN|JONES|1981-01-04"
    And method GET
    When status 200
    And match $.formStatus == 'Saved'

    * set formBody.instance = $.requestKey
    * set formBody.formBody.sfmData.systemProfile.revisionNumber = $.formBody.sfmData.systemProfile.revisionNumber
    * set formBody.formBody.sfmData.systemProfile.trackingCode = $.formBody.sfmData.systemProfile.trackingCode

    * set formBody.formBody.application.hasJointApplicant = <hasJoint>
    * set formBody.formBody.application.applicant.applicantType = '<applicantType>'

    # cif lookup
    * set formBody.formBody.journeyData.currentPage = 'jointInviteProduct'
    * set formBody.formBody.journeyData.currentPageAction = 'cifLookup'
    Given url baseUrl
    And path '/forms-orchestration/v1/form'
    And headers headers
    And request formBody
    And header Authorization = Authorisation
    And method PUT
    When status 200
    Then match $.formStatus == "Saved"
    And match $.data.executionStatus == 'SUCCESS'
    And match $.data.actionName == 'cifLookup'
    And match $.data.response.productEligibilityStatus == <eligibilityStatus>
    And match $.data.response.verificationResult == '<verificationStatus>'

    Examples:
      | cif    | trackingCode | hasJoint | applicantType | category | productIndex | eligibilityStatus | verificationStatus |
      | 111412 | LCFBQ6C      | true     | Joint         | SAVE     | 0            | false             | VERIFIED           |


