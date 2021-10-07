## LoremIpsum
-----

A generator of lorem ipsum like text.

The default word list included came from http://lipsum.com/

Features include:
    * Specify the number of paragraphs.
    * Specify the punctuation used for ending lines.
    * Specify the punctuation used mid lines.

The default configuration file is included ( `loremipsum.DEFAULT.conf` ) or can
be built by running:
    * `make config`

The configuration files that will be read (in order) are:

    * `/etc/loremipsum.conf`
    * `<YOUR_HOME_DIRECTORY>/.loremipsumrc`

Other `make` options are:
    * `config`    - Generate default config file
    * `all`       - Build all support files (Changelog, default config etc)
    * `Changelog` - Build Changelog file
    * `dist`      - Build all files and create a release tarball

[//]: # ( vim: set ts=4 sw=4 et cindent tw=80 ai si syn=markdown ft=markdown: )
