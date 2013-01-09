<%@ page language="java" import="java.util.*" import="java.sql.*"
	import="spencer.genie.*" contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"%>

<%
	Connect cn = (Connect) session.getAttribute("CN");
	String sdi = request.getParameter("sdi");
	String treekey = request.getParameter("treekey");
	String actionId = null;
	if (sdi!=null && treekey !=null) {
		actionId = cn.queryOne("SELECT actionid FROM CUSTOMTREEVIEW WHERE SDI = '"+sdi+"' AND TREEKEY='"+treekey+"'");
	}
%>

<html>
<head>
<title>CPAS Custom Tree View</title>

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
    width: 250px;
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
	loadTV('<%=sdi%>');
	loadSTMT('<%=sdi%>',<%=actionId%>,'<%=treekey%>');
<% } %>	
})

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
		url: "ajax-cpas/load-CTV.jsp?sdi=" + sdi + "&t=" + (new Date().getTime()),
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
		url: "ajax-cpas/load-CSTMT.jsp?sdi=" + sdi + "&actionid=" + actionid + "&t=" + (new Date().getTime()),
		success: function(data){
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

</script>

</head>

<body>

	<table width=100% border=0>
		<td><img src="image/cpas.jpg"
			title="Version <%=Util.getVersionDate()%>" /></td>
		<td><h2 style="color: blue;">CPAS Custom Tree View</h2></td>
		<td>&nbsp;</td>

		<td>
<a href="index.jsp">Home</a> |
<a href="query.jsp" target="_blank">Query</a> |
<a href="cpas-process.jsp" target="_blank">CPAS Process</a> 
		</td>
		<td align=right><h3><%=cn.getUrlString()%></h3></td>
	</table>

	<table border=0 cellspacing=0>
		<td valign=top>
			<div id="outer-sdi">
				<div id="inner-sdi">
				</div>
			</div>
		</td>
		<td valign=top>
			<div id="outer-tv">
				<div id="inner-tv"></div>
			</div>
		</td>
		<td valign=top>
			<div id="outer-tvstmt">
				<div id="inner-tvstmt"></div>
			</div>
		</td>
	</table>

<form id="FORM_query" name="FORM_query" action="query.jsp" target="_blank" method="post">
<input id="sql" name="sql" type="hidden"/>
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