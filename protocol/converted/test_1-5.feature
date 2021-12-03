Feature: Update: PUT text resources to container with no Interaction Model.

  Background: Setup
    * def testContainer = rootTestContainer.reserveContainer()
    * def resource = testContainer.createResource('.ttl', 'just some text', 'text/plain');
    * url resource.url
    * configure headers = clients.alice.getAuthHeaders('PUT', resource.url)

  Scenario: Test 5.1 Update with something that looks like Turtle without Interaction model
    Given header Content-Type = 'text/plain'
    And request '@prefix dc: <http://purl.org/dc/terms/>. <> dc:title "Update with no Interaction Model"@en .'
    When method PUT
    Then match [200, 201, 204, 205] contains responseStatus

  Scenario: Test 5.2 Update with real Turtle without Interaction model
    Given header Content-Type = 'text/turtle'
    And request '@prefix dc: <http://purl.org/dc/terms/>. <> dc:title "Update with no Interaction Model"@en .'
    When method PUT
    Then status 409

  Scenario: Test 5.3 Update with real Turtle with RDF Source Interaction model
    Given header Content-Type = 'text/turtle'
    And header Link = '<http://www.w3.org/ns/ldp#RDFSource>; rel="type"'
    And request '@prefix dc: <http://purl.org/dc/terms/>. <> dc:title "Update with RDF Source"@en .'
    When method PUT
    Then status 409

  Scenario: Test 5.4 Update with text looking like Turtle with RDF Source Interaction model
    Given header Content-Type = 'text/plain'
    And header Link = '<http://www.w3.org/ns/ldp#RDFSource>; rel="type"'
    And request '@prefix dc: <http://purl.org/dc/terms/>. <> dc:title "Update with RDF Source"@en .'
    When method PUT
    Then status 409



