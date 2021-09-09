Feature: Test that unauthenticated users get the correct response

  Background: Setup
    * def testContainer = createTestContainerImmediate()
    * def requestUri = testContainer.getUrl()

  Scenario: Unauthenticated user gets an appropriate response on GET
    Given url requestUri
    When method GET
    Then status 401
    And match header WWW-Authenticate != null

  Scenario: Unauthenticated user gets an appropriate response on HEAD
    Given url requestUri
    When method HEAD
    Then status 401
    And match header WWW-Authenticate != null

  Scenario: Unauthenticated user gets an appropriate response on PUT
    Given url requestUri
    When method PUT
    And header Content-Type = 'text/turtle'
    And request "<> a <#Something> ."
    Then status 401
    And match header WWW-Authenticate != null
