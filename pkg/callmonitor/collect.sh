#!/bin/sh
BNAME=$1
TAR=tar
$TAR c --exclude=.svn -C callmonitor . |  $TAR x -C "$BNAME"/root
$TAR c --exclude=.svn -C actions . |  $TAR x -C "$BNAME"/root
$TAR c --exclude=.svn -C freetz-base . |  $TAR x -C "$BNAME"/root
$TAR c --exclude=.svn -C freetz-actions . |  $TAR x -C "$BNAME"/root
$TAR c --exclude=.svn -C freetz . |  $TAR x -C "$BNAME"
