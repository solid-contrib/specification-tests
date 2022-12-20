# Solid Specification Conformance Tests

<!-- MarkdownTOC -->

- [Running these tests locally](#run-script)
- [KarateDSL](#karatedsl)
  - [Structure of a Test Case](#structure-of-a-test-case)
  - [Data related keywords](#data-related-keywords)
  - [HTTP related keywords](#http-related-keywords)
  - [Karate Object](#karate-object)
  - [Calling Functions](#calling-functions)
  - [Data driven tests](#data-driven-tests)
  - [Comments](#comments)
- [Test Harness Capabilities](#test-harness-capabilities)
  - [Global Variables](#global-variables)
  - [Helper Functions](#helper-functions)
  - [Libraries](#libraries)
- [Example Test Cases](#example-test-cases)
- [Specifications](#specifications)
  - [Annotations](#annotations)
  - [Versions](#versions)
- [Test Manifest](#test-manifest)
- [Versioning](#versioning)

<!-- /MarkdownTOC -->

This repository contains the tests that can be executed by the
[Solid Conformance Test Harness (CTH)](https://github.com/solid/conformance-test-harness). The best way to run the 
harness is by using the [Docker image](https://hub.docker.com/r/solidproject/conformance-test-harness).

The tests are written in a language called [KarateDSL](https://karatelabs.github.io/karate/). This is a simple 
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
[here](https://hub.docker.com/r/solidproject/conformance-test-harness).

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
git clone git@github.com:solid-contrib/specification-tests.git
cd specification-tests
````

Use the script with the `-d` option to use the local tests: 
```shell
./run.sh -d . css
```
## Creating a script for a CI workflow
If you just want to run tests against a single test subject, for example in a CI workflow, you can create a script such
as this one which will run the tests embedded in the latest published CTH image:
```shell
#!/bin/bash

mkdir -p config reports

cat > ./config/application.yaml <<EOF
subjects: /data/test-subjects.ttl
sources:
  # Protocol specification & manifest
  # Editor's draft (fully annotated)
  - https://solidproject.org/TR/protocol
  - https://github.com/solid-contrib/specification-tests/blob/main/protocol/solid-protocol-test-manifest.ttl

  # WAC specification & manifest
  # Editor's draft (fully annotated)
  - https://solid.github.io/web-access-control-spec
  - https://github.com/solid-contrib/specification-tests/blob/main/web-access-control/web-access-control-test-manifest.ttl

  # Published draft (not annotated)
  # This is an example of how you could run tests for a specific version of the specification 
#  - https://solidproject.org/TR/2021/wac-20210711
#  - https://github.com/solid-contrib/specification-tests/blob/main/web-access-control/web-access-control-test-manifest-20210711.ttl

mappings:
  - prefix: https://github.com/solid-contrib/specification-tests/blob/main
    path: /data
EOF

docker pull solidproject/conformance-test-harness
docker run -i --rm \
  -v "$(pwd)"/:/data \
  -v "$(pwd)"/config:/app/config \
  -v "$(pwd)"/reports:/reports \
  -v "$(pwd)"/target:/app/target \
  --env-file=.env solidproject/conformance-test-harness \
  --output=/reports --target=https://github.com/solid/conformance-test-harness/css "$@"
```

Just change the `target` option and create a `.env` file for the server as mentioned above.

# KarateDSL

The following is a high level overview of KarateDSL, focused on the most common aspects required in these specification
tests. For more detail please go to:
* [KarateDSL](https://karatelabs.github.io/karate/)
* [Syntax Guide](https://karatelabs.github.io/karate/#syntax-guide)

## Structure of a Test Case
The basic structure of a KarateDSL test file is:
```gherkin
@tag1
Feature: The title of the test case

  Background: Set up steps performed for each Scenario
    * def variable = 'something'

  @tag2
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
The example above shows the use of tags. If you tag a feature, the tag is applied to all scenarios and combined with any
tags on individual scenarios. The tag names should describe functionality that is optional so that testers can choose to
skip tests that are not appropriate to the server being tested. For example, you would tag any tests that only work for
servers implementing ACP with `@acp`.

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
2. Then use `Given` to start describing the context for the test. Often this will be where you set up the URL or path for
  the interaction.
3. Use `And` to provide more details for the context (e.g., setting up request headers).
4. The `When` keyword represents the action, but remember it has the same meaning as `*`. The request is actually
  triggered by the use of `method`.
5. Next you can begin to make assertions about the response starting with the `Then` keyword. Often the
  status is checked first.
6. Finally, you can use `And` to describe additional assertions. You could use `*` if you need to create variables and
  analyze the response as this allows you to reserve `And` for assertions. It is a style choice since the keywords have
  no meaning to the test harness as already stated.
  
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
```gherkin
And headers { Accept: 'text/turtle', 'Accept-Charset': 'iso-8859-5' }
```

Note:
* That these keywords can take expressions or functions which return a single value or a map for the multiple value
versions.
* These commands are additive - the key-value pair(s) are added to the request.
* The key is not in quotes in the single key-value variants.
* Karate tries to help by working out the default `Content-Type` from the request body however, this presents a problem
  if you need to test requests without the header. The `send` method of [SolidClient](#solidclient) provides a solution.

If you want to set up some headers to be used across multiple requests, you can use the following command:
```gherkin
* configure headers = { 'Content-Type': 'application/json' }
```
If you use this in the `Background`, the headers will apply to all scenarios and cannot be overwritten with other 
methods of adding headers. If you need to replace these headers in one of those scenarios, you will need to use
`configure` again to either replace them or set them to `null` and then set them as normal using either `header` or 
`headers`. The recommendation is to only use `configure headers` in the `Background` for any headers that should apply
to requests in all scenarios and won't need to be overwritten. Use `header` or `headers` within `Scenarios` to add extra
headers. Avoid using `configure headers` inside a `Scenario` unless you are setting up common headers for a series of 
requests within the one `Scenario`.

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

Since Karate has special handling of JSON you need to be careful when passing JSON which includes local variables in the
request. You can either use `#()` to embed an expression or wrap the whole JSON object in `()` so that it is treated as
Javascript and not processed by Karate. Also be aware that when sending JSON-LD you need to wrap any keywords in quotes.
Both of the following approaches will work but the first is preferred as it is more obvious:
```gherkin
* def url = 'http://localhost/test'
And request {@context: ['https://www.w3.org/ns/solid/notification/v1'], type: 'WebSocketSubscription2021', topic: '#(url)'}
And request ({'@context': ['https://www.w3.org/ns/solid/notification/v1'], type: 'WebSocketSubscription2021', topic: url})
```

### Sending the request
The HTTP request is sent when you use the `method` keyword and a specific method. You would normally use this in
conjunction with the `When` keyword:
```gherkin
When method PUT
```

Note:
* Karate will not allow you to set up request with unknown HTTP methods so in the rare cases when you need to test this,
  the `send` method of [SolidClient](#solidclient) provides a solution.

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
[Payload Assertions](https://karatelabs.github.io/karate/#payload-assertions).

In their simplest forms, `match` and `assert` simply take a JavaScript expression that evaluates to a boolean:
```gherkin
* match foo == bar && foo2 != 10
```
The left-hand side can be a variable name, a JSON/XML path, a function call, or anything in parentheses which evaluates as
JavaScript. The right-hand side can be any [Karate expression](https://karatelabs.github.io/karate/#karate-expressions).
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
fails. There is a new function which helps with this problem as the last example shows:
```gherkin
* match header Content-Type contains 'text/turtle'
* match header content-type contains 'text/turtle'
* match responseHeaders['Content-Type'][0] contains 'text/turtle'
* match responseHeaders['content-type'][0] contains 'text/turtle'  # fails as responseHeaders['content-type'] returns null
* match karate.response.header('content-type') contains 'text/turtle'
```
Note that it is safer to use `contains` instead of `==` in this case since the header value may contain an encoding
element such as `; charset=UTF-8`.
You can also get an array of all the values of a header with `karate.response.headerValues()`.

Using the `responseStatus` variable as an alternative to `status` was mentioned earlier.

## Karate Object
Within a test case, you have access to the Karate object which has a number of useful methods described
[here](https://karatelabs.github.io/karate/#the-karate-object). This includes methods to manipulate data, call functions
with a lock so they only run once, read from files, create loops, and handle async calling.

You can also access additional environment values using `karate.properties['OPTION']` where the values are defined in
your environment files using `JAVA_TOOL_OPTIONS`. For example:
```shell
JAVA_TOOL_OPTIONS=-Dproperty1=value1 -Dproperty2=value2
```
You should confirm the value is set before tests continue:
```gherkin
* def externalProperty = karate.properties['property1']
* match externalProperty == '#notnull'
```

## Calling Functions
See https://karatelabs.github.io/karate/#code-reuse--common-routines

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

## Data driven tests
When a group of tests are very similar it is good to use a `Scenario Outline` with `Examples` to set up tests on a data-
driven basis. There is a good description of this here: https://github.com/karatelabs/karate#data-driven-tests and an
example below.
```gherkin
Scenario Outline: Test status <status> with <method>
  Given url 'https://httpbin.org/status/<status>'
  When method <method>
  Then status <status>
  Examples:
    | method | status |
    | GET    | 200    |
    | GET    | 300    |
    | DELETE | 400    |
```

This runs 3 tests, replacing placeholders in the scenario name and throughout the test. This is a simple example and the
documentation linked above shows more possibilities, including generating tests in a function call.

*Note* If you are putting non-string data (e.g. a boolean or json) in a column then add `!` as a suffix to the column
name to make Karate handle the values correctly.  

## Comments
Comments in Karate test files are handled according to their position in the file. When they are added to reports this
is done with the `dcterms:description` predicate, applied as follows:
* Feature comments: `td:TestCase`
* Scenario or Step comments: `prov:Activity`
 
The following example explains how comments in different positions are used. Note that in each case the comment could
run over multiple lines and that any spaces before the `#` are stripped off.
```gherkin
# Feature level comments
Feature: Feature title
  # Comments here are treated as comments on the background and are prepended to scenario comments for each scenario
  Background: Set up the test
    # This applies to the variable declaration line below
    * def myVar = 'variable'
    # All comments between sections (Background or Scenario) are attached to the subsequent section

  # This would be the second comment for this Scenario as noted above
  Scenario: Run a test
    # This applies to the Given step below
    Given url '/test'
    When method GET
    Then Status 200

  Scenario: Run a test without its own comment but it would still pick up the background comments
    Given url '/test2'
    When method GET
    Then Status 200
    # There are no further sections so this comment will not be attached to the report
```

### Change logs
It would be good to keep a log of changes in a test case but we don't want to attach this to the report as it may make
them unnecessarily long. The best place to put the change log is therefore the bottom of the file where, as explained
above, comments are not included in the reports.

# Test Harness Capabilities

## Global Variables
The test harness makes some variables available to all tests:

* `rootTestContainer` - An instance of `SolidContainer` pointing to the container in which all test files will be created
  for this run of the test suite. This is guaranteed to exist when the tests start and is a unique URL for every run of
  the test suite. Each test should create its own test container from this container so that all resources created
  within the test are isolated from other tests.
* `clients` - An object containing the `SolidClient` instances that are set up for authenticated access by `alice` and 
  `bob`. One of these clients will need to be passed to any newly created `SolidContainer` or `SolidResource` - The user
  names are the key (e.g., `clients.alice`).
* `webIds` - An object containing the webIds of the 2 users. These are needed when setting up ACLs (e.g., `webIds.alice`).
* `RDF`, `XSD`, `LDP`, `ACL`, `FOAF`, `ACP`, `SOLID`, `NOTIFY`, `PROV`, `AS` - Namespaces for use when constructing IRIs.

## Helper Functions

### RDF Model Support
KarateDSL 'natively' supports JSON and XML, but sadly it does not yet support RDF. As a result you will need a library
to parse RDF documents and query them.

#### `iri(iri)`
This function returns an IRI object from the string version provided. The IRI can be used in functions querying RDF
models.

#### `iri(namespace, localName)`
This function returns an IRI object by combining the namespace and localName strings provided. The IRI can be used in
functions querying RDF models.

#### `literal(value, option)`
Returns a Literal value that can be used in functions querying RDF models. There are different variants of this function
depending on the type of `value` and whether the `option` parameter is provided:
type:
* `literal(object)` - attempt to convert the object based upon its type. This supports Javascript strings, integers and
  booleans, converting them to plain strings or `xsd:int` or `xsd:boolean` accordingly. If an unsupported type is
  provided the function will throw an exception.
  ```
  literal('text')
  literal(1234)
  literal(true)
  ```
* `literal(java.math.BigDecimal)` - converts to `xsd:decimal`.
  ```
  literal(new java.math.BigDecimal('1.2'))
  ```
* `literal(java.math.BigInteger)` - converts to `xsd:integer`.
  ```
  literal(new java.math.BigInteger('1234567890'))
  ```
* `literal(string, languageTag)` - converts to a string with a language tag set.
  ```
  literal('text', 'en')
  ```
* `literal(string, dataTypeIRI)` - converts to the given data type.
  ```
  literal('1.2', iri(XSD, 'decimal'))
  literal('1', iri(XSD, 'short'))
  literal('1234567890', iri(XSD, 'integer'))
  literal('1234', iri(XSD, 'int'))
  literal('1234567890', iri(XSD, 'long'))
  literal('1234567890.0', iri(XSD, 'float'))
  literal('1234567890.0', iri(XSD, 'double'))
  literal('2021-11-01', iri(XSD, 'date'))
  literal('2021-11-01T15:14:13.000Z', iri(XSD, 'dateTime'))
  literal('true', iri(XSD, 'boolean'))
  ```

### Parsing Functions
#### `parse(data, contentType, baseUri?)` (static function)
Parses an RDF document into a queryable model. The supported content types are: `text/turtle`, `application/ld+json`,
`text/html`, `application/xhtml+xml`.
* Parameters:
  * data - The RDF data.
  * contentType - The content type for this data.
  * baseUri (optional) - The base URI used for any relative IRIs.
* Returns a model array of strings in the form `<subject> <predicate> <object> .`

#### `contains(model)`
Returns true if the model passed in is a subset of the model the function is applied to. If it is not a subset it logs
information highlighting the differences.
* Parameters:
  * model - The model to compare to this one.
* Returns true or false.

#### `getMembers()` or read-only property `members`
Designed for use with container contents, this function extracts any objects that match the pattern
`<url> ldp:contains <object>` where `<url> a ldp:BasicContainer` and returns them as a list of strings.
* Returns a list of URLs.

#### `asTriples()`
Convert the model to triples.
* Returns a string.

#### `subjects(predicate, object)`
Returns a list of subjects matching the predicate and object.
* Parameters:
  * predicate - The iri of the predicate or null to match any.
  * object - The object value (iri/literal) or null to match any.
* Returns the list of subjects as strings.

#### `predicates(subject, object)`
Returns a list of predicates matching the subject and object.
* Parameters:
  * subject - The iri of the subject or null to match any.
  * object - The object value (iri/literal) or null to match any.
* Returns the list of predicates as strings.

#### `objects(subject, predicate)`
Returns a list of objects matching the subject and predicate.
* Parameters:
  * subject - The iri of the subject or null to match any.
  * predicate - The iri of the predicate or null to match any.
* Returns the list of objects as strings.

#### `contains(subject, predicate, object)`
Tests whether any statements exist that match the subject, predicate and object.
* Parameters:
  * subject - The iri of the subject or null to match any.
  * predicate - The iri of the predicate or null to match any.
  * object - The object value (iri/literal) or null to match any.
* Returns true if any matching statements are found.

### HTTP Header Support
##### `parseWacAllowHeader(headers)`
This function accepts the response headers, locates the `WAC-Allow` header, and parses it into a map object.
* Parameters:
  * headers - HTTP response headers. 
* Returns an object which will contain `user` and `public` keys plus any additional groups defined within the header.

It extracts all the access modes, and adds them as a list to the relevant group. The result can be treated as a JSON
object such as:
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

##### `parseLinkHeaders(headers)`
Ths processes the response headers to extract all the `Link` headers and return them in the form of
`List<Map<String, String>>`, where each item in the list is a map of the components of the link using the keys:
`rel`, `uri`, `title`, `type`. The `rel` and `uri` values are mandatory. The returned object can be treated as a JSON
object. 
* Parameters:
  * headers - HTTP response headers.
* Returns an object representing all the link headers.

For example:
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
Apply the target URI to the base URI to return a new URI. 
* Parameters:
  * base - The base URI.
  * target - The target URI or path to be resolved against the base URI.
* Returns a new URI.

For example
`resolveUri('https://example.org/test/resource', '/inbox/')` would return `https://example.org/inbox/`.

## Libraries

As previously mentioned, the global variable `clients` holds instances of `SolidClient` which are set up to be able to
access the test server as a specific user. There are some additional capabilities provided by this class. Most tests
will deal with resources and containers (which is a subclass of a resource). These objects are represented
by 2 classes in the test harness: `SolidResouce` and `SolidContainer`. For handling access controls in a universal way
there are two classes: `AccessDatasetBuilder` and `AccessDataset`. Finally, there are two libraries (`Utils` and
`RDFModel`) providing parsing functions for headers and RDF respectively. Their functions are exposed globally within
the Karate environment and have already been described above.

### SolidClient
The `SolidClient` class provides access to the test server on behalf of a user. This is mostly used internally within
`SolidResouce` and `SolidContainer` but there are three public API functions available.

#### `getAuthHeaders(method, uri)`
This returns a map of the authorization headers required for a request on behalf of the user registered in this instance
of the `SolidClient`. The map can be applied to a request being prepared in Karate using the `headers` keyword: 
```gherkin
  And headers clients.alice.getAuthHeaders('GET', url)
```
* Parameters:
  * method - The HTTP method of the request.
  * url - The absolute url of the request.
* Returns a map of headers.

#### `send(method, uri, data, headers, version)` and `sendAuthorized(method, uri, data, headers, version)`
This is an alternative way to send a request which allows testers to have full control over the HTTP method and request
headers. Karate will not allow invalid HTTP methods and sets some headers by default so this method allows some
additional edge case tests to be performed. The only request header these methods include by default is the `User-Agent`
so that requests are still traceable to the CTH. There are two versions of this method, the first sends un-authenticated 
requests, whereas the second adds the correct authorization headers for the user registered in this instance of the
`SolidClient`.
* Parameters:
  * method - The HTTP method of the request.
  * url - The absolute url of the request.
  * data - The data to be sent in the request (or null). 
  * headers - A map of key/value pairs to be send as request headers (or null). See the note below for additional tips.
  * version - The version of HTTP to use for the request "HTTP_1_1" or "HTTP_2".
* Returns the response as a map with the following structure:
  ```json5
  {
    version: "HTTP_1_1", // string (or HTTP_2 depending on which the server responded with)
    status: 200, // integer
    headers: {}, // map of all response headers
    body: "",    // the response body
  }
  ```
  This allows you to make assertions about the `response` using `assert` or `match` keywords. Note that you cannot use
  the shortcut style of `Then status 201` since the request has been made outside the Karate environment.
  ```gherkin
  Then assert response.status == 201
  And match response.header.location == someUrl
  And match response.body contains 'data'
  ```

The header parameter must be set carefully due to limitations in the way Karate translates JSON objects to Java. For
simple examples you can pass headers inline:
```gherkin
* def response = clients.alice.send('POST', resource.url, 'data', {'Content-Type': 'text/plain', Accept: 'text/plain'})
```
If a header has multiple values they must be set once using an array but this cannot be inline:
```gherkin
* def values = ['a', 'b', 'c']
* def response = clients.alice.send('GET', resource.url, 'data', {'X-test': values})
```
Obviously you can set up the whole map as a variable:
```gherkin
* def headers = {'X-test1': '1', 'X-test2': ['a', 'b', 'c']}
* def response = clients.alice.send('GET', resource.url, 'data', headers)
```

### SolidResource
The `SolidResource` class represents a resource or container on the server. Since this is also the base class for
`SolidContainer`, it includes methods that are related to containers. It is not common to need use this class directly
in a test as most resources and containers are created from the starting point of the `rootTestContainer`. Since this
class conforms to the JavaBeans standard, getters and setters can be treated as properties when accessed from
JavaScript. 

#### `SolidResource.create(solidClient, url, body, contentType)`
A static method that can create a resource on the server.
* Parameters:
  * solidClient - The authenticated client to use for this request (e.g., `clients.alice`).
  * url - The absolute url of the resource to create.
  * body - The data to be put in the resource.
  * contentType - The content type of ths data.
* Returns an instance of `SolidResource`.

#### `getUrl()` or read-only property `url`
Get the URL of this resource.
* Returns a string.

#### `getContainer()` or read-only property `container`
Gets the `SolidContainer` instance representing the parent container of this resource or ultimately returns the root
container.
* Returns a `SolidContainer`.

#### `getAclUrl()` or read-only property `aclUrl`
Get the ACL URL for this resource.
* Returns a string.

#### `findStorage()`
Get the storage root for this resource by working up the path hierarchy looking for the `pim:Storage` link header.
* Returns a new SolidResource representing the storage root or null if it could not be found or is not accessible to
  the user.

#### `isStorageType()` or read-only property `storageType`
Does this resource have the `pim:Storage` link header identifying it as a storage-type container?
* Returns a boolean.

#### `getAccessDatasetBuilder()` or read-only property `accessDatasetBuilder`
There are currently 2 access control implementations supported by the test harness:
* [Web Access Control (WAC)](https://solidproject.org/TR/wac)
* [Access Control Policies (ACP)](https://solid.github.io/authorization-panel/acp-specification)

Get an object that can build a set of access control statements in a WAC/ACP agnostic way. The object is initialized
by adding owner access for the specified owner (not applicable in ACP mode).
* Returns an [AccessDatasetBuilder](#accessdatasetbuilder).

#### `getAccessDataset()` and `setAccessDataset(accessDataset)` or read-write property `accessDataset`
Get or set an object representing the access control document/policy.
* Returns or accepts an [AccessDataset](#accessdataset).

#### `delete()`
Delete this resource and, if it is a container, recursively delete its members.

### SolidContainer
The `SolidContainer` class represents a container on the server and is a subcvlass of `SolidResource`. It is not common
to need use this class directly in a test as most resources and containers are created from the starting point of the
`rootTestContainer`. Since this class conforms to the JavaBeans standard, getters and setters can be treated as
properties when accessed from JavaScript.

#### `SolidContainer.create(solidClient, url)`
A static method that can create a container on the server.
* Parameters:
  * solidClient - The authenticated client to use for this request (e.g., `clients.alice`).
  * url - The absolute url of the container to create.
* Returns an instance of `SolidContainer`.

#### `instantiate()`
Create this previously reserved container on the server.
* Returns an instance of `SolidContainer` to allow call chaining.

#### `reserveContainer()`
Reserve a container as a child of this container using a UUID as the name but do not instantiate it on the server.
* Returns an instance of `SolidContainer` to allow call chaining.

#### `createContainer()`
Create a container as a child of this container using a UUID as the name. This is the equivalent of reserving a
container and then instantiating it.
* Returns an instance of `SolidContainer` to allow call chaining.

#### `reserveResource(suffix)`
Reserve a `SolidResource` as a child of this container using a UUID as the name with the provided suffix, but do not
instantiate it on the server.
* Parameters:
  * suffix - The filename extension to use or a blank string if not needed (e.g., `'.ttl'`).
* Returns an instance of `SolidResource` to allow call chaining.

#### `createResource(suffix, body, contentType)`
Create a `SolidResource` as a child of this container using a UUID as the name with the provided suffix, then put the
provided contents into it.
* Parameters:
  * suffix - The filename extension to use or a blank string if not needed (e.g., `'.ttl'`).
  * body - The data to be put in the resource.
  * contentType - The content type of ths data.
* Returns an instance of `SolidResource`.

#### `listMembers()`
Get a list of all the members of this container.
* Returns an array of URLs as strings.

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
const access = testContainer.accessDatasetBuilder
        .setAgentAccess(testContainer.url, webIds.bob, ['write'])
        .setInheritableAgentAccess(testContainer.url, webIds.bob, ['append', 'write', 'control'])
        .build();
testContainer.accessDataset = access;
```  

When the `AccessDatasetBuilder` is first created for a resource, it is configured with full access for the owner of that
resource and the base URI of the ACL is automatically set so there is no need to call `setOwnerAccess` or `setBaseUri`.

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

#### `asSparqlInsert()`
Returns a string with the turtle representation of the set of rules in the WAC or ACP format wrapped as a SPARQL
INSERT statement. This is only used for ACP.

#### `parseTurtle(data, baseUri)`
In the rare case where you want to manually construct an ACL document you may use this function to replace the content
of an `AccessDataset` object and then apply it to a resource.

### TestHarnessException

Any exceptions generated within the libraries below are wrapped as `TestHarnessException` errors and will be trapped
and reported by the Karate test engine. If you need to trap these exceptions within a test you can use a JavaScript
try/catch mechanism:
```gherkin
    * eval
    """
    try {
      resource = testContainer.createResource('.ttl', exampleTurtle, 'text/turtle');
    } catch(err) {
      resource = null
      karate.log(err.message);
    }
    """
```

# Example Test Cases
The following are a selection of example tests that demonstrate different features of the test harness, and show 
various approaches to writing tests.

## protocol/content-negotiation/content-negotiation-turtle.feature
The purpose of this test is to confirm that a Turtle resource can be fetched as either JSON-LD or Turtle using content
negotiation.

```gherkin
Feature: Requests support content negotiation for Turtle resource

  Background: Create a turtle resource
    * def testContainer = rootTestContainer.reserveContainer()
    * def exampleTurtle = karate.readAsString('../fixtures/example.ttl')
    * def resource = testContainer.createResource('.ttl', exampleTurtle, 'text/turtle');
    * def expected = parse(exampleTurtle, 'text/turtle')
    * configure headers = clients.alice.getAuthHeaders('GET', resource.url)
    * url resource.url

  Scenario: Alice can GET the TTL example as JSON-LD
    Given header Accept = 'application/ld+json'
    When method GET
    Then status 200
    And match header Content-Type contains 'application/ld+json'
    And assert parse(response, 'application/ld+json', resource.url).contains(expected)

  Scenario: Alice can GET the TTL example as TTL
    Given header Accept = 'text/turtle'
    When method GET
    Then status 200
    And match header Content-Type contains 'text/turtle'
    And assert parse(response, 'text/turtle', resource.url).contains(expected)
```

The `Background` for this test:
1. Sets up a test container (which isn't yet instantiated).
2. Loads example Turtle data into a variable from a file.
3. Puts this data into a resource inside the test container.
4. Convert the example data into an array of triples for later comparisons.
6. Sets up the URL and authorization headers for the HTTP requests used in the scenarios. 
  
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
        const testContainer = rootTestContainer.reserveContainer();
        const resource = testContainer.createResource('.ttl', karate.readAsString('../fixtures/example.ttl'), 'text/turtle');
        const access = resource.accessDatasetBuilder
          .setAgentAccess(resource.url, webIds.bob, ['write'])
          .setPublicAccess(resource.url, ['read', 'append'])
          .build();
        resource.accessDataset = access;
        return resource;
      }
    """
    * def resource = callonce setup
    * url resource.url

  Scenario: There is an acl on the resource containing Bob's WebID
    Given url resource.aclUrl
    And headers clients.alice.getAuthHeaders('GET', resource.aclUrl)
    And header Accept = 'text/turtle'
    When method GET
    Then status 200
    And match header Content-Type contains 'text/turtle'
    And match response contains webIds.bob

  # Note this test is not applicable to a server using ACP as the WAC-Allow header is not supported currently.
  # In ACP mode, the following step would fail as there will be an ACL on the parent - this step needs to change
  # to ask the test harness to confirm there is no inherited access.
  Scenario: There is no acl on the parent
    Given url resource.container.aclUrl
    And headers clients.alice.getAuthHeaders('HEAD', resource.container.aclUrl)
    And header Accept = 'text/turtle'
    When method HEAD
    Then status 404

  Scenario: Bob calls GET and the header shows RWA access for user, RA for public
    Given headers clients.bob.getAuthHeaders('GET', resource.url)
    When method GET
    Then status 200
    And match header WAC-Allow != null
    * def result = parseWacAllowHeader(responseHeaders)
    And match result.user contains only ['read', 'write', 'append']
    And match result.public contains only ['read', 'append']

  Scenario: Bob calls HEAD and the header shows RWA access for user, RA for public
    Given headers clients.bob.getAuthHeaders('HEAD', resource.url)
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
    1. Adds an ACL for the resource which grants Bob write access and the public read and append access.
1. Use `callonce` to run the setup process once for all scenarios.
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
    * def testContainer = rootTestContainer.reserveContainer()
    * def intermediateContainer = testContainer.reserveContainer()
    * def resource = intermediateContainer.reserveResource('.txt')

  Scenario: PUT creates a grandchild resource and intermediate containers
    Given url resource.url
    And headers clients.alice.getAuthHeaders('PUT', resource.url)
    And header Content-Type = 'text/plain'
    And request 'Hello'
    When method PUT
    Then status 201

    * def parentUrl = intermediateContainer.url
    Given url parentUrl
    And headers clients.alice.getAuthHeaders('GET', parentUrl)
    And header Accept = 'text/turtle'
    When method GET
    Then status 200
    And match parse(response, 'text/turtle', parentUrl).members contains resource.url

    * def grandParentUrl = testContainer.url
    Given url grandParentUrl
    And headers clients.alice.getAuthHeaders('GET', grandParentUrl)
    And header Accept = 'text/turtle'
    When method GET
    Then status 200
    And match parse(response, 'text/turtle', grandParentUrl).members contains intermediateContainer.url

  Scenario: PATCH creates a grandchild resource and intermediate containers
    Given url resource.url
    And headers clients.alice.getAuthHeaders('PATCH', resource.url)
    And header Content-Type = 'application/sparql-update'
    And request 'INSERT DATA { <#hello> <#linked> <#world> . }'
    When method PATCH
    Then assert responseStatus >= 200 && responseStatus < 300

    * def parentUrl = intermediateContainer.url
    Given url parentUrl
    And headers clients.alice.getAuthHeaders('GET', parentUrl)
    And header Accept = 'text/turtle'
    When method GET
    Then status 200
    And match parse(response, 'text/turtle', parentUrl).members contains resource.url

    * def grandParentUrl = testContainer.url
    Given url grandParentUrl
    And headers clients.alice.getAuthHeaders('GET', grandParentUrl)
    And header Accept = 'text/turtle'
    When method GET
    Then status 200
    And match parse(response, 'text/turtle', grandParentUrl).members contains intermediateContainer.url

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
        const testContainer = rootTestContainer.reserveContainer();
        const resource = testContainer.createResource('.ttl', karate.readAsString('../fixtures/example.ttl'), 'text/turtle');
        const access = resource.accessDatasetBuilder
          .setAgentAccess(resource.url, webIds.bob, ['read'])
          .build();
        resource.accessDataset = access;
        return resource;
      }
    """
    * def resource = callonce setup
    * url resource.url

  Scenario: Bob can read the resource with GET
    Given headers clients.bob.getAuthHeaders('GET', resource.url)
    When method GET
    Then status 200

  Scenario: Bob can read the resource with HEAD
    Given headers clients.bob.getAuthHeaders('HEAD', resource.url)
    When method HEAD
    Then status 200

  Scenario: Bob cannot PUT to the resource
    Given request '<> <http://www.w3.org/2000/01/rdf-schema#comment> "Bob replaced it." .'
    And headers clients.bob.getAuthHeaders('PUT', resource.url)
    And header Content-Type = 'text/turtle'
    When method PUT
    Then status 403

  Scenario: Bob cannot PATCH the resource
    Given request 'INSERT DATA { <> a <http://example.org/Foo> . }'
    And headers clients.bob.getAuthHeaders('PATCH', resource.url)
    And header Content-Type = 'application/sparql-update'
    When method PATCH
    Then status 403

  Scenario: Bob cannot POST to the resource
    Given request '<> <http://www.w3.org/2000/01/rdf-schema#comment> "Bob replaced it." .'
    And headers clients.bob.getAuthHeaders('POST', resource.url)
    And header Content-Type = 'text/turtle'
    When method POST
    Then status 403

  Scenario: Bob cannot DELETE the resource
    Given headers clients.bob.getAuthHeaders('DELETE', resource.url)
    When method DELETE
    Then status 403
```

The `Background` for this test:
1. Sets up a function which will be called once for the whole set of scenarios
    1. Creates a test container (which isn't yet instantiated).
    1. Creates a resource in this container using an example Turtle file.
    1. Adds an ACL for the resource which grants Bob read access. It logs this to make it visible in the reports.
1. Use `callonce` to run the setup process once for all scenarios.
1. Sets up the URL for the HTTP requests used in each of the scenarios.

The scenarios then:
1. Set up the authorization headers for Bob to make each request.
1. Send a request using each type of HTTP method.
1. Confirm that the status codes for the `GET` and `HEAD` requests are all `200`.
1. Confirm that the status codes for `PUT`, `PATCH`, `POST` and `DELETE` requests are all `403`.

# Specifications
## Annotations
All test cases should be linked to the related requirements in one of the Solid specifications. This depends on the
specifications being annotated:
* Provide each requirement with an identifier which should also be a valid URL in the specification
* Identify the subject of the requirement (e.g. client or server)
* Define the requirement level (e.g. SHOULD, MUST, MAY)
* Provide access to the text of the requirement

The intention is that this will be done as RDFa annotations in the specification documents, but it is understood that
this will take some time. As a workaround, the same data may be provided in Turtle format separate to the specification.

For example:
```turtle
prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
prefix xsd: <http://www.w3.org/2001/XMLSchema#>
prefix doap: <http://usefulinc.com/ns/doap#>
prefix spec: <http://www.w3.org/ns/spec#>

prefix wac: <https://solidproject.org/TR/2021/wac-20210711#>

<https://solidproject.org/TR/2021/wac-20210711>
  a doap:Specification ;
  spec:requirement
        wac:access-modes ,
        wac:access-objects
.

wac:access-modes
  spec:requirementSubject spec:Server ;
  spec:requirementLevel spec:MUST ;
  spec:statement "text of the requirement"@en .

wac:access-objects
  spec:requirementSubject spec:Server ;
  spec:requirementLevel spec:MUST ;
  spec:statement "text of the requirement"@en .
```

The specification vocab used above is under development, but the latest version is at
https://github.com/solid/vocab/blob/specification-terms/spec.ttl.

## Versions
It may be necessary to run tests against a specific version of a specification. This is simple to achieve by changing
the files passed to CTH either via the `--source` option or in `application.yaml`. A specification must be paired with 
a test manifest, for example:
```yaml
sources:
  - https://solidproject.org/TR/2021/wac-20210711
  - https://github.com/solid-contrib/specification-tests/blob/main/web-access-control/web-access-control-test-manifest-20210711.ttl
```
The manifest file might be a copy of the one used for the current version of a specification, however internal references
must point to the right specification. This is easiest to do by modifying a namespace prefix and using that prefix for
all such references.
```turtle
prefix wac: <https://solidproject.org/TR/2021/wac-20210711#>
prefix manifest: <#>
manifest:protected-operation-not-read-resource-access-AWC
  a td:TestCase ;
  spec:requirementReference wac:access-modes ;
  td:reviewStatus td:approved ;
  spec:testScript
    <https://github.com/solid-contrib/specification-tests/blob/main/web-access-control/protected-operation/not-read-resource-access-AWC.feature> .
```
If the test implementation has changed between specification versions, then you could have an alternative version of the
feature file and point to the relevant one in the manifest file.

The test report header shows the link to the specification making it clear which version was used.

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

prefix wac: <https://solidproject.org/TR/2021/wac-20210711#>

prefix manifest: <#>

manifest:protected-operation-not-read-resource-access-AWC
  a td:TestCase ;
  spec:requirementReference wac:access-modes ;
  td:reviewStatus td:unreviewed ;
  spec:testScript
    <https://github.com/solid-contrib/specification-tests/blob/main/web-access-control/protected-operation/not-read-resource-access-AWC.feature> .

manifest:protected-operation-not-read-resource-default-AWC
  a td:TestCase ;
  spec:requirementReference wac:access-modes ;
  td:reviewStatus td:unreviewed ;
  spec:testScript
    <https://github.com/solid-contrib/specification-tests/blob/main/web-access-control/protected-operation/not-read-resource-default-AWC.feature> .

manifest:acl-object-none
  a td:TestCase ;
  spec:requirementReference wac:access-objects ;
  td:reviewStatus td:unreviewed ;
  spec:testScript
    <https://github.com/solid-contrib/specification-tests/blob/main/web-access-control/acl-object/container-none.feature> .
```

# Versioning
This repository will tag releases to make it possible to track report results to the specific versions of tests that were
run. Changes to the tests for each version will be described in the [CHANGELOG.md](CHANGELOG.md).

The release process is:
* Check that any relevant PRs have been merged and pulled locally.
* Update CHANGELOG.md to describe changes since the last release.
* Set up the release (updates version.txt and pushes a tag):
  ```shell
  ./release.sh 1.0.0
  ```
* Create the release in GitHub - [Create a new release](https://github.com/solid-contrib/specification-tests/releases/new):
  * Choose the tag that was just created.
  * Add a title, e.g. `Release 1.0.0`.
  * Add some content describing notable changes.
  * Publish the release.
