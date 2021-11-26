Feature: Server assigns URI based on effective request URI

  Background: Setup
    * def testContainer = createTestContainerImmediate()

  Scenario: Create resource at /put-dahut with PUT
    * def requestUri = testContainer.url + 'put-dahut'
    Given url requestUri
    And configure headers = clients.alice.getAuthHeaders('PUT', requestUri)
    And header Content-Type = 'text/turtle'
    And request '@prefix dc: <http://purl.org/dc/terms/>. <> dc:title "Create resource without suffix"@en .'
    When method PUT
    Then status 201

    Given url requestUri
    And configure headers = clients.alice.getAuthHeaders('GET', requestUri)
    When method GET
    Then status 200

  @ignore  
  Scenario: Create resource at /patch-dahut with PATCH
    * def requestUri = testContainer.url + 'patch-dahut'
    Given url requestUri
    And configure headers = clients.alice.getAuthHeaders('PATCH', requestUri)
    And header Content-Type = 'text/n3'
    And request '@prefix solid: <http://www.w3.org/ns/solid/terms#>. @prefix dc: <http://purl.org/dc/terms/>. _:insert a solid:Patch ; solid:inserts { <> dc:title "Create resource without suffix"@en . } .'
    When method PATCH
    Then status 201

    Given url requestUri
    And configure headers = clients.alice.getAuthHeaders('GET', requestUri)
    When method GET
    Then status 200


