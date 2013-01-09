<%@ page language="java" 
	import="java.util.*" 
	import="spencer.genie.*" 
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
	
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
  <head>
    <title>Genie</title>

	<meta name="description" content="Genie is an open-source, web based oracle database schema navigator." />
	<meta name="keywords" content="Oracle Web Database OpenSource JDBC" />
	<meta name="author" content="Spencer Hwang" />

    <link rel='stylesheet' type='text/css' href='css/style.css?<%= Util.getScriptionVersion() %>'> 
	<link rel="icon" type="image/png" href="image/Genie-icon.png">
    <script src="script/jquery-1.7.2.min.js" type="text/javascript"></script>
    <script type="text/javascript">
    	function setLogin(jdbcUrl, userId) {
    		$("#url").val(jdbcUrl);
    		$("#username").val(userId);
    	}
    </script>
  </head>
  
  <body>
  <img src="image/genie2.jpg" title="Version <%= Util.getVersionDate() %>"/>
    <h2>Welcome to Oracle Genie.</h2>

<b>Connect to database</b>
	<form action="connect_new.jsp" method="POST">
    <table border=0>
    <tr>
    	<td>JDBC URL</td>
    	<td><input size=60 name="url" id="url" value="<%= initJdbcUrl %>"/></td>
    </tr>
    <tr>
    	<td>User Name</td>
    	<td><input name="username" id="username" value="<%= initUserName %>"/></td>
    </tr>
    <tr>
    	<td>Password</td>
    	<td><input name="password" type="password"/></td>
    </tr>
    <tr>
    	<td>Your Email</td>
    	<td><input name="email" id="email" value="<%= email %>"/> Genie will send query logs by email.</td>
    </tr>
    </table>
    <input type="submit" value="Connect"/>
	</form>

<br/>


<div>


<%
	StringTokenizer st = new StringTokenizer(cookieUrls);
    while (st.hasMoreTokens()) {
    	String token = st.nextToken();
    	int idx = token.indexOf("@");
    	String userid = token.substring(0, idx);
    	String jdbcUrl = token.substring(idx+1);
%>
<a href="javascript:setLogin('<%= jdbcUrl %>', '<%= userid %>')"><%= token %></a>
<a href="remove-cookie.jsp?value=<%= token %>"><img border=0 src="image/clear.gif"></a>
<br/>

<%
	}
%>


<br/><hr>
<b>CPAS Databases:</b><br/><br/>
ACTRA
<li style="margin-left: 100px;"><a href="javascript:setLogin('jdbc:oracle:thin:@s-ora-004.CPAS.COM:1521/ACTRA', 'cpasdba')">cpasdba@jdbc:oracle:thin:@s-ora-004.CPAS.COM:1521/ACTRA</a></li>
<br/>

AIARC
<li style="margin-left: 100px;"><a href="javascript:setLogin('jdbc:oracle:thin:@s-ora-002.cpas.com:1521/AIARC', 'aiarc')">aiarc@jdbc:oracle:thin:@s-ora-002.cpas.com:1521/AIARC</a></li>
<br/>

APA
<li style="margin-left: 100px;"><a href="javascript:setLogin('jdbc:oracle:thin:@s-ora-006.CPAS.COM:1526/APA', 'apa_client')">apa_client@jdbc:oracle:thin:@s-ora-006.CPAS.COM:1526/APA</a></li>
<br/>

CAPITAL
<li style="margin-left: 100px;"><a href="javascript:setLogin('jdbc:oracle:thin:@s-ora-003.cpas.com:1526/CAPITAL', 'test_capital')">test_capital@jdbc:oracle:thin:@s-ora-003.cpas.com:1526/CAPITAL</a></li>
<li style="margin-left: 100px;"><a href="javascript:setLogin('jdbc:oracle:thin:@s-ora-003.cpas.com:1526/CAPITAL', 'prd_capital')">prd_capital@jdbc:oracle:thin:@s-ora-003.cpas.com:1526/CAPITAL</a></li>
<br/>

CCCERA
<li style="margin-left: 100px;"><a href="javascript:setLogin('jdbc:oracle:thin:@s-ora-004.cpas.com:1521/CCCERA', 'client_54_dev')">client_54_dev@jdbc:oracle:thin:@s-ora-004.cpas.com:1521/CCCERA</a></li>
<li style="margin-left: 100px;"><a href="javascript:setLogin('jdbc:oracle:thin:@s-ora-004.cpas.com:1521/CCCERA', 'client_54_prd')">client_54_prd@jdbc:oracle:thin:@s-ora-004.cpas.com:1521/CCCERA</a></li>
<br/>

CIBC
<li style="margin-left: 100px;"><a href="javascript:setLogin('jdbc:oracle:thin:@s-ora-003.cpas.com:1521/IMPTEST', 'cpasdba')">cpasdba@jdbc:oracle:thin:@S-ORA-003.cpas.com:1521/IMPTEST</a></li>
<br/>

COR
<li style="margin-left: 100px;"><a href="javascript:setLogin('jdbc:oracle:thin:@s-ora-006.CPAS.COM:1526/COR', 'cor_client_577')">cor_client_577@jdbc:oracle:thin:@s-ora-006.CPAS.COM:1526/COR</a></li>
<br/>

DALLAS
<li style="margin-left: 100px;"><a href="javascript:setLogin('jdbc:oracle:thin:@s-ora-001.cpas.com:1521/DALLAS', 'client_55dl')">client_55dl@jdbc:oracle:thin:@s-ora-001.cpas.com:1521/DALLAS</a></li>
<br/>

GOODYEAR
<li style="margin-left: 100px;"><a href="javascript:setLogin('jdbc:oracle:thin:@s-ora-002.cpas.com:1526/GOODYEAR', 'gy_client')">gy_client@jdbc:oracle:thin:@s-ora-002.cpas.com:1526/GOODYEAR</a></li>
<li style="margin-left: 100px;"><a href="javascript:setLogin('jdbc:oracle:thin:@s-ora-006.cpas.com:1526/GOODYEAR', 'gy_client')">gy_client@jdbc:oracle:thin:@s-ora-006.cpas.com:1526/GOODYEAR</a></li>
<br/>

KCERA
<li style="margin-left: 100px;"><a href="javascript:setLogin('jdbc:oracle:thin:@s-ora-004.cpas.com:1521/KCERA', 'client_55kcd')">client_55kcd@jdbc:oracle:thin:@s-ora-004.cpas.com:1521/KCERA</a></li>
<br/>

MCERA
<li style="margin-left: 100px;"><a href="javascript:setLogin('jdbc:oracle:thin:@s-ora-001.cpas.com:1521/MCERA', 'client_55mc')">client_55mc@jdbc:oracle:thin:@s-ora-001.cpas.com:1521/MCERA</a></li>
<br/>

PEPP
<li style="margin-left: 100px;"><a href="javascript:setLogin('jdbc:oracle:thin:@s-ora-003.cpas.com:1526/PEPP', 'test_pepp')">test_pepp@jdbc:oracle:thin:@s-ora-003.cpas.com:1526/PEPP</a></li>
<li style="margin-left: 100px;"><a href="javascript:setLogin('jdbc:oracle:thin:@s-ora-003.cpas.com:1526/PEPP', 'prd_pepp')">prd_pepp@jdbc:oracle:thin:@s-ora-003.cpas.com:1526/PEPP</a></li>
<br/>

PMRS
<li style="margin-left: 100px;"><a href="javascript:setLogin('jdbc:oracle:thin:@s-ora-003.cpas.com:1526/PMRS', 'pmrs_client')">pmrs_client@jdbc:oracle:thin:@s-ora-003.cpas.com:1526/PMRS</a></li>
<br/>

PPL
<li style="margin-left: 100px;"><a href="javascript:setLogin('jdbc:oracle:thin:@s-ora-002.cpas.com:1521/WE8MSWIN', 'client_54')">client_54@jdbc:oracle:thin:@s-ora-002.cpas.com:1521/WE8MSWIN</a></li>
<br/>

RKLARGUS
<li style="margin-left: 100px;"><a href="javascript:setLogin('jdbc:oracle:thin:@s-ora-001.cpas.com:1521/RKLARGUS', 'client_55')">client_55@jdbc:oracle:thin:@s-ora-001.cpas.com:1521/RKLARGUS</a></li>
<li style="margin-left: 100px;"><a href="javascript:setLogin('jdbc:oracle:thin:@s-ora-001.cpas.com:1521/RKLARGUS', 'client_55_sit')">client_55_sit@jdbc:oracle:thin:@s-ora-001.cpas.com:1521/RKLARGUS</a></li>
<br/>


<br/>
Please conract Spencer Hwang(<a href="mailto:spencerh@cpas.com">spencerh@cpas.com</a>) to add more database locations.

</div>

<br/><br/><br/><br/><br/>
  </body>
</html>
