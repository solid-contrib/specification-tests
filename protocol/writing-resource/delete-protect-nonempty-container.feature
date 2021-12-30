Feature: Server protects non-empty container
  
  Background: Set up container and a few child resources
    * def testContainer = rootTestContainer.createContainer()
    * def exampleTurtle = karate.readAsString('../fixtures/example.ttl')
    * def resource1 = testContainer.createResource('.ttl', exampleTurtle, 'text/turtle');
    * def resource2 = testContainer.createResource('.txt', 'DAHUT', 'text/plain');

  
  Scenario: Check that container with child container is protected
    * def container1 = testContainer.createContainer()
    Given url testContainer.url
    And headers clients.alice.getAuthHeaders('DELETE', testContainer.url)
    When method DELETE
    Then status 409


    # TODO: Add tests for error message
