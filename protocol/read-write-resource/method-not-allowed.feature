Feature: Respond with 405 for non-existent method

  Background: Set up clients and paths
    * def testContainer = rootTestContainer.createContainer()
    * def resource = testContainer.createResource('.ttl', karate.readAsString('../fixtures/example.ttl'), 'text/turtle');

  Scenario: Check response for DAHU method on resource
    * def response = clients.alice.sendAuthorized('DAHU', resource.url, null, null, 'HTTP_1_1')
    Then assert response.status == 405
    And assert response.headers.allow != null

  Scenario: Check response for DAHU method on container
    * def response = clients.alice.sendAuthorized('DAHU', testContainer.url, null, null, 'HTTP_1_1')
    Then assert response.status == 405
    And assert response.headers.allow != null


    # TODO: Iterate over list of known and unknown methods, check Allow header, and test the resulting set.
