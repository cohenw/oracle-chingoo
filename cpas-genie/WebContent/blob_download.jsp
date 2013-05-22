<%@ page language="java" 
	import="java.io.*" 
	import="java.util.*" 
	import="java.util.Date" 
	import="java.sql.*" 
	import="spencer.genie.*"
	import="org.apache.commons.lang3.StringEscapeUtils" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>
<%
	int counter = 0;
	Connect cn = (Connect) session.getAttribute("CN");

	String fileName = request.getParameter("filename");
	String table = request.getParameter("table");
	String col = request.getParameter("col");
	String key = request.getParameter("key");
	
	String pkName = cn.getPrimaryKeyName(table);
	String conCols = cn.getConstraintCols(pkName);
	

	String sql = "SELECT " + col + " FROM " + table + " WHERE " + conCols + "='" + key +"'";
	if (sql.endsWith(";")) sql = sql.substring(0, sql.length()-1);
	sql = sql.replaceAll("&gt;",">").replace("&lt;","<");
	
	System.out.println(request.getRemoteAddr()+": " + sql +";");
	
	OldQuery q = new OldQuery(cn, sql, request);
	ResultSet rs = q.getResultSet();
	
	// get table name
	String tbl = null;
	//String temp = sql.replaceAll("\n", " ").trim();
	String temp=sql.replaceAll("[\n\r\t]", " ");
	
	int idx = temp.toUpperCase().indexOf(" FROM ");
	if (idx >0) {
		temp = temp.substring(idx + 6);
		idx = temp.indexOf(" ");
		if (idx > 0) temp = temp.substring(0, idx).trim();
		
		tbl = temp.trim();
		
		
		idx = tbl.indexOf(" ");
		if (idx > 0) tbl = tbl.substring(0, idx);
		
	}

	String fileType = "txt";
	int j = fileName.indexOf(".");
	if (j >0) fileType = fileName.substring(j+1);
	
	response.setHeader("cache-control", "must-revalidate");
	if (fileType.trim().equalsIgnoreCase("txt"))
	{
	response.setContentType( "text/plain" );
	}
	else if (fileType.trim().equalsIgnoreCase("doc"))
	{
	response.setContentType( "application/msword" );
	}
	else if (fileType.trim().equalsIgnoreCase("xls"))
	{
	response.setContentType( "application/vnd.ms-excel" );
	}
	else if (fileType.trim().equalsIgnoreCase("pdf"))
	{
	response.setContentType( "application/pdf" );
	}
	else if (fileType.trim().equalsIgnoreCase("ppt"))
	{
	response.setContentType( "application/ppt" );
	}
	else
	{
	response.setContentType( "application/octet-stream" );
	}
	
	response.setHeader("Content-Disposition","attachment; filename=\""+fileName+"\"");
	response.setHeader("cache-control", "no-cache");

	
	//Set the content header information
	String contentDisposition = "attachment; filename=";
	ServletOutputStream os = null;

	ServletContext sc = getServletContext();
	String mimetype = sc.getMimeType(fileName);

	int length = contentDisposition.length() + fileName.length();
	StringBuffer sb = new StringBuffer(length);
	sb.append(contentDisposition).append(fileName);

	response.setContentType(mimetype);
//	response.setHeader("Content-Disposition", sb.toString());


	boolean hasData = false;
	if (rs != null) hasData = rs.next();
	int colIdx = 0;
	for  (int i = 1; rs != null && i<= rs.getMetaData().getColumnCount(); i++){
		int colType = q.getColumnType(i);
		String val = q.getBlob(i);
		String escaped = Util.escapeHtml(val);

		Blob blob1 = rs.getBlob(i);
		InputStream in = new BufferedInputStream(blob1.getBinaryStream());
		os = response.getOutputStream();
		int b = -1;
		b = in.read();
		while(b != -1) {
		os.write(b);
		b = in.read();
		}

		os.flush();
		in.close();
		os.close();
		
/*		
		Blob image = rs.getBlob(i);
		File f = new File("C:\\temp\\" + fileName);
		FileOutputStream fos=new FileOutputStream(f);
		InputStream in = image.getBinaryStream();
		int length = (int) image.length();
		int bufferSize = 1024;
		byte[] buffer = new byte[bufferSize];
		while ((length = in.read(buffer)) != -1) {
		fos.write(buffer, 0, length);
		}
		out.println("Image is saved into the file.");
		in.close();
		fos.close();
*/
	}
%>
