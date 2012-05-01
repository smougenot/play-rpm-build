#!/bin/sh
PLAY_VERSION=1.2.4

if [ $# -gt 0 ]; then
  PLAY_VERSION=$1
  shift
fi

PLAY_URL=http://download.playframework.org/releases/play-${PLAY_VERSION}.zip
PLAY_LOCAL=SOURCES/play-${PLAY_VERSION}.zip

if [ ! -f ${PLAY_LOCAL} ]; then
  echo "downloading ${PLAY_LOCAL} from $PLAY_URL"
  curl -s -L $PLAY_URL -o ${PLAY_LOCAL}
else
  echo "source exists in ${PLAY_LOCAL}"
fi

if [ ! -f ${PLAY_LOCAL} ]; then
  echo "Fail downloading play"
  exit 2
fi

# Préparation des répertoires
rm -rf BUILD RPMS SRPMS TEMP
mkdir -p BUILD RPMS SRPMS TEMP

echo "Building RPM for play"
rpmbuild -bb --define="_topdir $PWD" --define="_tmppath $PWD/TEMP"\
 --define="PLAY_VERSION $PLAY_VERSION"\
 play.spec