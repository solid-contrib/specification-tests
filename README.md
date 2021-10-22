# Solid Specification Conformance Tests

<!-- MarkdownTOC -->

- [Running these tests locally](#running-these-tests-locally)
- [KarateDSL](#karatedsl)
  - [Structure of a Test Case](#structure-of-a-test-case)
  - [Data related keywords](#data-related-keywords)
  - [HTTP related keywords](#http-related-keywords)
  - [Karate Object](#karate-object)
  - [Calling Functions](#calling-functions)
- [Test Harness Capabilities](#test-harness-capabilities)
  - [Global Variables](#global-variables)
  - [Helper Functions](#helper-functions)
  - [Libraries](#libraries)
- [Example Test Cases](#example-test-cases)
- [Specification Annotations](#specification-annotations)
- [Test Manifest](#test-manifest)

<!-- /MarkdownTOC -->

This repository contains the tests that can be executed by the
[Solid Conformance Test Harness (CTH)](https://github.com/solid/conformance-test-harness). The best way to run the 
harness is by using the [Docker image](https://hub.docker.com/r/solidconformancetestbeta/conformance-test-harness).

The tests are written in a language called [KarateDSL](https://intuit.github.io/karate/). This is a simple 
Behaviour-Driven Development (BDD) testing language based on 
[Gherkin](https://cucumber.io/docs/gherkin/) but which has been extended specifically for testing HTTP APIs. Further
Solid-specific capabilities are added by the test harness. The difference to Cucumber's use of Gherkin is that this is
actually executable code rather than just a human readable layer on top of functions that the tester must write. It also
has an embedded JavaScript engine supporting ES6 syntax and provides the ability to call Java classes. The conformance 
tests are expected to be written in KarateDSL and JavaScript. Additional capabilities added to the test harness as Java
libraries will be called from these without the need for the test implementer to know Java.

# Run script

There is a handy script `run.sh` that you can use to run tests. It has options to specify the target server, to choose
whether to use the published CTH image or a locally built one, and whether to use the tests embedded in that image or
tests available locally.

For each test subject you want to test, create a `{subject}.env` file in this directory according to the instructions
[here](https://hub.docker.com/r/solidconformancetestbeta/conformance-test-harness).

To see the usage instructions:
```shell
./run.sh
```
The reports will be created in the `reports/` directory.

If you want to only run specific test(s), you can add the filter option, such as:
```shell
./run.sh css --filter=content-negotiation
```

## Running local tests
You can clone this repository, work on tests, and run them locally.
```shell
git clone git@github.com:solid/specification-tests.git
cd specification-tests
````

Use the script with the `-d` option to use the local tests: 
```shell
./run.sh -d . css
```
## Creating a script for a CI workflow
If you just want to run tests against a single test subject, for examnple in a CI workflow, you can create a script such
as this one which will run the tests embedded in the latest published CTH image:
```shell
#!/bin/bash

mkdir -p config reports

cat > ./config/application.yaml <<EOF
subjects: /data/test-subjects.ttl
sources:
  - https://github.com/solid/specification-tests/protocol/solid-protocol-test-manifest.ttl
  - https://github.com/solid/specification-tests/web-access-control/web-access-control-test-manifest.ttl
  - https://solidproject.org/TR/protocol
  - https://github.com/solid/specification-tests/web-access-control/web-access-control-spec.ttl
mappings:
  - prefix: https://github.com/solid/specification-tests
    path: /data
EOF

docker pull solidconformancetestbeta/conformance-test-harness
docker run -i --rm \
  -v "$(pwd)"/:/data \
  -v "$(pwd)"/config:/app/config \
  -v "$(pwd)"/reports:/reports \
  -v "$(pwd)"/target:/app/target \
  --env-file=.env solidconformancetestbeta/conformance-test-harness \
  --output=/reports --target=https://github.com/solid/conformance-test-harness/css "$@"
```

Just change the `target` option and create a `.env` file for the server as mentioned above.

# KarateDSL

The following is a high level overview of KarateDSL, focused on the most common aspects required in these specification
tests. For more detail please go to:
* [KarateDSL](https://intuit.github.io/karate/)
* [Syntax Guide](https://intuit.github.io/karate/#syntax-guide)

## Structure of a Test Case
The basic structure of a KarateDSL test file is:
```gherkin
Feature: The title of the test case

  Background: Set up steps performed for each Scenario
    * def variable = 'something'

  Scenario: The title of the scenario
    Given url 'https://example.org/test.ttl'
    And header Content-Type = 'text/turtle'
    When method GET
    Then status 200
    And match header Content-Type contains 'text/turtle'
    And match response contains 'some-text'

  Scenario: The title of another scenario
    * another set of steps
```

The keywords `Given`, `And`, `When`, and `Then` in the `Scenario` are for the benefit of human readers of the script. To 
the test harness they simply denote steps in the procedure and have the same meaning as `*`. They make it easier to gain
an understanding of the test.

The `Background` steps are executed before every `Scenario` in the file. This is important to understand as it allows
the scenarios to be run in parallel but can also cause confusion if you expect a scenario to depend on something done
in a previous scenario (i.e., chained together). If you need to perform a sequence of interactions in a single test then
they should all be added to the same scenario. It is important to think of each scenario as a *Test* and the background
as a *BeforeEach* method as you might see in other testing frameworks.

The first scenario represents a single HTTP interaction with the server. It has the following conceptual structure:

1. Start with any variables you need to set up. Normally this is done with a `*` prefix.
1. Then use `Given` to start describing the context for the test. Often this will be where you set up the URL or path for
  the interaction.
1. Use `And` to provide more details for the context (e.g., setting up request headers).
1. The `When` keyword represents the action, but remember it has the same meaning as `*`. The request is actually
  triggered by the use of `method`.
1. Next you can begin to make assertions about the response starting with the `Then` keyword. Often the
  status is checked first.
1. Finally you can use `And` to describe additional assertions. You could use `*` if you need to create variables and
  analyze the response as this allows you to reserve `And` for assertions. It is a style choice since the keywords have no
  meaning to the test harness as already stated.
  
## Data related keywords

* `def` - Set a variable: `* def myVar = 'text'`
* `assert` - Assert an expression evaluates to `true`: `* assert myVar == 'text'` 
* `print` - Log to the console: `* print 'myVar = ' + myVar`

JSON and XML are supported directly so you can express things such as:
```gherkin
* def cat = { name: 'Billie', color: 'black' }
* assert cat.color == 'black'
* def myCat = <cat><name>Billie</name><color>black</color></cat>
* assert myCat.cat.color == 'black'
```

When handling large amounts of data, you can either read it in from external files or express it on multiple lines
using `"""`. This can apply to commands such as `def`, `request`, and `match`:
```gherkin
* def cat =
  """
  {
    name: 'Billie',
    color: 'black'
  }
  """
```

KarateDSL attempts to parse the multiline data, so if you need to avoid this you can use the `text` keyword instead of
`def`. This is particularly useful when you have Turtle data that Karate thinks might be malformed XML:
```gherkin
* text data =
  """
  @base <https://example.org> .
  <#hello> <#linked> <#world> .
  """
```

To read data from an external file there is a `read` keyword. However, this attempts to parse the data as JSON or XML so
to get raw data you should use a Karate function as follows:
```gherkin
* def data = karate.readAsString('../fixtures/example.ttl')
```

## HTTP related keywords
### Setting the URL
There are 2 keywords for setting the URL to be used in a request: `url` and `path`. The full URL can be set in the 
background. It is good practice to use the `*` keyword in the background and the `Given` keyword in a scenario:
```gherkin
* url 'https://example.org/test`
```
You could set a base URL in the background which applies to all scenarios, and then use the `path` keyword to alter it
for each scenario:
```gherkin
* url 'https://example.org/`
Given path 'test'
```
An alternative would be to set the base URL as a variable in the background, and use `url` in the scenarios:
```gherkin
* def baseUrl = 'https://example.org/`
Given url baseUrl + 'test1'
```

### Configuring the request
The keywords: `param`, `header`, `cookie`, `form field`, and `multipart field` are used for setting key-value pairs in 
the relevant part of the request:
```gherkin
And param key = "value" # adds ?key=value to the query string
And header Accept = 'text/turtle'
And cookie foo = 'bar'
And form field username = 'john'
```
You can set multiple values at the same time with JSON using `params`, `headers`, `cookies`, and `form fields`.

Note:
* That these keywords can take expressions or functions which return a single value or a map for the multiple value
versions.
* These commands are additive - the key-value pair(s) are added to the request.
* The key is not in quotes in the single key-value variants.

If you want to set up some headers to be used across multiple requests, you can use the following command:
```gherkin
* configure headers = { 'Content-Type': 'application/json' }
```
If you use this in the `Background`, it will apply to all scenarios. So if you need to replace these headers in one of 
those scenarios, you will need to configure them again in the same way or configure the headers as null and set them as
normal.

### Setting the request body
To set up the body of the request use the `request` keyword. Note that for methods that expect a body (e.g., PUT, POST),
you must use this keyword even if you set the content as an empty string. You would normally be using this in
conjunction with the `And` keyword: 
```gherkin
And request 'data'
And request ''
And request { name: 'Billie', color: 'black' }
And request karate.readAsString('../fixtures/example.ttl')
```

### Sending the request
The HTTP request is sent when you use the `method` keyword and a specific method. You would normally use this in
conjunction with the `When` keyword:
```gherkin
When method PUT
```

### Checking the response code
Finally, there is a shorthand for asserting the value of the response code if you are only matching one code:
```gherkin
Then status 200
```
In cases where you need to match multiple possible codes, you need to revert to using the `responseStatus` variable:
```gherkin
* Then match [200, 201, 202] contains responseStatus
* Then assert responseStatus >= 200 && responseStatus < 300
* Then match karate.range(200, 299) contains responseStatus
```
Note that the last option creates and array of 100 values so the error message in not particularly helpful as it lists
all the options that the code did not match!

### Checking the response payload
The important keywords for this are `match` and `assert`. They are very similar but generally `match` should be used as
it is better at reporting errors than `assert`. The `match` keyword is very powerful. It has the ability to ignore parts
of the data when matching and to apply fuzzy matching. The full details are available here:
[Payload Assertions](https://intuit.github.io/karate/#payload-assertions).

In their simplest forms, `match` and `assert` simply take a JavaScript expression that evaluates to a boolean:
```gherkin
* match foo == bar && foo2 != 10
```
The left-hand side can be a variable name, a JSON/XML path, a function call, or anything in parentheses which evaluates as
JavaScript. The right-hand side can be any [Karate expression](https://intuit.github.io/karate/#karate-expressions).
Some of the important operators are outlined below.

#### `contains`
This can be a simple text comparison:
```gherkin
* match hello contains 'World'`
* match hello !contains 'World'`
```
It can also work with arrays and maps:
```gherkin
* def foo = { bar: 1, baz: ['hello', 'world'] }
* match foo contains { bar: 1 }
* match foo.baz contains 'world'
```
For matching the contents of an array independent of order:
```gherkin
* def data = { foo: [1, 2, 3] }
* match data.foo contains only [2, 3, 1]
* match data.foo contains any [9, 2, 8]
```
The `any` operator works with objects too:
```gherkin
* def data = { a: 1, b: 'x' }
* match data contains any { b: 'x', c: true }
```
If you want to match deeper into an object, you need `contains deep`:
```gherkin
* def original = { a: 1, b: 2, c: 3, d: { a: 1, b: 2 } }
* def expected = { a: 1, c: 3, d: { b: 2 } }
* match original contains deep expected
```

#### Special variables
You can access various parts of the HTTP response using special variables such as `response`, `responseHeaders`, and
`responseStatus`.

The response body is saved into `response` after a request. Depending on the content type, the returned value will be a
string, JSON, or XML object. You can apply matches to this or perform other logic on it:
```gherkin
* match response contains 'Billie'
* match response.name == 'Billie' # if the response is JSON
```

The headers are available as `responseHeaders`. However, this can be tricky to use. It is a map of all the header values
in the form `Map<String, List<String>>`, and it preserves the case of the returned header names even though they should
be treated as case insensitive. Because of this, there is a shortcut `header` which matches the header name 
case-insensitively and matches any value of that key. In the example below, the first 3 are equivalent but the 4th
fails:
```gherkin
* match header Content-Type contains 'text/turtle'
* match header content-type contains 'text/turtle'
* responseHeaders['Content-Type'][0] contains 'text/turtle'
* responseHeaders['content-type'][0] contains 'text/turtle'  # fails as responseHeaders['content-type'] returns null
```
Note that it is safer to use `contains` instead of `==` in this case since the header value may contain an encoding
element such as `; charset=UTF-8`.

Using the `responseStatus` variable as an alternative to `status` was mentioned earlier.

## Karate Object
Within a test case, you have access to the Karate object which has a number of useful methods described
[here](https://intuit.github.io/karate/#the-karate-object). This includes methods to manipulate data, call functions
with a lock so they only run once, read from files, create loops, and handle async calling.

## Calling Functions
See https://intuit.github.io/karate/#code-reuse--common-routines

Sometimes you may want to set up something in the `Background` section that is only done once for all scenarios whereas
typically these steps are run for every `Scenario`. This can be achieved using `callonce`. This would be similar to the
difference between *BeforeEach* and *BeforeAll* in other testing frameworks. You can set up a function in the 
`Background` section (or even in another feature file), and on calling it receive a single object back:
```gherkin
  Background: Setup (effectively BeforeAll)
    * def setupFn =
    """
      function() {
        // do some setup
        return something;
      }
    """
    * def something = callonce setupFn
```
Although the `Background` is run for every `Scenario`, the function will only be called once.

# Test Harness Capabilities

## Global Variables
The test harness makes some variables available to all tests:

* `rootTestContainer` - An instance of `SolidContainer` pointing to the container in which all test files will be created
  for this run of the test suite. This is guaranteed to exist when the tests start and is a unique URL for every run of
  the test suite.
* `clients` - An object containing the HTTP clients that are set up for authenticated access by `alice` and `bob`. One of
  these clients will need to be passed to any newly created `SolidContainer` or `SolidResource` - The user names are the
  key (e.g., `clients.alice`).
* `webIds` - An object containing the webIds of the 2 users. These are needed when setting up ACLs (e.g., `webIds.alice`).

## Helper Functions
### Setting up test containers

#### `createTestContainer()`
Create a SolidContainer object referencing a unique sub-container of the `rootTestContainer`.
  This container will not be created until a resource is created inside it.

#### `createTestContainerImmediate()`
Create a SolidContainer object referencing a unique sub-container of the
  `rootTestContainer`, but ensure that it is actually created at this point.

### Parsing Functions
##### WAC-Allow header
This `parseWacAllowHeader(headers)` function accepts the response headers, locates the `WAC-Allow` header, and parses
it into a map object. This object will contain `user` and `public` keys plus any additional groups defined within the
header. It extracts all the acccess modes, and adds them as a list to the relevant group. The result can be treated as
a JSON object such as:
```json5
{
  user: ['read', 'write', 'append'],
  public: ['read', 'append']
}
```
In a test, it could be used like this:
```gherkin
* def result = parseWacAllowHeader(responseHeaders)
And match result.user contains only ['read', 'write', 'append']
And match result.public contains only ['read', 'append']
```

##### Parse link header
The `parseLinkHeaders(headers)` processes the response headers to extract all the `Link` headers and return them in the
form of `List<Map<String, String>>`, where each item in the list is a map of the components of the link using the keys:
`rel`, `uri`, `title`, `type`. The `rel` and `uri` values are mandatory. The returned object can be treated as a JSON
object. For example:
```json5
[
  {
    rel: 'type',
    uri: 'http://www.w3.org/ns/pim/space#Storage'
  },
  {
    rel: 'acl',
    uri: 'https://example.org/test/resource.acl'
  }
]
```
This could be used in a test like this:
```gherkin
* def hasStorageType = (ls) => ls.findIndex(l => l.rel == 'type' && l.uri == 'http://www.w3.org/ns/pim/space#Storage') != -1
* def links = parseLinkHeaders(responseHeaders)
And assert hasStorageType(links)
```

### Other useful functions
#### `resolveUri(base, target)`
Apply the target URI to the base URI to return a new URI. For example
`resolveUri('https://example.org/test/resource', '/inbox/')` would return `https://example.org/inbox/`.

## Libraries

Most tests will deal with resources and containers (which is a subclass of a resource). These objects are represented
by 2 classes in the test harness: `SolidResouce` and `SolidContainer`. For handling access controls in a universal way
there are 2 classes: `AccessDatasetBuilder` and `AccessDataset`. Finally, there is also a library, `RDFUtils`, for
parsing RDF of various formats.

### SolidResource
The `SolidResource` class represents a resource or container on the server. Since this is also the base class for
`SolidContainer`, it includes methods that are related to containers. It is not common to need use this class directly
in a test as most resources and containers are created from the starting point of the `rootTestContainer`.

#### `SolidResource.create(solidClient, url, body, contentType)`
A static method that can create a resource on the server.
* Parameters:
  * solidClient - The authenticated client to use for this request (e.g., `clients.alice`).
  * url - The absolute url of the resource to create.
  * body - The data to be put in the resource.
  * contentType - The content type of ths data.
* Returns an instance of `SolidResource`.

#### `exists()`
Was this resource actually created?
* Returns a boolean.

#### `getUrl()`
Get the URL of this resource.
* Returns a string.

#### `getPath()`
Get the path of this resource relative to the server root.
* Returns a string.

#### `getContentAsTurtle()`
Get the contents of this URL as a Turtle document.
* Returns a string.

#### `isContainer()`
Is this resource a container?
* Returns a boolean. 

#### `getContainer()`
Gets the `SolidContainer` instance representing the parent container of this resource or ultimately returns the root 
container.
* Returns a `SolidContainer`.

#### `getAclUrl()`
Get the ACL URL for this resource.
* Returns a string.

#### `findStorage()`
Get the storage root for this resource by working up the path hierarchy looking for the `pim:Storage` link header.
* Returns a new SolidResource representing the storage root or null if it could not be found or is not accessible to
  the user.

#### `hasStorageType()`
Does this resource have the `pim:Storage` link header identifying it as a storage-type container?
* Returns a boolean.

#### `getAccessDatasetBuilder(owner)`
There are currently 2 access control implementations supported by the test harness:
* [Web Access Control (WAC)](https://solid.github.io/web-access-control-spec)
* [Access Control Policies (ACP)](https://github.com/solid/authorization-panel/tree/main/proposals/acp) - emerging

Get an object that can build a set of access control statements in a WAC/ACP agnostic way. The object is initialized
by adding owner access for the specified owner (in WAC mode only).
* Parameters:
  * owner - the WebID of the resource owner.
* Returns an [AccessDatasetBuilder](#accessdatasetbuilder). 

#### `getAccessDataset()`
Get an object representing the access control document/policy.
* Returns an [AccessDataset](#accessdataset).

#### `getAccessControlMode()`
Which access control implementations does the test subject implement?
* Returns "WAC" or "ACP".

#### `setAccessDataset(accessDataset)`
Applies the access controls to the resource.
* Parameters:
  * accessDataset - an [AccessDataset](#accessdataset).
* Returns boolean showing success or failure.

#### `delete()`
Delete this resource and if it is a container, recursively delete its members.

### SolidContainer

#### `SolidContainer.create(solidClient, url)`
A static method that can create a container on the server.
* Parameters:
  * solidClient - The authenticated client to use for this request (e.g., `clients.alice`).
  * url - The absolute url of the container to create.
* Returns an instance of `SolidResource`.

#### `listMembers()`
Get a list of all the members of this container.
* Returns an array of URLs as strings.

#### `parseMembers(data)`
Parse the container content to get a list of all the members/
* Parameters:
  * data - The Turtle content of the container.
* Returns an array of URLs as strings.

#### `instantiate()`
Create this container on the server.
* Returns an instance of `SolidContainer` to allow call chaining.

#### `generateChildContainer()`
Create a container as a child of this container using a UUID as the name but do not instantiate it on the server.
* Returns an instance of `SolidContainer` to allow call chaining.

#### `generateChildResource(suffix)`
Create a `SolidResource` as a child of this container using a UUID as the name with the provided suffix, but do not
  instantiate it on the server.
* Parameters:
  * suffix - The filename extension to use or a blank string if not needed (e.g., `'.ttl'`).
* Returns an instance of `SolidResource` to allow call chaining.

#### `createChildResource(suffix, body, contentType)`
Create a `SolidResource` as a child of this container using a UUID as the name with the provided suffix, then put the
  provided contents into it.
* Parameters:
  * suffix - The filename extension to use or a blank string if not needed (e.g., `'.ttl'`).
  * body - The data to be put in the resource.
  * contentType - The content type of ths data.
* Returns an instance of `SolidResource`.

#### `deleteContents()`
Recursively delete the contents of this container but not the container itself.

### AccessDatasetBuilder
This universal access dataset builder can be used to build up a set of rules which are then built into a WAC or ACP
specific [AccessDataset](#accessdataset). Many of the methods below take an access parameter which is a list of access
modes to be granted. This list can contain any of `read`, `write`, `append`, `control`, `controlRead`, `controlWrite` or
an IRI representing an access mode not known to the test harness. The known modes are translated to the appropriate IRI
for WAC or ACP. There are special conditions relating to the `control` modes. In WAC you can only set `control` however
in ACP it is possible to add `read` and/or `write` access to the ACL resource. When you use the mode `control` is used
for ACP it is translated to `read` and `write` but it is possible to set only one of these using the `controlRead` and
`controlWrite` variants.

For example:
```js
const access = testContainer.getAccessDatasetBuilder(webIds.alice)
        .setAgentAccess(testContainer.getUrl(), webIds.bob, ['write'])
        .setInheritableAgentAccess(testContainer.getUrl(), webIds.bob, ['append', 'write', 'control'])
        .build();
testContainer.setAccessDataset(access);
```  


#### `setOwnerAccess(target, owner)`
Add a rule granting the `owner` full access to the `target` resource. If the target is a container then this access is
made inheritable by current and future child resources.

#### `setBaseUri(uri)`
Set the base URI of the ACL document.

#### `setAgentAccess(target, webId, access)`
Add a rule granting access to the `target` for an agent, specified by their `webId`, with the specified `access` modes.

#### `setGroupAccess(target, members, access)`
Add a rule granting access to the `target`for a group, specified as a list (`members`) of their web IDs, with the
specified `access` modes.

#### `setPublicAccess(target, access)`
Add a rule granting access to the `target` for an unauthenticated user, with the specified `access` modes.

#### `setAuthenticatedAccess(target, access)`
Add a rule granting access to the `target`for any authenticated user, with the specified `access` modes.

#### `setInheritableAgentAccess(target, webId, access)`
Add a rule granting access to any child resources of `target` for an agent, specified by their `webId`, with the
specified `access` modes.

#### `setInheritableGroupAccess(target, members, access)`
Add a rule granting access to any child resources of `target` for a group, specified as a list (`members`) of their
web IDs, with the specified `access` modes.

#### `setInheritablePublicAccess(target, access)`
Add a rule granting access to any child resources of `target` for an unauthenticated user, with the specified `access`
modes.

#### `setInheritableAuthenticatedAccess(target, access)`
Add a rule granting access to any child resources of `target` for any authenticated user, with the specified `access`
modes.

#### `build()`
Returns an [AccessDataset](#accessdataset) constructed in WAC or ACP format using the rules added to the builder.

### AccessDataset
#### `asTurtle()`
Returns a string with the turtle representation of the set of rules in the WAC or ACP format.

#### `parseTurtle(data, baseUri)`
In the rare case where you want to manually construct an ACL document you may use this function to replace the content
of an `AccessDataset` object and then apply it to a resource.

### RDFUtils
KarateDSL 'natively' supports JSON and XML but sadly it does not yet support RDF. As a result you will need a library
to parse RDF documents into formats that are useful for comparisons.

#### `turtleToTripleArray(data, baseUri)`
Parses a Turtle document into an array of triples.
* Parameters:
  * data - The Turtle data.
  * baseUri - The base URI used for any relative IRIs.
* Returns an array of strings in the form `<subject> <predicate> <object> .`

#### `jsonLdToTripleArray(data, baseUri)`
Parses a JSON-LD document into an array of triples.
* Parameters:
  * data - The JSON-LD data.
  * baseUri - The base URI used for any relative IRIs.
* Returns an array of strings in the form `<subject> <predicate> <object> .`

#### `rdfaToTripleArray(data, baseUri)`
Parses a RDFa document into an array of triples.
* Parameters:
  * data - The RDFa data.
  * baseUri - The base URI used for any relative IRIs.
* Returns an array of strings in the form `<subject> <predicate> <object> .`

# Example Test Cases
The following are a selection of example tests that demonstrate different features of the test harness, and show 
various approaches to writing tests.

## protocol/content-negotiation/content-negotiation-turtle.feature
The purpose of this test is to confirm that a Turtle resource can be fetched as either JSON-LD or Turtle using content
negotiation.

```gherkin
Feature: Requests support content negotiation for Turtle resource

  Background: Create a turtle resource
    * def testContainer = createTestContainer()
    * def exampleTurtle = karate.readAsString('../fixtures/example.ttl')
    * def resource = testContainer.createChildResource('.ttl', exampleTurtle, 'text/turtle');
    * assert resource.exists()
    * def expected = RDFUtils.turtleToTripleArray(exampleTurtle, resource.getUrl())
    * configure headers = clients.alice.getAuthHeaders('GET', resource.getUrl())
    * url resource.getUrl()

  Scenario: Alice can read the TTL example as JSON-LD
    Given header Accept = 'application/ld+json'
    When method GET
    Then status 200
    And match header Content-Type contains 'application/ld+json'
    And match RDFUtils.jsonLdToTripleArray(JSON.stringify(response), resource.getUrl()) contains expected

  Scenario: Alice can read the TTL example as TTL
    Given header Accept = 'text/turtle'
    When method GET
    Then status 200
    And match header Content-Type contains 'text/turtle'
    And match RDFUtils.turtleToTripleArray(response, resource.getUrl()) contains expected
```

The `Background` for this test:
1. Sets up a test container (which isn't yet instantiated).
1. Loads example Turtle data into a variable from a file.
1. Puts this data into a resource inside the test container.
1. Asserts that this resource exists (if it doesn't the test will stop at this point).
1. Convert the example data into an array of triples for later comparisons.
1. Sets up the URL and authorization headers for the HTTP requests used in the scenarios. 
  
Note that this `Background` is run for each `Scenario` so in reality 2 test files are created. That may seem 
inefficient, but it allows all scenarios to be run in parallel.

There are 2 scenarios based on this setup which perform the following steps:
1. Set an `Accept` header to get the resource as JSON-LD or as Turtle.
1. Send a `GET` request for this resource.
1. Confirm that the response code is `200`.
1. Confirm the `Content-Type` header matches the requested type.
1. Confirm that the response body, when converted to an array of triples contains the triples saved in the background
  setup.

## protocol/wac-allow/access-Bob-W-public-RA.feature
The purpose of this test is to set up a resource with a combination of access controls and then confirm that the
WAC-Allow header reports the correct permissions.

```gherkin
Feature: The WAC-Allow header shows user and public access modes with Bob write and public read, append

  Background: Create test resource giving Bob write access and public read/append access
    * def setup =
    """
      function() {
        const testContainer = createTestContainer();
        const resource = testContainer.createChildResource('.ttl', karate.readAsString('../fixtures/example.ttl'), 'text/turtle');
        if (resource.exists()) {
          const access = resource.getAccessDatasetBuilder(webIds.alice)
            .setAgentAccess(resource.getUrl(), webIds.bob, ['write'])
            .setPublicAccess(resource.getUrl(), ['read', 'append'])
            .build();
          resource.setAccessDataset(access);
        }
        return resource;
      }
    """
    * def resource = callonce setup
    * assert resource.exists()
    * def resourceUrl = resource.getUrl()
    * url resourceUrl

  Scenario: There is an acl on the resource containing Bob's WebID
    Given url resource.getAclUrl()
    And headers clients.alice.getAuthHeaders('GET', resource.getAclUrl())
    And header Accept = 'text/turtle'
    When method GET
    Then status 200
    And match header Content-Type contains 'text/turtle'
    And match response contains webIds.bob

  # Note this test is not applicable to a server using ACP as the WAC-Allow header is not supported currently.
  # In ACP mode, the following step would fail as there will be an ACL on the parent - this step needs to change
  # to ask the test harness to confirm there is no inherited access.
  Scenario: There is no acl on the parent
    Given url resource.getContainer().getAclUrl()
    And headers clients.alice.getAuthHeaders('HEAD', resource.getContainer().getAclUrl())
    And header Accept = 'text/turtle'
    When method HEAD
    Then status 404

  Scenario: Bob calls GET and the header shows RWA access for user, RA for public
    Given headers clients.bob.getAuthHeaders('GET', resourceUrl)
    When method GET
    Then status 200
    And match header WAC-Allow != null
    * def result = parseWacAllowHeader(responseHeaders)
    And match result.user contains only ['read', 'write', 'append']
    And match result.public contains only ['read', 'append']

  Scenario: Bob calls HEAD and the header shows RWA access for user, RA for public
    Given headers clients.bob.getAuthHeaders('HEAD', resourceUrl)
    When method HEAD
    Then status 200
    And match header WAC-Allow != null
    * def result = parseWacAllowHeader(responseHeaders)
    And match result.user contains only ['read', 'write', 'append']
    And match result.public contains only ['read', 'append']

  Scenario: Public calls GET and the header shows RA access for user and public
    When method GET
    Then status 200
    And match header WAC-Allow != null
    * def result = parseWacAllowHeader(responseHeaders)
    And match result.user contains only ['read', 'append']
    And match result.public contains only ['read', 'append']

  Scenario: Public calls HEAD and the header shows RA access for user and public
    When method HEAD
    Then status 200
    And match header WAC-Allow != null
    * def result = parseWacAllowHeader(responseHeaders)
    And match result.user contains only ['read', 'append']
    And match result.public contains only ['read', 'append']

```

The `Background` for this test:
1. Sets up a function which will be called once for the whole set of scenarios:
    1. Creates a test container (which isn't yet instantiated).
    1. Creates a resource in this container using an example Turtle file.
    1. Adds an ACL for the resource which grants Bob write access and the public read and append access. It logs this to
  make it visible in the reports.
1. Use `callonce` to run the setup process once for all scenarios.
1. Asserts that this resource exists (if it doesn't the test will stop at this point).
1. Sets up the URL for the HTTP requests used in most of the scenarios.

The first 2 scenarios check the ACLs which could impact this test. The first fetches the resource's ACL and confirms
it contains the ACL document we just created. The second fetches the container's ACL to confirm there isn't one from 
which permissions could be inherited.

The subsequent scenarios have the following pattern:
1. Set up the authorization headers for requests from Bob but not for public requests.
1. Send a `GET` or `HEAD` request for this resource.
1. Confirm that the response code is `200`.
1. Confirm that the WAC-Allow header exists.
1. Parse the WAC-Allow header and save this to a variable.
1. Confirm the expected set of permissions for each of Bob and the public user.

## protocol/writing-resource/containment.feature
The purpose of this test is to check that all containment triples are created on intemediate containers if a
resource is created on a path that doesn't exist using PUT or PATCH.

```gherkin
Feature: Creating a resource using PUT and PATCH must create intermediate containers

  Background: Set up clients and paths
    * def testContainer = createTestContainer()
    * def intermediateContainer = testContainer.generateChildContainer()
    * def resource = intermediateContainer.generateChildResource('.txt')

  Scenario: PUT creates a grandchild resource and intermediate containers
    * def resourceUrl = resource.getUrl()
    Given url resourceUrl
    And configure headers = clients.alice.getAuthHeaders('PUT', resourceUrl)
    And request "Hello"
    When method PUT
    Then assert responseStatus >= 200 && responseStatus < 300

    * def parentUrl = intermediateContainer.getUrl()
    Given url parentUrl
    And configure headers = clients.alice.getAuthHeaders('GET', parentUrl)
    And header Accept = 'text/turtle'
    When method GET
    Then status 200
    And match intermediateContainer.parseMembers(response) contains resource.getUrl()

    * def grandParentUrl = testContainer.getUrl()
    Given url grandParentUrl
    And configure headers = clients.alice.getAuthHeaders('GET', grandParentUrl)
    And header Accept = 'text/turtle'
    When method GET
    Then status 200
    And match testContainer.parseMembers(response) contains intermediateContainer.getUrl()

  Scenario: PATCH creates a grandchild resource and intermediate containers
    * def resourceUrl = resource.getUrl()
    Given url resourceUrl
    And configure headers = clients.alice.getAuthHeaders('PATCH', resourceUrl)
    And header Content-Type = "application/sparql-update"
    And request 'INSERT DATA { <#hello> <#linked> <#world> . }'
    When method PATCH
    Then assert responseStatus >= 200 && responseStatus < 300

    * def parentUrl = intermediateContainer.getUrl()
    Given url parentUrl
    And configure headers = clients.alice.getAuthHeaders('GET', parentUrl)
    And header Accept = 'text/turtle'
    When method GET
    Then status 200
    And match intermediateContainer.parseMembers(response) contains resource.getUrl()

    * def grandParentUrl = testContainer.getUrl()
    Given url grandParentUrl
    And configure headers = clients.alice.getAuthHeaders('GET', grandParentUrl)
    And header Accept = 'text/turtle'
    When method GET
    Then status 200
    And match testContainer.parseMembers(response) contains intermediateContainer.getUrl()
```

The `Background` for this test:
1. Creates a resource as a grandchild of a test container (nothing is instantiated at this point).

Note that the 2 scenarios are independent as they each run the background steps, setting up their own test resource.

The pattern for the scenarios is based on making 3 HTTP requests. They each set up the URL and authorization headers
first, then the sequence is:
1. Send a `PUT` request to put data in this resource so it is actually created.
1. Confirm that the response code a success code.
1. Send a `GET` request for the resource's immediate container.
1. Confirm that the response code is `200`.
1. Parse the response and confirm that the resource is a member of this container.
1. Send a `GET` request for the resource's grandparent container (the original test container)
1. Confirm that the response code is `200`.
1. Parse the response and confirm that the resource's immediate container is a member of this container.

## web-access-control/protected-operation/read-resource-access-R.feature
The purpose of this test is to set up a resource with a combination of access controls and then confirm that the
WAC-Allow header reports the correct permissions.

```gherkin
Feature: Bob can only read an RDF resource to which he is only granted read access

  Background: Create test resource with read-only access for Bob
    * def setup =
    """
      function() {
        const testContainer = createTestContainer();
        const resource = testContainer.createChildResource('.ttl', karate.readAsString('../fixtures/example.ttl'), 'text/turtle');
        if (resource.exists()) {
          const access = resource.getAccessDatasetBuilder(webIds.alice)
            .setAgentAccess(resource.getUrl(), webIds.bob, ['read'])
            .build();
          resource.setAccessDataset(access);
        }
        return resource;
      }
    """
    * def resource = callonce setup
    * assert resource.exists()
    * def resourceUrl = resource.getUrl()
    * url resourceUrl

  Scenario: Bob can read the resource with GET
    Given headers clients.bob.getAuthHeaders('GET', resourceUrl)
    When method GET
    Then status 200

  Scenario: Bob can read the resource with HEAD
    Given headers clients.bob.getAuthHeaders('HEAD', resourceUrl)
    When method HEAD
    Then status 200

  Scenario: Bob cannot PUT to the resource
    Given request '<> <http://www.w3.org/2000/01/rdf-schema#comment> "Bob replaced it." .'
    And headers clients.bob.getAuthHeaders('PUT', resourceUrl)
    And header Content-Type = 'text/turtle'
    When method PUT
    Then status 403

  Scenario: Bob cannot PATCH the resource
    Given request 'INSERT DATA { <> a <http://example.org/Foo> . }'
    And headers clients.bob.getAuthHeaders('PATCH', resourceUrl)
    And header Content-Type = 'application/sparql-update'
    When method PATCH
    Then status 403

  Scenario: Bob cannot POST to the resource
    Given request '<> <http://www.w3.org/2000/01/rdf-schema#comment> "Bob replaced it." .'
    And headers clients.bob.getAuthHeaders('POST', resourceUrl)
    And header Content-Type = 'text/turtle'
    When method POST
    Then status 403

  Scenario: Bob cannot DELETE the resource
    Given headers clients.bob.getAuthHeaders('DELETE', resourceUrl)
    When method DELETE
    Then status 403
```

The `Background` for this test:
1. Sets up a function which will be called once for the whole set of scenarios
    1. Creates a test container (which isn't yet instantiated).
    1. Creates a resource in this container using an example Turtle file.
    1. Adds an ACL for the resource which grants Bob read access. It logs this to make it visible in the reports.
1. Use `callonce` to run the setup process once for all scenarios.
1. Asserts that this resource exists (if it doesn't the test will stop at this point).
1. Sets up the URL for the HTTP requests used in all of the scenarios.

The scenarios then:
1. Set up the authorization headers for Bob to make each request.
1. Send a request using each type of HTTP method.
1. Confirm that the status codes for the `GET` and `HEAD` requests are all `200`.
1. Confirm that the status codes for `PUT`, `PATCH`, `POST` and `DELETE` requests are all `403`.

# Specification Annotations
All test cases should be linked to the related requirements in one of the Solid specifications. This depends on the
specifications being annotated:
* Provide each requirement with an identifier which should also be a valid URL in the specification
* Identify the subject of the requirement (e.g. client or server)
* Define the requirement level (e.g. SHOULD, MUST, MAY)

The intention is that this will be done as RDFa annotations in the specification documents but it is understood that
this will take some time. As a workaround, the same data may be provided in Turtle format separate to the specification.

For example:
```turtle
prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
prefix xsd: <http://www.w3.org/2001/XMLSchema#>
prefix doap: <http://usefulinc.com/ns/doap#>
prefix spec: <http://www.w3.org/ns/spec#>

<https://solidproject.org/TR/2021/wac-20210711>
  a doap:Specification ;
  spec:requirement
        <https://solidproject.org/TR/2021/wac-20210711#access-modes> ,
        <https://solidproject.org/TR/2021/wac-20210711#access-objects>
.

<https://solidproject.org/TR/2021/wac-20210711#access-modes>
  spec:requirementSubject spec:Server ;
  spec:requirementLevel spec:MUST .

<https://solidproject.org/TR/2021/wac-20210711#access-objects>
  spec:requirementSubject spec:Server ;
  spec:requirementLevel spec:MUST .
```

The specification vocab used above is under development, but the latest version is at
https://github.com/solid/vocab/blob/specification-terms/spec.ttl.

# Test Manifest
The test cases themselves need to be described in a manifest file. For each test case, this provides:
* A link to the specification requirement `spec:requirementReference`
* The review status of this test case `td:reviewStatus` which can be one of:
  * `td:unreviewed` - test has been proposed, but hasn't been reviewed (e.g. for completeness) yet.
  * `td:accepted` - test has gone through a first review, which shows it as valid for further processing.
  * `td:assigned` - a more specific review of the test has been assigned to someone.
  * `td:approved` - test has gone through the review process and was approved.
  * `td:rejected` - test has gone through the review process and was rejected.
  * `td:onhold` - test had already gone through the review process, but the results of the review need to be re-assessed due to new input.
* The capabilities the test subject needs to support to be able to run the test case `td:preCondition`. The intention is
  to encode this information properly, but at present it is a simple list of keywords which are matched against the
  values of `solid-test:features` in the subject description found in `test-subjects.ttl`:
  * `authentication`
  * `acl` - either WAC or ACP supported
  * `wac-allow` - supports the `WAC-Allow` header
* A link to the script that defines the test case `spec:testScript` - note that the URL provided is normally mapped to 
  the local file system in the test harness configuration file.

Note that there may be more than one test case linked to a requirement as shown in the example below:
```turtle
prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
prefix xsd: <http://www.w3.org/2001/XMLSchema#>
prefix dcterms: <http://purl.org/dc/terms/>
prefix td: <http://www.w3.org/2006/03/test-description#>
prefix spec: <http://www.w3.org/ns/spec#>

prefix manifest: <#>

manifest:protected-operation-not-read-resource-access-AWC
  a td:TestCase ;
  spec:requirementReference <https://solidproject.org/TR/2021/wac-20210711#access-modes> ;
  td:reviewStatus td:unreviewed ;
  td:preCondition "authentication", "acl" ;
  spec:testScript
    <https://github.com/solid/specification-tests/web-access-control/protected-operation/not-read-resource-access-AWC.feature> .

manifest:protected-operation-not-read-resource-default-AWC
  a td:TestCase ;
  spec:requirementReference <https://solidproject.org/TR/2021/wac-20210711#access-modes> ;
  td:reviewStatus td:unreviewed ;
  td:preCondition "authentication", "acl" ;
  spec:testScript
    <https://github.com/solid/specification-tests/web-access-control/protected-operation/not-read-resource-default-AWC.feature> .

manifest:acl-object-none
  a td:TestCase ;
  spec:requirementReference <https://solidproject.org/TR/2021/wac-20210711#access-objects> ;
  td:reviewStatus td:unreviewed ;
  td:preCondition "authentication", "acl" ;
  spec:testScript
    <https://github.com/solid/specification-tests/web-access-control/acl-object/container-none.feature> .
```
