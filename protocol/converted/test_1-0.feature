@ignore
Feature: Set up initial resources as needed by the rest of the tests
Background: Setup
  * def testContainer = createTestContainer()
  * testContainer.createChildResource('.txt', '', 'text/plain');

# Background: Setup on URL /
#   * def requestUri = testContainer.getUrl()
#   Given url requestUri
#   And configure headers = clients.alice.getAuthHeaders('POST', requestUri)
#   And header Content-Type = 'text/turtle'
#   And header Link = '<http://www.w3.org/ns/ldp#BasicContainer>; rel="type"'
#   And header Slug = 'test-put-bc'
#   And request '@prefix dc: <http://purl.org/dc/terms/>. @prefix ldp: <http://www.w3.org/ns/ldp#>. <> a ldp:BasicContainer ;    dc:title "Initial container for Alice stuff"@en .'
#   When method POST
#   Then status 201


