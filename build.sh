#!/bin/bash

set -e

declare -r -x SWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
declare -r -x SRCDIR="${SWD}/src"
declare -r -x SOURCES="${SWD##*/}"
declare -r -x PROJECT=SignServer
declare BUILDDIR=${WORKSPACE}

SWD_REVNUM=$(cd "${SWD}"; git rev-list HEAD|wc -l)

if [[ -z "${GIT_BRANCH}" ]]; then
  if [[ -e "${SRCDIR}/.git" ]]; then
    GIT_BRANCH=$(cd "${SRCDIR}"; git rev-parse --abbrev-ref HEAD)
  else
    GIT_BRANCH=unknown
  fi
fi
if [[ -z "${GIT_COMMIT}" ]]; then
  if [[ -e "${SRCDIR}/.git" ]]; then
    GIT_COMMIT=$(cd "${SRCDIR}"; git rev-parse HEAD)
  else
    GIT_COMMIT=0000000000000000000000000000000000000000
  fi
fi
if [[ -z "${GIT_REVNUM}" ]]; then
  if [[ -e "${SRCDIR}/.git" ]]; then
    GIT_REVNUM=$(cd "${SRCDIR}"; git rev-list HEAD|wc -l)
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
  VERSION_TAG=$(cat ${SWD}/src/signserver/res/compile.properties |grep ^app.version.number|cut -d= -f 2).${BUILD_NUMBER:-${GIT_REVNUM}}
fi
if [[ -z "${VERSION_STRING}" ]]; then
  VERSION_STRING=$(echo "${VERSION_TAG}-${GIT_COMMIT:0:9} (${GIT_BRANCH})")
fi

function setup_vagrant_workspace ()
{
  echo "Setting up building workspace.."

  BUILDDIR="${SWD}/.builddir"

  pushd "${SWD}/src"

  [ -d "${BUILDDIR}" ] && rm -rf "${BUILDDIR}"
  mkdir -p "${BUILDDIR}"
  echo "Creating sources replica.."
  git ls-files | tar -cf - -T - | tar -xf - -C "${BUILDDIR}"

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

  ## Setup some needed folders..
  [ ! -d RPMS ]&& mkdir -p RPMS/noarch

  SPECFILE=${SWD}/packaging/${PROJECT}.spec

  RESULT=0

  #sed -i -e "s|GIT_COMMIT|${VERSION_STRING}|g" Sources/*/Properties/AssemblyInfo.cs

  rpmbuild -bb \
          --define "version $(echo ${VERSION_TAG}|rev|cut -d. -f 2-|rev)" \
          --define "release $(echo ${VERSION_TAG}|rev|cut -d. -f -1|rev).${SWD_REVNUM}" \
          --define "_topdir ${BUILDDIR}" \
          --define "_builddir ${BUILDDIR}/signserver" \
	  --define "full_version_string ${VERSION_STRING}" \
          --define 'setup echo "do nothing."' \
          "$SPECFILE"

  RESULT=$?
  
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

