dns = require("native-dns")
async = require("async")
getNameservers = (domain, cb) ->
  question = dns.Question(
    name: domain
    type: "NS"
  )
  req = dns.Request(
    question: question
    server:
      address: "8.8.8.8"
      port: 53
      type: "udp"

    timeout: 1000
  )
  data = []

  req.on "message", (err, answer) ->
    answer.answer.forEach (a) ->
      data.push a.data


  req.on "end", ->
    cb data

  req.send()

resolveIp = (domain, cb) ->
  question = dns.Question(
    name: domain
    type: "A"
  )
  req = dns.Request(
    question: question
    server:
      address: "69.20.95.4"
      port: 53
      type: "udp"

    timeout: 1000
  )

  data = []

  req.on "message", (err, answer) ->
    return  unless answer.answer[0]
    data.push answer.answer[0].address

  req.on "end", ->
    cb data

  req.send()

checkDomain = (domain, callback) ->
  async.parallel [
    (cb) ->
      getNameservers domain, (data) ->
        cb null, data

    (cb) ->
      resolveIp domain, (data) ->
        cb null, data

  ], (err, results) ->
    callback
      nameservers: results[0],
      ip: results[1]

module.exports = (robot) ->
  robot.hear /(check)( site)? (.*)/i, (msg) ->
    domain   = msg.match[3]
    langs = ["en"]

    msg.send("OK, I'll check " + domain + " for you")
    checkDomain domain, (data) ->
      if "#{data.nameservers.sort()}" is "#{['dns1.stabletransit.com','dns2.stabletransit.com']}"
        msg.send "Their nameservers are pointing at Rackspace"
      else
        msg.send "They have not changed their nameservers to point to rackspace"
      if data.ip.length
        msg.send "Their IP address resolves on our nameservers.  All good! #{JSON.stringify(data.ip)}"
      else
        msg.send "Uh oh, their IP address does not resolve on our nameservers.  Try to syncdns."
