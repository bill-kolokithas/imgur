#!/usr/bin/env ruby

require 'curb'
require 'json'
require 'clipboard'

CLIENT_ID = 'c3d5102cafbba4c'

def upload_image(image)
  imgur = Curl::Easy.new "https://api.imgur.com/3/upload.json"
  imgur.multipart_form_post = true
  imgur.headers['Authorization'] = "Client-ID #{CLIENT_ID}"
  imgur.http_post(Curl::PostField.file('image', image))

  response = JSON.parse(imgur.body_str)
  response['data']['link']
end

link = upload_image(ARGV[0])
if link
  Clipboard.copy link
  system('notify-send "Upload complete"')
else
  system('notify-send "Upload error"')
end
