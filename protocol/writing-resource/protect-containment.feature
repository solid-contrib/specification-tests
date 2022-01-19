Feature: Server protects containment triples
  
  Background: Set up container and a few child resources
    * def testContainer = rootTestContainer.createContainer()
    * def exampleTurtle = karate.readAsString('../fixtures/example.ttl')
    * def resource1 = testContainer.createResource('.ttl', exampleTurtle, 'text/turtle');
    * def resource2 = testContainer.createResource('.txt', 'DAHUT', 'text/plain');
    * def resource3 = testContainer.createResource('.txt', 'FOOBAR', 'text/plain');
    * def container1 = testContainer.createContainer()   
    * def children = ([ resource1.url, resource2.url, resource3.url, container1.url ])
    
  Scenario: Check that members are correct
    Given url testContainer.url
    And headers clients.alice.getAuthHeaders('GET', testContainer.url)
    When method GET
    Then status 200
    * def contained = parse(response, 'text/turtle', testContainer.url).members 
    And match contained contains only children
    And match children contains only contained

    Given url testContainer.url
    And headers clients.alice.getAuthHeaders('PUT', testContainer.url)
    And header Content-Type = 'text/turtle'
    And request '<> <http://www.w3.org/ns/ldp#contains> </foobar>.'
    When method PUT
    Then status 409

    Given url testContainer.url
    And headers clients.alice.getAuthHeaders('GET', testContainer.url)
    When method GET
    Then status 200
    * def contained = parse(response, 'text/turtle', testContainer.url).members
    And match contained contains only children
    And match children contains only contained
