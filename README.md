# shieldkins

Proxies to shields.io for displaying build result badges from Jenkins instances
that it knows about.

Pull requests accepted to add Jenkins instances. Add them
[here](https://github.com/CodeBlock/shieldkins/blob/master/Main.hs#L22).

# Usage

You can, of course, set it up yourself, but the production instance is hosted
on Heroku.

The DNS name is **shieldkins.elrod.me**.

Example of usage:

```html
<img src="http://shieldkins.elrod.me/fedora/fedora-mobile" alt="Fedora Mobile Status" />
```

where **fedora** above is the Jenkins shortname, and **fedora-mobile** is the
project name that the Jenkins instance builds.

# License

BSD-2.
