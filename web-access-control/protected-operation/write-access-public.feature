Feature: Only authenticated agents can write (and only that) a resource when granted write access
  # Grant public agents (setPublicAccess):
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
    * def utils = callonce read('common.feature') ({resources, subject: 'public'})

  Scenario Outline: <agent> <result> read a <type> resource (<method>), when a public agent has <container> access to the container and <resource> access to the resource
    * def testResource = utils.testResources[utils.getResourceKey(container, resource, type)]
    Given url testResource.url
    And retry until responseStatus == <status>
    When method <method>
    Examples:
      | agent  | result | method  | type      | container | resource  | status |
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

  @publicagent
  Scenario Outline: <agent> <result> write a <type> resource (<method>) and cannot read it, when a public agent has <container> access to the container and <resource> access to the resource
    * def testResource = utils.createResource(container, resource, type, 'public')
    * def requestData = utils.getRequestData(type)
    Given url testResource.url
    And header Content-Type = requestData.contentType
    And request requestData.requestBody
    And retry until utils.includesExpectedStatus(responseStatus, <writeStatus>)
    When method <method>
    # Server may return payload with information about the operation e.g. "Created" so check it hasn't leaked the data which was PUT
    And string responseString = response
    And match responseString !contains requestData.responseShouldNotContain

    When method GET
    Then status <readStatus>

    Examples:
      | agent  | result | method | type      | container | resource  | writeStatus          | readStatus |
      | Public | can    | PUT    | rdf       | no        | W         | [200, 201, 204, 205] | 401        |
      | Public | can    | PUT    | rdf       | W         | inherited | [200, 201, 204, 205] | 401        |
      | Public | can    | PUT    | plain     | no        | W         | [200, 201, 204, 205] | 401        |
      | Public | can    | PUT    | plain     | W         | inherited | [200, 201, 204, 205] | 401        |
      | Public | can    | PUT    | fictive   | W         | inherited | [201]                | 401        |
      | Public | can    | POST   | container | no        | W         | [200, 201, 204, 205] | 401        |
      | Public | can    | POST   | container | W         | inherited | [200, 201, 204, 205] | 401        |
      | Public | can    | POST   | container | no        | A         | [200, 201, 204, 205] | 401        |
      | Public | can    | POST   | container | A         | inherited | [200, 201, 204, 205] | 401        |

  @publicagent
  Scenario Outline: <agent> <result> <method> to a <type> resource, when a public agent has <container> access to the container and <resource> access to the resource
    * def testResource = utils.createResource(container, resource, type, 'public')
    * def requestData = utils.getRequestData('text/n3')
    Given url testResource.url
    And header Content-Type = requestData.contentType
    And request requestData.requestBody
    And retry until utils.includesExpectedStatus(responseStatus, <writeStatus>)
    When method <method>
    # Server may return payload with information about the operation e.g. "Created" so check it hasn't leaked the data which was PUT
    And string responseString = response
    And match responseString !contains requestData.responseShouldNotContain

    When method GET
    Then status <readStatus>

    Examples:
      | agent  | result | method | type    | container | resource  | writeStatus          | readStatus |
      | Public | can    | PATCH  | rdf     | no        | W         | [200, 201, 204, 205] | 401        |
      | Public | can    | PATCH  | rdf     | W         | inherited | [200, 201, 204, 205] | 401        |
      | Public | can    | PATCH  | fictive | W         | inherited | [200, 201, 204, 205] | 401        |
      | Public | can    | PATCH  | rdf     | no        | A         | [200, 201, 204, 205] | 401        |
      | Public | can    | PATCH  | rdf     | A         | inherited | [200, 201, 204, 205] | 401        |
      | Public | can    | PATCH  | fictive | A         | inherited | [200, 201, 204, 205] | 401        |
      | Public | cannot | PATCH  | rdf     | no        | C         | [401]                | 401        |
      | Public | cannot | PATCH  | rdf     | C         | inherited | [401]                | 401        |
      | Public | cannot | PATCH  | fictive | C         | inherited | [401]                | 401        |

  @publicagent
  Scenario Outline: <agent> <result> <method> a <type> resource, when a public agent has <container> access to the container and <resource> access to the resource
    * def testResource = utils.createResource(container, resource, type, 'public')
    Given url testResource.url
    And retry until utils.includesExpectedStatus(responseStatus, <status>)
    When method <method>
    Examples:
      | agent  | result | method | type      | container | resource  | status               |
      | Public | cannot | DELETE | plain     | no        | C         | [401]                |
      | Public | cannot | DELETE | plain     | C         | inherited | [401]                |
      | Public | cannot | DELETE | fictive   | C         | inherited | [401]                |
      | Public | cannot | DELETE | rdf       | no        | C         | [401]                |
      | Public | cannot | DELETE | rdf       | C         | inherited | [401]                |
      | Public | cannot | DELETE | container | no        | C         | [401]                |
      | Public | cannot | DELETE | container | C         | inherited | [401]                |
      | Public | cannot | DELETE | plain     | no        | A         | [401]                |
      | Public | cannot | DELETE | plain     | A         | inherited | [401]                |
      | Public | cannot | DELETE | fictive   | A         | inherited | [401]                |
      | Public | cannot | DELETE | rdf       | no        | A         | [401]                |
      | Public | cannot | DELETE | rdf       | A         | inherited | [401]                |
      | Public | cannot | DELETE | container | no        | A         | [401]                |
      | Public | cannot | DELETE | container | A         | inherited | [401]                |
      | Public | cannot | DELETE | plain     | no        | W         | [401]                |
      | Public | can    | DELETE | plain     | W         | inherited | [200, 202, 204, 205] |
      | Public | cannot | DELETE | fictive   | W         | inherited | [401]                |
      | Public | cannot | DELETE | rdf       | no        | W         | [401]                |
      | Public | can    | DELETE | rdf       | W         | inherited | [200, 202, 204, 205] |
      | Public | cannot | DELETE | container | no        | W         | [401]                |
      | Public | cannot | DELETE | container | W         | inherited | [401]                |
