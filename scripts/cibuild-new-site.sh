#!/bin/sh

set -e

# Exit if not running in GitHub Actions
if [ -z "$GITHUB_ACTIONS" ]; then
  echo "Not running in GitHub Actions, exiting"
  exit 0
fi

cmd_container () {
  tag_version="v1-$(date +%Y%m%d)-${GITHUB_RUN_NUMBER}"

  # Only login to quay.io if we're going to push (on main branch)
  if [ "$GITHUB_REF_NAME" = "main" ]; then
    echo $QUAY_PASSWORD | docker login quay.io -u $QUAY_USERNAME --password-stdin
  fi

  full_tag="quay.io/chroot.club/raku-doc-website:${tag_version}"
  docker build --build-arg quay_expiration="8w" -t $full_tag -f New_Website/Dockerfile New_Website/

  # Also tag as "latest"
  latest_tag="quay.io/chroot.club/raku-doc-website:latest"
  docker tag $full_tag $latest_tag

  # Only push if on main branch
  if [ "$GITHUB_REF_NAME" = "main" ]; then
    echo "Pushing container images (branch: $GITHUB_REF_NAME)"
    docker push $full_tag
    docker push $latest_tag
  else
    echo "Skipping push (branch: $GITHUB_REF_NAME, only pushing from main)"
  fi
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

