@notifications
Feature: WebSocketSubscription2021 topic field

  Background:
    * def testContainer = rootTestContainer.createContainer()
    * def setup = callonce read('../subscription-endpoint.feature') {subscriptionType: 'WebSocketSubscription2021'}
    * def wsEndpoint = setup.subscriptionEndpoint

  Scenario: Subscription request must contain topic
    Given url wsEndpoint
    And headers clients.alice.getAuthHeaders('POST', wsEndpoint)
    And header Content-Type = 'application/ld+json'
    And header Accept = 'application/ld+json'
    And request {@context: ['https://www.w3.org/ns/solid/notification/v1'], type: 'WebSocketSubscription2021', topic: '#(testContainer.url)'}
    When method POST
    Then status 200

    # server should respond with an error if the topic is missing
    Given url wsEndpoint
    And headers clients.alice.getAuthHeaders('POST', wsEndpoint)
    And header Content-Type = 'application/ld+json'
    And header Accept = 'application/ld+json'
    And request {@context: ['https://www.w3.org/ns/solid/notification/v1'], type: 'WebSocketSubscription2021'}
    When method POST
    Then assert responseStatus >= 400 && responseStatus < 500

    # server should respond with an error if the topic is invalid
    Given url wsEndpoint
    And headers clients.alice.getAuthHeaders('POST', wsEndpoint)
    And header Content-Type = 'application/ld+json'
    And header Accept = 'application/ld+json'
    And request {@context: ['https://www.w3.org/ns/solid/notification/v1'], type: 'WebSocketSubscription2021', topic: 'BAD'}
    When method POST
    Then assert responseStatus >= 400 && responseStatus < 500