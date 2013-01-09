<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<%
	boolean isCPAS = request.getRequestURI().contains("cpas-genie");
	Connect cn = (Connect) session.getAttribute("CN");

	String title = "Genie " + cn.getUrlString();
	String addedHistory = cn.getAddedHistory();
%>

<html>
<head> 
	<title><%= title %></title>

	<meta name="description" content="Genie is an open-source, web based oracle database schema navigator." />
	<meta name="keywords" content="Oracle Web Database OpenSource JDBC" />
	<meta name="author" content="Spencer Hwang" />
	
	<script src="script/jquery-1.7.2.min.js" type="text/javascript"></script>
	<script src="script/jquery-ui-1.8.18.custom.min.js" type="text/javascript"></script>
    <script src="script/genie.js?<%= Util.getScriptionVersion() %>" type="text/javascript"></script>
<%--
    <script src="script/data-methods.js?<%= Util.getScriptionVersion() %>" type="text/javascript"></script>
	<script src="script/main.js?<%= Util.getScriptionVersion() %>" type="text/javascript"></script>
    <script src="script/query-methods.js?<%= Util.getScriptionVersion() %>" type="text/javascript"></script>
--%>
	<link rel="icon" type="image/png" href="image/Genie-icon.png">
	<link rel="stylesheet" href="css/ui-lightness/jquery-ui-1.8.18.custom.css" type="text/css"/>
    <link rel='stylesheet' type='text/css' href='css/style.css?<%= Util.getScriptionVersion() %>'> 
	
<script type="text/javascript">
var CATALOG="";
var to;
var to2;
var stack = [];
var stackFwd = [];

$(window).resize(function() {
	checkResize();
});
	
$(document).ready(function(){

	setMode('table');
	checkResize();
	CATALOG = "<%= cn.getSchemaName()%>";
//	toggleKeepAlive();
	callserver();

	$('#searchFilter').change(function(){
		var filter = $(this).val().toUpperCase();
		searchWithFilter(filter);
 	})
/* 	
	$('#globalSearch').change(function(){
 		var keyword = $(this).val().toLowerCase();
 		globalSearch(keyword);
 	})
*/ 	
 	// load initial auto-complete
	$.ajax({
		url: "ajax/auto-complete.jsp?term=xxx",
		success: function(data){
		}  
	}); 	
	$.ajax({
		url: "ajax/auto-complete2.jsp?term=xxx",
		success: function(data){
		}  
	}); 	
})

	function aboutGenie() {
		// a workaround for a flaw in the demo system (http://dev.jqueryui.com/ticket/4375), ignore!
		$( "#dialog:ui-dialog" ).dialog( "destroy" );
	
		$( "#dialog-modal" ).dialog({
			height: 470,
			width: 500,
			modal: true,
			buttons: {
				Ok: function() {
					$( this ).dialog( "close" );
				}
			}			
		});
	}
	
	function toggleKeepAlive() {
		var t = $("#keepalivelink").html();
		if (t=="Off") {
			$("#keepalivelink").html("On");
			setTimeout("callserver()",1000);
		} else {
			$("#keepalivelink").html("Off");
			clearTimeout(to);
		}
	}

	function checkResize() {
		var w = $(window).width();
		var h = $(window).height();
	
		if (h > 500) {
			var diff = $('#outer-table').position().top - $('#outer-result1').position().top;
			//alert(diff);
			var newH = h - 80;

			var tmp = w - $('#outer-table').width() - $('#outer-result2').width() - 45; 

			$('#outer-table').height(newH-diff);
			$('#outer-result1').height(newH);
			$('#outer-result2').height(newH);
			
			if (tmp < 660) tmp = 660;
			$('#outer-result1').width(tmp);
			
		}
	}
	
function callserver() {
	var remoteURL = 'ping.jsp';
	$.get(remoteURL, function(data) {
		if (data.indexOf("true")>0)
			to = setTimeout("callserver()",600000);
		else {
			$("#inner-result1").html("Connection Closed.");
		}
	});
}	
</script>

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
	<script>
	$(function() {
		$( "#globalSearch-xxx" ).autocomplete({
			source: "ajax/auto-complete2.jsp",
			minLength: 2,
			select: function( event, ui ) {
				loadObject( ui.item ?
					ui.item.value: "" );
			}
		});
	});
	
	$(function() {
		$( "#globalSearch" ).autocomplete({
			source: "ajax/auto-complete2.jsp",
			minLength: 2,
			select: function( event, ui ) {
				loadObject( ui.item ?
					ui.item.value: "" );
			}
		}).data( "autocomplete" )._renderItem = function( ul, item ) {
			return $( "<li></li>" )
			.data( "item.autocomplete", item )
			.append( "<a>" + item.label + " <span class='rowcountstyle'>" + item.desc + "</span></a>" )
//			.append( "<a>" + item.label + "</a>" )
			.appendTo( ul );
		};
	});	
	</script>    

</head> 

<body>

<table width=100% border=0>
<td width="44">
<% if (isCPAS && false) {%>
<img align=middle src="image/cpas.jpg" title="Ver. <%= Util.getVersionDate() %>"/>
<% } else { %>
<img align=top src="image/lamp.png" title="Ver. <%= Util.getVersionDate() %>"/>
<% } %>
</td>
<td>
<span style="color: blue; font-family: Arial; font-size:28px; font-weight:bold;">Genie</span>
</td>
<!-- <td nowrap><h2 style="color: blue;">Genie</h2></td> -->
<td><h3><%= cn.getUrlString() %></h3></td>
<td nowrap>
<a href="query.jsp" target="_blank">Query</a> |
<!-- <a href="worksheet.jsp" target="_blank">Work Sheet</a> |
 -->
<a href="javascript:queryHistory()">History</a> |
<a href="javascript:clearCache()">Clear Cache</a> |
<a href='Javascript:aboutGenie()'>About Genie</a> |
<a href="logout.jsp">Log out</a>

<% if (cn.isCpas() && isCPAS) { %>
<br/>
<a href="javascript:showCPAS()">CPAS Catalogs</a> | 
<a href="cpas-treeview.jsp" target=_blank>Treeview</a> |
<a href="cpas-process.jsp" target=_blank>Process</a>
<% } %>
</td>
<td align=right nowrap>
<b>Search</b> <input id="globalSearch" style="width: 200px;"/>
<!-- <a href="Javascript:clearField2()"><img border=0 src="image/clear.gif"></a>
 -->
<input type="button" value="Find" onClick="Javascript:globalSearch($('#globalSearch').val())"/>
</td>
</table>


<table border=0 cellspacing=0>
<td valign=top width=250>

<a class="mainBtn" href="Javascript:setMode('table')" id="selectTable">Table</a> | 
<a class="mainBtn" href="Javascript:setMode('view')" id="selectView">View</a> | 
<a class="mainBtn" href="Javascript:setMode('synonym')" id="selectSynonym">Synonym</a> | 
<a class="mainBtn" href="Javascript:setMode('package')" title="Package, Type, Function & Procedure" id="selectPackage">Program</a> | 
<a class="mainBtn" href="Javascript:setMode('tool')" id="selectTool">Tool</a>

<!-- | <a href="Javascript:setMode('tool')" id="selectTool">Tool</a> -->
<%-- <% if (cn.hasDbaRole()) { %> --%>
<!-- | <a href="Javascript:setMode('dba')" id="selectDBA">DBA</a> -->
<%-- <% }  else { %> --%>
<!-- | not DBA -->
<%-- <% } %> --%>


<br/>
<b>Filter</b> <input id="searchFilter" style="width: 180px;"/>
<a href="Javascript:clearField()"><img border=0 src="image/clear.gif"></a>
<div id="outer-table">
<div id="inner-table">
</div>
</div>
</td>
<td valign=top>
<div id="outer-result1">
	<div id="inner-nav">
		<a href="Javascript:goBack()"><img id="imgBackward" src="image/blue_arrow_left.png" title="back" border="0" style="display:none;"></a>
		&nbsp;&nbsp;
		<a href="Javascript:goFoward()"><img id="imgForward" src="image/blue_arrow_right.png" title="forward" border="0" style="display:none;"></a>
	</div>
	<div id="inner-result1"><img src="image/genie_bw.png"/><br><img src="image/lamp.png">
	</div>
</div>
</td>
<td valign=top>
<div id="outer-result2">
	<div id="inner-result2"><%= addedHistory %></div>
</div>
</td>
</table>
<form id="FORM_query" name="FORM_query" action="query.jsp" target="_blank" method="post">
<input id="sql" name="sql" type="hidden"/>
<input name="norun" type="hidden" value="YES"/>
</form>

<div id="dialog-modal" title="About Genie" style="display:none; background: #ffffff;">
<img src="image/genie2.jpg" align="center" />
<br/>

<% if (isCPAS) { %>
Thanks for using CPAS Genie.<br/>

CPAS Genie is for CPAS Oracle database.<br/>
Genie will help you navigate through database objects and their relationships.<br/> 

<br/>
If you have any question or suggestion, please feel free to contact me.
<br/><br/>

<%--
Please download the latest community version here:<br/>
<a href="http://code.google.com/p/oracle-genie/">http://code.google.com/p/oracle-genie/</a>
<br/><br/>
--%>

<%= Util.getVersionDate() %><br/>
Spencer Hwang - the creator of Genie<br/>
<!-- <a href="mailto:spencer.hwang@gmail.com">spencer.hwang@gmail.com</a>
 --><a href="mailto:spencerh@cpas.com">spencerh@cpas.com</a>

<% } else { %>
Thanks for using Oracle Genie.<br/>

Genie will help you navigate through database objects and their relationships.<br/> 

<br/>
If you have any question or suggestion, please feel free to contact me.
<br/><br/>

Please download the latest community version here:<br/>
<a href="http://code.google.com/p/oracle-genie/">http://code.google.com/p/oracle-genie/</a>
<br/><br/>

<%= Util.getVersionDate() %><br/>
Spencer Hwang - the creator of Genie<br/>
<a href="mailto:spencer.hwang@gmail.com">spencer.hwang@gmail.com</a>

<% } %>

</div>

<script type="text/javascript">

  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', '<%= Util.trackingId() %>']);
  _gaq.push(['_setDomainName', 'none']);
  _gaq.push(['_trackPageview']);

  _gaq.push(['_setCustomVar',
             1,                   // This custom var is set to slot #1.  Required parameter.
             'Database',     // The name acts as a kind of category for the user activity.  Required parameter.
             '<%= cn.getUrlString() %>',               // This value of the custom variable.  Required parameter.
             2                    // Sets the scope to session-level.  Optional parameter.
          ]);

  _gaq.push(['_setCustomVar',
             2,                   // This custom var is set to slot #1.  Required parameter.
             'Email',     // The name acts as a kind of category for the user activity.  Required parameter.
             '<%= cn.getEmail() %>',               // This value of the custom variable.  Required parameter.
             2                    // Sets the scope to session-level.  Optional parameter.
          ]);

  _gaq.push(['_setCustomVar',
             3,                   // This custom var is set to slot #1.  Required parameter.
             'IP',     // The name acts as a kind of category for the user activity.  Required parameter.
             '<%= cn.getIPAddress() %>',               // This value of the custom variable.  Required parameter.
             2                    // Sets the scope to session-level.  Optional parameter.
          ]);
  
  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();

</script>

</body>
</html>

<%

cn.getSynonym("XXX");
%>
