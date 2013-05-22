<%@ page language="java" 
	import="java.io.*"
	import="java.util.*"
	import="java.util.Date" 
	import="java.sql.*" 
	import="spencer.genie.*"
	import="oracle.jdbc.OracleTypes" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%><%
Connect cn = (Connect) session.getAttribute("CN");

String eid = request.getParameter("id");
String fname = request.getParameter("fname");
String type = request.getParameter("type");

Connection oCon = cn.getConnection();
String res="";

response.setContentType( "text/plain" );
response.setHeader("Content-Disposition","attachment; filename=\""+fname+"\"");
response.setHeader("cache-control", "no-cache");

/*
System.out.println(cn.getSchemaName().toUpperCase());
System.out.println(type);
System.out.println(eid);
*/
 //   String cStmt = "{ ? = call UTIL_EXTRACTDATA.getCreateScript(?,?,?,?) }";
 //   String cStmt = "{ ? = call UTIL_EXTRACTDATA.getCreateScript(?,?,?) }";

    String cStmt = "{ call UTIL_EXTRACTDATA.getScriptGUI(?,?,?,?,?) }";
 
 	CallableStatement oStmt;
    int nResult = 0;
    
    try {
    	//'CLINET_55SG','MEMBER','0001_2994','S'
    	
    	oStmt = oCon.prepareCall(cStmt);
/*
    	oStmt.registerOutParameter(1, OracleTypes.CLOB);
        oStmt.setString(2,cn.getSchemaName().toUpperCase());
        oStmt.setString(3,type);
        oStmt.setString(4,eid);
        oStmt.setString(5,"S");
        oStmt.execute();
*/
		oStmt.setString(1,cn.getSchemaName().toUpperCase());
		oStmt.setString(2,type);
		oStmt.setString(3,eid);
        oStmt.setString(4,"S");
		oStmt.registerOutParameter(5, OracleTypes.CLOB);
		oStmt.execute();
        
        Clob clob1 = oStmt.getClob(5);

//        StringBuilder sb = new StringBuilder();
        try {
            Reader reader = clob1.getCharacterStream();
            BufferedReader br = new BufferedReader(reader);

            String line;
            while(null != (line = br.readLine())) {
//                sb.append(line + "\n");
                out.println(line);
            }
            br.close();
        } catch (Exception e) {
        	out.println(e);
        }
        
//        res = sb.toString();
        
        oStmt.close();
        
        oCon.commit();
    } catch (SQLException e) {
        e.printStackTrace();
        out.println(e);
    }
    
	out.flush();
%>
