Feature: Assignment of URIs for POST requests

  Background: Set up container
    * def testContainer = rootTestContainer.createContainer()
    
  Scenario: Allow resource creation via POST
    * def containerUrl = testContainer.url
    Given url containerUrl
    And headers clients.alice.getAuthHeaders('POST', containerUrl)
    And header Content-Type = 'text/turtle'
    And request "<> a <#Something> ."
    When method POST
    Then status 201

