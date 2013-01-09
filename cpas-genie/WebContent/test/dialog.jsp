<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Insert title here</title>
    <script src="../script/jquery.js" type="text/javascript"></script>

    <link rel='stylesheet' type='text/css' href='../css/style.css'>

			<link rel="stylesheet" href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.18/themes/base/jquery-ui.css" type="text/css" media="all" />
			<script src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.18/jquery-ui.min.js" type="text/javascript"></script>
	
	<script>
	$(function() {
		$( "#dialog" ).dialog();
	});
	
	function showme() {
		$( "#dialog2" ).dialog({ width: 600, height: 100 });
	}
	</script>



</head>
<body>




<div class="demo">

<div id="dialog" title="SELECT * FROM MEMBER WHERE MKEY='12345'">
<table border=1>
<tr>
	<td>Col 1</td>
	<td>Col 2</td>
	<td>Col 3</td>
	<td>Col 4</td>
	<td>Col 5</td>
</tr>
<tr>
	<td>Value 1</td>
	<td>Value 2</td>
	<td>Value 3</td>
	<td>Value 4</td>
	<td>Value 5</td>
</tr>
</table>
</div>


<div id="dialog2" title="Hidden Dialog">
<table border=1>
<tr>
	<td>Col 1</td>
	<td>Col 2</td>
	<td>Col 3</td>
	<td>Col 4</td>
	<td>Col 5</td>
</tr>
<tr>
	<td>Value 1</td>
	<td>Value 2</td>
	<td>Value 3</td>
	<td>Value 4</td>
	<td>Value 5</td>
</tr>
</table>
</div>


<!-- Sample page content to illustrate the layering of the dialog -->
<div class="hiddenInViewSource" style="padding:20px;">
<p>Sed vel diam id libero <a href="http://example.com">rutrum convallis</a>. Donec aliquet leo vel magna. Phasellus rhoncus faucibus ante. Etiam bibendum, enim faucibus aliquet rhoncus, arcu felis ultricies neque, sit amet auctor elit eros a lectus.</p>
<form>
	<input value="text input" /><br />
	<input type="checkbox" />checkbox<br />
	<input type="radio" />radio<br />
	<select>
		<option>select</option>
	</select><br /><br />
	<textarea>textarea</textarea><br />
</form>
</div><!-- End sample page content -->

</div><!-- End demo -->



<div class="demo-description">
<p>The basic dialog window is an overlay positioned within the viewport and is protected from page content (like select elements) shining through with an iframe.  It has a title bar and a content area, and can be moved, resized and closed with the 'x' icon by default.</p>
</div><!-- End demo-description -->


<a href="Javascript:showme()">Show me the dialog 2</a>


</body>
</html>