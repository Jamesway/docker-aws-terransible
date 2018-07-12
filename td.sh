#!/bin/bash

# check for docker
if ! docker ps >/dev/null
then
  exit 1
fi

# no args or --help, splash page
if [ -z "$1" ] || [ "$1" == "--help" ]
then
  docker run --rm -t jamesway/terradome
  exit 0
fi


# we are initializing
if [ "$1" == "init" ]
then
  if ! docker run --rm -v $(pwd):/code jamesway/terradome init
  then
    echo "houston, we have a problem - init failed"
    exit 1
  fi
  exit 0
fi


# "expand" shortcuts
# terraform shortcut
if [ "$1" == "tf" ]
then
  set -- "terraform" "${@:2}"

# ansible shortcut
elif [ "$1" == "ans" ]
then
  set -- "ansible" "${@:2}"
fi

# this is what we came for
if [ "$1" == "terraform" ] || [ "$1" == "ansible" ] || [ "$1" == "aws" ]
then

  # check for missing .example.env or docker_compose.yml - we need to initialize
  if [ ! -f ".example-env" ] || [ ! -f "docker-compose.yml" ]
  then
    echo "missing required files, please initialize: ./td.sh init"
    exit 0
  fi

  # check for missing .env - we need to copy
  if [ ! -f ".env" ]
  then
    cat << "EOF"

##########################################################################
#   IMPORTANT                                                            #
#   copy .example-env to .env and change the values to suit your needs   #
##########################################################################

EOF
    exit 0
  fi

  # hack to deal with time drift in container
  # I tried to do a compose, but I couldn't get it to work - I think "privileged: true" wasn't recognized
  docker run --rm --privileged alpine hwclock -s && docker-compose run --rm "$@"
  exit 0
else
  echo "invalid command, try ./td.sh --help"
  exit 1
fi
