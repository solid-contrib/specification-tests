@ignore
Feature: Delete resources that were set up in these tests
Background: Setup
  * def testContainer = createTestContainer()
  * testContainer.createChildResource('.txt', '', 'text/plain');



Scenario: Test 10.1 on URL /alice_share_bob.txt.acl
  * def requestUri = testContainer.getUrl() + 'alice_share_bob.txt.acl'
  Given url requestUri
  And configure headers = clients.alice.getAuthHeaders('DELETE', requestUri)
  When method DELETE
  Then assert responseStatus == 200 || responseStatus == 204


Scenario: Test 10.2 on URL /
  * def requestUri = testContainer.getUrl() + ''
  Given url requestUri
  And configure headers = clients.alice.getAuthHeaders('DELETE', requestUri)
  When method DELETE
  Then assert responseStatus == 200 || responseStatus == 204


Scenario: Test 10.3 on URL /
  * def requestUri = testContainer.getUrl() + ''
  Given url requestUri
  And configure headers = clients.alice.getAuthHeaders('GET', requestUri)
  When method GET
  Then status 404


