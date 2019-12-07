
<!doctype html>


<html lang="en">
<head>
  <meta charset="utf-8">
  <title>My sentiments</title>
  <!-- Link your php/css file -->
  <link rel="stylesheet" href="style.php" media="screen">
</head>

<body>
  <h1>My sentiments</h1>
  <p>Enter the sentence.</p>
  
  
<form action="index.php" method="POST">
<label>Enter Sentence (for example 'I like playing football'):</label><br />
<input type="text" value="I hate cats and dogs" name="sentence" placeholder="Enter  Sentence" required/>
<br /><br />
<input type="submit" value="Check sentiment of your sentence">
<input type="reset" value="Reset">
</form>
  
 
<?php

# force displaying errors
error_reporting(E_ALL);

ini_set("display_errors", 1);

#<button type="submit" name="submit" value="Check sentiment of your sentence">Submit</button>

$url ="http://ip172-18-0-8-blq190ad7o0g00edt8d0-8080.direct.labs.play-with-docker.com/sentiment/";

$url = getenv('SA_WEBAPP_API_URL');

print("Your endpoint->: ".$url); 
 
echo "<pre>";
    print_r($_POST);
echo "</pre>";


 
//if((isset($_POST['sentence']) && $_POST['sentence']!="")
//{

$sentence= $_POST['sentence'];
$data=array('sentence' => 'I hate cats and dogs');

$data["sentence"] = $sentence;

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
print ("\nInput: \n");
print($sentence);
print ("\nInput 2: \n");
print_r($data);
if ( $status > 200 ) {
    print("Error: call to URL $url failed with status $status, response $json_response, curl_error " . curl_error($curl) . ", curl_errno " . curl_errno($curl));
}

curl_close($curl);

$response = json_decode($json_response, true);

print ("CURLINFO_HTTP_CODE: \n");
print (CURLINFO_HTTP_CODE);
print ("\nOUTPUT: \n");
print_r($response);
echo "</pre>";

//} // of if 



?>
 
  


</body>
</html>