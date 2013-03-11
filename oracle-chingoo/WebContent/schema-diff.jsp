<%@ page language="java" 
	import="java.util.*" 
	import="chingoo.oracle.*" 
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
	
		cn2 = new Connect(session, url, username, password, Util.getIpAddress(request), false);	
	
		connected = cn2.isConnected();

		System.out.println("Schema 2 connected=" + connected);
		if (connected) {
			session.setAttribute("CN2", cn2);
		}
	}
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
  <head>
    <title>Schema Diff - Chingoo</title>
    <link rel='stylesheet' type='text/css' href='css/style.css?<%= Util.getScriptionVersion() %>'> 
    <link rel='stylesheet' type='text/css' href='css/slideshow.css?<%= Util.getScriptionVersion() %>'> 
	<link rel="icon" type="image/png" href="image/chingoo-icon.png">

<script src="script/jquery-1.7.2.min.js" type="text/javascript"></script>
<script src="script/jquery-ui-1.8.18.custom.min.js"
	type="text/javascript"></script>
<script src="script/chingoo.js?<%=Util.getScriptionVersion()%>"
	type="text/javascript"></script>

<link rel="icon" type="image/png" href="image/chingoo-icon.png">
<link rel="stylesheet" href="css/ui-lightness/jquery-ui-1.8.18.custom.css" type="text/css"/>
<link rel='stylesheet' type='text/css' 	href='css/style.css?<%=Util.getScriptionVersion()%>'>
    
    <script type="text/javascript">
    var to2;
    
    $(function() {
        $( "#ctabs" ).tabs();
    });
    
    function startCompareRoutine() {
    	$("#comparisonProgress").html("");
    	
    	checkProgress();
    	$("#comparisonResult").html("Comparing...");
		$("#comparisonResult").append("<div id='wait'><img src='image/loading.gif'/></div>");

		$.ajax({
			type: 'POST',
			url: "ajax/compare-behind.jsp",
			data: $("#form0").serialize(),
			success: function(data){
				$("#comparisonResult").html(data);
				$("#wait").remove();
				checkProgress();
				setReady();
			},
            error:function (jqXHR, textStatus, errorThrown){
            	alert(jqXHR.status + " " + errorThrown);
            }  
		});	
    	
    }    
    
    function checkProgress() {
    	clearTimeout(to2);
    	var current = $("#comparisonProgress").html();
		$.ajax({
			type: 'POST',
			url: "ajax/compare-progress.jsp",
			success: function(data){
				if (current != data) {
	    			$("#comparisonProgress").html(data);
				}
				
				if (data.indexOf("Finished") >= 0)
					clearTimeout(to2);
				else
					to2 = setTimeout("checkProgress()",1000);
			},
            error:function (jqXHR, textStatus, errorThrown){
            	alert(jqXHR.status + " " + errorThrown);
            }  
		});	    	
    }
    
    function startCompare() {
    	$("#startButton").attr("disabled", true);
    	$("#stopButton").attr("disabled", false);
    	startCompareRoutine();
    }
    
    function stopCompare() {
    	
    	clearTimeout(to2);
		$.ajax({
			type: 'POST',
			url: "ajax/cancel-compare.jsp",
			data: $("#form0").serialize(),
			success: function(data){
		    	setReady();
			},
            error:function (jqXHR, textStatus, errorThrown){
            	alert(jqXHR.status + " " + errorThrown);
            }  
		});	    	

    }
    
    function setReady() {
    	$("#startButton").attr("disabled", false);
    	$("#stopButton").attr("disabled", true);
    }
    
    function showDivA() {
    	$("#divA").show();
    	$("#divB").hide();
    }

    function showDivB() {
    	$("#divB").show();
    	$("#divA").hide();
    }

    function setReady2() {
    	$("#startButton2").attr("disabled", false);
    	$("#stopButton2").attr("disabled", true);
    }
    
    function startCompare2() {
    	$("#startButton2").attr("disabled", true);
    	$("#stopButton2").attr("disabled", false);
    	startCompareRoutine2();
    }
    
    function stopCompare2() {
    	
    	clearTimeout(to2);
		$.ajax({
			type: 'POST',
			url: "ajax/cancel-compare.jsp",
			data: $("#form0").serialize(),
			success: function(data){
		    	setReady2();
			},
            error:function (jqXHR, textStatus, errorThrown){
            	alert(jqXHR.status + " " + errorThrown);
            }  
		});	    	

    }    
    
    function startCompareRoutine2() {
    	$("#comparisonResult").html("Comparing...");
		$("#comparisonResult").append("<div id='wait'><img src='image/loading.gif'/></div>");

		$.ajax({
			type: 'POST',
			url: "ajax/compare-behind.jsp",
			data: $("#form2").serialize(),
			success: function(data){
				$("#comparisonResult").html(data);
				$("#wait").remove();
				setReady2();
			},
            error:function (jqXHR, textStatus, errorThrown){
            	alert(jqXHR.status + " " + errorThrown);
            }  
		});	
    	
    }      
    </script>
  </head>
  
<body>

<%
	if (!connected) {
%>
	<b>Sorry, Chingoo could not connect to the database.</b><br/>
	Message: <%= cn.getMessage() %>
	<br/><br/>
	<br/><br/>
	<a href="Javascript:window.close()">Close</a>
<%	
		return;
	}
%>

<h2><img src="image/diff.jpg" align="bottom"/> Schema Diff</h2>

<b>
Schema 1: <%= cn.getUrlString() %>
<br/>
Schema 2: <%= cn2.getUrlString() %> <a href="logout-schema2.jsp">Logout</a>
</b><br/><br/>

<div id="ctabs">
    <ul>
		<li><a href="#tabs1">Compare Schema</a></li>
		<li><a href="#tabs2">Compare Query Result</a></li>
    </ul>
<div id="tabs1">

<form name="form0" id="form0">
<table style="margin-left: 40px;">
<tr>
	<td>Object</td>
	<td>
		<input name="object" type="radio" value="T" checked>Table
		<input name="object" type="radio" value="V">View
<!-- 		<input name="object" type="radio" value="S">Synonym
 -->		<input name="object" type="radio" value="TR">Trigger 
		<input name="object" type="radio" value="P">Program (Package, Procedure, Function &amp; Type) 
	</td>
</tr>
<tr>
	<td>Include</td>
	<td>
		<input name="incl">
	</td>
</tr>
<tr>
	<td>Exclude</td>
	<td>
		<input name="excl">
	</td>
</tr>
<tr>
	<td colspan=2>
		<input id="startButton" type="button" value="Start Compare" onClick="javascript:startCompare()">
		<input id="stopButton" type="button" value="Stop" disabled="true"  onClick="javascript:stopCompare()">
	</td>
</tr>
</table>
</form>

<br/>
<div id="progressDiv" style="margin-left: 40px; border: 1px solid #D9D9D9; width: 400px; height: 200px; overflow: auto;">
	<div id="comparisonProgress"></div>
</div>

</div>
<div id="tabs2">

<form name="form1" id="form2">
<table style="margin-left: 40px;">
<tr>
	<td>Query statement<br/>
		<input name="object" type="hidden" value="S">
		<textarea id="text_sql" name="text_sql" rows=5 cols=60>select * from tab order by 1</textarea>
	</td>
</tr>
<tr>
	<td colspan=2>
		<input id="startButton2" type="button" value="Start Compare" onClick="javascript:startCompare2()">
		<input id="stopButton2" type="button" value="Stop" disabled="true"  onClick="javascript:stopCompare2()">
	</td>
</tr>
</table>
</form>

</div>
</div>    
<br/><br/>

<div id="comparisonResult">
</div>



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
