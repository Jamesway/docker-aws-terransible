#!/bin/bash

# copies a file or optionally appends to existing file
# function copy_append {
#
#   if [ -z "$1" ] || [ ! -f "$1" ]
#   then
#     echo "$0: invalid or missing source file $1, exiting"
#     exit 1;
#   fi
#
#   if [ -z "$2" ] || [ ! -d "$2" ]
#   then
#     echo "$0: invalid or missing destination directory $2, exiting"
#     exit 1;
#   fi
#
#   local file_name=$(basename "$1")
#
#   if [ -f "${2}/${file_name}" ] && [ ! -z "$3" ] && [ "$3" = "--append" ]
#   then
#     cat "$1" >> "${2}/${file_name}"
#     echo "${2}/${file_name} already exists, appended contents of ${1}"
#     return 0
#
#   elif [ -f "${2}/${file_name}" ]
#   then
#     echo "${2}/${file_name} already exists, skipping"
#     return 0
#   fi
#
#   cp "$1" "$2"
#   echo "    created ${file_name}"
# }

# jump to docker ENV APP_PATH
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

# no params
if [ -z "$1" ]
then
  echo "welcome to the"
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
  echo
  terraform --version
  echo
  ansible --version
  echo
  aws --version
  echo

  cat << "EOF"
###########################################################

usage:

  GOOD (plain old docker)
  docker run --rm -itv $(pwd):/code jamesway/terradome terraform [args]
  docker run --rm -itv $(pwd):/code jamesway/terradome ansible [args]
  docker run --rm -itv $(pwd):/code jamesway/terradome aws [args]

  BETTER (docker-compose)
  # run once per project
  docker run --rm -v $(pwd):/code jamesway/terradome init

  docker-compose run --rm terraform [args]
  docker-compose run --rm ansible [args]
  docker-compose run --rm aws [args]

  BASH
  # run once per project
  docker run --rm -v $(pwd):/code jamesway/terradome init && chmod +x td.sh

  ./td.sh terraform [args]
  ./td.sh ansible [args]
  ./td.sh aws [args]

###########################################################

EOF

  exit 0
fi

# we only want to change things if we're starting a project with a valid name
if [ ! -z "$1" ] && [ "$1" = "init" ]
then

  if [ ! -z "$2" ]
  then
    echo "init takes no arguments, exiting"
    exit 1
  fi

  echo "Generating project scaffolding..."
  echo

  if cp -n "${SRC_PATH}/.gitignore" "${APP_PATH}" || cat "${SRC_PATH}/.gitignore" >> "${APP_PATH}/.gitignore"
  then
    echo "created/appended .gitignore"
  fi

  # .example-env
  if cp -n "${SRC_PATH}/.example-env" "${APP_PATH}"
  then
    echo "created .example.env ***IMPORTANT*** copy .example-env to .env and change the values to suit your needs"
  fi

  # docker_compose
  if cp -n "${SRC_PATH}/docker-compose.yml" "${APP_PATH}"
  then
    echo "created docker-compose.yml"
  fi

  exit 0

else
  # I used ENVs because when querying the tool with --version, ansible was slow
  # run the container with not args to see how slow
  echo "TerraTool - Terraform ${TERRAFORM_VERSION}, Ansible ${ANSIBLE_VERSION}, aws-cli ${AWS_CLI_VERSION}"
  eval "$@"
fi
