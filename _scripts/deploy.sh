#!/bin/bash
set -e

SOURCE_COMMIT_MESSAGE=$(git log -1 --pretty=%B)

BUILD_DIR=${1:-${BUILD_DIR:-$(readlink -f "./_site")}}
DEPLOY_DIR=$(mktemp -d)

SOURCE_REPO_URL=${SOURCE_REPO_URL:-${CIRCLE_REPOSITORY_URL:-$(git config --get remote.origin.url)}}
SOURCE_REPO_BRANCH=${SOURCE_REPO_BRANCH:-${CIRCLE_BRANCH:-$(git rev-parse --abbrev-ref HEAD)}}
TARGET_REPO_URL=${TARGET_REPO_URL:-${CIRCLE_REPOSITORY_URL:-$SOURCE_REPO_URL}}
TARGET_REPO_BRANCH=${TARGET_REPO_BRANCH:-"master"}

CNAME=$(cat "CNAME")
DOMAIN_NAME=${DOMAIN_NAME:-${CNAME:-$CIRCLE_PROJECT_REPO_NAME}}
SITEMAP_URL=${SITEMAP_URL:-"https://$DOMAIN_NAME/sitemap.xml"}

GIT_USER_NAME=${GIT_USER_NAME:-"CI"}
GIT_USER_EMAIL=${GIT_USER_EMAIL:-"ci@$DOMAIN_NAME"}

COMMIT_MESSAGE=$(cat <<EOH
$SOURCE_COMMIT_MESSAGE

$CIRCLE_BUILD_URL
EOH
)

echo "BUILD_DIR          = $BUILD_DIR"
echo "DEPLOY_DIR         = $DEPLOY_DIR"

echo "SOURCE_REPO_URL    = $SOURCE_REPO_URL"
echo "SOURCE_REPO_BRANCH = $SOURCE_REPO_BRANCH"
echo "TARGET_REPO_URL    = $TARGET_REPO_URL"
echo "TARGET_REPO_BRANCH = $TARGET_REPO_BRANCH"

echo "CNAME              = $CNAME"
echo "DOMAIN_NAME        = $DOMAIN_NAME"
echo "SITEMAP_URL        = $SITEMAP_URL"

echo "GIT_USER_NAME      = $GIT_USER_NAME"
echo "GIT_USER_EMAIL     = $GIT_USER_EMAIL"
echo "COMMIT_MESSAGE     = $COMMIT_MESSAGE"

if [[ "$TARGET_REPO_BRANCH" == "$SOURCE_REPO_BRANCH" && "$TARGET_REPO_URL" == "$SOURCE_REPO_URL" ]]; then
  echo "Source repo and branch are the same as target repo and branch, refusing to deploy"
  exit 1
fi

if [[ "$SITEMAP_URL" == "https:///sitemap.xml" ]]; then
  echo "Required variables not set" 
  exit 2
fi

#clone target repo to a temp dir to ensure no name collisions
git clone $TARGET_REPO_URL $DEPLOY_DIR
cd $DEPLOY_DIR

#verify clean repo
git fetch origin
git checkout $TARGET_REPO_BRANCH

#configure git committer
git config --global user.name $GIT_USER_NAME
git config --global user.email $GIT_USER_EMAIL

#copy compiled site from artifacts
rsync -a --delete --exclude=.git $BUILD_DIR/ .

# commit changes
git add -A
git commit -m "$COMMIT_MESSAGE"
git push origin master

#ping search engines with new sitemap
curl "http://www.google.com/webmasters/sitemaps/ping?sitemap=$SITEMAP_URL"
