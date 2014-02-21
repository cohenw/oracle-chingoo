<%@ page language="java" 
	import="java.util.*" 
	import="spencer.genie.*" 
	import="java.sql.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"	
%>

<%

	Connect cn = (Connect) session.getAttribute("CN");
	// if connected, redirect to home
	if (cn==null || !cn.isConnected()) {
		response.sendRedirect("login.jsp");
		return;
	}

	Connect cn2 = (Connect) session.getAttribute("CN2");
	boolean connected = false;
	
	if (cn2 != null) {
		connected = cn2.isConnected();
		System.out.println("Schema 2 already estabilished. connected=" + connected);
	}
	if (cn2 == null) {
	
		String url = request.getParameter("url");
		String username = request.getParameter("username");
		String password = request.getParameter("password");
	
		cn2 = new Connect(session, url, username, password, Util.getIpAddress(request), false, null);	
	
		connected = cn2.isConnected();

		System.out.println("Schema 2 connected=" + connected);
		if (connected) {
			session.setAttribute("CN2", cn2);
		}
	}
	
	String clnt1="XXXX1";
	String mkey1="YYYYY1";

	String clnt2="XXXX2";
	String mkey2="YYYYY2";
	
	String q = "SELECT CLNT, MKEY FROM CALC WHERE CALCID=(SELECT MAX(CALCID) FROM CALC)";
	List<String[]> lst = cn.query(q);
	
	if (lst.size()>0) {
		clnt1 = lst.get(0)[1];
		mkey1 = lst.get(0)[2];
	}

	Connection conn = cn2.getConnection();
	try {
		Statement stmt = conn.createStatement();
		
		ResultSet rs = stmt.executeQuery(q);
		if (rs.next()) {
			clnt2 = rs.getString(1);
			mkey2 = rs.getString(2);
		}
		
		rs.close();
		stmt.close();

	} catch (SQLException e) {
		System.out.println(e.toString());
	}
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
  <head>
    <title>Clone Member (External DB) - Genie</title>
    <link rel='stylesheet' type='text/css' href='css/style.css?<%= Util.getScriptionVersion() %>'> 
    <link rel='stylesheet' type='text/css' href='css/slideshow.css?<%= Util.getScriptionVersion() %>'> 
	<link rel="icon" type="image/png" href="image/Genie-icon.png">

<script src="script/jquery-1.7.2.min.js" type="text/javascript"></script>
<script src="script/jquery-ui-1.8.18.custom.min.js"
	type="text/javascript"></script>
<script src="script/genie.js?<%=Util.getScriptionVersion()%>"
	type="text/javascript"></script>

<link rel="icon" type="image/png" href="image/Genie-icon.png">
<link rel="stylesheet" href="css/ui-lightness/jquery-ui-1.8.18.custom.css" type="text/css"/>
<link rel='stylesheet' type='text/css' 	href='css/style.css?<%=Util.getScriptionVersion()%>'>
    
<script type="text/javascript">

function changeDirection() {
	var img = $("#imgDirection").attr("src");
	
	if (img.indexOf("left")>0) {
		$("#imgDirection").attr("src","image/blue_arrow_right.png");
		$("#divDB1").show();
		$("#divDB2").hide();
	} else {
		$("#imgDirection").attr("src","image/blue_arrow_left.png");	
		$("#divDB2").show();
		$("#divDB1").hide();
	}
	//alert(img);
}

function cloneMember2() {
	$("#divProgress").html("<img src='image/waiting_big.gif'>");

	var clnt2 = $("#clnt2").val();
	var mkey2 = $("#mkey2").val();
	var newmkey2 = $("#newmkey2").val();
	
	// AJAX load
	$.ajax({
		url: "ajax/clone-member-ext-job2.jsp?clnt=" + clnt2 + "&mkey=" + mkey2 + "&newmkey=" + newmkey2 +"&t=" + (new Date().getTime()),
		success: function(data){
			$("#divProgress").html(data);
		},
        error:function (jqXHR, textStatus, errorThrown){
            alert(jqXHR.status + " " + errorThrown);
        }  
	});	
}

function cloneMember1() {
	$("#divProgress").html("<img src='image/waiting_big.gif'>");

	var clnt1 = $("#clnt1").val();
	var mkey1 = $("#mkey1").val();
	var newmkey1 = $("#newmkey1").val();
	
	// AJAX load
	$.ajax({
		url: "ajax/clone-member-ext-job1.jsp?clnt=" + clnt1 + "&mkey=" + mkey1 + "&newmkey=" + newmkey1 +"&t=" + (new Date().getTime()),
		success: function(data){
			$("#divProgress").html(data);
		},
        error:function (jqXHR, textStatus, errorThrown){
            alert(jqXHR.status + " " + errorThrown);
        }  
	});	
}

function getMemberScript1() {
	var clnt = $("#clnt1").val();
	var mkey = $("#mkey1").val();
	var eid = clnt + "_" + mkey;
	var fname = "C" + clnt + "_M" + mkey + ".member";
	
	$("#eid1").val(eid);
	$("#fname1").val(fname);
	$("#form_down1").submit();	
}

function getMemberScript2() {
	var clnt = $("#clnt2").val();
	var mkey = $("#mkey2").val();
	var eid = clnt + "_" + mkey;
	var fname = "C" + clnt + "_M" + mkey + ".member";
	
	$("#eid2").val(eid);
	$("#fname2").val(fname);
	$("#form_down2").submit();	
}

</script>


  </head>
  
<body>


<%
	if (!connected) {
%>
	<b>Sorry, Genie could not connect to the database.</b><br/>
	Message: <%= cn.getMessage() %>
	<br/><br/>
	<br/><br/>
	<a href="Javascript:window.close()">Close</a>
<%	
		return;
	}
%>

<div style="background-color: #E6F8E0; padding: 6px; border:1px solid #CCCCCC; border-radius:10px;">
<img src="image/diff.jpg" width=20 height=20 align="top"/>
<span style="color: blue; font-family: Arial; font-size:16px; font-weight:bold;">Clone Member (External DB)</span>
&nbsp;&nbsp;&nbsp;
<b><%= cn.getUrlString() %></b>
&nbsp;&nbsp;&nbsp;
<a href="index.jsp" target="_blank">Home</a> |
<a href="query.jsp" target="_blank">Query</a> |
</div>

<br/>


<table border=1 cellpadding=5>
<td valign=top width=400>

<h3>DB 1: <%= cn.getUrlString() %></h3><br/>

<div id="divDB1" style="display:none;">
<form>
<b>CLNT</b> <input name="clnt1" id="clnt1" value="<%= clnt1 %>" size=4>
<b>MKEY</b> <input name="mkey1" id="mkey1" value="<%= mkey1 %>" size=10>
<input id="down_button1" type="button" value="Download Script" onClick="getMemberScript1()">

<br/><br/>
<b>NEW MKEY</b> <input name="newmkey1" id="newmkey1" value="<%= mkey1 %>"size=10>
<input type="button" value="Clone Member (Push)" onClick="cloneMember1()">
</form>
</div>

</td>
<td valign=top>
<a href="Javascript:changeDirection()"><img id="imgDirection" src="image/blue_arrow_left.png"></a>
</td>
<td valign=top width=400>
<h3>DB 2: <%= cn2.getUrlString() %></h3><br/>

<div id="divDB2">
<form>
<b>CLNT</b> <input name="clnt2" id="clnt2" value="<%= clnt2 %>" size=4>
<b>MKEY</b> <input name="mkey2" id="mkey2" value="<%= mkey2 %>" size=10>
<input id="down_button2" type="button" value="Download Script" onClick="getMemberScript2()">
<br/><br/>
<b>NEW MKEY</b> <input name="newmkey2" id="newmkey2" value="<%= mkey2 %>"size=10>
<input type="button" value="Clone Member (Pull)" onClick="cloneMember2()">
</form>
</div>

</td>
</table>

<br/>
<div id="divProgress"></div>

<br/><br/><br/><br/>
<a href="logout-schema2.jsp">Logout DB2</a>
</b><br/><br/>


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


<form id="form_down1" target="_blank" action="cpas-extract.jsp">
<input name="id" id="eid1" type="hidden">
<input name="fname" id="fname1" type="hidden">
<input name="type" value="MEMBER" type="hidden">
</form>
	
<form id="form_down2" target="_blank" action="cpas-extract2.jsp">
<input name="id" id="eid2" type="hidden">
<input name="fname" id="fname2" type="hidden">
<input name="type" value="MEMBER" type="hidden">
</form>

</body>
</html>

