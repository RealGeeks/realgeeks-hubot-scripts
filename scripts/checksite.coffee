# Description:
#   Check a website to make sure it's dns is all good
#
# Dependencies:
#   native-dns
#   scyn
#
# Configuration:
#
# Commands:
#   check site <domain> - Check the site's DNS configuration
#
# Author:
#   kevin1024
#
RACKSPACE_DNS_SERVER = '69.20.95.4'
ANOTHER_DNS_SERVER = '8.8.8.8'

dns = require("native-dns")
async = require("async")

dnsQuery = (server, domain, record, cb) ->
  data = []
  question = dns.Question(
    name: domain
    type: record
  )
  req = dns.Request(
    question: question
    server:
      address: server
      port: 53
      type: "udp"

    timeout: 1000
  )

  req.on "message", (err, answer) ->
    data = answer.answer

  req.on "end", ->
    cb data

  req.send()

getNameservers = (domain, cb) ->
  dnsQuery ANOTHER_DNS_SERVER, domain, "NS", cb

getMXRecords = (domain, cb) ->
  dnsQuery RACKSPACE_DNS_SERVER, domain, "MX", (data) ->
    cb (d.exchange for d in data)

resolveIp = (domain, cb) ->
  dnsQuery RACKSPACE_DNS_SERVER, domain, "A", (data) ->
    cb (d.address for d in data)

checkDomain = (domain, callback) ->
  async.parallel [
    (cb) ->
      getNameservers domain, (data) ->
        cb null, data

    (cb) ->
      resolveIp domain, (data) ->
        cb null, data

    (cb) ->
      getMXRecords domain, (data) ->
        cb null, data

  ], (err, results) ->
    callback
      nameservers: results[0],
      ip: results[1]
      mx: results[2]

module.exports = (robot) ->
  robot.hear /(check)( site)? (.*)/i, (msg) ->
    domain   = msg.match[3]
    langs = ["en"]

    if domain.indexOf('www.') == 0
        msg.send("please just send the domain name without the www")
        return

    if domain.indexOf('http') == 0
        msg.send("Please just send the domain namee without the http and www")
        return

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
      if data.mx.length
        msg.send "Their MX records on our servers  are: #{JSON.stringify(data.mx)}"
