@FORM_ORCHESTRATION
Feature: Verify integration flow of Product Subscription for selecting a product

  Background:
    * def getHeader = call read('classpath:shared/get-gateway-headers.feature')
    * def headers = getHeader.headers
    * def productSubscriptionData = 'classpath:features/a4-form-orchestration-v1/data/'
    * def formBody = read(productSubscriptionData +'jointFirstApplicant.json')


  @GatewayAPI @A4.2 @NOVOCO-1761 @SIT @NOVOCO-1761.1 @ignore
  Scenario Outline: Verify the flow for Product Subscription for first joint applicant
    * def customerId = '<cif>'
    * def Authorisation = 'Bearer ' + Helper.jwtBuilder(customerId)
    * def email = RandomUtils.randomEmail()
    * def mobileNumber = RandomUtils.randomMobileNumber()
    * def firstName = RandomUtils.randomFirstName()
    * def lastName = RandomUtils.randomLastName()
    * def gender = RandomUtils.randomGender()
    * def jointApplicantFullName = RandomUtils.randomName()
    * def jointApplicantMobile = RandomUtils.randomMobileNumber()

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
    * set formBody.formBody.application.jointApplicant.fullName = jointApplicantFullName

    # Single product select
    Given url baseUrl
    And path '/forms-orchestration/v1/form'
    And headers headers
    And request formBody
    And method PUT
    When status 200
    Then match $.formStatus == "Saved"
    And match $.formBody.application.jointApplicant.fullName == jointApplicantFullName

    # current page joint invite
    * set formBody.formBody.journeyData.currentPage = 'jointInviteMobile'
    * set formBody.formBody.journeyData.currentPageAction = 'productEligibilityCheck'
    * set formBody.formBody.application.jointApplicant.mobileNumber = jointApplicantMobile
    Given url baseUrl
    And path '/forms-orchestration/v1/form/'
    And headers headers
    And header Authorization = Authorisation
    And request formBody
    And method PUT
    When status 200
    Then match $.data.executionStatus == 'SUCCESS'
    And match $.data.actionName == 'productEligibilityCheck'
    And match $.formBody.application.jointApplicant.mobileNumber == jointApplicantMobile
    And match $.data.response.productEligibilityStatus == <eligibilityStatus>

    Examples:
      | cif    | hasJoint | applicantType | category | productIndex | eligibilityStatus |
      | 111421 | true     | Joint         | SAVE     | 0            | true              |
      | 111470 | true     | Joint         | SAVE     | 1            | true              |
      | 111470 | true     | Joint         | SPEND    | 0            | true              |
      | 111470 | true     | Joint         | SPEND    | 1            | true              |
      | 111429 | false    | Joint         | SPEND    | 0            | true              |
      | 111429 | false    | Primary       | SAVE     | 0            | true              |
      | 111429 | true     | Joint         | SAVE     | 1            | true              |
      | 111429 | true     | Joint         | SPEND    | 1            | true              |

