Feature: Check that Bob can read and append to Non-RDF resource when he is authorized read-append.

  Background: Setup
    * def testContainer = createTestContainer()
    * def resource = testContainer.createChildResource('.txt', 'protected contents, that Alice gives Bob Read/Append to.', 'text/plain');
    * assert resource.exists()
    * def acl =
    """
      aclPrefix
       + createOwnerAuthorization(webIds.alice, resource.getPath())
       + createBobAccessToAuthorization(webIds.bob, resource.getPath(), 'acl:Read, acl:Append')
    """
    * assert resource.setAcl(acl)
    * def requestUri = resource.getUrl()

  Scenario: Test 5.1 Read resource (GET) allowed
    Given url requestUri
    And configure headers = clients.bob.getAuthHeaders('GET', requestUri)
    When method GET
    Then status 200

  Scenario: Test 5.2 Read resource (HEAD) allowed
    Given url requestUri
    And configure headers = clients.bob.getAuthHeaders('HEAD', requestUri)
    When method HEAD
    Then status 200

  Scenario: Test 5.3 Read resource (OPTIONS) allowed
    Given url requestUri
    And configure headers = clients.bob.getAuthHeaders('OPTIONS', requestUri)
    When method OPTIONS
    Then status 204

  Scenario: Test 5.4 Write resource (PUT) denied
    Given url requestUri
    And configure headers = clients.bob.getAuthHeaders('PUT', requestUri)
    And header Content-Type = 'text/plain'
    And request "Bob's replacement"
    When method PUT
    Then status 403

  Scenario: Test 5.5 Write resource (PATCH) denied
    Given url requestUri
    And configure headers = clients.bob.getAuthHeaders('PATCH', requestUri)
    And header Content-Type = 'text/plain'
    And request "+Bob's patch"
    When method PATCH
    Then status 415

  Scenario: Test 5.6 Write resource (POST) allowed
    Given url requestUri
    And configure headers = clients.bob.getAuthHeaders('POST', requestUri)
    And header Content-Type = 'text/plain'
    And request "Bob's addition"
    When method POST
    Then status 204

  Scenario: Test 5.7 Delete resource denied
    Given url requestUri
    And configure headers = clients.bob.getAuthHeaders('DELETE', requestUri)
    When method DELETE
    Then status 403

#  Scenario: Test 5.8 on URL /alice_share_bob.txt
#    Given url requestUri
#    And configure headers = clients.bob.getAuthHeaders('DAHU', requestUri)
#    When method DAHU
#    Then status 400
