# Prerequisites

It is recommended to run this with
[Docker](https://docs.docker.com/get-docker/). If you access your
systems under test from a host that does not support Docker, you could
setup Ruby and install InSpec and run that way.

Using [direnv](https://direnv.net/) is optional though makes repeated
usage safer and easier.

# Setup environment variables

Install direnv with `brew install direnv` or skip all these steps and `export INSPEC_PASSWORD=yourpassword` and `export PGPASSWORD=database_password`

## Copy the example

```
cp .envrc.example .envrc
```

## Edit the example

```
vi .envrc
```

## enable direnv for this directory

```
direnv allow
```

# Describe systems under test

## Copy the example environment and inputs data.

```
cp example_env.yaml environments/dev.yaml
cp example_env_inputs.yaml environments/dev.yaml
```

## Edit the examples

Suggest naming by environment such that you may have `dev.yaml` and
`dev_inputs.yaml` for Dev, `staging.yaml` and `staging_inputs.yaml` for
Staging and so on.

You must either specify an sshkey or export your user's password in
`INSPEC_PASSWORD`. If you omit the username your `$USER` environment
variable will be used.

# Rakefile inputs

This would execute against the `backend` key from the `environments/dev.yaml` file.

```
docker run --network host -it --rm -v $(pwd):/share \
-e USER=$USER \
-e PGPASSWORD=$PGPASSWORD \
-e INSPEC_PASSWORD=$INSPEC_PASSWORD \
sensu/sensu-go-validation \
test[backend,environments/dev.yaml]
```

If you need to specify other data, such as different ports, you can specify an
inputs file to be loaded.

```
docker run --network host -it --rm -v $(pwd):/share \
-e USER=$USER \
-e PGPASSWORD=$PGPASSWORD \
-e INSPEC_PASSWORD=$INSPEC_PASSWORD \
sensu/sensu-go-validation \
test[backend,environments/dev.yaml,environments/dev_inputs.yaml]
```

All tests defined can be run in one execution.

```
docker run --network host -it --rm -v $(pwd):/share \
-e USER=$USER \
-e PGPASSWORD=$PGPASSWORD \
-e INSPEC_PASSWORD=$INSPEC_PASSWORD \
sensu/sensu-go-validation \
test:all[environments/dev.yaml]
```

Execute all tests with inputs.

```
docker run --network host -it --rm -v $(pwd):/share \
-e USER=$USER \
-e PGPASSWORD=$PGPASSWORD \
-e INSPEC_PASSWORD=$INSPEC_PASSWORD \
sensu/sensu-go-validation \
test:all[environments/dev.yaml,environments/dev_inputs.yaml]
```

# Example execution

The following examples authenticate using password set in `INSPEC_PASSWORD` environment variable.

```
docker run --network host -it --rm -v $(pwd):/share \
-e USER=$USER \
-e PGPASSWORD=$PGPASSWORD \
-e INSPEC_PASSWORD=$INSPEC_PASSWORD \
sensu/sensu-go-validation \
test[db,environments/dev.yaml,environments/dev_inputs.yaml]
```

The following is an example if using SSH key:

```
docker run --network host -it --rm -v $(pwd):/share \
-e USER=$USER \
-e PGPASSWORD=$PGPASSWORD \
-v $HOME/.ssh/id_rsa:/sshkey \
sensu/sensu-go-validation \
test[db,environments/dev.yaml,environments/dev_inputs.yaml]
```

More commands can be found with the following command:

```
docker run -it --rm -v $(pwd):/share sensu/sensu-go-validation
```

# Build container:

```
rake docker:build
```
