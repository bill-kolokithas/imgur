Collection of programs to upload photos on imgur.
They use scrot to take a picture, xclip to put the direct link on clipboard and libnotify to show a notification when done.
All programs use v3 api and the ruby-oauth supports uploading photos to a user's album.

curb gem required for ruby versions (curl bindings)

Usage for all programs:
-
`./imgur_program <path/to/file.(png|jpg)> [scrot extra flag]` 

Example: (-s grabs selection or specific window)
-
`./imgur.rb ~/imgur.png -s`

Command to compile C program
-
`gcc -s -O2 imgur.c -o imgur -lcurl`
