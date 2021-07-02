Feature: Check that Bob can only append to Basic Container when he is authorized append only.

  Background: Setup
    * def testContainer = createTestContainer()
    * testContainer.createChildResource('.txt', '', 'text/plain');
    * def acl =
    """
      aclPrefix
       + createOwnerAuthorization(webIds.alice, testContainer.getPath())
       + createBobAccessToAuthorization(webIds.bob, testContainer.getPath(), 'acl:Append')
    """
    * assert testContainer.setAcl(acl)
    * def requestUri = testContainer.getUrl()

  Scenario: Test 3.1 Read container (GET) denied
    Given url requestUri
    And configure headers = clients.bob.getAuthHeaders('GET', requestUri)
    When method GET
    Then status 403

  Scenario: Test 3.2 Read container (HEAD) denied
    Given url requestUri
    And configure headers = clients.bob.getAuthHeaders('HEAD', requestUri)
    When method HEAD
    Then status 403

  Scenario: Test 3.3 Read container (OPTIONS) allowed
    Given url requestUri
    And configure headers = clients.bob.getAuthHeaders('OPTIONS', requestUri)
    When method OPTIONS
    Then status 204

  Scenario: Test 3.4 Write to container (PUT) denied
    Given url requestUri
    And configure headers = clients.bob.getAuthHeaders('PUT', requestUri)
    And header Content-Type = 'text/turtle'
    And request '@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>. <> rdfs:comment "Bob replaced it." .     '
    When method PUT
    Then status 403

  Scenario: Test 3.5 Write to container (PATCH) allowed
    Given url requestUri
    And configure headers = clients.bob.getAuthHeaders('PATCH', requestUri)
    And header Content-Type = 'application/sparql-update'
    And request 'INSERT DATA { <> a <http://example.org/Foo> . }'
    When method PATCH
    Then status 200

  Scenario: Test 3.6 Write to container (PATCH) with delete denied
    Given url requestUri
    And configure headers = clients.bob.getAuthHeaders('PATCH', requestUri)
    And header Content-Type = 'application/sparql-update'
    And request 'DELETE { ?s a ?o . } INSERT { <> a <http://example.org/Bar> . } WHERE  { ?s a ?o . }'
    When method PATCH
    Then status 403

  Scenario: Test 3.7 Append to container (POST) allowed
    Given url requestUri
    And configure headers = clients.bob.getAuthHeaders('POST', requestUri)
    And header Content-Type = 'text/turtle'
    And header Slug = 'bobsdata'
    And request '@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>. <> rdfs:comment "Bob added this."     '
    When method POST
    Then status 201

  Scenario: Test 3.8 Delete container denied
    Given url requestUri
    And configure headers = clients.bob.getAuthHeaders('DELETE', requestUri)
    When method DELETE
    Then status 403

#  Scenario: Test 3.9 on URL /
#    * def requestUri = testContainer.getUrl() + ''
#    Given url requestUri
#    And configure headers = clients.bob.getAuthHeaders('DAHU', requestUri)
#    When method DAHU
#    Then status 400
