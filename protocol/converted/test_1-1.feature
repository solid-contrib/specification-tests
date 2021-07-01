@ignore
Feature: Create: PUT Turtle resources to container with varying LDP Interaction Models.


Scenario: Test 1.1 on URL /dahut-bc.ttl
  * def requestUri = testContainer.getUrl() + 'dahut-bc.ttl'
  Given url requestUri
  And configure headers = clients.alice.getAuthHeaders('PUT', requestUri)
  And header Content-Type = 'text/turtle'
  And header Link = '<http://www.w3.org/ns/ldp#BasicContainer>; rel="type"'
  And request '@prefix dc: <http://purl.org/dc/terms/>. <> dc:title "Container Interaction Model"@en .'
  When method PUT
  Then status 409



Scenario: Test 1.2 on URL /dahut-nr.ttl
  * def requestUri = testContainer.getUrl() + 'dahut-nr.ttl'
  Given url requestUri
  And configure headers = clients.alice.getAuthHeaders('PUT', requestUri)
  And header Content-Type = 'text/turtle'
  And header Link = '<http://www.w3.org/ns/ldp#NonRDFSource>; rel="type"'
  And request '@prefix dc: <http://purl.org/dc/terms/>. <> dc:title "Non-RDF source Interaction Model"@en .'
  When method PUT
  Then status 409



Scenario: Test 1.3 on URL /dahut-rs.ttl
  * def requestUri = testContainer.getUrl() + 'dahut-rs.ttl'
  Given url requestUri
  And configure headers = clients.alice.getAuthHeaders('PUT', requestUri)
  And header Content-Type = 'text/turtle'
  And header Link = '<http://www.w3.org/ns/ldp#RDFSource>; rel="type"'
  And request '@prefix dc: <http://purl.org/dc/terms/>. <> dc:title "RDF source Interaction Model"@en .'
  When method PUT
  Then status 201



Scenario: Test 1.4 on URL /dahut-rs.ttl
  * def requestUri = testContainer.getUrl() + 'dahut-rs.ttl'
  Given url requestUri
  And configure headers = clients.alice.getAuthHeaders('GET', requestUri)
  When method GET
  Then status 200



Scenario: Test 1.5 on URL /dahut-no.ttl
  * def requestUri = testContainer.getUrl() + 'dahut-no.ttl'
  Given url requestUri
  And configure headers = clients.alice.getAuthHeaders('PUT', requestUri)
  And header Content-Type = 'text/turtle'
  And request '@prefix dc: <http://purl.org/dc/terms/>. <> dc:title "No Interaction Model"@en .'
  When method PUT
  Then status 201



Scenario: Test 1.6 on URL /dahut-no.ttl
  * def requestUri = testContainer.getUrl() + 'dahut-no.ttl'
  Given url requestUri
  And configure headers = clients.alice.getAuthHeaders('GET', requestUri)
  When method GET
  Then status 200


