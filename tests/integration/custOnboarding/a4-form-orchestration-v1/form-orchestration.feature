@FORM_ORCHESTRATION
Feature: Get Put and POST Form

  #Test Data- This is the beginning of customer onboarding. No prior test data set up required.
  Background:
    * def getHeader = call read('classpath:shared/get-gateway-headers.feature')
    * def headers = getHeader.headers
    * def responseFinal = read('classpath:features/a4-form-orchestration-v1/data/getFormResponse.json')
    * def generateOTPBody = read('classpath:features/a4-form-orchestration-v1/data/generateOTP.json')
    * def validateOTPBody = read('classpath:features/a4-form-orchestration-v1/data/validateOtp.json')
    * def mobEmailDupeBody = read('classpath:features/a4-form-orchestration-v1/data/mobEmailDupeCheck.json')
    * def postFormBody = read('classpath:features/a4-form-orchestration-v1/data/postForm.json')
    * def PUTBody = read('classpath:features/a4-form-orchestration-v1/data/greenID.json')
    * configure readTimeout = 60000

  @GatewayAPI @A4.1 @4.2 @A4.3 @NOVOCO-1121 @SIT
  Scenario: GET PUT POST Form

    * print 'Get Form'

    Given url baseUrl
    And path 'forms-orchestration/v1/form/vma-onboard-mobile'
    And headers headers
    When method GET
    Then status 200
    * def requestKey = response.requestKey
    * def revisionNumber = response.formBody.sfmData.systemProfile.revisionNumber
    * def trackingCode = response.formBody.sfmData.systemProfile.trackingCode
    And match response == responseFinal

    * print 'Generate OTP*******************'

    * set generateOTPBody.formBody.sfmData.systemProfile.revisionNumber = revisionNumber
    * set generateOTPBody.instance = requestKey
    * set generateOTPBody.formBody.application.applicant.mobileNumber = RandomUtils.randomMobileNumber().substring(RandomUtils.randomMobileNumber().lastIndexOf('+') + 1)
    * set generateOTPBody.formBody.application.applicant.emailAddress = RandomUtils.randomEmail()
    * set generateOTPBody.formBody.application.applicant.firstName = RandomUtils.randomFirstName()
    * set generateOTPBody.formBody.application.applicant.lastName = RandomUtils.randomLastName()
#    * set generateOTPBody.formBody.application.applicant.residentialAddress.fullAddress = TestDataUtils.generateAddressForCustomer()
    * set generateOTPBody.formBody.sfmData.systemProfile.trackingCode = trackingCode

    Given url baseUrl
    And path 'forms-orchestration/v1/form'
    And headers headers
    And request generateOTPBody
    When method PUT
    Then status 200

    * def trackToken = response.data.response.trackToken
    * def mobileNumber = response.data.response.mobileNumber
    * def email = response.formBody.application.applicant.emailAddress
    * def firstName = response.formBody.application.applicant.firstName
    * def lastName = response.formBody.application.applicant.lastName
    * def resAddress = response.formBody.application.applicant.residentialAddress.fullAddress
    * def genOTPRev = response.formBody.sfmData.systemProfile.revisionNumber
    And match response.data.actionName == "generateOTP"
    And match response.data.executionStatus == "SUCCESS"

    * print 'Validate OTP*******************'


    * set validateOTPBody.formBody.sfmData.systemProfile.revisionNumber = revisionNumber
    * set validateOTPBody.instance = requestKey
    * set validateOTPBody.formBody.application.applicant.mobileNumber = mobileNumber
    * set validateOTPBody.formBody.application.applicant.emailAddress = email
    * set validateOTPBody.formBody.application.applicant.firstName = firstName
    * set validateOTPBody.formBody.application.applicant.lastName = lastName
#    * set validateOTPBody.formBody.application.applicant.residentialAddress.fullAddress = resAddress
    * set validateOTPBody.formBody.sfmData.systemProfile.trackingCode = trackingCode
    * set validateOTPBody.formBody.application.applicant.trackToken = trackToken

    Given url baseUrl
    And path 'forms-orchestration/v1/form'
    And headers headers
    And request validateOTPBody
    When method PUT
    Then status 200
    * def accessToken = response.data.response.accessToken
    * def guid = response.data.response.user
    And match response.data.actionName == "validateOTP"
    And match response.data.executionStatus == "SUCCESS"
    And match response.data.response.accessToken == "#present"


    * print 'MobileEmailDupCheck*******************'

    * set mobEmailDupeBody.formBody.sfmData.systemProfile.revisionNumber = revisionNumber
    * set mobEmailDupeBody.instance = requestKey
    * set mobEmailDupeBody.formBody.application.applicant.mobileNumber = mobileNumber
    * set mobEmailDupeBody.formBody.application.applicant.emailAddress = email
    * set mobEmailDupeBody.formBody.application.applicant.firstName = firstName
    * set mobEmailDupeBody.formBody.application.applicant.lastName = lastName
#    * set mobEmailDupeBody.formBody.application.applicant.residentialAddress.fullAddress = resAddress
    * set mobEmailDupeBody.formBody.sfmData.systemProfile.trackingCode = trackingCode

    Given url baseUrl
    And path 'forms-orchestration/v1/form'
    And headers headers
    And request mobEmailDupeBody
    When method PUT
    Then status 200
    And match response.data.actionName == "mobEmailDupCheck"
    And match response.data.executionStatus == "SUCCESS"
    And match response.data.response.accountExists == false

    * print 'DLCheck*******************'

    * set PUTBody.formBody.sfmData.systemProfile.revisionNumber = revisionNumber
    * set PUTBody.instance = requestKey
    * set PUTBody.formBody.application.applicant.mobileNumber = mobileNumber
    * set PUTBody.formBody.application.applicant.emailAddress = email
    * set PUTBody.formBody.application.applicant.firstName = firstName
    * set PUTBody.formBody.application.applicant.lastName = lastName
#    * set dlBody.formBody.application.applicant.residentialAddress.fullAddress = resAddress
    * set PUTBody.formBody.sfmData.systemProfile.trackingCode = trackingCode
    * set PUTBody.formBody.application.applicant.greenIdVerify.regodvsFirstName = firstName
    * set PUTBody.formBody.application.applicant.greenIdVerify.regodvsLastName = lastName
    * set PUTBody.formBody.journeyData.currentPage = "confirm"
    * set PUTBody.formBody.journeyData.currentPageAction = "dlCheck"

    Given url baseUrl
    And path 'forms-orchestration/v1/form'
    And headers headers
    And request PUTBody
    When method PUT
    Then status 200
    * def verifyUserId = response.formBody.application.applicant.greenIdVerify.verifyUserId
    And match response.data.actionName == "dlCheck"
    And match response.data.executionStatus == "SUCCESS"
    And match response.data.response.verificationID == "#present"
    And match response.data.response.verificationResult == "VERIFIED"

    * print 'AU Passport Check*******************'

    * set PUTBody.formBody.sfmData.systemProfile.revisionNumber = revisionNumber
    * set PUTBody.instance = requestKey
    * set PUTBody.formBody.application.applicant.mobileNumber = mobileNumber
    * set PUTBody.formBody.application.applicant.emailAddress = email
    * set PUTBody.formBody.application.applicant.firstName = firstName
    * set PUTBody.formBody.application.applicant.lastName = lastName
#    * set mobEmailDupeBody.formBody.application.applicant.residentialAddress.fullAddress = resAddress
    * set PUTBody.formBody.application.applicant.greenIdVerify.passportdvsFirstName = firstName
    * set PUTBody.formBody.application.applicant.greenIdVerify.passportdvsLastName = lastName
    * set PUTBody.formBody.sfmData.systemProfile.trackingCode = trackingCode
    * set PUTBody.formBody.journeyData.currentPage = "confirm"
    * set PUTBody.formBody.journeyData.currentPageAction = "passportCheck"

    Given url baseUrl
    And path 'forms-orchestration/v1/form'
    And headers headers
    And request PUTBody
    When method PUT
    Then status 200
    And match response.data.response.verificationID == "#present"
    And match response.data.executionStatus == "SUCCESS"
    And match response.data.actionName == "passportCheck"
    And match response.data.response.verificationID == "#present"
    And match response.data.response.verificationResult == "VERIFIED"

    * print 'Medicare Check*******************'

    * set PUTBody.formBody.sfmData.systemProfile.revisionNumber = revisionNumber
    * set PUTBody.instance = requestKey
    * set PUTBody.formBody.application.applicant.mobileNumber = mobileNumber
    * set PUTBody.formBody.application.applicant.emailAddress = email
    * set PUTBody.formBody.application.applicant.firstName = firstName
    * set PUTBody.formBody.application.applicant.lastName = lastName
#    * set PUTBody.formBody.application.applicant.residentialAddress.fullAddress = resAddress
    * set PUTBody.formBody.application.applicant.greenIdVerify.medicaredvsNameLine2 = firstName
    * set PUTBody.formBody.application.applicant.greenIdVerify.medicaredvsNameLine4 = lastName
    * set PUTBody.formBody.application.applicant.greenIdVerify.medicaredvsNameOnCard = firstName + lastName
    * set PUTBody.formBody.sfmData.systemProfile.trackingCode = trackingCode
    * set PUTBody.formBody.journeyData.currentPage = "confirm"
    * set PUTBody.formBody.journeyData.currentPageAction = "medicareCheck"

    Given url baseUrl
    And path 'forms-orchestration/v1/form'
    And headers headers
    And request PUTBody
    When method PUT
    Then status 200
    And match response.data.executionStatus == "SUCCESS"
    And match response.data.actionName == "medicareCheck"
    And match response.data.response.verificationID == "#present"
    And match response.data.response.verificationResult == "VERIFIED"

    * print 'AU Birth Cert Check*******************'

    * set PUTBody.formBody.sfmData.systemProfile.revisionNumber = revisionNumber
    * set PUTBody.instance = requestKey
    * set PUTBody.formBody.application.applicant.mobileNumber = mobileNumber
    * set PUTBody.formBody.application.applicant.emailAddress = email
    * set PUTBody.formBody.application.applicant.firstName = firstName
    * set PUTBody.formBody.application.applicant.lastName = lastName
#    * set PUTBody.formBody.application.applicant.residentialAddress.fullAddress = resAddress
    * set PUTBody.formBody.application.applicant.greenIdVerify.birthdvsFirstName = firstName
    * set PUTBody.formBody.application.applicant.greenIdVerify.birthdvsLastName = lastName
    * set PUTBody.formBody.sfmData.systemProfile.trackingCode = trackingCode
    * set PUTBody.formBody.journeyData.currentPage = "confirm"
    * set PUTBody.formBody.journeyData.currentPageAction = "ausBirthCertCheck"

    Given url baseUrl
    And path 'forms-orchestration/v1/form'
    And headers headers
    And request PUTBody
    When method PUT
    Then status 200
    And match response.data.executionStatus == "SUCCESS"
    And match response.data.actionName == "ausBirthCertCheck"
    And match response.data.response.verificationID == "#present"
    And match response.data.response.verificationResult == "VERIFIED"

    * print 'AU Citizen Check*******************'

    * set PUTBody.formBody.sfmData.systemProfile.revisionNumber = revisionNumber
    * set PUTBody.instance = requestKey
    * set PUTBody.formBody.application.applicant.mobileNumber = mobileNumber
    * set PUTBody.formBody.application.applicant.emailAddress = email
    * set PUTBody.formBody.application.applicant.firstName = firstName
    * set PUTBody.formBody.application.applicant.lastName = lastName
#    * set PUTBody.formBody.application.applicant.residentialAddress.fullAddress = resAddress
    * set PUTBody.formBody.application.applicant.greenIdVerify.citizenshipdvsFirstName = firstName
    * set PUTBody.formBody.application.applicant.greenIdVerify.citizenshipdvsLastName = lastName
    * set PUTBody.formBody.sfmData.systemProfile.trackingCode = trackingCode
    * set PUTBody.formBody.journeyData.currentPage = "confirm"
    * set PUTBody.formBody.journeyData.currentPageAction = "ausCitizenCertCheck"

    Given url baseUrl
    And path 'forms-orchestration/v1/form'
    And headers headers
    And request PUTBody
    When method PUT
    Then status 200
    * def AUCRev = response.formBody.sfmData.systemProfile.revisionNumber
    And match response.data.executionStatus == "SUCCESS"
    And match response.data.actionName == "ausCitizenCertCheck"
    And match response.data.response.verificationID == "#present"
    And match response.data.response.verificationResult == "VERIFIED"

    * print 'Tax Obligation Check*******************'

    * set PUTBody.formBody.sfmData.systemProfile.revisionNumber = revisionNumber
    * set PUTBody.instance = requestKey
    * set PUTBody.formBody.application.applicant.mobileNumber = mobileNumber
    * set PUTBody.formBody.application.applicant.emailAddress = email
    * set PUTBody.formBody.application.applicant.firstName = firstName
    * set PUTBody.formBody.application.applicant.lastName = lastName
#    * set PUTBody.formBody.application.applicant.residentialAddress.fullAddress = resAddress
    * set PUTBody.formBody.sfmData.systemProfile.trackingCode = trackingCode
    * set PUTBody.formBody.journeyData.currentPage = "taxObligation"
    * set PUTBody.formBody.journeyData.currentPageAction = " "

    Given url baseUrl
    And path 'forms-orchestration/v1/form'
    And headers headers
    And request PUTBody
    When method PUT
    Then status 200

    * print 'Duplicate User Check*******************'

    * set PUTBody.formBody.sfmData.systemProfile.revisionNumber = revisionNumber
    * set PUTBody.instance = requestKey
    * set PUTBody.formBody.application.applicant.mobileNumber = mobileNumber
    * set PUTBody.formBody.application.applicant.emailAddress = email
    * set PUTBody.formBody.application.applicant.firstName = firstName
    * set PUTBody.formBody.application.applicant.lastName = lastName
#    * set mobEmailDupeBody.formBody.application.applicant.residentialAddress.fullAddress = resAddress
    * set PUTBody.formBody.sfmData.systemProfile.trackingCode = trackingCode
    * set PUTBody.formBody.journeyData.currentPage = "residentialAddressConfirm"
    * set PUTBody.formBody.journeyData.currentPageAction = "duplicateUserCheck"

    Given url baseUrl
    And path 'forms-orchestration/v1/form'
    And headers headers
    And request PUTBody
    When method PUT
    Then status 200
    * def RARev = response.formBody.sfmData.systemProfile.revisionNumber
    And match response.data.executionStatus == "SUCCESS"
    And match response.data.actionName == "duplicateUserCheck"

    * print 'Occupation Check*******************'

    * set PUTBody.formBody.sfmData.systemProfile.revisionNumber = revisionNumber
    * set PUTBody.instance = requestKey
    * set PUTBody.formBody.application.applicant.mobileNumber = mobileNumber
    * set PUTBody.formBody.application.applicant.emailAddress = email
    * set PUTBody.formBody.application.applicant.firstName = firstName
    * set PUTBody.formBody.application.applicant.lastName = lastName
#    * set PUTBody.formBody.application.applicant.residentialAddress.fullAddress = resAddress
    * set PUTBody.formBody.sfmData.systemProfile.trackingCode = trackingCode
    * set PUTBody.formBody.journeyData.currentPage = "occupation"
    * set PUTBody.formBody.journeyData.currentPageAction = " "

    Given url baseUrl
    And path 'forms-orchestration/v1/form'
    And headers headers
    And request PUTBody
    When method PUT
    Then status 200
    * def ORev = response.formBody.sfmData.systemProfile.revisionNumber

    * print 'Reserve Cif*******************'

    * set PUTBody.formBody.sfmData.systemProfile.revisionNumber = revisionNumber
    * set PUTBody.instance = requestKey
    * set PUTBody.formBody.application.applicant.mobileNumber = mobileNumber
    * set PUTBody.formBody.application.applicant.emailAddress = email
    * set PUTBody.formBody.application.applicant.firstName = firstName
    * set PUTBody.formBody.application.applicant.lastName = lastName
    * set PUTBody.formBody.application.applicant.residentialAddress.fullAddress = resAddress
    * set PUTBody.formBody.sfmData.systemProfile.trackingCode = trackingCode
    * set PUTBody.formBody.journeyData.currentPage = "confirm"
    * set PUTBody.formBody.journeyData.currentPageAction = "reserveCIF"

    Given url baseUrl
    And path 'forms-orchestration/v1/form'
    And headers headers
    And request PUTBody
    When method PUT
    Then status 200
    And match response.data.executionStatus == "SUCCESS"
    And match response.data.actionName == "reserveCIF"

    * print 'FCM Check*******************'

    * set PUTBody.formBody.sfmData.systemProfile.revisionNumber = revisionNumber
    * set PUTBody.instance = requestKey
    * set PUTBody.formBody.application.applicant.mobileNumber = mobileNumber
    * set PUTBody.formBody.application.applicant.emailAddress = email
    * set PUTBody.formBody.application.applicant.firstName = firstName
    * set PUTBody.formBody.application.applicant.lastName = lastName
#    * set PUTBody.formBody.application.applicant.residentialAddress.fullAddress = resAddress
    * set PUTBody.formBody.sfmData.systemProfile.trackingCode = trackingCode
    * set PUTBody.formBody.journeyData.currentPage = "confirm"
    * set PUTBody.formBody.journeyData.currentPageAction = "fcmCheck"

    Given url baseUrl
    And path 'forms-orchestration/v1/form'
    And headers headers
    And request PUTBody
    When method PUT
    Then status 200
    And match response.data.executionStatus == "SUCCESS"
    And match response.data.actionName == "fcmCheck"
    And match response.data.response.fcmCheckResult == "PASS"

    * print 'POST Form*******************'

    * set postFormBody.formBody.sfmData.systemProfile.revisionNumber = revisionNumber
    * set postFormBody.instance = requestKey
    * set postFormBody.formBody.application.applicant.mobileNumber = mobileNumber
    * set postFormBody.formBody.application.applicant.emailAddress = email
    * set postFormBody.formBody.application.applicant.firstName = firstName
    * set postFormBody.formBody.application.applicant.lastName = lastName
#    * set postFormBody.formBody.application.applicant.residentialAddress.fullAddress = resAddress
    * set postFormBody.formBody.sfmData.systemProfile.trackingCode = trackingCode
    * set postFormBody.formBody.application.applicant.greenIdVerify.regodvsFirstName = firstName
    * set postFormBody.formBody.application.applicant.greenIdVerify.regodvsLastName = lastName
    * set postFormBody.formBody.application.applicant.greenIdVerify.passportdvsFirstName = firstName
    * set postFormBody.formBody.application.applicant.greenIdVerify.passportdvsLastName = lastName
    * set postFormBody.formBody.application.applicant.greenIdVerify.medicaredvsNameLine2 = firstName
    * set postFormBody.formBody.application.applicant.greenIdVerify.medicaredvsNameLine4 = lastName
    * set postFormBody.formBody.application.applicant.greenIdVerify.medicaredvsNameOnCard = firstName + lastName
    * set postFormBody.formBody.application.applicant.greenIdVerify.birthdvsFirstName = firstName
    * set postFormBody.formBody.application.applicant.greenIdVerify.birthdvsLastName = lastName
    * set postFormBody.formBody.application.applicant.greenIdVerify.citizenshipdvsFirstName = firstName
    * set postFormBody.formBody.application.applicant.greenIdVerify.citizenshipdvsLastName = lastName
    * set postFormBody.formBody.sfmData.systemProfile.trackingCode = trackingCode
    * set postFormBody.formBody.journeyData.currentPage = "submit"
    * set postFormBody.formBody.journeyData.currentPageAction = ""

    Given url baseUrl
    And path 'forms-orchestration/v1/form'
    And headers headers
    And request postFormBody
    When method POST
    Then status 200
    And match response.data.response.arrangementId == "#present"




