Feature: Only Bob can write (and only that) a resource when granted write access
  # Grant a specific agent (setAgentAccess):
  # - restricted access or no access to the parent container
  # - restricted access to the test resources, or inherited access for fictive resources
  Background: Create test resources with correct access modes
    * table resources
      | type        | container | resource    |
      | 'plain'     | 'no'      | 'WAC'       |
      | 'plain'     | 'WAC'     | 'inherited' |
      | 'fictive'   | 'WAC'     | 'inherited' |
      | 'rdf'       | 'no'      | 'WAC'       |
      | 'rdf'       | 'WAC'     | 'inherited' |
      | 'container' | 'no'      | 'WAC'       |
      | 'container' | 'WAC'     | 'inherited' |
    * def utils = callonce read('common.feature') ({resources, subject: 'agent', agent: webIds.bob})

  Scenario Outline: <agent> <result> read a <type> resource (<method>), when Bob has <container> access to the container and <resource> access to the resource
    * def testResource = utils.testResources[utils.getResourceKey(container, resource, type)]
    Given url testResource.url
    And headers utils.authHeaders(method, testResource.url, agent)
    And retry until responseStatus == <status>
    When method <method>
    Examples:
      | agent  | result | method  | type      | container | resource  | status |
      | Bob    | cannot | GET     | plain     | no        | WAC       | 403    |
      | Bob    | cannot | GET     | plain     | WAC       | inherited | 403    |
      | Bob    | cannot | GET     | fictive   | WAC       | inherited | 403    |
      | Bob    | cannot | GET     | rdf       | no        | WAC       | 403    |
      | Bob    | cannot | GET     | rdf       | WAC       | inherited | 403    |
      | Bob    | cannot | GET     | container | no        | WAC       | 403    |
      | Bob    | cannot | GET     | container | WAC       | inherited | 403    |
      | Bob    | cannot | HEAD    | plain     | no        | WAC       | 403    |
      | Bob    | cannot | HEAD    | plain     | WAC       | inherited | 403    |
      | Bob    | cannot | HEAD    | fictive   | WAC       | inherited | 403    |
      | Bob    | cannot | HEAD    | rdf       | no        | WAC       | 403    |
      | Bob    | cannot | HEAD    | rdf       | WAC       | inherited | 403    |
      | Bob    | cannot | HEAD    | container | no        | WAC       | 403    |
      | Bob    | cannot | HEAD    | container | WAC       | inherited | 403    |
      | Public | cannot | GET     | plain     | no        | WAC       | 401    |
      | Public | cannot | GET     | plain     | WAC       | inherited | 401    |
      | Public | cannot | GET     | fictive   | WAC       | inherited | 401    |
      | Public | cannot | GET     | rdf       | no        | WAC       | 401    |
      | Public | cannot | GET     | rdf       | WAC       | inherited | 401    |
      | Public | cannot | GET     | container | no        | WAC       | 401    |
      | Public | cannot | GET     | container | WAC       | inherited | 401    |
      | Public | cannot | HEAD    | plain     | no        | WAC       | 401    |
      | Public | cannot | HEAD    | plain     | WAC       | inherited | 401    |
      | Public | cannot | HEAD    | fictive   | WAC       | inherited | 401    |
      | Public | cannot | HEAD    | rdf       | no        | WAC       | 401    |
      | Public | cannot | HEAD    | rdf       | WAC       | inherited | 401    |
      | Public | cannot | HEAD    | container | no        | WAC       | 401    |
      | Public | cannot | HEAD    | container | WAC       | inherited | 401    |

  Scenario Outline: <agent> <result> write a <type> resource (<method>) and cannot read it, when Bob has <container> access to the container and <resource> access to the resource
    * def testResource = utils.createResource(container, resource, type, 'agent', webIds.bob)
    * def requestData = utils.getRequestData(type)
    Given url testResource.url
    And headers utils.authHeaders(method, testResource.url, agent)
    And header Content-Type = requestData.contentType
    And request requestData.requestBody
    And retry until utils.includesExpectedStatus(responseStatus, <writeStatus>)
    When method <method>
    # Server may return payload with information about the operation e.g. "Created" so check it hasn't leaked the data which was PUT
    And string responseString = response
    And match responseString !contains requestData.responseShouldNotContain

    Given headers utils.authHeaders('GET', testResource.url, agent)
    And retry until responseStatus == <readStatus>
    When method GET

    Examples:
      | agent  | result | method | type      | container | resource  | writeStatus          | readStatus |
      | Bob    | can    | PUT    | rdf       | no        | W         | [200, 201, 204, 205] | 403        |
      | Bob    | can    | PUT    | rdf       | W         | inherited | [200, 201, 204, 205] | 403        |
      | Bob    | can    | PUT    | plain     | no        | W         | [200, 201, 204, 205] | 403        |
      | Bob    | can    | PUT    | plain     | W         | inherited | [200, 201, 204, 205] | 403        |
      | Bob    | can    | PUT    | fictive   | W         | inherited | [201]                | 403        |
      | Bob    | can    | POST   | container | no        | W         | [200, 201, 204, 205] | 403        |
      | Bob    | can    | POST   | container | W         | inherited | [200, 201, 204, 205] | 403        |
      | Bob    | can    | POST   | container | no        | A         | [200, 201, 204, 205] | 403        |
      | Bob    | can    | POST   | container | A         | inherited | [200, 201, 204, 205] | 403        |
      | Public | cannot | PUT    | rdf       | no        | WAC       | [401]                | 401        |
      | Public | cannot | PUT    | rdf       | WAC       | inherited | [401]                | 401        |
      | Public | cannot | PUT    | plain     | no        | WAC       | [401]                | 401        |
      | Public | cannot | PUT    | plain     | WAC       | inherited | [401]                | 401        |
      | Public | cannot | PUT    | fictive   | WAC       | inherited | [401]                | 401        |
      | Public | cannot | POST   | container | no        | WAC       | [401]                | 401        |
      | Public | cannot | POST   | container | WAC       | inherited | [401]                | 401        |

  Scenario Outline: <agent> <result> <method> to a <type> resource, when Bob has <container> access to the container and <resource> access to the resource
    * def testResource = utils.createResource(container, resource, type, 'agent', webIds.bob)
    * def requestData = utils.getRequestData('text/n3')
    Given url testResource.url
    And headers utils.authHeaders(method, testResource.url, agent)
    And header Content-Type = requestData.contentType
    And request requestData.requestBody
    And retry until utils.includesExpectedStatus(responseStatus, <writeStatus>)
    When method <method>
    # Server may return payload with information about the operation e.g. "Created" so check it hasn't leaked the data which was PUT
    And string responseString = response
    And match responseString !contains requestData.responseShouldNotContain

    Given headers utils.authHeaders('GET', testResource.url, agent)
    And retry until responseStatus == <readStatus>
    When method GET

    Examples:
      | agent  | result | method | type    | container | resource  | writeStatus          | readStatus |
      | Bob    | can    | PATCH  | rdf     | no        | W         | [200, 201, 204, 205] | 403        |
      | Bob    | can    | PATCH  | rdf     | W         | inherited | [200, 201, 204, 205] | 403        |
      | Bob    | can    | PATCH  | fictive | W         | inherited | [200, 201, 204, 205] | 403        |
      | Bob    | can    | PATCH  | rdf     | no        | A         | [200, 201, 204, 205] | 403        |
      | Bob    | can    | PATCH  | rdf     | A         | inherited | [200, 201, 204, 205] | 403        |
      | Bob    | can    | PATCH  | fictive | A         | inherited | [200, 201, 204, 205] | 403        |
      | Bob    | cannot | PATCH  | rdf     | no        | C         | [403]                | 403        |
      | Bob    | cannot | PATCH  | rdf     | C         | inherited | [403]                | 403        |
      | Bob    | cannot | PATCH  | fictive | C         | inherited | [403]                | 403        |
      | Public | cannot | PATCH  | rdf     | no        | WAC       | [401]                | 401        |
      | Public | cannot | PATCH  | rdf     | WAC       | inherited | [401]                | 401        |
      | Public | cannot | PATCH  | fictive | WAC       | inherited | [401]                | 401        |

  Scenario Outline: <agent> <result> <method> a <type> resource, when Bob has <container> access to the container and <resource> access to the resource
    * def testResource = utils.createResource(container, resource, type, 'agent', webIds.bob)
    Given url testResource.url
    And headers utils.authHeaders(method, testResource.url, agent)
    And retry until utils.includesExpectedStatus(responseStatus, <status>)
    When method <method>
    Examples:
      | agent  | result | method | type      | container | resource  | status               |
      | Bob    | cannot | DELETE | plain     | no        | C         | [403]                |
      | Bob    | cannot | DELETE | plain     | C         | inherited | [403]                |
      | Bob    | cannot | DELETE | fictive   | C         | inherited | [403]                |
      | Bob    | cannot | DELETE | rdf       | no        | C         | [403]                |
      | Bob    | cannot | DELETE | rdf       | C         | inherited | [403]                |
      | Bob    | cannot | DELETE | container | no        | C         | [403]                |
      | Bob    | cannot | DELETE | container | C         | inherited | [403]                |
      | Bob    | cannot | DELETE | plain     | no        | A         | [403]                |
      | Bob    | cannot | DELETE | plain     | A         | inherited | [403]                |
      | Bob    | cannot | DELETE | fictive   | A         | inherited | [403]                |
      | Bob    | cannot | DELETE | rdf       | no        | A         | [403]                |
      | Bob    | cannot | DELETE | rdf       | A         | inherited | [403]                |
      | Bob    | cannot | DELETE | container | no        | A         | [403]                |
      | Bob    | cannot | DELETE | container | A         | inherited | [403]                |
      | Bob    | cannot | DELETE | plain     | no        | W         | [403]                |
      | Bob    | can    | DELETE | plain     | W         | inherited | [200, 202, 204, 205] |
      | Bob    | cannot | DELETE | fictive   | W         | inherited | [403]                |
      | Bob    | cannot | DELETE | rdf       | no        | W         | [403]                |
      | Bob    | can    | DELETE | rdf       | W         | inherited | [200, 202, 204, 205] |
      | Bob    | cannot | DELETE | container | no        | W         | [403]                |
      | Bob    | cannot | DELETE | container | W         | inherited | [403]                |
      | Public | cannot | DELETE | plain     | no        | WAC       | [401]                |
      | Public | cannot | DELETE | plain     | WAC       | inherited | [401]                |
      | Public | cannot | DELETE | fictive   | WAC       | inherited | [401]                |
      | Public | cannot | DELETE | rdf       | no        | WAC       | [401]                |
      | Public | cannot | DELETE | rdf       | WAC       | inherited | [401]                |
      | Public | cannot | DELETE | container | no        | WAC       | [401]                |
      | Public | cannot | DELETE | container | WAC       | inherited | [401]                |
