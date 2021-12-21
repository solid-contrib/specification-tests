Feature: Server must link to exactly one description resource 

  Background: Set up clients and paths
    * def testContainer = rootTestContainer.createContainer()
    
  Scenario: Server sees exactly one Link to description resource from container
    Given url testContainer.url
    When method GET
    * def links = parseLinkHeaders(responseHeaders)
    * def test = links.filter(el => el.rel === 'describedBy')
    And assert (test.length === 1)

  Scenario: Server sees exactly one Link to description resource from RDF resource
    * def resource = testContainer.createResource('.ttl', '', 'text/turtle')
    Given url resource.url
    When method GET
    * def links = parseLinkHeaders(responseHeaders)
    * def test = links.filter(el => el.rel === 'describedBy')
    And assert (test.length === 1)
