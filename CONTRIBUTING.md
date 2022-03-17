# Contributing tests

The following is a proposal for a process by which tests can be contributed. The process will need testing and reviewing
so is likely to change.

* Add an issue for new tests using the label “Proposed Test Case” - this should reference the specification requirement
  to be tested and outline how you expect to test that requirement.
* When someone picks up an issue, add the label “In Progress”.
* Any discussion on how to implement the test should be captured in the issue.
* A new test will need the following:
  * An entry in the relevant manifest file (e.g. in protocol/ or web-access-control/). The initial status should be
    `td:reviewStatus td:unreviewed`.
  * If there are comments to make about the requirement, e.g. saying why a particular implementation doesn’t support it,
    these can be added to the matching requirement-comments.ttl with `rdfs:comment`.
  * Create the feature file - see notes in the [README](README.md) and refer to other tests as examples of common patterns.
* Submit a PR and request a review from another contributor (e.g. @edwardsph)
* The reviewer, at this stage, will focus on the test implementation more than how well it tests the requirement.
* The test is then merged and will be used by various Solid server implementors. This will provide feedback that will be part
  of a subsequent review by specification editors. If the test is approved by the editors, the manifest status will change
  to `td:approved`. Note the process for review by editors is not yet defined.

For advice on writing tests, you are welcome to contact @edwardsph via https://gitter.im/solid/test-suite
