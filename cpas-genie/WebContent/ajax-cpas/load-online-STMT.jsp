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

	String qry = "SELECT actiontype, actionstmt FROM TREEACTION_STMT WHERE SDI = '" + sdi + "' AND ACTIONID=" + actionid + ""; 	
	List<String[]> list = cn.query(qry);

	int totalCnt = list.size();
	
	qry = "SELECT CAPTION, TREEKEY FROM TREEVIEW where sdi='" + sdi + "' and actionid=" + actionid; 	
	List<String[]> tv = cn.query(qry);
	
	String label[][] = {
			{"AW", "Display when"},
			{"MB", "Repeat while"},
			{"SK", "Set Key"},
			{"AG", "Generate Script"},
			{"AS", "Action"},
			{"ML", "Url"},
			{"AI", "Instruction text"},
			{"","<hr>"},

			{"MS", "Primary Browser Select Statement"},
			{"MC", "Primary Caption"},
			{"MT", "Primary Layout name"},
			{"MI", "Primary Insert statement"},
			{"MU", "Primary Update statement"},
			{"MD", "Primary Delete statement"},
			{"MA", "Primary Action statement"},
			{"MV", "Primary Save statement"},

			{"MF", "Primary Screen form"},
			{"MN", "Primary Add privilege"},
			{"ME", "Primary Edit privilege"},
			{"MR", "Primary Delete privilege"},
			{"MY", "Primary Display rows"},
			{"","<hr>"},

			{"DS", "Secondary Browser Select Statement"},
			{"DC", "Secondary Caption"},
			{"DT", "Secondary Layout name"},
			{"DI", "Secondary Insert statement"},
			{"DU", "Secondary Update statement"},
			{"DD", "Secondary Delete statement"},
			{"DA", "Secondary Action statement"},
			{"DV", "Secondary Save statement"},

			{"DF", "Secondary Screen form"},
			{"DN", "Secondary Add privilege"},
			{"DE", "Secondary Edit privilege"},
			{"DR", "Secondary Delete privilege"},
			{"DY", "Secondary Display rows"},
			{"","<hr>"},
			{"AR", "Remarks"}
	};
	
	String values[] = new String[label.length];
	for (int i=0;i<values.length;i++) values[i] = "";
	
	String id = Util.getId();
	String sql = "SELECT * FROM TREEACTION_STMT WHERE SDI = '" + sdi + "' AND ACTIONID=" + actionid + ""; 	
%>
<b><%= tv.get(0)[1] %></b> <%= tv.get(0)[2] %>
<a href="javascript:openQuery('<%=id%>')"><img src="image/sql.png" border=0 align=middle  title="<%=sql%>"/></a>
<a href="javascript:openSimulator()">Simulator <img border=0 src="http://icons.iconarchive.com/icons/cornmanthe3rd/plex/16/Media-play-2-icon.png"></a>
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

<table id="dataTable" border=1 class="gridBody">
<tr>
	<th class="headerRow">Action Description</th>
	<th class="headerRow">Type</th>
	<th class="headerRow">Action Statement</th>
</tr>
<%
	int rowCnt = 0;

	for (int i=0;i<label.length;i++) {
		if (values[i].equals("")) continue;
		rowCnt ++;
		String rowClass = "oddRow";
		if (rowCnt%2 == 0) rowClass = "evenRow";
		
		String lbl = label[i][0];
%>
<tr class="simplehighlight">
	<td class="<%= rowClass%>" nowrap><%= label[i][1] %></td>
	<td class="<%= rowClass%>" nowrap><%= label[i][0] %></td>
	<td class="<%= rowClass%>">
<%= (label[i][0].equals("MS") || label[i][0].equals("DS")) ? "<PRE>":"" %><%= values[i] %>
<%= (label[i][0].equals("MS") || label[i][0].equals("DS")) ? "</PRE>":"" %>

<% if ((label[i][0].equals("MT") || label[i][0].equals("DT")) && !values[i].equals("") && values[i].length() < 30) {
	id = Util.getId();
	qry = "SELECT * FROM CPAS_LAYOUT WHERE TNAME = '" + values[i] + "'";
%>
	<a href="javascript:openQuery('<%=id%>')"><img src="image/sql.png" border=0 align=middle  title="<%=qry%>"/></a>
	<div style="display: none;" id="sql-<%=id%>"><%= qry%></div>
<% } %>

<% if (label[i][0].equals("AS") && !values[i].equals("") && values[i].indexOf(" ")<0) {
%>
	<a href="cpas-process.jsp?id=<%= values[i]%>" target="_blank">open process</a>
<% } %>

<% if (lbl.equals("AW") || lbl.equals("MN") || lbl.equals("ME") || lbl.equals("MR")
		|| lbl.equals("DN") || lbl.equals("DE") || lbl.equals("DR")) { 
	String secName = cn.queryOne("SELECT CAPTION FROM SECSWITCH WHERE LABEL ='" + values[i] + "'");
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