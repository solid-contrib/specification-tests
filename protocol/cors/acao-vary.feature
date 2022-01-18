Feature: Server returns correct Access-Control-Allow-Origin and Vary headers

  Background: Set up test container
    * def testContainer = rootTestContainer.createContainer()
    * def resource = testContainer.createResource('.txt', 'Hello', 'text/plain')

  Scenario: Access-Control-Allow-Origin header is set to correct origin for OPTIONS on container
    Given url testContainer.url
    And headers clients.alice.getAuthHeaders('OPTIONS', testContainer.url)
    And header Origin = 'https://tester'
    When method OPTIONS
    Then status 204
    And match header Access-Control-Allow-Origin == 'https://tester'
    And match response == ''

  Scenario: Access-Control-Allow-Origin header is set to correct origin for GET on container
    Given url testContainer.url
    And headers clients.alice.getAuthHeaders('GET', testContainer.url)
    And header Origin = 'https://tester'
    When method GET
    Then status 200
    And match header Access-Control-Allow-Origin == 'https://tester'
    And match response != ''

  Scenario: Vary header includes Origin for OPTIONS on container
    Given url testContainer.url
    And headers clients.alice.getAuthHeaders('OPTIONS', testContainer.url)
    And header Origin = 'https://tester'
    When method OPTIONS
    Then status 204
    And match header Vary contains 'Origin'
    And match response == ''

  Scenario: Vary header includes Origin for GET on container
    Given url testContainer.url
    And headers clients.alice.getAuthHeaders('GET', testContainer.url)
    And header Origin = 'https://tester'
    When method GET
    Then status 200
    And match header Vary contains 'Origin'
    And match response != ''

  Scenario: Access-Control-Allow-Origin header is set to correct origin for OPTIONS on resource
    Given url resource.url
    And headers clients.alice.getAuthHeaders('OPTIONS', resource.url)
    And header Origin = 'https://tester'
    When method OPTIONS
    Then status 204
    And match header Access-Control-Allow-Origin == 'https://tester'
    And match response == ''

  Scenario: Access-Control-Allow-Origin header is set to correct origin for GET on resource
    Given url resource.url
    And headers clients.alice.getAuthHeaders('GET', resource.url)
    And header Origin = 'https://tester'
    When method GET
    Then status 200
    And match header Access-Control-Allow-Origin == 'https://tester'
    And match response == 'Hello'

  Scenario: Vary header includes Origin for OPTIONS on resource
    Given url resource.url
    And headers clients.alice.getAuthHeaders('OPTIONS', resource.url)
    And header Origin = 'https://tester'
    When method OPTIONS
    Then status 204
    And match header Vary contains 'Origin'
    And match response == ''

  Scenario: Vary header includes Origin for GET on resource
    Given url resource.url
    And headers clients.alice.getAuthHeaders('GET', resource.url)
    And header Origin = 'https://tester'
    When method GET
    Then status 200
    And match header Vary contains 'Origin'
    And match response == 'Hello'
