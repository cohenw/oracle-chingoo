<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="spencer.genie.*"
	import="org.apache.commons.lang3.StringUtils" 
	import="org.apache.commons.lang3.StringEscapeUtils" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>
<%! 
	final int MAX_DISPLAY_LIST = 50;

%>
<%
	Connect cn = (Connect) session.getAttribute("CN");
	String term = request.getParameter("term");
	term = term.trim().toUpperCase();
	if (term.equals("")) return;
	
	String qry = "SELECT grup, caption FROM cpas_code order by 1, 2";
	
	List<String[]> list = cn.query(qry, 10000, true);
	
	int totalCnt = list.size();
	int selectedCnt = 0;

	List<String> res1 = null;
	List<String> res2 = null;
	res1 = new ArrayList<String>();
	res2 = new ArrayList<String>();
Util.p("term="+term);
/* for (int i=0; i<list.size();i++) {
	Util.p(list.get(i)[2].toUpperCase());
}
 */	int cnt = 0;
	for (int i=0; i<list.size();i++) {
		if (list.get(i)[1].startsWith(term)) { 
			res1.add(list.get(i)[1]);
			res2.add(list.get(i)[2]);
			cnt ++;
		}
		if (cnt >= MAX_DISPLAY_LIST) break; 
	}	

	if (cnt < MAX_DISPLAY_LIST) {
		for (int i=0; i<list.size();i++) {
			if (!list.get(i)[1].toUpperCase().startsWith(term) && StringUtils.containsIgnoreCase(list.get(i)[2], term)) {
				res1.add(list.get(i)[1]);
				res2.add(list.get(i)[2]);
				cnt ++;
			}
			if (cnt >= MAX_DISPLAY_LIST) break; 
		}	
	}
	
	Util.p("res1.size="+res1.size());
%>

[
<%	
for (int i=0; i<res1.size() && i < MAX_DISPLAY_LIST;i++) {
	String desc = StringEscapeUtils.escapeHtml3(res2.get(i));
	desc = desc.replaceAll("\n", "");
%>
<%=(i>0?",":"")%>{"value": "<%=res1.get(i)%>", "label": "<%=res1.get(i)%>", "desc": "<%=desc %>"} 
<% 
} 
%>
]

