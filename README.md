# Facebook Access Token Getter
Automatically get Facebook user access tokens using Selenium WebDriver... Basically a poor man's xAuth.

## Install
First, you'll need [Selenium WebDriver](http://docs.seleniumhq.org/) & [PhantomJS](http://phantomjs.org/). You can install both of these via Docker (see [selenium/hub](https://hub.docker.com/r/selenium/hub/) and [selenium-node-phantomjs](https://hub.docker.com/r/akeem/selenium-node-phantomjs/)), which is probably the easiest:

```bash
$ docker pull selenium/hub
$ docker pull akeem/selenium-node-phantomjs
$ docker run -d -P --name selenium-hub selenium/hub
$ docker run -d --link selenium-hub:hub akeem/selenium-node-phantomjs
```

These docker containers will need to be running on the same machine as this script, so Selenium can load HTML from the server we create on `http://localhost:8000`.

## Caveats
- Facebook will almost certainly revoke your app id if they find you using this on real user passwords. If you're trying to use this for ["design reasons"](http://stackoverflow.com/questions/3816842/facebook-login-programatically-using-oauth-xauth), just don't. This project is for getting around Facebook security in specific use-cases that Facebook's oAuth doesn't support.
- If Facebook changes certain parts of their login screen markup, this will break.
