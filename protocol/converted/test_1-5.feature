@ignore
Feature: Delete resources that were set up in these tests


Scenario: Test 5.1 on URL /test-put-bc/dahut-bc.ttl
  * def requestUri = testContainer.getUrl()
  Given url requestUri
  And configure headers = clients.alice.getAuthHeaders('DELETE', requestUri)
  When method DELETE
  Then assert responseStatus == 200 || responseStatus == 204 || responseStatus == 404


Scenario: Test 5.2 on URL /test-put-bc/dahut-nr.ttl
  * def requestUri = testContainer.getUrl()
  Given url requestUri
  And configure headers = clients.alice.getAuthHeaders('DELETE', requestUri)
  When method DELETE
  Then assert responseStatus == 200 || responseStatus == 204 || responseStatus == 404


Scenario: Test 5.3 on URL /test-put-bc/dahut-rs.ttl
  * def requestUri = testContainer.getUrl()
  Given url requestUri
  And configure headers = clients.alice.getAuthHeaders('DELETE', requestUri)
  When method DELETE
  Then assert responseStatus == 200 || responseStatus == 204 || responseStatus == 404


Scenario: Test 5.4 on URL /test-put-bc/dahut-no.ttl
  * def requestUri = testContainer.getUrl()
  Given url requestUri
  And configure headers = clients.alice.getAuthHeaders('DELETE', requestUri)
  When method DELETE
  Then assert responseStatus == 200 || responseStatus == 204 || responseStatus == 404


Scenario: Test 5.5 on URL /test-put-bc/dahut-no-nr.ttl
  * def requestUri = testContainer.getUrl()
  Given url requestUri
  And configure headers = clients.alice.getAuthHeaders('DELETE', requestUri)
  When method DELETE
  Then assert responseStatus == 200 || responseStatus == 204 || responseStatus == 404


Scenario: Test 5.6 on URL /test-put-bc/
  * def requestUri = testContainer.getUrl()
  Given url requestUri
  And configure headers = clients.alice.getAuthHeaders('DELETE', requestUri)
  When method DELETE
  Then assert responseStatus == 200 || responseStatus == 204


Scenario: Test 5.7 on URL /test-put-bc/
  * def requestUri = testContainer.getUrl()
  Given url requestUri
  And configure headers = clients.alice.getAuthHeaders('GET', requestUri)
  When method GET
  Then status 404


