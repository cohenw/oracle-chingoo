<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>
<%
	Connect cn = (Connect) session.getAttribute("CN");
	String sdi = request.getParameter("sdi");
	String actionid = request.getParameter("actionid");
	String treekey = request.getParameter("treekey");

	String qry = "SELECT actiontype, actionstmt FROM TREEACTION_STMT WHERE SDI = '" + sdi + "' AND ACTIONID=" + actionid; 	
	List<String[]> list = cn.query(qry, false);

	int totalCnt = list.size();

//String qry = "SELECT CAPTION, TREEKEY FROM TREEVIEW where sdi='" + sdi + "' and actionid=" + actionid; // + " and treekey='" + treekey + "'"; 	
	qry = "SELECT CAPTION, TREEKEY, UDATA FROM TREEVIEW where sdi='" + sdi + "' and treekey='" + treekey + "'"; 	
	List<String[]> tv = cn.query(qry, false);
	
	String label[][] = {
			{"AW", "Display when"},
			{"MB", "Repeat while"},
			{"AK", "Set Key"},
			{"AG", "Generate Script"},
			{"AS", "Action"},
			{"ML", "Url"},
			{"AM", "IntroMessage"},
			{"AI", "Instruction text"},
			{"","<hr>"},

			{"MS", "Primary Browser Select Statement"},
			{"MC", " Caption"},
			{"MT", " Layout name"},
			{"MI", " Insert statement"},
			{"MU", " Update statement"},
			{"MD", " Delete statement"},
			{"MA", " Action statement"},
			{"MV", " Save statement"},

			{"MF", " Screen form"},
			{"MN", " Add privilege"},
			{"ME", " Edit privilege"},
			{"MR", " Delete privilege"},
			{"MP", " Export privilege"},
			{"MQ", " Allow filter data"},
			{"MW", " Allow switch view"},
			{"MG", " Allow configure view"},
			{"MY", " Display rows"},
			{"MO", " Empty set handling"},
			{"MH", " Large set handling"},
			{"MJ", " Large set total query"},
			{"MM", " Additional settings"},
			{"","<hr>"},

			{"DS", "Secondary Browser Select Statement"},
			{"DC", " Caption"},
			{"DT", " Layout name"},
			{"DI", " Insert statement"},
			{"DU", " Update statement"},
			{"DD", " Delete statement"},
			{"DA", " Action statement"},
			{"DV", " Save statement"},

			{"DF", " Screen form"},
			{"DN", " Add privilege"},
			{"DE", " Edit privilege"},
			{"DR", " Delete privilege"},
			{"DP", " Export privilege"},
			{"DQ", " Allow filter data"},
			{"DW", " Allow switch view"},
			{"DG", " Allow configure view"},
			{"DY", " Display rows"},
			{"DO", " Empty set handling"},
			{"DH", " Large set handling"},
			{"DJ", " Large set total query"},
			{"DM", " Additional settings"},
			{"","<hr>"},
			{"AR", "Remarks"}
	};
	
	String values[] = new String[label.length];
	for (int i=0;i<values.length;i++) values[i] = "";
	
	String id = Util.getId();
	String sql = "SELECT * FROM TREEACTION_STMT WHERE SDI = '" + sdi + "' AND ACTIONID=" + actionid; // + " and treekey='" + treekey + "'"; 	
	
	
	String qq = "SELECT level, caption, actionid, treekey FROM TREEVIEW connect by sdi='" + sdi + "' and itemid = prior parentid " +
		"start with sdi='" + sdi + "' and actionid= " + actionid + " and treekey='" + treekey + "' order by level desc";
	
	List<String[]> tt = cn.query(qq, false);

	String l=null;
	for (String[] s: tt) {
		String tkey = s[4];
		if (l==null)
			l = "";
		else {
			if (!l.equals("")) l += "&gt; ";
			l += "<a href=\"javascript:loadSTMT('"+sdi+"', "+s[3]+", '" + tkey + "');\">" + Util.escapeHtml(s[2]) + "</a>";
		}
	}
	
	String udata = Util.nvl(tv.get(0)[3]);
	String ruleTextClntCustom = "";
	String ruleTextCustom = "";
	String ruleTextTemplate = "";
	
	if (!udata.equals("")) {
		// Client Custom
		String clnt = cn.queryOne("SELECT CLNT FROM CALC WHERE CALCID=(SELECT MAX(CALCID) FROM CALC)");
		
		String q2 = "SELECT text FROM EXPOSE_RULE_CLNT_CUSTOM WHERE RULETYPE='" + udata + "' AND CLNT='"+ clnt + "' order by line";
//Util.p(q2);
		List<String[]> list2 = cn.query(q2, false);
		

		for (String[] lst : list2) {
			if (lst[1] != null)
				ruleTextClntCustom += lst[1] + "\n";
		}
		
		//Custom
		// see if there is custom code
		int recCount = cn.getQryCount("SELECT COUNT(*) FROM EXPOSE_RULE_CUSTOM WHERE RULETYPE='" + udata + "'");
		if (recCount > 0) {
		
//			String q4 = "SELECT text FROM EXPOSE_RULE_CUSTOM WHERE RULETYPE='" + udata + "' and texttype in ('A','B','C') order by texttype, line";
			String q4 = "SELECT text FROM ( " +
				"SELECT text, texttype, line FROM EXPOSE_RULE_CUSTOM WHERE RULETYPE='" + udata + "' " +
				"union all " +
				"SELECT text, texttype, line FROM EXPOSE_RULE_TEMPLATE WHERE RULETYPE='" + udata + "' AND texttype in ('A','C') " +
				") order by texttype, line";
Util.p(q4);
			List<String[]> list4 = cn.query(q4, false);
		
			for (String[] lst : list4) {
				if (lst[1] != null)
					ruleTextCustom += lst[1] + "\n";
			}
		}
		
		// Template
		String q3 = "SELECT text FROM EXPOSE_RULE_TEMPLATE WHERE RULETYPE='" + udata + "' and texttype in ('A','B','C') order by texttype, line";
//Util.p(q3);
		List<String[]> list3 = cn.query(q3, false);
		
		for (String[] lst : list3) {
			if (lst[1] != null)
				ruleTextTemplate += lst[1] + "\n";
		}
		
%>
<%= l %><br/><br/>
<b>Exposed : <%= udata %></b><br/>
<%
	String qry2 = "SELECT RULETYPE, NAME, CAPTION, STYPE FROM EXPOSE_RULE WHERE RULETYPE = '" + udata + "'";
Util.p(qry2);
	Query q = new Query(cn, qry2, false);
	q.rewind(1000, 1);
	int rowCnt = 0;
%>
<table id="dataTable" border=1 class="gridBody">
<tr>
	<th class="headerRow">Rule Type</th>
<!-- 	<th class="headerRow">Name</th>
 -->
 	<th class="headerRow">Caption</th>
	<th class="headerRow">Stype</th>
</tr>
<%
	while (q.next()) {
		//String ruleType = q.getValue("RULETYPE");
		String name = q.getValue("NAME");
		String caption = q.getValue("CAPTION");
		String stype = q.getValue("STYPE");
		
%>
<tr>
<td><a href="src2.jsp?name=<%= name %>" target="_blank"><%= name %></a></td>
<%-- <td><a href="Javascript:searchExposedRule('<%= ruleType %>')"><b><%= ruleType %></b></a></td> --%>
<td><%= caption %></td>
<td><%= stype %></td>
</tr>
<%
	}
%>
</table>
<br/>

<% if (!ruleTextClntCustom.equals("")) { %>
<b>Custom Code for <%= clnt %></b><br/>
<div style="margi-left: 20px; background-color: #f0f0f0;">
<pre style='font-family: Consolas;'><%= new HyperSyntax4PB().getHyperSyntax(cn, ruleTextClntCustom, "PROCEDURE", "")%></pre>
</div>
<% } %>

<% if (/* ruleText.equals("") && */ !ruleTextCustom.equals("")) { %>
<b>Custom Code</b><br/>
<div style="margi-left: 20px; background-color: #f0f0f0;">
<pre style='font-family: Consolas;'><%= new HyperSyntax4PB().getHyperSyntax(cn, ruleTextCustom, "PROCEDURE", "")%></pre>
</div>
<% } %>

<% if (/* ruleText.equals("") && */ !ruleTextTemplate.equals("")) { %>
<b>Template Code</b><br/>
<div style="margi-left: 20px; background-color: #f0f0f0;">
<pre style='font-family: Consolas;'><%= new HyperSyntax4PB().getHyperSyntax(cn, ruleTextTemplate, "PROCEDURE", "")%></pre>
</div>
<% } %>

<%		
	}
%>

<%-- 
	if ( !ruleTextClntCustom.equals("") || !ruleTextTemplate.equals("")) { 
		return;
	}
--%>



<%= l %><br/><br/>

<b><%= tv.get(0)[1] %></b> <%= tv.get(0)[2] %> 
<a href="javascript:openQuery('<%=id%>')"><img src="image/linkout.png" border=0 title="<%=sql%>"/></a>
<a href="javascript:openSimulator()">Simulator <img border=0 src="image/Media-play-2-icon.png"></a> 
&nbsp;&nbsp;&nbsp;
<a href="cpas-on.jsp?keyword=<%= tv.get(0)[2] %>" target="_blank">CPAS Online<img src="image/tree.png" width=16 height=16></a>

<div style="display: none;" id="sql-<%=id%>"><%= sql%></div>
<br/>

<%
	for (int i=0; i<list.size();i++) {
		String key = list.get(i)[1];
		String val = list.get(i)[2];
		//if (val==null || val.equals("null")) val = "";
		for (int j=0;j<label.length;j++) {
			if (key.equals(label[j][0])) values[j] = val;
		}
	}
%>

<table id="dataTable" border=1 class="gridBody" width=100%>
<tr>
	<th class="headerRow">Action Description</th>
	<th class="headerRow">Type</th>
	<th class="headerRow">Action Statement</th>
</tr>
<%
	int rowCnt = 0;

	for (int i=0;i<label.length;i++) {
		rowCnt ++;
		String rowClass = "oddRow";
		if (rowCnt%2 == 0) rowClass = "evenRow";
		
		String lbl = label[i][0];
		boolean sqlFormat = false;
		
		if ("MS.DS.MB.MI.DI.AS.MA.DA.MD.DD.MU.DU.MV.DV".contains(label[i][0]))
			sqlFormat = true;

		if (values[i].startsWith("SELECT") || values[i].startsWith("DECLARE")|| values[i].startsWith("BEGIN")) sqlFormat = true;
		
%>
<tr class="simplehighlight">
	<td class="<%= rowClass%>" nowrap><%= label[i][1] %></td>
	<td class="<%= rowClass%>" nowrap><%= label[i][0] %></td>
	<td class="<%= rowClass%>">
<%= (sqlFormat) ? "<PRE style='font-family: Consolas;'>" + new HyperSyntax().getHyperSyntax(cn, values[i], "SQL"): values[i] %>
<%= (sqlFormat) ? "</PRE>":"" %>
<% if ((label[i][0].equals("MT") || label[i][0].equals("DT")) && !values[i].equals("")) {
	id = Util.getId();
	qry = "SELECT * FROM CPAS_LAYOUT WHERE TNAME = '" + values[i] + "'";
%>
	<a href="javascript:openQuery('<%=id%>')"><img src="image/linkout.png" border=0 title="<%=qry%>"/></a>
	<div style="display: none;" id="sql-<%=id%>"><%= qry%></div>
<% } %>

<% if (label[i][0].equals("AS") && !values[i].equals("") && values[i].indexOf(" ")<0) {
%>
	<a href="cpas-process.jsp?id=<%= values[i]%>" target="_blank">open process</a>
<% } %>
<% if (lbl.equals("AW") || lbl.equals("MN") || lbl.equals("ME") || lbl.equals("MR")
		|| lbl.equals("DN") || lbl.equals("DE") || lbl.equals("DR")) { 
	String secName = cn.queryOne("SELECT CAPTION FROM SECSWITCH WHERE LABEL ='" + values[i] + "'");
	if (secName == null) secName ="";
%>
	<span class='cpas'> <%= secName %></span>
<% } %>
	</td>
</tr>

<%
	}
%>
</table>

<form id="formSimul" target="_blank" action="cpas-simul.jsp">
<input name="sdi" type="hidden" value="<%=sdi%>"/>
<input name="actionid" type="hidden" value="<%=actionid%>"/>
</form>