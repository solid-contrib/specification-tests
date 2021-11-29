Feature: Check that Bob can only append to Non-RDF resource when he is authorized append only.

  Background: Setup
    * def testContainer = rootTestContainer.reserveContainer()
    * def resource = testContainer.createResource('.txt', 'protected contents, that Alice gives Bob Append to.', 'text/plain');
    * def aclBuilder = resource.accessDatasetBuilder
    * def access = aclBuilder.setAgentAccess(resource.url, webIds.bob, ['append']).build()
    * resource.accessDataset = access
    * def requestUri = resource.url

  Scenario: Test 3.1 Read resource (GET) denied
    Given url requestUri
    And configure headers = clients.bob.getAuthHeaders('GET', requestUri)
    When method GET
    Then status 403

  Scenario: Test 3.2 Read resource (HEAD) denied
    Given url requestUri
    And configure headers = clients.bob.getAuthHeaders('HEAD', requestUri)
    When method HEAD
    Then status 403

#  Scenario: Test 3.3 Read resource (OPTIONS) allowed
#    Given url requestUri
#    And configure headers = clients.bob.getAuthHeaders('OPTIONS', requestUri)
#    When method OPTIONS
#    Then status 204

  Scenario: Test 3.4 Write resource (PUT) denied
    Given url requestUri
    And configure headers = clients.bob.getAuthHeaders('PUT', requestUri)
    And header Content-Type = 'text/plain'
    And request "Bob's replacement"
    When method PUT
    Then status 403

  Scenario: Test 3.5 Write resource (PATCH) denied
    Given url requestUri
    And configure headers = clients.bob.getAuthHeaders('PATCH', requestUri)
    And header Content-Type = 'text/plain'
    And request "+Bob's patch"
    When method PATCH
    Then match [400, 403, 405, 415] contains responseStatus

  # Scenario: Test 3.6 Append resource (POST) allowed
  #   Given url requestUri
  #   And configure headers = clients.bob.getAuthHeaders('POST', requestUri)
  #   And header Content-Type = 'text/plain'
  #   And request "Bob's addition"
  #   When method POST
  #   Then match [400, 405, 415] contains responseStatus

  Scenario: Test 3.7 Delete resource denied
    Given url requestUri
    And configure headers = clients.bob.getAuthHeaders('DELETE', requestUri)
    When method DELETE
    Then status 403

#Scenario: Test 3.8 on URL /alice_share_bob.txt
#  Given url requestUri
#  And configure headers = clients.bob.getAuthHeaders('DAHU', requestUri)
#  When method DAHU
#  Then status 400
