<%@ page language="java" 
	import="java.util.*" 
	import="java.util.Date" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	import="oracle.jdbc.OracleTypes"
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<%!

public String getBC(Connection conn, String fname, String type) {
	String res="";
	if (conn != null) {

	    String cStmt = "{ ? = call " + fname+" }";
	    //Util.p(cStmt);
	    CallableStatement oStmt=null;
	    int nResult = 0;
	    
	    try {
	    	if (type.equals("NUMBER")) 
	    		cStmt = "{ ? = call round(" + fname+",10) }";
	    	
	    	oStmt = conn.prepareCall(cStmt);
			oStmt.registerOutParameter(1, OracleTypes.VARCHAR);
	        oStmt.execute();
	        res = oStmt.getString(1);

	    } catch (SQLException e) {
			//Util.p("***1 " + fname);
			res = "ERROR: " + e.getMessage();
			//Util.p(res);
	        //e.printStackTrace();
	    } finally {
		    try {
		    	if (oStmt != null)
				    oStmt.close();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
	    }
	        
	}
	
	return res;
}

public String getBCBoolean(Connection conn, String fname) {
	String res="";
	if (conn != null) {

	    //String cStmt = "{ ? = call " + fname+" }";
        String cStmt = "" +
        " declare " +  
        "    cRes varchar2(20) := '';" +
        "    lRes boolean;" +
        " begin " +
        "    lRes := " + fname + ";" +
        "    if lRes = true then cRes := 'true'; end if;" +
        "    if lRes = false then cRes := 'false'; end if;" +
        "    ? := cRes;" +
        " end;";
		
	    //Util.p(cStmt);
	    CallableStatement oStmt=null;
	    int nResult = 0;
	    
	    try {
	    	oStmt = conn.prepareCall(cStmt);
			oStmt.registerOutParameter(1, OracleTypes.VARCHAR);
	        oStmt.execute();
	        res = oStmt.getString(1);

	    } catch (SQLException e) {
			//Util.p("***2 " + fname);
			res = "ERROR: " + e.getMessage();
			//Util.p(res);
	        //e.printStackTrace();
	    } finally {
		    try {
		    	if (oStmt != null)
				    oStmt.close();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
	    }
	        
	}
	
	return res;
}
%>
<%!
public String getRuleDate(Connection conn, String dateStr) {
	String res="";
	if (conn != null) {

	    String cStmt = "{ ? = call TO_CHAR( BC_RULE.getDate(TO_DATE(?,'YYYYMMDD')), 'YYYY-MM-DD') }";
	    CallableStatement oStmt=null;
	    int nResult = 0;
	    
	    try {
	    	oStmt = conn.prepareCall(cStmt);
			oStmt.registerOutParameter(1, OracleTypes.VARCHAR);
	        oStmt.setString(2,dateStr);
	        oStmt.execute();
	        res = oStmt.getString(1);

	    } catch (SQLException e) {
	    	res = "ERROR " + e.getMessage();
	        //e.printStackTrace();
	    } finally {
		    try {
		    	if (oStmt != null)
				    oStmt.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
	    }
	}
	
	return res;
}


public String getFormula(Connection conn, String formula) {
	String res="";
	if (conn != null) {

		
	    String cStmt = "{ ? = call BC.getFormula(?,'') }";
//	    String cStmt = "{ ? = call BC_JAVA.getFormula(?,'') }";
	    
	    CallableStatement oStmt=null;
	    int nResult = 0;
	    
	    try {
	    	oStmt = conn.prepareCall(cStmt);
//			oStmt.registerOutParameter(1, OracleTypes.FLOAT);
			oStmt.registerOutParameter(1, OracleTypes.VARCHAR);
	        oStmt.setString(2,formula);
	        oStmt.execute();
	        
//	        float f = oStmt.getFloat(1);
//	        res = "" + f;
	        res = oStmt.getString(1);

	    } catch (SQLException e) {
	    	res = "ERROR " + e.getMessage();
	        //e.printStackTrace();
	    } finally {
		    try {
		    	if (oStmt != null)
				    oStmt.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
	    }
	}
	
	return res;
}

public String getService(Connection conn, String varname) {
	String res="";
	if (conn != null) {

	    String cStmt = "{ ? = call round(BC_SERVICE.getService(?),10) }";
	    CallableStatement oStmt=null;
	    int nResult = 0;
	    
	    try {
	    	oStmt = conn.prepareCall(cStmt);
			oStmt.registerOutParameter(1, OracleTypes.VARCHAR);
	        oStmt.setString(2,varname);
	        oStmt.execute();
	        
	        res = oStmt.getString(1);

	    } catch (SQLException e) {
	    	res = "ERROR " + e.getMessage() + cStmt;
	        //e.printStackTrace();
	    } finally {
		    try {
		    	if (oStmt != null)
				    oStmt.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
	    }
	}
	
	return res;
}

public String getAge(Connection conn, String varname) {
	String res="";
	if (conn != null) {

	    String cStmt = "{ ? = call round(BC_RULE.getAge(?),10) }";
	    CallableStatement oStmt=null;
	    int nResult = 0;
	    
	    try {
	    	oStmt = conn.prepareCall(cStmt);
			oStmt.registerOutParameter(1, OracleTypes.VARCHAR);
	        oStmt.setString(2,varname);
	        oStmt.execute();
	        
	        res = oStmt.getString(1);

	    } catch (SQLException e) {
	    	res = "ERROR " + e.getMessage() + cStmt;
	        //e.printStackTrace();
	    } finally {
		    try {
		    	if (oStmt != null)
				    oStmt.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
	    }
	}
	
	return res;
}

String getDateDesc(Connect cn, String dateStr) {
	if (dateStr.startsWith("1800")) {
		String desc = cn.queryOne("SELECT NAME FROM CPAS_DATE WHERE RDATE=TO_DATE('" + dateStr + "','YYYYMMDD')");
		return desc;
 	}
	return dateStr;
}

String getFormulaDesc(Connect cn, String formula) {
//	if (formula.startsWith("#")) return "value";
	String desc = cn.queryOne("SELECT FDESC FROM FORMULA WHERE FKEY='" + formula + "'");
	return desc;
}

String explainFormular(Connect cn, String ftype, String formula, String calcid, String fkey) {
	if (formula==null || formula.length()==0) return "";
	Query qCalc = new Query(cn, "SELECT * FROM CALC WHERE calcid="+calcid);
	String res="<table border=1 style='border: 1px solid #CCCCCC; border-collapse: collapse;'>";
	
	List<String> tokens = Arrays.asList(formula.split("\\|"));

	String q = "SELECT CAPTION, DATATYPE, CODEGRUP, CNAME FROM CPAS_formula_cargo where ftype='" + ftype + "' ORDER BY DATAORDER";
	List<String[]> cargo = cn.query(q);
	int i=0;
 	for (String[] cg : cargo) {
		String desc = "";
 		if (i < tokens.size()) {
 			desc = "";
 			if (cg[2].equals("D") && !tokens.get(i).startsWith("1800"))
 				desc = tokens.get(i);
 			else if (cg[3]!=null&&cg[3].length()>0&&tokens.get(i).length() > 0) {
 				desc += cn.getCpasUtil().getGrupValue(cg[3], tokens.get(i), qCalc);
 				if (desc.equals("null") && !cg[2].equals("D")) desc = "[" + cg[3] +"]";

			} else if (cg[2].equals("D") && tokens.get(i).length() > 0 ) {
				if (tokens.get(i).startsWith("1800"))
					desc = getDateDesc(cn, tokens.get(i));
				else
					desc = tokens.get(i);
			}
 			String value="";
 			if (cg[2].equals("D")) {
 				if (tokens.get(i).length() > 0)
 					value = getRuleDate(cn.getConnection(), tokens.get(i));
 				else if (cg[4].equals("DFROM")) {
 					value ="";
 				}
 			}
 			if (cg[2].equals("N")) {
 				value = tokens.get(i);
 			}
 			
 			if (value==null || value.equals("null")) value = "";
 			
// 			res += "<tr><td>" + cg[4] + "</td><td>" + cg[1] + "</td><td>"+tokens.get(i)+"</td><td>"+cg[2]+"</td><td>" + desc + 
 			res += "<tr><td>" + cg[1] + "</td><td>"+tokens.get(i)+"</td><td>"+cg[2]+"</td><td>" + desc +
 					"</td><td><b>" + value + "</b></td></tr>";
 		}
		i++;
	}

	res += "</table>";

	// Combination Formula
	if (ftype.equals("HY")) {
		res="<table border=1 style='border: 1px solid #CCCCCC; border-collapse: collapse;'>";
		StringTokenizer st = new StringTokenizer(formula,"()+-*/<>| ");
		while (st.hasMoreTokens()) {
			String token = st.nextToken();
			if (token.equals("I")) continue;
			if (token.startsWith("#")) continue;
			if (Util.isNumber(token)) continue;
			String val = getFormula(cn.getConnection(), token);
			if (val.startsWith("ERROR")) val = "ERROR";
			res += "<tr><td>" + token + "</td><td>" + getFormulaDesc(cn, token) + "</td><td align=right><b>" + val + "</b></td></tr>";
		}
		res += "</table>";
	};
	
	// HTML detail -- test
	if (cn.isTVS("CT$CPAS_HTML_PAGE")) {
		String h = cn.queryOne("SELECT pageitem FROM CT$CPAS_HTML_PAGE WHERE dockey like '%-" + fkey +"'");
		if(h==null) h= "";
		//Util.p("SELECT pageitem FROM CT$CPAS_HTML_PAGE WHERE dockey like '%" +formula+"'");
		res += h;
	}
	
	return res;
}

public String getBCParameter(Connection conn, String param, String datatype) {
	String res="";
	if (conn != null) {

		String fname="";
		if (datatype.equals("D")) fname = "BC_PARAMETER.getDate";
		if (datatype.equals("N")) fname = "BC_PARAMETER.getNum";
		if (datatype.equals("C")) fname = "BC_PARAMETER.getChar";
		
	    String cStmt = "{ ? = call " + fname+"(?) }";
	    //Util.p(cStmt);
	    CallableStatement oStmt=null;
	    int nResult = 0;
	    
	    try {
	    	oStmt = conn.prepareCall(cStmt);
			oStmt.registerOutParameter(1, OracleTypes.VARCHAR);
			oStmt.setString(2,param);
	        oStmt.execute();
	        res = oStmt.getString(1);

	    } catch (SQLException e) {
			//Util.p("***3 " + fname + " " + param);
			res = "ERROR: " + e.getMessage();
			//Util.p(res);
	        //e.printStackTrace();
	    } finally {
		    try {
		    	if (oStmt != null)
				    oStmt.close();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
	    }
	        
	}
	
	return res;
}


%>
<%
	Connect cn = (Connect) session.getAttribute("CN");
	String calcid = Util.nvl(request.getParameter("calcid"));
	boolean isRun = true; 

	if (calcid.equals("")) {
		calcid = cn.queryOne("SELECT MAX(calcid) FROM CALC", false);
		isRun = false;
	}

	String clnt=null;
	String plan=null;
	String mkey=null;
	String erkey=null;

	if (!calcid.equals("")) {
		clnt = cn.queryOne("SELECT CLNT FROM CALC WHERE CALCID="+calcid);
		plan = cn.queryOne("SELECT PLAN FROM CALC WHERE CALCID="+calcid);
		mkey = cn.queryOne("SELECT MKEY FROM CALC WHERE CALCID="+calcid);
		erkey = cn.queryOne("SELECT ERKEY FROM MEMBER_SERVICE WHERE CLNT='"+clnt + "' AND MKEY='" + mkey +"'");
	}
	
	String qry = "SELECT FTYPE VALU,NAME FROM CPAS_FORMULA ORDER BY NAME";
	List<String[]> ftypes = cn.query(qry);
	
	HashMap<String, String> hmFtype = new HashMap<String, String>(); 
	for (String[] var: ftypes) {
		hmFtype.put(var[1], var[2]);
	}
	
%>
<html>
<head> 
	<title>BenCalc <%= calcid %></title>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" /> 

    <script src="script/jquery-1.7.2.min.js" type="text/javascript"></script>
    <script src="script/genie.js?<%= Util.getScriptionVersion() %>" type="text/javascript"></script>
    <script src="script/data-methods.js?<%= Util.getScriptionVersion() %>" type="text/javascript"></script>

    <link rel='stylesheet' type='text/css' href='css/style.css?<%= Util.getScriptionVersion() %>'>
	<link rel="icon" type="image/png" href="image/Genie-icon.png">

	<link rel="stylesheet" href="css/ui-lightness/jquery-ui-1.8.18.custom.css" type="text/css"/>
	<link rel='stylesheet' type='text/css' href='css/doc.css?<%=Util.getScriptionVersion()%>'>
	<link rel='stylesheet' type='text/css' href='css/newdoc.css?<%=Util.getScriptionVersion()%>'>
	
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
	    
	function loadProc(pkgName, prcName) {
		$("#name-map").val(pkgName+"."+prcName);
		$("#form-map").submit();
	}	

	function toggleFormula() {
		var src = $("#imgFormula").attr('src');
		//alert(src);
		if (src.indexOf("minus")>0) {
			$("#BenFormula").slideUp();
			$("#imgFormula").attr('src','image/plus.gif');
		} else {
			$("#BenFormula").slideDown();
			$("#imgFormula").attr('src','image/minus.gif');
		}

	}

	function toggleBenCalc() {
		var src = $("#imgBenCalc").attr('src');
		//alert(src);
		if (src.indexOf("minus")>0) {
			$("#BenCalc").slideUp();
			$("#imgBenCalc").attr('src','image/plus.gif');
		} else {
			$("#BenCalc").slideDown();
			$("#imgBenCalc").attr('src','image/minus.gif');
		}

	}
	
	function toggleRuleDate() {
		var src = $("#imgRuleDate").attr('src');
		//alert(src);
		if (src.indexOf("minus")>0) {
			$("#RuleDate").slideUp();
			$("#imgRuleDate").attr('src','image/plus.gif');
		} else {
			$("#RuleDate").slideDown();
			$("#imgRuleDate").attr('src','image/minus.gif');
		}

	}

	function toggleParam() {
		var src = $("#imgBenParam").attr('src');
		//alert(src);
		if (src.indexOf("minus")>0) {
			$("#BenParam").slideUp();
			$("#imgBenParam").attr('src','image/plus.gif');
		} else {
			$("#BenParam").slideDown();
			$("#imgBenParam").attr('src','image/minus.gif');
		}
	}

	function toggleService() {
		var src = $("#imgService").attr('src');
		//alert(src);
		if (src.indexOf("minus")>0) {
			$("#BenService").slideUp();
			$("#imgService").attr('src','image/plus.gif');
		} else {
			$("#BenService").slideDown();
			$("#imgService").attr('src','image/minus.gif');
		}
	}

	function toggleAge() {
		var src = $("#imgAge").attr('src');
		//alert(src);
		if (src.indexOf("minus")>0) {
			$("#BenAge").slideUp();
			$("#imgAge").attr('src','image/plus.gif');
		} else {
			$("#BenAge").slideDown();
			$("#imgAge").attr('src','image/minus.gif');
		}
	}

	function testVar() {
		var testvar = $("#testvar").val();
		$("#testResult").html("");
		$.ajax({
			url: "ajax-cpas/test_bc.jsp?key=" + testvar + "&t=" + (new Date().getTime()),
			success: function(data){
				$("#testResult").html(data);
			},
            error:function (jqXHR, textStatus, errorThrown){
                alert(jqXHR.status + " " + errorThrown);
            }  
		});
		

	}
	</script>
    
</head> 

<body>
<%
	String id = Util.getId();
%>
<div id="topline" style="background-color: #EEEEEE; pading: 0px; border:1px solid #888888; border-radius:10px;">
<table width=100% border=0 cellpadding=0 cellspacing=0>
<td width="44">
<img align=top src="image/lamp.png" alt="Ver. <%= Util.getVersionDate() %>" title="<%= Util.getBuildNo() %>"/>
</td>
<td>
<span style="font-family: Arial; font-size:18px;"><span style="background-color:black; color: white;">C</span><span style="background-color:#FF9900; color: white;">PAS</span> <span style="color: blue; font-family: Arial; font-size:18px; font-weight:bold;">BenCalc</span></span>
</td>
<!-- <td nowrap><h2 style="color: blue;">Genie</h2></td> -->
<td><b><%= cn.getUrlString() %></b></td>
<td nowrap>

<a href="index.jsp">Home</a> |
<a href="Javascript:newQry()">Pop Query</a> |
<a href="query.jsp" target="_blank">Query</a> |
</td>
<td align=right nowrap>

Search <input id="globalSearch" style="width: 200px;" placeholder="table or view name"/>
</td>
</table>
</div>

<br/>

<form method="get">
Calc ID <input name="calcid" value="<%= calcid %>" size=10>

<input type="submit" value="Run"> 
clnt=[<%= clnt %>] plan=[<%= plan %>] mkey=[<%= mkey %>] erkey=[<%= erkey %>]

</form>

<% if (!isRun)  { %>
</body>
</html>
<% 		return;
	} %>
<hr>

<% if (!calcid.equals("")) {
	id = Util.getId();
	String sql= "SELECT * FROM CALC WHERE CALCID="+calcid; 
%>
<b>CALC</b>
<a href="cpas-calchtmldetail.jsp?calcid=<%=calcid%>" target=_blank>Html Calc Detail</a>
<a href="bencalc_member.jsp?calcid=<%=calcid%>" target=_blank>BenCalc Member</a>

<div style="display: none;" id="sql-<%=id%>"><%= sql%></div>
<div style="display: none;" id="mode-<%=id%>">hide</div>
<div style="display: none;" id="ori-<%=id%>">H</div>
<div style="display: none;" id="hide-<%=id%>"></div>
<div style="margin-left: 20px;" id="div-<%=id%>">
<jsp:include page='ajax/qry-simple.jsp'>
	<jsp:param value='<%= sql %>' name="sql"/>
	<jsp:param value="1" name="dataLink"/>
	<jsp:param value="<%= id %>" name="id"/>
</jsp:include>
</div>
<br/>
<% } %>

<%-- 
<% if (!calcid.equals("")) {
	id = Util.getId();
	String sql= "SELECT * FROM MEMBER WHERE CLNT='"+clnt + "' AND MKEY='" + mkey +"'"; 
%>
<b>MEMBER</b>
<div style="display: none;" id="sql-<%=id%>"><%= sql%></div>
<div style="display: none;" id="mode-<%=id%>">hide</div>
<div style="display: none;" id="ori-<%=id%>">H</div>
<div style="display: none;" id="hide-<%=id%>"></div>
<div style="margin-left: 20px;" id="div-<%=id%>">
<jsp:include page='ajax/qry-simple.jsp'>
	<jsp:param value='<%= sql %>' name="sql"/>
	<jsp:param value="1" name="dataLink"/>
	<jsp:param value="<%= id %>" name="id"/>
</jsp:include>
</div>
<br/>
<% } %>

 --%>


<br/>
<%
	cn.bcSetAll(calcid);

	id = Util.getId();
%>



<table border=0>
<tr>
<td valign=top>

<a href="javascript:toggleService()"><span style="color: blue; font-family: Arial; font-size:16px; font-weight:bold;">Services / Earnings</span><img id="imgService" src="image/minus.gif"></a>

<div id="BenService" style="display: block;">
<%
if (cn.isTVS("PLAN_MATRIX")) {
	id = Util.getId();
%>

<table id="table-<%= id %>" border=1 class="gridBody" style="margin-left: 40px;">
<tr>
	<th class="headerRow">Var Name</th>
	<th class="headerRow">Var Desc</th>
	<th class="headerRow">Type</th>
	<th class="headerRow">Value</th>
</tr>
<%
	String q2 = "select varname, vardesc, vartype  from PLAN_MATRIX WHERE CLNT = '"+ clnt + "' AND PLAN='"+plan+"' order by 3 desc, 1";

		List<String[]> ff2 = cn.query(q2, false);

		int rowCnt=0;
		for (String[] fl: ff2) {
			rowCnt++;
			String rowClass = "oddRow";
			if (rowCnt%2 == 0) rowClass = "evenRow";

			String varname = fl[1];
			String vardesc = fl[2];
			String value = "";
			value = getService(cn.getConnection(), varname);
			if (value==null) value ="";
			
			String tooltip = null;
			if (value.startsWith("ERROR")) {
				tooltip = value;
				value = "ERROR";
			}
			
			String vartype = "Service";
			if (fl[3].equals("E")) vartype = "Earning";
			
%>
<tr class="simplehighlight">
	<td class="<%= rowClass%>"><%= varname %></td>
	<td class="<%= rowClass%>"><%= vardesc %></td>
	<td class="<%= rowClass%>"><%= vartype %></td>
	<td class="<%= rowClass%>">
	<% if (tooltip != null) {%>
		<span class="pk2"><a title='<%=Util.escapeQuote(tooltip)%>'><%= value %></a></span>
	<% } else {  %>
		<span class="pk"><%= value %></span>
	<% } %>
	
	</td>
</tr>
<%			
	}
%>

</table>
<% } %>
</div>

</td>

<td valign=top>

<a href="javascript:toggleAge()"><span style="color: blue; font-family: Arial; font-size:16px; font-weight:bold;">Rule Ages</span><img id="imgAge" src="image/minus.gif"></a>
<div id="BenAge" style="display: block;">
<%
if (cn.isTVS("CPAS_AGE")) {
	id = Util.getId();
%>
<table id="table-<%= id %>" border=1 class="gridBody" style="margin-left: 40px;">
<tr>
	<th class="headerRow">Var</th>
	<th class="headerRow">Name</th>
	<th class="headerRow">Value</th>
	<th class="headerRow">Code</th>
</tr>
<%
	String q2 = "select valu, name,expcode  from CPAS_AGE order by 1";
	boolean fromFormula = false;
	if (cn.getBuildNo().compareTo("1257") >= 0) {
		q2 = "select fkey, fdesc, ruleid  from FORMULA WHERE fclass='A' and clnt='*' order by 1";
		fromFormula = true;
	}

	List<String[]> ff2 = cn.query(q2, false);

		int rowCnt=0;
		for (String[] fl: ff2) {
			rowCnt++;
			String rowClass = "oddRow";
			if (rowCnt%2 == 0) rowClass = "evenRow";

			String varname = fl[1];
			String vardesc = fl[2];
			String value = "";
			value = getAge(cn.getConnection(), varname);
			if (value==null) value ="";
			
			String tooltip = null;
			if (value != null && value.startsWith("ERROR")) {
				tooltip = value;
				value = "ERROR";
			}
			String link = "";
			if (fl[3] != null && fl[3].length()>2) {
				link = "<a href='javascript:showRuleAgeCode(\""+varname+"\")'>code</a>";
				if (fromFormula)
					link = "<a href='javascript:showCpasRule(\""+fl[3]+"\")'>"+fl[3]+"</a>";
			}			
%>
<tr class="simplehighlight">
	<td class="<%= rowClass%>"><%= varname %></td>
	<td class="<%= rowClass%>"><%= vardesc %></td>
	<td class="<%= rowClass%>">
	<% if (tooltip != null) {%>
		<span class="pk2"><a title='<%=Util.escapeQuote(tooltip)%>'><%= value %></a></span>
	<% } else {  %>
		<span class="pk"><%= value %></span>
	<% } %>
	</td>
	<td class="<%= rowClass%>"><%= link %></td>
</tr>
<%			
	}
%>

</table>
<% } %>
</div>

</td>

<td valign=top>

<a href="javascript:toggleRuleDate()"><span style="color: blue; font-family: Arial; font-size:16px; font-weight:bold;">Rule Dates</span><img id="imgRuleDate" src="image/minus.gif"></a>
<div id="RuleDate" style="display: block;">
<%
if (cn.isTVS("CPAS_DATE")) {
	id = Util.getId();
%>
<table id="table-<%= id %>" border=1 class="gridBody" style="margin-left: 40px;">
<tr>
	<th class="headerRow">Date</th>
	<th class="headerRow">Name</th>
	<th class="headerRow">Value</th>
	<th class="headerRow">Code</th>
</tr>
<%

String q = "select to_char(rdate,'YYYYMMDD'), name, expcode from CPAS_DATE order by 1";
boolean fromFormula = false;
if (cn.getBuildNo().compareTo("1257") >= 0) {
	q = "select fkey, fdesc, ruleid from FORMULA where fclass='D' and clnt='*' order by 1";
	fromFormula = true;
}
		List<String[]> ff = cn.query(q, false);

		int rowCnt=0;
		for (String[] fl: ff) {
			
			rowCnt++;
			String rowClass = "oddRow";
			if (rowCnt%2 == 0) rowClass = "evenRow";
			String dateStr = fl[1];

			String value = getRuleDate(cn.getConnection(), dateStr);;
			if (value==null) value="";
			String tooltip = null;
			if (value.startsWith("ERROR")) {
				tooltip = value;
				value = "ERROR";
			}
			String align="left";
			
			String link = "";
			if (fl[3] != null && fl[3].length()>2) {
				link = "<a href='javascript:showRuleDateCode(\""+dateStr+"\")'>code</a>";
				if (fromFormula)
					link = "<a href='javascript:showCpasRule(\""+fl[3]+"\")'>"+fl[3]+"</a>";
			}
%>
<tr class="simplehighlight">
	<td class="<%= rowClass%>"><%= dateStr %></td>
	<td class="<%= rowClass%>"><%= fl[2] %></td>
	<td class="<%= rowClass%>" align="<%= align %>">
	<% if (tooltip != null) {%>
		<span class="pk2"><a title='<%=Util.escapeQuote(tooltip)%>'><%= value %></a></span>
	<% } else {  %>
		<span class="pk"><%= value %></span>
	<% } %>
		
	</td>
	<td class="<%= rowClass%>"><%= link %></td>
</tr>
<%			
		}
%>
</table>

<% } %>
</div>


</td>

</tr>
</table>



<br/>

<table border=0>
<tr>
<td valign=top>
<%
if (cn.isTVS("CPAS_PARAMETER")) {
	id = Util.getId();
%>
<a href="javascript:toggleParam()"><span style="color: blue; font-family: Arial; font-size:16px; font-weight:bold;">Parameters</span><img id="imgBenParam" src="image/minus.gif"></a>

<div id="BenParam" style="display: block;">
<table id="table-<%= id %>" border=1 class="gridBody" style="margin-left: 40px;">
<tr>
	<th class="headerRow">Parameter</th>
	<th class="headerRow">Type</th>
	<th class="headerRow">Value</th>
	<th class="headerRow">Reamrk</th>
</tr>
<%
	String q = "select param, datatype, remark from CPAS_PARAMETER order by 1";

	List<String[]> ff = cn.query(q, false);

		int rowCnt=0;
		for (String[] fl: ff) {
			rowCnt++;
			String rowClass = "oddRow";
			if (rowCnt%2 == 0) rowClass = "evenRow";

			String param = fl[1];
			String datatype = fl[2];
			String remark = fl[3];
			String value = "";
			value = getBCParameter(cn.getConnection(), param, datatype);
			if (value==null) value ="";
			
			String tooltip = null;
			if (value != null && value.startsWith("ERROR")) {
				tooltip = value;
				value = "ERROR";
			}
			
			if (remark==null) remark="";
			String remarkDisp = remark;
			if (remark !=null && remark.length() > 50) {
				id = Util.getId();
				String id_x = Util.getId();
				remarkDisp = remarkDisp.substring(0,50) + "<a id='"+id_x+"' href='Javascript:toggleText(" +id_x + "," +id +")'>...</a><span id='"+id+"' style='display: none;'>" + remarkDisp.substring(50) + "</span>";
			}
%>
<tr class="simplehighlight">
	<td class="<%= rowClass%>"><%= param %></td>
	<td class="<%= rowClass%>"><%= datatype %></td>
	<td class="<%= rowClass%>">
	<% if (tooltip != null) {%>
		<span class="pk2"><a title='<%=Util.escapeQuote(tooltip)%>'><%= value %></a></span>
	<% } else {  %>
		<span class="pk"><%= value %></span>
	<% } %>
	
	</td>
	<td class="<%= rowClass%>"><%= remarkDisp %></td>
	</td>
</tr>
<%			
	}
%>

</table>
</div>

</td>

<td valign=top>
<a href="javascript:toggleBenCalc()"><span style="color: blue; font-family: Arial; font-size:16px; font-weight:bold;">BC Functions</span><img id="imgBenCalc" src="image/minus.gif"></a>
<br/>
<div id="BenCalc" style="display: block;">
<table id="table-<%= id %>" border=1 class="gridBody" style="margin-left: 40px;">
<tr>
	<th class="headerRow">Package.Function</th>
	<th class="headerRow">Type</th>
	<th class="headerRow">Value</th>
</tr>
<%
 q = "select package_name, object_name, pls_type from (select package_name, object_name, pls_type from user_arguments a where package_name like 'BC%' /*and (object_name like 'GET%' OR object_name like 'IS%') */ " +
	"and not exists (select 1 from user_arguments b where object_id=a.object_id and subprogram_id=a.subprogram_id and position=1) and pls_type !='BOOLEAN-' " +
	" union all select 'BC', 'getClnt', 'VARCHAR2' from dual " +
	" union all select 'BC', 'getPlan', 'VARCHAR2' from dual " +
	" union all select 'BC', 'getMkey', 'VARCHAR2' from dual " +
	" union all select 'BC', 'getAccountID', 'NUMBER' from dual " +
	" union all select 'BC', 'getCalcDate', 'DATE' from dual " +
	" union all select 'BC', 'getCalcId', 'NUMBER' from dual " +
	" union all select 'BC', 'getClass', 'VARCHAR2' from dual " +
	" union all select 'BC', 'getCategory', 'VARCHAR2' from dual " +
	" union all select 'BC', 'getPlanStatus', 'VARCHAR2' from dual " +
	" union all select 'BC', 'getCPASPlanStatus', 'VARCHAR2' from dual " +
	" union all select 'BC', 'getCalcStatus', 'VARCHAR2' from dual " +
	" union all select 'BC', 'getStage', 'VARCHAR2' from dual " +
	" union all select 'BC', 'getSType', 'VARCHAR2' from dual " +
	" union all select 'BC', 'getShowDetail', 'BOOLEAN' from dual " +
	" union all select 'BC', 'getRunDate', 'DATE' from dual " +
	" union all select 'BC', 'getRecalcID', 'NUMBER' from dual " +

	") order by package_name, upper(object_name)";

if (cn.getTargetSchema() != null) {
	q = "select package_name, object_name, pls_type from (select package_name, object_name, pls_type from all_arguments a where owner='"+cn.getTargetSchema()+"' and package_name like 'BC%' /*and (object_name like 'GET%' OR object_name like 'IS%')*/ " +
			"and not exists (select 1 from all_arguments b where object_id=a.object_id and subprogram_id=a.subprogram_id and position=1) and pls_type !='BOOLEAN-' " +
					" union all select 'BC', 'getClnt', 'VARCHAR2' from dual " +
					" union all select 'BC', 'getPlan', 'VARCHAR2' from dual " +
					" union all select 'BC', 'getMkey', 'VARCHAR2' from dual " +
					" union all select 'BC', 'getAccountID', 'NUMBER' from dual " +
					" union all select 'BC', 'getCalcDate', 'DATE' from dual " +
					" union all select 'BC', 'getCalcId', 'NUMBER' from dual " +
					" union all select 'BC', 'getClass', 'VARCHAR2' from dual " +
					" union all select 'BC', 'getCategory', 'VARCHAR2' from dual " +
					" union all select 'BC', 'getPlanStatus', 'VARCHAR2' from dual " +
					" union all select 'BC', 'getCPASPlanStatus', 'VARCHAR2' from dual " +
					" union all select 'BC', 'getCalcStatus', 'VARCHAR2' from dual " +
					" union all select 'BC', 'getStage', 'VARCHAR2' from dual " +
					" union all select 'BC', 'getSType', 'VARCHAR2' from dual " +
					" union all select 'BC', 'getShowDetail', 'BOOLEAN' from dual " +
					" union all select 'BC', 'getRunDate', 'DATE' from dual " +
					" union all select 'BC', 'getRecalcID', 'NUMBER' from dual " +

					") order by package_name, upper(object_name)";
}

		 ff = cn.query(q, false);

		rowCnt=0;
		for (String[] fl: ff) {
			if (fl[2].endsWith("INSTANCE")) continue;
			
			rowCnt++;
			String rowClass = "oddRow";
			if (rowCnt%2 == 0) rowClass = "evenRow";
//Util.p("plstype=" + fl[3]);			
			String fname = fl[1]+ "." + fl[2];
			String value = "";
			if (fl[3].equals("BOOLEAN"))
				value = getBCBoolean(cn.getConnection(), fname);
			else
			 	value = getBC(cn.getConnection(), fname, fl[3]);
			if (value==null) value="";
			String tooltip = null;
			if (value.startsWith("ERROR")) {
				tooltip = value;
				value = "ERROR";
			}
			String align="left";
			//if (fl[3].equals("NUMBER")||fl[3].equals("PLS_INTEGER")) align="right";
			
			//if (value.equals("")) continue;
%>
<tr class="simplehighlight">
	<td class="<%= rowClass%>"><%= fl[1] %>.<%= cn.getProcedureLabel(fl[1], fl[2])  %></td>
	<td class="<%= rowClass%>"><%= fl[3] %></td>
	<td class="<%= rowClass%>" align="<%= align %>">
	<% if (tooltip != null) {%>
		<span class="pk2"><a title='<%=Util.escapeQuote(tooltip)%>'><%= value %></a></span>
	<% } else {  %>
		<span class="pk"><%= value %></span>
	<% } %>
		
	</td>
</tr>
<%			
		}
%>
</table>

</div>

</td>
</tr>
</table>








<%
if (cn.isTVS("FORMULA")) {
	id = Util.getId();
%>
<br/><br/>
<a href="javascript:toggleFormula()"><span style="color: blue; font-family: Arial; font-size:16px; font-weight:bold;">Formulas</span><img id="imgFormula" src="image/minus.gif"></a>
<br/>
<div id="BenFormula" style="display: block;">
<table id="table-<%= id %>" border=1 class="gridBody" style="margin-left: 40px;">
<tr>
	<th class="headerRow">Client</th>
	<th class="headerRow">Plan</th>
	<th class="headerRow">ERKey</th>
	<th class="headerRow">Formula Key</th>
	<th class="headerRow">Value</th>
	<th class="headerRow">Description</th>
<!-- 	
	<th class="headerRow">Formula Type</th>
	<th class="headerRow">Category</th>
	<th class="headerRow">Page</th>
	<th class="headerRow">Display</th>
	<th class="headerRow">Formula</th>
	<th class="headerRow">Modified On</th>
	<th class="headerRow">Modified By</th>
--> 	
	<th class="headerRow">Rule</th>
</tr>


<%

		q = "SELECT * FROM (SELECT CLNT, PLAN, ERKEY, FKEY, FDESC, (SELECT NAME FROM CPAS_CODE_VALUE WHERE GRUP='PG' AND VALU=PAGE) PAGENAME, DISPLAY, FORMULA, " +
				"(SELECT NAME FROM CPAS_CODE_VALUE WHERE GRUP='RTY' AND VALU=RTYPE) CATEGORY, TIMESTAMP, USERNAME, RULEID, FTYPE, " +
				"row_number() over (partition by fkey order by decode(clnt,'"+clnt+"',0,1), decode(plan,'"+plan+"',0,1), decode(erkey,'"+erkey+"',0,1)) as rn " +
				"FROM FORMULA WHERE CLNT IN ('*','"+clnt+"') AND PLAN IN ('*','"+plan+"') " + 
				"AND ERKEY IN ('*','"+erkey+"') " + (cn.hasColumn("FORMULA", "FCLASS")?"AND FCLASS = 'F' ":"") +
				") WHERE rn=1 ORDER BY FKEY";

		// incase ERKEY is not in FORMULA
		if (!cn.hasColumn("FORMULA", "ERKEY")) {
			q = "SELECT * FROM (SELECT CLNT, PLAN, ' ' ERKEY, FKEY, FDESC, (SELECT NAME FROM CPAS_CODE_VALUE WHERE GRUP='PG' AND VALU=PAGE) PAGENAME, DISPLAY, FORMULA, " +
				"(SELECT NAME FROM CPAS_CODE_VALUE WHERE GRUP='RTY' AND VALU=RTYPE) CATEGORY, TIMESTAMP, USERNAME, RULEID, FTYPE, " +
				"row_number() over (partition by fkey order by decode(clnt,'"+clnt+"',0,1), decode(plan,'"+plan+"',0,1)) as rn " +
				"FROM FORMULA WHERE CLNT IN ('*','"+clnt+"') AND PLAN IN ('*','"+plan+"') " +
				(cn.hasColumn("FORMULA", "FCLASS")?"AND FCLASS = 'F' ":"") +
				") WHERE rn=1 ORDER BY FKEY";;
		}
		
		ff = cn.query(q, false);

		rowCnt=0;
		for (String[] fl: ff) {
			rowCnt++;
			String rowClass = "oddRow";
			if (rowCnt%2 == 0) rowClass = "evenRow";
			
			String value = getFormula(cn.getConnection(), fl[4]);
			String tooltip = null;
			if (value!=null && value.startsWith("ERROR")) {
				tooltip = value;
				value ="ERROR";
			}
			// check if there is RULE_SOURCE
			if (fl[12] != null && fl[12].length()>0) {
				String ruleid = fl[12]; 
				String cnt = cn.queryOne("SELECT COUNT(*) FROM RULE_SOURCE WHERE RULEID=" + ruleid);
				
				if (cnt.equals("0")) fl[12] = null;
			}
%>
<tr class="simplehighlight">
	<td class="<%= rowClass%>"><%= fl[1] %></td>
	<td class="<%= rowClass%>"><%= fl[2] %></td>
	<td class="<%= rowClass%>"><%= fl[3] %></td>
	<td class="<%= rowClass%>"><b><%= fl[4] %></b></td>
	<td class="<%= rowClass%>" align="right">
	<% if (tooltip != null) {%>
		<span class="pk2"><a title='<%=Util.escapeQuote(tooltip)%>'><%= value %></a></span>
	<% } else {  %>
		<span class="pk"><%= value %></span>
	<% } %>
	</td>
	<td class="<%= rowClass%>"><%= fl[5] %></td>
<!-- 	
	<td class="<%= rowClass%>"><%= fl[13]==null?"":hmFtype.get(fl[13]) %></td>
	<td class="<%= rowClass%>"><%= fl[9] %></td>
	<td class="<%= rowClass%>"><%= fl[6] %></td>
	<td class="<%= rowClass%>"><%= fl[7] %></td>
 	<td class="<%= rowClass%>"><%= fl[8]==null?"":Util.escapeHtml( fl[8] ) %><br/>
 	<td class="<%= rowClass%>"><%= fl[10] %></td>
	<td class="<%= rowClass%>"><%= fl[11] %></td>
--> 	
	<td class="<%= rowClass%>"><%= fl[12]==null?"":"<a href='javascript:showCpasRule("+fl[12]+")'>"+fl[12]+"</a>" %></td>
</tr>
<%			
		}
%>
</table>
</div>
<% } } %>

<br/><br/>
<span style="color: blue; font-family: Arial; font-size:16px; font-weight:bold;">Test</span>

<form id="formTest">
<input style="margin-left: 40px;" id="testvar" name="testvar" size=40><input type="button" value="Test" onclick="Javascript:testVar()">
</form>
<div id="testResult" style="margin-left: 40px;">
</div>

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
<form name="form-map" id="form-map" action="package-tree.jsp" target="_blank" method="get">
<input id="name-map" name="name" type="hidden">
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

