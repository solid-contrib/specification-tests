#!/bin/bash

# This script runs tests on the given target server but has options to use the
# published test harness docker image or a local image, and the option to run
# with the default tests included in the published image or local tests.
# Environment variables are defined in the file `<subject>.env` in the directory
# from which you run this script.
#
# The script creates directories in current working directory for:
#  - config
#  - reports - with subdirectories for each test subject
#  - target - for additional reports created by Karate
#
# See below for assumptions made when running CSS

display_usage() {
  cat << EOF
Usage: ./run.sh [-d testdir] [-l] [-e <envfile>] <subject> [args]
  -d <testdir> Use local development version of tests in specified location
  -l           Use local docker image of test harness (called testharness)
  -e <envfile> Use this env file instead of <subject>.env
  <subject>    The short name of the test subject
  [args]       Other arguments passed to the test harness
EOF
}

setup_css() {
  mkdir -p config
  cat > ./config/css-config.json <<EOF
{
  "@context": "https://linkedsoftwaredependencies.org/bundles/npm/@solid/community-server/^5.0.0/components/context.jsonld",
  "import": [
    "css:config/app/main/default.json",
    "css:config/app/init/initialize-prefilled-root.json",
    "css:config/app/setup/optional.json",
    "css:config/app/variables/default.json",
    "css:config/http/handler/default.json",
    "css:config/http/middleware/websockets.json",
    "css:config/http/server-factory/https-websockets.json",
    "css:config/http/static/default.json",
    "css:config/identity/access/public.json",
    "css:config/identity/email/default.json",
    "css:config/identity/handler/default.json",
    "css:config/identity/ownership/token.json",
    "css:config/identity/pod/static.json",
    "css:config/identity/registration/enabled.json",
    "css:config/ldp/authentication/dpop-bearer.json",
    "css:config/ldp/authorization/webacl.json",
    "css:config/ldp/handler/default.json",
    "css:config/ldp/metadata-parser/default.json",
    "css:config/ldp/metadata-writer/default.json",
    "css:config/ldp/modes/default.json",
    "css:config/storage/backend/memory.json",
    "css:config/storage/key-value/resource-store.json",
    "css:config/storage/middleware/default.json",
    "css:config/util/auxiliary/acl.json",
    "css:config/util/identifiers/suffix.json",
    "css:config/util/index/default.json",
    "css:config/util/logging/winston.json",
    "css:config/util/representation-conversion/default.json",
    "css:config/util/resource-locker/memory.json",
    "css:config/util/variables/default.json"
  ],
  "@graph": [
    {
      "comment": [
        "Adds CLI options --httpsKey and --httpsCert and uses those to start an HTTPS server."
      ]
    },
  ]
}
EOF

  openssl req -new -x509 -days 365 -nodes \
    -out certs/server.cert \
    -keyout certs/server.key \
    -subj "/C=US/ST=California/L=Los Angeles/O=Security/OU=IT Department/CN=server"

  # Assumption: You have added 'server' as a mapping of localhost in /etc/hosts

  docker network create testnet
  docker run -d --name=server --network=testnet --env NODE_TLS_REJECT_UNAUTHORIZED=0 \
    -v "$(pwd)"/config:/config \
    -v "$(pwd)"/certs:/certs \
    -p 443:443 -it solidproject/community-server:5 \
    -c /config/css-config.json \
    --httpsKey=/certs/server.key --httpsCert=/certs/server.cert \
    --port=443 --baseUrl=https://server/

  until $(curl --output /dev/null --silent --head --fail -k https://server); do
    printf '.'
    sleep 1
  done
  echo 'CSS is running'
}

stop_css() {
  echo 'Stopping CSS'
  docker stop server
  docker rm server
  docker network rm testnet
}

setup_config() {
  mkdir -p config
  cp ./application.yaml ./config/application.yaml
}

# if no arguments supplied, display usage
if [ $# -lt 1 ]
then
	display_usage
	exit 1
fi

dockerimage='solidproject/conformance-test-harness'
dockerargs=('-i' '--rm')
cwd=$(pwd)

# parse options
# the 'target' directory is used by Karate for it's own format reports which can be helpful in development
while getopts "lhd:e:" arg; do
  case $arg in
    d)
      testDir="$(cd "${OPTARG}" && pwd)"
      setup_config
      outdir='local'
      dockerargs+=('-v' "$testDir/:/data" '-v' "$cwd/config:/app/config" '-v' "$cwd/target:/app/target")
      ;;
    l)
      outdir='local'
      dockerargs+=('-v' "$cwd/target:/app/target")
      dockerimage='testharness'
      ;;
    e)
      envfile="${OPTARG}"
      ;;
    *)
      ;;
  esac
done

shift $((OPTIND-1))

# check there is at least a subject argument
if [ $# -lt 1 ]
then
	display_usage
	exit 1
fi

# extract subject
subject=$1
outdir=$subject
if [ -z ${envfile} ]
then
  envfile="${subject}.env"
fi
shift

echo "Running tests on $subject and reporting to $cwd/reports/$subject"

dockerargs+=('-v' "$cwd/reports/$outdir:/reports" "--env-file=$envfile")
harnessargs=('--output=/reports')
if ! [[ "$*" == *"--target="* ]]; then
  harnessargs+=("--target=https://github.com/solid/conformance-test-harness/$subject")
fi

# ensure report directory exists
mkdir -p reports/$subject

# optionally start CSS
if [ $subject == "css" ]
then
	setup_css
  dockerargs+=('--network=testnet')
fi

# optionally pull published CTH image
if [[ ! $dockerimage == 'testharness' ]]
then
  docker pull solidproject/conformance-test-harness
fi

echo "RUNNING: docker run ${dockerargs[@]} $dockerimage ${harnessargs[@]} $@"
docker run ${dockerargs[@]} $dockerimage ${harnessargs[@]} $@
exit_code=$?
echo "Exit code: $exit_code"

# optionally stop CSS
if [ $subject == "css" ]
then
	stop_css
fi

exit "$exit_code"