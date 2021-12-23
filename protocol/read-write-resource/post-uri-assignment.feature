Feature: Assignment of URIs for POST requests

  Background: Set up container
    * def testContainer = rootTestContainer.createContainer()
    
  Scenario: Allow resource creation via POST
    Given url testContainer.url
    And headers clients.alice.getAuthHeaders('POST', testContainer.url)
    And header Content-Type = 'text/turtle'
    And request "<> a <#Something> ."
    When method POST
    Then status 201

    # TODO: Test Location header and that the container is updated.
