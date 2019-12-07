<?php // demo/curl_post_example.php
/**
 * Demonstrate how to use cURL to make a POST request
 * This may be used to start an asynchronous process
 * Property 'title' is a comment field to identify the object
 *
 * http://php.net/manual/en/book.curl.php
 * https://curl.haxx.se/libcurl/c/
 * https://curl.haxx.se/libcurl/c/libcurl-errors.html
 */
error_reporting(E_ALL);
ini_set("display_errors", 1);

// USAGE EXAMPLE CREATES ASSOCIATIVE ARRAY OF KEY=>VALUE PAIRS
#$args["name"] = 'Ray';
#$args["mail"] = 'Ray.Paseur@Gmail.com';

$args["sentiment"]="I love playing tennis";
print_r($args);

// SET THE URL
$url = "https://Iconoun.com/demo/request_reflector.php";

$url=getenv('SA_WEBAPP_API_URL');

$url='http://ip172-18-0-8-blq190ad7o0g00edt8d0-8080.direct.labs.play-with-docker.com/sentiment/';

// CREATE THE RESPONSE OBJECT
$response = new POST_Response_Object($url, $args, 'TESTING 1 2 3...');

// SHOW THE WORK PRODUCT
echo "<pre>";
if ( $response->document) echo htmlentities($response->document); // ON SUCCESS SHOW RETURNED DOCUMENT
if (!$response->document) print_r($response); // ON FAILURE SHOW ERROR INFORMATION

// SHOW CURL RESPONSE MESSAGES FOR DEBUGGING
unset($response->document);
echo PHP_EOL . PHP_EOL;
print_r($response);

// OPTIONAL -- SHOW THE COOKIES, IF ANY
echo PHP_EOL . PHP_EOL;
echo @file_get_contents('cookie.txt');


Class POST_Response_Object
{
    public $href, $title, $http_code, $errno, $error, $info, $document;

    public function __construct($href, $post_array=[], $title=NULL)
    {
        // ACTIVATE THIS TO AVOID TIMEOUT FOR LONG RUNNING SCRIPT
        // set_time_limit(10);

        // STORE THE CALL INFORMATION
        $this->href  = $href;
        $this->title = $title;

        // CREATE THE REFERRER
        $refer = $_SERVER['REQUEST_SCHEME'] . '://' . $_SERVER['HTTP_HOST'] . $_SERVER['REQUEST_URI'];

        // PREPARE THE POST STRING
        $post_string = http_build_query($post_array);

        // MAKE THE REQUEST
        if (!$this->my_curl($href, $post_string, $refer))
        {
            // ACTIVATE THIS TO SEE THE ERRORS AS THEY OCCUR
            // trigger_error("Errno: $this->errno; HTTP: $this->http_code; URL: $this->href", E_USER_WARNING);
        }
    }

    protected function my_curl($url, $post_string, $refer, $timeout=3)
    {
        // PREPARE THE CURL CALL
        $curl = curl_init();
        curl_setopt( $curl, CURLOPT_URL,            $url           );
        curl_setopt( $curl, CURLOPT_REFERER,        $refer         );
        curl_setopt( $curl, CURLOPT_HEADER,         FALSE          );
        curl_setopt( $curl, CURLOPT_POST,           TRUE           );
        curl_setopt( $curl, CURLOPT_POSTFIELDS,     $post_string   );
        curl_setopt( $curl, CURLOPT_ENCODING,       'gzip,deflate' );
        curl_setopt( $curl, CURLOPT_TIMEOUT,        $timeout       );
        curl_setopt( $curl, CURLOPT_RETURNTRANSFER, TRUE           );
        curl_setopt( $curl, CURLOPT_FOLLOWLOCATION, TRUE           );
        curl_setopt( $curl, CURLOPT_FAILONERROR,    TRUE           );

        // IF USING SSL, THIS INFORMATION IS IMPORTANT -- UNDERSTAND THE SECURITY RISK!
        curl_setopt( $curl, CURLOPT_SSLVERSION,     CURL_SSLVERSION_DEFAULT  );
        curl_setopt( $curl, CURLOPT_SSL_VERIFYHOST, 2  ); // DEFAULT
        curl_setopt( $curl, CURLOPT_SSL_VERIFYPEER, 1  ); // DEFAULT

        // SET THE LOCATION OF THE COOKIE JAR (THIS FILE WILL BE OVERWRITTEN)
        curl_setopt( $curl, CURLOPT_COOKIEFILE,     'cookie.txt' );
        curl_setopt( $curl, CURLOPT_COOKIEJAR,      'cookie.txt' );

        // RUN THE CURL REQUEST AND GET THE RESULTS
        $this->document  = curl_exec($curl);
        $this->errno     = curl_errno($curl);
        $this->info      = curl_getinfo($curl);
        $this->http_code = $this->info['http_code'];
        curl_close($curl);

        // RETURN THE OBJECT
        return $this;
    }
}