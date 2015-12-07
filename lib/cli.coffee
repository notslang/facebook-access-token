ArgumentParser = require('argparse').ArgumentParser

packageInfo = require '../package'
getAuth = require './'

argparser = new ArgumentParser(
  version: packageInfo.version
  addHelp: true
  description: packageInfo.description
)

argparser.addArgument(
  ['--app-id']
  dest: 'appId'
  help: 'The id of the app to get a token for.'
  required: true
  type: 'string'
)
argparser.addArgument(
  ['--email']
  help: 'Email of the account to login with when getting the access token.'
  required: true
  type: 'string'
)
argparser.addArgument(
  ['--password', '-p']
  help: 'Password of the account specified with --username.'
  required: true
  type: 'string'
)
argparser.addArgument(
  ['--webdriver']
  defaultValue: 'http://localhost:4444'
  dest: 'webdriverServer'
  help: 'Address of the Selenium Hub instance or other webdriver-compatible API
  to use. Defaults to "http://localhost:4444".'
  type: 'string'
)

getAuth(argparser.parseArgs()).then(console.log.bind(console))
