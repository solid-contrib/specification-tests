Feature: Create: PUT Turtle resources to into a deep hierarchy.

  Background: Setup
    * def testContainer = createTestContainer()
    * testContainer.createChildResource('.txt', '', 'text/plain');

  Scenario: Test 4.1 on URL /foo/bar/dahut-bc.ttl
    * def requestUri = testContainer.getUrl() + 'foo/bar/dahut-bc.ttl'
    Given url requestUri
    And configure headers = clients.alice.getAuthHeaders('PUT', requestUri)
    And header Content-Type = 'text/turtle'
    And header Link = '<http://www.w3.org/ns/ldp#BasicContainer>; rel="type"'
    And request '@prefix dc: <http://purl.org/dc/terms/>. <> dc:title "Container Interaction Model"@en .'
    When method PUT
    Then status 409

  Scenario: Test 4.2 on URL /foo/bar/dahut-bc.ttl
    * def requestUri = testContainer.getUrl() + 'foo/bar/dahut-bc.ttl'
    Given url requestUri
    And configure headers = clients.alice.getAuthHeaders('GET', requestUri)
    When method GET
    Then status 404

  Scenario: Test 4.3 on URL /foo
    * def requestUri = testContainer.getUrl() + 'foo'
    Given url requestUri
    And configure headers = clients.alice.getAuthHeaders('GET', requestUri)
    When method GET
    Then status 404

  Scenario: Test 4.4 on URL /foo/baz/dahut-rs.ttl
    * def requestUri = testContainer.getUrl() + 'foo/baz/dahut-rs.ttl'
    Given url requestUri
    And configure headers = clients.alice.getAuthHeaders('PUT', requestUri)
    And header Content-Type = 'text/turtle'
    And header Link = '<http://www.w3.org/ns/ldp#RDFSource>; rel="type"'
    And request '@prefix dc: <http://purl.org/dc/terms/>. <> dc:title "RDF source Interaction Model"@en .'
    When method PUT
    Then status 201

  # Test 4.5 on URL /foo/baz/dahut-rs.ttl
    Given url requestUri
    And configure headers = clients.alice.getAuthHeaders('GET', requestUri)
    When method GET
    Then status 200

  # Test 4.6 on URL /foo
    * def requestUri = testContainer.getUrl() + 'foo/'
    Given url requestUri
    And configure headers = clients.alice.getAuthHeaders('GET', requestUri)
    When method GET
    Then status 200

  Scenario: Test 4.7 on URL /foobar/baz/dahut-no.ttl
    * def requestUri = testContainer.getUrl() + 'foobar/baz/dahut-no.ttl'
    Given url requestUri
    And configure headers = clients.alice.getAuthHeaders('PUT', requestUri)
    And header Content-Type = 'text/turtle'
    And request '@prefix dc: <http://purl.org/dc/terms/>. <> dc:title "No Interaction Model"@en .'
    When method PUT
    Then status 201

  Scenario: Test 4.8 on URL /foobar/baz/dahut-no.ttl
    * def requestUri = testContainer.getUrl() + 'foobar/baz/dahut-no.ttl'
    Given url requestUri
    And configure headers = clients.alice.getAuthHeaders('GET', requestUri)
    When method GET
    Then status 200

  # Test 4.9 on URL /foobar
    * def requestUri = testContainer.getUrl() + 'foobar/'
    Given url requestUri
    And configure headers = clients.alice.getAuthHeaders('GET', requestUri)
    When method GET
    Then status 200
