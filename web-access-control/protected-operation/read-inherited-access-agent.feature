Feature: Only authenticated agents can read (and only that) a resource when granted inherited read access
  # Grant authenticated agents (setAuthenticatedAccess/setInheritableAuthenticatedAccess):
  # - full access to the parent container (to ensure the tests are specific to the resource)
  # - restricted access to the any contained resources via the parent
  Background: Create test resources with correct access modes
    * def authHeaders = (method, url, public) => !public ? clients.bob.getAuthHeaders(method, url) : {}
    * def createResources =
    """
      function (modes) {
        const testContainer = rootTestContainer.createContainer()
        testContainer.accessDataset = testContainer.accessDatasetBuilder
          .setAuthenticatedAccess(testContainer.url, ['read', 'write', 'append', 'control'])
          .setInheritableAuthenticatedAccess(testContainer.url, modes).build()
        const plainResource = testContainer.createResource('.txt', 'Hello', 'text/plain')
        const fictiveResource = testContainer.reserveResource('.txt')
        const rdfResource = testContainer.createResource('.ttl', karate.readAsString('../fixtures/example.ttl'), 'text/turtle')
        const container = testContainer.createContainer()
        return { plain: plainResource, fictive: fictiveResource, rdf: rdfResource, container: container }
      }
    """
    # Create 3 test resources with read access for authenticated agents
    * def testsR = callonce createResources ['read']
    # Create 3 test resources with append, write, control access for authenticated agents
    * def testsAWC = callonce createResources ['append', 'write', 'control']

  Scenario Outline: <agent> read a <type> resource (<method>) to which an authenticated agent has inherited <mode> access
    Given url tests<mode>[type].url
    And headers authHeaders(method, tests<mode>[type].url, public)
    When method <method>
    Then status <status>
    Examples:
      | agent         | type      | mode | method | public! | status |
      | Bob can       | plain     | R    | GET    | false   | 200    |
      | Bob can       | fictive   | R    | GET    | false   | 404    |
      | Bob can       | rdf       | R    | GET    | false   | 200    |
      | Bob can       | container | R    | GET    | false   | 200    |
      | Bob can       | plain     | R    | HEAD   | false   | 200    |
      | Bob can       | fictive   | R    | HEAD   | false   | 404    |
      | Bob can       | rdf       | R    | HEAD   | false   | 200    |
      | Bob can       | container | R    | HEAD   | false   | 200    |
      | Public cannot | plain     | R    | GET    | true    | 401    |
      | Public cannot | fictive   | R    | GET    | true    | 401    |
      | Public cannot | rdf       | R    | GET    | true    | 401    |
      | Public cannot | container | R    | GET    | true    | 401    |
      | Public cannot | plain     | R    | HEAD   | true    | 401    |
      | Public cannot | fictive   | R    | HEAD   | true    | 401    |
      | Public cannot | rdf       | R    | HEAD   | true    | 401    |
      | Public cannot | container | R    | HEAD   | true    | 401    |
      | Bob cannot    | plain     | AWC  | GET    | false   | 403    |
      | Bob cannot    | fictive   | AWC  | GET    | false   | 403    |
      | Bob cannot    | rdf       | AWC  | GET    | false   | 403    |
      | Bob cannot    | container | AWC  | GET    | false   | 403    |
      | Bob cannot    | plain     | AWC  | HEAD   | false   | 403    |
      | Bob cannot    | fictive   | AWC  | HEAD   | false   | 403    |
      | Bob cannot    | rdf       | AWC  | HEAD   | false   | 403    |
      | Bob cannot    | container | AWC  | HEAD   | false   | 403    |
      | Public cannot | plain     | AWC  | GET    | true    | 401    |
      | Public cannot | fictive   | AWC  | GET    | true    | 401    |
      | Public cannot | rdf       | AWC  | GET    | true    | 401    |
      | Public cannot | container | AWC  | GET    | true    | 401    |
      | Public cannot | plain     | AWC  | HEAD   | true    | 401    |
      | Public cannot | fictive   | AWC  | HEAD   | true    | 401    |
      | Public cannot | rdf       | AWC  | HEAD   | true    | 401    |
      | Public cannot | container | AWC  | HEAD   | true    | 401    |

  Scenario Outline: <agent> cannot <method> to a <type> resource to which an authenticated agent has inherited <mode> access
    Given url tests<mode>[type].url
    And headers authHeaders(method, tests<mode>[type].url, public)
    And header Content-Type = 'text/turtle'
    And request '@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>. <> rdfs:comment "Bob added this.".'
    When method <method>
    Then status <status>
    Examples:
      | agent  | type      | mode | method | public! | status |
      | Bob    | rdf       | R    | PUT    | false   | 403    |
      | Bob    | fictive   | R    | PUT    | false   | 403    |
      | Bob    | container | R    | PUT    | false   | 403    |
      | Bob    | rdf       | R    | POST   | false   | 403    |
      | Bob    | fictive   | R    | POST   | false   | 404    |
      | Bob    | container | R    | POST   | false   | 403    |
      | Public | rdf       | R    | PUT    | true    | 401    |
      | Public | fictive   | R    | PUT    | true    | 401    |
      | Public | container | R    | PUT    | true    | 401    |
      | Public | rdf       | R    | POST   | true    | 401    |
      | Public | fictive   | R    | POST   | true    | 401    |
      | Public | container | R    | POST   | true    | 401    |

  Scenario Outline: <agent> cannot <method> to a <type> resource to which an authenticated agent has inherited <mode> access
    Given url tests<mode>[type].url
    And headers authHeaders(method, tests<mode>[type].url, public)
    And header Content-Type = 'text/n3'
    And request '@prefix solid: <http://www.w3.org/ns/solid/terms#>. _:insert a solid:InsertDeletePatch; solid:inserts { <> a <http://example.org#Foo> . }.'
    When method <method>
    Then status <status>
    Examples:
      | agent  | type      | mode | method | public! | status |
      | Bob    | rdf       | R    | PATCH  | false   | 403    |
      | Bob    | fictive   | R    | PATCH  | false   | 403    |
      | Bob    | container | R    | PATCH  | false   | 403    |
      | Public | rdf       | R    | PATCH  | true    | 401    |
      | Public | fictive   | R    | PATCH  | true    | 401    |
      | Public | container | R    | PATCH  | true    | 401    |

  Scenario Outline: <agent> cannot <method> to a <type> resource to which an authenticated agent has inherited <mode> access
    Given url tests<mode>[type].url
    And headers authHeaders(method, tests<mode>[type].url, public)
    And header Content-Type = 'text/plain'
    And request "Bob's text"
    When method <method>
    Then match <status> contains responseStatus
    Examples:
      | agent  | type      | mode | method | public! | status          |
      | Bob    | plain     | R    | PUT    | false   | [403]           |
      | Bob    | plain     | R    | POST   | false   | [403]           |
      | Bob    | plain     | R    | PATCH  | false   | [403, 405, 415] |
      | Bob    | fictive   | R    | PUT    | false   | [403]           |
      | Bob    | fictive   | R    | POST   | false   | [404]           |
      | Bob    | fictive   | R    | PATCH  | false   | [403, 405, 415] |
      | Public | plain     | R    | PUT    | true    | [401]           |
      | Public | plain     | R    | POST   | true    | [401]           |
      | Public | plain     | R    | PATCH  | true    | [401, 405, 415] |
      | Public | fictive   | R    | PUT    | true    | [401]           |
      | Public | fictive   | R    | POST   | true    | [401]           |
      | Public | fictive   | R    | PATCH  | true    | [401, 405, 415] |

  Scenario Outline: <agent> cannot <method> a <type> resource to which an authenticated agent has inherited <mode> access
    Given url tests<mode>[type].url
    And headers authHeaders(method, tests<mode>[type].url, public)
    When method <method>
    Then status <status>
    Examples:
      | agent  | type      | mode | method | public! | status |
      | Bob    | plain     | R    | DELETE | false   | 403    |
      | Bob    | fictive   | R    | DELETE | false   | 404    |
      | Bob    | rdf       | R    | DELETE | false   | 403    |
      | Bob    | container | R    | DELETE | false   | 403    |
      | Public | plain     | R    | DELETE | true    | 401    |
      | Public | fictive   | R    | DELETE | true    | 401    |
      | Public | rdf       | R    | DELETE | true    | 401    |
      | Public | container | R    | DELETE | true    | 401    |
