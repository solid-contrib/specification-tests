Feature: Assignment of URIs for POST requests with Slug

  Background: Set up container
    * def testContainer = rootTestContainer.createContainer()
    
  Scenario: Allow resource creation via POST with Slug
    Given url testContainer.url
    And headers clients.alice.getAuthHeaders('POST', testContainer.url)
    And header Content-Type = 'text/turtle'
    And header Slug = 'foobar'
    And request "<> a <#Something> ."
    When method POST
    Then status 201
    And match header Location contains 'foobar'

    # TODO: Test Location header for base and that the container is updated.
