#!/usr/bin/env python3

import urllib.request, urllib.parse, json
from sys import argv, exit
from os.path import expanduser as path
from subprocess import call, Popen, PIPE
from base64 import b64encode

CLIENT_ID = "c3d5102cafbba4c"

def upload_image(image_path, cid=CLIENT_ID):
    url = "https://api.imgur.com/3/upload"
    image = open(path(image_path), 'rb').read()
    data = {'image' : b64encode(image), 'type' : "base64"}
    headers = {'Authorization' : "Client-ID "+cid}
    req = urllib.request.Request(url, data, headers)
    req.add_data(urllib.parse.urlencode(data).encode('utf-8'))
    try:
        res = urllib.request.urlopen(req)
    except urllib.error.HTTPError as e:
        print("HTTP Error:", e.getcode(), e.reason)
        return None
    return json.loads(res.read().decode("utf-8"))['data']['link']

def main():

    if len(argv) != 2:
        exit("Usage: ./imgur.py <path/to/image.(png|jpg)>")

    link = upload_image(argv[1])
    if not link:
        call(["notify-send", "Upload error"])
    else:
        try:
            p = Popen(['xclip', '-selection', 'c'], stdin=PIPE)
        except FileNotFoundError:
            print(link, end="")
        else:
            p.communicate(input=bytes(link, "utf-8"))
            p.wait()
        finally:
            call(["notify-send", "Upload complete"])

if __name__ == "__main__":
    main()
