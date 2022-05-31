Feature: Servers MUST support GET, HEAD and OPTIONS

  Background: Set up container
    * def testContainer = rootTestContainer.createContainer()
    * def container = testContainer.createContainer()  
    * def exampleTurtle = karate.readAsString('../fixtures/example.ttl')
    * def rdfResource = testContainer.createResource('.ttl', exampleTurtle, 'text/turtle');
    * def expected = parse(exampleTurtle, 'text/turtle')
    
  Scenario: GET is supported for containers
    Given url testContainer.url
    And headers clients.alice.getAuthHeaders('GET', testContainer.url)
    When method GET
    Then assert responseStatus != 400 && responseStatus <= 403

  Scenario: GET is supported for resources
    Given url rdfResource.url
    And headers clients.alice.getAuthHeaders('GET', rdfResource.url)
    When method GET
    Then assert responseStatus != 400 && responseStatus <= 403

  Scenario: HEAD is supported for containers
    Given url testContainer.url
    And headers clients.alice.getAuthHeaders('HEAD', testContainer.url)
    When method HEAD
    Then assert responseStatus != 400 && responseStatus <= 403

  Scenario: HEAD is supported for resources
    Given url rdfResource.url
    And headers clients.alice.getAuthHeaders('HEAD', rdfResource.url)
    When method HEAD
    Then assert responseStatus != 400 && responseStatus <= 403


  Scenario: OPTIONS is supported for containers
    Given url testContainer.url
    And headers clients.alice.getAuthHeaders('OPTIONS', testContainer.url)
    When method OPTIONS
    Then assert responseStatus != 400 && responseStatus <= 403

  Scenario: OPTIONS is supported for resources
    Given url rdfResource.url
    And headers clients.alice.getAuthHeaders('OPTIONS', rdfResource.url)
    When method OPTIONS
    Then assert responseStatus != 400 && responseStatus <= 403

    
# TODO: What does requirement really mean? Since authn isn't required, should we test without authn and allow 40x, or should we always test with out and require a 200 response?
