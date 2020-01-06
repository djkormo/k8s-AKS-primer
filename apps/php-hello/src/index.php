<?php

echo "Hello, World from Docker! <br>";
echo '<img src="https://www.docker.com/sites/default/files/horizontal.png">';
echo "<br> ";
echo " Displayed at: ";
echo gethostname();
echo "<br>";
echo "Application version : ";
echo $_ENV["VERSION"] . '     !';
echo "<br>";
$debug=false;

$debug = ($_ENV["DEBUG"] === 'true');

if ($debug)
{
  phpinfo(INFO_ENVIRONMENT);
}
?>
