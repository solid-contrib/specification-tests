Feature: POST to non-existing resource must result in 404

  Background: Set up container
    * def testContainer = rootTestContainer.createContainer()

  Scenario: Reserved container does not exist
    * def container = testContainer.reserveContainer()  
    Given url container.url
    And headers clients.alice.getAuthHeaders('POST', container.url)
    And header Content-Type = 'text/turtle'
    When method POST
    Then status 404
    
  Scenario: Reserved RDF resource does not exist
    * def rdfResource = testContainer.reserveResource('.ttl');
    Given url rdfResource.url
    And headers clients.alice.getAuthHeaders('POST', rdfResource.url)
    And header Content-Type = 'text/turtle'
    When method POST
    Then status 404

    Given url rdfResource.url
    And headers clients.alice.getAuthHeaders('GET', rdfResource.url)
    When method GET
    Then status 404

  Scenario: Reserved JSON-LD resource does not exist
    * def jsonResource = testContainer.reserveResource('.json');
    Given url jsonResource.url
    And headers clients.alice.getAuthHeaders('POST', jsonResource.url)
    And header Content-Type = 'application/ld+json'
    When method POST
    Then status 404

  Scenario: Reserved resource does not exist
    * def fooResource = testContainer.reserveResource('.foo');
    Given url fooResource.url
    And headers clients.alice.getAuthHeaders('POST', fooResource.url)
    And header Content-Type = 'foo/bar'
    When method POST
    Then match [404, 415] contains responseStatus
