<?php

$url ="http://ip172-18-0-8-blq190ad7o0g00edt8d0-8080.direct.labs.play-with-docker.com/sentiment/";

$url = getenv('SA_WEBAPP_API_URL');
print("Endpoint->:".$url);

#$url ="http://ip172-18-0-8-blq190ad7o0g00edt8d0-5000.direct.labs.play-with-docker.com/analyse/sentiment";   
$data=array('sentence' => 'I like yogobella',
'sentence' => 'I hate cats'
);
$content = json_encode($data);

$curl = curl_init($url);
curl_setopt($curl, CURLOPT_HEADER, false);
curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
curl_setopt($curl, CURLOPT_HTTPHEADER,
        array("Content-type: application/json"));
curl_setopt($curl, CURLOPT_POST, true);
curl_setopt($curl, CURLOPT_POSTFIELDS, $content);

$json_response = curl_exec($curl);

$status = curl_getinfo($curl, CURLINFO_HTTP_CODE);
echo "<pre>";
print($status);

if ( $status > 200 ) {
    print("Error: call to URL $url failed with status $status, response $json_response, curl_error " . curl_error($curl) . ", curl_errno " . curl_errno($curl));
}

curl_close($curl);

$response = json_decode($json_response, true);

print_r($data);
print (CURLINFO_HTTP_CODE);
print($status);
print_r($response);
echo "</pre>";

?>