#!/bin/bash

if [ -z "$1" ]
then
  docker run --rm jamesway/terradome
fi

if [ "$1" = "terraform" ] || [ "$1" = "ansible" ] || [ "$1" = "aws" ]
then
  docker run --rm -itv $(pwd):/code jamesway/terradome "$@"
else
  docker run --rm jamesway/terradome
fi
