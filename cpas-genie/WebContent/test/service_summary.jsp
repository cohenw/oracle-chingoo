<html>
<head>

<style>
.graph {
    width: 50px;
    height: 50px;
    border: 1px solid #aeaeae;
    background-color: #eaeaea;
}
.bar {
    width: 8px;
    margin: 1px;
    display: inline-block;
    position: relative;
    background-color: #aeaeae;
    vertical-align: baseline;
}

.service {
    width: 900px;
    height: 200px;
    border: 1px solid #aeaeae;
    background-color: #ffffcc;
}


.active {
    height: 10px;
    margin: 1px;
    display: inline-block;
    position: relative;
    background-color: #009900;
    vertical-align: baseline;
}
</style>
</head>
<body>
<h2>Service Summary Demo</h2>
<!-- 
<div class="graph">
        <div style="height: 22px;" class="bar"></div>
       <div style="height: 11px;" class="bar"></div>
       <div style="height: 6px;" class="bar"></div>
       <div style="height: 49px;" class="bar"></div>
       <div style="height: 28px;" class="bar"></div>
</div>

 -->
 
<!-- 
	<div style="height: 20px;"></div>
	<div style="width: 122px;" class="active"> </div>AC:1991-08-29  RT:1994-12-06<br/>

	<div style="height: 20px;"></div>
	<div style="width: 222px; margin-left:122px;" class="active"> </div><br/>

	<div style="height: 20px;"></div>
	<div style="width: 322px; margin-left:422px;" class="active"> </div>

<br/><br/>
 -->
<h2>SVG</h2>

<svg width="800" height="200">
  <rect width="800" height="200" style="fill:rgb(255,255,255);stroke-width:1;stroke:rgb(0,0,0)" />

  <rect x="50" y="48" width="200" height="5" style="fill:rgb(255,0,0);stroke-width:1;stroke:rgb(0,0,0)" />
  <circle cx="50" cy="50" r="8" stroke="black" stroke-width="1" fill="red" />
  <circle cx="250" cy="50" r="8" stroke="black" stroke-width="1" fill="black" />
  <text x="10" y="55" fill="blue">065</text>
  <text x="50" y="35" fill="black" style="font-size: 12px;">AC 1991-08-31</text>
  <text x="250" y="35" fill="black" style="font-size: 12px;">TR 1994-12-06</text>



  <rect x="250" y="80" width="200" height="20" style="fill:rgb(255,255,0);stroke-width:1;stroke:rgb(0,0,0)" />
  <circle cx="250" cy="90" r="10" stroke="black" stroke-width="1" fill="yellow" />
  <circle cx="450" cy="90" r="10" stroke="black" stroke-width="1" fill="black" />
  <text x="10" y="90" fill="blue">123</text>
  <text x="250" y="75" fill="black" style="font-size: 12px;">AC 1994-12-06</text>
  <text x="450" y="75" fill="black" style="font-size: 12px;">TR 1997-08-22</text>
  
  
</svg>

</body>
</html>