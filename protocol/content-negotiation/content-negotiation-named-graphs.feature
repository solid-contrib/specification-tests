Feature: RDF documents containing named graphs can be stored and retrieved

  Background: Create a JSON-LD resource with a named graph
    * def testContainer = rootTestContainer.reserveContainer()
    * def withNamedGraphsJson = karate.readAsString('../fixtures/with-named-graphs.json')
    * def resource = testContainer.createResource('.json', withNamedGraphsJson, 'application/ld+json');
    * def expected = parse(withNamedGraphsJson, 'application/ld+json')
    * configure headers = clients.alice.getAuthHeaders('GET', resource.url)
    * url resource.url

  Scenario: Alice can GET the JSON-LD with named graph as JSON-LD
    Given header Accept = 'application/ld+json'
    When method GET
    Then status 200
    And match header Content-Type contains 'application/ld+json'
    And assert parse(response, 'application/ld+json', resource.url).contains(expected)

  Scenario: Alice can GET the JSON-LD with named graph as TTL
    Given header Accept = 'text/turtle'
    When method GET
    Then status 200
    And match header Content-Type contains 'text/turtle'
    And assert parse(response, 'text/turtle', resource.url).contains(expected)
