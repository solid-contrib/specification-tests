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

  @ignore
  Scenario: Alice can GET the JSON-LD with named graph as TTL
    # The expected response is disputed - since TTL doesn't support Quads, the RDF spec suggests:
    # "If an RDF dataset is returned and the consumer is expecting an RDF graph, the consumer is expected to use the RDF dataset's default graph."
    # https://github.com/solid-contrib/specification-tests/pull/101#issuecomment-1491711705
    Given header Accept = 'text/turtle'
    When method GET
    Then status 200
    And match header Content-Type contains 'text/turtle'
    And assert parse(response, 'text/turtle', resource.url).contains(expected)
