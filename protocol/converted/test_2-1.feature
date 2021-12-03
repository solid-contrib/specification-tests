Feature: Create containers

  Background: Setup
    * def testContainer = rootTestContainer.reserveContainer()

  Scenario: Test 1.1 Create container: /
    * def requestUri = testContainer.url
    Given url requestUri
    And headers clients.alice.getAuthHeaders('PUT', requestUri)
    And header Content-Type = 'text/turtle'
    And header Link = '<http://www.w3.org/ns/ldp#BasicContainer>; rel="type"'
    And request '@prefix dc: <http://purl.org/dc/terms/>. <> dc:title "Container Interaction Model"@en .'
    When method PUT
    Then match [200, 201, 204, 205] contains responseStatus

  Scenario: Test 1.2 Create container with no interaction model
    * def requestUri = testContainer.url + 'no-interaction/'
    Given url requestUri
    And headers clients.alice.getAuthHeaders('PUT', requestUri)
    And header Content-Type = 'text/turtle'
    And request '@prefix dc: <http://purl.org/dc/terms/>. <> dc:title "No Interaction Model"@en .'
    When method PUT
    Then match [200, 201, 204, 205] contains responseStatus

    # Test 1.5 Create container with no interaction model if doesn't exist
    Given url requestUri
    And headers clients.alice.getAuthHeaders('PUT', requestUri)
    And header If-None-Match = '*'
    And header Content-Type = 'text/turtle'
    And request '@prefix dc: <http://purl.org/dc/terms/>. <> dc:title "No Interaction Model, but if-none-match"@en .'
    When method PUT
    Then status 412

  Scenario: Test 1.3 Create container as RDFSource but no BasicContainer
    * def requestUri = testContainer.url + 'rs-interaction/'
    Given url requestUri
    And headers clients.alice.getAuthHeaders('PUT', requestUri)
    And header Content-Type = 'text/turtle'
    And header Link = '<http://www.w3.org/ns/ldp#RDFSource>; rel="type"'
    And request '@prefix dc: <http://purl.org/dc/terms/>. <> dc:title "RDF Source Interaction Model"@en .'
    When method PUT
    Then match [200, 201, 204, 205] contains responseStatus

  Scenario: Test 1.4 Create container as NonRDFSource but no BasicContainer
    * def requestUri = testContainer.url + 'nr-interaction/'
    Given url requestUri
    And headers clients.alice.getAuthHeaders('PUT', requestUri)
    And header Content-Type = 'text/turtle'
    And header Link = '<http://www.w3.org/ns/ldp#NonRDFSource>; rel="type"'
    And request '@prefix dc: <http://purl.org/dc/terms/>. <> dc:title "Non-RDF Source Interaction Model"@en .'
    When method PUT
    Then status 409

  Scenario: Test 1.6 Create empty container with no interaction model, no content-type
    * def requestUri = testContainer.url + 'empty-container/'
    Given url requestUri
    And headers clients.alice.getAuthHeaders('PUT', requestUri)
    When method PUT
    Then status 400

  Scenario: Test 1.7 Create empty container with no interaction model
    * def requestUri = testContainer.url + 'empty-container/'
    Given url requestUri
    And headers clients.alice.getAuthHeaders('PUT', requestUri)
    And header Content-Type = 'text/turtle'
    When method PUT
    Then match [200, 201, 204, 205] contains responseStatus
