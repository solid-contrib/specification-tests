Feature: Server MUST reject write requests without Content-Type

  Background: Set up clients and paths
    * def testContainer = createTestContainer()
    * def resource = testContainer.generateChildResource('.ttl')

  Scenario: Server rejects PUT requests without Content-Type
    * def resourceUrl = resource.getUrl()
    Given url resourceUrl
    And configure headers = clients.alice.getAuthHeaders('PUT', resourceUrl)
    And header Content-Type = ''
    And request "<> a <#Something> ."
    When method PUT
    Then status 400

  Scenario: Server rejects POST requests without Content-Type
    * def containerUrl = testContainer.getUrl()
    Given url containerUrl
    And configure headers = clients.alice.getAuthHeaders('POST', containerUrl)
    And header Content-Type = ''
    And request "<> a <#Something> ."
    When method POST
    Then status 400

  Scenario: Server rejects PATCH requests without Content-Type
    * def resourceUrl = resource.getUrl()
    Given url resourceUrl
    And configure headers = clients.alice.getAuthHeaders('PATCH', resourceUrl)
    And header Content-Type = ''
    And request "INSERT DATA { <> a <#Something> . }"
    When method PATCH
    Then status 400


