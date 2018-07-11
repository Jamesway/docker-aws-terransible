#!/bin/bash

if [ -z "${APP_PATH}" ]
then
  echo "APP_PATH not set - are we running in a docker container?"
  exit 1
fi

if [ -z "${SRC_PATH}" ]
then
  echo "SRC_PATH not set - are we running in a docker container?"
  exit 1
fi

# no params, show the usage
if [ -z "$1" ]
then
  cat << "EOF"

###########################################################
#                     WELCOME TO THE                      #
###########################################################
#  _______                  _____                         #
# |__   __|                |  __ \                        #
#    | | ___ _ __ _ __ __ _| |  | | ___  _ __ ___   ___   #
#    | |/ _ \ '__| '__/ _` | |  | |/ _ \| '_ ` _ \ / _ \  #
#    | |  __/ |  | | | (_| | |__| | (_) | | | | | |  __/  #
#    |_|\___|_|  |_|  \__,_|_____/ \___/|_| |_| |_|\___|  #
#                                                         #
###########################################################

EOF

  terraform --version
  ansible --version
  echo
  aws --version
  echo

  cat << "EOF"
###########################################################

requirements:
- docker

usage:

  NOTE1: "run --rm" removes the container when finished
  NOTE2: If you get some unexplained AWS AuthFailed errors, the time in the vm may have drifted too far.

         docker run --rm --privileged alpine hwclock -s

  GOOD (plain old docker)
  # pros - it's docker
  # cons - requires passing ENVs on the commandline :(
  cd [project_directory]
  docker run --rm -e AWS_ACCESS_KEY_ID=id -e AWS_SECRET_ACCESS_KEY=key -itv $(pwd):/code jamesway/terradome terraform [args]
  docker run --rm -e AWS_ACCESS_KEY_ID=id -e AWS_SECRET_ACCESS_KEY=key -itv $(pwd):/code jamesway/terradome ansible [args]
  docker run --rm -e AWS_ACCESS_KEY_ID=id -e AWS_SECRET_ACCESS_KEY=key -itv $(pwd):/code jamesway/terradome aws [args]


  BETTER (docker-compose)
  # pros - pulls ENVs from your .env file and less typing
  # cons - requires an initialization step

  # to initialize
  cd [project_directory]
  docker run --rm -v $(pwd):/code jamesway/terradome init

  docker-compose run --rm terraform [args]
  docker-compose run --rm ansible [args]
  docker-compose run --rm aws [args]


  BASH
  # pros everthing from docker-compose with less typing
  # cons not a lot

  cd [project_directory]
  # grab the terradome wrapper (td.sh)

  # make it executable
  chmod +x td.sh

  # initialize
  ./td.sh init


  ./td.sh or ./td.sh --help

  ./td.sh terraform [args]  # also ./tf.sh tf [args]
  ./td.sh ansible [args]    # and  ./tf.sh ans [args]
  ./td.sh aws [args]


###########################################################

EOF

  exit 0
fi

# init - we only want to change things if we're starting a project with an optional dir
if [ ! -z "$1" ] && [ "$1" == "init" ]
then
  echo
  echo "generating scaffolding..."

  # copy or append .gitignore
  if [ -f ".gitignore" ]
  then
    if ! cat .gitignore | grep .env
    then
      echo ".env" >> .gitignore
      echo "- appended .env to .gitignore"
    fi
  elif cp -n "${SRC_PATH}/.gitignore" "${APP_PATH}"
  then
    echo "- created .gitignore"
  fi

  # .example-env
  if cp -n "${SRC_PATH}/.example-env" "${APP_PATH}"
  then
    echo "- created .example.env"
  fi

  # docker_compose
  if cp -n "${SRC_PATH}/docker-compose.yml" "${APP_PATH}"
  then
    echo "- created docker-compose.yml"
  fi

  # sample terraform file
  if ! ls ${dest}/*.tf
  then
    if cp -n "${SRC_PATH}/example.tf" "${APP_PATH}"
    then
      echo "- created example.tf"
    fi

  # td.sh wrapper
  if cp -n "${SRC_PATH}/td.sh" "${APP_PATH}"
  then
    echo "- created td.sh, chmod +x td.sh to execute"
  fi

  cat << "EOF"

#############################################################################
#   IMPORTANT                                                               #
#   1) copy .example-env to .env and change the values to suit your needs   #
#   2) if you haven't already, don't forget to: chmod +x td.sh              #
#############################################################################

EOF

  exit 0

# execute the command(s)
else

  # I used ENVs because when querying the tool with --version, ansible was slow
  # run the container with not args to see how slow
  echo
  if [ "$1" == "terraform" ]
  then
    echo "Terraform ${TERRAFORM_VERSION}"
  elif [ "$1" == "ansible" ]
  then
    echo "ansible ${ANSIBLE_VERSION}"
  elif [ "$1" == "aws" ]
  then
    echo "aws-cli ${AWS_CLI_VERSION}"
  fi
  echo

  eval "$@"
fi
