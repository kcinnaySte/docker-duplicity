# Supported tags and respective `Dockerfile` links
[![](https://images.microbadger.com/badges/image/kcinnayste/duplicity.svg)](https://microbadger.com/images/kcinnayste/duplicity "Get your own image badge on microbadger.com")

# What is Duplicity?

**[duplicity](http://duplicity.nongnu.org/)** backup tool.

Features of this Docker image:

  * **Small**: Built using [alpine](https://hub.docker.com/_/alpine/).
  * **Simple**: Most common cases are explained below and require minimal setup.
  * **Secure**: Runs non-root by default (use randomly chosen UID `1896`), and meant to run as any user.


## Usage

For the general command-line syntax, do:

    $ docker run --rm kcinnayste/duplicity --help

In general you...

  * Must mount what you want to backup or where you want to restore a backup.
  * Should mount `/home/duplicity/.cache/duplicity` as writable somewhere (if not cached, [duplicity will have to recreate it from the remote repository which may require decrypting the backup contents](http://duplicity.nongnu.org/duplicity.1.html#sect5)). Note it may be quite large and contains metadata info about files you've backed up in clear text.
  * Should mount `/home/duplicity/.gnupg` as writable somewhere (that directory is used to validate incremental backups and shouldn't be necessary to restore your backup if you follows steps below).
  * Should specify duplicity flag `--allow-source-mismatch` because Docker has a random host for each container.
  * Could set environment variable `PASSPHRASE`, unless you want to type it manually in the prompt (remember then to add `-it`).
  * May have to mount a few other files for authentication (see examples below).


Example of commands you may want to run **periodically to back up** with good clean-up/maintenance (see below for various storage options):

```sh
     $ docker run --rm ... kcinnayste/duplicity --full-if-older-than=6M source_directory target_url
     $ docker run --rm ... kcinnayste/duplicity remove-older-than 6M --force target_url
     $ docker run --rm ... kcinnayste/duplicity cleanup --force target_url
```

This would do:

 1. A full backup every 6 months so that restoration is a lot faster and for cleanup to work,
    and incremental backups the rest of the time.
 2. Delete backups older than 6 months (doesn't break incremental backups).
 3. Delete files from failed sessions (if any).


### Backup via **SSH** example

at the first, you have to generate the SSH-Keys and add the Target to the **known_hosts**.
```sh
$ docker run --rm -it \
          -v $PWD/sshParams/known_hosts:/home/duplicity/.ssh \
          kcinnayste/duplicity \
          --add-known-host example.com \
          --generate-ssh-key
```

Supposing you've an **SSH** access to some machine, you can:
```sh
    $ docker run --rm -it \
          -e PASSPHRASE=P4ssw0rd \
          -v $PWD/.cache:/home/duplicity/.cache/duplicity \
          -v $PWD/.gnupg:/home/duplicity/.gnupg \
          -v $PWD/sshParams/known_hosts:/home/duplicity/.ssh \
          -v /:/data:ro \
          kcinnayste/duplicity \
          --full-if-older-than=6M --allow-source-mismatch \
          --rsync-options='-e "ssh -i /id_rsa"' \
          /data scp://user@example.com//some_dir
```

## Alias

Here is a simple alias that should work in most cases:

    $ alias duplicity='docker run --rm --user=root -v ~/.ssh/id_rsa:/home/duplicity/.ssh/id_rsa:ro -v ~/.boto:/home/duplicity/.boto:ro -v ~/.gnupg:/home/duplicity/.gnupg -v /:/mnt:ro -e PASSPHRASE=$PASSPHRASE wernight/duplicity duplicity $@'

Now you should be able to run duplicity almost as if it were installed, example:

    $ PASSPHRASE=123456 duplicity --progress /mnt rsync://user@example.com/some_dir


## See also

  * [duplicity man](http://duplicity.nongnu.org/duplicity.1.html) page
  * [duplicity back-up how-to - Ubuntu](https://help.ubuntu.com/community/DuplicityBackupHowto)
  * [How To Use Duplicity with GPG to Securely Automate Backups on Ubuntu | DigitalOcean](https://www.digitalocean.com/community/tutorials/how-to-use-duplicity-with-gpg-to-securely-automate-backups-on-ubuntu)
