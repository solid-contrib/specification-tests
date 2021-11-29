Feature: Check that Bob can't delete RDF resource when he is only authorized read-write on the container.

  Background: Setup
    * def testContainer = rootTestContainer.reserveContainer()
    * def resource = testContainer.createResource('.ttl', karate.readAsString('../fixtures/example.ttl'), 'text/turtle');
    * def aclBuilder = testContainer.accessDatasetBuilder
    * def access = aclBuilder.setAgentAccess(testContainer.url, webIds.bob, ['read', 'write']).build()
    * testContainer.accessDataset = access
    * def requestUri = resource.url

  Scenario: Test 9.1 Delete resource denied
    Given url requestUri
    And configure headers = clients.bob.getAuthHeaders('DELETE', requestUri)
    When method DELETE
    Then status 403

