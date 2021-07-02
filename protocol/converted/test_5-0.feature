@ignore
Feature: Set up initial resources as needed by the rest of the tests
Background: Setup
  * def testContainer = createTestContainer()
  * testContainer.createChildResource('.txt', '', 'text/plain');

# Background: Setup on URL /alice_share_bob.txt
#   * def requestUri = testContainer.getUrl() + 'alice_share_bob.txt'
#   Given url requestUri
#   And configure headers = clients.alice.getAuthHeaders('PUT', requestUri)
#   And header Content-Type = 'text/plain'
#   And request 'protected contents, that Alice gives Bob Read to.'
#   When method PUT
#   Then status 201

# Background: Setup on URL /alice_share_bob.txt.acl
#   * def requestUri = testContainer.getUrl() + 'alice_share_bob.txt.acl'
#   Given url requestUri
#   And configure headers = clients.alice.getAuthHeaders('PUT', requestUri)
#   And header Content-Type = 'text/turtle'
#   And request '@prefix acl: <http://www.w3.org/ns/auth/acl#>. <#owner> a acl:Authorization;   acl:agent <https://alice.idp.test.solidproject.org/profile/card#me>;   acl:accessTo </test-auth-nr/alice_share_bob.txt>; acl:mode acl:Read, acl:Write, acl:Control. <#bob> a acl:Authorization;   acl:agent <https://bobwebid.idp.test.solidproject.org/profile/card#me>;   acl:accessTo </test-auth-nr/alice_share_bob.txt>;   acl:mode acl:Read. '
#   When method PUT
#   Then status 201


