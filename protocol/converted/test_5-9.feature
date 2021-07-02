@ignore
Feature: Check that Bob can delete Non-RDF resource when he is authorized read-write on the container.
Background: Setup
  * def testContainer = createTestContainer()
  * testContainer.createChildResource('.txt', '', 'text/plain');



Scenario: Test 9.1 on URL /alice_share_bob.txt
  * def requestUri = testContainer.getUrl() + 'alice_share_bob.txt'
  Given url requestUri
  And configure headers = clients.alice.getAuthHeaders('DELETE', requestUri)
  When method DELETE
  Then assert responseStatus == 200 || responseStatus == 204

