<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	import="javax.xml.transform.*"
	import="org.xml.sax.*"
	import="javax.xml.transform.sax.*"
	import="javax.xml.transform.stream.*"
	import="java.io.*"
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%><%!
public String formatXml(String xml){
    try{
        Transformer serializer= SAXTransformerFactory.newInstance().newTransformer();
        serializer.setOutputProperty(OutputKeys.INDENT, "yes");
        //serializer.setOutputProperty(OutputKeys.OMIT_XML_DECLARATION, "yes");
        serializer.setOutputProperty("{http://xml.apache.org/xslt}indent-amount", "2");
        //serializer.setOutputProperty("{http://xml.customer.org/xslt}indent-amount", "2");
        Source xmlSource=new SAXSource(new InputSource(new ByteArrayInputStream(xml.getBytes())));
        StreamResult res =  new StreamResult(new ByteArrayOutputStream());            
        serializer.transform(xmlSource, res);
        return new String(((ByteArrayOutputStream)res.getOutputStream()).toByteArray());
    }catch(Exception e){
        //TODO log error
        return xml;
    }
}
%><%
	String text = request.getParameter("xml");
	Connect cn = (Connect) session.getAttribute("CN");

	String result = formatXml(text);

%><%= result %>
