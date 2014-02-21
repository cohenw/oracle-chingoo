<%@ page language="java" 
	import="java.util.*" 
	import="java.util.Date" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<%
	Connect cn = (Connect) session.getAttribute("CN");
	String calcid = Util.nvl(request.getParameter("calcid"));
	String var1 = Util.nvl(request.getParameter("var1"));
	String var2 = Util.nvl(request.getParameter("var2"));
	String var3 = Util.nvl(request.getParameter("var3"));
	String fdate = Util.nvl(request.getParameter("fdate"));
	String tdate = Util.nvl(request.getParameter("tdate"));
	boolean isRun = true; 
	String mkey=null;

	if (calcid.equals("")) {
		calcid = cn.queryOne("SELECT MAX(calcid) FROM CALC");
		isRun = false;
	}

	String clnt=null;
	if (!calcid.equals(""))
		clnt = cn.queryOne("SELECT CLNT FROM CALC WHERE CALCID="+calcid);
		mkey = cn.queryOne("SELECT MKEY FROM CALC WHERE CALCID="+calcid);
	
	String qry = "SELECT DISTINCT VARNAME, VARDESC FROM PLAN_MATRIX A ORDER BY 2";
	if (clnt!=null) {
		qry = "SELECT DISTINCT VARNAME, VARDESC FROM PLAN_MATRIX A WHERE CLNT='"+clnt+"' ORDER BY 1";
	}
	
	List<String[]> varnames = cn.query(qry);
/*	
	Util.p("clnt=" + clnt);
	for (String[] var: varnames) {
		Util.p(var[1] + ":" + var[2]);
	}
*/	
%>
<html>
<head> 
	<title>Matrix Test</title>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" /> 

    <script src="script/jquery-1.7.2.min.js" type="text/javascript"></script>
    <script src="script/genie.js?<%= Util.getScriptionVersion() %>" type="text/javascript"></script>
    <script src="script/data-methods.js?<%= Util.getScriptionVersion() %>" type="text/javascript"></script>

    <link rel='stylesheet' type='text/css' href='css/style.css?<%= Util.getScriptionVersion() %>'>
	<link rel="icon" type="image/png" href="image/Genie-icon.png">

	<link rel="stylesheet" href="css/ui-lightness/jquery-ui-1.8.18.custom.css" type="text/css"/>
	<script src="script/jquery-ui-1.8.18.custom.min.js" type="text/javascript"></script>

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
		$("#popKey").val(oname);
    	$("#FormPop").submit();
	}
	    
	$(function() {
	    $( "#datepicker1" ).datepicker( { dateFormat: "yymmdd", changeMonth: true, changeYear: true } );
	    $( "#datepicker2" ).datepicker( { dateFormat: "yymmdd", changeMonth: true, changeYear: true } );
	  });

	function toggleMemberInfo() {
		var src = $("#imgMemberInfo").attr('src');
		//alert(src);
		var data = $("#MemberInfo").html();
		if (data == '') {
			$("#MemberInfo").show();
			$("#MemberInfo").html('<img src="image/waiting_big.gif">');
			// AJAX load
			$.ajax({
				url: "ajax-cpas/member-info.jsp?clnt=<%=clnt%>&mkey=<%=mkey%>" + "&t=" + (new Date().getTime()),
				success: function(data){
					$("#MemberInfo").html(data);
				},
	            error:function (jqXHR, textStatus, errorThrown){
	                alert(jqXHR.status + " " + errorThrown);
	            }  
			});
			$("#imgMemberInfo").attr('src','image/minus.gif');
			return;
		}
		if (src.indexOf("minus")>0) {
			$("#MemberInfo").slideUp();
			$("#imgMemberInfo").attr('src','image/plus.gif');
		} else {
			$("#MemberInfo").slideDown();
			$("#imgMemberInfo").attr('src','image/minus.gif');
		}
	}

	function toggleMemberService() {
		var src = $("#imgMemberService").attr('src');
		//alert(src);
		var data = $("#MemberService").html();
		if (data == '') {
			$("#MemberService").show();
			$("#MemberService").html('<img src="image/waiting_big.gif">');
			// AJAX load
			$.ajax({
				url: "ajax-cpas/service-timeline.jsp?clnt=<%=clnt%>&mkey=<%=mkey%>" + "&t=" + (new Date().getTime()),
				success: function(data){
					$("#MemberService").html(data);
				},
	            error:function (jqXHR, textStatus, errorThrown){
	                alert(jqXHR.status + " " + errorThrown);
	            }  
			});
			$("#imgMemberService").attr('src','image/minus.gif');
			return;
		}
		if (src.indexOf("minus")>0) {
			$("#MemberService").slideUp();
			$("#imgMemberService").attr('src','image/plus.gif');
		} else {
			$("#MemberService").slideDown();
			$("#imgMemberService").attr('src','image/minus.gif');
		}
	}



	
	</script>
    
</head> 

<body>
<%
	String id = Util.getId();
%>

<div style="background-color: #E6F8E0; padding: 6px; border:1px solid #CCCCCC; border-radius:10px;">
<img src="image/star-big.png" width=20 height=20 align="top"/>
<span style="color: blue; font-family: Arial; font-size:16px; font-weight:bold;">Matrix Test</span>
 
&nbsp;&nbsp;
<b><%= cn.getUrlString() %></b>

&nbsp;&nbsp;&nbsp;&nbsp;

<a href="Javascript:hideNullColumn()">Hide Null</a> |
<a href="Javascript:newQry()">Pop Query</a> |
<a href="query.jsp" target="_blank">Query</a> |
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<!-- <a href="Javascript:openWorksheet()">Open Work Sheet</a>
 -->
<span style="float:right;">
Search <input id="globalSearch" style="width: 200px;" placeholder="table or view name"/>
</span>
</div>

<br/>

<form method="get">
Calc ID <input name="calcid" value="<%= calcid %>" size=8>
Variable 1 
<select name="var1" style="width: 160px;">
<option></option>
<%
	for (String[] var: varnames) {
%>
<option value="<%=var[1]%>" <%= (var1.equals(var[1])?"SELECTED":"") %>><%=var[1]%>: <%=var[2]%></option>
<%		
	}
%>
</select>
<%-- <input name="var1" value="<%= var1 %>" size=10> --%>
Variable 2 
<select name="var2" style="width: 160px;">
<option></option>
<%
	for (String[] var: varnames) {
%>
<option value="<%=var[1]%>" <%= (var2.equals(var[1])?"SELECTED":"") %>><%=var[1]%>: <%=var[2]%></option>
<%		
	}
%>
</select>
<%-- <input name="var2" value="<%= var2 %>" size=10> --%>
Variable 3 
<select name="var3" style="width: 160px;">
<option></option>
<%
	for (String[] var: varnames) {
%>
<option value="<%=var[1]%>" <%= (var3.equals(var[1])?"SELECTED":"") %>><%=var[1]%>: <%=var[2]%></option>
<%		
	}
%>
</select>
<%-- <input name="var3" value="<%= var3 %>" size=10> --%>

From Date <input name="fdate" type="text" id="datepicker1" value="<%= fdate %>" size=8/>
To Date <input name="tdate" type="text" id="datepicker2" value="<%= tdate %>" size=8/>

<input type="submit" value="Run"> 
</form>

<% if (!isRun)  { %>
</body>
</html>
<% 		return;
	} %>


<hr>
<% if (!calcid.equals("")) {%>
<div id="div-<%=id%>">
<jsp:include page='ajax/qry-simple.jsp'>
	<jsp:param value='<%= "SELECT * FROM CALC WHERE CALCID="+calcid %>' name="sql"/>
	<jsp:param value="1" name="dataLink"/>
	<jsp:param value="<%= id %>" name="id"/>
</jsp:include>
</div>
<br/>
<% } %>

<a href="javascript:toggleMemberService()"><span style="color: blue; font-family: Arial; font-size:16px; font-weight:bold;">Service Timeline</span><img id="imgMemberService" src="image/plus.gif"></a>
<br/>
<div id="MemberService" style="display: none; margin-left:20px;"></div>
<br/>

<a href="javascript:toggleMemberInfo()"><span style="color: blue; font-family: Arial; font-size:16px; font-weight:bold;">Member Tables</span><img id="imgMemberInfo" src="image/plus.gif"></a>
<br/>
<div id="MemberInfo" style="display: none;"></div>
<br/>


<pre style="font-family: Consolas; font-size: 14px;"></pre>
<pre>
<%
	if (!calcid.equals("")) {
//		String sql = "BEGIN MAIN_RULEBUILD.TESTMATRIX("+calcid+ ",'" + var1 + "','" + var2 + "','" + var3 + "',null,null,'*','D'); END;";
		String sql = "BEGIN MAIN_RULEBUILD.TESTMATRIX("+calcid+ ",'" + var1 + "','" + var2 + "','" + var3 + "',to_date('"+fdate+"','yyyymmdd'),to_date('"+tdate+"','yyyymmdd'),'*','D'); END;";
		//Util.p(sql);
		CallableStatement call = cn.getConnection().prepareCall(sql);
		call.execute();
		call.close();

		List<String> lines = cn.queryMulti("SELECT LINETEXT FROM CT$MATRIX ORDER BY LINENO", false);
		
		for (String ln:lines) {
			out.println(Util.nvl(ln));
		}
	}
%>
</pre>

<form id="FormPop" name="FormPop" target="_blank" method="post" action="pop.jsp">
<input id="popType" name="type" type="hidden" value="OBJECT">
<input id="popKey" name="key" type="hidden">
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

<form id="FORM_query" name="FORM_query" action="query.jsp" target="_blank" method="post">
<input id="sql-query" name="sql" type="hidden"/>
</form>

<div style="display: none;">
<form name="form0" id="form0" action="query.jsp" target="_blank">
<input id="sql" name="sql" type="hidden" value=""/>
<input id="dataLink" name="dataLink" type="hidden" value="1"/>
<input id="id" name="id" type="hidden" value=""/>
<input id="showFK" name="showFK" type="hidden" value="0"/>
<input type="hidden" id="sortColumn" name="sortColumn" value="">
<input type="hidden" id="sortDirection" name="sortDirection" value="0">
<input type="hidden" id="hideColumn" name="hideColumn" value="">
<input type="hidden" id="filterColumn" name="filterColumn" value="">
<input type="hidden" id="filterValue" name="filterValue" value="">
<input type="hidden" id="searchValue" name="searchValue" value="">
<input type="hidden" id="pageNo" name="pageNo" value="1">
<input type="hidden" id="rowsPerPage" name="rowsPerPage" value="20">
</form>
</div>

</body>
</html>

