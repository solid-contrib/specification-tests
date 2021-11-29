Feature: Check that Bob can only read Basic Container when he is authorized read only.

  Background: Setup
    * def testContainer = rootTestContainer.createContainer()
    * def aclBuilder = testContainer.accessDatasetBuilder
    * def access = aclBuilder.setAgentAccess(testContainer.url, webIds.bob, ['read']).build()
    * testContainer.accessDataset = access
    * def requestUri = testContainer.url

  Scenario: Test 1.1 Read container (GET) allowed
    Given url requestUri
    And configure headers = clients.bob.getAuthHeaders('GET', requestUri)
    When method GET
    Then status 200

  Scenario: Test 1.2 Read container (HEAD) allowed
    Given url requestUri
    And configure headers = clients.bob.getAuthHeaders('HEAD', requestUri)
    When method HEAD
    Then status 200

  Scenario: Test 1.3 Read container (OPTIONS) allowed
    Given url requestUri
    And configure headers = clients.bob.getAuthHeaders('OPTIONS', requestUri)
    When method OPTIONS
    Then status 204

  Scenario: Test 1.4 Write to container (PUT) denied
    Given url requestUri
    And configure headers = clients.bob.getAuthHeaders('PUT', requestUri)
    And header Content-Type = 'text/turtle'
    And request '@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>. <> rdfs:comment "Bob replaced it." .     '
    When method PUT
    Then status 403
    # Test 1.5 was a duplicate - was it meant to be PATCH with DELETE?

  Scenario: Test 1.6 Write to container (PATCH) denied
    Given url requestUri
    And configure headers = clients.bob.getAuthHeaders('PATCH', requestUri)
    And header Content-Type = 'application/sparql-update'
    And request 'INSERT DATA { <> a <http://example.org/Foo> . }'
    When method PATCH
    Then status 403

  Scenario: Test 1.7 Append to container (POST) denied
    Given url requestUri
    And configure headers = clients.bob.getAuthHeaders('POST', requestUri)
    And header Content-Type = 'text/turtle'
    And header Slug = 'bobsdata'
    And request '@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>. <> rdfs:comment "Bob added this."     '
    When method POST
    Then status 403

  Scenario: Test 1.8 Delete container denied
    Given url requestUri
    And configure headers = clients.bob.getAuthHeaders('DELETE', requestUri)
    When method DELETE
    Then status 403

#  Scenario: Test 1.9 on URL /
#    * def requestUri = testContainer.url
#    Given url requestUri
#    And configure headers = clients.bob.getAuthHeaders('DAHU', requestUri)
#    When method DAHU
#    Then status 400

