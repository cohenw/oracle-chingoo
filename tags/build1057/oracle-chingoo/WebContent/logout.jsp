<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="chingoo.oracle.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>
<%
	Connect cn = (Connect) session.getAttribute("CN");
	if (cn!=null) {
		try {
			cn.disconnect();
		} catch (Exception e) {}
	}
	
	session.removeAttribute("CN");
%>

<html>
  <head>
    <title>Chingoo</title>
    <link rel='stylesheet' type='text/css' href='css/style.css?<%= Util.getScriptionVersion() %>'> 
	<link rel="icon" type="image/png" href="image/chingoo-icon.png">
  </head>

 <img src="image/chingoo.png"/>

<h2>Disconnected. Good Bye!</h2>

<br/>
<a href="index.jsp">Home</a>

<script type="text/javascript">

  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', '<%= Util.trackingId() %>']);
  _gaq.push(['_setDomainName', 'none']);
  _gaq.push(['_trackPageview']);

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();

</script>

</html>