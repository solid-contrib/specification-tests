Feature: Servers MUST support GET, HEAD and OPTIONS

  Background: Set up container
    * def testContainer = rootTestContainer.createContainer()
    * def container = testContainer.createContainer()  
    * def exampleTurtle = karate.readAsString('../fixtures/example.ttl')
    * def rdfResource = testContainer.createResource('.ttl', exampleTurtle, 'text/turtle');
    * def expected = parse(exampleTurtle, 'text/turtle')
    
  Scenario: GET is supported for containers
    * def containerUrl = testContainer.url
    Given url containerUrl
    And headers clients.alice.getAuthHeaders('GET', containerUrl)
    When method GET
    Then assert responseStatus != 400 && responseStatus <= 403

