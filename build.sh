#!/bin/bash

set -e

declare -r -x SWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
declare -r -x SOURCES="${SWD##*/}"
declare -r -x PROJECT=Veritas
declare BUILDDIR=${WORKSPACE}

if [[ -z "${GIT_BRANCH}" ]]; then
  if [[ -d "${SWD}/.git" ]]; then
    GIT_BRANCH=$(cd "${SWD}"; git rev-parse --abbrev-ref HEAD)
  else
    GIT_BRANCH=unknown
  fi
fi
if [[ -z "${GIT_COMMIT}" ]]; then
  if [[ -d "${SWD}/.git" ]]; then
    GIT_COMMIT=$(cd "${SWD}"; git rev-parse HEAD)
  else
    GIT_COMMIT=0000000000000000000000000000000000000000
  fi
fi
if [[ -z "${GIT_REVNUM}" ]]; then
  if [[ -d "${SWD}/.git" ]]; then
    GIT_REVNUM=$(cd "${SWD}"; git rev-list HEAD|wc -l)
  else
    GIT_REVNUM=0
  fi
fi
if [[ -z "${GIT_BNAME}" ]]; then
  GIT_BNAME=${GIT_BRANCH#*/}
fi

function warn () 
{
    echo "${BASH_SOURCE[1]}:${BASH_LINENO[0]} (${FUNCNAME[1]}): $@" >&2
}

function die () 
{
  local rc=$1
  local message=$2
  [ -z "$message" ] && message="Died"
  echo "${BASH_SOURCE[1]}:${BASH_LINENO[0]} (${FUNCNAME[1]}): $message" >&2
  exit $rc
}

function pushd () 
{
    command pushd "$@" > /dev/null
}

function popd () 
{
    command popd "$@" > /dev/null
}

function is_vagrant ()
{
   test -d /vagrant
}

if [[ -z "${VERSION_TAG}" ]]; then
  if is_vagrant; then
    VERSION_TAG="0.0.0.0"
  else
    VERSION_TAG=$(date -u +%y%j.${GIT_REVNUM}.${BUILD_NUMBER:-0})
  fi
fi
if [[ -z "${VERSION_STRING}" ]]; then
  VERSION_STRING=$(echo "${VERSION_TAG}-${GIT_COMMIT:0:9} (${GIT_BRANCH})")
fi

function setup_vagrant_workspace ()
{
  echo "Setting up building workspace.."

  BUILDDIR="${SWD}/.builddir"

  pushd "${SWD}"

  [ -d "${BUILDDIR}" ] && rm -rf "${BUILDDIR}"
  mkdir -p "${BUILDDIR}/Sources"
  echo "Creating sources replica.."
  ## XXX: Using 'git archive' here wont export non-commited changes.
  #git archive --format tar HEAD| tar -xf - -C "${BUILDDIR}/Sources"
  git ls-files | tar -cf - -T - | tar -xf - -C "${BUILDDIR}/Sources"

  popd
}

function build ()
{
  echo "Building version: ${VERSION_STRING}.."

  if is_vagrant; then
    setup_vagrant_workspace
  fi

  [ -z "${BUILDDIR}" ] && die 127 "Missing BUILDDIR variable."

  pushd "${BUILDDIR}"

  ## Clean up data (possibly) left by previous builds.
  for i in $(ls |grep -v Sources|grep -v NuGets);do rm -rf "$i";done
 
  RESULT=0

  echo "Setting version.."
  #sed -i -e "s|0\.0\.0\.0|${VERSION_TAG}|g" Sources/*/Properties/AssemblyInfo.cs
  #sed -i -e "s|GIT_COMMIT|${VERSION_STRING}|g" Sources/*/Properties/AssemblyInfo.cs

  cat > setenv.sh <<_EOF
export JBOSS_HOME="/var/lib/jbossas" 
export APPSRV_HOME=$JBOSS_HOME
export ANT_HOME=/usr/share/ant
export ANT_OPTS="-Xmx512m -XX:MaxPermSize=128m" 
export SIGNSERVER_HOME=/opt/signserver
export SIGNSERVER_NODEID=ssdemo.ter0.com
_EOF

  bin/ant clean
  bin/ant build
  bin/ant deploy
 
  RESULT=$?
  
  echo "Copying output artifacts.."
  #mv RPMS/noarch/* Outputs/ || :
 
  popd 
  exit $RESULT
}

case "$1" in
  show-version)
    echo VERSION_STRING=${VERSION_STRING}
    echo VERSION_TAG=${VERSION_TAG}
    ;;
  build|"")
    build
    ;;
  *)
    die 1 "Unknown command: $1"    
esac

