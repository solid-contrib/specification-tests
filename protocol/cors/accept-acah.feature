# This only applies to pre-flight checks since that is where Access-Control-Allow-Headers is used
Feature: Server should explicitly list Accept under Access-Control-Allow-Headers

  Background: Set up test container
    * def testContainer = rootTestContainer.createContainer()

  Scenario: OPTIONS request returns Accept in Access-Control-Allow-Headers
    Given url testContainer.url
    And headers clients.alice.getAuthHeaders('OPTIONS', testContainer.url)
    And header Origin = 'https://tester'
    And header Access-Control-Request-Method = 'GET'
    And header Access-Control-Request-Headers = 'X-CUSTOM, Content-Type'
    When method OPTIONS
    Then match [200, 204] contains responseStatus
    And match response == ''
    And match header Access-Control-Allow-Headers contains 'Accept'
