Feature: Server MUST reject write requests without Content-Type

  Background: Set up clients and paths
    * def testContainer = rootTestContainer.reserveContainer()
    * def resource = testContainer.reserveResource('.ttl')

  Scenario: Server rejects PUT requests without Content-Type
    Given url resource.url
    And headers clients.alice.getAuthHeaders('PUT', resource.url)
    And header Content-Type = ''
    And request "<> a <#Something> ."
    When method PUT
    Then status 400

  Scenario: Server rejects POST requests without Content-Type
    * def containerUrl = testContainer.url
    Given url containerUrl
    And headers clients.alice.getAuthHeaders('POST', containerUrl)
    And header Content-Type = ''
    And request "<> a <#Something> ."
    When method POST
    Then status 400

  Scenario: Server rejects PATCH requests without Content-Type
    Given url resource.url
    And headers clients.alice.getAuthHeaders('PATCH', resource.url)
    And header Content-Type = ''
    And request "INSERT DATA { <> a <#Something> . }"
    When method PATCH
    Then status 400


