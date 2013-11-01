<%@ page language="java" 
	import="java.util.*" 
	import="java.util.Date" 
	import="java.sql.*" 
	import="spencer.genie.*" 
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
			if (token.startsWith(":") && !token.startsWith(":=") && token.length()>1) {
				System.out.println("token=" + token);
				if (!al.contains(token)) al.add(token);
			}
		}
		return al;
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
			sql = "SELECT * FROM BATCH WHERE PROCESSID='" + value + "'";
		else if (key.equals("mkey"))
			sql = "SELECT * FROM MEMBER WHERE MKEY='" + value + "'";
		else if (key.equals("memno"))
			sql = "SELECT * FROM MEMBER WHERE MEMNO='" + value + "'";
		else if (key.equals("accountid"))
			sql = "SELECT * FROM ACCOUNT WHERE ACCOUNTID='" + value + "'";
		else if (key.equals("penid"))
			sql = "SELECT * FROM PENSIONER WHERE PENID='" + value + "'";
		else if (key.equals("personid"))
			sql = "SELECT * FROM PERSON WHERE PERSONID='" + value + "'";
		else if (key.equals("calcid"))
			sql = "SELECT * FROM CALC WHERE CALCID='" + value + "'";
		else if (key.equals("errorid"))
			sql = "SELECT * FROM ERRORCAT WHERE ERRORID='" + value + "'";
		else if (key.equals("requestid"))
			sql = "SELECT * FROM REQUEST WHERE REQUESTID='" + value + "'";
		else if (key.equals("sin"))
			sql = "SELECT * FROM PERSON WHERE SIN='" + value + "'";
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
	if (lineLength <5) lineLength = 5;
	if (lineLength >50) lineLength = 50;
	
	cn.queryCache.removeQuery(sqlh);
	Query q = null;
	
	if (norun==null) {
		q = new Query(cn, sqlh, maxRow);
		//System.out.println(cn.getUrlString() + " " + Util.getIpAddress(request) + " " + (new java.util.Date()) + "\nQuery: " + sql);
		if (q.isError()) System.out.println("Error: " + q.getMessage());
		else System.out.println("Count: " + q.getRecordCount());

		if (!q.isError())
			cn.queryCache.addQuery(sqlh, q);
	}
	
	// get table name
	String tbl = null;
	//List<String> tbls = Util.getTables(sql); 
	List<String> tbls = new HyperSyntax().getTables(cn, sql);
//	System.out.println("XXX TBLS=" + tbls);

	if (tbls.size()>0) tbl = tbls.get(0);
//	System.out.println("XXX TBL=" + tbl);
	
	String title = sql;
	if (title.length() > 100) title = title.substring(0,100) + " ...";
%>

<html>
<head> 
	<title><%= title %></title>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" /> 

    <script src="script/jquery-1.7.2.min.js" type="text/javascript"></script>

    <script src="script/genie.js?<%= Util.getScriptionVersion() %>" type="text/javascript"></script>
    <script src="script/data-methods.js?<%= Util.getScriptionVersion() %>" type="text/javascript"></script>
<%--     <script src="script/query-methods.js?<%= Util.getScriptionVersion() %>" type="text/javascript"></script>
 --%>
    <link rel='stylesheet' type='text/css' href='css/style.css?<%= Util.getScriptionVersion() %>'>
	<link rel="icon" type="image/png" href="image/Genie-icon.png">

	<link rel="stylesheet" href="css/ui-lightness/jquery-ui-1.8.18.custom.css" type="text/css"/>
	<script src="script/jquery-ui-1.8.18.custom.min.js" type="text/javascript"></script>
    
    <script type="text/javascript">
	$(document).ready(function() {
<% for (String tname : tbls) { 
//	Util.p("*** " +  tname);
%>
		showTable('<%=tname%>');
<%
	} 
%>
		setDoMode('sort');
		var cnt = $("#recordCount").val();
		if (cnt != "0") $("#buttonsDiv").slideDown();
	});	    
	
    $(document).ready(function(){
    	setHighlight();
      });
    
    $(function() {
        $( "input[type=button], button" )
          .button()
          .click(function( event ) {
            event.preventDefault();
          });
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
	var doMode = 'copy';
	var qryPage = 'ajax/qry.jsp';
	
	function rowsPerPage(rows) {
		$("#rowsPerPage").val(rows);
		$("#pageNo").val(1);
		$("#data-div").html("<div id='wait'><img src='image/loading.gif'/></div>");
		
		reloadData0();
	}

	function showTable(tbl) {
		if (tbl == "") return;
		
		$("#table-detail").append("<div id='wait'><img src='image/loading.gif'/></div>");
		$("#table-detail").hide();
		$.ajax({
//			url: "ajax/table_col.jsp?table=" + tbl + "&t=" + (new Date().getTime()),
			url: "ajax/table_col.jsp?table=" + tbl,
			success: function(data){
				$("#wait").remove();
				$("#table-detail").append(data);
				$("#table-detail").slideDown();
			},
            error:function (jqXHR, textStatus, errorThrown){
            	alert(jqXHR.status + " " + errorThrown);
            }  
		});	
	}
	
	function setDoMode(mode) {
		var select = "";

		doMode = mode;

		$("#modeCopy").css("font-weight", "");
		$("#modeHide").css("font-weight", "");
		$("#modeSort").css("font-weight", "");
		$("#modeFilter").css("font-weight", "");
		$("#modeFilter2").css("font-weight", "");

		$("#modeCopy").css("background-color", "");
		$("#modeHide").css("background-color", "");
		$("#modeSort").css("background-color", "");
		$("#modeFilter").css("background-color", "");
		$("#modeFilter2").css("background-color", "");

		if (mode == "copy") {
			select = "modeCopy";
		} else if (mode == "hide") {
			select = "modeHide";
			hideNullColumnTableMaster();
		} else if (mode == "sort") {
			select = "modeSort";
		} else if (mode == "filter") {
			select = "modeFilter";
			filter('0');
		} else if (mode == "filter2") {
			select = "modeFilter2";
			filter2();
		}
		
		$("#" + select).css("font-weight", "bold");
		$("#" + select).css("background-color", "yellow");
	}

	function submitQuery() {
		$("#form1").attr("action", "query.jsp");
		$("#form1").submit();
	}
	
	function toggleSort(divId) {
		$("#"+divId+"-a").toggle();
		$("#"+divId+"-b").toggle();
	}	

	function removeDiv(divId) {
		$("#"+divId).remove();
	}	
	
	function copyPaste(val) {
//		$("#sql1").insertAtCaret(" " + val);
		$("#sql1").insertAtCaret2(val);
	}

	function doAction(val, idx) {
		if (doMode=='copy') {
			copyPaste(val);
		} else if (doMode=='hide') {
   	 		hideX(idx);
		} else if (doMode=='sort' || doMode=='filter2') {
			sort(val);
		} else if (doMode=='filter') {
			filter(val);
		} else {
			alert("mode=" + doMode);
		}
	}

    function hideX(idx) {
		var cols = $("#hideColumn").val();
		if (cols == "") cols = idx;
		else cols += "," + idx;
		
		$("#hideColumn").val(cols);
		hide(idx);
		$("#showAllCol").show();    	
    }

	function sort(col) {
		$("#pageNo").val(1);
		$("#data-div").html("<div id='wait'><img src='image/loading.gif'/></div>");
		var prevSortColumn = $("#sortColumn").val();
		var prevSortDirection = $("#sortDirection").val();
		var newSortDirection = "0";
		
		if (prevSortColumn==col && prevSortDirection=="0") { 
			newSortDirection = "1";  
		}
		$("#sortColumn").val(col);
		$("#sortDirection").val(newSortDirection);
		
		reloadData0();
	}

	function filter(col) {
		$("#filter-div").html("<div id='wait'><img src='image/loading.gif'/></div>");
		$("#filterColumn").val(col);
		$("#filterValue").val('');
		
		$.ajax({
			type: 'POST',
			url: "ajax/filter.jsp",
			data: $("#form0").serialize(),
			success: function(data){
				$("#filter-div").append(data);
				$("#wait").remove();
				reloadData0();
			},
            error:function (jqXHR, textStatus, errorThrown){
            	alert(jqXHR.status + " " + errorThrown);
            }  
		});	
	}	

	function gotoPage0(pageNo) {
		$("#pageNo").val(pageNo);
		$("#data-div").html("<div id='wait'><img src='image/loading.gif'/></div>");

		reloadData0();
	}
	
	function reloadData0() {
		$("#data-div").html("<div id='wait'><img src='image/loading.gif'/></div>");
		
		//$('body').css('cursor', 'wait'); 
		$.ajax({
			type: 'POST',
			url: qryPage,
			data: $("#form0").serialize(),
			success: function(data){
				$("#data-div").append(data);
				$("#wait").remove();
				hideIfAny();
				
				setHighlight();
				//$('body').css('cursor', 'default'); 
				refreshSummary();
			},
            error:function (jqXHR, textStatus, errorThrown){
            	alert(jqXHR.status + " " + errorThrown);
            }  
		});	
		
	}
	
	function reloadSummary() {
		$("#summary-div").hide();
		$("#summary-div").html("<div id='wait'><img src='image/loading.gif'/></div>");
		
		//$('body').css('cursor', 'wait'); 
		$.ajax({
			type: 'POST',
			url: 'qry-summary.jsp',
			data: $("#form0").serialize(),
			success: function(data){
				$("#summary-div").append(data);
				$("#wait").remove();
				$("#summary-div").slideDown();
				setHighlight();
			},
            error:function (jqXHR, textStatus, errorThrown){
            	alert(jqXHR.status + " " + errorThrown);
            }  
		});	
	}

	function refreshSummary() {
		var v = $("#summary").val();
		if (v==0) return;

		$.ajax({
			type: 'POST',
			url: 'qry-summary.jsp',
			data: $("#form0").serialize(),
			success: function(data){
				$("#summary-div").html(data);
				setHighlight();
			},
            error:function (jqXHR, textStatus, errorThrown){
            	alert(jqXHR.status + " " + errorThrown);
            }  
		});	
	}
	
    function hideNullColumnTableMaster() {
    	var divName = "dataTable";
    	var rowCount = $('#' + divName + ' tr').length;
    	
    	//if (rowCount > 2) return;
    	
   	    //var row = 1;
   	 	var hideCol = []; 
   	 	var colCnt = numCol(divName);
   	 	//alert(rowCount + "," +colCnt);
    	for (var col = 0; col < colCnt; col++) {
   	 		var nullValue = true;
       	 	for (var row=1; row<rowCount;row++) {
	    		var value = $("#" + divName).children().children()[row].children[col].innerHTML;
    			if (value.indexOf(">null<")<=0) {
   				nullValue = false;
	    		}
   	    	}
   	    	if (nullValue) hideCol.push(col+1);
   	    }
   	    
   	 	for (var i = 0, l = hideCol.length; i < l; ++i) {
   	 		//alert('hide ' + hideCol[i] );
   	 		hideX(hideCol[i]);
   	    }
   	    
    }

    function hideX(idx) {
		var cols = $("#hideColumn").val();
		if (cols == "") cols = idx;
		else cols += "," + idx;
		
		$("#hideColumn").val(cols);
		hide(idx);
		$("#showAllCol").show();    	
    }

	function hide(col) {
		$('table#dataTable').hideCol(col);
	}
	
	function show(col) {
		$('table#dataTable').showCol(col);
	}
	
	function hideInspectComment() {
		$('table#inspectTable').hideCol(3);
	}	

	function showAllColumn() {
		var hiddenCols = $("#hideColumn").val();
		if (hiddenCols != '') {
			var cols = hiddenCols.split(",");
			for(var i = 0;i<cols.length;i++){
				show(cols[i]);
			}
		}

		$("#showAllCol").hide();
		$("#hideColumn").val('');
	}

	function toggleSummary() {
		var v = $("#summary").val();
		v = (v=="1"?"0":"1");
		$("#summary").val(v);
		//alert(v);
		if (v=='1') {
			reloadSummary();
		} else
			$("#summary-div").slideUp();
	}
	
    $.fn.insertAtCaret2 = function (tagName) {
		return this.each(function(){
			if (document.selection) {
				//IE support
				this.focus();
				sel = document.selection.createRange();
				sel.text = tagName;
				this.focus();
			}else if (this.selectionStart || this.selectionStart == '0') {
				//MOZILLA/NETSCAPE support
				startPos = this.selectionStart;
				endPos = this.selectionEnd;
				scrollTop = this.scrollTop;
				var x = this.value.substring(startPos-1, startPos);
				//alert("[" + x + "]");
				if (x != ' ') tagName = ' ' + tagName; 
				this.value = this.value.substring(0, startPos) + tagName + this.value.substring(endPos,this.value.length);
				this.focus();
				this.selectionStart = startPos + tagName.length;
				this.selectionEnd = startPos + tagName.length;
				this.scrollTop = scrollTop;
			} else {
				this.value += tagName;
				this.focus();
			}
		});
	};	

	function filter2() {
		if ($("#filter2-div").is(':visible')) {
			$("#filter2-div").slideUp();
			resetFilter();
			return;
		}
		
		$("#filter2-div").html("<div id='wait'><img src='image/loading.gif'/></div>");
		$("#filterColumn").val('');
		$("#filterValue").val('');
		
		$.ajax({
			type: 'POST',
			url: "ajax/filter2.jsp",
			data: $("#form0").serialize(),
			success: function(data){
				$("#filter2-div").append(data);
				$("#wait").remove();
				$("#filter2-div").slideDown();
				reloadData0();
			},
            error:function (jqXHR, textStatus, errorThrown){
            	alert(jqXHR.status + " " + errorThrown);
            }  
		});	
	}	
	
	function applyFilter(value) {
		$("#pageNo").val(1);
		$("#filterValue").val(value);
		$("#data-div").html("<div id='wait'><img src='image/loading.gif'/></div>");
		
		reloadData0();
	}

	function setFilter() {
		$("#pageNo").val(1);
		var valList = "";
		$("select.filterCol").each(function() {
			var val = $(this).val();
			if (val==null) val = "";
			valList += val + "^";
		});		
		$("#filter2").val(valList);
		//alert(valList);
		reloadData0();
	}

	function resetFilter() {
		$('select[name=options]').val( '' );
		$("select.filterCol").val(''); 
		//reloadData();
		setFilter();
	}

	function download() {
		$("#form1").attr("action", "download.jsp");
		$("#form1").submit();
		$("#form1").attr("action", "query.jsp");
	}

	function searchRecords0(filter) {
		
		$("#search").attr("onchange" , "");
		
		$("#pageNo").val(1);
		$("#data-div").html("<div id='wait'><img src='image/loading.gif'/></div>");
		$("#searchValue").val(filter);
		
		reloadData0();
	}

	function clearSearch0() {
		$("#search").val("");
		searchRecords0('');
	}

	function toggleDataLink() {
		var v = $("#dataLink").val();
		v = (v=="1"?"0":"1");
		$("#dataLink").val(v);
//		alert(v);
		reloadData0();
	}

	function togglePreFormat() {
		var v = $("#preFormat").val();
		v = (v=="1"?"0":"1");
		$("#preFormat").val(v);
//		alert(v);
		reloadData0();
	}

	function setTranspose() {
		if (qryPage == "ajax/qry.jsp") {
			qryPage = "ajax/qry-v.jsp";
		} else {
			qryPage = "ajax/qry.jsp";
		}
		reloadData0();
	}

	function toggleCpas() {
		var v = $("#cpas").val();
		v = (v=="1"?"0":"1");
		$("#cpas").val(v);
//		alert(v);
		reloadData0();
	}

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

	function toggleHelp() {
		var src = $("#helpDivImage").attr('src');
		if (src.indexOf("minus")>0) {
			$("#div-help").slideUp();
			$("#helpDivImage").attr('src','image/plus.gif');
		} else {
			$("#div-help").slideDown();
			$("#helpDivImage").attr('src','image/minus.gif');
		}
	}
	</script>    
</head> 

<body>

<div style="background-color: #E6F8E0; padding: 6px; border:1px solid #CCCCCC; border-radius:10px;">
<img src="image/icon_query.png" width=20 height=20 align="top"/>
<span style="color: blue; font-family: Arial; font-size:16px; font-weight:bold;">Query</span>
&nbsp;&nbsp;&nbsp;
<b><%= cn.getUrlString() %></b>
&nbsp;&nbsp;&nbsp;
<a href="index.jsp" target="_blank">Home</a> |
<a href="query.jsp" target="_blank">Query</a> |
<a href="Javascript:newQry()">Pop Query</a> |
<a target=_blank href="history.jsp">History</a>
<!-- <a href="q.jsp" target="_blank">Q</a> |

<a href="erd_svg.jsp?tname=<%= tbl %>" target="_blank">ERD</a> |
<a href="worksheet.jsp" target="_blank">Work Sheet</a>
 -->&nbsp;&nbsp;&nbsp;
<span style="float:right;">
Search <input id="globalSearch" style="width: 200px;" placeholder="table or view name"/>
</span>
</div>
<div style="height: 4px;"></div>
<div id="queryMain">

<a href="Javascript:toggleHelp()"><img  style="float: left" id="helpDivImage" border="0" src="image/minus.gif"></a>

<div id="div-help" style="float: left;">
<%-- 	<a id="showERD" href="Javascript:showERD('<%=tbl%>')">Show ERD</a>
	<div id="tableList1" style="margin-left: 5px;">
 	</div>
 --%>
<div class="ui-widget">
	<label for="tablesearch">Table/View: </label>
	<input id="tablesearch" style="width: 200px;"/>
</div>

	<div id="table-detail"></div>

	<div>
	<a href="Javascript:copyPaste('SELECT');">SELECT</a>&nbsp;
	<a href="Javascript:copyPaste('DISTINCT');">DISTINCT</a>&nbsp;
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
	<a href="Javascript:copyPaste('ASC');">ASC</a>&nbsp;
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
<form name="form0" id="form0">
<textarea style="display: none;" id="sql" name="sql" ><%= sqlh %></textarea>
<input type="hidden" id="sortColumn" name="sortColumn" value="">
<input type="hidden" id="sortDirection" name="sortDirection" value="0">
<input type="hidden" id="hideColumn" name="hideColumn" value="">
<input type="hidden" id="filterColumn" name="filterColumn" value="">
<input type="hidden" id="filterValue" name="filterValue" value="">
<input type="hidden" id="searchValue" name="searchValue" value="">
<input type="hidden" id="filter2" name="filter2" value="">
<input type="hidden" id="pageNo" name="pageNo" value="1">
<input type="hidden" id="rowsPerPage" name="rowsPerPage" value="20">
<input type="hidden" id="dataLink" name="dataLink" value="1">
<input type="hidden" id="preFormat" name="preFormat" value="0">
<input type="hidden" id="summary" name="summary" value="0">
<input type="hidden" id="cpas" name="cpas" value="0">
<input id="id" name="id" type="hidden" value=""/>
<input id="showFK" name="showFK" type="hidden" value="0"/>
</form>


<form id="FormPop" name="FormPop" target="_blank" method="post" action="pop.jsp">
<input id="popType" name="type" type="hidden" value="OBJECT">
<input id="popKey" name="key" type="hidden">
</form>

</div> <!-- end of query main -->

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

<div id="buttonsDiv" style="display: block;">
<TABLE>
<TD><a class="qryBtn" id="modeSort" href="Javascript:setDoMode('sort')">Sort</a>
<TD><a class="qryBtn" id="modeCopy" href="Javascript:setDoMode('copy')">Copy&amp;Paste</a></TD>
<TD><a class="qryBtn" id="modeHide" href="Javascript:setDoMode('hide')">Hide Column</a>
	<span id="showAllCol" style="display: none;">
		<a href="Javascript:showAllColumn()">Show All</a>&nbsp;
	</span>
</TD>

<td>&nbsp;&nbsp;&nbsp;</td>
<td>
<input type="button" value="Summary" onClick="Javascript:toggleSummary()"/>
<input type="button" value="Filter" onClick="Javascript:filter2()"/>
</td>
<td>&nbsp;&nbsp;&nbsp;</td>
<td>
<input type="button" value="Download" onClick="Javascript:download()"/>
<input type="button" value="Explain plan" onClick="Javascript:explainPlan()"/>
</td>
<td>&nbsp;&nbsp;&nbsp;</td>
<td>
<input type="button" value="Reload" onClick="Javascript:reloadQuery()"/>
<input type="button" value="Edit Query" onClick="Javascript:editQuery()"/>
</td>
</TABLE>
</div>
<BR/>
<div id="summary-div" style="display:none"></div>
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
	  var rc = $("#recordCount").val();
//	  alert(rc);
//	  alert("upto "+ <%=upto%>);
	  if (rc != "0" && rc < <%=upto%>) {
	  	$("#queryMain").slideUp();
	  }
   });

</script>

<form id="FORM_query" name="FORM_query" action="query.jsp" target="_blank" method="post">
<input id="sql-query" name="sql" type="hidden"/>
</form>

</body>
</html>