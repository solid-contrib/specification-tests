@ignore
Feature: Delete resources that were set up in these tests
Background: Setup
  * def testContainer = createTestContainer()
  * testContainer.createChildResource('.txt', '', 'text/plain');



Scenario: Test 5.1 on URL /dahut-bc.ttl
  * def requestUri = testContainer.getUrl() + 'dahut-bc.ttl'
  Given url requestUri
  And configure headers = clients.alice.getAuthHeaders('DELETE', requestUri)
  When method DELETE
  Then assert responseStatus == 200 || responseStatus == 204 || responseStatus == 404


Scenario: Test 5.2 on URL /dahut-nr.ttl
  * def requestUri = testContainer.getUrl() + 'dahut-nr.ttl'
  Given url requestUri
  And configure headers = clients.alice.getAuthHeaders('DELETE', requestUri)
  When method DELETE
  Then assert responseStatus == 200 || responseStatus == 204 || responseStatus == 404


Scenario: Test 5.3 on URL /dahut-rs.ttl
  * def requestUri = testContainer.getUrl() + 'dahut-rs.ttl'
  Given url requestUri
  And configure headers = clients.alice.getAuthHeaders('DELETE', requestUri)
  When method DELETE
  Then assert responseStatus == 200 || responseStatus == 204 || responseStatus == 404


Scenario: Test 5.4 on URL /dahut-no.ttl
  * def requestUri = testContainer.getUrl() + 'dahut-no.ttl'
  Given url requestUri
  And configure headers = clients.alice.getAuthHeaders('DELETE', requestUri)
  When method DELETE
  Then assert responseStatus == 200 || responseStatus == 204 || responseStatus == 404


Scenario: Test 5.5 on URL /dahut-no-nr.ttl
  * def requestUri = testContainer.getUrl() + 'dahut-no-nr.ttl'
  Given url requestUri
  And configure headers = clients.alice.getAuthHeaders('DELETE', requestUri)
  When method DELETE
  Then assert responseStatus == 200 || responseStatus == 204 || responseStatus == 404


Scenario: Test 5.6 on URL /
  * def requestUri = testContainer.getUrl() + ''
  Given url requestUri
  And configure headers = clients.alice.getAuthHeaders('DELETE', requestUri)
  When method DELETE
  Then assert responseStatus == 200 || responseStatus == 204


Scenario: Test 5.7 on URL /
  * def requestUri = testContainer.getUrl() + ''
  Given url requestUri
  And configure headers = clients.alice.getAuthHeaders('GET', requestUri)
  When method GET
  Then status 404


