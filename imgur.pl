#!/usr/bin/env perl
use strict;
use warnings;
use WWW::Curl::Easy;
use WWW::Curl::Form;

my $url = &upload_image($ARGV[0]);
if ($url) {
    system("notify-send Upload Complete");
    system("echo -n $url |xclip -selection c");
}
else {
    system("notify-send Upload error");
}

sub upload_image {
    my $filename = shift @_;
    my $link;
    my @headers = ('Authorization: Client-ID c3d5102cafbba4c');

    my $curl = WWW::Curl::Easy->new;
    $curl->setopt(CURLOPT_HEADER,1);
    $curl->setopt(CURLOPT_HTTPHEADER,\@headers);
    $curl->setopt(CURLOPT_URL,"https://api.imgur.com/3/upload.xml");

    my $curl_form= new WWW::Curl::Form;
    $curl_form ->formaddfile($filename, 'image', "multipart/form-data");
    $curl->setopt(CURLOPT_HTTPPOST,$curl_form);

    my $response_body;
    $curl->setopt(CURLOPT_WRITEDATA, \$response_body);

    my $retcode = $curl->perform;
    if ($retcode == 0) {
        my $response_code = $curl->getinfo(CURLINFO_HTTP_CODE);
        ($link) = $response_body =~ m/(http:\/\/i.imgur.com\/\w+.\w+)/;
        return $link;
    }
}
