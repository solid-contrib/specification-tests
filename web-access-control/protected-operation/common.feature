@ignore
Feature:

Scenario:
  * def authHeaders =
    """
      function (method, url, agent) {
        const agentLowerCase = agent.toLowerCase()
        return agentLowerCase !== 'public' ? clients[agentLowerCase].getAuthHeaders(method, url) : {}
      }
    """
  * def resourcePermissions =
    """
      function (modes) {
        if (modes && modes !== 'inherited' && modes !== 'no') {
          return Object.entries({ R: 'read', W: 'write', A: 'append', C: 'control' })
            .filter(([mode, permission]) => modes.includes(mode))
            .map(([mode, permission]) => permission)
        }
        return undefined
      }
    """
  * def getRequestData =
    """
      function (type) {
        switch(type) {
          case 'rdf':
            return {
              contentType: 'text/turtle',
              requestBody: '<> <http://www.w3.org/2000/01/rdf-schema#comment> "Bob replaced it." .',
              responseShouldNotContain: "Bob replaced it"
            }
          case 'text/n3':
            return {
              contentType: 'text/n3',
              requestBody: '@prefix solid: <http://www.w3.org/ns/solid/terms#>. _:insert a solid:InsertDeletePatch; solid:inserts { <> a <http://example.org#Foo> . }.',
              responseShouldNotContain: "http://example.org#Foo"
            }
          default:
            return {
              contentType: 'text/plain',
              requestBody: "Bob's text",
              responseShouldNotContain: "Bob's text"
            }
        }
      }
    """
  * def resourceEntry =
    """
      function (container, type) {
        switch (type) {
          case 'plain':
            return container.createResource('.txt', 'Hello', 'text/plain')
          case 'fictive':
            return container.reserveResource('.txt')
          case 'rdf':
            return container.createResource('.ttl', karate.readAsString('../fixtures/example.ttl'), 'text/turtle')
          case 'container':
            return container.createContainer()
          default:
            return undefined
        }
      }
    """
  * def createResource =
    """
      function (containerModes, resourceModes, resourceType, subject, agent) {
        const testContainerPermissions = resourcePermissions(containerModes)
        const testResourcePermissions = resourcePermissions(resourceModes)
        const testContainerInheritablePermissions = resourceModes === 'inherited'
          ? testContainerPermissions
          : undefined

        const testContainer = rootTestContainer.createContainer()
        const testResource = resourceEntry(testContainer, resourceType)

        const testContainerAccess = testContainer.accessDatasetBuilder
        if (subject === 'agent') {
          if (testContainerPermissions) {
            testContainerAccess.setAgentAccess(testContainer.url, agent, testContainerPermissions)
          }
          if (testContainerInheritablePermissions) {
            testContainerAccess.setInheritableAgentAccess(testContainer.url, agent, testContainerInheritablePermissions)
          }
        } else if (subject === 'authenticated') {
          if (testContainerPermissions) {
            testContainerAccess.setAuthenticatedAccess(testContainer.url, testContainerPermissions)
          }
          if (testContainerInheritablePermissions) {
            testContainerAccess.setInheritableAuthenticatedAccess(testContainer.url, testContainerInheritablePermissions)
          }
        } else if (subject === 'public') {
          if (testContainerPermissions) {
            testContainerAccess.setPublicAccess(testContainer.url, testContainerPermissions)
          }
          if (testContainerInheritablePermissions) {
            testContainerAccess.setInheritablePublicAccess(testContainer.url, testContainerInheritablePermissions)
          }
        }
        testContainer.accessDataset = testContainerAccess.build()

        if (resourceType !== 'fictive' && resourceModes !== 'inherited') {
          const testResourceAccess = testResource.accessDatasetBuilder
          if (testResourcePermissions) {
            if (subject === 'agent') {
              testResourceAccess.setAgentAccess(testResource.url, agent, testResourcePermissions)
            } else if (subject === 'authenticated') {
              testResourceAccess.setAuthenticatedAccess(testResource.url, testResourcePermissions)
            } else if (subject === 'public') {
              testResourceAccess.setPublicAccess(testResource.url, testResourcePermissions)
            }
          }
          testResource.accessDataset = testResourceAccess.build()
        }
        return testResource
      }
    """
  * def getResource = (container, resource, type) => testResources[`${container}:${resource}:${type}`]
  * def testResources = resources.reduce((map, t) => { map[`${t.container}:${t.resource}:${t.type}`] = createResource(t.container, t.resource, t.type, subject, agent); return map;}, {})
