Feature: Access permissions and return codes for public reflect container and resource permissions
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
            ? resource.accessDatasetBuilder.setInheritablePublicAccess(resource.url, permissions)
            : resource.accessDatasetBuilder.setPublicAccess(resource.url, permissions)
          //return inheritable
          //  ? resource.accessDatasetBuilder.setInheritableAuthenticatedAccess(resource.url, permissions)
          //  : resource.accessDatasetBuilder.setAuthenticatedAccess(resource.url, permissions)
          //return inheritable
          //  ? resource.accessDatasetBuilder.setInheritableAgentAccess(resource.url, webIds[client], permissions)
          //  : resource.accessDatasetBuilder.setAgentAccess(resource.url, webIds[client], permissions)
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
      | OPTIONS | public | no        | inherited | rdf       | 204    |
      | OPTIONS | public | no        | inherited | plain     | 204    |
      | OPTIONS | public | no        | inherited | fictive   | 204    |
      | OPTIONS | public | no        | inherited | container | 204    |
      | OPTIONS | public | no        | R         | rdf       | 204    |
      | OPTIONS | public | no        | R         | plain     | 204    |
      | OPTIONS | public | no        | R         | fictive   | 204    |
      | OPTIONS | public | no        | R         | container | 204    |
      | OPTIONS | public | R         | inherited | rdf       | 204    |
      | OPTIONS | public | R         | inherited | plain     | 204    |
      | OPTIONS | public | R         | inherited | fictive   | 204    |
      | OPTIONS | public | R         | inherited | container | 204    |
      | HEAD    | public | no        | inherited | rdf       | 401    |
      | HEAD    | public | no        | inherited | plain     | 401    |
      | HEAD    | public | no        | inherited | fictive   | 401    |
      | HEAD    | public | no        | inherited | container | 401    |
      | HEAD    | public | no        | R         | rdf       | 200    |
      | HEAD    | public | no        | R         | plain     | 200    |
      #| HEAD    | public | no        | R         | fictive   | 404    |
      | HEAD    | public | no        | R         | container | 200    |
      | HEAD    | public | R         | inherited | rdf       | 200    |
      | HEAD    | public | R         | inherited | plain     | 200    |
      | HEAD    | public | R         | inherited | fictive   | 404    |
      | HEAD    | public | R         | inherited | container | 200    |
      | GET     | public | no        | inherited | rdf       | 401    |
      | GET     | public | no        | inherited | plain     | 401    |
      | GET     | public | no        | inherited | fictive   | 401    |
      | GET     | public | no        | inherited | container | 401    |
      | GET     | public | no        | R         | rdf       | 200    |
      | GET     | public | no        | R         | plain     | 200    |
      #| GET     | public | no        | R         | fictive   | 404    |
      | GET     | public | no        | R         | container | 200    |
      | GET     | public | R         | inherited | rdf       | 200    |
      | GET     | public | R         | inherited | plain     | 200    |
      | GET     | public | R         | inherited | fictive   | 404    |
      | GET     | public | R         | inherited | container | 200    |
      | GET     | public | R         | W         | rdf       | 401    |
      | GET     | public | R         | W         | plain     | 401    |
      | GET     | public | R         | W         | fictive   | 401    |
      | GET     | public | R         | W         | container | 401    |

  Scenario Outline: <method> by <client> on container produces <status> with <container> permissions on container and <resource> permissions on resource
    Given def testResources = prepareResources(container, resource, type, client)
    And url testResources.container.url
    And headers authHeaders(method, client, testResources.container.url)
    And header Content-Type = 'text/turtle'
    And request '@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>. <> rdfs:comment "Public added this.".'
    When method <method>
    Then status <status>
    Examples:
      | method  | client | container | resource  | type      | status |
      | POST    | public | no        | inherited | fictive   | 401    |
      | POST    | public | no        | R         | fictive   | 401    |
      | POST    | public | A         | inherited | fictive   | 401    |
      | POST    | public | A         | R         | fictive   | 201    |
      | POST    | public | RA        | inherited | fictive   | 401    |
      | POST    | public | RA        | R         | fictive   | 201    |
      | PUT     | public | no        | inherited | fictive   | 401    |
      | PUT     | public | R         | inherited | fictive   | 401    |
      | PUT     | public | W         | inherited | fictive   | 401    |

  Scenario Outline: <method> by <client> on <type> resource produces <status> with <container> permissions on container and <resource> permissions on resource
    Given def testResources = prepareResources(container, resource, type, client)
    And url testResources.resource.url
    And headers authHeaders(method, client, testResources.resource.url)
    And header Content-Type = 'text/plain'
    And request "Public's text"
    When method <method>
    Then status <status>
    Examples:
      | method  | client | container | resource  | type      | status |
      | PUT     | public | no        | inherited | plain     | 401    |
      | PUT     | public | no        | inherited | fictive   | 401    |
      | PUT     | public | no        | R         | plain     | 401    |
      | PUT     | public | no        | R         | fictive   | 401    |
      | PUT     | public | no        | A         | plain     | 401    |
      | PUT     | public | no        | A         | fictive   | 401    |
      | PUT     | public | no        | W         | plain     | 205    |
      | PUT     | public | no        | W         | fictive   | 401    |
      | PUT     | public | R         | inherited | plain     | 401    |
      | PUT     | public | R         | inherited | fictive   | 401    |
      | PUT     | public | A         | inherited | plain     | 401    |
      | PUT     | public | A         | inherited | fictive   | 401    |
      | PUT     | public | W         | inherited | plain     | 205    |
      #| PUT     | public | W         | inherited | fictive   | 201    |
      | PUT     | public | A         | W         | plain     | 205    |
      #| PUT     | public | A         | W         | fictive   | 201    |
      | POST    | public | no        | inherited | plain     | 401    |
      | POST    | public | no        | inherited | fictive   | 401    |
      | POST    | public | no        | R         | plain     | 401    |
      | POST    | public | no        | R         | fictive   | 401    |
      | POST    | public | no        | A         | plain     | 405    |
      | POST    | public | no        | A         | fictive   | 401    |
      | POST    | public | no        | W         | plain     | 405    |
      | POST    | public | no        | W         | fictive   | 401    |
      | POST    | public | R         | inherited | plain     | 401    |
      | POST    | public | R         | inherited | fictive   | 404    |
      | POST    | public | A         | inherited | plain     | 405    |
      | POST    | public | A         | inherited | fictive   | 404    |
      | POST    | public | W         | inherited | plain     | 405    |
      #| POST    | public | W         | inherited | fictive   | 201    |
      | POST    | public | A         | W         | plain     | 405    |
      #| POST    | public | A         | W         | fictive   | 201    |
