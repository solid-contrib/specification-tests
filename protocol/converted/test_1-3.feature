Feature: Update: PUT Turtle resources to container with varying LDP Interaction Models.

  Background: Setup
    * def testContainer = createTestContainer()
    * def resource = testContainer.createChildResource('.ttl', '@prefix dc: <http://purl.org/dc/terms/>. <> dc:title "data"@en .', 'text/turtle');
    * def requestUri = resource.getUrl()

  Scenario: Test 3.1 on URL /dahut-rs.ttl
    Given url requestUri
    And configure headers = clients.alice.getAuthHeaders('PUT', requestUri)
    And header Content-Type = 'text/turtle'
    And header Link = '<http://www.w3.org/ns/ldp#NonRDFSource>; rel="type"'
    And request '@prefix dc: <http://purl.org/dc/terms/>. <> dc:title "Updating Non-RDF source Interaction Model"@en .'
    When method PUT
    Then status 409

  Scenario: Test 3.2 on URL /dahut-rs.ttl
    Given url requestUri
    And configure headers = clients.alice.getAuthHeaders('PUT', requestUri)
    And header Content-Type = 'text/turtle'
    And header Link = '<http://www.w3.org/ns/ldp#BasicContainer>; rel="type"'
    And request '@prefix dc: <http://purl.org/dc/terms/>. <> dc:title "Container Interaction Model"@en .'
    When method PUT
    Then status 409

  Scenario: Test 3.3 on URL /dahut-rs.ttl
    Given url requestUri
    And configure headers = clients.alice.getAuthHeaders('PUT', requestUri)
    And header Content-Type = 'text/plain'
    And header Link = '<http://www.w3.org/ns/ldp#NonRDFSource>; rel="type"'
    And request 'Non RDF Interaction Model'
    When method PUT
    Then status 409

  Scenario: Test 3.4 on URL /dahut-rs.ttl
    Given url requestUri
    And configure headers = clients.alice.getAuthHeaders('PUT', requestUri)
    And header Content-Type = 'text/plain'
    And request 'No source Interaction Model'
    When method PUT
    Then status 409

  Scenario: Test 3.5 on URL /dahut-rs.ttl
    Given url requestUri
    And configure headers = clients.alice.getAuthHeaders('PUT', requestUri)
    And header Content-Type = 'text/turtle'
    And header Link = '<http://www.w3.org/ns/ldp#RDFSource>; rel="type"'
    And request '@prefix dc: <http://purl.org/dc/terms/>. <> dc:title "Update RDF source Interaction Model"@en .'
    When method PUT
    Then assert responseStatus == 200 || responseStatus == 204

  Scenario: Test 3.6 on URL /dahut-no.ttl
    * testContainer.createChildResource('dahut-no.ttl', 'No interaction model', 'text/plain');
    * def requestUri = testContainer.getUrl() + 'dahut-no.ttl'
    Given url requestUri
    And configure headers = clients.alice.getAuthHeaders('PUT', requestUri)
    And header Content-Type = 'text/turtle'
    And request '@prefix dc: <http://purl.org/dc/terms/>. <> dc:title "Update with no Interaction Model"@en .'
    When method PUT
    Then assert responseStatus == 200 || responseStatus == 204

    Given url requestUri
    And configure headers = clients.alice.getAuthHeaders('GET', requestUri)
    When method GET
    Then status 200
    And response '@prefix dc: <http://purl.org/dc/terms/>. <> dc:title "Update with no Interaction Model"@en .'
