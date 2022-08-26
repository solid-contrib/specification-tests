Feature: Servers MUST support GET, HEAD and OPTIONS

  Background: Set up container
    * def testContainer = rootTestContainer.createContainer()
    * def exampleTurtle = karate.readAsString('../fixtures/example.ttl')
    * def rdfResource = testContainer.createResource('.ttl', exampleTurtle, 'text/turtle');

  Scenario: GET is supported for containers
    Given url testContainer.url
    When method GET
    Then assert responseStatus != 405 && responseStatus != 501

  Scenario: GET is supported for resources
    Given url rdfResource.url
    When method GET
    Then assert responseStatus != 405 && responseStatus != 501

  Scenario: HEAD is supported for containers
    Given url testContainer.url
    When method HEAD
    Then assert responseStatus != 405 && responseStatus != 501

  Scenario: HEAD is supported for resources
    Given url rdfResource.url
    When method HEAD
    Then assert responseStatus != 405 && responseStatus != 501

  Scenario: OPTIONS is supported for containers
    Given url testContainer.url
    When method OPTIONS
    Then assert responseStatus != 405 && responseStatus != 501

  Scenario: OPTIONS is supported for resources
    Given url rdfResource.url
    When method OPTIONS
    Then assert responseStatus != 405 && responseStatus != 501
