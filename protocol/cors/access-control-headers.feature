# Simple requests
# - Methods: GET, HEAD, POST
# - Extra headers: Accept, Accept-Language, Content-Language, Content-Type (application/x-www-form-urlencoded, multipart/form-data, text/plain)
# Pre-flight requests - handled in a separate test since it has its own requirement
# Requests with credentials
Feature: Server must respond to requests sending Origin with the appropriate Access-Control-* headers

  Background: Set up test container and test data
    * table testData
      | method | headers                        | body              | statuses | authStatuses         |
      | 'GET'  | {Accept: 'text/turtle'}        | 'def ignore = 1'  | [401]    | [200]                |
      | 'HEAD' | {}                             | 'def ignore = 1'  | [401]    | [200]                |
      | 'POST' | {'Content-Type': 'text/plain'} | 'request "Hello"' | [401]    | [200, 201, 204, 205] |
    * def testContainer = rootTestContainer.createContainer()

  Scenario Outline: Simple request: <method> request returns access control headers
    Given url testContainer.url
    And header Origin = 'https://tester'
    And headers <headers>
    * <body>
    When method <method>
    Then match <statuses> contains responseStatus
    And match header Access-Control-Allow-Origin == 'https://tester'
    # And match header Access-Control-Allow-Credentials == 'true' - not required?
    Examples:
      | testData |

  Scenario Outline: Requests with credentials: <method> request returns access control headers
    Given url testContainer.url
    And headers clients.alice.getAuthHeaders('<method>', testContainer.url)
    And header Origin = 'https://tester'
    And headers <headers>
    * <body>
    When method <method>
    Then match <authStatuses> contains responseStatus
    And match header Access-Control-Allow-Origin == 'https://tester'
    And match header Access-Control-Allow-Credentials == 'true'
    Examples:
      | testData |

  # How should other methods be handled? The CORS spec is very open so perhaps it is inappropriate to go further
