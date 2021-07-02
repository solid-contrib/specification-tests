Feature: Check that Bob can only read Non-RDF resource when he is authorized read only.

  Background: Setup
    * def testContainer = createTestContainer()
    * def resource = testContainer.createChildResource('.ttl', 'protected contents, that Alice gives Bob Read to.', 'text/plain');
    * assert resource.exists()
    * def acl =
    """
      aclPrefix
       + createOwnerAuthorization(webIds.alice, resource.getPath())
       + createBobAccessToAuthorization(webIds.bob, resource.getPath(), 'acl:Read')
    """
    * assert resource.setAcl(acl)
    * def requestUri = resource.getUrl()

  Scenario: Test 1.1 on URL /alice_share_bob.txt
    Given url requestUri
    And configure headers = clients.bob.getAuthHeaders('GET', requestUri)
    When method GET
    Then status 200

  Scenario: Test 1.2 on URL /alice_share_bob.txt
    Given url requestUri
    And configure headers = clients.bob.getAuthHeaders('HEAD', requestUri)
    When method HEAD
    Then status 200

  Scenario: Test 1.3 on URL /alice_share_bob.txt
    Given url requestUri
    And configure headers = clients.bob.getAuthHeaders('OPTIONS', requestUri)
    When method OPTIONS
    Then status 204

  Scenario: Test 1.4 on URL /alice_share_bob.txt
    Given url requestUri
    And configure headers = clients.bob.getAuthHeaders('PUT', requestUri)
    And header Content-Type = 'text/plain'
    And request 'Bob's replacement'
    When method PUT
    Then status 403

  Scenario: Test 1.5 on URL /alice_share_bob.txt
    Given url requestUri
    And configure headers = clients.bob.getAuthHeaders('PATCH', requestUri)
    And header Content-Type = 'text/plain'
    And request '+Bob's patch'
    When method PATCH
    Then status 403

  Scenario: Test 1.6 on URL /alice_share_bob.txt
    Given url requestUri
    And configure headers = clients.bob.getAuthHeaders('POST', requestUri)
    And header Content-Type = 'text/plain'
    And request 'Bob's addition'
    When method POST
    Then status 403

  Scenario: Test 1.7 on URL /alice_share_bob.txt
    Given url requestUri
    And configure headers = clients.bob.getAuthHeaders('DELETE', requestUri)
    When method DELETE
    Then status 403

#Scenario: Test 1.8 on URL /alice_share_bob.txt
#  Given url requestUri
#  And configure headers = clients.bob.getAuthHeaders('DAHU', requestUri)
#  When method DAHU
#  Then status 400

