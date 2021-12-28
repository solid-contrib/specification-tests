Feature: POST to non-existing resource must result in 404

  Background: Set up container
    * def testContainer = rootTestContainer.createContainer()
    * def container = testContainer.reserveContainer()  
    * def rdfResource = testContainer.reserveResource('.ttl');

  Scenario: Reserved container does not exist
    Given url container.url
    And headers clients.alice.getAuthHeaders('POST', container.url)
    And header Content-Type = 'text/turtle'
    When method POST
    Then status 404
    
  Scenario: Reserved resource does not exist
    Given url rdfResource.url
    And headers clients.alice.getAuthHeaders('POST', rdfResource.url)
    And header Content-Type = 'text/turtle'
    When method POST
    Then status 404
