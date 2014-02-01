#!/usr/bin/env ruby

require 'httparty'
require 'json'
require 'clipboard'

CLIENT_ID     = 'xxxxxxxxxxxxxxx'
CLIENT_SECRET = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
TOKEN_FILE    = ENV['HOME'] + '/.imgur_token'
FILENAME      = ENV['HOME'] + '/imgur.png'

def auth_app
  puts 'Follow the link to allow the application access to your account and enter the pin'
  puts "https://api.imgur.com/oauth2/authorize?client_id=#{CLIENT_ID}&response_type=pin"

  print 'Pin: '
  pin = gets.chomp

  response = HTTParty.post 'https://api.imgur.com/oauth2/token',
    :body => {
      'client_id'     => CLIENT_ID,
      'client_secret' => CLIENT_SECRET,
      'grant_type'    => 'pin',
      'pin'           => pin
    }
  abort 'Authorization failed' unless response['access_token']
  tokens = {
    'access_token'  => response['access_token'],
    'refresh_token' => response['refresh_token']
  }
  File.write(TOKEN_FILE, tokens.to_json)
  tokens
end

def refresh_token(refresh_token)
  response = HTTParty.post 'https://api.imgur.com/oauth2/token',
    :body => {
      'refresh_token' => refresh_token,
      'client_id'     => CLIENT_ID,
      'client_secret' => CLIENT_SECRET,
      'grant_type'    => 'refresh_token'
    }
  response['access_token']
end

def upload_image(access_token)
  response = HTTParty.post 'https://api.imgur.com/3/upload.json',
    :headers => { 'Authorization' => "Bearer #{access_token}" },
    :body    => { 'image' => Base64.encode64(File.read(FILENAME)) }

  response['data']['link']
end

abort 'scrot not found' unless system("scrot #{ARGV[0]} #{FILENAME}")
tokens = File.exists?(TOKEN_FILE) ? JSON.parse(File.read(TOKEN_FILE)) : auth_app

link = upload_image(tokens['access_token'])
unless link
  tokens['access_token'] = refresh_token(tokens['refresh_token'])
  link = upload_image(tokens['access_token'])
  File.write(TOKEN_FILE, tokens.to_json)
end

if link
  Clipboard.copy link
  system("notify-send -t 2000 'Upload complete'")
else
  system("notify-send -t 2000 'Upload error'")
end
