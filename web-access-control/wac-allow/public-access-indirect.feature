Feature: The WAC-Allow header shows public access modes for a public agent when given indirect access via a container

  Background: Create test resources giving a public agent different access modes
    * table testModes
      | test | modes | check |
      | 'read' | ['read'] | 'only' |
      | 'read/control' | ['read', 'control'] | 'only' |
      | 'read/write' | ['read', 'write'] | '' |
      | 'read/append' | ['read', 'append'] | 'only' |
      | 'read/write/append' | ['read', 'write', 'append'] | 'only' |

    * def setup =
    """
      function() {
        const resources = {}
        for (const row of testModes) {
          const testContainer = rootTestContainer.createContainer();
          const access = testContainer.accessDatasetBuilder
                .setInheritablePublicAccess(testContainer.url, row.modes)
                .build();
          testContainer.accessDataset = access;
          const resource = testContainer.createResource('.ttl', karate.readAsString('../fixtures/example.ttl'), 'text/turtle');
          resources[row.test] = resource;
        }
        return resources;
      }
    """
    * def resources = callonce setup
    * def resource = resources['read']

  Scenario: There is no acl on the resource that references a public agent
    Given url resource.aclUrl
    And headers clients.alice.getAuthHeaders('GET', resource.aclUrl)
    And header Accept = 'text/turtle'
    When method GET
    Then status 404

  Scenario: There is an acl on the parent containing a public agent
    Given url resource.container.aclUrl
    And headers clients.alice.getAuthHeaders('GET', resource.container.aclUrl)
    And header Accept = 'text/turtle'
    When method GET
    Then status 200
    And match header Content-Type contains 'text/turtle'
    # check array of triples contains one with the given predicate-object
    # TODO: this would be better implemented as hasStatement(null, <http://www.w3.org/ns/auth/acl#agentClass> <http://xmlns.com/foaf/0.1/Agent>)
    And match RDFUtils.turtleToTripleArray(response, resource.url) contains '#? _.includes("<http://www.w3.org/ns/auth/acl#agentClass> <http://xmlns.com/foaf/0.1/Agent>")'

  Scenario: Alice calls GET and the header shows full access for user
    Given url resource.url
    And headers clients.alice.getAuthHeaders('GET', resource.url)
    When method GET
    Then status 200
    And match header WAC-Allow != null
    * def result = parseWacAllowHeader(responseHeaders)
    And match result.user contains ['read', 'write', 'control']
    # note append is sometimes seen but redundant since it is a subset of write

  Scenario: Alice calls HEAD and the header shows full access for user
    Given url resource.url
    And headers clients.alice.getAuthHeaders('HEAD', resource.url)
    When method HEAD
    Then status 200
    And match header WAC-Allow != null
    * def result = parseWacAllowHeader(responseHeaders)
    And match result.user contains ['read', 'write', 'control']

  Scenario Outline: A public user calls GET on a resource with <test> access and the header shows <test> access for publi
    Given url resources['<test>'].url
    When method GET
    Then status 200
    And match header WAC-Allow != null
    * def result = parseWacAllowHeader(responseHeaders)
    And match result.public contains <check> <modes>
    # user access is implied by public
    And match result.user contains <check> <modes>
    Examples:
      | testModes |

  Scenario Outline: A public user calls HEAD on a resource with <test> access and the header shows <test> access for public
    Given url resources['<test>'].url
    When method HEAD
    Then status 200
    And match header WAC-Allow != null
    * def result = parseWacAllowHeader(responseHeaders)
    And match result.public contains <check> <modes>
    And match result.user contains <check> <modes>
    Examples:
      | testModes |
