@notifications
Feature: Notification subscription metadata resource serialization

  Background: Discover the notification channels
    # TODO: The spec does not yet define how Notification Subscription Metadata should be discovered - this is an example approach
    Given url resolveUri(rootTestContainer.url, '/.well-known/solid')
    And header Accept = 'text/turtle'
    When method GET
    Then status 200

    * def model = parse(response, 'text/turtle', rootTestContainer.url)
    * def notificationGatewayPredicate = iri(SOLID, 'notificationGateway')
    * assert model.contains(null, notificationGatewayPredicate, null)
    * def notificationSubscriptionMetadata = model.objects(null, notificationGatewayPredicate)[0]

    * def channelsHaveTypes =
    """
      function(model) {
        // get all channels and filter out those with an RDF type - the result should be empty
        return model.objects(null, iri(NOTIFY, 'notificationChannel')).filter(nc => {
          !model.contains(iri(nc), iri(RDF, 'type'), null)
        }).length === 0
      }
    """

  Scenario: Serialized as Turtle
    Given url notificationSubscriptionMetadata
    And header Accept = 'text/turtle'
    When method GET
    Then status 200
    And match header Content-Type contains 'text/turtle'
    * def model = parse(response, 'text/turtle', notificationGateway)
    And assert channelsHaveTypes(model)

  Scenario: Serialized as JSON-LD
    Given url notificationSubscriptionMetadata
    And header Accept = 'application/ld+json'
    When method GET
    Then status 200
    And match header Content-Type contains 'application/ld+json'
    * def model = parse(response, 'application/ld+json', notificationGateway)
    And assert channelsHaveTypes(model)
