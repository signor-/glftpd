<?php
class Imdb
{
// Get Top 250 Movie List
public function getTop250(){
	$html = $this->geturl("http://www.imdb.com/chart/top");
	$top250 = array();                 
	$rank = 1;
	foreach ($this->match_all('/<tr class="(even|odd)">(.*?)<\/tr>/ms', $html, 2) as $m) {
		$id = $this->match('/<td class="titleColumn">.*?<a href="\/title\/(tt\d+)\/.*?"/msi', $m, 1);
		$title = $this->match('/<td class="titleColumn">.*?<a.*?>(.*?)<\/a>/msi', $m, 1);
		$year = $this->match('/<td class="titleColumn">.*?<span.*?class="secondaryInfo">\((.*?)\)<\/span>/msi', $m, 1);
		$rating = $this->match('/<td class="ratingColumn">.*?<strong.*?>(.*?)<\/strong>/msi', $m, 1);
		$top250[] = array("rank"=>$rank, "id"=>$id, "title"=>$title, "year"=>$year, "rating"=>$rating);
		$rank++;
	}
return $top250;
}
// Get URL
private function geturl($url){
	$ch = curl_init();
	$ip=rand(0,255).'.'.rand(0,255).'.'.rand(0,255).'.'.rand(0,255);
	curl_setopt($ch, CURLOPT_URL, $url);
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
	curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, 5);
	curl_setopt($ch, CURLOPT_HTTPHEADER, array("REMOTE_ADDR: $ip", "HTTP_X_FORWARDED_FOR: $ip", "Accept-Charset: ISO-8859-1,utf-8;q=0.7,*;q=0.7", "Accept-Language: en-us,en;q=0.5"));
	curl_setopt($ch, CURLOPT_USERAGENT, "Mozilla/".rand(3,5).".".rand(0,3)." (Windows NT ".rand(3,5).".".rand(0,2)."; rv:2.0.1) Gecko/20100101 Firefox/".rand(3,5).".0.1");
	curl_setopt($ch, CURLOPT_REFERER, "http://www.google.com");
	curl_setopt($ch, CURLOPT_AUTOREFERER, true);
	$html = curl_exec($ch);
	curl_close($ch);
	return $html;
}
// Match All
private function match_all($regex, $str, $i = 0){
	if(preg_match_all($regex, $str, $matches) === false)
		return false;
	else
		return $matches[$i];
}
// Match
private function match($regex, $str, $i = 0){
	if(preg_match($regex, $str, $match) == 1)
		return $match[$i];
	else
		return false;
	}
}
?>