Feature:

  Scenario: Get Gateway access token

    * def randomString = RandomUtils.randomNumber(10)
    * def headers =
    """
    {
      "Request-Id": '#(RandomUtils.randomUUID())',
      "Timestamp": '#(RandomUtils.getCurrentDate())',
      "Sending-System-Version": "v1.0",
      "Sending-System-Id": "REF001",
      "Initiating-System-Id": "Karate",
      "Initiating-System-Version": "v1.0",
      "Accept": '#(contentType)',
      "Content-Type": '#(contentType)'
    }
    """