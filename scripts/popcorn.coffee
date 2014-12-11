# Description:
#   answers whether the popcorn machine is here or not
#
# Dependencies:
#   infusionsoft-api
#
# Configuration:
#
# Commands:
#   is our popcorn machine here yet?
#
# Author:
#   kevin1024
#

env = process.env

module.exports = (robot) ->
  robot.respond /is.*popcorn.*/, (msg) ->
    msg.reply('No')
