#!/bin/bash

function clone() {
    git clone git@github.com:jobworkfor/note.git
}

function push() {
    git add -A
    git commit -m "no commit"
    git push origin master
}

for arg in "$@"
do
    case $arg in
    clone)
        clone
        ;;
    push)
        push
        ;;
    *)
        echo "unkonw argument"
        exit 1
        ;;
    esac
done