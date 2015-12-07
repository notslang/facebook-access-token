BPromise = require 'bluebird'
express = require 'express'
url = require 'url'
webdriverio = require 'webdriverio'

SITE_URL = 'http://localhost:8000/'

getTokenPage = (appId, version) ->
  fbOptions = JSON.stringify {appId, cookie: true, xfbml: true, version}
  """
  <!DOCTYPE html>
  <html>
    <body>
      <style> * {margin: 0; padding: 0;}</style>
      <script>
        function checkLoginState() {
          FB.getLoginStatus(function(response) {
            var output = document.createElement('div');
            output.id = 'facebook-response';
            output.innerHTML = JSON.stringify(response);
            document.getElementsByTagName('body')[0].appendChild(output);
          });
        }
        window.fbAsyncInit = function() {
          FB.init(#{fbOptions});
        };
      </script>
      <fb:login-button scope="public_profile,email" onlogin="checkLoginState();"
                       id="login-button">
      </fb:login-button>
      <script id="facebook-jssdk"
              src="https://connect.facebook.net/en_US/sdk.js">
      </script>
    </body>
  </html>
  """

module.exports = ({appId, apiVersion, email, password, webdriverServer}) ->
  apiVersion ?= '2.5'
  {protocol, hostname, port} = webdriverServer
  accessToken = null

  app = express()
  app.get('/', (req, res) ->
    res.set('Content-Type', 'text/html')
    res.send(getTokenPage(appId, apiVersion))
  )
  server = app.listen(8000)

  client = webdriverio.remote(
    protocol: protocol
    host: hostname
    port: port
    desiredCapabilities:
      browserName: 'phantomjs'
  ).init()

  client.url(
    SITE_URL
  ).waitForVisible(
    '#login-button iframe', 5000
  ).moveToObject(
    '#login-button', 5, 5
  ).leftClick().then( ->
    checkForPopup = ->
      client.getTabIds().then((ids) ->
        if ids.length > 1
          return ids[-1...][0]
        else
          return BPromise.delay(300).then(checkForPopup)
      )
    checkForPopup()
  ).then((popupHandle) ->
    client.window(popupHandle)
  ).waitForVisible(
    '#email', 5000
  ).setValue(
    '#email', email
  ).setValue(
    '#pass', password
  ).leftClick('#loginbutton input').then( ->
    checkForPopupClosed = ->
      client.getTabIds().then((ids) ->
        if ids.length is 1
          return ids[0]
        else
          return BPromise.delay(300).then(checkForPopupClosed)
      )
    checkForPopupClosed()
  ).then((popupHandle) ->
    client.window(popupHandle)
  ).waitForVisible(
    '#facebook-response', 5000
  ).execute( ->
    document.getElementById('facebook-response').innerHTML
  ).then(({value}) ->
    value = JSON.parse(value)
    if value.status isnt 'connected'
      throw new Error("Got bad status from Facebook: #{value.status}")
    accessToken = value.authResponse.accessToken
    return
  ).end().then( ->
    server.close()
    return accessToken
  )
