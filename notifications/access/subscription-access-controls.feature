@notifications
Feature: Notification subscription access controls

  Background:
    * def testContainer = rootTestContainer.createContainer()
    * def setup = callonce read('../subscription-endpoint.feature')
    * def subscription = call read('subscribe.feature') { subscriptionEndpoint: '#(setup.subscriptionEndpoint)', subscriptionType: '#(setup.subscriptionType)', url: '#(testContainer.url)' }

  Scenario: Notifications are sent
    * def containerSocket = karate.webSocket(subscription.endpoint, null, {subProtocol: 'solid-0.2'})
    * assert containerSocket != null
    * def resource = testContainer.createResource('.txt', 'Hello World!', 'text/plain');
    * listen 5000
    * def model = parse(listenResult, 'application/ld+json', testContainer.url)
    * assert model.contains(null, iri(RDF, 'type'), iri(PROV, 'Activity'))
    * assert model.contains(null, iri(RDF, 'type'), iri(AS, 'Update'))
    * assert model.contains(null, iri(AS, 'object'), iri(testContainer.url))
    * assert model.contains(null, iri(AS, 'published'), null)
    # actor - currently returns container not webid
#    * assert model.contains(null, iri('https://www.w3.org/ns/activitystreams#actor'), iri(webIds.alice))
    * resource.delete()
    * listen 5000
    * def resourceModel = parse(listenResult, 'application/ld+json', testContainer.url)
    * print resourceModel.asTriples()
