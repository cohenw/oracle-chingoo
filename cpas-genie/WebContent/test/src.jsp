<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	import="org.apache.commons.lang3.StringEscapeUtils" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>


<%
%>
<html>
<head>
	<title>Source</title>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" /> 

	<script src="../script/jquery-1.7.2.min.js" type="text/javascript"></script>
	<script src="../script/main.js?<%= Util.getScriptionVersion() %>" type="text/javascript"></script>
    <link href='../css/shCore.css' rel='stylesheet' type='text/css' > 
    <link href="../css/shThemeDefault.css" rel="stylesheet" type="text/css" />
    <link href="../css/style.css?<%= Util.getScriptionVersion() %>" rel="stylesheet" type="text/css" />
	<link rel="icon" type="../image/png" href="image/Genie-icon.png">

  <style>
  p { margin: 8px; font-size:16px; }
  .selected { color:blue; }
  .highlight { background:yellow; }
  </style>
  
<script type="text/javascript">
function hi_on(v) {
	$("." + v).addClass("highlight");
}
function hi_off(v) {
	$("." + v).removeClass("highlight");
}
</script>
</head>
<body>

<span class="abc" onmouseover="hi_on('abc')" onmouseout="hi_off('abc')">abc</span> xxx xxx xxxx xxx xxx 
<span class="abc" onmouseover="hi_on('abc')" onmouseout="hi_off('abc')">abc</span>  ;lk;lk ;lk;l  
<span class="abc" onmouseover="hi_on('abc')" onmouseout="hi_off('abc')">abc</span> dsf dsfsfsdfsdfdsf


<a href="Javascript:abc_on()">on</a>
<a href="Javascript:abc_off()">off</a>

</body>
</html>

