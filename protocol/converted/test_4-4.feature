@ignore
Feature: Modify ACL to add append and read to resources as needed by the rest of the tests
Background: Setup
  * def testContainer = createTestContainer()
  * testContainer.createChildResource('.txt', '', 'text/plain');



Scenario: Test 4.1 on URL /alice_share_bob.ttl.acl
  * def requestUri = testContainer.getUrl() + 'alice_share_bob.ttl.acl'
  Given url requestUri
  And configure headers = clients.alice.getAuthHeaders('PUT', requestUri)
  And header Content-Type = 'text/turtle'
  And request '@prefix acl: <http://www.w3.org/ns/auth/acl#>. <#owner> a acl:Authorization;   acl:agent <https://alice.idp.test.solidproject.org/profile/card#me>;   acl:accessTo </test-auth-rs/alice_share_bob.ttl>;   acl:mode acl:Read, acl:Write, acl:Control. <#bob> a acl:Authorization;   acl:agent <https://bobwebid.idp.test.solidproject.org/profile/card#me>;   acl:accessTo </test-auth-rs/alice_share_bob.ttl>;   acl:mode acl:Read, acl:Append. '
  When method PUT
  Then status 201


