# awstok
This is a simple shell script that does one thing well. That one thing is ask
for the MFA code from your authenticator app, and pass it to AWS. Maybe that's
two things.

## Use eval
Because of how shell variables work, the commands that set environment
variables needs to be executed from within the shell where the variables will
live (i.e. not a subshell). The easiest way to do this is to put `awstok.sh`
in your path, and add this to your `.bashrc` file:
```
export AWS_MFA_ARN='arn:aws:iam::###:mfa/NAME'
awstok() { eval "$(awstok.sh)"; }
```
The value for the `AWS_MFA_ARN` var for your user can be found on your user's
AWS IAM page once you have setup MFA.

# Dependencies
Obviously, you will need the command line tool `aws` installed. We also depend
on `jq`, which should exist as a package on most systems, so
`apt-get install jq` or `brew install jq` as appropriate.

