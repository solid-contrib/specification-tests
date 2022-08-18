Feature: Server must implement the CORS protocol for preflight requests

  Background: Set up test container and resource
    * def testContainer = rootTestContainer.createContainer()
    * def resource = testContainer.createResource('.txt', 'Hello', 'text/plain')

  Scenario Outline: Pre-flight CORS request for <method> request
    Given url testContainer.url
    And header Origin = 'https://tester'
    And header Access-Control-Request-Method = '<method>'
    And header Access-Control-Request-Headers = 'X-CUSTOM, Content-Type, Accept'
    When method OPTIONS
    Then match [200, 204] contains responseStatus
    And match header Access-Control-Allow-Origin == 'https://tester'
    And match header Access-Control-Allow-Methods contains '<method>'
    And match header Access-Control-Allow-Headers contains 'X-CUSTOM'
    And match header Access-Control-Allow-Headers contains 'Content-Type'
    And match header Access-Control-Allow-Headers contains 'Accept'
    And match header Access-Control-Allow-Credentials == 'true'
    And match header Access-Control-Expose-Headers != null
    And match response == ''

    Given url testContainer.url
    And header Origin = 'https://tester'
    And headers clients.alice.getAuthHeaders('<method>', testContainer.url)
    # Demonstrates the case where a long Accept header is allowed
    And header Accept = 'text/turtle;q=0.9, application/rdf+xml;q=0.8, application/n-triples;q=0.8, application/n-quads;q=0.8, text/x-nquads;q=0.8, application/trig;q=0.8, text/n3;q=0.8, application/ld+json;q=0.8, application/x-binary-rdf;q=0.8, text/plain;q=0.7'
    * <body>
    When method <method>
    Then match <statuses> contains responseStatus
    And match header Access-Control-Allow-Origin == 'https://tester'
    And match header Access-Control-Allow-Credentials == 'true'
    And match header Access-Control-Expose-Headers != null
    And match header Access-Control-Expose-Headers != '*'
    # Check Content-Type on GET request only
    And <check>
    And match header Vary contains 'Origin'
    Examples:
      | method | body            | statuses             | check                                            |
      | GET    | def ignore = 1  | [200]                | match header Content-Type contains 'text/turtle' |
      | HEAD   | def ignore = 1  | [200]                | def ignore = 1                                   |
      | POST   | request "Hello" | [200, 201, 204, 205] | def ignore = 1                                   |

  @http-redirect
  Scenario: OPTIONS request returns headers for pre-flight check after redirect from http
    * configure followRedirects = false
    Given url testContainer.url.replace(/^https:/, 'http:')
    And header Origin = 'https://tester'
    And header Access-Control-Request-Method = 'POST'
    And header Access-Control-Request-Headers = 'X-CUSTOM, Content-Type'
    When method OPTIONS
    Then match [301, 308] contains responseStatus
    * def location = karate.response.headerValues('location')[0]

    Given url location
    And header Origin = 'https://tester'
    And header Access-Control-Request-Method = 'POST'
    And header Access-Control-Request-Headers = 'X-CUSTOM, Content-Type'
    When method OPTIONS
    Then match [200, 204] contains responseStatus
    And match header Access-Control-Allow-Origin == 'https://tester'
    And match header Access-Control-Allow-Methods contains 'POST'
    And match header Access-Control-Allow-Headers contains 'X-CUSTOM'
    And match header Access-Control-Allow-Headers contains 'Content-Type'
    And match header Access-Control-Allow-Credentials == 'true'
    And match header Access-Control-Expose-Headers != null
    And match response == ''
