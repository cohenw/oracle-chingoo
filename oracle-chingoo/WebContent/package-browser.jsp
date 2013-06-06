<%@ page language="java" import="java.util.*" import="java.sql.*"
	import="chingoo.oracle.*" contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"%>

<%
	Connect cn = (Connect) session.getAttribute("CN");
	String qry = "SELECT object_name FROM user_objects where object_type in ('PACKAGE BODY') order by 1";	

	Query q = new Query(cn, qry, false);
	String name = request.getParameter("name");
	if (name != null) name = name.toUpperCase();
	String gPkg = "";
	String gPrc = "";
	if (name != null) {
		int idx = name.indexOf(".");
		if (idx <0) {
			gPkg = name;
		} else {
			gPkg = name.substring(0, idx);
			gPrc = name.substring(idx+1);
		}
	}
%>

<html>
<head>
<title>Package Browser</title>

<meta name="description"
	content="Chingoo is an open-source, web based oracle database schema navigator." />
<meta name="keywords" content="Oracle Web Database OpenSource JDBC" />
<meta name="author" content="Spencer Hwang" />

<script src="script/jquery-1.7.2.min.js" type="text/javascript"></script>
<script src="script/jquery-ui-1.8.18.custom.min.js"	type="text/javascript"></script>
<script src="script/chingoo.js?<%=Util.getScriptionVersion()%>" type="text/javascript"></script>

<link rel="icon" type="image/png" href="image/chingoo-icon.png">
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
    width: 250px;
    height: 600px;
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
var gPackage = "";
var pProc = "";

var stack = [];
var stackFwd = [];

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
	
	loadProc('<%=gPkg%>', '<%=gPrc%>');
	showNavButton();
})

	function checkResize() {
		var w = $(window).width();
		var h = $(window).height();
	
		if (h > 500) {
			var newH = h - 80;
			var diff = $('#outer-tab').position().top - $('#outer-tab').position().top;

			$('#outer-tab').height(newH);
			$('#outer-event').height(newH);
			$('#outer-eventview').height(newH);
			
			var tmp = w - $('#outer-tab').width() - 50; 

			if (tmp < 600) tmp = 600;
			$('#outer-eventview').width(tmp- 213);			
		}
	}

function loadPackage(pName) {
	$("#inner-event").html('');
	$("#inner-eventview").html('');
	$.ajax({
		url: "ajax/load-package.jsp?name=" + pName,
		success: function(data){
			$("#inner-event").html(data);
			$('#inner-event a').click( function(e) {
			    $('#inner-event a.selected').removeClass('selected');
			    $(this).addClass('selected');
			});
			gPackage = pName;
		},
        error:function (jqXHR, textStatus, errorThrown){
            alert(jqXHR.status + " " + errorThrown);
        }  
	});	
}

function loadProc(pkgName, prcName) {
	loadProc2(pkgName, prcName, 1);
	stackFwd = [];
}

function loadProc2(pkgName, prcName, saveHistory) {
	$("#inner-eventview").html('');

	if (pkgName != gPackage) {
		loadPackage(pkgName);
	}
//	console.log("saveHistory=" +saveHistory);
	$.ajax({
		url: "ajax-cpas/load-proc.jsp?key=" + pkgName + "." + prcName,
		success: function(data){
			$("#inner-eventview").html(data);
			setHighlight();
			gPackage = pkgName;
			gProcedure = prcName;
			window.setTimeout(function() {
				setYellow(gPackage, gProcedure);
			}, 400);
			if (saveHistory=="1") {
				stack.push(pkgName + "." + prcName);
			}
			showNavButton();
		},
        error:function (jqXHR, textStatus, errorThrown){
            alert(jqXHR.status + " " + errorThrown);
        }  
	});
}	

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

function setYellow(pkg, prc) {
	$('#inner-tab a.selected').removeClass('selected');
	$('#inner-event a.selected').removeClass('selected');
	var pkgId = "pkg-" + replaceall(pkg, "$", "_");
	//console.log(pkgId);
	$('#' + pkgId ).addClass('selected');
	$('#prc-' + prc ).addClass('selected');
	
	if ($('#' + pkgId).length) {
		var newTop = $('#' + pkgId ).position().top - $('#inner-tab').position().top;
		$('#outer-tab').animate({scrollTop: newTop }, 500);
	}
	
	if ($('#prc-' + prc).length) {
		var newTop = $('#prc-' + prc ).position().top - $('#inner-event').position().top;
		$('#outer-event').animate({scrollTop: newTop }, 500);
	} 
}

function toggleData(id) {
	var key = $("#key-" + id).html();
	var divName = "div-" + id;
	
	var imgSrc = $("#img-" + id).attr("src");
	//alert(imgSrc);
	if (imgSrc.indexOf("plus") > 0) {
		$("#img-" + id).attr("src","image/minus.gif");
	} else {
		$("#img-" + id).attr("src","image/plus.gif");
		$("#" + divName).slideUp();
		return;
	}

	if ($("#" + divName).html().length > 3){
		$("#" + divName).slideDown();
		return;
	}
	
	$("#key").val(key);
	$("#id").val(id);
	$("#" + divName).hide();
//alert("key=" + key);	
	$.ajax({
		type: 'POST',
		url: "ajax/pkg-proc-detail.jsp",
		data: $("#form0").serialize(),
		success: function(data){
			$("#" + divName).html(data);
			$("#" + divName).slideDown();
			//alert(data);
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

function showNavButton() {
	if (stack.length > 1 )
		$("#imgBackward").show();
	else
		$("#imgBackward").hide();

	if (stackFwd.length > 0 )
		$("#imgForward").show();
	else
		$("#imgForward").hide();
	
	console.log(stack.length + "," + stackFwd.length);
	console.log(stack);
	console.log(stackFwd);
}

function goBack() {
	if (stack.length>1) {
		var data1 = stack.pop();
		var data = stack.pop();
		//alert(data);
		var tmp = data.split(".");
		loadProc2(tmp[0], tmp[1], 1);
//		$("#inner-result1").html(data);
//		stackFwd.push(current);
		showNavButton();
		stackFwd.push(data1);
	}
}

function goFoward() {
	if (stackFwd.length>0) {
		var data = stackFwd.pop();
		var tmp = data.split(".");
		loadProc2(tmp[0], tmp[1], 1);
		showNavButton();
	}
}
</script>

<style>
  .highlight { background:yellow; }
</style>

<script type="text/javascript">
var hi_v = "";
function hi_on(v) {
	if (hi_v != "") hi_off(hi_v);
	$("." + v).addClass("highlight");
	hi_v = v;
}
function hi_off(v) {
	$("." + v).removeClass("highlight");
}

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
</script>

</head>


<body>
	<table width=100% border=0>
		<td width=40><img src="image/package_ok.png"
			title="Version <%=Util.getVersionDate()%>" /></td>
		<td><h2 style="color: blue;">Package Browser</h2></td>
		<td></td>
		<td>&nbsp;</td>

		<td>
<a href="index.jsp">Home</a> |
<a href="query.jsp" target="_blank">Query</a>
		</td>
		<td><b><%=cn.getUrlString()%></b></td>

<td align=right nowrap>
<!-- <b>Global Search</b> <input id="globalSearch" style="width: 200px;" placeholder="table, view or package name"/>
<input type="button" value="Find" onClick="Javascript:globalSearch($('#globalSearch').val())"/>
 --></td>
 	</table>

	<table border=0 cellspacing=0>
		<td valign=top>
			<div id="outer-tab">
				<div id="inner-tab">
<%
	String id = Util.getId();
%>
<b>Packages</b>
<a href="javascript:openQuery('<%=id%>')"><img src="image/sql.png" border=0 align=middle  title="<%=qry%>"/></a>
<div style="display: none;" id="sql-<%=id%>"><%= qry%></div>
<br/>
			
<%
	q.rewind(1000, 1);
	int rowCnt = 0;
	while (q.next()) {
		String pname = q.getValue("object_name");
		String pkgId = "pkg-" + pname;
		pkgId = pkgId.replaceAll("\\$", "\\_");
%>
	<a id="<%= pkgId %>" href="Javascript:loadPackage('<%= pname %>')"><%= pname %></a><br/>
<%
	}
%>


				</div>
			</div>
		</td>
		<td valign=top>
			<div id="outer-event" style="margin-top: 0px;">
				<div id="inner-event">
				<b>Procedures</b><br>
				</div>
			</div>
		</td>
		<td valign=top>
		
			<div id="outer-eventview" style="margin-top: 0px; margin-left: 0px;">
	<div id="inner-nav">
		<a href="Javascript:goBack()"><img id="imgBackward" src="image/blue_arrow_left.png" title="back" border="0" style="display:none;"></a>
		&nbsp;&nbsp;
		<a href="Javascript:goFoward()"><img id="imgForward" src="image/blue_arrow_right.png" title="forward" border="0" style="display:none;"></a>
	</div>
				<div id="inner-eventview"></div>
			</div>
		</td>
	</table>

<form id="FORM_query" name="FORM_query" action="query.jsp" target="_blank" method="post">
<input id="sql-query" name="sql" type="hidden"/>
</form>

<div style="display: none;">
<form name="form0" id="form0">
<input id="key" name="key" type="hidden" value=""/>
<input id="id" name="id" type="hidden" value=""/>
</form>
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
