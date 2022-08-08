# Solid Specification Conformance Tests

## Release 0.0.12
* Use harness API to test sending requests without a content type header.
* Ensure container created correctly on slash semantic tests.

## Release 0.0.11
* Moved repository to `solid-contrib` organization.

## Release 0.0.10
* Add some initial comments for servers (in test-subjects.ttl) and requirements (in ./{spec}/requirement-comments.ttl).

## Release 0.0.9
* Remove unused converted tests.
* Add data driven tests for reading protected resources.

## Release 0.0.8
* Test CORS support.

## Release 0.0.7
* Change all github-related URIs to use accessible versions

## Release 0.0.6
* Replace the test preconditions in the manifest files with tags in the test files and specify which tests to skip in
 the test-subjects file.
* Amend instructions to point to the new docker image location.
* Test for URI assignment on POST with or without a Slug.
* Test for Allow header on GET & HEAD.
* Test for POST to non-existing resource.
* Test for deletion of containment triples on child deletion.
* Test for blocking delete of non-empty container.
* Improve test for unsupported request methods.

## Release 0.0.5
* Add information about the `send` methods of `SolidClient` for cases when you need to have more control over a request.
* Explain how comments should be used with test files.
* Test for a `describedBy` link.
* Test for unsupported request methods.

## Release 0.0.4
* Update tests to work with new RDF library in CTH v1.0.12 API.
* Clarify instructions on configuring request headers and make all tests consistent.
* Test for intermediate containers overwriting a resource in `containment.feature`.

## Release 0.0.3
* Update tests to work with CTH v1.0.11 API.

## Release 0.0.2
* Fix manifest for converted tests to ensure one manifest entry per test case.

## Release 0.0.1
Initial release of tests in the following areas:

### Solid Protocol
* Content-header for `PUT`, `POST`, `PATCH` requests.
* Slash semantics.
* Authentication header (approved).
* Content negotiation (approved).
* Creation of intermediate containers (approved).

### Web Access Control
* Access modes (some approved).
* Access objects (some approved).
* Evaluation context (approved).
* WAC-Allow header (approved).

### Converted tests
* These are a set of tests that apply to some of the above areas but have neither been linked into specification 
  requirements, nor reviewed. 