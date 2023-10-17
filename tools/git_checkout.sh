#! /bin/sh

# Copyright (C) 2011-2013 OpenStack Foundation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied.
#
# See the License for the specific language governing permissions and
# limitations under the License.

# usage
# % git_checkout.sh https://github.com/apache/nuttx d62a01ebfad2e224baf3d6f3d6058bac0e31c8c3 nuttx

set -e

GIT_REPO=$1
GIT_REF=$2
DEST=$3

echo "Preparing ${DEST}:"
echo "  GIT repo: ${GIT_REPO}"
echo "  GIT ref: ${GIT_REF}"

mkdir -p "${DEST}"
ORIG_DIR="$(pwd -P)"
cd "${DEST}"
git init
git fetch --depth 1 ${GIT_REPO} ${GIT_REF}
git checkout FETCH_HEAD
git submodule update --init --recursive
git show --oneline | head -1
cd "${ORIG_DIR}"
