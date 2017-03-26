<?php
function dump($vars, $label = '', $return = false) {
    if (ini_get('html_errors')) {
        $content = "<pre>\n";
        if ($label != '') {
            $content .= "<strong>{$label} :</strong>\n";
        }
        $content .= htmlspecialchars(print_r($vars, true));
        $content .= "\n</pre>\n";
    } else {
        $content = $label . " :\n" . print_r($vars, true);
    }
    if ($return) { return $content; }
    echo $content;
    return null;
}
/**
 * 发送post请求
 * @param string $url 请求地址
 * @param array $post_data post键值对数据
 * @return string
 */
function send_post($url, $post_data) {

	$postdata = http_build_query($post_data);
	$options = array(
		'http' => array(
			'method' => 'POST',
			'header' => 'Content-type:application/x-www-form-urlencoded',
			'content' => $postdata,
			'timeout' => 15 * 60 // 超时时间（单位:s）
		)
	);
	$context = stream_context_create($options);
	$result = file_get_contents($url, false, $context);

	return $result;
}

		$lic = $_GET["lic"];

    $post_data = array(
      "lic" => $lic,
      "mode" => "Regular",
      "daily_monthly" => "daily",
		"arr" => "22/06/16 6:20 PM",
		"dep" => "22/06/16 9:20 PM"
    );
    $jsonString = send_post("http://www.bestparking.com/ottawa-parking/garage_info",$post_data);
    $jsonString = str_replace("&nbsp;", " ", $jsonString);
    $phoneNumPattern = "/[0-9]{3}-[0-9]{3}-[0-9]{4}/";
   // $matches = array();
    preg_match($phoneNumPattern, $jsonString, $matches);
    $phoneNum = "";
    if(isset($matches[0])){
      $phoneNum = $matches[0];
    }else{
      $phoneNum = "";
    }

    $capacityPattern = "/Capacity: [0-9]*/";
    preg_match($capacityPattern, $jsonString, $matches);
    $capacity = "";
    $capacity = $matches[0];
    $capacity = "Available ".$capacity;


	  $json = json_decode($jsonString, true);
    $allRates = $json["AllRates"];
    $allRatesArray = array();
    foreach ($allRates as $key => $value) {

        $allRatesArray[$key] = $value["HOURLY_PARKING"]["DATA"];

    }
    
    $detailInfoArray = array("phoneNum" => $phoneNum, "capacity" => $capacity, "img" => $json["img"], "allRates" => $allRatesArray);
    //dump($detailInfoArray);
		echo json_encode( $detailInfoArray );
