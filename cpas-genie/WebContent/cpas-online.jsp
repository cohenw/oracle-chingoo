<%@ page language="java" import="java.util.*" import="java.sql.*"
	import="spencer.genie.*" contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"%>

<%
	Connect cn = (Connect) session.getAttribute("CN");
	String qry = "SELECT LEVEL, ITEMID, CAPTION, SWITCH, ACTIONID, TREEKEY, UDATA /*, TRANSLATE, RATIO */ FROM TREEVIEW A START WITH ITEMID = 0 AND SDI = 'WP' AND SCHEMA = 'TREEVIEW' CONNECT BY PARENTID = PRIOR ITEMID AND SDI = 'WP' AND SCHEMA = 'TREEVIEW' " +
		" AND EXISTS (SELECT 1 FROM TREEACTION_STMT WHERE SDI=A.SDI AND ACTIONID=A.ACTIONID AND ACTIONTYPE='AW' AND UPPER(ACTIONSTMT) !='SC_NEVER') " +
		" ORDER BY SORTORDER";	

	Query q = new Query(cn, qry, false);
%>

<html>
<head>
<title>CPAS Online</title>

<meta name="description"
	content="Genie is an open-source, web based oracle database schema navigator." />
<meta name="keywords" content="Oracle Web Database OpenSource JDBC" />
<meta name="author" content="Spencer Hwang" />

<script src="script/jquery-1.7.2.min.js" type="text/javascript"></script>
<script src="script/jquery-ui-1.8.18.custom.min.js"
	type="text/javascript"></script>
<script src="script/genie.js?<%=Util.getScriptionVersion()%>"
	type="text/javascript"></script>

<link rel="icon" type="image/png" href="image/Genie-icon.png">
<link rel="stylesheet"
	href="css/ui-lightness/jquery-ui-1.8.18.custom.css" type="text/css" />
<link rel='stylesheet' type='text/css'
	href='css/style.css?<%=Util.getScriptionVersion()%>'>

<style>
.selected { 
    background-color: yellow;
    font-weight: bold;
//    border:  1px solid #2F557B;
}
 
#outer-tab {
    background-color: #FFFFFF;
    border: 1px solid #999999;
    width: 200px;
    height: 600px;
    overflow: auto;
    float: left;
    padding: 4px;
}

#outer-process {
    background-color: #FFFFFF;
    border: 1px solid #999999;
    width: 600px;
    height: 60px;
    overflow: auto;
    float: left;
    padding: 4px;
}

#outer-event {
    background-color: #FFFFFF;
    border: 1px solid #999999;
    width: 200px;
    height: 600px;
    overflow: auto;
    float: left;
    padding: 4px;
}

#outer-eventview {
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
var selectedSdi = "";
$(window).resize(function() {
	checkResize();
});

$(document).ready(function(){
	checkResize();
	
	$('#inner-tab a').click( function(e) {
	    $('#inner-tab a.selected').removeClass('selected');
	    $(this).addClass('selected');
	});
	
})

	function checkResize() {
		var w = $(window).width();
		var h = $(window).height();
	
		if (h > 500) {
			var newH = h - 80;
			var diff = $('#outer-tab').position().top - $('#outer-tab').position().top;

			$('#outer-tab').height(newH);
//			$('#outer-process').height(newH);
			$('#outer-event').height(newH - 73);
			$('#outer-eventview').height(newH - 73);
			
//			var tmp = w - $('#outer-tab').width() - $('#outer-process').width() - 50; 
			var tmp = w - $('#outer-tab').width() - 50; 

			if (tmp < 600) tmp = 600;
			$('#outer-process').width(tmp);			
			$('#outer-eventview').width(tmp- 213);			
		}
	}

function loadProcess(tabName) {
	$("#inner-process").html('');
	$("#inner-event").html('');
	$("#inner-eventview").html('');
	$.ajax({
		url: "ajax-cpas/load-online-process.jsp?ptype=" + tabName + "&t=" + (new Date().getTime()),
		success: function(data){
			$("#inner-process").html(data);
			$('#inner-process a').click( function(e) {
			    $('#inner-process a.selected').removeClass('selected');
			    $(this).addClass('selected');
			});
		},
        error:function (jqXHR, textStatus, errorThrown){
            alert(jqXHR.status + " " + errorThrown);
        }  
	});	
}


function loadEvent(process) {
	$("#inner-eventview").html('');
	$.ajax({
		url: "ajax-cpas/load-online-event.jsp?process=" + process + "&t=" + (new Date().getTime()),
		success: function(data){
			$("#inner-event").html(data);
			setHighlight();
			$('#inner-event a').click( function(e) {
			    //Remove the selected class from all of the links
			    $('#inner-event a.selected').removeClass('selected');
			    //Add the selected class to the current link
			    $(this).addClass('selected');
			});
			$("#pr-"+process).addClass('selected');	
		},
        error:function (jqXHR, textStatus, errorThrown){
            alert(jqXHR.status + " " + errorThrown);
        }  
	});	
}	

function loadEventView(process, event) {
	$.ajax({
		url: "ajax-cpas/load-online-eventview.jsp?process=" + process + "&event="+event +"&t=" + (new Date().getTime()),
		success: function(data){
			$("#inner-eventview").html(data);
			setHighlight();
			$('#inner-eventview a').click( function(e) {
			    //Remove the selected class from all of the links
			    $('#inner-eventview a.selected').removeClass('selected');
			    //Add the selected class to the current link
			    $(this).addClass('selected');
			});
			$("#ev-"+event).addClass('selected');	
		},
        error:function (jqXHR, textStatus, errorThrown){
            alert(jqXHR.status + " " + errorThrown);
        }  
	});	
}	

function openSimul(sdi, tkey) {
	$("#formSimulSdi").val(sdi);
	$("#formSimulTkey").val(tkey);
	$("#formSimul").submit();
}


function toggleChild(sdi, parentid){
	var imgsrc = $("#img-"+parentid).attr("src");
	if (imgsrc.indexOf("plus.gif") >0 ) {
		imgsrc=imgsrc.replace("plus","minus");
		$("#img-"+parentid).attr("src", imgsrc);
	} else {
		imgsrc=imgsrc.replace("minus","plus");
		$("#img-"+parentid).attr("src", imgsrc);
	}
	//alert(imgsrc);
	var divName = "div-" + sdi + "-" + parentid;
	$("#"+divName).toggle();
	
	var html = $("#"+divName).html();
	if (html=='') {
		//$("#"+divName).html('abc');
		loadChildTV(sdi, parentid, divName)
	}
}

function openChild(sdi, parentid){
	var imgsrc = $("#img-"+parentid).attr("src");
	if (imgsrc.indexOf("plus.gif") >0 ) {
		imgsrc=imgsrc.replace("plus","minus");
		$("#img-"+parentid).attr("src", imgsrc);
	} else {
		return 0;
	}
	var divName = "div-" + sdi + "-" + parentid;
	$("#"+divName).show();
	
	var html = $("#"+divName).html();
	if (html=='') {
		loadChildTV(sdi, parentid, divName)
	}
	return 1;
}

function closeChild(sdi, parentid){
	var imgsrc = $("#img-"+parentid).attr("src");
	if (imgsrc.indexOf("plus.gif") >0 ) {
		return;
	} else {
		imgsrc=imgsrc.replace("minus","plus");
		$("#img-"+parentid).attr("src", imgsrc);
	}
	var divName = "div-" + sdi + "-" + parentid;
	$("#"+divName).hide();
}

function openAll() {
	var cnt = 0;
	$("img.toggle").each(function(index) {
		var id = $(this).attr('id').substring(4);
		cnt += openChild(selectedSdi, id);
	});
	
	//alert(cnt);
	return cnt;
}

function closeAll() {
	$("img.toggle").each(function(index) {
		var id = $(this).attr('id').substring(4);
		closeChild(selectedSdi, id);
	});
	
}

function openSimulator() {
	$("#formSimul").submit();
}

function onSearch(keyword) {
	keyword = $.trim(keyword);
	$("#inner-eventview").html("<img src='image/loading.gif'/>");

	$.ajax({
		url: "ajax-cpas/tv-search.jsp?keyword=" + keyword + "&t=" + (new Date().getTime()),
		success: function(data){
			$("#inner-eventview").html(data);
		},
        error:function (jqXHR, textStatus, errorThrown){
            alert(jqXHR.status + " " + errorThrown);
        }  
	});
}

function processSearch(keyword) {
	keyword = $.trim(keyword);

	$("#inner-eventview").html("<img src='image/loading.gif'/>");
	$("#inner-event").html('');
	$("#inner-eventview").html('');

	$.ajax({
		url: "ajax-cpas/online-process-search.jsp?keyword=" + keyword + "&t=" + (new Date().getTime()),
		success: function(data){
			$("#inner-eventview").html(data);
		},
        error:function (jqXHR, textStatus, errorThrown){
            alert(jqXHR.status + " " + errorThrown);
        }  
	});
}

function setProcess(sdi, process) {
	$('#inner-tab a.selected').removeClass('selected');
	$('#inner-tab [title="' + sdi + '"]').addClass('selected');
//	$('#inner-tab a').addClass('selected');
	window.setTimeout(function() {
		loadProcess(sdi);
	}, 200);
	
	window.setTimeout(function() {
		loadEvent(process);
	}, 400);
}

function setEvent(sdi, process, event) {
	$('#inner-tab a.selected').removeClass('selected');
	$('#inner-tab [title="' + sdi + '"]').addClass('selected');
	window.setTimeout(function() {
		loadProcess(sdi);
	}, 200);
	
	window.setTimeout(function() {
		loadEvent(process);
	}, 400);

	window.setTimeout(function() {
		loadEventView(process, event);
	}, 600);
}

function loadSTMT(sdi, actionid, treekey) {
	$.ajax({
		url: "ajax-cpas/load-online-STMT.jsp?sdi=" + sdi + "&actionid=" + actionid + "&t=" + (new Date().getTime()),
		success: function(data){
			$("#inner-tvstmt").html(data);
			var id = treekey.replace(/_/g,"-");
			$("#"+id).addClass('selected');		
			//alert(treekey + " " + id);
			setHighlight();
		},
        error:function (jqXHR, textStatus, errorThrown){
            alert(jqXHR.status + " " + errorThrown);
        }  
	});	
}	
</script>

</head>


<body>
	<table width=100% border=0>
		<td><img src="image/cpas.jpg"
			title="Version <%=Util.getVersionDate()%>" /></td>
		<td><h2 style="color: blue;">CPAS Online</h2></td>
		<td>&nbsp;</td>

		<td>
<a href="index.jsp">Home</a> |
<a href="query.jsp" target="_blank">Query</a> |
<a href="cpas-process.jsp" target="_blank">CPAS Process</a> 
		</td>
		<td><h3><%=cn.getUrlString()%></h3></td>

<td align=right nowrap>
<b>Search</b> <input id="globalSearch" style="width: 200px;"/>
<input type="button" value="Find" onClick="Javascript:processSearch($('#globalSearch').val())"/>
</td>

 	</table>

	<table border=0 cellspacing=0>
		<td valign=top>
			<div id="outer-tab">
				<div id="inner-tab">
<%
	String id = Util.getId();
%>
<b>CPAS Online Tab</b>
<a href="javascript:openQuery('<%=id%>')"><img src="image/sout.gif" border=0 align=middle  title="<%=qry%>"/></a>
<div style="display: none;" id="sql-<%=id%>"><%= qry%></div>
<br/>
			
<%
	q.rewind(1000, 1);
	int rowCnt = 0;
	while (q.next()) {
		//LEVEL, ITEMID, CAPTION, SWITCH, ACTIONID, TREEKEY, UDATA, TRANSLATE, RATIO
		String caption = q.getValue("CAPTION");
		String level = q.getValue("LEVEL");
		String actionid = q.getValue("ACTIONID");
		if (level.equals("1") || level.equals("2")) continue;
		
		rowCnt ++;
		if (level.equals("3")) {
%>
<br/>
<b><%= caption %></b><br/>
<%
		} else {
			
			qry = "SELECT actionstmt FROM TREEACTION_STMT WHERE SDI = 'WP' AND ACTIONID=" + actionid + " AND ACTIONTYPE='AS'"; 	
			String actionName = cn.queryOne(qry);
//System.out.println(qry);			
			qry = "SELECT CAPTION, TREEKEY FROM TREEVIEW where sdi='WP' and actionid=" + actionid;
//System.out.println(qry);			
%>
	<span style="margin-left:20px;"></span><a href="Javascript:loadProcess('<%= actionName %>')" title="<%= actionName %>"><%= caption %></a><br/>
<%
		}
	}
%>

<br/><br/>
<%

// for PEPP
if (cn.getUrlString().contains("PEPP")) {

	qry = "SELECT DISTINCT TYPE, (SELECT NAME FROM CPAS_CODE_VALUE WHERE GRUP='CCV' AND VALU=A.TYPE) FROM CPAS_PROCESS A ORDER BY 1";
	List<String[]> list = cn.query(qry, false);

%>
<b>Process Type</b>
<%
	for (int i=0; i<list.size();i++) {
%>
	<li><a id="pt-<%=list.get(i)[1]%>" href="javascript:loadProcess('<%=list.get(i)[1]%>');"><%=list.get(i)[2]%></a> <span class="nullstyle"><%=list.get(i)[1]%></span></li>
<% 
	} 
}
%>

				</div>
			</div>
		</td>
		<td valign=top>
			<div id="outer-process">
				<div id="inner-process"></div>
			</div>
			<br/>
			<div id="outer-event" style="margin-top: 3px;">
				<div id="inner-event"></div>
			</div>

			<div id="outer-eventview" style="margin-top: 3px; margin-left: 3px;">
				<div id="inner-eventview"></div>
			</div>
		</td>
	</table>

<form id="FORM_query" name="FORM_query" action="query.jsp" target="_blank" method="post">
<input id="sql-query" name="sql" type="hidden"/>
</form>

<form id="formSimul" target="_blank" action="cpas-simul.jsp">
<input id="formSimulSdi" name="sdi" type="hidden"/>
<input id="formSimulTkey" name="treekey" type="hidden"/>
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