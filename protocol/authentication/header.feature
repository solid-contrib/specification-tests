Feature: Test that unauthenticated users get the correct response

  Background: Setup
    * def testContainer = createTestContainerImmediate()
    * def requestUri = testContainer.getUrl()

  Scenario: Unauthenticated user gets an appropriate response on GET
    Given url requestUri
    When method GET
    Then match [401, 403] contains responseStatus
    And match header WWW-Authenticate != null

  Scenario: Unauthenticated user gets an appropriate response on HEAD
    Given url requestUri
    When method HEAD
    Then match [401, 403] contains responseStatus
    And match header WWW-Authenticate != null

  Scenario: Unauthenticated user gets an appropriate response on PUT
    Given url requestUri
    And header Content-Type = 'text/turtle'
    And request "<> a <#Something> ."
    When method PUT
    Then match [401, 403] contains responseStatus
    And match header WWW-Authenticate != null

  Scenario: Unauthenticated user gets an appropriate response on POST
    Given url requestUri
    And header Content-Type = 'text/turtle'
    And request "<> a <#Something> ."
    When method POST
    Then match [401, 403] contains responseStatus
    And match header WWW-Authenticate != null

  Scenario: Unauthenticated user gets an appropriate response on PATCH
    Given url requestUri
    And header Content-Type = 'application/sparql-update'
    And request "INSERT DATA { <> a <#Something> .}"
    When method PATCH
    Then match [401, 403] contains responseStatus
    And match header WWW-Authenticate != null

  Scenario: Unauthenticated user gets an appropriate response on DELETE
    Given url requestUri
    When method DELETE
    Then match [401, 403] contains responseStatus
    And match header WWW-Authenticate != null
