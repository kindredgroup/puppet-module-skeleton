#!/bin/bash -e

#
# Copyright 2015 North Development AB
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Author: Ilja Bobkevic <ilja.bobkevic@unibet.com>
#

###
### FUNCTIONS LOGGING
###
msg() {
  local level="${1}"
  local msg="${2}"
  local output_code="${3:-1}"
  echo >&$output_code "${level} $(date '+%Y-%m-%d %H:%M:%S') - ${msg}"
}

info() {
  msg "INFO " "${1}"
}

warn() {
  msg "WARN " "${1}"
}

debug() {
  if [ "x" != "x${DEBUG}" ]; then
    msg "DEBUG" "${1}"
  fi
}

error() {
  msg "ERROR" "${1}" 2
}

###
### FUNCTIONS MISC
###
realpath() { echo $(cd $(dirname $1); pwd)/$(basename $1); }

verify_variable_set() {
  local variable="${1}"
  if [ -z "${!variable}" ]; then
    error "Environment variable ${variable} not set"
    exit 2
  fi
}

###
### VARIABLES
###
MODULE_AUTHOR=${MODULE_AUTHOR:-"unibet"}
GITHUB_ORG=$(echo ${GITHUB_ORG:-"unibet"} |tr '[:upper:]' '[:lower:]')
SOURCE_URL=https://github.com/${GITHUB_ORG}/puppet-${MODULE_NAME}.git
PROJECT_URL=https://github.com/${GITHUB_ORG}/puppet-${MODULE_NAME}
MODULE_SUMMARY=${MODULE_SUMMARY:-"Unibet ${MODULE_NAME} puppet module"}
MODULE_PATH=$(dirname ${BASH_SOURCE[0]})

###
### PREREQUISITES
###
for V in "MODULE_NAME FORGE_USER FORGE_PASSWORD"; do
  verify_variable_set $V
done

set +e
TRAVIS=$(which travis)
if [ ! -x "${TRAVIS}" ]; then
  error "Travis command is not available. Consider running 'gem install travis'"
  exit 3
fi
set -e

###
### MAIN
###
cd $MODULE_PATH

FILES=(.fixtures.yml metadata.json README.md manifests/init.pp manifests/params.pp spec/classes/init_spec.rb test/integration/default/puppet/manifests/site.pp tests/init.pp)

set +e
# gsed if available
SED=$(which gsed)
set -e
if [ ! -x "${SED}" ]; then
  SED=$(which sed)
fi

for V in "MODULE_NAME MODULE_AUTHOR SOURCE_URL PROJECT_URL ISSUES_URL MODULE_SUMMARY"; do
  for F in "${FILES[@]}"; do
    info "Setting ${V} to '${!V}' in ${F}..."
    $SED -i -e "s|__${V}__|${!V}|g" $F
  done
done

info "Adding encrypted credentials for travis"
$TRAVIS encrypt "${FORGE_USER}" --add deploy.user
$TRAVIS encrypt "${FORGE_PASSWORD}" --add deploy.password

cd -

info "Removing myself..."
rm -f ${BASH_SOURCE[0]}
