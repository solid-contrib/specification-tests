Feature: The WAC-Allow header is advertised

Scenario: Alice calls GET and gets the header
  Given url rootTestContainer.url
  And headers clients.alice.getAuthHeaders('GET', rootTestContainer.url)
  When method GET
  Then status 200
  And match header WAC-Allow != null

Scenario: Alice calls HEAD and gets the header
  Given url rootTestContainer.url
  And headers clients.alice.getAuthHeaders('HEAD', rootTestContainer.url)
  When method HEAD
  Then status 200
  And match header WAC-Allow != null