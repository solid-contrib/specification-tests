Feature: Only authenticated agents can write (and only that) a resource when granted write access
  # Grant authenticated agents (setAuthenticatedAccess):
  # - restricted access or no access to the parent container
  # - restricted access to the test resources, or inherited access for fictive resources
  Background: Create test resources with correct access modes
    * def authHeaders =
    """
      function (method, url, agent) {
        const agentLowerCase = agent.toLowerCase()
        return agentLowerCase != 'public' ? clients[agentLowerCase].getAuthHeaders(method, url) : {}
      }
    """
    * def resourcePermissions =
    """
      function (modes) {
        if (modes && modes != 'inherited' && modes != 'no') {
          return Object.entries({ R: 'read', W: 'write', A: 'append', C: 'control' })
            .filter(([mode, permission]) => modes.includes(mode))
            .map(([mode, permission]) => permission)
        }
        return undefined
      }
    """
    * def getRequestData =
    """
      function (type) {
        switch(type) {
          case 'rdf':
            return {
              contentType: 'text/turtle',
              requestBody: '<> <http://www.w3.org/2000/01/rdf-schema#comment> "Bob replaced it." .',
              responseShouldNotContain: "Bob replaced it"
            }
          default:
            return {
              contentType: 'text/plain',
              requestBody: "Bob's text",
              responseShouldNotContain: "Bob's text"
            }
        }
      }
    """
    * def resourceEntry =
    """
      function (container, type) {
        switch (type) {
          case 'plain':
            return container.createResource('.txt', 'Hello', 'text/plain')
          case 'fictive':
            return container.reserveResource('.txt')
          case 'rdf':
            return container.createResource('.ttl', karate.readAsString('../fixtures/example.ttl'), 'text/turtle')
          case 'container':
            return container.createContainer()
          default:
            return undefined
        }
      }
    """
    * def createResource =
    """
      function (containerModes, resourceModes, resourceType) {

        const testContainerPermissions = resourcePermissions(containerModes == 'all' ? 'RWAC' : containerModes)
        const testResourcePermissions = resourcePermissions(resourceModes)

        const testContainerInheritablePermissions = resourceModes == 'inherited'
          ? testContainerPermissions
          : resourceType == 'fictive'
          ? testResourcePermissions
          : undefined

        const testContainer = rootTestContainer.createContainer()
        const testResource = resourceEntry(testContainer, resourceType)

        testContainer.accessDataset = testContainer.accessDatasetBuilder
          .setAuthenticatedAccess(testContainer.url, testContainerPermissions)
          .setInheritableAuthenticatedAccess(testContainer.url, testContainerInheritablePermissions)
          .build()

        if (resourceType != 'fictive' && resourceModes != 'inherited') {
          testResource.accessDataset = testResource.accessDatasetBuilder
            .setAuthenticatedAccess(testResource.url, testResourcePermissions)
            .build()
        }

        return testResource
      }
    """

  Scenario Outline: <agent> <result> read a <type> resource (<method>), when an authenticated agent has <container> access to the container and <resource> access to the resource
    * def testResource = createResource(container, resource, type)
    Given url testResource.url
    And headers authHeaders(method, testResource.url, agent)
    When method <method>
    Then status <status>
    Examples:
      | agent  | result | method  | type      | container | resource  | status |
      | Bob    | cannot | GET     | plain     | no        | AWC       | 403    |
      | Bob    | cannot | GET     | plain     | AWC       | inherited | 403    |
      | Bob    | cannot | GET     | fictive   | AWC       | inherited | 403    |
      | Bob    | cannot | GET     | rdf       | no        | AWC       | 403    |
      | Bob    | cannot | GET     | rdf       | AWC       | inherited | 403    |
      | Bob    | cannot | GET     | container | no        | AWC       | 403    |
      | Bob    | cannot | GET     | container | AWC       | inherited | 403    |
      | Bob    | cannot | HEAD    | plain     | no        | AWC       | 403    |
      | Bob    | cannot | HEAD    | plain     | AWC       | inherited | 403    |
      | Bob    | cannot | HEAD    | fictive   | AWC       | inherited | 403    |
      | Bob    | cannot | HEAD    | rdf       | no        | AWC       | 403    |
      | Bob    | cannot | HEAD    | rdf       | AWC       | inherited | 403    |
      | Bob    | cannot | HEAD    | container | no        | AWC       | 403    |
      | Bob    | cannot | HEAD    | container | AWC       | inherited | 403    |
      | Public | cannot | GET     | plain     | no        | AWC       | 401    |
      | Public | cannot | GET     | plain     | AWC       | inherited | 401    |
      | Public | cannot | GET     | fictive   | AWC       | inherited | 401    |
      | Public | cannot | GET     | rdf       | no        | AWC       | 401    |
      | Public | cannot | GET     | rdf       | AWC       | inherited | 401    |
      | Public | cannot | GET     | container | no        | AWC       | 401    |
      | Public | cannot | GET     | container | AWC       | inherited | 401    |
      | Public | cannot | HEAD    | plain     | no        | AWC       | 401    |
      | Public | cannot | HEAD    | plain     | AWC       | inherited | 401    |
      | Public | cannot | HEAD    | fictive   | AWC       | inherited | 401    |
      | Public | cannot | HEAD    | rdf       | no        | AWC       | 401    |
      | Public | cannot | HEAD    | rdf       | AWC       | inherited | 401    |
      | Public | cannot | HEAD    | container | no        | AWC       | 401    |
      | Public | cannot | HEAD    | container | AWC       | inherited | 401    |

  Scenario Outline: <agent> <result> write a <type> resource (<method>) and cannot read it, when an authenticated agent has <container> access to the container and <resource> access to the resource
    * def testResource = createResource(container, resource, type)
    * def requestData = getRequestData(type)
    Given url testResource.url
    And headers authHeaders(method, testResource.url, agent)
    And header Content-Type = requestData.contentType
    And request requestData.requestBody
    When method <method>
    Then match <writeStatus> contains responseStatus
    # Server may return payload with information about the operation e.g. "Created" so check it hasn't leaked the data which was PUT
    And string responseString = response
    And match responseString !contains requestData.responseShouldNotContain

    Given headers authHeaders('GET', testResource.url, agent)
    When method GET
    Then status <readStatus>

    Examples:
      | agent  | result | method  | type      | container | resource  | writeStatus     | readStatus |
      | Bob    | can    | PUT     | rdf       | no        | W         | [201, 204, 205] | 403        |
      | Bob    | can    | PUT     | rdf       | W         | inherited | [201, 204, 205] | 403        |
      | Bob    | can    | PUT     | plain     | no        | W         | [201, 204, 205] | 403        |
      | Bob    | can    | PUT     | plain     | W         | inherited | [201, 204, 205] | 403        |
      | Bob    | can    | PUT     | fictive   | W         | inherited | [201, 204, 205] | 403        |
      | Bob    | can    | POST    | container | no        | W         | [201, 204, 205] | 403        |
      | Bob    | can    | POST    | container | W         | inherited | [201, 204, 205] | 403        |
      | Bob    | can    | POST    | container | no        | A         | [201, 204, 205] | 403        |
      | Bob    | can    | POST    | container | A         | inherited | [201, 204, 205] | 403        |
      | Public | cannot | PUT     | rdf       | no        | WAC       | [401]           | 401        |
      | Public | cannot | PUT     | rdf       | WAC       | inherited | [401]           | 401        |
      | Public | cannot | PUT     | plain     | no        | WAC       | [401]           | 401        |
      | Public | cannot | PUT     | plain     | WAC       | inherited | [401]           | 401        |
      | Public | cannot | PUT     | fictive   | WAC       | inherited | [401]           | 401        |
      | Public | cannot | POST    | container | no        | WAC       | [401]           | 401        |
      | Public | cannot | POST    | container | WAC       | inherited | [401]           | 401        |

  Scenario Outline: <agent> <result> <method> to a <type> resource, when an authenticated agent has <container> access to the container and <resource> access to the resource
    * def testResource = createResource(container, resource, type)
    Given url testResource.url
    And headers authHeaders(method, testResource.url, agent)
    And header Content-Type = 'text/n3'
    And request '@prefix solid: <http://www.w3.org/ns/solid/terms#>. _:insert a solid:InsertDeletePatch; solid:inserts { <> a <http://example.org#Foo> . }.'
    When method <method>
    Then match <writeStatus> contains responseStatus
    # Server may return payload with information about the operation e.g. "Created" so check it hasn't leaked the data which was PUT
    And string responseString = response
    And match responseString !contains 'http://example.org#Foo'

    Given headers authHeaders('GET', testResource.url, agent)
    When method GET
    Then status <readStatus>

    Examples:
      | agent  | result | method | type      | container | resource  | writeStatus     | readStatus |
      | Bob    | can    | PATCH  | rdf       | no        | W         | [201, 204, 205] | 403        |
      | Bob    | can    | PATCH  | rdf       | W         | inherited | [201, 204, 205] | 403        |
      | Bob    | can    | PATCH  | fictive   | W         | inherited | [201, 204, 205] | 403        |
      | Bob    | can    | PATCH  | rdf       | no        | A         | [201, 204, 205] | 403        |
      | Bob    | can    | PATCH  | rdf       | A         | inherited | [201, 204, 205] | 403        |
      | Bob    | can    | PATCH  | fictive   | A         | inherited | [201, 204, 205] | 403        |
      | Bob    | cannot | PATCH  | rdf       | no        | C         | [403]           | 403        |
      | Bob    | cannot | PATCH  | rdf       | C         | inherited | [403]           | 403        |
      | Bob    | cannot | PATCH  | fictive   | C         | inherited | [403]           | 403        |
      | Public | cannot | PATCH  | rdf       | no        | WAC       | [401]           | 401        |
      | Public | cannot | PATCH  | rdf       | WAC       | inherited | [401]           | 401        |
      | Public | cannot | PATCH  | fictive   | WAC       | inherited | [401]           | 401        |

  Scenario Outline: <agent> <result> <method> a <type> resource, when an authenticated agent has <container> access to the container and <resource> access to the resource
    * def testResource = createResource(container, resource, type)
    Given url testResource.url
    And headers authHeaders(method, testResource.url, agent)
    When method <method>
    Then status <status>
    Examples:
      | agent  | result | method | type      | container | resource  | status |
      | Bob    | cannot | DELETE | plain     | no        | C         | 403    |
      | Bob    | cannot | DELETE | plain     | C         | inherited | 403    |
      | Bob    | cannot | DELETE | fictive   | C         | inherited | 403    |
      | Bob    | cannot | DELETE | rdf       | no        | C         | 403    |
      | Bob    | cannot | DELETE | rdf       | C         | inherited | 403    |
      | Bob    | cannot | DELETE | container | no        | C         | 403    |
      | Bob    | cannot | DELETE | container | C         | inherited | 403    |
      | Bob    | cannot | DELETE | plain     | no        | A         | 403    |
      | Bob    | cannot | DELETE | plain     | A         | inherited | 403    |
      | Bob    | cannot | DELETE | fictive   | A         | inherited | 403    |
      | Bob    | cannot | DELETE | rdf       | no        | A         | 403    |
      | Bob    | cannot | DELETE | rdf       | A         | inherited | 403    |
      | Bob    | cannot | DELETE | container | no        | A         | 403    |
      | Bob    | cannot | DELETE | container | A         | inherited | 403    |
      | Bob    | cannot | DELETE | plain     | no        | W         | 403    |
      | Bob    | can    | DELETE | plain     | W         | inherited | 205    |
      | Bob    | cannot | DELETE | fictive   | W         | inherited | 404    |
      | Bob    | cannot | DELETE | rdf       | no        | W         | 403    |
      | Bob    | can    | DELETE | rdf       | W         | inherited | 205    |
      | Bob    | cannot | DELETE | container | no        | W         | 403    |
      | Bob    | cannot | DELETE | container | W         | inherited | 403    |
      | Public | cannot | DELETE | plain     | no        | WAC       | 401    |
      | Public | cannot | DELETE | plain     | WAC       | inherited | 401    |
      | Public | cannot | DELETE | fictive   | WAC       | inherited | 401    |
      | Public | cannot | DELETE | rdf       | no        | WAC       | 401    |
      | Public | cannot | DELETE | rdf       | WAC       | inherited | 401    |
      | Public | cannot | DELETE | container | no        | WAC       | 401    |
      | Public | cannot | DELETE | container | WAC       | inherited | 401    |
