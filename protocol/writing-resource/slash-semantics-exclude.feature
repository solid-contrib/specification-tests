@parallel=false
Feature: With and without trailing slash cannot co-exist

  Background: Set up clients and paths
    * def testContainer = rootTestContainer.createContainer()
    * configure followRedirects = false

  Scenario: PUT container, then try resource with same name
    * def childContainerUrl = testContainer.url + 'foo/'
    Given url childContainerUrl
    And headers clients.alice.getAuthHeaders('PUT', childContainerUrl)
    And header Content-Type = 'text/turtle'
    When method PUT
    Then assert responseStatus >= 200 && responseStatus < 300

    # confirm there is no non-container resource with the same URI
    * def resourceUrl = testContainer.url + 'foo'
    Given url resourceUrl
    And headers clients.alice.getAuthHeaders('GET', resourceUrl)
    When method GET
    Then match [301, 404, 410] contains responseStatus

    # attempt to overwrite the container with a resource of the same name
    Given url resourceUrl
    And headers clients.alice.getAuthHeaders('PUT', resourceUrl)
    And header Content-Type = 'text/plain'
    And request 'Hello'
    When method PUT
     # See https://www.rfc-editor.org/rfc/rfc7231.html#page-27 for why 409 or 415
    Then match [409, 415] contains responseStatus

  Scenario: PUT resource, then try container with same name
    * def resourceUrl = testContainer.url + 'foo'
    Given url resourceUrl
    And headers clients.alice.getAuthHeaders('PUT', resourceUrl)
    And header Content-Type = 'text/plain'
    And request 'Hello'
    When method PUT
    Then assert responseStatus >= 200 && responseStatus < 300

    # confirm there is no container with the same URI
    * def childContainerUrl = testContainer.url + 'foo/'
    Given url childContainerUrl
    And headers clients.alice.getAuthHeaders('GET', childContainerUrl)
    When method GET
    Then match [301, 404, 410] contains responseStatus

    # attempt to overwrite the resource with a container of the same name
    Given url childContainerUrl
    And headers clients.alice.getAuthHeaders('PUT', childContainerUrl)
    And header Content-Type = 'text/turtle'
    When method PUT
     # See https://www.rfc-editor.org/rfc/rfc7231.html#page-27 for why 409 or 415
    Then match [409, 415] contains responseStatus

  Scenario: POST container, then try resource with same name
    Given url testContainer.url
    And headers clients.alice.getAuthHeaders('POST', testContainer.url)
    And header Content-Type = 'text/turtle'
    And header Link = '<http://www.w3.org/ns/ldp#BasicContainer>; rel="type"'
    When method POST
    Then assert responseStatus >= 200 && responseStatus < 300
    And def childContainerUrl = karate.response.headerValues('location')[0]
    And assert childContainerUrl.endsWith('/')

    # confirm there is no non-container resource with the same URI
    * def resourceUrl = childContainerUrl.slice(0, -1)
    Given url resourceUrl
    And headers clients.alice.getAuthHeaders('GET', resourceUrl)
    When method GET
    Then match [301, 404, 410] contains responseStatus

    # attempt to overwrite the container with a resource of the same name by PUT
    Given url resourceUrl
    And headers clients.alice.getAuthHeaders('PUT', resourceUrl)
    And header Content-Type = 'text/plain'
    And request 'Hello'
    When method PUT
     # See https://www.rfc-editor.org/rfc/rfc7231.html#page-27 for why 409 or 415
    Then match [409, 415] contains responseStatus

    # attempt to overwrite the container with a resource of the same name by POST with a slug
    Given url testContainer.url
    And headers clients.alice.getAuthHeaders('POST', testContainer.url)
    And header Slug = resourceUrl.substring(resourceUrl.lastIndexOf('/') + 1)
    And header Content-Type = 'text/plain'
    And request 'Hello'
    When method POST
    # this should either succeed (without using the slug) or fail as a conflict
    Then assert (responseStatus >= 200 && responseStatus < 300 && karate.response.headerValues('location')[0] != resourceUrl) || [409, 415].includes(responseStatus)

  Scenario: POST resource, then try container with same name
    Given url testContainer.url
    And headers clients.alice.getAuthHeaders('POST', testContainer.url)
    And header Content-Type = 'text/plain'
    And request 'Hello'
    When method POST
    Then assert responseStatus >= 200 && responseStatus < 300
    And def resourceUrl = karate.response.headerValues('location')[0]
    And assert !resourceUrl.endsWith('/')

    # confirm there is no container with the same URI
    * def childContainerUrl = resourceUrl + '/'
    Given url childContainerUrl
    And headers clients.alice.getAuthHeaders('GET', childContainerUrl)
    When method GET
    Then match [301, 404, 410] contains responseStatus

    # attempt to overwrite the resource with a container of the same name by PUT
    Given url childContainerUrl
    And headers clients.alice.getAuthHeaders('PUT', childContainerUrl)
    And header Content-Type = 'text/turtle'
    When method PUT
     # See https://www.rfc-editor.org/rfc/rfc7231.html#page-27 for why 409 or 415
    Then match [409, 415] contains responseStatus

    # attempt to overwrite the resource with a container of the same name by POST with a slug
    Given url testContainer.url
    And headers clients.alice.getAuthHeaders('POST', testContainer.url)
    And header Slug = resourceUrl.substring(resourceUrl.lastIndexOf('/') + 1)
    And header Content-Type = 'text/turtle'
    And header Link = '<http://www.w3.org/ns/ldp#BasicContainer>; rel="type"'
    When method POST
    # this should either succeed (without using the slug) or fail as a conflict
    Then assert (responseStatus >= 200 && responseStatus < 300 && karate.response.headerValues('location')[0] != resourceUrl + '/') || [409, 415].includes(responseStatus)

# TODO: Evil test to check various suffices.
