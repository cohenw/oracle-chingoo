<%@ page language="java" 
	import="java.util.*" 
	import="spencer.genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<%
	boolean isCPAS = request.getRequestURI().contains("cpas-genie");

Connect cn = (Connect) session.getAttribute("CN");
if (cn!=null && cn.isConnected()) {
	String redirectPage = "index.jsp";
	response.sendRedirect(redirectPage);
	return;
}

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
				if (email==null || email.equals("null")) email = "";
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
	    	if (idx >0) {
	    		initUserName = token.substring(0, idx);
	    		initJdbcUrl = token.substring(idx+1);
	    	}
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
    <title>Genie</title>

	<meta name="description" content="Genie is an open-source, web based oracle database schema navigator." />
	<meta name="keywords" content="Oracle Web Database OpenSource JDBC" />
	<meta name="author" content="Spencer Hwang" />
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" /> 

    <link rel='stylesheet' type='text/css' href='css/style.css?<%= Util.getScriptionVersion() %>'> 
	<link rel="icon" type="image/png" href="image/Genie-icon.png">
    <script src="script/jquery-1.7.2.min.js" type="text/javascript"></script>
    <script type="text/javascript">
    	function setLogin(jdbcUrl, userId) {
    		$("#url").val(jdbcUrl);
    		$("#username").val(userId);
    		$("#cpasuserid").val('');
    		$('html, body').animate({scrollTop:0}, 'fast');
    	}
    	
    	function setLogin2(str) {
    		var n=str.split("#");
    		$("#username").val(n[0]);
    		$("#url").val(n[1]);
    	}
    	
    </script>
  </head>
  
  <body>
  
<div id="ienotice" style="display: none;">
<h2>Genie works best with 
<a target="_blank" href="https://www.google.com/intl/en/chrome/browser/"><img src="https://www.google.com/intl/en/chrome/assets/common/images/chrome_logo_2x.png"></a> 
or 
<a target="_blank" href="http://www.mozilla.org/en-US/firefox/new/"><img src="http://mozorg.cdn.mozilla.net/media/img/firefox/new/header-firefox.png"></a></h2>
</div>  
  
<% if (isCPAS && false) { %>
	<img src="http://www.cpas.com/images/layout_01.jpg">
<% } %>	
<% if (isCPAS) { %>

	<br/>
	<h1 style="margin-left:40px;">
    Welcome to <span style="background-color:black; color: white;">C</span><span style="background-color:#FF9900; color: white;">PAS</span> Genie.<br/>
    </h1> 
<!--     <a href="login_cpas.jsp">CPAS login (Test Environments)</a> -->
<% } else {%>	
    <h2>Welcome to Oracle Genie.</h2>
<% } %>	

	<form action="connect_new.jsp" method="POST">
    <table border=0 style="margin-left: 60px;">
    <tr>
    	<td align='right'><span style="font-size:14px; font-weight: bold;">JDBC URL</span></td>
    	<td><input style="font-size:14px;" size=60 name="url" id="url" value="<%= initJdbcUrl %>"/></td>
	    <td rowspan=5>
    		  <img src="image/genie-lamp.jpg" width="200" height="155" title="<%= Util.getVersionDate() + " Build " + Util.getBuildNo() %>"/>
		</td>
    </tr>
    <tr>
    	<td align='right'><span style="font-size:14px; font-weight: bold;">Client Schema</span></td>
    	<td><input style="font-size:14px;" name="username" id="username" value="<%= initUserName %>"/> ex) CLIENT_55</td>
    </tr>
    <tr>
    	<td align='right'><span style="font-size:14px; font-weight: bold;">CPAS User ID</span></td>
    	<td><input style="font-size:14px;" name="cpasuserid" id="cpasuserid"/>(optional)</td>
    </tr>
    <tr>
    	<td align='right'><span style="font-size:14px; font-weight: bold;">Password</span></td>
    	<td><input style="font-size:14px;" name="password" type="password"/></td>
    </tr>
<% if (isCPAS && Util.isInCpasNetwork(request)) { %>
    <tr>
    	<td align='right'><span style="font-size:14px; font-weight: bold;">Your Email</span></td>
    	<td><input style="font-size:14px;" name="email" id="email" value="<%= email %>"/>(optional) Genie will send you query logs.</td>
    </tr>
<% } %>	
    </table>
    <input type="submit" value="Connect" style="margin-left: 160px;"/>
	</form>


<% if (isCPAS) { %>
<hr width="850" align="left" color="green">
<br/>
<b style="margin-left: 20px;">CPAS Databases:</b>
<select id="dbSelect" onchange="setLogin(this.options[this.selectedIndex].value, '');">
<option></option>
<option value="jdbc:oracle:thin:@s-ora-001.cpas.com:1521/ACAW">S-ORA-001.ACAW</option>
<option value="jdbc:oracle:thin:@s-ora-001.cpas.com:1521/BMO">S-ORA-001.BMO</option>
<option value="jdbc:oracle:thin:@s-ora-001.cpas.com:1521/CIBCGIC">S-ORA-001.CIBCGIC</option>
<option value="jdbc:oracle:thin:@s-ora-001.cpas.com:1521/COGNOS">S-ORA-001.COGNOS</option>
<option value="jdbc:oracle:thin:@s-ora-001.cpas.com:1521/CQ2">S-ORA-001.CQ2</option>
<option value="jdbc:oracle:thin:@s-ora-001.cpas.com:1521/DALLAS">S-ORA-001.DALLAS</option>
<option value="jdbc:oracle:thin:@s-ora-001.cpas.com:1521/MCERA">S-ORA-001.MCERA</option>
<option value="jdbc:oracle:thin:@s-ora-001.cpas.com:1521/OE">S-ORA-001.OE</option>
<option value="jdbc:oracle:thin:@s-ora-001.cpas.com:1521/OEFREEZ2">S-ORA-001.OEFREEZ2</option>
<option value="jdbc:oracle:thin:@s-ora-001.cpas.com:1521/PSAC">S-ORA-001.PSAC</option>
<option value="jdbc:oracle:thin:@s-ora-001.cpas.com:1521/RKLARGUS">S-ORA-001.RKLARGUS</option>
<option value="jdbc:oracle:thin:@s-ora-001.cpas.com:1521/SASKATN">S-ORA-001.SASKATN</option>
<option value="jdbc:oracle:thin:@s-ora-001.cpas.com:1521/TEMPLATE">S-ORA-001.TEMPLATE</option>
<option></option>

<option value="jdbc:oracle:thin:@s-ora-002.cpas.com:1526/AIARC">S-ORA-002.AIARC</option>
<option value="jdbc:oracle:thin:@s-ora-002.cpas.com:1526/GOODYEAR">S-ORA-002.GOODYEAR</option>
<option value="jdbc:oracle:thin:@s-ora-002.cpas.com:1521/RKLDBV3">S-ORA-002.RKLDBV3</option>
<option value="jdbc:oracle:thin:@s-ora-002.cpas.com:1521/SDCDEV">S-ORA-002.SDCDEV</option>
<option value="jdbc:oracle:thin:@s-ora-002.cpas.com:1521/SDCERA">S-ORA-002.SDCERA</option>
<option value="jdbc:oracle:thin:@s-ora-002.cpas.com:1521/SSGQA">S-ORA-002.SSGQA</option>
<option value="jdbc:oracle:thin:@s-ora-002.cpas.com:1526/KCERA">S-ORA-002.KCERA</option>
<option value="jdbc:oracle:thin:@s-ora-002.cpas.com:1526/MERCED">S-ORA-002.MERCED</option>
<option></option>

<option value="jdbc:oracle:thin:@s-ora-003.cpas.com:1526/BALTIMOR">S-ORA-003.BALTIMOR</option>
<option value="jdbc:oracle:thin:@s-ora-003.cpas.com:1526/CAAT">S-ORA-003.CAAT</option>
<option value="jdbc:oracle:thin:@s-ora-003.cpas.com:1526/CAPITAL">S-ORA-003.CAPITAL</option>
<option value="jdbc:oracle:thin:@s-ora-003.cpas.com:1521/DEV10G">S-ORA-003.DEV10G</option>
<option value="jdbc:oracle:thin:@s-ora-003.cpas.com:1521/MPI">S-ORA-003.MPI</option>
<option value="jdbc:oracle:thin:@s-ora-003.cpas.com:1526/NDRIO">S-ORA-003.NDRIO</option>
<option value="jdbc:oracle:thin:@s-ora-003.cpas.com:1526/NTCA">S-ORA-003.NTCA</option>
<option value="jdbc:oracle:thin:@s-ora-003.cpas.com:1526/PAOC">S-ORA-003.PAOC</option>
<option value="jdbc:oracle:thin:@s-ora-003.cpas.com:1521/PENSCO">S-ORA-003.PENSCO</option>
<option value="jdbc:oracle:thin:@s-ora-003.cpas.com:1526/PEPP">S-ORA-003.PEPP</option>
<option value="jdbc:oracle:thin:@s-ora-003.cpas.com:1526/PMRS">S-ORA-003.PMRS</option>
<option value="jdbc:oracle:thin:@s-ora-003.cpas.com:1526/SIGMA">S-ORA-003.SIGMA</option>
<option value="jdbc:oracle:thin:@s-ora-003.cpas.com:1521/VANGUARD">S-ORA-003.VANGUARD</option>
<option value="jdbc:oracle:thin:@s-ora-003.cpas.com:1526/VCENTER">S-ORA-003.VCENTER</option>
<option value="jdbc:oracle:thin:@s-ora-003.cpas.com:1526/VUPDATE">S-ORA-003.VUPDATE</option>
<option></option>

<option value="jdbc:oracle:thin:@s-ora-004.cpas.com:1521/ACTRA">S-ORA-004.ACTRA</option>
<option value="jdbc:oracle:thin:@s-ora-004.cpas.com:1521/CCCERA">S-ORA-004.CCCERA</option>
<option value="jdbc:oracle:thin:@s-ora-004.cpas.com:1521/CQDEV">S-ORA-004.CQDEV</option>
<option value="jdbc:oracle:thin:@s-ora-004.cpas.com:1521/GENDYN">S-ORA-004.GENDYN</option>
<option value="jdbc:oracle:thin:@s-ora-004.cpas.com:1521/IBT">S-ORA-004.IBT</option>
<option value="jdbc:oracle:thin:@s-ora-004.cpas.com:1521/INTEGRA">S-ORA-004.INTEGRA</option>
<option value="jdbc:oracle:thin:@s-ora-004.cpas.com:1521/KEYSTONE">S-ORA-004.KEYSTONE</option>
<option value="jdbc:oracle:thin:@s-ora-004.cpas.com:1521/OEFROZEN">S-ORA-004.OEFROZEN</option>
<option value="jdbc:oracle:thin:@s-ora-004.cpas.com:1521/PPL">S-ORA-004.PPL</option>
<option value="jdbc:oracle:thin:@s-ora-004.cpas.com:1521/SAXON55">S-ORA-004.SAXON55</option>
<option value="jdbc:oracle:thin:@s-ora-004.cpas.com:1521/SMUCKERS">S-ORA-004.SMUCKERS</option>
<option value="jdbc:oracle:thin:@s-ora-004.cpas.com:1521/SVB">S-ORA-004.SVB</option>
<option></option>

<option value="jdbc:oracle:thin:@s-ora-005.cpas.com:1521/MERCED">S-ORA-005.MERCED</option>
<option value="jdbc:oracle:thin:@s-ora-005.cpas.com:1521/NTCA">S-ORA-005.NTCA</option>
<option value="jdbc:oracle:thin:@s-ora-005.cpas.com:1521/TAIKANG">S-ORA-005.TAIKANG</option>
<option value="jdbc:oracle:thin:@s-ora-005.cpas.com:1521/TCERADEV">S-ORA-005.TCERADEV</option>
<option value="jdbc:oracle:thin:@s-ora-005.cpas.com:1521/WYATT">S-ORA-005.WYATT</option>
<option></option>

<option value="jdbc:oracle:thin:@s-ora-006.cpas.com:1521/AFM">S-ORA-006.AFM</option>
<option value="jdbc:oracle:thin:@s-ora-006.cpas.com:1526/APA">S-ORA-006.APA</option>
<option value="jdbc:oracle:thin:@s-ora-006.cpas.com:1521/ARGUS">S-ORA-006.ARGUS</option>
<option value="jdbc:oracle:thin:@s-ora-006.cpas.com:1526/CIBC">S-ORA-006.CIBC</option>
<option value="jdbc:oracle:thin:@s-ora-006.cpas.com:1521/CIBC2">S-ORA-006.CIBC2</option>
<option value="jdbc:oracle:thin:@s-ora-006.cpas.com:1526/COR">S-ORA-006.COR</option>
<option value="jdbc:oracle:thin:@s-ora-006.cpas.com:1521/DALLAS">S-ORA-006.DALLAS</option>
<option value="jdbc:oracle:thin:@s-ora-006.cpas.com:1526/GOODYEAR">S-ORA-006.GOODYEAR</option>
<option value="jdbc:oracle:thin:@s-ora-006.cpas.com:1526/LUTHERAN">S-ORA-006.LUTHERAN</option>
<option value="jdbc:oracle:thin:@s-ora-006.cpas.com:1521/NAV">S-ORA-006.NAV</option>
<option value="jdbc:oracle:thin:@s-ora-006.cpas.com:1521/PENSCO">S-ORA-006.PENSCO</option>
<option value="jdbc:oracle:thin:@s-ora-006.cpas.com:1526/RECKEEP">S-ORA-006.RECKEEP</option>
<option value="jdbc:oracle:thin:@s-ora-006.cpas.com:1521/SAXON">S-ORA-006.SAXON</option>
<option value="jdbc:oracle:thin:@s-ora-006.cpas.com:1521/SEARSDB">S-ORA-006.SEARSDB</option>
<option value="jdbc:oracle:thin:@s-ora-006.cpas.com:1521/SEARSDC">S-ORA-006.SEARSDC</option>
<option value="jdbc:oracle:thin:@s-ora-006.cpas.com:1526/TTC">S-ORA-006.TTC</option>
<option value="jdbc:oracle:thin:@s-ora-006.cpas.com:1521/UNILEASE">S-ORA-006.UNILEASE</option>
<option></option>

<option value="jdbc:oracle:thin:@s-dev-012.cpas.com:1521/DEV102">S-DEV-012.DEV102</option>
<option value="jdbc:oracle:thin:@VS-ORATEST-001.CPAS.COM:1521/WEBDEMO">VS-ORATEST-001.WEBDEMO</option>
<option value="jdbc:oracle:thin:@w-onlinecpascom:1521/ONLINE">W-ONLINECPASCOM.ONLINE</option>
<option value="jdbc:oracle:thin:@VW-TWG-805:1521/ORCL">VW-TWG-805.ORCL</option>

</select>

<img style="margin-left: 250px;" src="image/video.png">
<a href="http://genie.cpas.com/genie-video/index.html" target=_blank><span style="background-color: yellow;">Watch tutorial videos</span></a>
<br/>


<jsp:include page="cpas-database.jsp"/>

<br/>
<!-- Are you new to Genie? Please watch the tutorial videos. <a href="file:///picard/training/">\\picard\training\CPAS Genie</a><br/><br/>
 -->
Please contact Spencer Hwang(<a href="mailto:spencerh@cpas.com">spencerh@cpas.com</a> x350) to add more database locations.
<br/>
</div>

<% } %>


<br/>
<div>

<b>Connection history:</b><br/>
<%
	int i=0;
	StringTokenizer st = new StringTokenizer(cookieUrls);
    while (st.hasMoreTokens()) {
    	String token = st.nextToken();
    	int idx = token.indexOf("@");
    	String userid = token.substring(0, idx);
    	String jdbcUrl = token.substring(idx+1);
    	if (i++ >= 20) break;
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

  $(document).ready(function () {
	  if (navigator.userAgent.indexOf("MSIE") > 0) {
		  $("#ienotice").slideDown();
	  }
  });
  
  
</script>


  </body>
</html>

<%
System.out.println("login.jsp " + Util.getIpAddress(request) + " " + (new java.util.Date()));
%>