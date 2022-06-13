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
    # We should check the list of headers exposed but what is the required list
    And match header Access-Control-Expose-Headers != null
    And match response == ''

  @http-redirect
  Scenario: OPTIONS request returns headers for pre-flight check after redirect from http
    Given url testContainer.url.replace(/^https:/, 'http:')
    And header Origin = 'https://tester'
    And header Access-Control-Request-Method = 'POST'
    And header Access-Control-Request-Headers = 'X-CUSTOM, Content-Type'
    When method OPTIONS
    Then match [301, 308] contains responseStatus
    * def location = responseHeaders['Location'][0]

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
    # We should check the list of headers exposed but what is the required list
    And match header Access-Control-Expose-Headers != null
    And match response == ''
