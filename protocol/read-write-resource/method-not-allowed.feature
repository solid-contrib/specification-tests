Feature: Error for unsupported method

  Background: Set up clients and paths
    * def testContainer = rootTestContainer.createContainer()
    * def resource = testContainer.createResource('.ttl', karate.readAsString('../fixtures/example.ttl'), 'text/turtle');

  Scenario: Check response for TRACE method on resource
    * def response = clients.alice.sendAuthorized('TRACE', resource.url, null, null, null)
    Then match [400, 405, 501] contains response.status
#    And assert response.headers.allow != null

  Scenario: Check response for TRACE method on container
    * def response = clients.alice.sendAuthorized('TRACE', testContainer.url, null, null, null)
    Then match [400, 405, 501] contains response.status
#    And assert response.headers.allow != null

    # TODO: Test that Allow is present when 405 is returned

    # TODO: Iterate over list of known and unknown methods, check Allow header, and test the resulting set.
