# Simple requests
# - Methods: GET, HEAD, POST
# - Safe headers: Accept, Accept-Language, Content-Language, Content-Type (application/x-www-form-urlencoded, multipart/form-data, text/plain)
Feature: Server must implement the CORS protocol for simple requests

  Background: Set up test container and test data
    * def testContainer = rootTestContainer.createContainer()
    * def resource = testContainer.createResource('.txt', 'Hello', 'text/plain')

  Scenario Outline: Simple container request: <method> request returns access control headers
    Given url testContainer.url
    And header Origin = config.origin
    And headers <headers>
    * <body>
    When method <method>
    Then match <statuses> contains responseStatus
    And match header Access-Control-Allow-Origin == config.origin
    And match header Access-Control-Expose-Headers != null
    And match header Access-Control-Expose-Headers != '*'
    Examples:
      | method | headers!                       | body            | statuses |
      | GET    | {Accept: 'text/turtle'}        | def ignore = 1  | [401]    |
      | HEAD   | {}                             | def ignore = 1  | [401]    |
      | POST   | {'Content-Type': 'text/plain'} | request "Hello" | [401]    |

  Scenario Outline: Simple resource request: <method> request returns access control headers
    Given url resource.url
    And header Origin = config.origin
    And headers <headers>
    * <body>
    When method <method>
    Then match <statuses> contains responseStatus
    And match header Access-Control-Allow-Origin == config.origin
    And match header Access-Control-Expose-Headers != null
    And match header Access-Control-Expose-Headers != '*'
    Examples:
      | method | headers!                       | body            | statuses |
      | GET    | {Accept: 'text/plain'}         | def ignore = 1  | [401]    |
      | HEAD   | {}                             | def ignore = 1  | [401]    |

  Scenario Outline: Requests container with credentials: <method> request returns access control headers
    Given url testContainer.url
    And headers clients.alice.getAuthHeaders('<method>', testContainer.url)
    And header Origin = config.origin
    And headers <headers>
    * <body>
    When method <method>
    Then match <statuses> contains responseStatus
    And match header Access-Control-Allow-Origin == config.origin
    And match header Access-Control-Expose-Headers != null
    And match header Access-Control-Expose-Headers != '*'
    # Check Vary on GET/HEAD requests only
    And <checkVary>
    Examples:
      | method | headers!                       | body            | statuses             | checkVary                           |
      | GET    | {Accept: 'text/turtle'}        | def ignore = 1  | [200]                | match header Vary contains 'Origin' |
      | HEAD   | {}                             | def ignore = 1  | [200]                | match header Vary contains 'Origin' |
      | POST   | {'Content-Type': 'text/plain'} | request "Hello" | [200, 201, 204, 205] | def ignore = 1                      |

  Scenario Outline: Requests resource with credentials: <method> request returns access control headers
    Given url resource.url
    And headers clients.alice.getAuthHeaders('<method>', resource.url)
    And header Origin = config.origin
    And headers <headers>
    * <body>
    When method <method>
    Then match <statuses> contains responseStatus
    And match header Access-Control-Allow-Origin == config.origin
    And match header Access-Control-Expose-Headers != null
    And match header Access-Control-Expose-Headers != '*'
    And match header Vary contains 'Origin'
    Examples:
      | method | headers!                       | body            | statuses             |
      | GET    | {Accept: 'text/plain'}         | def ignore = 1  | [200]                |
      | HEAD   | {}                             | def ignore = 1  | [200]                |
