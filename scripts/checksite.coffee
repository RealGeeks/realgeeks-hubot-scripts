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

OUR_IP_ADDRESSES = [
    '52.202.207.170',
    '52.202.220.30',
    '52.203.159.207',
    '52.203.246.216',
    '52.203.78.209',
    '52.204.22.70',
    '52.204.51.220',
    '52.204.55.6',
    '52.204.60.71',
    '52.204.63.7',
    '52.204.65.164',
    '52.204.65.224',
    '52.204.73.145',
    '52.204.73.80',
    '52.204.74.10',
    '52.204.74.186',
    '52.204.76.155',
    '52.204.77.157',
    '52.204.77.215',
    '52.204.78.17',
    '52.204.81.187',
    '52.204.81.23',
    '52.204.81.50',
    '52.204.81.53',
    '52.204.81.57',
    '52.204.81.59',
    '52.204.81.63',
    '52.204.81.79',
    '52.204.82.16',
    '52.23.85.97',
    '52.7.182.159',
    '52.7.71.22',
    '52.71.60.227',
    '52.87.57.92',
    '67.192.203.35',
    '98.129.53.0',
    '67.192.111.55',
    '67.192.203.36',
    '98.129.51.162',
    '72.32.55.73',
    '72.32.189.255',
    '98.129.51.166',
    '98.129.11.123',
    '67.192.111.53',
    '67.192.111.54',
    '98.129.53.1',
    '98.129.6.190',
    '98.129.11.121',
    '72.32.55.74',
    '74.205.36.225',
    '98.129.11.122',
    '98.129.11.127',
    '67.192.111.51',
    '72.32.55.75',
    '67.192.111.56',
    '67.192.111.57',
    '98.129.53.6',
    '98.129.53.4',
    '98.129.11.125',
    '98.129.11.124',
    '72.32.55.76',
    '72.32.189.254',
    '67.192.111.52',
    '72.32.55.72',
    '72.32.55.77',
    '98.129.53.5',
    '98.129.11.126',
    '67.192.111.49',
    '72.32.55.79',
    '67.192.111.48',
    '72.32.55.78',
    '98.129.6.189',
    '67.192.111.58',
    '98.129.6.184'
]

dns = require("native-dns")
async = require("async")
url = require("url")

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
  dnsQuery ANOTHER_DNS_SERVER, domain, "NS", (data) ->
    cb (d.data for d in data)

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
  robot.respond /(check site) (.*)/i, (msg) ->
    domain = msg.match[2].trim()
    langs = ["en"]

    if domain.indexOf('http') == 0
        domain = url.parse(domain).hostname

    msg.send("OK, I'll check " + domain + " for you")
    checkDomain domain, (data) ->
      if "#{data.nameservers.sort()}" is "#{['dns1.stabletransit.com','dns2.stabletransit.com']}"
        msg.send "Their nameservers are pointing at Rackspace"
      else
        msg.send "They have not changed their nameservers to point to rackspace"
      if data.ip.length and data.ip[0] in OUR_IP_ADDRESSES
        msg.send "Their IP address resolves on our nameservers and points to one of our servers."
      else if data.ip.length and data.ip[0] not in OUR_IP_ADDRESSES
        msg.send "Their IP adddress resolves on our nameservers, but points to another IP.  We need to contact Rackspace and get them to move the domain to our control panel."
      else
        msg.send "Uh oh, their IP address does not resolve on our nameservers.  Try to syncdns."
      if data.mx.length
        msg.send "Their MX records on our servers  are: #{JSON.stringify(data.mx)}"
