@ignore
Feature: Create containers
Background: Setup
  * def testContainer = createTestContainer()
  * testContainer.createChildResource('.txt', '', 'text/plain');

# Background: Setup on URL /
#   * def requestUri = testContainer.getUrl() + ''
#   Given url requestUri
#   And configure headers = clients.alice.getAuthHeaders('PUT', requestUri)
#   And header Content-Type = 'text/turtle'
#   And header Link = '<http://www.w3.org/ns/ldp#BasicContainer>; rel="type"'
#   And request '@prefix dc: <http://purl.org/dc/terms/>. <> dc:title "Container Interaction Model"@en .'
#   When method PUT
#   Then status 201

# Background: Setup on URL /no-interaction
#   * def requestUri = testContainer.getUrl() + 'no-interaction'
#   Given url requestUri
#   And configure headers = clients.alice.getAuthHeaders('PUT', requestUri)
#   And header Content-Type = 'text/turtle'
#   And request '@prefix dc: <http://purl.org/dc/terms/>. <> dc:title "No Interaction Model"@en .'
#   When method PUT
#   Then status 201

# Background: Setup on URL /rs-interaction
#   * def requestUri = testContainer.getUrl() + 'rs-interaction'
#   Given url requestUri
#   And configure headers = clients.alice.getAuthHeaders('PUT', requestUri)
#   And header Content-Type = 'text/turtle'
#   And header Link = '<http://www.w3.org/ns/ldp#RDFSource>; rel="type"'
#   And request '@prefix dc: <http://purl.org/dc/terms/>. <> dc:title "RDF Source Interaction Model"@en .'
#   When method PUT
#   Then status 409

# Background: Setup on URL /nr-interaction
#   * def requestUri = testContainer.getUrl() + 'nr-interaction'
#   Given url requestUri
#   And configure headers = clients.alice.getAuthHeaders('PUT', requestUri)
#   And header Content-Type = 'text/turtle'
#   And header Link = '<http://www.w3.org/ns/ldp#NonRDFSource>; rel="type"'
#   And request '@prefix dc: <http://purl.org/dc/terms/>. <> dc:title "Non-RDF Source Interaction Model"@en .'
#   When method PUT
#   Then status 409

# Background: Setup on URL /no-interaction
#   * def requestUri = testContainer.getUrl() + 'no-interaction'
#   Given url requestUri
#   And configure headers = clients.alice.getAuthHeaders('PUT', requestUri)
#   And header If-None-Match = '*'
#   And header Content-Type = 'text/turtle'
#   And request '@prefix dc: <http://purl.org/dc/terms/>. <> dc:title "No Interaction Model, but if-none-match"@en .'
#   When method PUT
#   Then status 412

# Background: Setup on URL /empty-container
#   * def requestUri = testContainer.getUrl() + 'empty-container'
#   Given url requestUri
#   And configure headers = clients.alice.getAuthHeaders('PUT', requestUri)
#   When method PUT
#   Then status 201
