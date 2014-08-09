# Description:
#  Image splode
#
# Commands:
#   splode <query|beagle puppy> <n>

Array::shuffle = -> @sort -> 0.5 - Math.random()

module.exports = (robot) ->
  robot.respond /(([\w\s]+) )?splode( (\d+))?/i, (msg) ->
    
    query = msg.match[2] || 'beagle puppy'
    count = msg.match[4]-1 || 5
    
    # Fix the space characters to be url friendly
    query = query.replace(/[\s]+/g, '+')
    
    output_photos = []
    msg.http("http://api.tumblr.com/v2/tagged?tag=" + query + "&api_key=wP7Zp7uiqJPwFJ4muezAOMtAzHE3fEn3AZb0T8XcZEnlTFBN4M")
      .get() (err, res, body) ->
        data = JSON.parse(body)
        for response in data.response
          if response.photos?
             for photo in response.photos
               output_photos.push photo.original_size.url
        output_photos = output_photos.shuffle()[0..count]
        for i in output_photos
          msg.send i
