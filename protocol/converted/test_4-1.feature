Feature: Check that Bob can only read RDF resource when he is authorized read only.

  Background: Setup
    * def testContainer = createTestContainer()
    * def resource = testContainer.createChildResource('.ttl', karate.readAsString('../fixtures/example.ttl'), 'text/turtle');
    * assert resource.exists()
    * def acl =
    """
      aclPrefix
       + createOwnerAuthorization(webIds.alice, resource.getPath())
       + createBobAccessToAuthorization(webIds.bob, resource.getPath(), 'acl:Read')
    """
    * assert resource.setAcl(acl)
    * def requestUri = resource.getUrl()

  Scenario: Test 1.1 on URL /alice_share_bob.ttl
    Given url requestUri
    And configure headers = clients.bob.getAuthHeaders('GET', requestUri)
    When method GET
    Then status 200

  Scenario: Test 1.2 on URL /alice_share_bob.ttl
    Given url requestUri
    And configure headers = clients.bob.getAuthHeaders('HEAD', requestUri)
    When method HEAD
    Then status 200

  Scenario: Test 1.3 on URL /alice_share_bob.ttl
    Given url requestUri
    And configure headers = clients.bob.getAuthHeaders('OPTIONS', requestUri)
    When method OPTIONS
    Then status 204

  Scenario: Test 1.4 on URL /alice_share_bob.ttl
    Given url requestUri
    And configure headers = clients.bob.getAuthHeaders('PUT', requestUri)
    And header Content-Type = 'text/turtle'
    And request '@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>. <> rdfs:comment "Bob replaced it." .     '
    When method PUT
    Then status 403

  Scenario: Test 1.5 on URL /alice_share_bob.ttl
    Given url requestUri
    And configure headers = clients.bob.getAuthHeaders('PATCH', requestUri)
    And header Content-Type = 'application/sparql-update'
    And request 'INSERT DATA { <> a <http://example.org/Foo> . }'
    When method PATCH
    Then status 403

  Scenario: Test 1.6 on URL /alice_share_bob.ttl
    Given url requestUri
    And configure headers = clients.bob.getAuthHeaders('PATCH', requestUri)
    And header Content-Type = 'application/sparql-update'
    And request 'INSERT DATA { <> a <http://example.org/Foo> . }'
    When method PATCH
    Then status 403

  Scenario: Test 1.7 on URL /alice_share_bob.ttl
    Given url requestUri
    And configure headers = clients.bob.getAuthHeaders('POST', requestUri)
    And header Content-Type = 'text/turtle'
    And request '@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>. <> rdfs:comment "Bob added this."     '
    When method POST
    Then status 403

  Scenario: Test 1.8 on URL /alice_share_bob.ttl
    Given url requestUri
    And configure headers = clients.bob.getAuthHeaders('DELETE', requestUri)
    When method DELETE
    Then status 403

#Scenario: Test 1.9 on URL /alice_share_bob.ttl
#  Given url requestUri
#  And configure headers = clients.bob.getAuthHeaders('DAHU', requestUri)
#  When method DAHU
#  Then status 400
