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
public void bcSetAll(Connection conn, String calcId) {
	if (conn != null) {

	    String cStmt = "{ call BC.setAll(?) }";
	    CallableStatement oStmt=null;
	    int nResult = 0;
	    
	    try {
	    	oStmt = conn.prepareCall(cStmt);
	        oStmt.setString(1,calcId);
	        oStmt.execute();
	    } catch (SQLException e) {
//	    	res = "ERROR " + e.getMessage();
	        e.printStackTrace();
	    } finally {
		    try {
		    	if (oStmt != null)
				    oStmt.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
	    }
	}
}

public void bcSetAll(Connection conn, String clnt, String plan, String mkey, String calcDate) {
	if (conn != null) {

	    String cStmt = "{ call BC.setAll(?,?,?,null,to_date(?,'YYYYMMDD')) }";
	    CallableStatement oStmt=null;
	    int nResult = 0;
	    
	    try {
	    	oStmt = conn.prepareCall(cStmt);
	        oStmt.setString(1, clnt);
	        oStmt.setString(2, plan);
	        oStmt.setString(3, mkey);
	        oStmt.setString(4, calcDate);
	        
	        oStmt.execute();
	    } catch (SQLException e) {
//	    	res = "ERROR " + e.getMessage();
	        e.printStackTrace();
	    } finally {
		    try {
		    	if (oStmt != null)
				    oStmt.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
	    }
	}
}

public String getFormula(Connection conn, String formula, String erkey) {
	String res="";
	if (conn != null) {

		
	    String cStmt = "{ ? = call BC.getFormula(?,?,'') }";
//	    String cStmt = "{ ? = call BC_JAVA.getFormula(?,'') }";
	    
	    CallableStatement oStmt=null;
	    int nResult = 0;
	    
	    try {
	    	oStmt = conn.prepareCall(cStmt);
//			oStmt.registerOutParameter(1, OracleTypes.FLOAT);
			oStmt.registerOutParameter(1, OracleTypes.VARCHAR);
	        oStmt.setString(2,erkey);
	        oStmt.setString(3,formula);
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

String getDateDesc(Connect cn, String dateStr) {
	if (dateStr.startsWith("1800")||dateStr.startsWith("1700")) {
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

public String getRuleDate(Connection conn, String dateStr, String erkey) {
	String res="";
	if (conn != null) {

//	    String cStmt = "{ ? = call TO_CHAR( BC_RULE.getDate(TO_DATE(?,'YYYYMMDD')),'"+erkey+"'), 'YYYY-MM-DD') }";
	    String cStmt = "{ ? = call TO_CHAR( BC_RULE.getDate(TO_DATE(?,'YYYYMMDD'), '" + erkey+ "'), 'YYYY-MM-DD') }";
	    
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

String explainFormular(Connect cn, String ftype, String formula, String calcid, String fkey, String erkey) {
//Util.p("ftype=" + ftype + " formula=" + formula + " fkey=" + fkey);
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
 			if (cg[2].equals("D") && !(tokens.get(i).startsWith("1800")||tokens.get(i).startsWith("1700")))
 				desc = tokens.get(i);
 			else if (cg[3]!=null&&cg[3].length()>0&&tokens.get(i).length() > 0) {
//Util.p("$$$ " + cg[3] + "," +  tokens.get(i));
 				desc += cn.getCpasUtil().getGrupValue(cg[3], tokens.get(i), qCalc);
 				if (desc.equals("null") && !cg[2].equals("D")) desc = "[" + cg[3] +"]";

 				//if (cg[3].equals("FOR") || cg[3].startsWith("FOR_")) desc = "";
			} else if (cg[2].equals("D") && tokens.get(i).length() > 0 ) {
				if (tokens.get(i).startsWith("1800")||tokens.get(i).startsWith("1700"))
					desc = getDateDesc(cn, tokens.get(i));
				else
					desc = tokens.get(i);
			}
 			String value="";
 			String tooltip = null;
 			if (cg[2].equals("D")) {
 				if (tokens.get(i).length() > 0)
 					value = getRuleDate(cn.getConnection(), tokens.get(i), erkey);
 				else if (cg[4].equals("DFROM")) {
 					value ="";
 				}
 			} else if (cg[2].equals("C")) {
 				if (tokens.get(i).length() > 0) {
 					if ( cg[1].equalsIgnoreCase("Service to Use") || cg[1].equalsIgnoreCase("Earnings to Use") || cg[1].equalsIgnoreCase("Wage Base") || cg[1].equalsIgnoreCase("Service for maximum years")) {
 						value = getService(cn.getConnection(), tokens.get(i));
 					}
 					else if (cg[1].endsWith(" Earnings")|| cg[1].endsWith(" Service")) {
 						value = getService(cn.getConnection(), tokens.get(i));
 					}
 					else if (cg[1].endsWith(" age")) {
 						value = getAge(cn.getConnection(), tokens.get(i));
 					}
 					else if (cg[3] != null && (cg[3].equals("FOR") || cg[3].startsWith("FOR_"))) {
 						if (Util.isNumber(tokens.get(i)))
 							value = tokens.get(i);
 						else {
 							value = getFormula(cn.getConnection(), tokens.get(i), erkey);
 						}
 						
 					}
 					else
 						value = ""; //tokens.get(i); // + " " + getFormula(cn.getConnection(), tokens.get(i));
 				}
 			}

 			if (cg[2].equals("N")) {
 				value = tokens.get(i);
 			}
			
				if (value != null && value.startsWith("ERROR")) {
						tooltip = value;
						value = "ERROR";
					} 							

 			if (value==null || value.equals("null")) value = "";
 			if (tooltip != null) 
 				value = "<span class='pk2'><a title='" + Util.escapeQuote(tooltip) + "'>" + value + "</a></span>";
 				
// 			res += "<tr><td>" + cg[4] + "</td><td>" + cg[1] + "</td><td>"+tokens.get(i)+"</td><td>"+cg[2]+"</td><td>" + desc + 
 			res += "<tr><td>" + cg[1] + "</td><td>"+tokens.get(i)+"</td><td>"+cg[2]+"</td><td>" + desc + //" " + cg[3] +
 					"</td><td><b>" + value + "</b></td><td>" + (cg[3]==null?"":cg[3]) + "</td></tr>";
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
			String val = getFormula(cn.getConnection(), token, erkey);
			if (val.startsWith("ERROR")) val = "ERROR";
			res += "<tr><td><a href=\"javascript:searchFormula('"+token+"')\">" + token + "</a></td><td>" + getFormulaDesc(cn, token) + "</td><td align=right><b>" + val + "</b></td></tr>";
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

public String getService(Connection conn, String varname) {
	String res="";
	if (conn != null) {

	    String cStmt = "{ ? = call round(BC_SERVICE.getService(?),10) }";
//	    String cStmt = "{ ? = call BC_SERVICE.getService(?) }";
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
	        e.printStackTrace();
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

%>
<%
	Connect cn = (Connect) session.getAttribute("CN");

	String calcid = request.getParameter("calcid");
	String fkey = request.getParameter("fkey");
	
	String clnt=null;
	String plan=null;
	String mkey=null;
	String cdate=null;
	String erkey=null;

	if (calcid != null && !calcid.equals("")) {
		bcSetAll(cn.getConnection(), calcid);
		
		clnt = cn.queryOne("SELECT CLNT FROM CALC WHERE CALCID="+calcid);
		plan = cn.queryOne("SELECT PLAN FROM CALC WHERE CALCID="+calcid);
		mkey = cn.queryOne("SELECT MKEY FROM CALC WHERE CALCID="+calcid);
	} else {
		
		clnt = Util.nvl(request.getParameter("clnt"));
		plan = Util.nvl(request.getParameter("plan"));
		mkey = Util.nvl(request.getParameter("mkey"));
		cdate = Util.nvl(request.getParameter("cdate"));
		
		calcid = cn.queryOne("SELECT MAX(CALCID) FROM CALC WHERE CLNT='"+clnt + "' AND MKEY='" + mkey +"'");
		
		bcSetAll(cn.getConnection(), clnt, plan, mkey, cdate);
	}
//Util.p("* clnt="+clnt);	
	//erkey = cn.queryOne("SELECT ERKEY FROM MEMBER_SERVICE WHERE CLNT='"+clnt + "' AND MKEY='" + mkey +"'");
	erkey = cn.queryOne("select erkey from ( "+
				"SELECT A.*, row_number() over (partition by clnt, mkey order by edate) rn " +
				"FROM MEMBER_SERVICE A WHERE CLNT='"+clnt + "' AND MKEY='"+mkey+"' " +
				"and edate <= (select cdate from calc where calcid="+calcid + ") " + 
				") where rn=1");	
	
	String qry = "SELECT FTYPE VALU,NAME FROM CPAS_FORMULA ORDER BY NAME";
	List<String[]> ftypes = cn.query(qry);
	
	HashMap<String, String> hmFtype = new HashMap<String, String>(); 
	for (String[] var: ftypes) {
		hmFtype.put(var[1], var[2]);
	}
%>
<table id="table-formula" border=1 class="gridBody" style="margin-left: 20px;">
<tr>
	<th class="headerRow">Client</th>
	<th class="headerRow">Plan</th>
	<th class="headerRow">ERKey</th>
	<th class="headerRow">Formula Key</th>
	<th class="headerRow">Value</th>
	<th class="headerRow">Description</th>
	<th class="headerRow">Additional Info</th>
<!-- 
	<th class="headerRow">Formula Type</th>
	<th class="headerRow">Category</th>
	<th class="headerRow">Page</th>
	<th class="headerRow">Display</th>
	<th class="headerRow">Formula</th>
	<th class="headerRow">Modified On</th>
	<th class="headerRow">Modified By</th>
--> 	
	<th class="headerRow">Formula Explained</th>
	<th class="headerRow">Modified By</th>
	<th class="headerRow">Rule</th>
</tr>


<%

		String q = "SELECT * FROM (SELECT CLNT, PLAN, ERKEY, FKEY, FDESC, (SELECT NAME FROM CPAS_CODE_VALUE WHERE GRUP='PG' AND VALU=PAGE) PAGENAME, DISPLAY, FORMULA, " +
				"(SELECT NAME FROM CPAS_CODE_VALUE WHERE GRUP='RTY' AND VALU=RTYPE) CATEGORY, TIMESTAMP, USERNAME, RULEID, FTYPE, " +
				"row_number() over (partition by fkey order by decode(clnt,'"+clnt+"',0,1), decode(plan,'"+plan+"',0,1), decode(erkey,'"+erkey+"',0,1)) as rn " +
				"FROM FORMULA WHERE CLNT IN ('*','"+clnt+"') AND PLAN IN ('*','"+plan+"') " + 
				"AND ERKEY IN ('*','"+erkey+"') " + (cn.hasColumn("FORMULA", "FCLASS")?"AND FCLASS = 'F' ":"") +
				(fkey != null?"AND FKEY = '"+fkey+"' ":"") +
				") WHERE rn=1 ORDER BY FKEY";

		// incase ERKEY is not in FORMULA
		if (!cn.hasColumn("FORMULA", "ERKEY")) {
			q = "SELECT * FROM (SELECT CLNT, PLAN, ' ' ERKEY, FKEY, FDESC, (SELECT NAME FROM CPAS_CODE_VALUE WHERE GRUP='PG' AND VALU=PAGE) PAGENAME, DISPLAY, FORMULA, " +
				"(SELECT NAME FROM CPAS_CODE_VALUE WHERE GRUP='RTY' AND VALU=RTYPE) CATEGORY, TIMESTAMP, USERNAME, RULEID, FTYPE, " +
				"row_number() over (partition by fkey order by decode(clnt,'"+clnt+"',0,1), decode(plan,'"+plan+"',0,1)) as rn " +
				"FROM FORMULA WHERE CLNT IN ('*','"+clnt+"') AND PLAN IN ('*','"+plan+"') " +
				(cn.hasColumn("FORMULA", "FCLASS")?"AND FCLASS = 'F' ":"") +
				(fkey != null?"AND FKEY = '"+fkey+"' ":"") +
				") WHERE rn=1 ORDER BY FKEY";;
		}
//Util.p(q);		
		List<String[]> ff = cn.query(q, false);

		int rowCnt=0;
		for (String[] fl: ff) {
			rowCnt++;
			String rowClass = "oddRow";
			if (rowCnt%2 == 0) rowClass = "evenRow";
			
			String value = getFormula(cn.getConnection(), fl[4], erkey);
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
		<span class="pk3"><%= value %></span>
	<% } %>
	</td>
	<td class="<%= rowClass%>"><%= fl[5] %></td>
	
	<td class="<%= rowClass%>">
		Type: <%= fl[13]==null?"":"[" + fl[13] + "] " +hmFtype.get(fl[13]) %><br/>
		Category: <%= fl[9] %> <br/>
		Page: <%= fl[6] %><br/>
		Display: <%= fl[7] %><br/>
	
 	<td class="<%= rowClass%>">
 	<% if (fl[13].equals("RA")) { // user defined %>
 		<%= "" %>
 	<% } else { %>
 		<%= fl[8]==null?"":Util.escapeHtml( fl[8] ) %><br/>
 		<%= explainFormular(cn, fl[13], fl[8], calcid, fl[4], erkey) %>
 	<% } %>
 	</td>
 	<td class="<%= rowClass%>"><%= fl[11] %><br/><%= fl[10] %></td>

	<td class="<%= rowClass%>"><%= fl[12]==null?"":"<a href='javascript:showCpasRule("+fl[12]+")'>"+fl[12]+"</a>" %></td>
</tr>
<%			
		}
%>
</table>

<%
cn.getConnection().rollback();
%>
