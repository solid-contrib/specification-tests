@ignore
Feature: Check that Bob can only append to Non-RDF resource when he is authorized append only.
Background: Setup
  * def testContainer = createTestContainer()
  * testContainer.createChildResource('.txt', '', 'text/plain');



Scenario: Test 3.1 on URL /alice_share_bob.txt
  * def requestUri = testContainer.getUrl() + 'alice_share_bob.txt'
  Given url requestUri
  And configure headers = clients.alice.getAuthHeaders('GET', requestUri)
  When method GET
  Then status 403



Scenario: Test 3.2 on URL /alice_share_bob.txt
  * def requestUri = testContainer.getUrl() + 'alice_share_bob.txt'
  Given url requestUri
  And configure headers = clients.alice.getAuthHeaders('HEAD', requestUri)
  When method HEAD
  Then status 403



Scenario: Test 3.3 on URL /alice_share_bob.txt
  * def requestUri = testContainer.getUrl() + 'alice_share_bob.txt'
  Given url requestUri
  And configure headers = clients.alice.getAuthHeaders('OPTIONS', requestUri)
  When method OPTIONS
  Then status 204



Scenario: Test 3.4 on URL /alice_share_bob.txt
  * def requestUri = testContainer.getUrl() + 'alice_share_bob.txt'
  Given url requestUri
  And configure headers = clients.alice.getAuthHeaders('PUT', requestUri)
  And header Content-Type = 'text/plain'
  And request 'Bob's replacement'
  When method PUT
  Then status 403



Scenario: Test 3.5 on URL /alice_share_bob.txt
  * def requestUri = testContainer.getUrl() + 'alice_share_bob.txt'
  Given url requestUri
  And configure headers = clients.alice.getAuthHeaders('PATCH', requestUri)
  And header Content-Type = 'text/plain'
  And request '+Bob's patch'
  When method PATCH
  Then status 415



Scenario: Test 3.6 on URL /alice_share_bob.txt
  * def requestUri = testContainer.getUrl() + 'alice_share_bob.txt'
  Given url requestUri
  And configure headers = clients.alice.getAuthHeaders('POST', requestUri)
  And header Content-Type = 'text/plain'
  And request 'Bob's addition'
  When method POST
  Then status 204



Scenario: Test 3.7 on URL /alice_share_bob.txt
  * def requestUri = testContainer.getUrl() + 'alice_share_bob.txt'
  Given url requestUri
  And configure headers = clients.alice.getAuthHeaders('DELETE', requestUri)
  When method DELETE
  Then status 403



Scenario: Test 3.8 on URL /alice_share_bob.txt
  * def requestUri = testContainer.getUrl() + 'alice_share_bob.txt'
  Given url requestUri
  And configure headers = clients.alice.getAuthHeaders('DAHU', requestUri)
  When method DAHU
  Then status 400


