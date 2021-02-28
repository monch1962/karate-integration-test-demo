Feature:

  Scenario: Get Gateway headers

    * def headers =
    """
    {
      "Request-Id": '#(RandomUtils.randomUUID())',
      "Timestamp": '#(RandomUtils.getCurrentDate())',
      "Sending-System-Version": 'v1.0',
      "Sending-System-Id": "REF001",
      "Initiating-System-Id": "MOBILE",
      "Initiating-System-Version": "v1.0",
      "Accept": '#(contentType)',
      "Content-Type": '#(contentType)',
      "Ocp-Apim-Subscription-Key": '#(ocpKey)',
      "Trusteer-Session-Id": '#(RandomUtils.randomUUID())',
      "Interaction-Id": '#(RandomUtils.randomUUID())',
      "Ocp-Apim-Trace": "True"
    }
    """