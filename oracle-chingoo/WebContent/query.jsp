<%@ page language="java" 
	import="java.util.*" 
	import="java.util.Date" 
	import="java.sql.*" 
	import="chingoo.oracle.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<%!
	ArrayList<String> getBindVariableList(String qry) {
		ArrayList<String> al = new ArrayList<String>();
		if (qry==null) return al;
		StringTokenizer st = new StringTokenizer(qry, " =)\n");
		while (st.hasMoreTokens()) {
			String token = st.nextToken().trim();
			if (token.startsWith(":")) {
				System.out.println("token=" + token);
				al.add(token);
			}
		}
	
		return al;
	}

	public boolean isTable(String tname) {
		String temp = tname.toUpperCase().trim();
	
		if (tname.contains("\'")) return false;
		if (tname.contains(" ")) return false;
		return true;
	}
%>
<%
	Connect cn = (Connect) session.getAttribute("CN");
	
	int counter = 0;
	String sql = request.getParameter("sql");
	boolean isDynamic = false;
	
	ArrayList<String> varAl = getBindVariableList(sql);
	if (varAl.size() >0 ) isDynamic = true;
	
	String upto = request.getParameter("upto");
	if (upto == null || upto.equals("")) upto = "1000";

	String key = request.getParameter("key");
	String value = request.getParameter("value");
	
	if (key != null && value != null && sql == null) {
		value = value.trim();
		if (key.equals("processid"))
			sql = "SELECT * FROM BATCH WHERE processid='" + value + "'";
		else if (key.equals("mkey"))
			sql = "SELECT * FROM MEMBER WHERE mkey='" + value + "'";
		else if (key.equals("accountid"))
			sql = "SELECT * FROM ACCOUNT WHERE accountid='" + value + "'";
		else if (key.equals("penid"))
			sql = "SELECT * FROM PENSIONER WHERE penid='" + value + "'";
		else if (key.equals("personid"))
			sql = "SELECT * FROM PERSON WHERE personid='" + value + "'";
		else if (key.equals("calcid"))
			sql = "SELECT * FROM CALC WHERE calcid='" + value + "'";
		else if (key.equals("errorid"))
			sql = "SELECT * FROM ERRORCAT WHERE errorid='" + value + "'";
		else if (key.equals("requestid"))
			sql = "SELECT * FROM REQUEST WHERE requestid='" + value + "'";
	}
	
	int maxRow = Integer.parseInt(upto);
	
	String norun = request.getParameter("norun");

	if (sql==null) {
		sql = "SELECT * FROM TAB";
		norun = "Y";
	}
	sql = sql.trim();
	if (sql.endsWith(";")) sql = sql.substring(0, sql.length()-1);
	sql = sql.replaceAll("&gt;",">").replace("&lt;","<");

	
	String sqlh = sql;
	String dynamicVars = request.getParameter("dynamicVars");
	//System.out.println("*** dynamicVars=" + dynamicVars);
	if (dynamicVars!=null && dynamicVars.length() > 0) {
		isDynamic = true;
		String[] vars = dynamicVars.split(" ");
		for (String var : vars) {
			System.out.println("* " + var + ": " + request.getParameter(var));
			sqlh = sqlh.replaceAll(var, "'" + request.getParameter(var) + "'");
		}
	}	
	int lineLength = Util.countLines(sql);
	if (lineLength <3) lineLength = 4;
	if (lineLength >50) lineLength = 50;
	
	cn.queryCache.removeQuery(sqlh);
	Query q = null;
	
	if (norun==null) {
		q = new Query(cn, sqlh, maxRow);
		System.out.println(cn.getUrlString() + " " + Util.getIpAddress(request) + " " + (new java.util.Date()) + "\nQuery: " + sql);
		if (q.isError()) System.out.println("Error: " + q.getMessage());
		else System.out.println("Count: " + q.getRecordCount());

		if (!q.isError())
			cn.queryCache.addQuery(sqlh, q);
	}
	
	// get table name
	String tbl = null;
	List<String> tbls = Util.getTables(sql); 
	if (tbls.size()>0) tbl = tbls.get(0);
//	System.out.println("XXX TBL=" + tbl);
	
	String title = sql;
	if (title.length() > 100) title = title.substring(0,100) + " ...";
%>

<html>
<head> 
	<title><%= title %></title>
    <script src="script/jquery-1.7.2.min.js" type="text/javascript"></script>

    <script src="script/data-methods.js?<%= Util.getScriptionVersion() %>" type="text/javascript"></script>
    <script src="script/query-methods.js?<%= Util.getScriptionVersion() %>" type="text/javascript"></script>

    <link rel='stylesheet' type='text/css' href='css/style.css?<%= Util.getScriptionVersion() %>'>
	<link rel="icon" type="image/png" href="image/chingoo-icon.png">

	<link rel="stylesheet" href="css/ui-lightness/jquery-ui-1.8.18.custom.css" type="text/css"/>
	<script src="script/jquery-ui-1.8.18.custom.min.js" type="text/javascript"></script>
    
    <script type="text/javascript">
	$(document).ready(function() {
<% for (String tname : tbls) { 
		if (isTable(tname)) {
%>
			showTable('<%=tname%>');
<%
		}
	} 
%>
		setDoMode('sort');
		var cnt = $("#recordCount").val();
		if (cnt != "0") $("#buttonsDiv").slideDown();
	});	    
	
    $(document).ready(function(){
    	setHighlight();
      });
    </script>
    
	<style>
	.ui-autocomplete-loading { background: white url('image/ui-anim_basic_16x16.gif') right center no-repeat; }
.ui-autocomplete {
		max-height: 300px;
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
		height: 300px;
	}	
	</style>
	<script>
	$(function() {
		function addTable( tname ) {
			if (tname == "") return;
			showTable(tname);
		}

		$( "#tablesearch-xxx" ).autocomplete({
			source: "ajax/auto-complete.jsp",
			minLength: 2,
			select: function( event, ui ) {
				addTable( ui.item ?
					ui.item.value: "" );
			}
		});

		$( "#tablesearch" ).autocomplete({
			source: "ajax/auto-complete.jsp",
			minLength: 2,
			select: function( event, ui ) {
				addTable( ui.item ?
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
	
	function explainPlan() {
		if ($("#explainPlan").is(':visible')) {
			$("#explainPlan").slideUp();
			return;
		}
		
		$.ajax({
			type: 'POST',
			url: "ajax/explain-plan.jsp",
			data: $("#form1").serialize(),
			success: function(data){
				$("#explainPlan").html(data);
				$("#explainPlan").slideDown();
//				$("#wait").remove();
			},
	        error:function (jqXHR, textStatus, errorThrown){
	            alert(jqXHR.status + " " + errorThrown);
	        }  
		});	
	}
	
	function editQuery() {
		$("#queryMain").slideToggle();		
	}
	
	function reloadQuery() {
		$("#form1").submit();		
	}
	
	</script>    
</head> 

<body>

<table>
<td>
<img src="image/icon_query.png" align="middle"/> <b>QUERY</b>
</td>
<td>
<b><%= cn.getUrlString() %></b>
&nbsp;&nbsp;&nbsp;
</td>
<td>
<a href="query.jsp" target="_blank">Query</a> |
<a href="q.jsp" target="_blank">Q</a> |
<a href="erd_svg.jsp?tname=<%= tbl %>" target="_blank">ERD</a> |
<a href="worksheet.jsp" target="_blank">Work Sheet</a>
</td>
<td>&nbsp;&nbsp;&nbsp;</td>
<td>
Search <input id="globalSearch" style="width: 200px;"/>
</td>
</table>
<br/>

<div id="queryMain">

<a href="Javascript:toggleHelp()"><img  style="float: left" id="helpDivImage" border="0" src="image/minus.gif"></a>
<div id="div-help" style="float: left">
	<a id="showERD" href="Javascript:showERD('<%=tbl%>')">Show ERD</a>
	<div id="tableList1" style="margin-left: 5px;">
<%-- 	<a href="Javascript:showRelatedTables('<%=tbl%>')">Show Related Tables</a>
 --%>
 	</div>

<div class="ui-widget">
	<label for="tablesearch">Table/View: </label>
	<input id="tablesearch" style="width: 200px;"/>
</div>

	<div id="table-detail"></div>

	<div>
	<a href="Javascript:copyPaste('SELECT');">SELECT</a>&nbsp;
	<a href="Javascript:copyPaste('*');">*</a>&nbsp;
	<a href="Javascript:copyPaste('FROM');">FROM</a>&nbsp;
	<a href="Javascript:copyPaste('WHERE');">WHERE</a>&nbsp;
	<a href="Javascript:copyPaste('=');">=</a>&nbsp;
	<a href="Javascript:copyPaste('LIKE');">LIKE</a>&nbsp;
	<a href="Javascript:copyPaste('\'%\'');">'%'</a>&nbsp;
	<a href="Javascript:copyPaste('IS');">IS</a>&nbsp;
	<a href="Javascript:copyPaste('NOT');">NOT</a>&nbsp;
	<a href="Javascript:copyPaste('NULL');">NULL</a>&nbsp;
	<a href="Javascript:copyPaste('AND');">AND</a>&nbsp;
	<a href="Javascript:copyPaste('OR');">OR</a>&nbsp;
	<a href="Javascript:copyPaste('IN');">IN</a>&nbsp;
	<a href="Javascript:copyPaste('( )');">( )</a>&nbsp;
	<a href="Javascript:copyPaste('EXISTS');">EXISTS</a>&nbsp;
	<a href="Javascript:copyPaste('ORDER BY');">ORDER-BY</a>&nbsp;
	<a href="Javascript:copyPaste('DESC');">DESC</a>&nbsp;
<!-- 
	<br/>
	&nbsp;&nbsp;&nbsp;
	<a href="Javascript:copyPaste('LOWER( )');">LOWER( )</a>&nbsp;
	<a href="Javascript:copyPaste('UPPER( )');">UPPER( )</a>&nbsp;
	<a href="Javascript:copyPaste('SUBSTR( )');">SUBSTR( )</a>&nbsp;
	<a href="Javascript:copyPaste('TRIM( )');">TRIM( )</a>&nbsp;
	<a href="Javascript:copyPaste('LENGTH( )');">LENGTH( )</a>&nbsp;
	&nbsp;&nbsp;&nbsp;
	<a href="Javascript:copyPaste('TO_DATE( )');">TO_DATE( )</a>&nbsp;
	<a href="Javascript:copyPaste('TO_NUMBER( )');">TO_NUMBER( )</a>&nbsp;
	<a href="Javascript:copyPaste('TO_CHAR( )');">TO_CHAR( )</a>&nbsp;

 -->
 	<br/>
	&nbsp;&nbsp;&nbsp;
	<a href="Javascript:copyPaste('GROUP BY');">GROUP-BY</a>&nbsp;
	<a href="Javascript:copyPaste('HAVING');">HAVING</a>&nbsp;
	<a href="Javascript:copyPaste('COUNT(*)');">COUNT(*)</a>&nbsp;
	<a href="Javascript:copyPaste('SUM( )');">SUM( )</a>&nbsp;
	<a href="Javascript:copyPaste('AVG( )');">AVG( )</a>&nbsp;
	<a href="Javascript:copyPaste('MIN( )');">MIN( )</a>&nbsp;
	<a href="Javascript:copyPaste('MAX( )');">MAX( )</a>&nbsp;
	
	</div>
</div>
<br clear="all"/>

<form name="form1" id="form1" method="post" action="query.jsp">
<textarea id="sql1" name="sql" cols=100 rows=<%= lineLength %>><%= sql %></textarea><br/>

<%
	if (isDynamic) {
		String varlist = "";
		for (String var:varAl) {
			varlist += var + " ";
			String dval = request.getParameter(var);
			if (dval==null) dval = "";
%>
	<%= var %> <input name="<%= var %>" value="<%= dval %>" length=30>
<%
		}
%>
		<br/>
		<input name="dynamicVars" value="<%= varlist.trim() %>" type="hidden"/>
<%		
	}
%>


Up to 
<select name="upto">
<option value="100" <%= maxRow==100?"SELECTED":"" %>>100</option>
<option value="500" <%= maxRow==500?"SELECTED":"" %>>500</option>
<option value="1000" <%= maxRow==1000?"SELECTED":"" %>>1,000</option>
<option value="5000" <%= maxRow==5000?"SELECTED":"" %>>5,000</option>
<option value="10000" <%= maxRow==10000?"SELECTED":"" %>>10,000</option>
<option value="50000" <%= maxRow==50000?"SELECTED":"" %>>50,000</option>
</select>
<!-- 
<input type="submit" name="submit" value="Submit"/>
 -->
<input type="button" value="Submit" onClick="Javascript:submitQuery()"/>
<!-- &nbsp;
<input type="button" value="Download" onClick="Javascript:download()"/>
&nbsp;
<input type="button" value="Explain plan" onClick="Javascript:explainPlan()"/>
 -->
</form>

</div> <!-- end of query main -->

<form name="form0" id="form0">
<textarea style="display: none;" id="sql" name="sql" ><%= sql %></textarea>
<input type="hidden" id="sortColumn" name="sortColumn" value="">
<input type="hidden" id="sortDirection" name="sortDirection" value="0">
<input type="hidden" id="hideColumn" name="hideColumn" value="">
<input type="hidden" id="filterColumn" name="filterColumn" value="">
<input type="hidden" id="filterValue" name="filterValue" value="">
<input type="hidden" id="filter2" name="filter2" value="">
<input type="hidden" id="searchValue" name="searchValue" value="">
<input type="hidden" id="pageNo" name="pageNo" value="1">
<input type="hidden" id="rowsPerPage" name="rowsPerPage" value="20">
<input type="hidden" id="dataLink" name="dataLink" value="1">
<input type="hidden" id="preFormat" name="preFormat" value="0">
</form>

<form id="FormPop" name="FormPop" target="_blank" method="post" action="pop.jsp">
<input id="popType" name="type" type="hidden" value="OBJECT">
<input id="popKey" name="key" type="hidden">
</form>

<div id="explainPlan" style="display: none;"></div>

<%= q==null?"":q.getMessage() %>

<%
	if (norun!=null || !q.hasMetaData()) {
%>
<br/><br/>
<a href="Javascript:window.close()">Close</a>
<br/><br/>

</body>
</html>
<%
		return;		
	}
%>

<hr noshade color="green"/>
<br/>

<div id="buttonsDiv" style="display: none;">
<TABLE>
<TD><a class="qryBtn" id="modeSort" href="Javascript:setDoMode('sort')">Sort</a>
<TD><a class="qryBtn" id="modeCopy" href="Javascript:setDoMode('copy')">Copy&amp;Paste</a></TD>
<TD><a class="qryBtn" id="modeCopy" href="Javascript:setTranspose()">Transpose</a></TD>
<!-- 
<TD><a class="qryBtn" id="modeHide" href="Javascript:setDoMode('hide')">Hide Column</a>
	<span id="showAllCol" style="display: none;">
		<a href="Javascript:showAllColumn()">Show All Column</a>&nbsp;
	</span>
</TD>

 -->
</TD>
<!-- 
<TD><a class="qryBtn" id="modeFilter" href="Javascript:setDoMode('filter')">Filter</a></TD>
<TD><span id="filter-div"></span></TD>
 -->
<TD><a class="qryBtn" id="modeFilter2" href="Javascript:setDoMode('filter2')">Filter</a></TD>

<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
<td>
<input type="button" value="Transpose" onClick="Javascript:setTranspose()"/>
</td>
<td>
<input type="button" value="Filter" onClick="Javascript:filter2()"/>
</td>
<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
<td>
<input type="button" value="Download" onClick="Javascript:download()"/>
</td>
<td>
<input type="button" value="Explain plan" onClick="Javascript:explainPlan()"/>
</td>
<td>
<input type="button" value="Reload" onClick="Javascript:reloadQuery()"/>
</td>

</TABLE>
</div>
<BR/>
<div id="filter2-div" style="display:none"></div>

<div id="data-div">
<jsp:include page="ajax/qry.jsp">
	<jsp:param value="<%= sqlh%>" name="sql"/>
	<jsp:param value="1" name="pageNo"/>
	<jsp:param value="" name="sortColumn"/>
	<jsp:param value="0" name="sortDirection"/>
	<jsp:param value="" name="filterColumn"/>
	<jsp:param value="" name="filterValue"/>
	<jsp:param value="1" name="dataLink"/>
</jsp:include>
</div>

<br/>
<a href="Javascript:window.close()">Close</a>
<br/><br/>


<script type="text/javascript">

  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', '<%= Util.trackingId() %>']);
  _gaq.push(['_setDomainName', 'none']);
  _gaq.push(['_trackPageview']);

  _gaq.push(['_trackEvent', 'Query', 'Query <%= tbl %>']);
  
  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();

  $(document).ready(function(){
  	$("#queryMain").slideUp();
   });

</script>


</body>
</html>