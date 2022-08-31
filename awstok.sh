#!/bin/bash

# Copyright 2020 Jesse Dutton
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.


# The easiest way to use this is to add a funtion to your .bashrc as follows:
#
#   export AWS_MFA_ARN='arn:aws:iam::###:mfa/NAME'  # see first echo, below
#   awstok() { eval "$(awstok.sh)"; }
#

if [[ -z "$AWS_MFA_ARN" ]]; then
  echo -e "First, set the environment variable AWS_MFA_ARN. After MFA is setup,\nthis value is shown on your user page in the AWS console. For hardware\ndevices, use the device serial number." >&2
  exit 1
fi
if [[ -z "$(which aws)" ]]; then
  echo "Dependency 'aws' is not in the path" >&2
  exit 1
fi
if [[ -z "$(which jq)" ]]; then
  echo "Dependency 'jq' is not in the path" >&2
  exit 1
fi

# read -p writes to stderr
read -p "Enter the value from Authenticator: " token
if [[ -z "$token" ]]; then
  echo "Aborted" >&2
  exit 1
fi

unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN
result="$(aws sts get-session-token --serial-number "$AWS_MFA_ARN" --token-code "$token")"
if [ $? -ne 0 ]; then
  echo "${result}" >&2
  exit 1
fi

cat<<EOF
export AWS_ACCESS_KEY_ID="$(echo "$result" | jq -r .Credentials.AccessKeyId)"
export AWS_SECRET_ACCESS_KEY="$(echo "$result" | jq -r .Credentials.SecretAccessKey)"
export AWS_SESSION_TOKEN="$(echo "$result" | jq -r .Credentials.SessionToken)"
EOF
