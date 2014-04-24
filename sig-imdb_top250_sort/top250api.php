<?php
include("imdb_top250.php");
$imdb = new Imdb(); 
$top250 = $imdb->getTop250();
foreach ($top250 as $value){
	$value = is_array($value)?implode("#", $value):$value;
	echo "$value\n";
}
?>