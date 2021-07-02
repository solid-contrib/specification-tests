Feature: Update: PUT Turtle resources to container with varying LDP Interaction Models.

  Background: Setup
    * def testContainer = createTestContainer()
    * def resource = testContainer.createChildResource('.ttl', '@prefix dc: <http://purl.org/dc/terms/>. <> dc:title "data"@en .', 'text/turtle');
    * assert resource.exists()
    * def requestUri = resource.getUrl()

  Scenario: Test 3.1 Conflict when updating RDFSource with a NonRDFSource containing RDF
    Given url requestUri
    And configure headers = clients.alice.getAuthHeaders('PUT', requestUri)
    And header Content-Type = 'text/turtle'
    And header Link = '<http://www.w3.org/ns/ldp#NonRDFSource>; rel="type"'
    And request '@prefix dc: <http://purl.org/dc/terms/>. <> dc:title "Updating Non-RDF source Interaction Model"@en .'
    When method PUT
    Then status 409

  Scenario: Test 3.2 Conflict when updating RDFSource with a Container
    Given url requestUri
    And configure headers = clients.alice.getAuthHeaders('PUT', requestUri)
    And header Content-Type = 'text/turtle'
    And header Link = '<http://www.w3.org/ns/ldp#BasicContainer>; rel="type"'
    And request '@prefix dc: <http://purl.org/dc/terms/>. <> dc:title "Container Interaction Model"@en .'
    When method PUT
    Then status 409

  Scenario: Test 3.3 Conflict when updating RDFSource with a NonRDFSource
    Given url requestUri
    And configure headers = clients.alice.getAuthHeaders('PUT', requestUri)
    And header Content-Type = 'text/plain'
    And header Link = '<http://www.w3.org/ns/ldp#NonRDFSource>; rel="type"'
    And request 'Non RDF Interaction Model'
    When method PUT
    Then status 409

  Scenario: Test 3.4 Conflict when updating RDFSource no interaction model
    Given url requestUri
    And configure headers = clients.alice.getAuthHeaders('PUT', requestUri)
    And header Content-Type = 'text/plain'
    And request 'No source Interaction Model'
    When method PUT
    Then status 409

  Scenario: Test 3.5 Update RDFSource with PUT
    Given url requestUri
    And configure headers = clients.alice.getAuthHeaders('PUT', requestUri)
    And header Content-Type = 'text/turtle'
    And header Link = '<http://www.w3.org/ns/ldp#RDFSource>; rel="type"'
    And request '@prefix dc: <http://purl.org/dc/terms/>. <> dc:title "Update RDF source Interaction Model"@en .'
    When method PUT
    Then assert responseStatus == 200 || responseStatus == 204

  Scenario: Test 3.6 Update plain text with Turtle without Interaction model
    * def resource2 = testContainer.createChildResource('.ttl', 'No interaction model', 'text/plain');
    * def requestUri = resource2.getUrl()
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
    # TODO - if we check the headers here will it now have RDFSource interaction model?
