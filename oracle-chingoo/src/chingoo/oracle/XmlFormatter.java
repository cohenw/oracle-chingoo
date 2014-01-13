package chingoo.oracle;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;

import javax.xml.transform.OutputKeys;
import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.sax.SAXSource;
import javax.xml.transform.sax.SAXTransformerFactory;
import javax.xml.transform.stream.StreamResult;

import org.xml.sax.InputSource;

public class XmlFormatter {
    public static void main(String[] args) {
    	XmlFormatter t = new XmlFormatter();
        System.out.println(t.formatXml("<a><b><c/><d>text D</d><e value='0'/></b></a>"));
        System.out.println(t.formatXml("<VESTING><SCHEDULE defaultItem=\"true\"><CLIFF_VESTING><YEARS_OR_AGE><YEARS>10</YEARS></YEARS_OR_AGE></CLIFF_VESTING></SCHEDULE></VESTING>"));
    }

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

}