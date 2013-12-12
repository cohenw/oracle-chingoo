<%@ page language="java" 
	import="java.util.*" 
	import="chingoo.oracle.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<%
	session.removeAttribute("CN");

	String cookieName = "url";
	String email = "";
	Cookie cookies [] = request.getCookies ();
	Cookie myCookie = null;
	if (cookies != null) {
		for (int i = 0; i < cookies.length; i++) {
			if (cookies [i].getName().equals (cookieName)) {
				myCookie = cookies[i];
				break;
			}
		}	
		for (int i = 0; i < cookies.length; i++) {
			if (cookies [i].getName().equals ("email")) {
				email = cookies[i].getValue();
				break;
			}
		}	
	}
	
	String cookieUrls = "";
	if (myCookie != null) cookieUrls = myCookie.getValue();
	
	// default login info
	String initJdbcUrl = "jdbc:oracle:thin:@localhost:1521/SID";
	String initUserName = "userid";
	
	// get the last login from cookie
	if (cookieUrls != null && cookieUrls.length()>1) {
		StringTokenizer st = new StringTokenizer(cookieUrls);
	    if (st.hasMoreTokens()) {
	    	String token = st.nextToken();
	    	int idx = token.indexOf("@");
	    	initUserName = token.substring(0, idx);
	    	initJdbcUrl = token.substring(idx+1);
	    }
	}


	String jdbcurl = request.getParameter("jdbcurl");
	String schema = request.getParameter("schema");
	if (jdbcurl != null ) initJdbcUrl = jdbcurl;
	if (schema != null) initUserName = schema;
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
  <head>
    <title>Chingoo</title>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" /> 

	<meta name="description" content="Chingoo is an open-source, web based oracle database schema navigator." />
	<meta name="keywords" content="Oracle Web Database OpenSource JDBC" />
	<meta name="author" content="Spencer Hwang" />

    <link rel='stylesheet' type='text/css' href='css/style.css?<%= Util.getScriptionVersion() %>'> 
	<link rel="icon" type="image/png" href="image/chingoo-icon.png">
    <script src="script/jquery-1.7.2.min.js" type="text/javascript"></script>
    <script type="text/javascript">
    	function setLogin(jdbcUrl, userId) {
    		$("#url").val(jdbcUrl);
    		$("#username").val(userId);
    	}
    	
    	function setLogin2(str) {
    		var n=str.split("#");
    		$("#username").val(n[0]);
    		$("#url").val(n[1]);
    	}
    	
    </script>
  </head>
  
<body>
    <h1>Oracle Chingoo<%--  - Build <%= Util.getBuildNo() %> --%></h1>

<table>
<td>
<img src="image/chingoo.png" title="<%= Util.getVersionDate() + " Build" + Util.getBuildNo() %>" width=128 height=128 />
</td>
<td>
<form action="connect_new.jsp" method="POST">


    <table border=0>
    <tr>
    	<td><span style="font-size:16px; color: blue;">JDBC URL</span></td>
    	<td><input style="font-size:16px;" size=60 name="url" id="url" value="<%= initJdbcUrl %>"/></td>
    </tr>
    <tr>
    	<td><span style="font-size:16px; color: blue;">User Name</span></td>
    	<td><input style="font-size:16px;" name="username" id="username" value="<%= initUserName %>"/></td>
    </tr>
    <tr>
    	<td><span style="font-size:16px; color: blue;">Password</span></td>
    	<td><input style="font-size:16px;" name="password" type="password"/></td>
    </tr>
    </table>
    <input type="submit" value="Connect"/>
	</form>
</td>
</table>
   
   

<br/>


<br/>
<div>

<b>Connection history:</b><br/>
<%
	StringTokenizer st = new StringTokenizer(cookieUrls);
    while (st.hasMoreTokens()) {
    	String token = st.nextToken();
    	int idx = token.indexOf("@");
    	String userid = token.substring(0, idx);
    	String jdbcUrl = token.substring(idx+1);
%>
<a style="margin-left: 20px;" href="javascript:setLogin('<%= jdbcUrl %>', '<%= userid %>')"><%= token %></a>
<a href="remove-cookie.jsp?value=<%= token %>"><img border=0 src="image/clear.gif"></a>
<br/>

<%
	}
%>
</div>

<br/><br/><br/>

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


  </body>
</html>

<%
System.out.println("login.jsp " + Util.getIpAddress(request) + " " + (new java.util.Date()));
%>