## LoremIpsum
-----

A generator of lorem ipsum like text.

The default word list included came from http://lipsum.com/

### Features

  * Specify the number of paragraphs.
  * Specify the punctuation used for ending lines.
  * Specify the punctuation used mid lines.

### Config

The default configuration file is included ( `loremipsum.DEFAULT.conf` ) or can
be built by running:

  * `make config`

The configuration files that will be read (in order) are:

  * `/etc/loremipsum.conf`
  * `<YOUR_HOME_DIRECTORY>/.loremipsum.conf`

### Makefile options

Other `make` options are:

  * `config`    - Generate default config file
  * `all`       - Build all support files (Changelog, default config etc)
  * `Changelog` - Build Changelog file
  * `dist`      - Build all files and create a release tarball

### Signature

*LoremIpsum* script and archive should be signed with my GPG key (
[231A 94F4 81EC F212](http://pgp.mit.edu/pks/lookup?op=get&search=0x231A94F481ECF212)
).

Binary signature files end in .asc and can be verified using
[gpg/gpg2](https://www.gnupg.org/)
thus:

```console
$ gpg --verify loremipsum-0.07.tar.gz.asc

    gpg: assuming signed data in 'loremipsum-0.07.tar.gz'
    gpg: Signature made 2021-10-07T14:52:45 AEDT
    gpg:                using RSA key CDEC1051087406FB832346DC231A94F481ECF212
    gpg: Good signature from "Krayon (Code Signing Key) <krayon.git@qdnx.org>" [ultimate]
    gpg:                 aka "[jpeg image of size 4730]" [ultimate]
```

You may first need to retrieve my public key if you haven't already done so:

```console
$ gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 231A94F481ECF212
    gpg: keyring `/home/krayon/.gnupg/secring.gpg' created
    gpg: requesting key 231A94F481ECF212 from hkp server keyserver.ubuntu.com
    gpg: /home/krayon/.gnupg/trustdb.gpg: trustdb created
    gpg: key 231A94F481ECF212: public key "Krayon (Code Signing Key) <krayon.git@qdnx.org>" imported
    gpg: no ultimately trusted keys found
    gpg: Total number processed: 1
    gpg:               imported: 1  (RSA: 1)
```

The keyserver can be any of your choosing. If you do not specify one, `gpg` will
use `keys.gnupg.net` .

[//]: # ( vim: set ts=4 sw=4 et cindent tw=80 ai si syn=markdown ft=markdown: )
