#!/usr/bin/env ruby

require 'httmultiparty'
require 'clipboard'

CLIENT_ID = 'c3d5102cafbba4c'
FILENAME  = ENV['HOME'] + '/imgur.png'

class Imgur
  include HTTMultiParty
  base_uri 'https://api.imgur.com'
end

def upload_image
  response = Imgur.post '/3/upload.json',
    :headers => { 'Authorization' => "Client-ID #{CLIENT_ID}" },
    :body    => { 'image' => File.new(FILENAME) }

  response['data']['link']
end

abort 'scrot not found' unless system("scrot #{ARGV[0]} #{FILENAME}")

link = upload_image
if link
  Clipboard.copy link
  system("notify-send -t 2000 'Upload complete'")
else
  system("notify-send -t 2000 'Upload error'")
end
