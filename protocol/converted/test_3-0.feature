@ignore
Feature: Set up initial resources as needed by the rest of the tests
Background: Setup
  * def testContainer = createTestContainer()
  * testContainer.createChildResource('.txt', '', 'text/plain');

# Background: Setup on URL /
#   * def requestUri = testContainer.getUrl() + ''
#   Given url requestUri
#   And configure headers = clients.alice.getAuthHeaders('POST', requestUri)
#   And header Content-Type = 'text/turtle'
#   And header Link = '<http://www.w3.org/ns/ldp#BasicContainer>; rel="type"'
#   And header Slug = 'test-auth-bc'
#   And request '@prefix dc: <http://purl.org/dc/terms/>. @prefix ldp: <http://www.w3.org/ns/ldp#>. <> a ldp:BasicContainer ;    dc:title "Initial container for Bobs stuff"@en .'
#   When method POST
#   Then status 201

# Background: Setup on URL /.acl
#   * def requestUri = testContainer.getUrl() + '.acl'
#   Given url requestUri
#   And configure headers = clients.alice.getAuthHeaders('PUT', requestUri)
#   And header Content-Type = 'text/turtle'
#   And request '@prefix acl: <http://www.w3.org/ns/auth/acl#>. <#owner> a acl:Authorization;   acl:agent <https://alice.idp.test.solidproject.org/profile/card#me>;   acl:accessTo </test-auth-bc/>;   acl:mode acl:Read, acl:Write, acl:Control. <#bob> a acl:Authorization;   acl:agent <https://bobwebid.idp.test.solidproject.org/profile/card#me>;   acl:accessTo </test-auth-bc/>;   acl:mode acl:Read. '
#   When method PUT
#   Then status 201


