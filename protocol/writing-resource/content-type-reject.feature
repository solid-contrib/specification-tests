Feature: Server MUST reject write requests without Content-Type

  Background: Set up clients and paths
    * def testContainer = rootTestContainer.createContainer()

  Scenario: Server rejects PUT requests without Content-Type
    * def resource = testContainer.reserveResource('.ttl')
    * def response = clients.alice.sendAuthorized('PUT', resource.url, '<> a <#Something> .', null, null)
    Then assert response.status == 400

  Scenario: Server rejects POST requests without Content-Type
    * def response = clients.alice.sendAuthorized('POST', testContainer.url, '<> a <#Something> .', null, null)
    Then assert response.status == 400

  Scenario: Server rejects PATCH requests without Content-Type
    * def resource = testContainer.createResource('.ttl', karate.readAsString('../fixtures/example.ttl'), 'text/turtle')
    * def patch = '@prefix solid: <http://www.w3.org/ns/solid/terms#>. _:insert a solid:InsertDeletePatch; solid:inserts { <> a <http://example.org#Foo> . }.'
    * def response = clients.alice.sendAuthorized('PATCH', resource.url, patch, null, null)
    Then assert response.status == 400
