env = process.env
FabricRemote = require('fabric-remote')

fr = new FabricRemote(env.FABRIC_REMOTE_SERVER, env.FABRIC_REMOTE_PORT, env.FABRIC_REMOTE_PASS)

module.exports = (robot) ->
  robot.respond /(refresh|update) (naughty|delinquent) .*/i, (msg) ->
    msg.send("Ok, I'll do exactly that")

    environment = "production"

    execution = fr.execute([
      {task: environment, args: [], kwargs: {}},
      {task: "accounts.update_delinquents", args: [], kwargs: {}}
    ])
    .then (data) ->
      log_url = "http://admin:#{env.FABRIC_REMOTE_PASS}@#{env.FABRIC_REMOTE_SERVER}:#{env.FABRIC_REMOTE_PORT}#{data['output']}"
      if data.error
        msg.reply("Error updating list")
        return
      msg.reply("List has been updated")
    ,(err) ->
      msg.reply("Error updating: #{err}. View logs: #{log_url}")
