@notifications
Feature: Notification subscription topic field

  Background:
    * def testContainer = rootTestContainer.createContainer()
    * def setup = callonce read('../subscription-endpoint.feature')
    * def subscriptionEndpoint = setup.subscriptionEndpoint

  Scenario: Subscription request must contain topic
    Given url subscriptionEndpoint
    And headers clients.alice.getAuthHeaders('POST', subscriptionEndpoint)
    And header Content-Type = 'application/ld+json'
    And header Accept = 'application/ld+json'
    And request {@context: ['https://www.w3.org/ns/solid/notification/v1'], type: '#(setup.subscriptionType)', topic: '#(testContainer.url)'}
    When method POST
    Then status 200

    # server should respond with an error if the topic is missing
    Given url subscriptionEndpoint
    And headers clients.alice.getAuthHeaders('POST', subscriptionEndpoint)
    And header Content-Type = 'application/ld+json'
    And header Accept = 'application/ld+json'
    And request {@context: ['https://www.w3.org/ns/solid/notification/v1'], type: '#(setup.subscriptionType)'}
    When method POST
    Then assert responseStatus >= 400 && responseStatus < 500

    # server should respond with an error if the topic is invalid
    Given url subscriptionEndpoint
    And headers clients.alice.getAuthHeaders('POST', subscriptionEndpoint)
    And header Content-Type = 'application/ld+json'
    And header Accept = 'application/ld+json'
    And request {@context: ['https://www.w3.org/ns/solid/notification/v1'], type: '#(setup.subscriptionType)', topic: 'BAD'}
    When method POST
    Then assert responseStatus >= 400 && responseStatus < 500