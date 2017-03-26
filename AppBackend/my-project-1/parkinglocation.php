<?php
date_default_timezone_set("America/Toronto");
//Only used to debug
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

//Connect to DataBase 
function connectToDB(){
 // Connect to CloudSQL from App Engine.
  $dsn = getenv('MYSQL_DSN');
  $user = getenv('MYSQL_USER');
  $password = getenv('MYSQL_PASSWORD');
  if (!isset($dsn, $user) || false === $password) {
      throw new Exception('Set MYSQL_DSN, MYSQL_USER, and MYSQL_PASSWORD environment variables');
  }

  $db = new PDO($dsn, $user, $password);
 
  return $db;
 };

 /**
 * @desc Calculating the distance between two coordinates
 * @param float $lat latitude
 * @param float $lng longitude
 */

function getDistance($lat1, $lng1, $lat2, $lng2) {
 $earthRadius = 6367000; //approximate radius of earth in meters

 /*
 Convert these degrees to radians
 to work with the formula
 */

 $lat1 = ($lat1 * pi() ) / 180;
 $lng1 = ($lng1 * pi() ) / 180;

 $lat2 = ($lat2 * pi() ) / 180;
 $lng2 = ($lng2 * pi() ) / 180;

 /*
 Using the
 Haversine formula

 http://en.wikipedia.org/wiki/Haversine_formula

 calculate the distance
 */

 $calcLongitude = $lng2 - $lng1;
 $calcLatitude = $lat2 - $lat1;
 $stepOne = pow(sin($calcLatitude / 2), 2) + cos($lat1) * cos($lat2) * pow(sin($calcLongitude / 2), 2);
 $stepTwo = 2 * asin(min(1, sqrt($stepOne)));
 $calculatedDistance = $earthRadius * $stepTwo;

 return round($calculatedDistance);
}
/**
* @desc Filtering the parking locations using given distance and specified coordinate
* @param float $latitude latitude
* @param float $longitude longitude
* @param int $distance distance given
* @param array $parkingArray all parking locations found
* @return array
*/

function filterByDistance($latitude, $longitude, $distance, $parkingArray){

  $filterdParkingArray = array();
  foreach ($parkingArray as $key => $value) {

    $dis = getDistance($latitude, $longitude, $value["latitude"], $value["longitude"]);

    if( $dis <= $distance ){

      //$value["distance"] = $dis;
      $filterdParkingArray[] = $value;
      //dump($filterdParkingArray);

    }
  }

  return $filterdParkingArray;
}
/**
* @desc Check if the parking is available now.
* @param array $parkingArray all parking locations found and filterd
*/
function checkParkingAvailability(&$parkingArray){
  $weekDay = date("w");
  if($weekDay == 0){
    $weekDay = 7;
  }
  $hour = date("H");
  $minute = date("i")/60.0;
  $time = $hour + $minute;

    foreach ($parkingArray as $key => $value) {
      $unavailableTime = $value["unavailableTime"];
      unset($parkingArray[$key]["unavailableTime"]);
      if($unavailableTime == "N"){
        $parkingArray[$key]["canParkNow"] = true;//YES
        continue;
      }
      $unavailableTimeArray = explode("&", $unavailableTime);
      $canParkNow = true;
      foreach($unavailableTimeArray as $key1 => $timePeriods){
        $weeday_time = explode(":", $timePeriods);//weekday:time  :  1-5:16-17.5

        $weekdayInterval = $weeday_time[0];
        $timeInterval = $weeday_time[1];
        $weekday_startToend = explode("-", $weekdayInterval);

        $startWeekDay = $weekday_startToend[0];
        $endWeekDay = $weekday_startToend[1];
        $time_startToend = explode("-", $timeInterval);

        $startTime = $time_startToend[0];
        $endTime = $time_startToend[1];
        if($weekDay >= $startWeekDay && $weekDay<= $endWeekDay){
          if($time >= $startTime && $time <= $endTime){
            $canParkNow = false;
            $parkingArray[$key]["canParkNow"] = false;//NO
            //$parkingArray[$key]["unavailableTime"] += ""
            break;
          }else{
            continue;
          }
        }else{
          continue;
        }

      }
      if($canParkNow){
        $parkingArray[$key]["canParkNow"] = true;//YES
      }
  }

}

function changeToBoolean($parkingType, &$parkingArray){
  if($parkingType == "onstreetparking"){
    foreach ($parkingArray as $key => $value) {
      if($value["forcharge"] == "Y"){
        $parkingArray[$key]["forcharge"] = true;
      }else{
        $parkingArray[$key]["forcharge"] = false;
      }
  }
}else{
  foreach ($parkingArray as $key => $value) {
    if($value["forcharge"] == "Y"){
      $parkingArray[$key]["forcharge"] = true;
    }else{
      $parkingArray[$key]["forcharge"] = false;
    }
    if($value["hasphoto"] == "1"){
      $parkingArray[$key]["hasphoto"] = true;
    }else{
      $parkingArray[$key]["hasphoto"] = false;
    }
}
}
}

/**
* @desc Calculate the distance between the starMarker and the parking
* @param float $starMarkerlatitude latitude of star marker
* @param float $starMarkerlongitude longitude of star marker
* @param array $parkingArray all parking locations found and filterd
*/

function calculateDistance($starMarkerlatitude, $starMarkerlongitude, &$parkingArray){
  foreach ($parkingArray as $key => $value) {
    $dis = getDistance($starMarkerlatitude, $starMarkerlongitude, $value["latitude"], $value["longitude"]);
    $parkingArray[$key]["distance"] = $dis;
  }
}
 // Get the parameter
  $distance = $_GET["distance"];
  $latitude = $_GET["latitude"];
  $longitude = $_GET["longitude"];
  $starMarkerlatitude = $_GET["starMarkerlatitude"];
  $starMarkerlongitude = $_GET["starMarkerlongitude"];

  try{

    $db = connectToDB();
    //echo $db;
    //$stm = $db->prepare('insert into user(id, name) values(:id, :name)');
    $stm = $db->prepare('select * from onstreetparking');
    $stm->execute();
    $onstreetparking = $stm->fetchAll(PDO::FETCH_ASSOC);

    //
    $fileterdOnStreetParking = filterByDistance($latitude, $longitude, $distance, $onstreetparking);
    //
    checkParkingAvailability($fileterdOnStreetParking);
    //
    changeToBoolean("onstreetparking", $fileterdOnStreetParking);
    //
    calculateDistance($starMarkerlatitude, $starMarkerlongitude, $fileterdOnStreetParking);
    //Geodecode
    //$geoDecodeUrl = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=45.41954,-75.676183&result_type=street_address&key=AIzaSyCbdAUyQGbt7Cnwl7wi7sMa0fA-Brpmy3A';
    //dump( json_decode(file_get_contents($geoDecodeUrl)) );

    $stm = $db->prepare('select * from parkinglot');
    $stm->execute();
    $parkinglot = $stm->fetchAll(PDO::FETCH_ASSOC);

    //
    $fileterdParkinglot = filterByDistance($latitude, $longitude, $distance, $parkinglot);

    //
    checkParkingAvailability($fileterdParkinglot);
    //

    changeToBoolean("parkinglot", $fileterdParkinglot);
    //
    calculateDistance($starMarkerlatitude, $starMarkerlongitude, $fileterdParkinglot);

    $returnArr = array('onstreetparking' => $fileterdOnStreetParking, 'parkinglot' => $fileterdParkinglot);
    $returnJson = json_encode($returnArr);

    echo $returnJson;
    $db = null;

  }catch(PDOException $e){
    //if errors , what to do ?
    //echo "Error!:".$e->getMessage()."<br/>";
  }
