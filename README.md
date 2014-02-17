Collection of scripts to upload photos on imgur.
All scripts use xclip to put the direct link on clipboard and libnotify to show a notification when done.
Images are uploaded anonymously using v3 api.
ruby-oauth supports uploading photos to a user's album. (you have to run it from terminal the first time)

C version requires curl headers and ruby needs the curl bindings provided by `curb` gem.

Usage for all scripts
-
`./imgur_script <path/to/file.(png|jpg)>`

Example invocation using scrot
-
`scrot -e 'imgur.rb $f'`

Command to compile C program
-
`gcc -s -O2 imgur.c -o imgur -lcurl`
