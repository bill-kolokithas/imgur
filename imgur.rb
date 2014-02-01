#!/usr/bin/env ruby

require 'httparty'
require 'clipboard'

CLIENT_ID = 'c3d5102cafbba4c'
FILENAME  = ENV['HOME'] + '/imgur.png'

def upload_image
  response = HTTParty.post 'https://api.imgur.com/3/upload.json',
    :headers => { 'Authorization' => "Client-ID #{CLIENT_ID}" },
    :body    => { 'image' => Base64.encode64(File.read(FILENAME)) }

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
