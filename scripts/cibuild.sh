#!/bin/sh

set -e

cmd_container () {
  # https://docs.github.com/en/actions/writing-workflows/choosing-what-your-workflow-does/store-information-in-variables#default-environment-variables
  tag_version="v1-$(date +%Y%m%d)-${GITHUB_RUN_NUMBER}"

  echo $QUAY_PASSWORD | docker login quay.io -u $QUAY_USERNAME --password-stdin
  sortable_tag="quay.io/chroot.club/raku-doc-website-current:${tag_version}"
  latest_tag="quay.io/chroot.club/raku-doc-website-current:latest"
  docker build --build-arg quay_expiration="8w" -f Website/Dockerfile -t $sortable_tag -t $latest_tag .
  docker push $sortable_tag
  docker push $latest_tag
}


if [ -z $1 ]; then
  cmd_container
fi

CMD=$1
shift
case $CMD in
  container)
    cmd_$CMD $@
    ;;
  *)
    echo "unknown command $CMD"
    exit 1
    ;;
esac
