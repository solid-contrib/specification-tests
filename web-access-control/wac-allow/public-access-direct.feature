Feature: The WAC-Allow header shows public access modes for a public agent when given direct access

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
        const testContainer = rootTestContainer.reserveContainer();
        const resources = {}
        for (const row of testModes) {
          const resource = testContainer.createResource('.ttl', karate.readAsString('../fixtures/example.ttl'), 'text/turtle');
          const access = resource.accessDatasetBuilder
                .setPublicAccess(resource.url, row.modes)
                .build();
          resource.accessDataset = access;
          resources[row.test] = resource;
        }
        return resources;
      }
    """
    * def resources = callonce setup
    * def resource = resources['read']

  Scenario: There is an acl on the resource containing a public agent
    Given url resource.aclUrl
    And headers clients.alice.getAuthHeaders('GET', resource.aclUrl)
    And header Accept = 'text/turtle'
    When method GET
    Then status 200
    And match header Content-Type contains 'text/turtle'
    And assert parse(response, 'text/turtle', resource.url).contains(null, iri(ACL, 'agentClass'), iri(FOAF, 'Agent'))

  Scenario: There is no acl on the parent that references a public agent
    Given url resource.container.aclUrl
    And headers clients.alice.getAuthHeaders('GET', resource.container.aclUrl)
    And header Accept = 'text/turtle'
    When method GET
    Then assert responseStatus == 404

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
