#!/bin/sh
BNAME=$1
TAR=tar
$TAR c --exclude=.svn -C actions . |  $TAR x -C "$BNAME"/root
$TAR c --exclude=.svn -C freetz-base . |  $TAR x -C "$BNAME"/root
$TAR c --exclude=.svn -C freetz-actions . |  $TAR x -C "$BNAME"/root
$TAR c --exclude=.svn -C actions-config . |  $TAR x -C "$BNAME"/root
cp freetz/.language "$BNAME"
