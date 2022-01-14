Feature: Error for undefined method

  Background: Set up clients and paths
    * def testContainer = rootTestContainer.createContainer()
    * def resource = testContainer.createResource('.ttl', karate.readAsString('../fixtures/example.ttl'), 'text/turtle');

  Scenario: Check response for TRACE method on resource
    * def response = clients.alice.sendAuthorized('TRACE', resource.url, null, null, null)
    Then assert response.status == 400 || response.status == 405 || response.status == 501
#    And assert response.headers.allow != null

  Scenario: Check response for TRACE method on container
    * def response = clients.alice.sendAuthorized('TRACE', testContainer.url, null, null, null)
    Then assert response.status == 400 || response.status == 405 || response.status == 501
#    And assert response.headers.allow != null

    # TODO: Test that Allow is present when 405 is returned

    # TODO: Iterate over list of known and unknown methods, check Allow header, and test the resulting set.
