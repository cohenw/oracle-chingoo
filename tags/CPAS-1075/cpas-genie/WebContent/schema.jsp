<%@ page language="java" 
	import="java.util.*" 
	import="java.util.Date" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	import="spencer.genie.schema.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<%
System.out.println(new Date());
	Schema schema = new Schema();

	Connect cn = (Connect) session.getAttribute("CN");
	String sql = "SELECT OWNER, TABLE_NAME, NUM_ROWS FROM ALL_TABLES where (owner=user or owner in (select distinct table_owner from user_synonyms))";
	Query q = new Query(cn, sql, 10000, false);

	q.rewind(10000,1);
	
	int rowCnt = 0;
	while (q.next()) {
		rowCnt++;
		String owner = q.getValue(0);
		String tname = q.getValue(1);
		String numRow = q.getValue(2);
		
		Table t = new Table(owner, tname, numRow);
		schema.addTable(t);
	}
	q.destroy();
	
System.out.println(new Date());

	String sql1 = "SELECT OWNER, VIEW_NAME FROM ALL_VIEWS where (owner=user or owner in (select distinct table_owner from user_synonyms))";
	Query q1 = new Query(cn, sql1, 10000, false);

	q1.rewind(10000,1);

	while (q1.next()) {
		String owner = q1.getValue(0);
		String vname = q1.getValue(1);
	
		View v = new View(owner, vname);
		schema.addView(v);
	}
	q1.destroy();
	
System.out.println(new Date());
/*
	String sql2 = "SELECT OWNER, TABLE_NAME, COLUMN_NAME, DATA_TYPE, DATA_LENGTH, DATA_PRECISION, DATA_SCALE, NULLABLE, COLUMN_ID, DATA_DEFAULT FROM ALL_TAB_COLUMNS where (owner=user or owner in (select distinct table_owner from user_synonyms)) ORDER BY TABLE_NAME, COLUMN_ID";
	Query q2 = new Query(cn, sql2, 1000000, false);

	q2.rewind(10000,1);
	
	while (q2.next()) {
		String owner = q2.getValue(0);
		String tname = q2.getValue(1);
		String cname = q2.getValue(2);
		String dtype = q2.getValue(3);
		String id = q2.getValue("COLUMN_ID");
		String length = q2.getValue("LENGTH");
		String precision = q2.getValue("PRECISION");
		boolean nullable = q2.getValue("NULLABLE").equals("Y");
		String dvalue = q2.getValue("DATA_DEFAULT");
		
		Column c = new Column(id, cname, dtype, length, precision, nullable, dvalue); 
		
		schema.addColumn(owner, tname, c);
	}
	q2.destroy();
System.out.println(new Date());
*/	

	String sql3 = "SELECT OWNER, CONSTRAINT_NAME, TABLE_NAME from ALL_CONSTRAINTS where (owner=user or owner in (select distinct table_owner from user_synonyms)) AND CONSTRAINT_TYPE='P'";
	Query q3 = new Query(cn, sql3, 1000000, false);

	q3.rewind(10000,1);

	while (q3.next()) {
		String owner = q3.getValue(0);
		String cname = q3.getValue(1);
		String tname = q3.getValue(2);

		PrimaryKey pk = new PrimaryKey(cname); 
		schema.addPrimaryKey(owner, tname, pk);
	}
	q3.destroy();
	System.out.println(new Date());
%>

<%
	int cnt = 0;
	for (Table t : schema.getTables()) {
%>
		<%=++cnt%> <%= t.toString() %><br/>
<%		
	}
%>

<%
	cnt = 0;
	for (View v : schema.getViews()) {
%>
		<%=++cnt%> <%= v.toString() %><br/>
<%		
	}
%>