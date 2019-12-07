<?php

# force displaying errors
error_reporting(E_ALL);

ini_set("display_errors", 1);

$url = 'http://ip172-18-0-8-blq190ad7o0g00edt8d0-8080.direct.labs.play-with-docker.com/sentiment/';
$data = array('sentiment' => 'I like yogobella');
$options = array(
        'http' => array(
        'header'  => "Content-type: application/json\r\n",
        'method'  => 'POST',
        'content' => json_encode($data),
    )
);
print_r($options);
$context  = stream_context_create($options);
$result = file_get_contents( $url, false, $context );
$response = json_decode( $result );
print($response);

?>