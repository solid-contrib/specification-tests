Feature: PUT or PATCH on auxiliary resources

  Background: Set up container and parse link headers
    * def testContainer = rootTestContainer.createContainer()
    * def container = testContainer.createContainer()  
    * def exampleTurtle = karate.readAsString('../fixtures/example.ttl')
    * def rdfResource = testContainer.createResource('.ttl', exampleTurtle, 'text/turtle');
    * def textResource = testContainer.createResource('.txt', 'Some text', 'text/plain');

  Scenario: PUT auxiliary resource to container
    * def response = clients.alice.sendAuthorized('GET', container.url, null, null)
    * def links = parseLinkHeaders(response.headers)
    * def describedby = links.find(el => el.rel.toLowerCase() === 'describedby')
    * def metaUrl = resolveUri(container.url, describedby.uri)
    Given url metaUrl
    And headers clients.alice.getAuthHeaders('PUT', metaUrl)
    And header Content-Type = 'text/turtle'
    And request "<./> a <#Something> ."
    When method PUT
    Then status 201

    Given url metaUrl
    And headers clients.alice.getAuthHeaders('PUT', metaUrl)
    And header Content-Type = 'text/turtle'
    And request "<./> a <#SomethingMore> ."
    When method PUT
    Then match [200, 204, 205] contains responseStatus

  Scenario: PUT auxiliary resource to rdfResource
    * def response = clients.alice.sendAuthorized('GET', rdfResource.url, null, null)
    * def links = parseLinkHeaders(response.headers)
    * def describedby = links.find(el => el.rel.toLowerCase() === 'describedby')
    * def metaUrl = resolveUri(rdfResource.url, describedby.uri)
    Given url metaUrl
    And headers clients.alice.getAuthHeaders('PUT', metaUrl)
    And header Content-Type = 'text/turtle'
    And request "<.> a <#Something> ."
    When method PUT
    Then status 201
    
    Given url metaUrl
    And headers clients.alice.getAuthHeaders('PUT', metaUrl)
    And header Content-Type = 'text/turtle'
    And request "<.> a <#SomethingMore> ."
    When method PUT
    Then match [200, 204, 205] contains responseStatus

  Scenario: PUT auxiliary resource to textResource
    * def response = clients.alice.sendAuthorized('GET', textResource.url, null, null)
    * def links = parseLinkHeaders(response.headers)
    * def describedby = links.find(el => el.rel.toLowerCase() === 'describedby')
    * def metaUrl = resolveUri(textResource.url, describedby.uri)
    Given url metaUrl
    And headers clients.alice.getAuthHeaders('PUT', metaUrl)
    And header Content-Type = 'text/turtle'
    And request "<.> a <#Something> ."
    When method PUT
    Then status 201

    Given url metaUrl
    And headers clients.alice.getAuthHeaders('PUT', metaUrl)
    And header Content-Type = 'text/turtle'
    And request "<.> a <#SomethingMore> ."
    When method PUT
    Then match [200, 204, 205] contains responseStatus

