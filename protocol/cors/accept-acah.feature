# This only applies to pre-flight checks since that is where Access-Control-Allow-Headers is used
Feature: Server should explicitly list Accept under Access-Control-Allow-Headers

  Background: Set up test container
    * def testContainer = rootTestContainer.createContainer()
    * def resource = testContainer.createResource('.txt', 'Hello', 'text/plain')

  Scenario: OPTIONS request doesn't return Accept in Access-Control-Allow-Headers for GET pre-flight if not requested
    Given url testContainer.url
    And headers clients.alice.getAuthHeaders('OPTIONS', testContainer.url)
    And header Origin = 'https://tester'
    And header Access-Control-Request-Method = 'GET'
    And header Access-Control-Request-Headers = 'X-CUSTOM, Content-Type'
    When method OPTIONS
    Then match [200, 204] contains responseStatus
    And match response == ''
    And match header Access-Control-Allow-Headers !contains 'Accept'

  Scenario: OPTIONS request returns Accept in Access-Control-Allow-Headers for POST pre-flight
    Given url testContainer.url
    And headers clients.alice.getAuthHeaders('OPTIONS', testContainer.url)
    And header Origin = 'https://tester'
    And header Access-Control-Request-Method = 'POST'
    And header Access-Control-Request-Headers = 'X-CUSTOM, Content-Type, Accept'
    When method OPTIONS
    Then match [200, 204] contains responseStatus
    And match response == ''
    And match header Access-Control-Allow-Headers contains 'Accept'

  Scenario: OPTIONS request returns Accept in Access-Control-Allow-Headers for GET pre-flight with long Accept
    Given url testContainer.url
    And headers clients.alice.getAuthHeaders('OPTIONS', testContainer.url)
    And header Origin = 'https://tester'
    And header Access-Control-Request-Method = 'GET'
    And header Access-Control-Request-Headers = 'X-CUSTOM, Content-Type, Accept'
    # The following header is irrelevant
    And header Accept = 'text/turtle;q=0.8, application/rdf+xml;q=0.8, application/n-triples;q=0.8, application/n-quads;q=0.8, text/x-nquads;q=0.8, application/trig;q=0.8, text/n3;q=0.8, application/ld+json;q=0.8, application/x-binary-rdf;q=0.8, text/plain;q=0.7'
    When method OPTIONS
    Then match [200, 204] contains responseStatus
    And match response == ''
    And match header Access-Control-Allow-Headers contains 'Accept'

    Given url testContainer.url
    And headers clients.alice.getAuthHeaders('GET', testContainer.url)
    And header Accept = 'text/turtle;q=0.8, application/rdf+xml;q=0.8, application/n-triples;q=0.8, application/n-quads;q=0.8, text/x-nquads;q=0.8, application/trig;q=0.8, text/n3;q=0.8, application/ld+json;q=0.8, application/x-binary-rdf;q=0.8, text/plain;q=0.7'
    When method GET
    Then status 200
    And match response != ''
