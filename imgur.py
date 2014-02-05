#!/usr/bin/env python3

import urllib.request, urllib.parse, json
from sys import argv, exit
from os import system, WEXITSTATUS
from subprocess import Popen, PIPE
from base64 import b64encode

CLIENT_ID = "c41f83908ef6e8f"

def upload_image(cid):
    url = "https://api.imgur.com/3/upload"
    image = open(argv[1], 'rb').read()
    data = {'image' : b64encode(image), 'type' : "base64"}
    headers = {'Authorization' : "Client-ID "+cid}
    req = urllib.request.Request(url, data, headers)
    req.add_data(urllib.parse.urlencode(data).encode('utf-8'))     
    return urllib.request.urlopen(req)

try:    
    image = argv[1]
except IndexError:
    exit('image path required')
try:
    etc = argv[2]
except IndexError:
    etc = ""

status = system("scrot %s %s" % (image, etc))       
if WEXITSTATUS(status) == 127 : exit("scrot is not installed!")
   
try:
    res = upload_image(CLIENT_ID)
except urllib.error.HTTPError as e:
    print("HTTP Error:", e.getcode(), e.reason)
    system('notify-send -t 2000 "Upload error"')
else:
    res = json.loads(res.read().decode("utf-8"))
    
    try:
        p = Popen(['xclip', '-selection', 'c'], stdin=PIPE)
    except FileNotFoundError as e:
        print(res['data']['link'], end="")
        system('notify-send -t 2000 "Upload complete"')
    else:
        p.communicate(input=bytes(res['data']['link'], "utf-8"))
        system('notify-send -t 2000 "Upload complete"')
        
