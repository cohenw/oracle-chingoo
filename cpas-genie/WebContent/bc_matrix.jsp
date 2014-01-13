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

	if (calcid.equals("")) {
		calcid = cn.queryOne("SELECT MAX(calcid) FROM CALC");
	}

	String clnt=null;
	if (!calcid.equals(""))
		clnt = cn.queryOne("SELECT CLNT FROM CALC WHERE CALCID="+calcid);
	
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
	    $( "#datepicker1" ).datepicker();
	    $( "#datepicker2" ).datepicker();
	  });
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
Calc ID <input name="calcid" value="<%= calcid %>" size=10>
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
<%-- <br/>
From Date <input name="fdate" type="text" id="datepicker1" value="<%= fdate %>" size=10/>
To Date <input name="tdate" type="text" id="datepicker2" value="<%= tdate %>" size=10/>
 --%>
<input type="submit" value="Run"> 
</form>

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

<pre style="font-family: Consolas; font-size: 14px;"></pre>
<pre>
<%
	if (!calcid.equals("")) {
		String sql = "BEGIN MAIN_RULEBUILD.TESTMATRIX("+calcid+ ",'" + var1 + "','" + var2 + "','" + var3 + "',null,null,'*','D'); END;";
		Util.p(sql);
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

</body>
</html>

