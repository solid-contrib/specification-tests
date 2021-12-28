Feature: PUT or PATCH on auxiliary resources

  Background: Set up container and parse link headers
    * def testContainer = rootTestContainer.createContainer()
    * def container = testContainer.createContainer()  
    * def exampleTurtle = karate.readAsString('../fixtures/example.ttl')
    * def rdfResource = testContainer.createResource('.ttl', exampleTurtle, 'text/turtle');

  Scenario: PUT auxiliary resource to container
    * def response = clients.alice.sendAuthorized('GET', container.url, null, null)
    * def links = parseLinkHeaders(response.headers)
    * def describedby = links.find(el => el.rel === 'describedBy')
    * def metaUrl = resolveUri(container.url, describedby.uri)
    Given url metaUrl
    And headers clients.alice.getAuthHeaders('PUT', metaUrl)
    And header Content-Type = 'text/turtle'
    And request "<./> a <#Something> ."
    When method PUT
    Then status 201
