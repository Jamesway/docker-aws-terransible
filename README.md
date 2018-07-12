# TerraDome - a docker image with Terraform, Ansible and aws-cli
#### [https://hub.docker.com/u/jamesway/terradome](https://hub.docker.com/u/jamesway/terradome) contains:  
- Terraform 0.11.7  
- Ansible 2.6.1  
- aws-cli 1.15.55  
- love

## Requirements
- docker

## Usage

### tl;dr
```
cd [project_name]
wget --no-check-certificate https://raw.github.com/Jamesway/docker-terradome/master/td.sh
chmod +x td.sh

# make sure it works
./td.sh

# init
./td.sh init

cp .example-env .env
# add your creds, subnet_id and vpc_security_group_ids to .env

# terraform an ec2 instance in a vpc
./td.sh tf init
./td.sh tf apply
./td.sh tf destroy
```

### Initialize a new or existing project

```
cd [project_name]

wget --no-check-certificate https://raw.github.com/Jamesway/docker-terradome/master/td.sh

# it's always a good idea to look inside the script before you run it
# also a good idea to take a look a the docker file and entrypoint.sh too
chmod +x td.sh

# show the splash page
./td.sh

# or
./td.sh --help

# since we need some supporting files
# creates:
#   docker-compose.yml
#   example-env.
#   .gitignore
#   example.tf (if there aren't any other .tf files)
#   td.sh (in case you init'd with docker run ... instead of td.sh)

# init is non-destructive so you can run it in an existing project - maybe
./td.sh init

```

### Configure
If you're like me and you don't like entering entering ENVs on the commandline, set up an .env for docker-compose.

**Note: td.sh will try to keep ".env" in your .gitignore file, but you need to be sure it's there before committing**

```
# copy the .example-env to .env
# it's nice to leave the .example-env with the project so others can see the layout
cp .example-env .env

# open .env and fill these out:
#   AWS_ACCESS_KEY_ID
#   AWS_SECRET_ACCESS_KEY
#   TF_VAR_vpc_security_group_ids
#   TF_VAR_subnet_id

```


### Terraform
```
./td.sh terraform [args]

# init
./td.sh terraform init

# or
./td.sh tf init


# apply
./td.sh tf apply

# destroy
./td.sh tf destroy
```


### Ansible
```
./td.sh ansible [args]

# eg
./td.sh ansible --help

# or
./td.sh ans --help
```

### aws-cli
```
./td.sh aws [args]

# eg
./td.sh aws --help
```

## Issues
- Container time drift  
I spent a good amount of time tracking down an issue on OS X (maybe others) where the container's time would drift from the host.  This gave me some inconsistent aws connection failures. I solved this (I think) with this [hack](https://blog.shameerc.com/2017/03/quick-tip-fixing-time-drift-issue-on-docker-for-mac)

- Not really an issue, but Terraform environment variables are interesting
