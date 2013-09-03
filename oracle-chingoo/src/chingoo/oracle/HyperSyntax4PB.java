package chingoo.oracle;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashSet;
import java.util.List;
import java.util.StringTokenizer;

public class HyperSyntax4PB {

	static String delim = " \r\n\t(),;%|=><*+-";
	
	static String syntaxString1[] = {"CREATE", "OR", "BODY", "IS", "PACKAGE","FUNCTION","RETURN",
		"IN", "OUT", "CURSOR", "SELECT", "FROM", "WHERE", "AND", "TYPE", "ROWTYPE", "EXCEPTION",
		"PROCEDURE", "PRAGMA", "RESTRICT_REFERENCES", "END", "DEFAULT", "EXCEPTION_INIT", "BEGIN", "IF",
		"OPEN", "FETCH", "CLOSE", "FOR", "INTO", "INSERT", "DELETE", "VALUES", "AS", "TRUE", "FALSE",
		"THEN", "ELSE", "ELSIF", "NOT", "TRIGGER", "UNION", "GROUP", "BY", "ORDER", "BEFORE", "AFTER",
		"ROW", "ON", "NEW", "OLD", "EACH", "UPDATE", "OF", "DECLARE", "WHILE", "LOOP", "DESC", "ASC",
		"WHEN", "OTHERS", "ROLLBACK", "NEXTVAL", "REF", "WITH", "ALL", "EXISTS", "EXIT",
		"NUMBER", "CHAR", "VARCHAR", "VARCHAR2", "DATE", "BOOLEAN",  "NULL", "FLOAT", "PLS_INTEGER",
		"INSTEAD", "COMMIT", "ROLLBACK", "SAVEPOINT", "SET", "EXECUTE", "IMMEDIATE",
		"CONSTANT", "DEF", "WNDS", "RNDS", "WNPS", "RETURNING", "BINARY_INTEGER", "TABLE", "INDEX",
		"RECORD", "FOUND", "NOTFOUND", "ALTER", "ANY", "BETWEEN", "CURRENT", "COMMENT", "CONNECT", "DISTINCT",
		"DROP", "GRANT", "HAVING", "IDENTIFIED", "INCREMENT", "INDEX", "VIEW", "INTERSECT",
		"LEVEL", "LIKE", "LOCK", "LONG", "CLOB", "BLOB", "MINUS", "ONLINE", "OFFLINE", "OPTION", "PRIOR",
		"PUBLIC", "ROWID", "ROWNUM", "ROWS", "SESSION", "SET", "SMALLINT", "START", "SYNONYM", "UNIQUE",
		"VALIDATE"
		};

	static String syntaxString2[] = { "SUBSTR", "TRUNC", "TO_CHAR", "TO_DATE", "ROUND", "COUNT", "AVG", "NVL",
		"DECODE", "TRIM", "LTRIM", "RTRIM", "TO_NUMBER", "GREATEST", "LEAST", "UPPER", "LOWER",
		"MIN", "MAX", "REPLACE", "RAISE_APPLICATION_ERROR",	"ASCII", "ASCIISTR", "CHR", "COMPOSE", "CONCAT",
		"CONVERT","DECOMPOSE","DUMP","INITCAP","INSTR","LENGTH","LOWER","LPAD","LTRIM","REPLACE",
		"RPAD","RTRIM","SOUNDEX","SUBSTR","TRANSLATE","TRIM","UPPER","VSIZE","BIN_TO_NUM","CAST",
		"CHARTOROWID","FROM_TZ","HEXTORAW","NUMTODSINTERVAL","NUMTOYMINTERVAL","RAWTOHEX","TO_CHAR","TO_CLOB",
		"TO_DATE","TO_DSINTERVAL","TO_LOB","TO_MULTI_BYTE","TO_NCLOB","TO_NUMBER","TO_SINGLE_BYTE","TO_TIMESTAMP",
		"TO_TIMESTAMP_TZ","TO_YMINTERVAL","COALESCE","DECODE","GROUP_ID","LAG","LEAD","LNNVL","NANVL","NULLIF",
		"NVL","NVL2","SYS_CONTEXT","UID","USER","USERENV","ABS","ACOS","ASIN","ATAN","ATAN2","AVG","BIN_TO_NUM",
		"BITAND","CEIL","CORR","COS","COSH","COVAR_POP","COVAR_SAMP","COUNT","CUME_DIST","DENSE_RANK","EXP",
		"EXTRACT","FLOOR","GREATEST","LEAST","LN","LOG","MAX","MEDIAN","MIN","MOD","POWER","RANK","REMAINDER",
		"SIGN","SIN","SINH","SQRT","STDDEV","SUM","TAN","TANH","VAR_POP","VAR_SAMP","VARIANCE","ADD_MONTHS",
		"CURRENT_DATE","CURRENT_TIMESTAMP","DBTIMEZONE","FROM_TZ","LAST_DAY","LOCALTIMESTAMP","MONTHS_BETWEEN",
		"NEW_TIME","NEXT_DAY","ROUND","SESSIONTIMEZONE","SYSDATE","TO_DATE","TRUNC","TZ_OFFSET","SYSTIMESTAMP",
		"TO_CHAR","ERROR FUNCTIONS","SQLCODE","SQLERRM"
	};
	
	static HashSet<String> syntax1 = new HashSet<String>(Arrays.asList(syntaxString1));
	static HashSet<String> syntax2 = new HashSet<String>(Arrays.asList(syntaxString2));
	
	HashSet<String> vars = new HashSet<String>();
	String procName = "";
	String pr=null; // procedure name 
	HashSet<String> packageProc = new HashSet<String>();

	int cntProc = 0;
	
	public HyperSyntax4PB() {
	}

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
			//if (end < 0) break;
			if (end < 0) end = text.length()-1;

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

	private static ArrayList<String> getProcedureNames(String text, String type) {
		ArrayList<String> list = new ArrayList<String>();
		
		StringTokenizer st = new StringTokenizer(text, delim, true);
		String s = "";
		while (st.hasMoreTokens()) {
			String token = st.nextToken();
			
			String tmp = token.toUpperCase();
			if (tmp.equals("PROCEDURE")|| tmp.equals("FUNCTION")|| tmp.equals("TRIGGER")){
				String name="";
				while (true) {
					name = st.nextToken();
					if (!name.trim().equals("")) break;
					if(!st.hasMoreTokens()) break;
				}
				list.add(name.toUpperCase());
				
			}
			
		}
		
		return list;
	}

	public static HashSet<String> getLinkables(String key, String text) {
		HashSet<String> set = new HashSet<String>();
		
		String textU = text.toUpperCase();
		int start=0;
		int end=0;
		int cnt=0;
		while (true) {
			start = textU.indexOf(key, end);
			if (start < 0) break;
			if (++cnt > 1000) break;
			
			char ch = ' ';
			if (start-1 >=0) {
				 ch = textU.charAt(start-1);
				// System.out.println("(" + ch + ")");
				if (delim.indexOf(ch)<0 ) {
					continue;
				}
			}
			
			ch = textU.charAt(start +key.length());
			//System.out.println("(" + ch + ")");
			if (delim.indexOf(ch)<0 ) {
				continue;
			}
			
			end = textU.indexOf(";", start);
			if (end < 0) break;
			
			end+=2;
			
			String tmp = text.substring(start+key.length(), end).trim();
			StringTokenizer st = new StringTokenizer(tmp, delim);
			if (st.hasMoreTokens()) {
				String token = st.nextToken();
				set.add(token.toUpperCase());
			}
			
			//System.out.println("[" + text.substring(start, end) + "] (" + tmp + ")");
		}
		//System.out.println("SSSS " + set);
		
		return set;
	}
	
	// Get linkable - Global Variables
	public static HashSet<String> getLinkablesGV(String text) {
		HashSet<String> set = new HashSet<String>();
		
		String textU = text.toUpperCase();
		int start=0;
		int end=0;
		while (true) {
			start = textU.indexOf("\n", end);
			if (start < 0) break;
			
			end = textU.indexOf(";", start);
			if (end < 0) break;
			
			end++;
			
			String tmp = text.substring(start, end).trim();
			StringTokenizer st = new StringTokenizer(tmp, delim, false);
			if (st.hasMoreTokens()) {
				String token = st.nextToken();
				if (token.equals("CURSOR") || token.equals("TYPE")) {
					if (st.hasMoreTokens()) token = st.nextToken();
				}
				
				if (!syntax1.contains(token)) {
					set.add(token.toUpperCase());
					//System.out.println(" gv=" + token);
				}
			}
			
			//System.out.println("[" + text.substring(start, end) + "] (" + tmp + ")");
		}
		//System.out.println("GV " + set);
		
		return set;
	}

	public static HashSet<String> getProcedures(String text, ArrayList<Range> ranges, String type) {
		
		HashSet<String> set = new HashSet<String>();
		
		int start=0;
		for (Range r:ranges) {
			if (start > r.start) continue;
			String s = text.substring(start, r.start);
			ArrayList<String> list = getProcedureNames(s, type);
			set.addAll(list);
			
			start = r.end;
		}
		String s = text.substring(start);	
		ArrayList<String> list = getProcedureNames(s, type);
		set.addAll(list);
		
		//System.out.println("SET" + set);
		return set;
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
	
	private String hyperSyntax(Connect cn, String text, HashSet<String> procedures, HashSet<String> GV, String type, String pkgName) {
		StringTokenizer st = new StringTokenizer(text, delim, true);
		StringBuffer s = new StringBuffer();
		boolean hyperlink = false;
		
		boolean catchName = false;
		while (st.hasMoreTokens()) {
			String token = st.nextToken();
			if (token.equals("\t")) token = "   ";	// convert tab to 3 spaces
			
			if (token.length()==1 && token.indexOf(delim)>=0 ) {
				s.append( Util.escapeHtml(token) );
				continue;
			} 
			
			String tmp = token.toUpperCase();
/*			
			if (this.procName==null && !tmp.trim().equals("")) {
				procName = tmp;
				//System.out.println("procName " + tmp);
			}
*/
			
			if (catchName && !tmp.trim().equals("")) {
				catchName = false;
				pr = tmp; 
			}
			
			if (tmp.equals("PROCEDURE")|| tmp.equals("FUNCTION")|| tmp.equals("TRIGGER")){
				//s += "<a name='chapter'></a>"+ "<span class='syntax1'>" + token + "</span>";
				s.append( "<span class='syntax1'>" + token + "</span>" );
				if (!type.equals("PACKAGE"))
					hyperlink = true;
				hyperlink = false;

				cntProc++;
				this.procName = "P1"; // + cntProc;
				catchName = true;
			} else if (syntax1.contains(tmp)) {
				s.append( "<span class='syntax1'>" + token + "</span>" );
			} else if (syntax2.contains(tmp)) {
				s.append( "<span class='syntax2'>" + token + "</span>" );
			} else if (isNumeric(tmp))
				s.append( "<span class='syntax3'>" + token + "</span>" );
			else if (cn.isTVS(tmp)|| cn.isPublicSynonym(tmp)) {
				s.append( "<a style='color: darkblue;' href='pop.jsp?key="+tmp+"' target='_blank'>" + token + "</a>" );
			} else if (cn.isProcedure(tmp)) {
				s.append( "<a style='color: darkblue;' target='_blank' href=\"Javascript:loadProc('" + pkgName + "','" + tmp + "');\">" + token + "</a>" );
			} else if (hyperlink && !tmp.trim().equals("")) {
				hyperlink = false;
				s.append( "<a name='" + tmp.toLowerCase() + "'></a><a href='package-tree.jsp?name=" + pkgName + "." + token + "' target=_blank>"+ token + "</a>");
			} else if (GV !=null && GV.contains(tmp)) {
				if (type.equals("PACKAGE"))
					s.append( "<a name='" + tmp.toLowerCase() + "'>" + token + "</a>" );
				else {
					s.append( "<a style='color: darkblue;' href=\"Javascript:loadProc('" + pkgName + "','" + tmp + "');\">" + token + "</a>" );
//					System.out.println(pr + " proc1 " + tmp);			
				}
			} else if (procedures.contains(tmp)) {
				s.append( "<a style='color: darkblue;' href=\"Javascript:loadProc('" + pkgName + "','" + tmp + "');\">" + token + "</a>" );
//				System.out.println(pr + " proc2 " + tmp);
				packageProc.add(pr + " "  + tmp);
			} else if (vars.contains(procName+"-"+tmp))
				s.append( "<span class='"+procName+"-"+tmp+"' onmouseover='hi_on(\"" + procName+"-"+tmp + "\")' onclick='hi_off(\"" + procName+"-"+tmp + "\")'>" + token + "</span>" );
			else if (tmp.indexOf('.') > 0) {
				int idx = tmp.indexOf('.');
				String pkg = tmp.substring(0,idx);
				String prc = tmp.substring(idx+1);
				
				if (cn.isPackage(pkg)||(cn.isSynonym(pkg))) {
					s.append( "<a style='color: darkblue;' target='_blank' href=\"Javascript:loadProc('" + pkg + "','" + prc + "');\">" + token + "</a>" );
					packageProc.add(pr + " "  + tmp);
//					System.out.println(pr + " proc3 " + tmp);
				} else if (vars.contains(procName+"-"+pkg)) { 
					s.append( "<span class='"+procName+"-"+pkg+"' onmouseover='hi_on(\"" + procName+"-"+pkg + "\")' onclick='hi_off(\"" + procName+"-"+pkg + "\")'>" + token + "</span>" );
				} else
					s.append( token );
			} else {
				s.append( Util.escapeHtml(token) );
			}
			
		}
		
		return s.toString();
	}

	public String getHyperSyntax(Connect cn, String text, String type) {
		return getHyperSyntax( cn, text, type, "");
	}

	public String getHyperSyntax(Connect cn, String text, String type, String pkgName) {
		StringBuffer s = new StringBuffer();
		ArrayList<Range> ranges = extractComments(text);
		
		// build string that stripped out comment and string literals
		StringBuffer sb2 = new StringBuffer();
		int start=0;
		for (Range r:ranges) {
			if (start > r.start) continue;
			sb2.append(text.substring(start, r.start));
			start = r.end;
		}
		sb2.append( text.substring(start));
		String s2 = sb2.toString();
		
		PlsqlAnalyzer4PB pa = new PlsqlAnalyzer4PB(s2);
		this.vars = pa.getVariables();
//System.out.println("s2 vars=" + this.vars);
		
		//System.out.println("s2 size=" + s2.length());
		// if (s2.length()<5000) System.out.println(s2);
		
//		HashSet<String> set1 = getLinkables("PROCEDURE", s2);
//		HashSet<String> set2 = getLinkables("FUNCTION", s2);
		HashSet<String> GV = cn.tempSet; 
/*
		if (type.equals("PACKAGE")) {
			GV = getLinkablesGV(s2);
			cn.tempSet = GV;
		}
*/		
		HashSet<String> procedures = new HashSet<String>();

		String q = "SELECT PROCEDURE_NAME FROM CHINGOO_PA_PROCEDURE WHERE PACKAGE_NAME='" + pkgName +"'";
//		System.out.println(q);
		List<String[]> prcs = cn.query(q, false);
		
		for (int i=0;i<prcs.size();i++) {
			String prc = prcs.get(i)[1];
			procedures.add(prc);
		}
		
//		procedures.addAll(set1);
//		procedures.addAll(set2);
		
		this.procName = "";
		this.cntProc=0;
		start=0;
		String className="";
		for (Range r:ranges) {
			if (start > r.start) continue;
			s.append( hyperSyntax(cn, text.substring(start, r.start), procedures, GV, type, pkgName) );
			if (r.type=='C')
				className = "syn_cmt";
			else if (r.type=='S')
				className ="syn_str";
			s.append( "<span class='"+className+"'>" );
			s.append( Util.escapeHtml( text.substring(r.start, r.end) ) );
			s.append( "</span>" );
			start = r.end;
		}
		s.append( hyperSyntax(cn, text.substring(start), procedures, GV, type, pkgName) );
		
		return s.toString();
	}
	
	public HashSet<String> getPackageProcedure() {
		return this.packageProc;
	}
	
	public ArrayList<String> getTables(Connect cn, String sql) {
		ArrayList<String> tables = new ArrayList<String>();
		
		StringTokenizer st = new StringTokenizer(sql, delim, true);
		while (st.hasMoreTokens()) {
			String token = st.nextToken();
			
			if (token.length()==1 && token.indexOf(delim)>=0 ) {
				continue;
			} 
			
			String tmp = token.toUpperCase();
			//System.out.println("[" + tmp + "]");
			if (syntax1.contains(tmp) || syntax2.contains(tmp)) {
				continue;
			} else if (cn.isTVS(tmp) || cn.isPublicSynonym(tmp)) {
				if (!tables.contains(tmp))
					tables.add(tmp);
			}
		}

		return tables; 
	}
	
	static String slimIt(String src) {
System.out.println("before slim " + src.length());
		StringBuffer sb = new StringBuffer();
		
		int processedUpto=0;
		int start = getNextSpanIndex(src, 0);

		String prevSpan = null;
		String span = getSpanString(src, start);
		while (span != null) {
	//		System.out.println(span);
			if (prevSpan == null) {
				sb.append(src.substring(0, start));
				//System.out.println("[" + sb.toString() + "]");
				prevSpan = span;
				processedUpto = start;
			} else if (!span.equals(prevSpan)){
				//System.out.println("   "+ prevSpan + " " + span);
				String temp = src.substring(processedUpto, start);
				int s1 = temp.indexOf(">");
				int s2 = temp.lastIndexOf("</span>");
				
//				System.out.println("s1,s2 "+s1+","+s2);
				String temp3 = "";
				if (s1>0 && s2>0) {
					String temp2 = temp.substring(s1+1, s2);
					temp3 = temp.substring(s2+7);
//					System.out.println("temp2=[" + temp2 + "]");
//					System.out.println("temp3=[" + temp3 + "]");
					
					temp = temp2;
				}
				
				String newString = temp.replace("</span>", "");
				newString = newString.replace(prevSpan, "");
				newString = prevSpan + newString + "</span>" + temp3;
				
//				System.out.println("    ["+ temp + "] ]" + newString + "[");
				sb.append(newString);
				prevSpan = span;
				processedUpto = start;
			}
			
			start = getNextSpanIndex(src, start + span.length());
			if (start <0) break;
			span = getSpanString(src, start);
		}
		String temp = src.substring(processedUpto);
//		System.out.println("    ["+ temp + "]");
		sb.append(temp);

		System.out.println("after slim " + sb.length());

		return sb.toString();
	}

	static int getNextSpanIndex(String str, int start) {
		int i = str.indexOf("<span ", start);
		
		return i;
	}
	
	static String getSpanString(String str, int start) {
		int end = str.indexOf(">", start);
		if (end <0) return null;
		
		return str.substring(start, end+1);
	}	
}
