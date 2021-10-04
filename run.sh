#!/bin/bash

mkdir -p config reports

cat > ./config/application.yaml <<EOF
subjects: /data/test-subjects.ttl
sources:
  - https://github.com/solid/specification-tests/protocol/solid-protocol-test-manifest.ttl
  - https://github.com/solid/specification-tests/web-access-control/web-access-control-test-manifest.ttl
  - https://github.com/solid/specification-tests/protocol/solid-protocol-spec.ttl
  - https://github.com/solid/specification-tests/web-access-control/web-access-control-spec.ttl
  - https://github.com/solid/specification-tests/protocol/converted.ttl
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
  --output=/reports --target=https://github.com/solid/conformance-test-harness/ess "$@"
