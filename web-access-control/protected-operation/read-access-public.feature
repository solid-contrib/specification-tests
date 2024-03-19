Feature: Public agents can read (and only that) a resource when granted read access
  # Grant public agents (setPublicAccess):
  # - restricted access or no access to the parent container
  # - restricted access to the test resources, or inherited access for fictive resources
  Background: Create test resources with correct access modes
    * table resources
      | type        | container | resource    |
      | 'plain'     | 'no'      | 'R'         |
      | 'plain'     | 'R'       | 'inherited' |
      | 'fictive'   | 'R'       | 'inherited' |
      | 'rdf'       | 'no'      | 'R'         |
      | 'rdf'       | 'R'       | 'inherited' |
      | 'container' | 'no'      | 'R'         |
      | 'container' | 'R'       | 'inherited' |
    * def utils = callonce read('common.feature') ({resources, subject: 'public'})

  Scenario Outline: <agent> <result> read a <type> resource (<method>), when a public agent has <container> access to the container and <resource> access to the resource
    * def testResource = utils.testResources[utils.getResourceKey(container, resource, type)]
    Given url testResource.url
    And headers utils.authHeaders(method, testResource.url, agent)
    And retry until responseStatus == <status>
    When method <method>
    Examples:
      | agent  | result | method  | type      | container | resource  | status |
      | Bob    | can    | GET     | plain     | no        | R         | 200    |
      | Bob    | can    | GET     | plain     | R         | inherited | 200    |
      | Bob    | can    | GET     | fictive   | R         | inherited | 404    |
      | Bob    | can    | GET     | rdf       | no        | R         | 200    |
      | Bob    | can    | GET     | rdf       | R         | inherited | 200    |
      | Bob    | can    | GET     | container | no        | R         | 200    |
      | Bob    | can    | GET     | container | R         | inherited | 200    |
      | Bob    | can    | HEAD    | plain     | no        | R         | 200    |
      | Bob    | can    | HEAD    | plain     | R         | inherited | 200    |
      | Bob    | can    | HEAD    | fictive   | R         | inherited | 404    |
      | Bob    | can    | HEAD    | rdf       | no        | R         | 200    |
      | Bob    | can    | HEAD    | rdf       | R         | inherited | 200    |
      | Bob    | can    | HEAD    | container | no        | R         | 200    |
      | Bob    | can    | HEAD    | container | R         | inherited | 200    |

    @publicagent
    Examples:
      | agent  | result | method  | type      | container | resource  | status |
      | Public | can    | GET     | plain     | no        | R         | 200    |
      | Public | can    | GET     | plain     | R         | inherited | 200    |
      | Public | can    | GET     | fictive   | R         | inherited | 404    |
      | Public | can    | GET     | rdf       | no        | R         | 200    |
      | Public | can    | GET     | rdf       | R         | inherited | 200    |
      | Public | can    | GET     | container | no        | R         | 200    |
      | Public | can    | GET     | container | R         | inherited | 200    |
      | Public | can    | HEAD    | plain     | no        | R         | 200    |
      | Public | can    | HEAD    | plain     | R         | inherited | 200    |
      | Public | can    | HEAD    | fictive   | R         | inherited | 404    |
      | Public | can    | HEAD    | rdf       | no        | R         | 200    |
      | Public | can    | HEAD    | rdf       | R         | inherited | 200    |
      | Public | can    | HEAD    | container | no        | R         | 200    |
      | Public | can    | HEAD    | container | R         | inherited | 200    |

  Scenario Outline: <agent> <result> <method> to a <type> resource, when a public agent has <container> access to the container and <resource> access to the resource
    * def testResource = utils.testResources[utils.getResourceKey(container, resource, type)]
    Given url testResource.url
    And headers utils.authHeaders(method, testResource.url, agent)
    And header Content-Type = 'text/turtle'
    And request '@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>. <> rdfs:comment "Bob added this.".'
    And retry until match <status> contains responseStatus
    When method <method>
    Examples:
      | agent  | result | method | type      | container | resource  | status     |
      | Bob    | cannot | PUT    | rdf       | no        | R         | [403]      |
      | Bob    | cannot | PUT    | rdf       | R         | inherited | [403]      |
      | Bob    | cannot | PUT    | fictive   | R         | inherited | [403]      |
      | Bob    | cannot | PUT    | container | no        | R         | [403]      |
      | Bob    | cannot | PUT    | container | R         | inherited | [403]      |
      | Bob    | cannot | POST   | rdf       | no        | R         | [403]      |
      | Bob    | cannot | POST   | rdf       | R         | inherited | [403]      |
      | Bob    | cannot | POST   | fictive   | R         | inherited | [403, 404] |
      | Bob    | cannot | POST   | container | no        | R         | [403]      |
      | Bob    | cannot | POST   | container | R         | inherited | [403]      |
      | Public | cannot | PUT    | rdf       | no        | R         | [401]      |
      | Public | cannot | PUT    | rdf       | R         | inherited | [401]      |
      | Public | cannot | PUT    | fictive   | R         | inherited | [401]      |
      | Public | cannot | PUT    | container | no        | R         | [401]      |
      | Public | cannot | PUT    | container | R         | inherited | [401]      |
      | Public | cannot | POST   | rdf       | no        | R         | [401]      |
      | Public | cannot | POST   | rdf       | R         | inherited | [401]      |
      | Public | cannot | POST   | fictive   | R         | inherited | [401, 404] |
      | Public | cannot | POST   | container | no        | R         | [401]      |
      | Public | cannot | POST   | container | R         | inherited | [401]      |

  Scenario Outline: <agent> <result> <method> to a <type> resource, when a public agent has <container> access to the container and <resource> access to the resource
    * def testResource = utils.testResources[utils.getResourceKey(container, resource, type)]
    Given url testResource.url
    And headers utils.authHeaders(method, testResource.url, agent)
    And header Content-Type = 'text/n3'
    And request '@prefix solid: <http://www.w3.org/ns/solid/terms#>. _:insert a solid:InsertDeletePatch; solid:inserts { <> a <http://example.org#Foo> . }.'
    And retry until responseStatus == <status>
    When method <method>
    Examples:
      | agent  | result | method | type      | container | resource  | status |
      | Bob    | cannot | PATCH  | rdf       | no        | R         | 403    |
      | Bob    | cannot | PATCH  | rdf       | R         | inherited | 403    |
      | Bob    | cannot | PATCH  | fictive   | R         | inherited | 403    |
      | Bob    | cannot | PATCH  | container | no        | R         | 403    |
      | Bob    | cannot | PATCH  | container | R         | inherited | 403    |
      | Public | cannot | PATCH  | rdf       | no        | R         | 401    |
      | Public | cannot | PATCH  | rdf       | R         | inherited | 401    |
      | Public | cannot | PATCH  | fictive   | R         | inherited | 401    |
      | Public | cannot | PATCH  | container | no        | R         | 401    |
      | Public | cannot | PATCH  | container | R         | inherited | 401    |

  Scenario Outline: <agent> <result> <method> to a <type> resource, when a public agent has <container> access to the container and <resource> access to the resource
    * def testResource = utils.testResources[utils.getResourceKey(container, resource, type)]
    Given url testResource.url
    And headers utils.authHeaders(method, testResource.url, agent)
    And header Content-Type = 'text/plain'
    And request "Bob's text"
    And retry until match <status> contains responseStatus
    When method <method>
    Examples:
      | agent  | result | method | type    | container | resource  | status          |
      | Bob    | cannot | PUT    | plain   | no        | R         | [403]           |
      | Bob    | cannot | PUT    | plain   | R         | inherited | [403]           |
      | Bob    | cannot | PUT    | fictive | R         | inherited | [403]           |
      | Bob    | cannot | POST   | plain   | no        | R         | [403]           |
      | Bob    | cannot | POST   | plain   | R         | inherited | [403]           |
      | Bob    | cannot | POST   | fictive | R         | inherited | [403, 404]      |
      | Bob    | cannot | PATCH  | plain   | no        | R         | [403, 405, 415] |
      | Bob    | cannot | PATCH  | plain   | R         | inherited | [403, 405, 415] |
      | Bob    | cannot | PATCH  | fictive | R         | inherited | [403, 405, 415] |
      | Public | cannot | PUT    | plain   | no        | R         | [401]           |
      | Public | cannot | PUT    | plain   | R         | inherited | [401]           |
      | Public | cannot | PUT    | fictive | R         | inherited | [401]           |
      | Public | cannot | POST   | plain   | no        | R         | [401]           |
      | Public | cannot | POST   | plain   | R         | inherited | [401]           |
      | Public | cannot | POST   | fictive | R         | inherited | [401, 404]      |
      | Public | cannot | PATCH  | plain   | no        | R         | [401, 405, 415] |
      | Public | cannot | PATCH  | plain   | R         | inherited | [401, 405, 415] |
      | Public | cannot | PATCH  | fictive | R         | inherited | [401, 405, 415] |

  Scenario Outline: <agent> <result> <method> a <type> resource, when a public agent has <container> access to the container and <resource> access to the resource
    * def testResource = utils.testResources[utils.getResourceKey(container, resource, type)]
    Given url testResource.url
    And headers utils.authHeaders(method, testResource.url, agent)
    And retry until match <status> contains responseStatus
    When method <method>
    Examples:
      | agent  | result | method | type      | container | resource  | status     |
      | Bob    | cannot | DELETE | plain     | no        | R         | [403]      |
      | Bob    | cannot | DELETE | plain     | R         | inherited | [403]      |
      | Bob    | cannot | DELETE | fictive   | R         | inherited | [403, 404] |
      | Bob    | cannot | DELETE | rdf       | no        | R         | [403]      |
      | Bob    | cannot | DELETE | rdf       | R         | inherited | [403]      |
      | Bob    | cannot | DELETE | container | no        | R         | [403]      |
      | Bob    | cannot | DELETE | container | R         | inherited | [403]      |
      | Public | cannot | DELETE | plain     | no        | R         | [401]      |
      | Public | cannot | DELETE | plain     | R         | inherited | [401]      |
      | Public | cannot | DELETE | fictive   | R         | inherited | [401, 404] |
      | Public | cannot | DELETE | rdf       | no        | R         | [401]      |
      | Public | cannot | DELETE | rdf       | R         | inherited | [401]      |
      | Public | cannot | DELETE | container | no        | R         | [401]      |
      | Public | cannot | DELETE | container | R         | inherited | [401]      |
