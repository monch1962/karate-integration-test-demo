Feature:
# Refer https://qdigital.atlassian.net/wiki/spaces/DNMVP/pages/1215634732/Top+up+customer+account+balance for more info
  Scenario: Get Customer Profile from T24
    * def requestBody =
		"""
		{
        "body": {
        "transactionAmount":"#(Amount)",
        "paymentCurrency":"AUD",
        "debitCurrency":"AUD",
        "debitAccount":"#(T24addMoneyAccount)",
        "creditAccount":"#(AccountID)"
         }
        }
		"""

    Given url T24addMoneyUrl
    And request requestBody
    When method POST
    Then status 200
    * def details = get response