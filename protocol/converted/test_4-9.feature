Feature: Check that Bob can delete RDF resource when he is authorized read-write on the container.

  Background: Setup
    * def testContainer = createTestContainer()
    * def resource = testContainer.createChildResource('.ttl', karate.readAsString('../fixtures/example.ttl'), 'text/turtle');
    * assert resource.exists()
    * def acl =
    """
      aclPrefix
       + createOwnerAuthorization(webIds.alice, testContainer.getPath())
       + createBobAccessToAuthorization(webIds.bob, testContainer.getPath(), 'acl:Read, acl:Write')
    """
    * assert testContainer.setAcl(acl)
    * def requestUri = resource.getUrl()

  Scenario: Test 9.1 on URL /alice_share_bob.ttl
    Given url requestUri
    And configure headers = clients.bob.getAuthHeaders('DELETE', requestUri)
    When method DELETE
    Then assert responseStatus == 200 || responseStatus == 204

