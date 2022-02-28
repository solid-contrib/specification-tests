# This test will move to the write operations group when added but represents a useful test to keep until then.
Feature: Bob cannot read an RDF resource even if he can write to it

  Background: Create test resource with all default access except read for Bob
    * def setup =
    """
      function() {
        const testContainer = rootTestContainer.createContainer();
        const access = testContainer.accessDatasetBuilder
          .setAgentAccess(testContainer.url, webIds.bob, ['write'])
          .setInheritableAgentAccess(testContainer.url, webIds.bob, ['append', 'write', 'control'])
          .build();
        testContainer.accessDataset = access;
        return testContainer.createResource('.ttl', karate.readAsString('../fixtures/example.ttl'), 'text/turtle');
      }
    """
    * def resource = callonce setup
    * url resource.url

  Scenario: Bob cannot read the resource with GET
    Given headers clients.bob.getAuthHeaders('GET', resource.url)
    When method GET
    Then status 403

  Scenario: Bob cannot read the resource with HEAD
    Given headers clients.bob.getAuthHeaders('HEAD', resource.url)
    When method HEAD
    Then status 403

  Scenario: Bob can PUT to the resource but doesn't get it back since he cannot read
    Given request '<> <http://www.w3.org/2000/01/rdf-schema#comment> "Bob replaced it." .'
    And headers clients.bob.getAuthHeaders('PUT', resource.url)
    And header Content-Type = 'text/turtle'
    When method PUT
    Then match [201, 204, 205] contains responseStatus
    # Server may return payload with information about the operation e.g. "Created" so check it hasn't leaked the data which was PUT
    And match response !contains "Bob replaced it"

    Given headers clients.bob.getAuthHeaders('GET', resource.url)
    When method GET
    Then status 403
