# Description:
#   Does stuff to leads on infusionsoft
#
# Dependencies:
#   infusionsoft-api
#
# Configuration:
#   INFUSIONSOFT_NAME - The unique ID on the front of your IFS subdomain
#   INFUSIONSOFT_API_KEY - API key for your infusionsoft account
#
# Commands:
#   delete <email> from infusionsoft - Deletes a contact from infusionsoft
#
# Author:
#   kevin1024
#

api = require('infusionsoft-api')
env = process.env
infusionsoft = new api.DataContext(env.INFUSIONSOFT_NAME, env.INFUSIONSOFT_API_KEY)

module.exports = (robot) ->
  robot.respond /delete\s+(.*\@.*\..*)\s+from (?:infusionsoft|ifs)(?:.*)/i, (msg) ->
    email = msg.match[1].trim()
    infusionsoft.Contacts
      .where(Contact.Email, email)
      .select(Contact.FirstName, Contact.LastName, Contact.Id)
      .toArray()
      .then (result) ->
        if result.length
          result.forEach (contact) ->
            infusionsoft.DataService.delete('Contact', contact.Id)
            .then (result) ->
              msg.reply("OK, I deleted #{contact.FirstName} #{contact.LastName} <#{email}>")
            .fail (err) ->
              msg.reply('Error communicating with Infusionsoft, try again:', err)
        else
          msg.reply("Sorry, I was unable to find a user with email #{email} in InfusionSoft")
      .fail (err) ->
        msg.reply('Error communicating with Infusionsoft, try again:', err)
