#!/bin/bash

# This script builds the coverage report but has options to use the
# published test harness docker image or a local image, and the option to use
# the default tests included in the published image or local tests.
#
# The script creates directories in current working directory for:
#  - config
#  - reports

display_usage() {
  cat << EOF
Usage: ./coverage.sh [-d testdir] [-l] [-h]
  -d <testdir> Use local development version of tests in specified location
  -l           Use local docker image of test harness (called testharness)
  -h           Display usage
EOF
}

setup_config() {
  cat > ./config/application.yaml <<EOF
sources:
  - https://github.com/solid/specification-tests/protocol/solid-protocol-test-manifest.ttl
  - https://github.com/solid/specification-tests/web-access-control/web-access-control-test-manifest.ttl
  - https://solidproject.org/TR/protocol
  - https://github.com/solid/specification-tests/web-access-control/web-access-control-spec.ttl
  - https://github.com/solid/specification-tests/protocol/converted.ttl
mappings:
  - prefix: https://github.com/solid/specification-tests
    path: /data
EOF
}

dockerimage='solidconformancetestbeta/conformance-test-harness'
dockerargs=('-i' '--rm')
cwd=$(pwd)

# parse options
while getopts ":lhd:" arg; do
  case $arg in
    d)
      testDir="$(cd "${OPTARG}" && pwd)"
      setup_config
      outdir='local'
      dockerargs+=('-v' "$testDir/:/data" '-v' "$cwd/config:/app/config")
      ;;
    l)
      outdir='local'
      dockerimage='testharness'
      ;;
    h)
      display_usage
      exit 0
  esac
done

shift $((OPTIND-1))

dockerargs+=('-v' "$cwd/reports:/reports")
dockerargs+=('--env' 'USERS_ALICE_WEBID=x' '--env' 'USERS_BOB_WEBID=x')
dockerargs+=('--env' 'SOLID_IDENTITY_PROVIDER=x' '--env' 'TEST_CONTAINER=x' '--env' 'RESOURCE_SERVER_ROOT=x')
harnessargs=('--output=/reports' "--coverage")

# ensure report directory exists
mkdir -p reports

# optionally pull published CTH image
if [[ ! $dockerimage == 'testharness' ]]
then
  docker pull solidconformancetestbeta/conformance-test-harness
fi

#echo "RUNNING: docker run ${dockerargs[@]} $dockerimage ${harnessargs[@]} $@"
docker run ${dockerargs[@]} $dockerimage ${harnessargs[@]} $@
