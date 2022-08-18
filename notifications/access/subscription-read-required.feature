@notifications
Feature: Notification subscription requires read access

  Background:
    * def testContainer = rootTestContainer.createContainer()
    * def setup = callonce read('../subscription-endpoint.feature')
    * def subscriptionEndpoint = setup.subscriptionEndpoint

  Scenario: Bob can subscribe with read access to resource
    * testContainer.accessDataset = testContainer.accessDatasetBuilder.setAgentAccess(testContainer.url, webIds.bob, ['read']).build()
    Given url subscriptionEndpoint
    And headers clients.bob.getAuthHeaders('POST', subscriptionEndpoint)
    And header Content-Type = 'application/ld+json'
    And header Accept = 'application/ld+json'
    And request {@context: ['https://www.w3.org/ns/solid/notification/v1'], type: '#(setup.subscriptionType)', topic: '#(testContainer.url)'}
    When method POST
    Then status 200

  Scenario: Bob cannot subscribe without read access to resource
    * testContainer.accessDataset = testContainer.accessDatasetBuilder.setAgentAccess(testContainer.url, webIds.bob, ['write', 'append', 'control']).build()
    Given url subscriptionEndpoint
    And headers clients.bob.getAuthHeaders('POST', subscriptionEndpoint)
    And header Content-Type = 'application/ld+json'
    And header Accept = 'application/ld+json'
    And request {@context: ['https://www.w3.org/ns/solid/notification/v1'], type: '#(setup.subscriptionType)', topic: '#(testContainer.url)'}
    When method POST
    Then status 403