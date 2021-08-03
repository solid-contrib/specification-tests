Feature: Check that Bob cannot delete Non-RDF resource when he is only authorized read-write on the container.

  Background: Setup
    * def testContainer = createTestContainer()
    * def resource = testContainer.createChildResource('.txt', 'protected contents, where Alice gives Bob Read/Write to container.', 'text/plain');
    * assert resource.exists()
    * def acl =
    """
      aclPrefix
       + createOwnerAuthorization(webIds.alice, testContainer.getUrl())
       + createBobAccessToAuthorization(webIds.bob, testContainer.getUrl(), 'acl:Read, acl:Write')
    """
    * assert testContainer.setAccessDataset(acl)
    * def requestUri = resource.getUrl()

  Scenario: Test 9.1 Delete resource denied
    Given url requestUri
    And headers clients.bob.getAuthHeaders('DELETE', requestUri)
    When method DELETE
    Then status 403

