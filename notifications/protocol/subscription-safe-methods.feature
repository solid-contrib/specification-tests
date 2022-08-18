@notifications
Feature: Notification subscription safe methods

  Background:
    * def setup = callonce read('../subscription-endpoint.feature')
    * def subscriptionEndpoint = setup.subscriptionEndpoint

  Scenario: Subscription endpoint accepts GET
    Given url subscriptionEndpoint
    And headers clients.alice.getAuthHeaders('GET', subscriptionEndpoint)
    When method GET
    Then status 200

  Scenario: Subscription endpoint accepts HEAD
    Given url subscriptionEndpoint
    And headers clients.alice.getAuthHeaders('HEAD', subscriptionEndpoint)
    When method HEAD
    Then status 200

  Scenario: Subscription endpoint accepts OPTIONS
    Given url subscriptionEndpoint
    And headers clients.alice.getAuthHeaders('OPTIONS', subscriptionEndpoint)
    When method OPTIONS
    Then match [200, 204] contains responseStatus
