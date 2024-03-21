Feature: Server should enumerate headers in Access-Control-Expose-Headers

  Background: Set up test container (not empty)
    * def testContainer = rootTestContainer.createContainer()
    * def resource = testContainer.createResource('.txt', 'Hello', 'text/plain')

  Scenario: Access-Control-Expose-Headers is present but not *
    Given url testContainer.url
    And headers clients.alice.getAuthHeaders('GET', testContainer.url)
    And header Origin = config.origin
    And header Accept = 'text/turtle'
    When method GET
    Then status 200
    And match header Access-Control-Expose-Headers != null
    And match header Access-Control-Expose-Headers != '*'
    And match response != ''

  # To test this enumerates all headers we could split it on ', ' and compare to the set of all keys in responseHeaders
  # The FETCH spec says
  #   "A response will typically get its CORS-exposed header-name list set by extracting header values from the
  #   `Access-Control-Expose-Headers` header. This list is used by a CORS filtered response to determine which headers to expose."
  # This makes it sound as though the important thing is the intersection - it doesn't matter if headers are in one list but not the other.
