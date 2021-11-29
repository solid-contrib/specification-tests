Feature: Creating a resource using PUT and PATCH must create intermediate containers

  Background: Set up clients and paths
    * def testContainer = rootTestContainer.reserveContainer()
    * def intermediateContainer = testContainer.reserveContainer()
    * def resource = intermediateContainer.reserveResource('.txt')

  Scenario: PUT creates a grandchild resource and intermediate containers
    Given url resource.url
    And configure headers = clients.alice.getAuthHeaders('PUT', resource.url)
    And header Content-Type = 'text/plain'
    And request 'Hello'
    When method PUT
    Then assert responseStatus >= 200 && responseStatus < 300

    * def parentUrl = intermediateContainer.url
    Given url parentUrl
    And configure headers = clients.alice.getAuthHeaders('GET', parentUrl)
    And header Accept = 'text/turtle'
    When method GET
    Then status 200
    And match intermediateContainer.parseMembers(response) contains resource.url

    * def grandParentUrl = testContainer.url
    Given url grandParentUrl
    And configure headers = clients.alice.getAuthHeaders('GET', grandParentUrl)
    And header Accept = 'text/turtle'
    When method GET
    Then status 200
    And match testContainer.parseMembers(response) contains intermediateContainer.url

  Scenario: PATCH creates a grandchild resource and intermediate containers
    Given url resource.url
    And configure headers = clients.alice.getAuthHeaders('PATCH', resource.url)
    And header Content-Type = 'application/sparql-update'
    And request 'INSERT DATA { <#hello> <#linked> <#world> . }'
    When method PATCH
    Then assert responseStatus >= 200 && responseStatus < 300

    * def parentUrl = intermediateContainer.url
    Given url parentUrl
    And configure headers = clients.alice.getAuthHeaders('GET', parentUrl)
    And header Accept = 'text/turtle'
    When method GET
    Then status 200
    And match intermediateContainer.parseMembers(response) contains resource.url

    * def grandParentUrl = testContainer.url
    Given url grandParentUrl
    And configure headers = clients.alice.getAuthHeaders('GET', grandParentUrl)
    And header Accept = 'text/turtle'
    When method GET
    Then status 200
    And match testContainer.parseMembers(response) contains intermediateContainer.url

  Scenario: PUT conflicts when creating resource turning resource into container
    * def requestUri = rootTestContainer.url + 'dahut'
    Given url requestUri
    And configure headers = clients.alice.getAuthHeaders('PUT', requestUri)
    And header Content-Type = 'text/turtle'
    And request '<> a <http://example.org/Dahut> .'
    When method PUT
    Then assert responseStatus >= 200 && responseStatus < 300

    * def childrenRequestUri = rootTestContainer.url + 'dahut/foo/bar.txt'
    Given url childrenRequestUri
    And configure headers = clients.alice.getAuthHeaders('PUT', childrenRequestUri)
    And header Content-Type = 'text/plain'
    And request 'Hello'
    When method PUT
    Then assert responseStatus >= 400 && responseStatus < 500

  Scenario: PATCH conflicts when creating resource turning resource into container
    * def requestUri = rootTestContainer.url + 'dahut2'
    Given url requestUri
    And configure headers = clients.alice.getAuthHeaders('PATCH', requestUri)
    And header Content-Type = 'application/sparql-update'
    And request 'INSERT DATA { <#hello> <#linked> <#world> . }'
    When method PATCH
    Then assert responseStatus >= 200 && responseStatus < 300

    * def childrenRequestUri = rootTestContainer.url + 'dahut2/foo/bar.txt'
    Given url childrenRequestUri
    And configure headers = clients.alice.getAuthHeaders('PATCH', childrenRequestUri)
    And header Content-Type = 'text/plain'
    And request 'Hello'
    When method PATCH
    Then assert responseStatus >= 400 && responseStatus < 500
