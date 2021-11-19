Feature: Create: PUT Turtle resources to container with If-None-Match: * headers.

  Background: Setup
    * def testContainer = createTestContainer()
    * def resource = testContainer.createChildResource('.ttl', '@prefix dc: <http://purl.org/dc/terms/>. <> dc:title "data"@en .', 'text/turtle');
    * assert resource.exists()

  Scenario: Precondition Fails not met when putting a resource over an existing one
    * def requestUri = resource.getUrl()
    Given url requestUri
    And configure headers = clients.alice.getAuthHeaders('PUT', requestUri)
    And header If-None-Match = '*'
    And header Content-Type = 'text/turtle'
    And request '@prefix dc: <http://purl.org/dc/terms/>. <> dc:title "No Interaction Model, but if-none-match"@en .'
    When method PUT
    Then status 412

  Scenario: Precondition OK when creating new resource
    * def requestUri = testContainer.getUrl() + 'dahut-no-nr.ttl'
    Given url requestUri
    And configure headers = clients.alice.getAuthHeaders('PUT', requestUri)
    And header If-None-Match = '*'
    And header Content-Type = 'text/turtle'
    And request '@prefix dc: <http://purl.org/dc/terms/>. <> dc:title "No Interaction Model, but if-none-match"@en .'
    When method PUT
    # Required by https://datatracker.ietf.org/doc/html/rfc7231#section-4.3.4
    Then status 201

  # Test 2.3 on URL /dahut-no-nr.ttl
    Given url requestUri
    And configure headers = clients.alice.getAuthHeaders('GET', requestUri)
    When method GET
    Then status 200

  # Scenario: Test 2.4 Conflict when putting a container as a non-container
  #   * def requestUri = testContainer.getUrl() + 'dahut-bc.ttl'
  #   Given url requestUri
  #   And configure headers = clients.alice.getAuthHeaders('PUT', requestUri)
  #   And header If-None-Match = '*'
  #   And header Content-Type = 'text/turtle'
  #   And header Link = '<http://www.w3.org/ns/ldp#BasicContainer>; rel="type"'
  #   And request '@prefix dc: <http://purl.org/dc/terms/>. <> dc:title "Container Interaction Model"@en .'
  #   When method PUT
  #   Then status 409
