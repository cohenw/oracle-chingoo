<%@ page language="java" import="java.util.*" import="java.sql.*"
	import="spencer.genie.*" contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"%>

<%
	Connect cn = (Connect) session.getAttribute("CN");
	String qry = "SELECT * FROM TREEVIEW WHERE parentid='0' and sdi='DR' ORDER BY SORTORDER";	

	Query q = new Query(cn, qry, false);
%>

<html>
<head>
<title>Genie - Development Rules</title>

<meta name="description"
	content="Genie is an open-source, web based oracle database schema navigator." />
<meta name="keywords" content="Oracle Web Database OpenSource JDBC" />
<meta name="author" content="Spencer Hwang" />

<script src="script/jquery-1.7.2.min.js" type="text/javascript"></script>
<script src="script/jquery-ui-1.8.18.custom.min.js"	type="text/javascript"></script>
<script src="script/genie.js?<%=Util.getScriptionVersion()%>" type="text/javascript"></script>
<script src="script/data-methods.js?<%=Util.getScriptionVersion()%>" type="text/javascript"></script>

<link rel="icon" type="image/png" href="image/Genie-icon.png">
<link rel="stylesheet" href="css/ui-lightness/jquery-ui-1.8.18.custom.css" type="text/css" />
<link rel='stylesheet' type='text/css'
	href='css/style.css?<%=Util.getScriptionVersion()%>'>

<style>
.selected { 
    background-color: yellow;
    font-weight: bold;
}

#outer-tv {
    background-color: #f0f0f0;
    border: 1px solid #999999;
    width: 260px;
    height: 600px;
    overflow: auto;
    float: left;
    padding: 4px;
}

#outer-con {
    background-color: #FFFFFF;
    border: 1px solid #999999;
    width: 600px;
    height: 600px;
    overflow: auto;
    float: left;
    padding: 4px;
}
 
</style>

<script type="text/javascript">
$(window).resize(function() {
	checkResize();
});

$(document).ready(function(){
	
	$('#inner-tv a').click( function(e) {
	    $('#inner-tv a.selected').removeClass('selected');
	    $(this).addClass('selected');
	});
	
	checkResize();
})

	function checkResize() {
		var w = $(window).width();
		var h = $(window).height();
	
		if (h > 500) {
			var tmp = w - 30; 

			if (tmp < 600) tmp = 600;
			$('#outer-con').width(tmp- 273);			

			var newH = h - 90;

			$('#outer-tv').height(newH);
			$('#outer-con').height(newH);
			
//			var tmp = w - $('#outer-tab').width() - $('#outer-process').width() - 50; 
		}
				
		//$('#outer-eventview').html($('#outer-process').height());
	}

function toggle(id, itemid) {
	
	var imgSrc = $("#img-"+id).attr("src");
	if (imgSrc.indexOf("plus") > 0) {
		$("#img-" + id).attr("src","image/minus.gif");
		var con = $("#div-" + id).html();
		if (con == "*") {
			$("#div-" + id).html("<img src='image/loading.gif'/>");
			var legacy=$("#legacy-" + id).html();
			if (legacy==null) legacy="";
			loadChild(id, itemid, legacy);
		}
		$("#div-" + id).slideDown();
	} else {
		$("#img-" + id).attr("src","image/plus.gif");
		$("#div-" + id).slideUp();
	}
}

function loadChild(id, itemid, legacy) {
	$.ajax({
		url: "ajax-cpas/load-child-tv.jsp?sdi=DR&parentid=" + itemid + "&legacy=" + legacy,
		success: function(data){
			$("#div-" + id).html(data);
		},
        error:function (jqXHR, textStatus, errorThrown){
            alert(jqXHR.status + " " + errorThrown);
        }  
	});	
}

//url: "ajax-cpas/load-STMT.jsp?sdi=" + sdi + "&actionid=" + actionid + "&t=" + (new Date().getTime()),
function loadCon(sdi, actionid, treekey, divid, itemid) {
	$.ajax({
		url: "ajax-cpas/tv-simul.jsp?sdi=" + sdi + "&actionid=" + actionid + "&divid="+divid + "&itemid=" +itemid,
		success: function(data){
			$("#inner-con").html(data);
		    $('#inner-tv a.selected').removeClass('selected');
		    $("#aa-" + divid).addClass('selected');
		},
        error:function (jqXHR, textStatus, errorThrown){
            alert(jqXHR.status + " " + errorThrown);
        }  
	});	
}

function loadCon2(sdi, actionid, treekey, divid, itemid, key) {
	$.ajax({
		url: "ajax-cpas/tv-simul.jsp?sdi=" + sdi + "&actionid=" + actionid + "&divid="+divid + "&itemid=" +itemid + "&key=" +key,
		success: function(data){
			$("#inner-con").html(data);
		    $('#inner-tv a.selected').removeClass('selected');
		    $("#aa-" + divid).addClass('selected');
		},
        error:function (jqXHR, textStatus, errorThrown){
            alert(jqXHR.status + " " + errorThrown);
        }  
	});	
}

function loadContent(sdi, actionid, treekey, divid, itemid, key, legacy) {
	$.ajax({
		url: "ajax-cpas/tv-simul.jsp?sdi=" + sdi + "&actionid=" + actionid + "&divid="+divid + "&itemid=" +itemid + "&key=" +key + "&legacy=" +legacy,
		success: function(data){
			$("#inner-con").html(data);
		    $('#inner-tv a.selected').removeClass('selected');
		    $("#aa-" + divid).addClass('selected');
		},
        error:function (jqXHR, textStatus, errorThrown){
            alert(jqXHR.status + " " + errorThrown);
        }  
	});	
}

function hideIfAny(id) {
	var hiddenCols = $("#hide-" + id).val();
	if (hiddenCols!=undefined && hiddenCols != '') {
		var cols = hiddenCols.split(",");
		for(var i = 0;i<cols.length;i++){
			hideColumn(id, cols[i]);
		}
	}
}	

function gotoPage(id, pageNo) {
	$("#pageNo").val(pageNo);

	reloadData(id);
}
    
</script>

</head>

<body>

<div id="topline" style="background-color: #EEEEEE; padding: 0px; border:1px solid #888888; border-radius:10px;">
<table width=100% border=0 cellpadding=0 cellspacing=0>
<td width="44">
<img align=top src="image/lamp.png" alt="Ver. <%= Util.getVersionDate() %>" title="<%= Util.getBuildNo() %>"/>
</td>
<td>
<span style="font-family: Arial; font-size:18px;"><span style="background-color:black; color: white;">C</span><span style="background-color:#FF9900; color: white;">PAS</span> <span style="color: blue; font-family: Arial; font-size:18px; font-weight:bold;">Development Rules</span></span>
</td>
<!-- <td nowrap><h2 style="color: blue;">Genie</h2></td> -->
<td><b><%= cn.getUrlString() %></b></td>
<td nowrap>

<a href="index.jsp">Home</a> |
<a href="query.jsp" target="_blank">Query</a> 

</td>
<!-- <td align=right nowrap>
<b>Search</b> <input id="globalSearch" style="width: 200px;"/>
<input type="button" value="Find" onClick="Javascript:processSearch($('#globalSearch').val())"/>
</td> -->
</table>
</div>
<div style="height: 4px;"></div>


<div id="outer-tv" style="margin-top: 3px;">
<div id="inner-tv">


<%
	String id=""; String itemid="";
	q.rewind(1000, 1);
	int rowCnt = 0;
	while (q.next()) {
		String caption = q.getValue("CAPTION");
		itemid = q.getValue("ITEMID");
		String treekey = q.getValue("TREEKEY");
		rowCnt ++;
		id = Util.getId();
%>
	<a href="Javascript:toggle(<%=id%>, <%=itemid%>)"><img id="img-<%=id%>" src="image/plus.gif" align="top"><%= caption %></a><br/>
	<div id="div-<%=id%>" style="margin-left: 10px; display:none;">*</div>
	
<% 	} %>

<script type="text/javascript">
$(document).ready(function(){
	toggle(<%=id%>, <%=itemid%>);	
})
</script>

</div>
</div>


<div id="outer-con" style="margin-top: 3px; margin-left: 3px;">
	<div id="inner-con"></div>
</div>


<form id="FORM_query" name="FORM_query" action="query.jsp" target="_blank" method="post">
<input id="sql-query" name="sql" type="hidden"/>
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

</script>

</body>
</html>