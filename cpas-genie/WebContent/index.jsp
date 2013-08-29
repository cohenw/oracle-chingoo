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
	String quickLinks = cn.getQuickLinks();
%>

<html>
<head> 
	<title><%= title %></title>

	<meta name="description" content="Genie is an open-source, web based oracle database schema navigator." />
	<meta name="keywords" content="Oracle Web Database OpenSource JDBC" />
	<meta name="author" content="Spencer Hwang" />
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" /> 
	
	<script src="script/jquery-1.7.2.min.js" type="text/javascript"></script>
	<script src="script/jquery-ui-1.8.18.custom.min.js" type="text/javascript"></script>
    <script src="script/genie.js?<%= Util.getScriptionVersion() %>" type="text/javascript"></script>
    <script src="script/data-methods.js?<%= Util.getScriptionVersion() %>" type="text/javascript"></script>
<%--
	<script src="script/main.js?<%= Util.getScriptionVersion() %>" type="text/javascript"></script>
    <script src="script/query-methods.js?<%= Util.getScriptionVersion() %>" type="text/javascript"></script>
--%>
	<link rel="icon" type="image/png" href="image/Genie-icon.png">
	<link rel="stylesheet" href="css/ui-lightness/jquery-ui-1.8.18.custom.css" type="text/css"/>
    <link rel='stylesheet' type='text/css' href='css/style.css?<%= Util.getScriptionVersion() %>'> 

<style>
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

	$('#searchFilter1').change(function(){
		var filter = $(this).val().toUpperCase();
		searchWithFilter1(filter);
	})
	$('#hideEmpty').change(function(){
		var filter = $('#searchFilter1').val().toUpperCase();
		searchWithFilter1(filter);
	})

 	$('#searchFilter2').change(function(){
		var filter = $(this).val().toUpperCase();
		searchWithFilter2(filter);
 	})
	$('#searchFilter3').change(function(){
		var filter = $(this).val().toUpperCase();
		searchWithFilter3(filter);
 	})
	$('#searchFilter4').change(function(){
		var filter = $(this).val().toUpperCase();
		searchWithFilter4(filter);
 	})
	$('#searchFilter5').change(function(){
		var filter = $(this).val().toUpperCase();
		searchWithFilter5(filter);
 	})

	initLoad();
	checkResize();
	CATALOG = "<%= cn.getSchemaName()%>";
//	toggleKeepAlive();
	callserver();

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
//			var diff = $('#outer-table').position().top - $('#outer-result1').position().top;
			//alert(diff);
			var newH = h - 80;

			var tmp = w - $('#tabs').width() - $('#outer-result2').width() - 45;
			if (!$("#outer-result2").is(":visible"))
				tmp = w - $('#tabs').width() - 45;

//			$('#outer-table').height(newH-diff);
			$('#outer-result1').height(newH);
			$('#outer-result2').height(newH);
			$('#tabs').height(newH-4);
			$('#tabs2').height(newH-40);
			
			if (tmp < 660) tmp = 660;
			$('#outer-result1').width(tmp);
			
			if (w > 1200)
				$('#topline').width(w-30);
			else
				$('#topline').width(1170);
		}
	}

	function checkResizeW() {
		var w = $(window).width();
		var tmp = w - $('#tabs').width() - $('#outer-result2').width() - 45;
		if (!$("#outer-result2").is(":visible"))
			tmp = w - $('#tabs').width() - 45;

		if (tmp < 660) tmp = 660;
		$('#outer-result1').width(tmp);
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

function hideHist() {
	$("#outer-result2").hide();
	checkResize();
}
function toggleHist() {
	$("#outer-result2").toggle();
	checkResizeW();
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
	var loadCount=0;
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
			.appendTo( ul );
		};
	});	
	
	$(function() {
		$( "#tabs" ).tabs();
	});	
	
	function initLoad() {
		$("#list-table").html("<img src='image/loading.gif'/>");
		$("#inner-result1").html("<img src='image/loading.gif'/>");
		loadList("ajax/list-view.jsp", "list-view");	
		loadList("ajax/list-synonym.jsp", "list-synonym");	
		loadList("ajax/list-package.jsp", "list-package");	
		loadList("ajax/list-tool.jsp", "list-tool");	
		loadList("ajax/list-table.jsp", "list-table");	
		
		//$("#inner-result1").html('<img src="image/genie_bw.png"/>');
	}
	
	function loadList(url, targetDiv) {
		$.ajax({
			url: url,
			success: function(data){
				$("#" + targetDiv).html(data);
				loadCount ++;
				if (loadCount >= 5) {
					//$("#inner-result1").html('<img src="image/genie_bw.png"/>');
					showCPAS();
				}
			},
            error:function (jqXHR, textStatus, errorThrown){
                alert(jqXHR.status + " " + errorThrown);
            }  
		});
	}
	
	function searchWithFilter1(filter) {
		if($('#hideEmpty').attr('checked'))
			gotoUrl = "ajax/list-table.jsp?filter=" + filter+"&hideEmpty=true";
		else 
			gotoUrl = "ajax/list-table.jsp?filter=" + filter;

		$.ajax({
			url: gotoUrl,
			success: function(data){
				$("#list-table").html(data);
			},
            error:function (jqXHR, textStatus, errorThrown){
                alert(jqXHR.status + " " + errorThrown);
            }  
		});
		
	}
	function searchWithFilter2(filter) {
		gotoUrl = "ajax/list-view.jsp?filter=" + filter;

		$.ajax({
			url: gotoUrl,
			success: function(data){
				$("#list-view").html(data);
			},
            error:function (jqXHR, textStatus, errorThrown){
                alert(jqXHR.status + " " + errorThrown);
            }  
		});
		
	}
	function searchWithFilter3(filter) {
		gotoUrl = "ajax/list-synonym.jsp?filter=" + filter;

		$.ajax({
			url: gotoUrl,
			success: function(data){
				$("#list-synonym").html(data);
			},
            error:function (jqXHR, textStatus, errorThrown){
                alert(jqXHR.status + " " + errorThrown);
            }  
		});
		
	}
	function searchWithFilter4(filter) {
		gotoUrl = "ajax/list-package.jsp?filter=" + filter;

		$.ajax({
			url: gotoUrl,
			success: function(data){
				$("#list-package").html(data);
			},
            error:function (jqXHR, textStatus, errorThrown){
                alert(jqXHR.status + " " + errorThrown);
            }  
		});
		
	}
	function searchWithFilter5(filter) {
		gotoUrl = "ajax/list-tool.jsp?filter=" + filter;

		$.ajax({
			url: gotoUrl,
			success: function(data){
				$("#list-tool").html(data);
			},
            error:function (jqXHR, textStatus, errorThrown){
                alert(jqXHR.status + " " + errorThrown);
            }  
		});
		
	}

	function clearField1() {
		$("#searchFilter1").val("");
		searchWithFilter1('');
	}
	function clearField2() {
		$("#searchFilter2").val("");
		searchWithFilter2('');
	}
	function clearField3() {
		$("#searchFilter3").val("");
		searchWithFilter3('');
	}
	function clearField4() {
		$("#searchFilter4").val("");
		searchWithFilter4('');
	}
	function clearField5() {
		$("#searchFilter5").val("");
		searchWithFilter5('');
	}
	
	</script>    

</head> 

<body>

<div id="topline" style="background-color: #E6F8E0; padding: 0px; border:1px solid #CCCCCC; border-radius:10px;">

<table width=100% border=0 cellpadding=0 cellspacing=0>
<td width="44">
<% if (isCPAS && false) {%>
	<img align=middle src="image/cpas.jpg" alt="Ver. <%= Util.getVersionDate() %>"/>
<% } else { %>
	<img align=top src="image/lamp.png" alt="Ver. <%= Util.getVersionDate() %>" title="<%= Util.getBuildNo() %>"/>
<% } %>
</td>
<td>
<span style="font-family: Arial; font-size:18px;"><span style="background-color:black; color: white;">C</span><span style="background-color:#FF9900; color: white;">PAS</span> <span style="color: blue; font-family: Arial; font-size:18px; font-weight:bold;">Genie</span></span>
</td>
<!-- <td nowrap><h2 style="color: blue;">Genie</h2></td> -->
<td><b><%= cn.getUrlString() %></b></td>
<td nowrap>
<% if (cn.isCpas() && isCPAS) { %>
<a href="javascript:showCPAS()"><img border=0 src="image/cpas.jpg" width=12 height=12>
CPAS</a> |
<% } %>
<a href="query.jsp" target="_blank">Query</a> |
<a target=_blank href="history.jsp">History</a> |
<a href="javascript:clearCache()">Clear Cache</a> |
<a href='Javascript:aboutGenie()'>About Genie</a> |
<a href="logout.jsp">Log out</a>

</td>
<td align=right nowrap>
<b>Global Search</b> <input id="globalSearch" style="width: 200px;" placeholder="table, view or package name"/>
<!-- <a href="Javascript:clearField2()"><img border=0 src="image/clear.gif"></a>
 -->
<input type="button" value="Find" onClick="Javascript:globalSearch($('#globalSearch').val())"/>
<a href="Javascript:toggleHist()"><img src="image/downarrow_small_black.png"></a>
</td>
</table>
</div>
<div style="height: 4px;"></div>
<table border=0 cellspacing=0 cellpadding=1>
<td valign=top width=280>

<div id="tabs">
	<ul>
		<li><a href="#tabs-1">Table</a></li>
		<li><a href="#tabs-2">View</a></li>
		<li><a href="#tabs-3">Synonym</a></li>
		<li><a href="#tabs-4">Program</a></li>
		<li><a href="#tabs-5">Tool</a></li>
	</ul>
<div id="tabs2" style="overflow: auto;">
	<div id="tabs-1">
<b>Filter</b> <input id="searchFilter1" style="width: 180px;" placeholder="table name"/>
<a href="Javascript:clearField1()"><img border=0 src="image/clear.gif"></a>
<br/><input id="hideEmpty" value="1" type="checkbox">Hide Empty tables
<div id="list-table"></div>
	</div>
	<div id="tabs-2">
<b>Filter</b> <input id="searchFilter2" style="width: 180px;" placeholder="view name"/>
<a href="Javascript:clearField2()"><img border=0 src="image/clear.gif"></a>
<div id="list-view"></div>
	</div>
	<div id="tabs-3">
<b>Filter</b> <input id="searchFilter3" style="width: 180px;"  placeholder="synonym name"/>
<a href="Javascript:clearField3()"><img border=0 src="image/clear.gif"></a>
<div id="list-synonym"></div>
	</div>
	<div id="tabs-4">
<b>Filter</b> <input id="searchFilter4" style="width: 180px;"  placeholder="program name"/>
<a href="Javascript:clearField4()"><img border=0 src="image/clear.gif"></a>
<div id="list-package"></div>
	</div>
	<div id="tabs-5">
<b>Filter</b> <input id="searchFilter5" style="width: 180px;"/>
<a href="Javascript:clearField5()"><img border=0 src="image/clear.gif"></a>
<div id="list-tool"></div>
	</div>
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
	<div id="inner-result1"><img src='image/loading.gif'/></div>
</div>
</td>
<td valign=top>
<div id="outer-result2">
<%--
	<a href="Javascript:hideHist()" style="float:right;">hide</a>
--%>
 	<div id="inner-result2"><%= quickLinks %></div>
</div>
</td>
</table>
<form id="FORM_query" name="FORM_query" action="query.jsp" target="_blank" method="post">
<input id="sql-query" name="sql" type="hidden"/>
<input name="norun" type="hidden" value="YES"/>
</form>

<div id="dialog-modal" title="About Genie" style="display:none; background: #ffffff;">
<img src="image/genie-lamp.jpg" align="center" />
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
Build: <%= Util.getBuildNo() %><br/>
Spencer Hwang<br/>
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
Build: <%= Util.getBuildNo() %><br/>
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

  _gaq.push(['_setCustomVar',
             4,                   // This custom var is set to slot #1.  Required parameter.
             'BuildNo',     // The name acts as a kind of category for the user activity.  Required parameter.
             '<%= Util.getBuildNo() %>',               // This value of the custom variable.  Required parameter.
             2                    // Sets the scope to session-level.  Optional parameter.
          ]);
  
  _gaq.push(['_setCustomVar',
             5,                   // This custom var is set to slot #1.  Required parameter.
             'URL',     // The name acts as a kind of category for the user activity.  Required parameter.
             '<%= request.getRequestURL() %>',               // This value of the custom variable.  Required parameter.
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
