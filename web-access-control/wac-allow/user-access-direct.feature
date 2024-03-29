Feature: The WAC-Allow header shows user access modes for Bob when given direct access

  Background: Create test resources giving Bob different access modes
    * def modesList = [['read'], ['read', 'control'], ['read', 'write'], ['read', 'append'], ['read', 'write', 'append']]
    * def setup =
    """
      function() {
        const testContainer = rootTestContainer.reserveContainer();
        const resources = {}
        for (const modes of modesList) {
          const resource = testContainer.createResource('.ttl', karate.readAsString('../fixtures/example.ttl'), 'text/turtle');
          const access = resource.accessDatasetBuilder
                .setAgentAccess(resource.url, webIds.bob, modes)
                .build();
          resource.accessDataset = access;
          resources[modes.join('/')] = resource;
        }
        return resources;
      }
    """
    * def resources = callonce setup
    * def resource = resources['read']

  @setup
  Scenario: Define test cases
    * table testModes
      | test | modes | check |
      | 'read' | ['read'] | 'only' |
      | 'read/control' | ['read', 'control'] | 'only' |
      | 'read/write' | ['read', 'write'] | '' |
      | 'read/append' | ['read', 'append'] | 'only' |
      | 'read/write/append' | ['read', 'write', 'append'] | 'only' |

  Scenario: There is an acl on the resource containing Bob's WebID
    Given url resource.aclUrl
    And headers clients.alice.getAuthHeaders('GET', resource.aclUrl)
    And header Accept = 'text/turtle'
    When method GET
    Then status 200
    And match header Content-Type contains 'text/turtle'
    And match response contains webIds.bob

  Scenario: There is no acl on the parent that references Bob
    Given url resource.container.aclUrl
    And headers clients.alice.getAuthHeaders('GET', resource.container.aclUrl)
    And header Accept = 'text/turtle'
    When method GET
    Then assert responseStatus == 404 || !response.includes(webIds.bob)

  Scenario: Alice calls GET and the header shows full access for user
    Given url resource.url
    And headers clients.alice.getAuthHeaders('GET', resource.url)
    When method GET
    Then status 200
    And match header WAC-Allow != null
    * def result = parseWacAllowHeader(responseHeaders)
    And match result.user contains ['read', 'write', 'control']
    # note append is sometimes seen but redundant since it is a subset of write
    And match result.public == []

  Scenario: Alice calls HEAD and the header shows full access for user
    Given url resource.url
    And headers clients.alice.getAuthHeaders('HEAD', resource.url)
    When method HEAD
    Then status 200
    And match header WAC-Allow != null
    * def result = parseWacAllowHeader(responseHeaders)
    And match result.user contains ['read', 'write', 'control']
    And match result.public == []

  Scenario Outline: Bob calls GET on a resource with <test> access and the header shows <test> access for user
    Given url resources['<test>'].url
    And headers clients.bob.getAuthHeaders('GET', resources['<test>'].url)
    When method GET
    Then status 200
    And match header WAC-Allow != null
    * def result = parseWacAllowHeader(responseHeaders)
    And match result.user contains <check> <modes>
    And match result.public == []
    Examples:
      | karate.setup().testModes |

  Scenario Outline: Bob calls HEAD on a resource with <test> access and the header shows <test> access for user
    Given url resources['<test>'].url
    And headers clients.bob.getAuthHeaders('HEAD', resources['<test>'].url)
    When method HEAD
    Then status 200
    And match header WAC-Allow != null
    * def result = parseWacAllowHeader(responseHeaders)
    And match result.user contains <check> <modes>
    And match result.public == []
    Examples:
      | karate.setup().testModes |
