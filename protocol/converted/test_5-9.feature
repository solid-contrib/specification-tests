Feature: Check that Bob can delete Non-RDF resource when he is authorized read-write on the container.

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

  Scenario: Test 9.1 Delete resource allowed
    Given url requestUri
    And headers clients.bob.getAuthHeaders('DELETE', requestUri)
    When method DELETE
    Then assert responseStatus == 200 || responseStatus == 204

