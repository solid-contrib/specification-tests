Feature: Access permissions and return codes for Bob reflect container and resource permissions
  Background: Prepare functions for generating resources for test cases
    * def authHeaders = (method, client, url) => client == 'public' ? {} : clients[client].getAuthHeaders(method, url)
    * def prepareResources =
    """
      function (containerModes, resourceModes, resourceType, client) {

        // containerModes, resourceModes = 'RWAC' or any combination thereof, or nothing for no permissions

        const resolvePermissions = function(modes) {
          return modes
            ? Object.entries({ R: 'read', W: 'write', A: 'append', C: 'control' }).filter(([mode, permission]) => modes.includes(mode)).map(([mode, permission]) => permission)
            : []
        }

        const createResourceByType = function(containerToCreateIn, typeToCreate) {
          switch (typeToCreate) {
            case 'plain':
              return containerToCreateIn.createResource('.txt', 'Hello', 'text/plain')
            case 'fictive':
              return containerToCreateIn.reserveResource('.txt')
            case 'rdf':
              return containerToCreateIn.createResource('.ttl', karate.readAsString('../fixtures/example.ttl'), 'text/turtle')
            case 'container':
              return containerToCreateIn.createContainer()
          }
        }

        const getAccessDatasetByPermissions = function(resource, client, permissions, inheritable) {
          return inheritable
            ? resource.accessDatasetBuilder.setInheritableAgentAccess(resource.url, webIds[client], permissions)
            : resource.accessDatasetBuilder.setAgentAccess(resource.url, webIds[client], permissions)
        }

        const testContainer = rootTestContainer.createContainer()
        const testResource = createResourceByType(testContainer, resourceType)

        const containerPermissions = resolvePermissions(containerModes)
        const resourcePermissions = resourceModes == 'inherited' ? undefined : resolvePermissions(resourceModes)

        // console.log(`Container: ${containerPermissions}, Resource: ${resourcePermissions}`)

        if (containerPermissions) {
          testContainer.accessDataset = getAccessDatasetByPermissions(testContainer, client, containerPermissions, resourcePermissions ? false : true).build()
        }

        if (resourcePermissions && resourceType != 'fictive') {
          testResource.accessDataset = getAccessDatasetByPermissions(testResource, client, resourcePermissions, false).build()
        }

        return { container: testContainer, resource: testResource }
      }
    """

  Scenario Outline: <method> by <client> on <type> resource produces <status> with <container> permissions on container and <resource> permissions on resource
    Given def testResources = prepareResources(container, resource, type, client)
    And url testResources.resource.url
    And headers authHeaders(method, client, testResources.resource.url)
    When method <method>
    Then status <status>
    Examples:
      | method  | client | container | resource  | type      | status |
      | OPTIONS | bob    | no        | inherited | rdf       | 204    |
      | OPTIONS | bob    | no        | inherited | plain     | 204    |
      | OPTIONS | bob    | no        | inherited | fictive   | 204    |
      | OPTIONS | bob    | no        | inherited | container | 204    |
      | OPTIONS | bob    | no        | R         | rdf       | 204    |
      | OPTIONS | bob    | no        | R         | plain     | 204    |
      | OPTIONS | bob    | no        | R         | fictive   | 204    |
      | OPTIONS | bob    | no        | R         | container | 204    |
      | OPTIONS | bob    | R         | inherited | rdf       | 204    |
      | OPTIONS | bob    | R         | inherited | plain     | 204    |
      | OPTIONS | bob    | R         | inherited | fictive   | 204    |
      | OPTIONS | bob    | R         | inherited | container | 204    |
      | HEAD    | bob    | no        | inherited | rdf       | 403    |
      | HEAD    | bob    | no        | inherited | plain     | 403    |
      | HEAD    | bob    | no        | inherited | fictive   | 403    |
      | HEAD    | bob    | no        | inherited | container | 403    |
      | HEAD    | bob    | no        | R         | rdf       | 200    |
      | HEAD    | bob    | no        | R         | plain     | 200    |
      #| HEAD    | bob    | no        | R         | fictive   | 404    |
      | HEAD    | bob    | no        | R         | container | 200    |
      | HEAD    | bob    | R         | inherited | rdf       | 200    |
      | HEAD    | bob    | R         | inherited | plain     | 200    |
      | HEAD    | bob    | R         | inherited | fictive   | 404    |
      | HEAD    | bob    | R         | inherited | container | 200    |
      | GET     | bob    | no        | inherited | rdf       | 403    |
      | GET     | bob    | no        | inherited | plain     | 403    |
      | GET     | bob    | no        | inherited | fictive   | 403    |
      | GET     | bob    | no        | inherited | container | 403    |
      | GET     | bob    | no        | R         | rdf       | 200    |
      | GET     | bob    | no        | R         | plain     | 200    |
      #| GET     | bob    | no        | R         | fictive   | 404    |
      | GET     | bob    | no        | R         | container | 200    |
      | GET     | bob    | R         | inherited | rdf       | 200    |
      | GET     | bob    | R         | inherited | plain     | 200    |
      | GET     | bob    | R         | inherited | fictive   | 404    |
      | GET     | bob    | R         | inherited | container | 200    |
      | GET     | bob    | R         | W         | rdf       | 403    |
      | GET     | bob    | R         | W         | plain     | 403    |
      | GET     | bob    | R         | W         | fictive   | 403    |
      | GET     | bob    | R         | W         | container | 403    |

  Scenario Outline: <method> by <client> on container produces <status> with <container> permissions on container and <resource> permissions on resource
    Given def testResources = prepareResources(container, resource, type, client)
    And url testResources.container.url
    And headers authHeaders(method, client, testResources.container.url)
    And header Content-Type = 'text/turtle'
    And request '@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>. <> rdfs:comment "Bob added this.".'
    When method <method>
    Then status <status>
    Examples:
      | method  | client | container | resource  | type      | status |
      | POST    | bob    | no        | inherited | fictive   | 403    |
      | POST    | bob    | no        | R         | fictive   | 403    |
      | POST    | bob    | A         | inherited | fictive   | 403    |
      | POST    | bob    | A         | R         | fictive   | 201    |
      | POST    | bob    | RA        | inherited | fictive   | 403    |
      | POST    | bob    | RA        | R         | fictive   | 201    |
      | PUT     | bob    | no        | inherited | fictive   | 403    |
      | PUT     | bob    | R         | inherited | fictive   | 403    |
      | PUT     | bob    | W         | inherited | fictive   | 403    |

  Scenario Outline: <method> by <client> on <type> resource produces <status> with <container> permissions on container and <resource> permissions on resource
    Given def testResources = prepareResources(container, resource, type, client)
    And url testResources.resource.url
    And headers authHeaders(method, client, testResources.resource.url)
    And header Content-Type = 'text/plain'
    And request "Bob's text"
    When method <method>
    Then status <status>
    Examples:
      | method  | client | container | resource  | type      | status |
      | PUT     | bob    | no        | inherited | plain     | 403    |
      | PUT     | bob    | no        | inherited | fictive   | 403    |
      | PUT     | bob    | no        | R         | plain     | 403    |
      | PUT     | bob    | no        | R         | fictive   | 403    |
      | PUT     | bob    | no        | A         | plain     | 403    |
      | PUT     | bob    | no        | A         | fictive   | 403    |
      | PUT     | bob    | no        | W         | plain     | 205    |
      | PUT     | bob    | no        | W         | fictive   | 403    |
      | PUT     | bob    | R         | inherited | plain     | 403    |
      | PUT     | bob    | R         | inherited | fictive   | 403    |
      | PUT     | bob    | A         | inherited | plain     | 403    |
      | PUT     | bob    | A         | inherited | fictive   | 403    |
      | PUT     | bob    | W         | inherited | plain     | 205    |
      #| PUT     | bob    | W         | inherited | fictive   | 201    |
      | PUT     | bob    | A         | W         | plain     | 205    |
      #| PUT     | bob    | A         | W         | fictive   | 201    |
      | POST    | bob    | no        | inherited | plain     | 403    |
      | POST    | bob    | no        | inherited | fictive   | 403    |
      | POST    | bob    | no        | R         | plain     | 403    |
      | POST    | bob    | no        | R         | fictive   | 403    |
      | POST    | bob    | no        | A         | plain     | 405    |
      | POST    | bob    | no        | A         | fictive   | 403    |
      | POST    | bob    | no        | W         | plain     | 405    |
      | POST    | bob    | no        | W         | fictive   | 403    |
      | POST    | bob    | R         | inherited | plain     | 403    |
      | POST    | bob    | R         | inherited | fictive   | 404    |
      | POST    | bob    | A         | inherited | plain     | 405    |
      | POST    | bob    | A         | inherited | fictive   | 404    |
      | POST    | bob    | W         | inherited | plain     | 405    |
      #| POST    | bob    | W         | inherited | fictive   | 201    |
      | POST    | bob    | A         | W         | plain     | 405    |
      #| POST    | bob    | A         | W         | fictive   | 201    |
