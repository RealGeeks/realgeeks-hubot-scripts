# Description:
#   Deploys code to production
#
# Dependencies:
#   fabric-remote
#
# Configuration:
#   FABRIC_REMOTE_SERVER - Hostname of the fabric remote server
#   FABRIC_REMOTE_PORT - Port of the fabric remote server
#   FABRIC_REMOTE_PASS - Password of the fabric remote server
#
# Commands:
#   deploy <project> - Deploys the master branch of a project to production
#
# Author:
#   kevin1024
#

ENVS = [
  'staging',
  'production'
]


env = process.env
FabricRemote = require('fabric-remote')

fr = new FabricRemote(env.FABRIC_REMOTE_SERVER, env.FABRIC_REMOTE_PORT, env.FABRIC_REMOTE_PASS)

module.exports = (robot) ->
  robot.respond /(?:deploy) (.*)(?: to (.*))/i, (msg) ->
    project  = msg.match[1].trim()
    environment  = msg.match[2].trim()
    langs = ["en"]

    if environment not in ENVS
        msg.send("Sorry, I've never heard of the #{environment} environment")

    msg.send("OK, I'm deploying #{project} to #{environment}")

    execution = fr.execute([
      {task: environment, args: [], kwargs: {}},
      {task: "#{project}.deploy", args: [], kwargs: {}}
    ])
    .then (data) ->
      log_url = "http://admin:#{env.FABRIC_REMOTE_PASS}@#{env.FABRIC_REMOTE_SERVER}:#{env.FABRIC_REMOTE_PORT}#{data['output']}"
      if data.error
        msg.send("Error deploying #{project} to #{environment}: #{data.error}. View logs: #{log_url}")
        return
      msg.send("Project #{project} successfully deployed.  View logs: #{log_url}")
    ,(err) ->
      msg.send("Error deploying #{project}: #{err}. View logs: #{log_url}")
