package spencer.genie;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashSet;
import java.util.StringTokenizer;

public class SyntaxHighlightOld {

	static String syntaxString1[] = {"CREATE", "OR", "REPLACE", "BODY", "IS", "PACKAGE","FUNCTION","RETURN",
		"IN", "OUT", "CURSOR", "SELECT", "FROM", "WHERE", "AND", "TYPE", "ROWTYPE", "EXCEPTION",
		"PROCEDURE", "PRAGMA", "RESTRICT_REFERENCES", "END", "DEFAULT", "EXCEPTION_INIT", "BEGIN", "IF",
		"OPEN", "FETCH", "CLOSE", "FOR", "INTO", "INSERT", "DELETE", "VALUES", "AS", "TRUE", "FALSE",
		"THEN", "ELSE", "ELSIF", "NOT", "TRIGGER", "UNION", "GROUP", "BY", "ORDER", "BEFORE", "AFTER",
		"ROW", "ON", "NEW", "OLD", "EACH", "UPDATE", "OF", "DECLARE", "LOOP", "DESC",
		"WHEN", "OTHERS", "ROLLBACK", "NEXTVAL", "REF", "WITH", "ALL", "EXISTS", "EXIT",
		"NUMBER", "VARCHAR", "VARCHAR2", "DATE", "BOOLEAN",  "NULL", "FLOAT", "PLS_INTEGER",
		"INSTEAD", "COMMIT", "ROLLBACK", "SAVETO", "SET", "SYSDATE"
		};

	static String syntaxString2[] = { "SUBSTR", "TRUNC", "TO_CHAR", "TO_DATE", "ROUND", "COUNT", "AVG", "NVL",
		"DECODE", "TRIM", "LTRIM", "RTRIM", "TO_NUMBER", "GREATEST", "LEAST", "UPPER", "LOWER",
		"MIN", "MAX"};
	
	static HashSet<String> syntax1 = new HashSet<String>(Arrays.asList(syntaxString1));
	static HashSet<String> syntax2 = new HashSet<String>(Arrays.asList(syntaxString2));
	
	public static ArrayList<Range> extractComments(String text) {

		ArrayList<Range> list = new ArrayList<Range>();

		// extract multiple line comments - ex: /* .... */
		int last = 0;
		int start = 0;
		while (true) {
			start = text.indexOf("/*", last);
			
			if (start < 0) break;
			
			int end = text.indexOf("*/", start+2);
			if (end < 0) break;
			
			end +=2;
			
			//System.out.println(start + " - " + (end));
			list.add(new Range(start, end, 'C'));
			last = end;
		}
		
		// extract single line comments
		last = 0;
		while (true) {
			start = text.indexOf("--", last);
			
			if (start < 0) break;
			
			int end = text.indexOf("\n", start+2);
			if (end < 0) break;
			
			end += 1;
			
			//System.out.println(start + " : " + end);
			list.add(new Range(start, end, 'C'));
			last = end;
		}
		
		// extract string literals
		// extract single line comments
		last = 0;
		while (true) {
			start = text.indexOf("'", last);
			
			if (start < 0) break;

			// check if start is in between any of comment
			boolean isComment = false;
			for (int i=0;i<list.size();i++) {
				if (list.get(i).start < start && list.get(i).end > start) {
					isComment = true;
					break;
				}
			}
			if (isComment) {
				last = start+1;
				continue;
			}
			
			int end = text.indexOf("'", start+1);
			if (end < 0) break;
			
			end += 1;
			
			// System.out.println(start + " # " + end + ":" + text.substring(start,end));
			list.add(new Range(start, end, 'S'));
			last = end;
		}		
		
		Collections.sort(list, new Comparator<Range>(){
			 
            public int compare(Range o1, Range o2) {
        		return o1.start - o2.start;
            }
 
        });		
		return list;
	}

	public static boolean isNumeric(String str)  
	{  
	  try  
	  {  
	    double d = Double.parseDouble(str);  
	  }  
	  catch(NumberFormatException nfe)  
	  {  
	    return false;  
	  }  
	  return true;  
	}
	
	private static String syntax(String text) {
		StringTokenizer st = new StringTokenizer(text, " \t(),\n;%|", true);
		String s = "";
		
		while (st.hasMoreTokens()) {
			String token = st.nextToken();
			
			String tmp = token.toUpperCase();
			if (syntax1.contains(tmp)) {
				s += "<span class='syntax1'>" + token + "</span>";
			} else if (syntax2.contains(tmp)) {
				s += "<span class='syntax2'>" + token + "</span>";
			} else {
				if (isNumeric(tmp))
					s += "<span class='syntax3'>" + token + "</span>";
				else
					s += token;
			}
		}
		
		return s;
	}

	public static String getSyntaxHighlight(String text) {
		String s="";
		
		ArrayList<Range> ranges = extractComments(text);
		
		int start=0;
		String className="";
		for (Range r:ranges) {
			if (start > r.start) continue;
			s += syntax(text.substring(start, r.start));
			if (r.type=='C')
				className = "syn_cmt";
			else if (r.type=='S')
				className ="syn_str";
			s += "<span class='"+className+"'>";
			s += text.substring(r.start, r.end);
			s += "</span>";
			start = r.end;
		}
		s += syntax(text.substring(start));
		
		return s;
	}
}
