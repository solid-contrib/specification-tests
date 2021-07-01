@ignore

Scenario: Set up initial resources as needed by the rest of the tests
* def requestUri = resource.getUrl()
Given url requestUri
And header Content-Type = 'text/turtle'
And header Link = '<http://www.w3.org/ns/ldp#BasicContainer>; rel="type"'
And header Slug = 'test-put-bc'
And request
"""
@prefix dc: <http://purl.org/dc/terms/>.
@prefix ldp: <http://www.w3.org/ns/ldp#>.
<> a ldp:BasicContainer ;
   dc:title "Initial container for Alice stuff"@en .
"""
When method POST
Then status 201


Scenario: Create: PUT Turtle resources to container with varying LDP Interaction Models.
* def requestUri = resource.getUrl()
Given url requestUri
And header Content-Type = 'text/turtle'
And header Link = '<http://www.w3.org/ns/ldp#BasicContainer>; rel="type"'
And request
"""
@prefix dc: <http://purl.org/dc/terms/>.
<> dc:title "Container Interaction Model"@en .
"""
When method PUT
Then status 409

* def requestUri = resource.getUrl()
Given url requestUri
And header Content-Type = 'text/turtle'
And header Link = '<http://www.w3.org/ns/ldp#NonRDFSource>; rel="type"'
And request
"""
@prefix dc: <http://purl.org/dc/terms/>.
<> dc:title "Non-RDF source Interaction Model"@en .
"""
When method PUT
Then status 409

* def requestUri = resource.getUrl()
Given url requestUri
And header Content-Type = 'text/turtle'
And header Link = '<http://www.w3.org/ns/ldp#RDFSource>; rel="type"'
And request
"""
@prefix dc: <http://purl.org/dc/terms/>.
<> dc:title "RDF source Interaction Model"@en .
"""
When method PUT
Then status 201

* def requestUri = resource.getUrl()
Given url requestUri
When method GET
Then status 200

* def requestUri = resource.getUrl()
Given url requestUri
And header Content-Type = 'text/turtle'
And request
"""
@prefix dc: <http://purl.org/dc/terms/>.
<> dc:title "No Interaction Model"@en .
"""
When method PUT
Then status 201

* def requestUri = resource.getUrl()
Given url requestUri
When method GET
Then status 200


Scenario: Create: PUT Turtle resources to container with If-None-Match: * headers.
* def requestUri = resource.getUrl()
Given url requestUri
And header If-None-Match = '*'
And header Content-Type = 'text/turtle'
And request
"""
@prefix dc: <http://purl.org/dc/terms/>.
<> dc:title "No Interaction Model, but if-none-match"@en .
"""
When method PUT
Then status 412

* def requestUri = resource.getUrl()
Given url requestUri
And header If-None-Match = '*'
And header Content-Type = 'text/turtle'
And request
"""
@prefix dc: <http://purl.org/dc/terms/>.
<> dc:title "No Interaction Model, but if-none-match"@en .
"""
When method PUT
Then status 201

* def requestUri = resource.getUrl()
Given url requestUri
When method GET
Then status 200

* def requestUri = resource.getUrl()
Given url requestUri
And header If-None-Match = '*'
And header Content-Type = 'text/turtle'
And header Link = '<http://www.w3.org/ns/ldp#BasicContainer>; rel="type"'
And request
"""
@prefix dc: <http://purl.org/dc/terms/>.
<> dc:title "Container Interaction Model"@en .
"""
When method PUT
Then status 409


Scenario: Update: PUT Turtle resources to container with varying LDP Interaction Models.
* def requestUri = resource.getUrl()
Given url requestUri
And header Content-Type = 'text/turtle'
And header Link = '<http://www.w3.org/ns/ldp#NonRDFSource>; rel="type"'
And request
"""
@prefix dc: <http://purl.org/dc/terms/>.
<> dc:title "Updating Non-RDF source Interaction Model"@en .
"""
When method PUT
Then status 409

* def requestUri = resource.getUrl()
Given url requestUri
And header Content-Type = 'text/turtle'
And header Link = '<http://www.w3.org/ns/ldp#BasicContainer>; rel="type"'
And request
"""
@prefix dc: <http://purl.org/dc/terms/>.
<> dc:title "Container Interaction Model"@en .
"""
When method PUT
Then status 409

* def requestUri = resource.getUrl()
Given url requestUri
And header Content-Type = 'text/plain'
And header Link = '<http://www.w3.org/ns/ldp#NonRDFSource>; rel="type"'
And request
"""
Non RDF Interaction Model
"""
When method PUT
Then status 409

* def requestUri = resource.getUrl()
Given url requestUri
And header Content-Type = 'text/plain'
And request
"""
No source Interaction Model
"""
When method PUT
Then status 409

* def requestUri = resource.getUrl()
Given url requestUri
And header Content-Type = 'text/turtle'
And header Link = '<http://www.w3.org/ns/ldp#RDFSource>; rel="type"'
And request
"""
@prefix dc: <http://purl.org/dc/terms/>.
<> dc:title "Update RDF source Interaction Model"@en .
"""
When method PUT
Then assert responseStatus == 200 || responseStatus == 204
* def requestUri = resource.getUrl()
Given url requestUri
And header Content-Type = 'text/turtle'
And request
"""
@prefix dc: <http://purl.org/dc/terms/>.
<> dc:title "Update with no Interaction Model"@en .
"""
When method PUT
Then assert responseStatus == 200 || responseStatus == 204
* def requestUri = resource.getUrl()
Given url requestUri
And request
"""
@prefix dc: <http://purl.org/dc/terms/>.
<> dc:title "Update with no Interaction Model"@en .
"""
When method GET
Then status 200


Scenario: Create: PUT Turtle resources to into a deep hierarchy.
* def requestUri = resource.getUrl()
Given url requestUri
And header Content-Type = 'text/turtle'
And header Link = '<http://www.w3.org/ns/ldp#BasicContainer>; rel="type"'
And request
"""
@prefix dc: <http://purl.org/dc/terms/>.
<> dc:title "Container Interaction Model"@en .
"""
When method PUT
Then status 409

* def requestUri = resource.getUrl()
Given url requestUri
When method GET
Then status 404

* def requestUri = resource.getUrl()
Given url requestUri
When method GET
Then status 404

* def requestUri = resource.getUrl()
Given url requestUri
And header Content-Type = 'text/turtle'
And header Link = '<http://www.w3.org/ns/ldp#RDFSource>; rel="type"'
And request
"""
@prefix dc: <http://purl.org/dc/terms/>.
<> dc:title "RDF source Interaction Model"@en .
"""
When method PUT
Then status 201

* def requestUri = resource.getUrl()
Given url requestUri
When method GET
Then status 200

* def requestUri = resource.getUrl()
Given url requestUri
When method GET
Then status 200

* def requestUri = resource.getUrl()
Given url requestUri
And header Content-Type = 'text/turtle'
And request
"""
@prefix dc: <http://purl.org/dc/terms/>.
<> dc:title "No Interaction Model"@en .
"""
When method PUT
Then status 201

* def requestUri = resource.getUrl()
Given url requestUri
When method GET
Then status 200

* def requestUri = resource.getUrl()
Given url requestUri
When method GET
Then status 200

Scenario: Delete resources that were set up in these tests
* def requestUri = resource.getUrl()
Given url requestUri
When method DELETE
Then assert responseStatus == 200 || responseStatus == 204 || responseStatus == 404
* def requestUri = resource.getUrl()
Given url requestUri
When method DELETE
Then assert responseStatus == 200 || responseStatus == 204 || responseStatus == 404
* def requestUri = resource.getUrl()
Given url requestUri
When method DELETE
Then assert responseStatus == 200 || responseStatus == 204 || responseStatus == 404
* def requestUri = resource.getUrl()
Given url requestUri
When method DELETE
Then assert responseStatus == 200 || responseStatus == 204 || responseStatus == 404
* def requestUri = resource.getUrl()
Given url requestUri
When method DELETE
Then assert responseStatus == 200 || responseStatus == 204 || responseStatus == 404
* def requestUri = resource.getUrl()
Given url requestUri
When method DELETE
Then assert responseStatus == 200 || responseStatus == 204
* def requestUri = resource.getUrl()
Given url requestUri
When method GET
Then status 404
