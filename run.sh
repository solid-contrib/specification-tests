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
  "@context": "https://linkedsoftwaredependencies.org/bundles/npm/@solid/community-server/^3.0.0/components/context.jsonld",
  "import": [
    "files-scs:config/app/main/default.json",
    "files-scs:config/app/init/initialize-prefilled-root.json",
    "files-scs:config/app/setup/optional.json",
    "files-scs:config/app/variables/default.json",
    "files-scs:config/http/handler/default.json",
    "files-scs:config/http/middleware/websockets.json",
    "files-scs:config/http/server-factory/websockets.json",
    "files-scs:config/http/static/default.json",
    "files-scs:config/identity/access/public.json",
    "files-scs:config/identity/email/default.json",
    "files-scs:config/identity/handler/default.json",
    "files-scs:config/identity/ownership/token.json",
    "files-scs:config/identity/pod/static.json",
    "files-scs:config/identity/registration/enabled.json",
    "files-scs:config/ldp/authentication/dpop-bearer.json",
    "files-scs:config/ldp/authorization/webacl.json",
    "files-scs:config/ldp/handler/default.json",
    "files-scs:config/ldp/metadata-parser/default.json",
    "files-scs:config/ldp/metadata-writer/default.json",
    "files-scs:config/ldp/modes/default.json",
    "files-scs:config/storage/backend/memory.json",
    "files-scs:config/storage/key-value/resource-store.json",
    "files-scs:config/storage/middleware/default.json",
    "files-scs:config/util/auxiliary/acl.json",
    "files-scs:config/util/identifiers/suffix.json",
    "files-scs:config/util/index/default.json",
    "files-scs:config/util/logging/winston.json",
    "files-scs:config/util/representation-conversion/default.json",
    "files-scs:config/util/resource-locker/memory.json",
    "files-scs:config/util/variables/default.json"
  ],
  "@graph": [
    {
      "comment": [
        "An example of what a config could look like if HTTPS is required.",
        "The http/server-factory import above has been omitted since that feature is set below."
      ]
    },
    {
      "comment": "The key/cert values should be replaces with paths to the correct files. The 'options' block can be removed if not needed.",
      "@id": "urn:solid-server:default:ServerFactory",
      "@type": "WebSocketServerFactory",
      "baseServerFactory": {
        "@id": "urn:solid-server:default:HttpServerFactory",
        "@type": "BaseHttpServerFactory",
        "handler": { "@id": "urn:solid-server:default:HttpHandler" },
        "options_showStackTrace": { "@id": "urn:solid-server:default:variable:showStackTrace" },
        "options_https": true,
        "options_key": "/config/server.key",
        "options_cert": "/config/server.cert"
      },
      "webSocketHandler": {
        "@type": "UnsecureWebSocketsProtocol",
        "source": { "@id": "urn:solid-server:default:ResourceStore" }
      }
    }
  ]
}
EOF

  openssl req -new -x509 -days 365 -nodes \
    -out config/server.cert \
    -keyout config/server.key \
    -subj "/C=US/ST=California/L=Los Angeles/O=Security/OU=IT Department/CN=server"

  # Assumption: You have added 'server' as a mapping of localhost in /etc/hosts

  docker network create testnet
  docker run -d --name=server --network=testnet --env NODE_TLS_REJECT_UNAUTHORIZED=0 \
    -v "$(pwd)"/config:/config -p 443:443 -it solidproject/community-server:3 \
    -c /config/css-config.json --port=443 --baseUrl=https://server/

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
harnessargs=('--output=/reports' "--target=https://github.com/solid/conformance-test-harness/$subject")

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