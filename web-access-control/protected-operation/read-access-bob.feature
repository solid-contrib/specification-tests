Feature: Only Bob can read (and only that) a resource when granted read access
  Background: Create test resources with correct access modes
    * def authHeaders = (method, url, public) => !public ? clients.bob.getAuthHeaders(method, url) : {}
    * def createResources =
    """
      function (modes) {
        const testContainer = rootTestContainer.reserveContainer()
        const plainResource = testContainer.createResource('.txt', 'Hello', 'text/plain')
        plainResource.accessDataset = plainResource.accessDatasetBuilder.setAgentAccess(plainResource.url, webIds.bob, modes).build()
        const rdfResource = testContainer.createResource('.ttl', karate.readAsString('../fixtures/example.ttl'), 'text/turtle')
        rdfResource.accessDataset = rdfResource.accessDatasetBuilder.setAgentAccess(rdfResource.url, webIds.bob, modes).build()
        const container = testContainer.createContainer()
        container.accessDataset = container.accessDatasetBuilder.setAgentAccess(container.url, webIds.bob, modes).build()
        return { plain: plainResource, rdf: rdfResource, container: container }
      }
    """
    # Create 3 test resources with read access for Bob
    * def testsR = callonce createResources ['read']
    # Create 3 test resources with append, write, control access for Bob
    * def testsAWC = callonce createResources ['append', 'write', 'control']

  Scenario Outline: <agent> read a <type> resource (<method>) to which Bob has <mode> access
    Given url tests<mode>[type].url
    And headers authHeaders(method, tests<mode>[type].url, public)
    When method <method>
    Then status <status>
    Examples:
      | agent         | type      | mode | method | public! | status |
      | Bob can       | plain     | R    | GET    | false   | 200    |
      | Bob can       | rdf       | R    | GET    | false   | 200    |
      | Bob can       | container | R    | GET    | false   | 200    |
      | Bob can       | plain     | R    | HEAD   | false   | 200    |
      | Bob can       | rdf       | R    | HEAD   | false   | 200    |
      | Bob can       | container | R    | HEAD   | false   | 200    |
      | Public cannot | plain     | R    | GET    | true    | 401    |
      | Public cannot | rdf       | R    | GET    | true    | 401    |
      | Public cannot | container | R    | GET    | true    | 401    |
      | Public cannot | plain     | R    | HEAD   | true    | 401    |
      | Public cannot | rdf       | R    | HEAD   | true    | 401    |
      | Public cannot | container | R    | HEAD   | true    | 401    |
      | Bob cannot    | plain     | AWC  | GET    | false   | 403    |
      | Bob cannot    | rdf       | AWC  | GET    | false   | 403    |
      | Bob cannot    | container | AWC  | GET    | false   | 403    |
      | Bob cannot    | plain     | AWC  | HEAD   | false   | 403    |
      | Bob cannot    | rdf       | AWC  | HEAD   | false   | 403    |
      | Bob cannot    | container | AWC  | HEAD   | false   | 403    |
      | Public cannot | plain     | AWC  | GET    | true    | 401    |
      | Public cannot | rdf       | AWC  | GET    | true    | 401    |
      | Public cannot | container | AWC  | GET    | true    | 401    |
      | Public cannot | plain     | AWC  | HEAD   | true    | 401    |
      | Public cannot | rdf       | AWC  | HEAD   | true    | 401    |
      | Public cannot | container | AWC  | HEAD   | true    | 401    |

  Scenario Outline: <agent> cannot <method> to a <type> resource to which Bob has <mode> access
    Given url tests<mode>[type].url
    And headers authHeaders(method, tests<mode>[type].url, public)
    And header Content-Type = 'text/turtle'
    And request '@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>. <> rdfs:comment "Bob added this.".'
    When method <method>
    Then status <status>
    Examples:
      | agent  | type      | mode | method | public! | status |
      | Bob    | rdf       | R    | PUT    | false   | 403    |
      | Bob    | container | R    | PUT    | false   | 403    |
      | Bob    | rdf       | R    | POST   | false   | 403    |
      | Bob    | container | R    | POST   | false   | 403    |
      | Public | rdf       | R    | PUT    | true    | 401    |
      | Public | container | R    | PUT    | true    | 401    |
      | Public | rdf       | R    | POST   | true    | 401    |
      | Public | container | R    | POST   | true    | 401    |

  Scenario Outline: <agent> cannot <method> to a <type> resource to which Bob has <mode> access
    Given url tests<mode>[type].url
    And headers authHeaders(method, tests<mode>[type].url, public)
    And header Content-Type = 'application/sparql-update'
    And request 'INSERT DATA { <> a <http://example.org/Foo> . }'
    When method <method>
    Then status <status>
    Examples:
      | agent  | type      | mode | method | public! | status |
      | Bob    | rdf       | R    | PATCH  | false   | 403    |
      | Bob    | container | R    | PATCH  | false   | 403    |
      | Public | rdf       | R    | PATCH  | true    | 401    |
      | Public | container | R    | PATCH  | true    | 401    |

  Scenario Outline: <agent> cannot <method> to a <type> resource to which Bob has <mode> access
    Given url tests<mode>[type].url
    And headers authHeaders(method, tests<mode>[type].url, public)
    And header Content-Type = 'text/plain'
    And request "Bob's text"
    When method <method>
    Then match <status> contains responseStatus
    Examples:
      | agent  | type      | mode | method | public! | status     |
      | Bob    | plain     | R    | PUT    | false   | [403]      |
      | Bob    | plain     | R    | POST   | false   | [403]      |
      | Bob    | plain     | R    | PATCH  | false   | [403, 501] |
      | Public | plain     | R    | PUT    | true    | [401]      |
      | Public | plain     | R    | POST   | true    | [401]      |
      | Public | plain     | R    | PATCH  | true    | [401, 501] |

  Scenario Outline: <agent> cannot <method> a <type> resource to which Bob has <mode> access
    Given url tests<mode>[type].url
    And headers authHeaders(method, tests<mode>[type].url, public)
    When method <method>
    Then status <status>
    Examples:
      | agent | type      | mode | method | public! | status |
      | Bob   | plain     | R    | DELETE | false   | 403    |
      | Bob   | rdf       | R    | DELETE | false   | 403    |
      | Bob   | container | R    | DELETE | false   | 403    |
