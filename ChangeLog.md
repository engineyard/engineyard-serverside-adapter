# ChangeLog

## NEXT

  *

## v2.5.0 (2022-04-04) 

  * Removes `--no-ri` and `--no-rdoc` as they are no longer supported in later versions of ruby.

## v2.4.0 (2014-09-22)

  * Add MaintenanceStatus action that reports maintenance page up/down.

## v2.3.1 (2014-06-10)

  * Fixes a bug where maintenance actions incorrectly did not accept --config options.

## v2.3.0 (2014-06-02)

  * Support new --ignore-existing option for integrate, which tells rsync not to overwrite existing files on the destination server when syncing existing app files before deploy.

## v2.2.2 (2013-10-10)

  * Remove --clean option form Integrate command. We've decided that integrate should just always run clean.

## v2.2.1 (2013-10-03)

  * Add --clean option to Integrate command.

## v2.2.0 (2013-09-30)

  * Require `serverside\_version` for all commands.
  * Add --clean option to Deploy command.
