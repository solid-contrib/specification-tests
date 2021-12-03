Feature: Create: PUT Turtle resources to container with If-None-Match: * headers.

  Background: Setup
    * def testContainer = rootTestContainer.reserveContainer()
    * def resource = testContainer.createResource('.ttl', '@prefix dc: <http://purl.org/dc/terms/>. <> dc:title "data"@en .', 'text/turtle');

  Scenario: Precondition Fails not met when putting a resource over an existing one
    * def requestUri = resource.url
    Given url requestUri
    And headers clients.alice.getAuthHeaders('PUT', requestUri)
    And header If-None-Match = '*'
    And header Content-Type = 'text/turtle'
    And request '@prefix dc: <http://purl.org/dc/terms/>. <> dc:title "No Interaction Model, but if-none-match"@en .'
    When method PUT
    Then status 412

    Given url requestUri
    And headers clients.alice.getAuthHeaders('GET', requestUri)
    When method GET
    Then status 200
    * match response !contains 'if-none-match'

  Scenario: Precondition OK when creating new resource
    * def requestUri = testContainer.url + 'dahut-no-nr.ttl'
    Given url requestUri
    And headers clients.alice.getAuthHeaders('PUT', requestUri)
    And header If-None-Match = '*'
    And header Content-Type = 'text/turtle'
    And request '@prefix dc: <http://purl.org/dc/terms/>. <> dc:title "No Interaction Model, but if-none-match"@en .'
    When method PUT
    # Required by https://datatracker.ietf.org/doc/html/rfc7231#section-4.3.4
    Then status 201

    Given url requestUri
    And headers clients.alice.getAuthHeaders('GET', requestUri)
    When method GET
    Then status 200
    * match response contains 'if-none-match'

  # Scenario: Test 2.4 Conflict when putting a container as a non-container
  #   * def requestUri = testContainer.url + 'dahut-bc.ttl'
  #   Given url requestUri
  #   And headers clients.alice.getAuthHeaders('PUT', requestUri)
  #   And header If-None-Match = '*'
  #   And header Content-Type = 'text/turtle'
  #   And header Link = '<http://www.w3.org/ns/ldp#BasicContainer>; rel="type"'
  #   And request '@prefix dc: <http://purl.org/dc/terms/>. <> dc:title "Container Interaction Model"@en .'
  #   When method PUT
  #   Then status 409
