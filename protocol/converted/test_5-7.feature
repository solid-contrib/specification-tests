Feature: Check that Bob can read and write to Non-RDF resource when he is authorized read-write.

  Background: Setup
    * def testContainer = rootTestContainer.reserveContainer()
    * def resource = testContainer.createResource('.txt', 'protected contents, that Alice gives Bob Read/Write to.', 'text/plain');
    * def aclBuilder = resource.accessDatasetBuilder
    * def access = aclBuilder.setAgentAccess(resource.url, webIds.bob, ['read', 'write']).build()
    * resource.accessDataset = access
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
    And header Content-Type = 'text/plain'
    And request "Bob's replacement"
    When method PUT
    Then match [200, 201, 204, 205] contains responseStatus

  Scenario: Test 7.5 Write resource (PATCH) denied
    Given url requestUri
    And headers clients.bob.getAuthHeaders('PATCH', requestUri)
    And header Content-Type = 'text/plain'
    And request "+Bob's patch"
    When method PATCH
    Then status 415

  # Scenario: Test 7.6 Append resource (POST) allowed
  #   Given url requestUri
  #   And headers clients.bob.getAuthHeaders('POST', requestUri)
  #   And header Content-Type = 'text/plain'
  #   And request "Bob's addition"
  #   When method POST
  #   Then match [400, 405, 415] contains responseStatus

#  Scenario: Test 7.7 on URL /alice_share_bob.txt
#    Given url requestUri
#    And headers clients.bob.getAuthHeaders('DAHU', requestUri)
#    When method DAHU
#    Then status 400

  Scenario: Test 7.8 Delete resource denied
    Given url requestUri
    And headers clients.bob.getAuthHeaders('DELETE', requestUri)
    When method DELETE
    Then status 403
