Feature: Servers MUST return Allow for GET and HEAD

  Background: Set up container
    * def testContainer = rootTestContainer.createContainer()
    * def exampleTurtle = karate.readAsString('../fixtures/example.ttl')
    * def rdfResource = testContainer.createResource('.ttl', exampleTurtle, 'text/turtle');
    
  Scenario: GET is allowed for containers
    Given url testContainer.url
    And headers clients.alice.getAuthHeaders('GET', testContainer.url)
    When method GET
    Then match header allow contains 'GET'
    And match header allow contains 'HEAD'

  Scenario: GET is allowed for resources
    Given url rdfResource.url
    And headers clients.alice.getAuthHeaders('GET', rdfResource.url)
    When method GET
    Then match header allow contains 'GET'
    And match header allow contains 'HEAD'

  Scenario: HEAD is allowed for containers
    Given url testContainer.url
    And headers clients.alice.getAuthHeaders('HEAD', testContainer.url)
    When method HEAD
    Then match header allow contains 'GET'
    And match header allow contains 'HEAD'

  Scenario: HEAD is allowed for resources
    Given url rdfResource.url
    And headers clients.alice.getAuthHeaders('HEAD', rdfResource.url)
    When method HEAD
    Then match header allow contains 'GET'
    And match header allow contains 'HEAD'
