<%@ page language="java" 
	import="java.io.*"
	import="java.util.*"
	import="java.util.Date" 
	import="java.sql.*" 
	import="chingoo.oracle.*"
	import="oracle.jdbc.OracleTypes" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<%
Connect cn = (Connect) session.getAttribute("CN");

Connection oCon = cn.getConnection();
String res="";
if (oCon != null) {

    String cStmt = "{ ? = call UTIL_EXTRACTDATA.getCreateScript(?,?,?,?) }";
    CallableStatement oStmt;
    int nResult = 0;
    
    try {
    	//'CLINET_55SG','MEMBER','0001_2994','S'
    	
    	oStmt = oCon.prepareCall(cStmt);
		oStmt.registerOutParameter(1, OracleTypes.CLOB);
        oStmt.setString(2,"CLIENT_55SG");
        oStmt.setString(3,"MEMBER");
        oStmt.setString(4,"0001_2994");
        oStmt.setString(5,"S");
        oStmt.execute();
        
        Clob clob1 = oStmt.getClob(1);

        StringBuilder sb = new StringBuilder();
        try {
            Reader reader = clob1.getCharacterStream();
            BufferedReader br = new BufferedReader(reader);

            String line;
            while(null != (line = br.readLine())) {
                sb.append(line + "\n");
            }
            br.close();
        } catch (SQLException e) {
            // handle this exception
        } catch (IOException e) {
            // handle this exception
        }
        
        res = sb.toString();
        
        oStmt.close();
        
        oCon.commit();
    } catch (SQLException e) {
        e.printStackTrace();
    }
    
//    out.println("Print Confirmation Set to '" + cPrinfConfYN + "'. AccountId = " + cAccountId);
}
%>

<%= res %>