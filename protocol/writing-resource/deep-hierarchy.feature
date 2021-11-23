Feature: Create: PUT Turtle resources to into a deep hierarchy.

  Background: Setup
    * def testContainer = createTestContainerImmediate()

  Scenario: Create RDFSource at /foo/baz/dahut-rs.ttl
    * def requestUri = testContainer.url + 'foo/baz/dahut-rs.ttl'
    Given url requestUri
    And configure headers = clients.alice.getAuthHeaders('PUT', requestUri)
    And header Content-Type = 'text/turtle'
    And header Link = '<http://www.w3.org/ns/ldp#RDFSource>; rel="type"'
    And request '@prefix dc: <http://purl.org/dc/terms/>. <> dc:title "RDF source Interaction Model"@en .'
    When method PUT
    Then status 201

    # Test 4.5 Check resource exists: /foo/baz/dahut-rs.ttl
    Given url requestUri
    And configure headers = clients.alice.getAuthHeaders('GET', requestUri)
    When method GET
    Then status 200

    # Test 4.6 Check container exists: /foo/
    * def requestUri = testContainer.url + 'foo/'
    Given url requestUri
    And configure headers = clients.alice.getAuthHeaders('GET', requestUri)
    When method GET
    Then status 200

  Scenario: Create No Interaction model resource at /foobar/baz/dahut-no.ttl
    * def requestUri = testContainer.url + 'foobar/baz/dahut-no.ttl'
    Given url requestUri
    And configure headers = clients.alice.getAuthHeaders('PUT', requestUri)
    And header Content-Type = 'text/turtle'
    And request '@prefix dc: <http://purl.org/dc/terms/>. <> dc:title "No Interaction Model"@en .'
    When method PUT
    Then status 201

    # Test 4.8 Check resource exists /foobar/baz/dahut-no.ttl
    * def requestUri = testContainer.url + 'foobar/baz/dahut-no.ttl'
    Given url requestUri
    And configure headers = clients.alice.getAuthHeaders('GET', requestUri)
    When method GET
    Then status 200

  # Test 4.9 Check container exists: /foobar/
    * def requestUri = testContainer.url + 'foobar/'
    Given url requestUri
    And configure headers = clients.alice.getAuthHeaders('GET', requestUri)
    When method GET
    Then status 200
