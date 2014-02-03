#!/usr/bin/env ruby

require 'curb'
require 'json'
require 'clipboard'

CLIENT_ID     = 'xxxxxxxxxxxxxxx'
CLIENT_SECRET = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
TOKEN_FILE    = ENV['HOME'] + '/.imgur_token'

def auth_app
  puts 'Follow the link to allow the application access to your account and enter the pin'
  puts "https://api.imgur.com/oauth2/authorize?client_id=#{CLIENT_ID}&response_type=pin"

  print 'Pin: '
  pin = STDIN.gets.chomp

  imgur = Curl.post "https://api.imgur.com/oauth2/token", {
    client_id:     CLIENT_ID,
    client_secret: CLIENT_SECRET,
    grant_type:    :pin,
    pin:           pin
  }

  response = JSON.parse(imgur.body_str)
  abort 'Authorization failed' unless response['access_token']
  tokens = {
    'access_token'  => response['access_token'],
    'refresh_token' => response['refresh_token']
  }

  File.write(TOKEN_FILE, tokens.to_json)
  tokens
end

def refresh_token(refresh_token)
  imgur = Curl.post "https://api.imgur.com/oauth2/token", {
    refresh_token: refresh_token,
    client_id:     CLIENT_ID,
    client_secret: CLIENT_SECRET,
    grant_type:    :refresh_token
  }

  response = JSON.parse(imgur.body_str)
  response['access_token']
end

def upload_image(image, access_token)
  imgur = Curl::Easy.new "https://api.imgur.com/3/upload.json"
  imgur.multipart_form_post = true
  imgur.headers['Authorization'] = "Bearer #{access_token}"
  imgur.http_post(Curl::PostField.file('image', image))

  response = JSON.parse(imgur.body_str)
  response['data']['link']
end

abort "Usage: #{$PROGRAM_NAME} <path/to/file.(png|jpg)> [scrot extra flag]" unless ARGV.length > 0
abort 'scrot not found' unless system("scrot #{ARGV[0]} #{ARGV[1]}")
tokens = File.exists?(TOKEN_FILE) ? JSON.parse(File.read(TOKEN_FILE)) : auth_app

link = upload_image(ARGV[0], tokens['access_token'])
unless link
  tokens['access_token'] = refresh_token(tokens['refresh_token'])
  link = upload_image(ARGV[0], tokens['access_token'])
  File.write(TOKEN_FILE, tokens.to_json)
end

if link
  Clipboard.copy link
  system('notify-send -t 2000 "Upload complete"')
else
  system('notify-send -t 2000 "Upload error"')
end
