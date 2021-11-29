Feature: Check that Bob can read and write to RDF resource when he is authorized read-write.

  Background: Setup
    * def testContainer = rootTestContainer.reserveContainer()
    * def resource = testContainer.createResource('.ttl', karate.readAsString('../fixtures/example.ttl'), 'text/turtle');
    * def aclBuilder = resource.accessDatasetBuilder
    * def access = aclBuilder.setAgentAccess(resource.url, webIds.bob, ['read', 'write']).build()
    * resource.accessDataset = access;
    * def requestUri = resource.url

  Scenario: Test 7.1 Read resource (GET) allowed
    Given url requestUri
    And headers clients.bob.getAuthHeaders('GET', requestUri)
    When method GET
    Then status 200

  Scenario: Test 7.2 Read resource (HEAD) allowed
    Given url requestUri
    And headers clients.bob.getAuthHeaders('HEAD', requestUri)
    When method HEAD
    Then status 200

  Scenario: Test 7.3 Read resource (OPTIONS) allowed
    Given url requestUri
    And headers clients.bob.getAuthHeaders('OPTIONS', requestUri)
    When method OPTIONS
    Then status 204

  Scenario: Test 7.4 Write resource (PUT) allowed
    Given url requestUri
    And headers clients.bob.getAuthHeaders('PUT', requestUri)
    And header Content-Type = 'text/turtle'
    And request '@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>. <> rdfs:comment "Bob replaced it." .     '
    When method PUT
    Then match [200, 201, 204, 205] contains responseStatus

  Scenario: Test 7.5 Write resource (PATCH) allowed
    Given url requestUri
    And headers clients.bob.getAuthHeaders('PATCH', requestUri)
    And header Content-Type = 'application/sparql-update'
    And request 'INSERT DATA { <> a <http://example.org/Foo> . }'
    When method PATCH
    Then match [200, 204, 205] contains responseStatus

  Scenario: Test 7.6 Write resource (PATCH) with delete allowed
    Given url requestUri
    And headers clients.bob.getAuthHeaders('PATCH', requestUri)
    And header Content-Type = 'application/sparql-update'
    And request 'DELETE { ?s a ?o . } INSERT { <> a <http://example.org/Bar> . } WHERE  { ?s a ?o . }'
    When method PATCH
    Then match [200, 204, 205] contains responseStatus


  # Scenario: Test 7.7 Append resource (POST) allowed
  #   Given url requestUri
  #   And headers clients.bob.getAuthHeaders('POST', requestUri)
  #   And header Content-Type = 'text/turtle'
  #   And request '@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>. <> rdfs:comment "Bob added this."     '
  #   When method POST
  #   Then match [400, 405, 415] contains responseStatus

#  Scenario: Test 7.8 on URL /alice_share_bob.ttl
##    Given url requestUri
#    And headers clients.bob.getAuthHeaders('DAHU', requestUri)
#    When method DAHU
#    Then status 400

  Scenario: Test 7.9 Delete resource denied
    Given url requestUri
    And headers clients.bob.getAuthHeaders('DELETE', requestUri)
    When method DELETE
    Then status 403
