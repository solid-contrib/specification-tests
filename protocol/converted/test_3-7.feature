Feature: Check that Bob can read and write to Basic Container when he is authorized read-write.

  Background: Setup
    * def testContainer = createTestContainerImmediate()
    * def aclBuilder = testContainer.getAccessDatasetBuilder(webIds.alice)
    * def access = aclBuilder.setAgentAccess(testContainer.getUrl(), webIds.bob, ['read', 'write']).build()
    * print 'ACL:\n' + access.asTurtle()
    * assert testContainer.setAccessDataset(access)
    * def requestUri = testContainer.getUrl()

  Scenario: Test 7.1 Read container (GET) allowed
    Given url requestUri
    And configure headers = clients.bob.getAuthHeaders('GET', requestUri)
    When method GET
    Then status 200

  Scenario: Test 7.2 Read container (HEAD) allowed
    Given url requestUri
    And configure headers = clients.bob.getAuthHeaders('HEAD', requestUri)
    When method HEAD
    Then status 200

#  Scenario: Test 7.3 Read container (OPTIONS) allowed
#    Given url requestUri
#    And configure headers = clients.bob.getAuthHeaders('OPTIONS', requestUri)
#    When method OPTIONS
#    Then status 204

  Scenario: Test 7.4 Write to container (PUT) allowed
    Given url requestUri
    And configure headers = clients.bob.getAuthHeaders('PUT', requestUri)
    And header Content-Type = 'text/turtle'
    And request '@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>. <> rdfs:comment "Bob replaced it." .     '
    When method PUT
    Then assert responseStatus == 200 || responseStatus == 204

  Scenario: Test 7.5 Write to container (PATCH) allowed
    Given url requestUri
    And configure headers = clients.bob.getAuthHeaders('PATCH', requestUri)
    And header Content-Type = 'application/sparql-update'
    And request 'INSERT DATA { <> a <http://example.org/Foo> . }'
    When method PATCH
    Then match [200, 204, 205] contains responseStatus

  Scenario: Test 7.6 Write to container (PATCH) with delete allowed
    Given url requestUri
    And configure headers = clients.bob.getAuthHeaders('PATCH', requestUri)
    And header Content-Type = 'application/sparql-update'
    And request 'DELETE { ?s a ?o . } INSERT { <> a <http://example.org/Bar> . } WHERE  { ?s a ?o . }'
    When method PATCH
    Then match [200, 204, 205] contains responseStatus

  Scenario: Test 7.7 Append to container (POST) allowed
    Given url requestUri
    And configure headers = clients.bob.getAuthHeaders('POST', requestUri)
    And header Content-Type = 'text/turtle'
    And header Slug = 'bobsdata'
    And request '@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>. <> rdfs:comment "Bob added this."     '
    When method POST
    Then match [200, 201, 204, 205] contains responseStatus

#  Scenario: Test 7.8 on URL /
##    Given url requestUri
#    And configure headers = clients.bob.getAuthHeaders('DAHU', requestUri)
#    When method DAHU
#    Then status 400

  Scenario: Test 7.9 Delete container denied
    Given url requestUri
    And configure headers = clients.bob.getAuthHeaders('DELETE', requestUri)
    When method DELETE
    Then status 403
