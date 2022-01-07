Feature: Server protects non-empty container
  
  Background: Set up container and a few child resources
    * def testContainer = rootTestContainer.createContainer()
  
  Scenario: Check that container with child container is protected
    * testContainer.createContainer()
    Given url testContainer.url
    And headers clients.alice.getAuthHeaders('DELETE', testContainer.url)
    When method DELETE
    Then status 409

  Scenario: Check that container with child RDF resource is protected
    * def exampleTurtle = karate.readAsString('../fixtures/example.ttl')
    * testContainer.createResource('.ttl', exampleTurtle, 'text/turtle');
    Given url testContainer.url
    And headers clients.alice.getAuthHeaders('DELETE', testContainer.url)
    When method DELETE
    Then status 409


  Scenario: Check that container with child text resource is protected
    * def resource2 = testContainer.createResource('.txt', 'DAHUT', 'text/plain');
    Given url testContainer.url
    And headers clients.alice.getAuthHeaders('DELETE', testContainer.url)
    When method DELETE
    Then status 409


    # TODO: Add tests for error message
