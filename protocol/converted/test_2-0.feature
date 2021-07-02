@ignore
Feature: Set up initial resources as needed by the rest of the tests
Background: Setup
  * def testContainer = createTestContainer()
  * testContainer.createChildResource('.txt', '', 'text/plain');

# Background: Setup on URL /
#   * def requestUri = testContainer.getUrl() + ''
#   Given url requestUri
#   And configure headers = clients.alice.getAuthHeaders('', requestUri)
#   When method 
#   Then status 201
