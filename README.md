# nimpkgs

The [nimble.directory](https://nimble.directory) alternative no one asked for, that I felt like making anyways.
Check it out at [nimpkgs.dayl.in](https://nimpkgs.dayl.in).

<hr>

## why though...

In it's [current form](nim-lang/packages) packages for `nim` are managed by a single JSON file.
A web UI is available at [nimble.directory](https://nimble.directory)([repo](https://github.com/FedericoCeratto/nim-package-directory)).
But, there are some outstanding [issues](https://github.com/FedericoCeratto/nim-package-directory/issues/53) that have affected even my own packages.

This site is client-only, powered by [karax](https://github.com/karaxnim/karax) and styled with [unocss](https://github.com/unocss/unocss).
It provide a single page search UI over `nim-lang/packages`.
This makes it trivial to deploy with Github Actions.

## usage

On page load 10 random packages and a set of tags will be selected. 
Search can be modified by specifying fields.

examples:
- `tag:database sqlite`
- `license:MIT web`


## license

Logos in [site/img](./site/img/) by [The Nim Programming language](https://nim-lang.org) used under [CC BY 3.0](https://github.com/nim-lang/website/blob/master/LICENSE.md).

