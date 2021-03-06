<%@ page language="java" import="java.util.*" import="java.sql.*"
	import="spencer.genie.*" contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"%>

<%
	Connect cn = (Connect) session.getAttribute("CN");
	String sdi = request.getParameter("sdi");
	String treekey = request.getParameter("treekey");
	String actionId = null;
	if (sdi!=null && treekey !=null) {
		actionId = cn.queryOne("SELECT actionid FROM TREEVIEW WHERE SDI = '"+sdi+"' AND TREEKEY='"+treekey+"'");
	}
	
	String search = request.getParameter("search");
%>

<html>
<head>
<title>CPAS Tree View</title>

<meta name="description"
	content="Genie is an open-source, web based oracle database schema navigator." />
<meta name="keywords" content="Oracle Web Database OpenSource JDBC" />
<meta name="author" content="Spencer Hwang" />

<script src="script/jquery-1.7.2.min.js" type="text/javascript"></script>
<script src="script/jquery-ui-1.8.18.custom.min.js"
	type="text/javascript"></script>
<script src="script/genie.js?<%=Util.getScriptionVersion()%>"
	type="text/javascript"></script>
<%--
    <script src="script/data-methods.js?<%= Util.getScriptionVersion() %>" type="text/javascript"></script>
	<script src="script/main.js?<%= Util.getScriptionVersion() %>" type="text/javascript"></script>
    <script src="script/query-methods.js?<%= Util.getScriptionVersion() %>" type="text/javascript"></script>
--%>
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
 
#outer-sdi {
    background-color: #FFFFFF;
    border: 1px solid #999999;
    width: 200px;
    height: 600px;
    overflow: auto;
    float: left;
    padding: 4px;
}

#outer-tv {
    background-color: #FFFFFF;
    border: 1px solid #999999;
    width: 300px;
    height: 600px;
    overflow: auto;
    float: left;
    padding: 4px;
}

#outer-tvstmt {
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
	loadSdi();

<% if (sdi != null ) {%>
	window.setTimeout(function() {
		loadTV('<%=sdi%>');
	}, 250);
<% } %>

<% if (treekey != null ) {%>
	window.setTimeout(function() {
		loadSTMT('<%=sdi%>',<%=actionId%>,'<%=treekey%>');
		setYellow('<%=sdi%>', '<%=treekey%>');
	}, 500);
<% } %>

<% if (search != null ) {%>
window.setTimeout(function() {
	tvSearch('<%=search%>');
}, 500);
<% } %>
})

function replaceall(str,replace,with_this)
{
    var str_hasil ="";
    var temp;

    for(var i=0;i<str.length;i++) // not need to be equal. it causes the last change: undefined..
    {
        if (str[i] == replace)
        {
            temp = with_this;
        }
        else
        {
                temp = str[i];
        }

        str_hasil += temp;
    }

    return str_hasil;
}

	function checkResize() {
		var w = $(window).width();
		var h = $(window).height();
	
		if (h > 500) {
			var newH = h - 80;
			var diff = $('#outer-sdi').position().top - $('#outer-sdi').position().top;

			$('#outer-sdi').height(newH);
			$('#outer-tv').height(newH);
			$('#outer-tvstmt').height(newH);
			
			var tmp = w - $('#outer-sdi').width() - $('#outer-tv').width() - 50; 

			if (tmp < 600) tmp = 600;
			$('#outer-tvstmt').width(tmp);			
		}
	}

function loadSdi() {
	$("#inner-tv").html('');
	$("#inner-tvstmt").html('');
	$.ajax({
		url: "ajax-cpas/load-sdi.jsp?t=" + (new Date().getTime()),
		success: function(data){
			$("#inner-sdi").html(data);
			$('#inner-sdi a').click( function(e) {
			    //Remove the selected class from all of the links
			    $('#inner-sdi a.selected').removeClass('selected');
			    //Add the selected class to the current link
			    $(this).addClass('selected');
			});
		},
        error:function (jqXHR, textStatus, errorThrown){
            alert(jqXHR.status + " " + errorThrown);
        }  
	});	
}

function loadTV(sdi) {
	selectedSdi = sdi;
	$("#inner-tvstmt").html('');
	$.ajax({
		url: "ajax-cpas/load-TV.jsp?sdi=" + sdi + "&t=" + (new Date().getTime()),
		success: function(data){
			$("#inner-tv").html(data);
			openAll();
			$('#inner-tv a').click( function(e) {
			    //Remove the selected class from all of the links
			    $('#inner-tv a.selected').removeClass('selected');
			    //Add the selected class to the current link
			    $(this).addClass('selected');
			});
			$("#sdi-"+sdi).addClass('selected');			
		},
        error:function (jqXHR, textStatus, errorThrown){
            alert(jqXHR.status + " " + errorThrown);
        }  
	});	
}	

function loadChildTV(sdi, parentid, divName) {
	$.ajax({
		url: "ajax-cpas/load-TV.jsp?sdi=" + sdi + "&parentid=" + parentid,
		success: function(data){
			$("#"+divName).html(data);
			$('#inner-tv a').click( function(e) {
			    //Remove the selected class from all of the links
			    $('#inner-tv a.selected').removeClass('selected');
			    //Add the selected class to the current link
			    $(this).addClass('selected');
			});


		},
        error:function (jqXHR, textStatus, errorThrown){
            alert(jqXHR.status + " " + errorThrown);
        }  
	});	
}	

function loadSTMT(sdi, actionid, treekey) {
	$.ajax({
		url: "ajax-cpas/load-STMT.jsp?sdi=" + sdi + "&actionid=" + actionid + "&treekey=" + treekey + "&t=" + (new Date().getTime()),
		success: function(data){
			$('#inner-tv a.selected').removeClass('selected');
			$("#inner-tvstmt").html(data);
			var id = treekey.replace(/_/g,"-");
			$("#"+id).addClass('selected');		
			//alert(treekey + " " + id);
		},
        error:function (jqXHR, textStatus, errorThrown){
            alert(jqXHR.status + " " + errorThrown);
        }  
	});	
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

function tvSearch(keyword) {
	//keyword = keyword.trim();
	keyword = $.trim(keyword);
	$("#inner-tvstmt").html("<img src='image/loading.gif'/>");

	$.ajax({
		url: "ajax-cpas/tv-search.jsp?keyword=" + keyword + "&t=" + (new Date().getTime()),
		success: function(data){
			$("#inner-tvstmt").html(data);
		},
        error:function (jqXHR, textStatus, errorThrown){
            alert(jqXHR.status + " " + errorThrown);
        }  
	});
}

function searchExposedRule(ruleType) {
	ruleType = $.trim(ruleType);
	$("#inner-tvstmt").html("<img src='image/loading.gif'/>");

	$.ajax({
		url: "ajax-cpas/tv-search.jsp?ruleType=" + ruleType + "&t=" + (new Date().getTime()),
		success: function(data){
			$("#inner-tvstmt").html(data);
		},
        error:function (jqXHR, textStatus, errorThrown){
            alert(jqXHR.status + " " + errorThrown);
        }  
	});
}

function setYellow(sdi, treekey) {
	$('#inner-sdi a.selected').removeClass('selected');
	$('#inner-tv a.selected').removeClass('selected');
	var sdiId = "sdi-" + replaceall(sdi, "_", "-");
	var tkId = replaceall(treekey, "_", "-");
	//console.log(pkgId);
	$('#' + sdiId ).addClass('selected');
	$('#' + tkId ).addClass('selected');

	if ($('#' + sdiId).length) {
		var newTop = $('#' + sdiId ).position().top - $('#inner-sdi').position().top;
		$('#outer-sdi').animate({scrollTop: newTop}, 500);
	}
//alert(tkId);
	if ($('#' + tkId).length) {
		var newTop = $('#' + tkId ).position().top - $('#inner-tv').position().top;
		//alert(newTop);
		$('#outer-tv').animate({scrollTop: newTop }, 500);
		//alert('xxx');
	}
	
	//alert('aaa');
}

function exposedRules() {
	$.ajax({
		url: "ajax-cpas/exposed-rules.jsp",
		success: function(data){
			$("#inner-tvstmt").html(data);
		},
        error:function (jqXHR, textStatus, errorThrown){
            alert(jqXHR.status + " " + errorThrown);
        }  
	});	
}

function loadProc(pkgName, prcName) {
	$("#name-map").val(pkgName+"."+prcName);
	$("#form-map").submit();
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
<span style="font-family: Arial; font-size:18px;"><span style="background-color:black; color: white;">C</span><span style="background-color:#FF9900; color: white;">PAS</span> <span style="color: blue; font-family: Arial; font-size:18px; font-weight:bold;">Treeview</span></span>
</td>
<!-- <td nowrap><h2 style="color: blue;">Genie</h2></td> -->
<td><b><%= cn.getUrlString() %></b></td>
<td nowrap>

<a href="index.jsp">Home</a> |
<a href="query.jsp" target="_blank">Query</a> |
<a href="cpas-process.jsp" target="_blank">CPAS Process</a> 
&nbsp;&nbsp;&nbsp;
<a href="Javascript:exposedRules()">Exposed Rule</a>

</td>
<td align=right nowrap>
<b>TreeView Search</b> <input id="globalSearch" style="width: 200px;" onChange="tvSearch($('#globalSearch').val())" placeholder="treeview item or table/view"/>
<input type="button" value="Find" onClick="Javascript:tvSearch($('#globalSearch').val())"/>
</td>
</table>
</div>
<div style="height: 4px;"></div>

	<table border=0 cellspacing=0>
		<td valign=top>
			<div id="outer-sdi">
				<div id="inner-sdi">
				</div>
			</div>
		</td>
		<td valign=top>
			<div id="outer-tv">
				<div id="inner-tv" style="width: 400px;"></div>
			</div>
		</td>
		<td valign=top>
			<div id="outer-tvstmt">
				<div id="inner-tvstmt"></div>
			</div>
		</td>
	</table>

<form id="FORM_query" name="FORM_query" action="query.jsp" target="_blank" method="post">
<input id="sql-query" name="sql" type="hidden"/>
</form>
<form name="form-map" id="form-map" action="package-tree.jsp" target="_blank" method="get">
<input id="name-map" name="name" type="hidden">
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