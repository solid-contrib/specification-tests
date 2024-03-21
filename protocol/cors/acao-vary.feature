Feature: Server returns correct Access-Control-Allow-Origin and Vary headers

  Background: Set up test container
    * def testContainer = rootTestContainer.createContainer()
    * def resource = testContainer.createResource('.txt', 'Hello', 'text/plain')

  Scenario Outline: Access-Control-Allow-Origin header is set to correct origin for <method> on container
    Given url testContainer.url
    And headers clients.alice.getAuthHeaders('<method>', testContainer.url)
    And header Origin = config.origin
    When method <method>
    Then match <statuses> contains responseStatus
    And match header Access-Control-Allow-Origin == config.origin
    * string response = response
    And match response <check>
    Examples:
      | method  | statuses   | check |
      | OPTIONS | [200, 204] | == '' |
      | GET     | [200]      | != '' |
      | HEAD    | [200]      | == '' |

  Scenario Outline: Vary header includes Origin for <method> on container
    Given url testContainer.url
    And headers clients.alice.getAuthHeaders('<method>', testContainer.url)
    And header Origin = config.origin
    When method <method>
    Then match <statuses> contains responseStatus
    And match header Vary contains 'Origin'
    * string response = response
    And match response <check>
    Examples:
      | method  | statuses   | check |
      | OPTIONS | [200, 204] | == '' |
      | GET     | [200]      | != '' |
      | HEAD    | [200]      | == '' |

  Scenario Outline: Access-Control-Allow-Origin header is set to correct origin for <method> on resource
    Given url resource.url
    And headers clients.alice.getAuthHeaders('<method>', resource.url)
    And header Origin = config.origin
    When method <method>
    Then match <statuses> contains responseStatus
    And match header Access-Control-Allow-Origin == config.origin
    * string response = response
    And match response <check>
    Examples:
      | method  | statuses   | check      |
      | OPTIONS | [200, 204] | == ''      |
      | GET     | [200]      | == 'Hello' |
      | HEAD    | [200]      | == ''      |

  Scenario Outline: Vary header includes Origin for <method> on resource
    Given url resource.url
    And headers clients.alice.getAuthHeaders('<method>', resource.url)
    And header Origin = config.origin
    When method <method>
    Then match <statuses> contains responseStatus
    And match header Vary contains 'Origin'
    * string response = response
    And match response <check>
    Examples:
      | method  | statuses   | check      |
      | OPTIONS | [200, 204] | == ''      |
      | GET     | [200]      | == 'Hello' |
      | HEAD    | [200]      | == ''      |
