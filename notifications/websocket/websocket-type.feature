@notifications
Feature: WebSocketSubscription2021 type field

  Background:
    * def testContainer = rootTestContainer.createContainer()
    * def setup = callonce read('../subscription-endpoint.feature') {subscriptionType: 'WebSocketSubscription2021'}
    * def wsEndpoint = setup.subscriptionEndpoint

  Scenario: Subscription request must contain subscription type
    Given url wsEndpoint
    And headers clients.alice.getAuthHeaders('POST', wsEndpoint)
    And header Content-Type = 'application/ld+json'
    And header Accept = 'application/ld+json'
    And request {@context: ['https://www.w3.org/ns/solid/notification/v1'], type: 'WebSocketSubscription2021', topic: '#(testContainer.url)'}
    When method POST
    Then status 200
#    "protocol":"ws","subprotocol":"solid-0.2" for ESS
    And match response.type == 'WebSocketSubscription2021'

    # server should respond with an error if the type is missing
    Given url wsEndpoint
    And headers clients.alice.getAuthHeaders('POST', wsEndpoint)
    And header Content-Type = 'application/ld+json'
    And header Accept = 'application/ld+json'
    And request {@context: ['https://www.w3.org/ns/solid/notification/v1'], topic: '#(testContainer.url)'}
    When method POST
    Then assert responseStatus >= 400 && responseStatus < 500

    # server should respond with an error if the type is unknown
    Given url wsEndpoint
    And headers clients.alice.getAuthHeaders('POST', wsEndpoint)
    And header Content-Type = 'application/ld+json'
    And header Accept = 'application/ld+json'
    And request {@context: ['https://www.w3.org/ns/solid/notification/v1'], type: 'UNKNOWN', topic: '#(testContainer.url)'}
    When method POST
    Then assert responseStatus >= 400 && responseStatus < 500
