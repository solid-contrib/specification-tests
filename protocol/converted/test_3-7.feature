Feature: Check that Bob can read and write to Basic Container when he is authorized read-write.

  Background: Setup
    * def testContainer = createTestContainer()
    * testContainer.createChildResource('.txt', '', 'text/plain');
    * def acl =
    """
      aclPrefix
       + createOwnerAuthorization(webIds.alice, testContainer.getPath())
       + createBobAccessToAuthorization(webIds.bob, testContainer.getPath(), 'acl:Read, acl:Write')
    """
    * assert testContainer.setAcl(acl)

  Scenario: Test 7.1 on URL /
    * def requestUri = testContainer.getUrl() + ''
    Given url requestUri
    And configure headers = clients.bob.getAuthHeaders('GET', requestUri)
    When method GET
    Then status 200

  Scenario: Test 7.2 on URL /
    * def requestUri = testContainer.getUrl() + ''
    Given url requestUri
    And configure headers = clients.bob.getAuthHeaders('HEAD', requestUri)
    When method HEAD
    Then status 200

  Scenario: Test 7.3 on URL /
    * def requestUri = testContainer.getUrl() + ''
    Given url requestUri
    And configure headers = clients.bob.getAuthHeaders('OPTIONS', requestUri)
    When method OPTIONS
    Then status 204

  Scenario: Test 7.4 on URL /
    * def requestUri = testContainer.getUrl() + ''
    Given url requestUri
    And configure headers = clients.bob.getAuthHeaders('PUT', requestUri)
    And header Content-Type = 'text/turtle'
    And request '@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>. <> rdfs:comment "Bob replaced it." .     '
    When method PUT
    Then assert responseStatus == 200 || responseStatus == 204

  Scenario: Test 7.5 on URL /
    * def requestUri = testContainer.getUrl() + ''
    Given url requestUri
    And configure headers = clients.bob.getAuthHeaders('PATCH', requestUri)
    And header Content-Type = 'application/sparql-update'
    And request 'INSERT DATA { <> a <http://example.org/Foo> . }'
    When method PATCH
    Then status 200

  Scenario: Test 7.6 on URL /
    * def requestUri = testContainer.getUrl() + ''
    Given url requestUri
    And configure headers = clients.bob.getAuthHeaders('PATCH', requestUri)
    And header Content-Type = 'application/sparql-update'
    And request 'DELETE { ?s a ?o . } INSERT { <> a <http://example.org/Bar> . } WHERE  { ?s a ?o . }'
    When method PATCH
    Then status 200

  Scenario: Test 7.7 on URL /
    * def requestUri = testContainer.getUrl() + ''
    Given url requestUri
    And configure headers = clients.bob.getAuthHeaders('POST', requestUri)
    And header Content-Type = 'text/turtle'
    And header Slug = 'bobsdata'
    And request '@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>. <> rdfs:comment "Bob added this."     '
    When method POST
    Then status 201

#  Scenario: Test 7.8 on URL /
#    * def requestUri = testContainer.getUrl() + ''
#    Given url requestUri
#    And configure headers = clients.bob.getAuthHeaders('DAHU', requestUri)
#    When method DAHU
#    Then status 400

  Scenario: Test 7.9 on URL /
    * def requestUri = testContainer.getUrl() + ''
    Given url requestUri
    And configure headers = clients.bob.getAuthHeaders('DELETE', requestUri)
    When method DELETE
    Then status 403
