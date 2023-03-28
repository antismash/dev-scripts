# Scripts to help with antiSMASH development

These scripts can help with setting up and running antiSMASH development.

## `db_setup`

The `bootstrap.sh` script can boostrap your development environment. It will need `git`, `podman`,
and of course `python3` installed. You can either use a preexisting python virtual environment to
install the dependencies, or the boostrap script will create one for you.

Some settings can be influenced by environment variables, check the script for details.

## `git_hooks`

Contains useful git pre-commit and pre-push hooks you can place into your `.git/hooks` directory.

## LICENCE

These scripts are under an Apache 2 licence, see [`LICENSE`](LICENSE) file for details.
antiSMASH components themselves are available under their respective licences.
