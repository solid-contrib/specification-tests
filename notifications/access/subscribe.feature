@ignore
Feature: Subscribe to a resource

  # params are subscriptionEndpoint, subscriptionType, url
  Scenario:
    Given url subscriptionEndpoint
    And headers clients.alice.getAuthHeaders('POST', subscriptionEndpoint)
    And header Content-Type = 'application/ld+json'
    And header Accept = 'application/ld+json'
    And request {@context: ['https://www.w3.org/ns/solid/notification/v1'], type: '#(subscriptionType)', topic: '#(url)'}
    When method POST
    Then status 200
    * def endpoint = response.endpoint
