@notifications
Feature: Notification subscription creation

  Background:
    * def testContainer = rootTestContainer.createContainer()
    * def setup = callonce read('../subscription-endpoint.feature')
    * def subscriptionEndpoint = setup.subscriptionEndpoint

  Scenario: Subscription endpoint accepts POST
    Given url subscriptionEndpoint
    And headers clients.alice.getAuthHeaders('POST', subscriptionEndpoint)
    And header Content-Type = 'application/ld+json'
    And header Accept = 'application/ld+json'
    And request {@context: ['https://www.w3.org/ns/solid/notification/v1'], type: '#(setup.subscriptionType)', topic: '#(testContainer.url)'}
    When method POST
    Then match responseStatus != 405
