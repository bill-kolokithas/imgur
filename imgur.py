#!/usr/bin/env python3

import urllib.request, urllib.parse, json
from sys import argv, exit
from subprocess import call, Popen, PIPE
from base64 import b64encode

CLIENT_ID = "c3d5102cafbba4c"

def upload_image(image_path, cid=CLIENT_ID):
    url = "https://api.imgur.com/3/upload"
    image = open(image_path, 'rb').read()
    data = {'image' : b64encode(image), 'type' : "base64"}
    headers = {'Authorization' : "Client-ID "+cid}
    req = urllib.request.Request(url, data, headers)
    req.add_data(urllib.parse.urlencode(data).encode('utf-8'))
    return urllib.request.urlopen(req)

def main():

    if len(argv) != 2:
        exit("Usage: ./imgur.py <path/to/image.(png|jpg)>")

    try:
        res = upload_image(argv[1])
    except urllib.error.HTTPError as e:
        print("HTTP Error:", e.getcode(), e.reason)
        call(["notify-send", "Upload error"])
    else:
        res = json.loads(res.read().decode("utf-8"))
        
        try:
            p = Popen(['xclip', '-selection', 'c'], stdin=PIPE)
        except FileNotFoundError:
            print(res['data']['link'], end="")
        else:
            p.communicate(input=bytes(res['data']['link'], "utf-8"))
            p.wait()
        finally:
            call(["notify-send", "Upload complete"])

if __name__ == "__main__":
    main()
