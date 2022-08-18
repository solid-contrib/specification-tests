@notifications
Feature: WebSocketSubscription2021 source field

  Background:
    * def testContainer = rootTestContainer.createContainer()
    * def setup = callonce read('../subscription-endpoint.feature') {subscriptionType: 'WebSocketSubscription2021'}
    * def wsEndpoint = setup.subscriptionEndpoint

  Scenario: Subscription response source must use wss schema
    Given url wsEndpoint
    And headers clients.alice.getAuthHeaders('POST', wsEndpoint)
    And header Content-Type = 'application/ld+json'
    And header Accept = 'application/ld+json'
    And request {@context: ['https://www.w3.org/ns/solid/notification/v1'], type: 'WebSocketSubscription2021', topic: '#(testContainer.url)'}
    When method POST
    Then match responseStatus != 405
    And assert response.endpoint.startsWith('wss://')
