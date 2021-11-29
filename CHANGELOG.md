# Solid Specification Conformance Tests

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