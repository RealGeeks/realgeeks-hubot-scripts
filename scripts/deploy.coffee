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

env = process.env
FabricRemote = require('fabric-remote')

fr = new FabricRemote(env.FABRIC_REMOTE_SERVER, env.FABRIC_REMOTE_PORT, env.FABRIC_REMOTE_PASS)

module.exports = (robot) ->
  robot.respond /(deploy)?( me)? (.*)/i, (msg) ->
    project  = msg.match[3].trim()
    langs = ["en"]

    if project != 'web'
        msg.send("I only know how to deploy web")
        return

    msg.send("OK, I'm deploying #{project}")

    execution = fr.execute([
      {task: "production", args: [], kwargs: {}},
      {task: "web.deploy", args: [], kwargs: {}}
    ])
    .then (data) ->
      msg.send("Project #{project} successfully deployed")
    ,(err) ->
      msg.send("Error deploying #{project}: #{err}")
