@ignore
Feature: Routine to get a websocket endpoint from a notification gateway

  # param: subscriptionType
  Scenario:
    # TODO: The spec does not yet define how Notification Subscription Metadata should be discovered - this is an example approach
    Given url resolveUri(rootTestContainer.url, '/.well-known/solid')
    And header Accept = 'text/turtle'
    When method GET
    Then status 200

    * def model = parse(response, 'text/turtle', rootTestContainer.url)
    * def notificationGatewayPredicate = iri('http://www.w3.org/ns/solid/terms#notificationGateway')
    * assert model.contains(null, notificationGatewayPredicate, null)
    * def notificationSubscriptionMetadata = model.objects(null, notificationGatewayPredicate)[0]

    # NOTIFICATION GATEWAY IMPLEMENTATION
    * def selectedType = karate.get('subscriptionType', 'WebSocketSubscription2021')
    Given url notificationSubscriptionMetadata
    And header Accept = 'application/ld+json'
    And header Content-Type = 'application/ld+json'
    And request {"@context": ["https://www.w3.org/ns/solid/notification/v1"], "type": ["#(selectedType)"], "protocols": ["ws"]}
    When method POST
    Then status 200
    And match response.endpoint == '#notnull'
    * def subscriptionEndpoint = response.endpoint
    * def subscriptionType = selectedType

    # NOTIFICATION CHANNEL DISCOVERY
#    Given url notificationSubscriptionMetadata
#    And header Accept = 'text/turtle'
#    When method GET
#    Then status 200
#
#    # find the subscription endpoint for the given channel, or default to the first available
#    * def findEndpoint =
#    """
#      function(model) {
#        let channels;
#        const selectedType = karate.get('subscriptionType')
#        if (selectedType) {
#          channels = model.subjects(iri(RDF, 'type'), iri(NOTIFY, selectedType));
#        } else {
#          channels = model.objects(null, iri(NOTIFY, 'notificationChannel'));
#        }
#        if (channels.length > 0) {
#          const subscriptions = model.objects(channels[0], iri(NOTIFY, 'subscription'));
#          if (subscriptions.length > 0) {
#            if (!selectedType) {
#              const types = model.objects(channels[0], iri(RDF, 'type'));
#              if (types.length > 0) {
#                karate.set('subscriptionType', types[0])
#              }
#            }
#            return subscriptions[0]
#          }
#        }
#        return null;
#      }
#    """
#
#    * def model = parse(response, 'text/turtle', notificationSubscriptionMetadata)
#    * def subscriptionEndpoint = findEndpoint(model)