<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>
<%
	Connect cn = (Connect) session.getAttribute("CN");

	String type = request.getParameter("type");
	String key = request.getParameter("key").toUpperCase();

	if (type.equals("OBJECT")) {
		type = cn.getObjectType(key);
	}
	
	System.out.println("type=" + type);
%>

<html>
<head> 
	<title><%= key %></title>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" /> 

	<script src="script/jquery-1.7.2.min.js" type="text/javascript"></script>
	<script src="script/jquery-ui-1.8.18.custom.min.js" type="text/javascript"></script>
    <script src="script/genie.js?<%= Util.getScriptionVersion() %>" type="text/javascript"></script>

	<link rel="stylesheet" href="css/ui-lightness/jquery-ui-1.8.18.custom.css" type="text/css"/>
    <link rel='stylesheet' type='text/css' href='css/style.css?<%= Util.getScriptionVersion() %>'> 

    <link href='css/shCore.css' rel='stylesheet' type='text/css' > 
    <link href="css/shThemeDefault.css" rel="stylesheet" type="text/css" />
	<script type="text/javascript" src="script/shCore.js"></script>
	<script type="text/javascript" src="script/shBrushSql.js"></script>

    <link rel='stylesheet' type='text/css' href='css/style.css?<%= Util.getScriptionVersion() %>'>
	<link rel="icon" type="image/png" href="image/Genie-icon.png">

	<style>
	.ui-autocomplete-loading { background: white url('image/ui-anim_basic_16x16.gif') right center no-repeat; }
.ui-autocomplete {
		max-height: 500px;
		overflow-y: auto;
		/* prevent horizontal scrollbar */
		overflow-x: hidden;
		/* add padding to account for vertical scrollbar */
		padding-right: 20px;
	}
	/* IE 6 doesn't support max-height
	 * we use height instead, but this forces the menu to always be this tall
	 */
	* html .ui-autocomplete {
		height: 500px;
	}	
	</style>
	    
<script type="text/javascript">
var CATALOG="";
var to;
var to2;
var stack = [];
var stackFwd = [];

function saveForNavigation() {
	var current = $("#inner-result1").html();
	stack.push(current);
	
	stackFwd = [];
//	console.log(stackFwd.length);
	showNavButton();
}

function goBack() {
	if (stack.length>0) {
		var current = $("#inner-result1").html();
		var data = stack.pop();
		$("#inner-result1").html(data);
		stackFwd.push(current);
		showNavButton();
	   	setTitle();
	}
}

function goFoward() {
	if (stackFwd.length>0) {
		var current = $("#inner-result1").html();
		var data = stackFwd.pop();
		$("#inner-result1").html(data);
		stack.push(current);
		showNavButton();
	   	setTitle();
	}
}

function showNavButton() {
	if (stack.length > 1 )
		$("#imgBackward").show();
	else
		$("#imgBackward").hide();

	if (stackFwd.length > 0 )
		$("#imgForward").show();
	else
		$("#imgForward").hide();
}

$(document).ready(function() {
<% if (type.equals("TABLE")) { %>
	loadTable('<%= key %>');
<% } %>
<% if (type.equals("VIEW")) { %>
	loadView('<%= key %>');
<% } %>
<% if (type.equals("PACKAGE")) { %>
	loadPackage('<%= key %>');
<% } %>


})

</script>
</head> 

<body>

<img align=top src="image/lamp.png" alt="Ver. <%= Util.getVersionDate() %>"/>
<b><%= cn.getUrlString() %></b>
&nbsp;&nbsp;&nbsp;&nbsp;

<a href="query.jsp" target="_blank">Query</a>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
Search <input id="globalSearch" style="width: 200px;"/>

<div id="outer-result1-div">
	<div id="inner-nav">
		<a href="Javascript:goBack()"><img id="imgBackward" src="image/blue_arrow_left.png" title="back" border="0" style="display:none;"></a>
		&nbsp;&nbsp;
		<a href="Javascript:goFoward()"><img id="imgForward" src="image/blue_arrow_right.png" title="forward" border="0" style="display:none;"></a>
	</div>
	<div id="inner-result1"><img src='image/loading.gif'/></div>
</div>


<form id="FORM_query" name="FORM_query" action="query.jsp" target="_blank" method="post">
<input id="sql" name="sql" type="hidden"/>
<input name="norun" type="hidden" value="YES"/>
</form>

<form id="FormPop" name="FormPop" target="_blank" method="post" action="pop.jsp">
<input id="popType" name="type" type="hidden" value="OBJECT">
<input id="popKey" name="key" type="hidden">
</form>

<form id="FormLink" name="FormLink" method="post" action="pop.jsp">
<input id="linkType" name="type" type="hidden" value="">
<input id="linkKey" name="key" type="hidden">
</form>

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

	$(function() {
		$( "#globalSearch" ).autocomplete({
			source: "ajax/auto-complete2.jsp",
			minLength: 2,
			select: function( event, ui ) {
				popObject( ui.item ?
					ui.item.value: "" );
			}
		}).data( "autocomplete" )._renderItem = function( ul, item ) {
			return $( "<li></li>" )
			.data( "item.autocomplete", item )
			.append( "<a>" + item.label + " <span class='rowcountstyle'>" + item.desc + "</span></a>" )
			.appendTo( ul );
		};
	});	
	
	function popObject(oname) {
//		alert(oname);
		$("#popKey").val(oname);
    	$("#FormPop").submit();
	}
	
</script>


</body>
</html>