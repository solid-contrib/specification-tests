Feature: POST to non-existing resource must result in 404

  Background: Set up container
    * def testContainer = rootTestContainer.createContainer()

  Scenario: Reserved container does not exist
    * def container = testContainer.reserveContainer()  
    Given url container.url
    And headers clients.alice.getAuthHeaders('POST', container.url)
    And header Content-Type = 'text/turtle'
    And request "<> a <#Something> ."
    When method POST
    Then status 404

    Given url container.url
    And headers clients.alice.getAuthHeaders('GET', container.url)
    When method GET
    Then status 404
    
  Scenario: Reserved RDF resource does not exist
    * def rdfResource = testContainer.reserveResource('.ttl');
    Given url rdfResource.url
    And headers clients.alice.getAuthHeaders('POST', rdfResource.url)
    And header Content-Type = 'text/turtle'
    And request "<> a <#Something> ."
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
    And request '{ "http://schema.org/name": "Thing" }'
    When method POST
    Then status 404

    Given url jsonResource.url
    And headers clients.alice.getAuthHeaders('GET', jsonResource.url)
    When method GET
    Then status 404
    
  Scenario: Reserved resource does not exist
    * def fooResource = testContainer.reserveResource('.foo');
    Given url fooResource.url
    And headers clients.alice.getAuthHeaders('POST', fooResource.url)
    And header Content-Type = 'foo/bar'
    And request 'Foobar'    
    When method POST
    Then match [404, 415] contains responseStatus

    Given url fooResource.url
    And headers clients.alice.getAuthHeaders('GET', fooResource.url)
    When method GET
    Then status 404
