Feature: Server must support HTTP OPTIONS for CORS preflight requests

  Background: Set up test container
    * def testContainer = rootTestContainer.createContainer()

  Scenario: OPTIONS request returns headers for pre-flight check
    Given url testContainer.url
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
    # We should check the list of headers exposed but what is the required list
    And match header Access-Control-Expose-Headers != null
    And match response == ''

  # See https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS - "CORS-preflight requests must never include credentials." - what should happen then?
#  Scenario: Authorized OPTIONS request returns access control headers
#    Given url testContainer.url
#    And headers clients.alice.getAuthHeaders('OPTIONS', testContainer.url)
#    And header Origin = 'https://tester'
#    And header Access-Control-Request-Method = 'POST'
#    And header Access-Control-Request-Headers = 'X-CUSTOM, Content-Type'
#    When method OPTIONS
#    Then match [200, 204] contains responseStatus
#    And match header Access-Control-Allow-Origin == 'https://tester'
#    And match header Access-Control-Allow-Methods contains 'POST'
#    And match header Access-Control-Allow-Headers contains 'X-CUSTOM'
#    And match header Access-Control-Allow-Headers contains 'Content-Type'
#    And match header Access-Control-Allow-Credentials == 'true'
#    # We should check the list of headers exposed but what is the required list
#    And match header Access-Control-Expose-Headers != null
#    And match response == ''
