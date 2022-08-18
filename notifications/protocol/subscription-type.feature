@notifications
Feature: Notification subscription type field

  Background:
    * def testContainer = rootTestContainer.createContainer()
    * def setup = callonce read('../subscription-endpoint.feature')
    * def subscriptionEndpoint = setup.subscriptionEndpoint

  Scenario: Subscription request must contain subscription type
    Given url subscriptionEndpoint
    And headers clients.alice.getAuthHeaders('POST', subscriptionEndpoint)
    And header Content-Type = 'application/ld+json'
    And header Accept = 'application/ld+json'
    And request {@context: ['https://www.w3.org/ns/solid/notification/v1'], type: '#(setup.subscriptionType)', topic: '#(testContainer.url)'}
    When method POST
    Then status 200
    And match response.type == setup.subscriptionType

    # server should respond with an error if the type is missing
    Given url subscriptionEndpoint
    And headers clients.alice.getAuthHeaders('POST', subscriptionEndpoint)
    And header Content-Type = 'application/ld+json'
    And header Accept = 'application/ld+json'
    And request {@context: ['https://www.w3.org/ns/solid/notification/v1'], topic: '#(testContainer.url)'}
    When method POST
    Then assert responseStatus >= 400 && responseStatus < 500

    # server should respond with an error if the type is unknown
    Given url subscriptionEndpoint
    And headers clients.alice.getAuthHeaders('POST', subscriptionEndpoint)
    And header Content-Type = 'application/ld+json'
    And header Accept = 'application/ld+json'
    And request {@context: ['https://www.w3.org/ns/solid/notification/v1'], type: 'UNKNOWN', topic: '#(testContainer.url)'}
    When method POST
    Then assert responseStatus >= 400 && responseStatus < 500
