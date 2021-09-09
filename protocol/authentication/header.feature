Feature: Test that unauthenticated users get the correct response

  Background: Setup
    * def testContainer = createTestContainerImmediate()
    * def requestUri = testContainer.getUrl()

  Scenario: Unauthenticated user gets an appropriate response
    Given url requestUri
    And configure headers = clients.bob.getAuthHeaders('GET', requestUri)
    When method GET
    Then status 401
    And match header WWW-Authenticate != null
