#!/bin/bash

# taken from https://www.viget.com/articles/create-a-github-repo-from-the-command-line
version=$1
release_note="Version $version"

repo_name=heroku-buildpack-node-preservation
username=`git config github.user`
if [ "$username" = "" ]; then
    echo "Could not find username, run 'git config --global github.user <username>'"
    invalid_credentials=1
fi

token=`git config github.token`
if [ "$token" = "" ]; then
    echo "Could not find token, run 'git config --global github.token <token>'"
    invalid_credentials=1
fi

if [ "$invalid_credentials" == "1" ]; then
    exit 1
fi

if [ "$release_note" = "" ]; then
  release_note="Version 1.0.10"
  echo "[INFO] No command line input provided. Set \$release_note to $release_note"
fi

git init .
git add .
git commit -m "$release_note"
# Sets the new remote
git_remote=`git remote`
if [ "$git_remote" = "" ]; then # git remote not defined

  printf "Creating Github repository '$repo_name' ...\n"
  curl -u "$username:$token" https://api.github.com/orgs/getasnap/repos -d '{"name":"'$repo_name'", "private":true}' > /dev/null 2>&1
  printf "Adding remote"
  git remote add origin git@github.com:getasnap/$repo_name > /dev/null 2>&1
  printf "Setting upstream"
  git push --set-upstream origin master
  echo " done."
else
  git pull origin
  git push origin
fi

git tag -a "$version" -m "Releasing Version $version"
git push origin "$version"

echo "Done!"
