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

	String calcid = request.getParameter("calcid");
Util.p("calcid=" + calcid);
	String clnt=null;
	String plan=null;
	String mkey=null;
	String cdate=null;
	String erkey=null;

	if (calcid != null && !calcid.equals("")) {
		clnt = cn.queryOne("SELECT CLNT FROM CALC WHERE CALCID="+calcid);
		plan = cn.queryOne("SELECT PLAN FROM CALC WHERE CALCID="+calcid);
		mkey = cn.queryOne("SELECT MKEY FROM CALC WHERE CALCID="+calcid);
	} else {
		clnt = Util.nvl(request.getParameter("clnt"));
		plan = Util.nvl(request.getParameter("plan"));
		mkey = Util.nvl(request.getParameter("mkey"));
	}
	erkey = cn.queryOne("SELECT ERKEY FROM MEMBER_SERVICE WHERE CLNT='"+clnt + "' AND MKEY='" + mkey +"'");
	
	String q = "SELECT * FROM (SELECT CLNT, PLAN, ERKEY, FKEY, FDESC, (SELECT NAME FROM CPAS_CODE_VALUE WHERE GRUP='PG' AND VALU=PAGE) PAGENAME, DISPLAY, FORMULA, " +
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

	List<String[]> list = cn.query(q, 10000, true);
Util.p(q);
Util.p("size=" + list.size());
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
		if (list.get(i)[4].startsWith(term)) { 
			res1.add(list.get(i)[4]);
			res2.add(list.get(i)[5]);
			cnt ++;
		}
		if (cnt >= MAX_DISPLAY_LIST) break; 
	}	

	if (cnt < MAX_DISPLAY_LIST) {
		for (int i=0; i<list.size();i++) {
			if (!list.get(i)[4].toUpperCase().startsWith(term) && StringUtils.containsIgnoreCase(list.get(i)[5], term)) {
				res1.add(list.get(i)[4]);
				res2.add(list.get(i)[5]);
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

