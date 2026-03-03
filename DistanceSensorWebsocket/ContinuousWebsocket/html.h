/*
  ESP32 HTML WebServer Page Code
  http:://www.electronicwings.com
*/

const char html_page[] PROGMEM = R"RawString(
<!DOCTYPE html>
<html>
  <style>
    body {font-family: sans-serif;}
    h1 {text-align: center; font-size: 30px;}
    p {text-align: center; color: #4CAF50; font-size: 40px;}
  </style>

<body>
  <h1>VL53L0X Time of Flight Distance Measurement</h1><br>
  <p>Distance in CM : <span id="_CM">0</span> mm</p>

<script>
  setInterval(function() {
    var xhttp = new XMLHttpRequest();
    xhttp.onreadystatechange = function() {
      if (this.readyState == 4 && this.status == 200) {
        const text = this.responseText;
        const myArr = JSON.parse(text);
       document.getElementById("_CM").innerHTML = myArr[0];
      }
    };
    xhttp.open("GET", "readDistance", true);
    xhttp.send();
  },50);
</script>
</body>
</html>
)RawString";