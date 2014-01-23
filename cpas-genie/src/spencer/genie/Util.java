package spencer.genie;

import java.io.UnsupportedEncodingException;
import java.lang.instrument.Instrumentation;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;

import org.apache.commons.lang3.StringEscapeUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.math.NumberUtils;

/**
 * Utility class for Genie
 * 
 * @author spencer.hwang
 *
 */
public class Util {

	static int counter = 0;
	
	public static int countLines(String str) {
		String[] lines = str.split("\r\n|\r|\n");
		return lines.length;
	}
	
	public static int countMatches(String str, String value) {
		int count = StringUtils.countMatches(str, value);
		return count;
	}
	
	public static String buildCondition(String col, String key) {
		String res="1=1";
		
		if (key==null) key = "is null";
		
		if (key==null || col==null) return null;
//System.out.println("col= " + col);
//System.out.println("key= " + key);
		
		String[] cols = col.split(",");
		String[] keys = key.split("\\^");
		
		if (cols.length != keys.length) {
			
			System.out.println(col + " " + key);
			System.out.println(cols.length + " " + keys.length);
			return "ERROR";
		}
		
		for(int i =0; i < cols.length; i++) {
			
			if (keys[i].equals("is null"))
				res = res + " AND " + cols[i].trim() + " IS NULL";
			else if (keys[i].length()==10 && keys[i].substring(4,5).equals("-") && keys[i].substring(7,8).equals("-")) { // date 
				res = res + " AND " + cols[i].trim() + "= to_date('" + keys[i] + "','yyyy-mm-dd')";
			} else if (keys[i].length()==19 && keys[i].substring(4,5).equals("-") && keys[i].substring(7,8).equals("-")) { // date 
				res = res + " AND " + cols[i].trim() + "= to_date('" + keys[i] + "','yyyy-mm-dd hh24:mi:ss')";
			} else if (keys[i].length()==21 && keys[i].substring(4,5).equals("-") && keys[i].substring(7,8).equals("-")) { // date 
				res = res + " AND " + cols[i].trim() + "= to_date('" + keys[i].substring(0,19) + "','yyyy-mm-dd hh24:mi:ss')";
			} else if (keys[i].length()>21 && keys[i].substring(4,5).equals("-") && keys[i].substring(7,8).equals("-")) { // timestamp 
				res = res + " AND " + cols[i].trim() + "= TO_TIMESTAMP('" + keys[i] + "','YYYY-MM-DD HH24:MI:SS.FF')";
			} else {
				res = res + " AND " + cols[i].trim() + "='" + keys[i] + "'";
			}
		}
			
		return res.replace("1=1 AND ", "");
	}
	
	public static String escapeHtml(String str) {
		return StringEscapeUtils.escapeHtml3(str);
	}
	
	public static String encodeUrl(String str) throws UnsupportedEncodingException {
		if (str==null) return null;
		//return java.net.URLEncoder.encode(str, "ISO-8859-1");
		return java.net.URLEncoder.encode(str, "UTF-8");
	}
	
	public static String escapeQuote(String str) {
		return str.replaceAll("'", "''");
	}
	
	public static String getId() {
		counter++;
		
		return "" + counter;
	}

	public static boolean isNumberType(int typeId) {
		boolean res = false;
		
		int[] types = {2,3,4,5,7,8};
		
		for (int i : types) {
			if (typeId == i) {
				res = true;
				break;
			}
		}

		return res;
	}
	
	public static boolean isNumber(String inputData) {
		return NumberUtils.isNumber(inputData);
		//return inputData.matches("[-+]?\\d+(\\.\\d+)?");
	}
	
	public static List<String> getTables(String sql) {
		List<String> tables = new ArrayList<String>();
		List<String> tables2 = new ArrayList<String>();
//		Set<String> tbls = new HashSet<String>();

		// remove comments
		ArrayList<Range> ranges = extractComments(sql);
		// build string that stripped out comment and string literals
		StringBuffer sb2 = new StringBuffer();
		int start=0;
		for (Range r:ranges) {
			if (start > r.start) continue;
			sb2.append(sql.substring(start, r.start));
			start = r.end;
		}
		sb2.append( sql.substring(start));
		String s2 = sb2.toString();		
		String temp=s2.replaceAll("[\n\r\t]", " ").toUpperCase();

		String froms[] = temp.split(" FROM ");
		
		for (int i=1; i < froms.length; i++) {
			String str = froms[i];
			//System.out.println(i + ": " + str);
			if (str.startsWith("(")) continue;
			
			int idx = str.indexOf(" WHERE ");
			if (idx > 0) str = str.substring(0, idx);

			//System.out.println("*** " + i + ": " + str);
			
			String a[] = str.split(",");
			for (int j=0; j<a.length; j++) {
				String tname = a[j].trim();
				String ttt = tname;
				while (true) {
					int x = ttt.indexOf(" JOIN ");
					if (x > 0) {
						int y = ttt.indexOf(" ON ", x);
						if (y > 0) {
							String tmp = ttt.substring(x+6, y);
							//System.out.println("tmp=[" + tmp + "]");

							x = tmp.indexOf(" ");
							if (x > 0) tmp = tmp.substring(0, x).trim();
							//System.out.println(j + "=" +tname);
							
							if (tmp.endsWith(")")) tmp = tmp.substring(0, tmp.length()-1);
							if (tmp.startsWith("'")) continue;

							//tbls.add(tmp);
							if (!tables2.contains(tmp)) tables2.add(tmp);
							
							ttt = ttt.substring(y + 4);
						}
					} else
						break;
				}
				
				int x = tname.indexOf(" ");
				if (x > 0) tname = tname.substring(0, x).trim();
				//System.out.println(j + "=" +tname);
				
				if (tname.endsWith(")")) tname = tname.substring(0, tname.length()-1);
				if (tname.startsWith("'")) continue;

				//tbls.add(tname);
				if (!tables.contains(tname)) tables.add(tname);
			}			
		}
		
		tables.addAll(tables2);
		
		return tables;
	}
	
public static void main(String args[]) {
	String sql = "SELECT A.CLIENT_CODE, A.FUND_CODE, A.EDATE, A.NET_PERFORMANCE, \n" +
"B.GROSS_PERFORMANCE, B.NET_PERFORMANCE\n" +
"FROM CQ68418_NET A \n" +
"left join FUND_PERF_MTH_NET B on CLNT='0'||A.Client_code AND FUND=A.FUND_CODE AND B.edate=A.edate\n" +
"left join FUND_PERF_MTH_NET2 C on CLNT='0'||A.Client_code AND FUND=A.FUND_CODE AND B.edate=A.edate\n" +
"WHERE a.edate=to_date('20130531','yyyymmdd') ORDER BY CLIENT_CODE";
	sql = "SELECT * FROM ACCOUNT where accountid in (select accountid from member_plan_account where 1=2)";
	
	System.out.println("*== " + getTables(sql));
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

	public static String getMainTable(String sql) {
		String tname = "";
		
		// remove comments
		ArrayList<Range> ranges = extractComments(sql);
		// build string that stripped out comment and string literals
		StringBuffer sb2 = new StringBuffer();
		int start=0;
		for (Range r:ranges) {
			if (start > r.start) continue;
			sb2.append(sql.substring(start, r.start));
			start = r.end;
		}
		sb2.append( sql.substring(start));
		String s2 = sb2.toString();		
//System.out.println("s2=" + s2);		
		String temp=s2.replaceAll("[\n\r\t]", " ").toUpperCase();

		String froms[] = temp.split(" FROM ");
		
		for (int i=1; i < froms.length; i++) {
			String str = froms[i];
			//System.out.println(i + ": " + str);
			if (str.startsWith("(")) continue;
			
			int idx = str.indexOf(" WHERE ");
			if (idx > 0) str = str.substring(0, idx);

			//System.out.println("*** " + i + ": " + str);
			
			String a[] = str.split(",");
			for (int j=0; j<a.length; j++) {
				tname = a[j].trim();
				return tname;
			}			
		}
		
		return tname;
	}
	
	public static List<String> _getTables(String sql) {
		List<String> tables = new ArrayList<String>();

		String temp=sql.replaceAll("[\n\r\t]", " ");
		
		int idx = temp.toUpperCase().indexOf(" FROM ");
		if (idx > 0) {
			// process multiple tables
			String temp2 = temp.substring(idx + 6);
			int idx2 = temp2.toUpperCase().indexOf(" WHERE ");
			if (idx2 > 0) temp2 = temp2.substring(0, idx2);
			
		//	System.out.println("temp2=" +temp2);
			
			String a[] = temp2.split(",");
			for (int i=0; i<a.length; i++) {
				String tname = a[i].trim();
				int x = tname.indexOf(" ");
				if (x > 0) tname = tname.substring(0, x).trim();
			//	System.out.println(i + "=" +tname);
				
				if (!tname.startsWith("(")) {
					tables.add(tname);
				}
			}
		}
		
		return tables;
	}
	
	public static String getScriptionVersion() {
		return getBuildNo();
	}

	public static String getIpAddress(HttpServletRequest request) {
		String ipAddress = request.getRemoteAddr();
		if (request.getHeader("X-Forwarded-For") != null) ipAddress=request.getHeader("X-Forwarded-For");
		//if (ipAddress.equals("127.0.0.1")) ipAddress=request.getHeader("X-Forwarded-For");
		
		return ipAddress;
	}

	public static String trackingId() {
		return "UA-34000949-1";
	}

	public static String getURL(HttpServletRequest req) {

	    String scheme = req.getScheme();             // http
	    String serverName = req.getServerName();     // hostname.com
	    int serverPort = req.getServerPort();        // 80
	    String contextPath = req.getContextPath();   // /mywebapp
	    String servletPath = req.getServletPath();   // /servlet/MyServlet
	    String pathInfo = req.getPathInfo();         // /a/b;c=123
	    String queryString = req.getQueryString();          // d=789

	    // Reconstruct original requesting URL
	    StringBuffer url =  new StringBuffer();
	    url.append(scheme).append("://").append(serverName);

	    if ((serverPort != 80) && (serverPort != 443)) {
	        url.append(":").append(serverPort);
	    }

	    url.append(contextPath).append(servletPath);

	    if (pathInfo != null) {
	        url.append(pathInfo);
	    }
	    if (queryString != null) {
	        url.append("?").append(queryString);
	    }
	    return url.toString();

	}

	public static ArrayList<String> getInsertColumn(String sql) {
		ArrayList<String> res = new ArrayList<String>();

		int start = sql.indexOf("(");
		int end  = sql.indexOf(")");
		
		if (start < 0 || end < 0) return res;
		
		String ext = sql.substring(start +1, end);
		//System.out.println("[" + ext + "]");
		
		String[] arr = ext.split(",");
		
		for (String col:arr)
			res.add(col.toUpperCase().trim());
		return res;
	}
	
	public static ArrayList<String> getUpdateColumn(String sql) {
		ArrayList<String> res = new ArrayList<String>();

		sql = sql.toUpperCase();
		int start = sql.indexOf(" SET ");
		int end  = sql.indexOf(" WHERE ");
		
		if (start < 0) return res;
		if (end <0) end = sql.length();
		
		String ext = sql.substring(start +5, end);
		//System.out.println("[" + ext + "]");
		
		String[] arr = ext.split("=");
		
		int i = 0;
		for (String tmp:arr) {
			int s = tmp.lastIndexOf(",");
			if (s > 0) tmp = tmp.substring(s+1);
			tmp = tmp.trim();
			if (tmp.contains(".")) tmp = tmp.substring(tmp.lastIndexOf(".")+1);
			res.add(tmp);
			i++;
		}
		if (res.size()>0) res.remove(res.size()-1);
		return res;
	}

	public static ArrayList<String> getDeleteColumn(String sql) {
		ArrayList<String> res = new ArrayList<String>();

		sql = sql.toUpperCase();
		int start = sql.indexOf(" WHERE ");
		if (start <0) return res;
		String ext = sql.substring(start +7);
//System.out.println("[" + ext + "]");
		
		String[] arr = ext.split("AND");
		
		int i = 0;
		for (String tmp:arr) {
			//System.out.println("<" + tmp + ">");
			int s1 = tmp.indexOf(" ");
			int s2 = tmp.indexOf("=");
			int s3 = tmp.indexOf("<");
			int s4 = tmp.indexOf(">");
			int s=1000;
			if (s1 >0 && s1 < s) s = s1;
			if (s2 >0 && s2 < s) s = s2;
			if (s3 >0 && s3 < s) s = s3;
			if (s4 >0 && s4 < s) s = s4;
			
			if (s > 0 && s!= 1000) tmp = tmp.substring(0,s);
			tmp = tmp.trim();
			if (tmp.contains(".")) tmp = tmp.substring(tmp.lastIndexOf(".")+1);
			//System.out.println("$" + tmp + "$");
			res.add(tmp);
			i++;
		}
		//if (res.size()>0) res.remove(res.size()-1);
		return res;
	}

	public static boolean isInCpasNetwork(HttpServletRequest req) {
		String url = getURL(req);
		return true;
		//return (url != null && url.contains("cpas.com") );
	}

	public static String getBuildNo() {
		return "CPAS-1104";
	}

	public static String getVersionDate() {
		return "Jan 23, 2014";
	}

	public static void p(String str) {
		System.out.println(str);
	}
	
	public static String nvl(String val, String val2) {
		if (val==null)
			return val2;
		
		return val;
	}

	public static String nvl(String val) {
		return nvl(val, "");
	}
   
}
