package chingoo.oracle;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Stack;
import java.util.StringTokenizer;

public class PackageTable {

	private static String delim = " \t(),;";
	private String name;
	private String type;
	private String returnType;
	private HashMap<String, String> hm = new HashMap<String, String>();
	private HashMap<String, HashSet<String>> hmIns = new HashMap<String, HashSet<String>>();  // table columns for Insert
	private HashMap<String, HashSet<String>> hmUpd = new HashMap<String, HashSet<String>>();  // table columns for Update
	private HashMap<String, HashSet<String>> hmDel = new HashMap<String, HashSet<String>>();  // table columns for Delete

	static int cntProc = 0;
	
	private ArrayList<ProcDetail> pd = new ArrayList<ProcDetail>(); 
	
	static String params = "";
	static String vars = "";

	static Stack<Block> blocks = new Stack<Block>();
	static ArrayList<Block> bls = new ArrayList<Block>();
	
	static int prgIdx = 0;	// internal process index

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
	
	public PackageTable(String packageName, String packageSource) throws IOException {

		String text = packageSource; //.toUpperCase();
		
		StringBuffer s = new StringBuffer();

		ArrayList<Range> ranges = extractComments(text);

		// build string that stripped out comment and string literals
		StringBuffer sb2 = new StringBuffer();
		int start=0;
/*		
		for (Range r:ranges) {
			if (start > r.start) continue;
			sb2.append(text.substring(start, r.start));
			start = r.end;
		}
		sb2.append( text.substring(start));
		String s2 = sb2.toString();
*/
		for (Range r:ranges) {
			if (start > r.start) continue;
			sb2.append(text.substring(start, r.start));
			String cmt = text.substring(r.start, r.end);
			
			int lastIndex = 0;
			int count =0;
			while (lastIndex != -1){

			       lastIndex = cmt.indexOf("\n", lastIndex+1);

			       if( lastIndex != -1){
			             count ++;
			             sb2.append("\n");
			      }
			}
			//System.out.println("1[" + cmt + "]" + count);
			start = r.end;
		}
		sb2.append( text.substring(start));
		String s2 = sb2.toString();
		
		//System.out.println("------------------------------------");
		//System.out.println(s2);

		String[] lines = s2.split("\r\n|\r|\n");
		this.analyze_new(lines);
		
	}

	private void analyze_new(String lines[]) {
		// analyze the plsql source code
		int ln = 0;
		int prcStart=0;
		boolean skipNextLoop = false;
		for (String s: lines) {
			ln++;
			
			StringTokenizer st = new StringTokenizer(s, delim, true);
			int tokenSeq =0;
			while (st.hasMoreTokens()) {
				String token = st.nextToken();
				if (token.equals(" ") || token.equals("\t")) continue;	// ignore white space
				
				tokenSeq++;
				//System.out.println(tokenSeq + " " + token);
				
				String tokenUp = token.toUpperCase();
				if (tokenUp.equals("PROCEDURE")) {
					this.type = "PROCEDURE";
					prgIdx = 1;
					prcStart = ln;
				} else if (tokenUp.equals("FUNCTION")) {
					this.type = "FUNCTION";
					prgIdx = 1;
					prcStart = ln;
				} else if (tokenUp.equals("TRIGGER")) {
					this.type = "TRIGGER";
					prgIdx = 1;
					prcStart = ln;
					break;
				} else if (prgIdx == 1) {
					this.name = token;
					cntProc++;
					prgIdx = 2;
					Block block = new Block(prcStart, "PROC/FUNC", token);
					blocks.push(block);	// begining of body
					//System.out.println("name=" + this.name);
				} else if (prgIdx >= 2 && prgIdx < 10 && token.equals(";") && blocks.size()>0) {   // ignore forward declaration
					prgIdx = 0;
					Util.p("forward declation " + this.name);
					blocks.pop();
				} else if (prgIdx == 2 && token.equals("(")) {
					prgIdx = 3;
				} else if (prgIdx == 3) {
					if (!token.equals(")")) {
						this.params += token +" ";
					} else {
						prgIdx ++;
					}
				} else if (prgIdx <=4 && tokenUp.equals("RETURN")) {
					prgIdx = 5;
				} else if (prgIdx == 5 && !(tokenUp.equals("AS") || tokenUp.equals("IS"))) {
					returnType = token;
					prgIdx = 6;
				} else if (prgIdx <= 6 && (tokenUp.equals("AS") || tokenUp.equals("IS"))) {
					prgIdx = 10;
				} else if (prgIdx == 10) {
					if (tokenUp.equals("BEGIN")) {
						prgIdx = 11;
						Block block = new Block(ln, tokenUp);
						blocks.push(block);	// begining of body
					}
					else {
						vars += token + " ";
					}
				} else if (prgIdx > 10) {
					
					if (tokenUp.equals("DECLARE") && vars.equals("")) {
						prgIdx = 10;
					}
					
					if (tokenSeq==1 && (tokenUp.equals("BEGIN")||tokenUp.equals("IF")||tokenUp.equals("FOR")||tokenUp.equals("LOOP")
							||tokenUp.equals("CASE")||tokenUp.equals("WHILE")  )) {
						
						if (tokenUp.equals("LOOP") && skipNextLoop) {
							skipNextLoop = false;
						} else {
							Block block = new Block(ln, tokenUp);
							blocks.push(block);	// begining of body
						}
						
						// For WHILE and FOR, skip until LOOP is found
						if ((tokenUp.equals("FOR")||tokenUp.equals("WHILE")) && s.indexOf("LOOP") < 0) skipNextLoop = true; 
						
					}
					
					if (tokenUp.equals("END")) {
						if (blocks.empty()) continue;

						Block block = blocks.pop();
						block.endLine = ln;
						
						bls.add(block);
						if (block.blockType.equals("BEGIN") && blocks.size() >0 ) {
							//System.out.println("pop3 " + block + " " + blocks.size() + " "  + this.name);
							if (!blocks.empty()) {
								Block block2 = blocks.pop();
								if (block2.blockType.equals("PROC/FUNC")) {
									ProcDetail item = new ProcDetail(block2.blockName, block2.startLine, block.endLine);
									if (blocks.size()==0 && !pd.contains(item))
										pd.add(item);

									if (blocks.size()==0) {
										StringBuffer sb = new StringBuffer();
									
										for (int i=block2.startLine; i<block.endLine;i++) {
											sb.append(lines[i] + "\n");
										}
										extractTables2(block2.blockName, sb.toString());
									}
								} else {
									blocks.push(block2);
								}
							}
							
						}
						
						if (blocks.size()==0 && this.name != null) {
							//System.out.println("params=" + params);
//							extractVariables(this.name.toUpperCase(), this.params, this.vars);
							prgIdx = 0;
							this.params = "";
							this.vars = "";
						}
					}
				}
			}
		}
		
	}

/*	
	private void analyze(String lines[]) {
		// analyze the plsql source code
		int ln = 0;
		int prcStart=0;
		for (String s: lines) {
			ln++;
			
			if (type != null && type.equals("TRIGGER") && prgIdx==1) {
				if (s.trim().toUpperCase().equals("BEGIN") || s.trim().toUpperCase().equals("DECLARE")) {
					prgIdx = 10;
					name ="TRIGGER";
				} else
					continue;
			}
			
			//System.out.println(ln + " " + s);
			StringTokenizer st = new StringTokenizer(s, delim, true);
			int tokenSeq =0;
			while (st.hasMoreTokens()) {
				String token = st.nextToken();
				if (token.equals(" ") || token.equals("\t")) continue;	// ignore white space
				
				tokenSeq++;
				//System.out.println(tokenSeq + " " + token);
				
				String tokenUp = token.toUpperCase();
				if (tokenUp.equals("PROCEDURE")) {
					this.type = "PROCEDURE";
					prgIdx = 1;
					prcStart = ln;
				} else if (tokenUp.equals("FUNCTION")) {
					this.type = "FUNCTION";
					prgIdx = 1;
					prcStart = ln;
				} else if (tokenUp.equals("TRIGGER")) {
					this.type = "TRIGGER";
					prgIdx = 1;
					prcStart = ln;
					break;
				} else if (prgIdx == 1) {
					this.name = token;
					cntProc++;
					prgIdx = 2;
					//System.out.println("name=" + this.name);
				} else if (prgIdx == 2 && token.equals("(")) {
					prgIdx = 3;
				} else if (prgIdx == 3) {
					if (!token.equals(")")) {
						this.params += token +" ";
					} else {
						prgIdx ++;
					}
				} else if (prgIdx <=4 && tokenUp.equals("RETURN")) {
					prgIdx = 5;
				} else if (prgIdx == 5 && !(tokenUp.equals("AS") || tokenUp.equals("IS"))) {
					returnType = token;
					prgIdx = 6;
				} else if (prgIdx <= 6 && (tokenUp.equals("AS") || tokenUp.equals("IS"))) {
					prgIdx = 10;
				} else if (prgIdx == 10) {
					if (tokenUp.equals("BEGIN")) {
						prgIdx = 11;
						Block block = new Block( prcStart, tokenUp);
						blocks.push(block);	// begining of body
					}
					else {
						vars += token + " ";
					}
				} else if (prgIdx > 10) {
					
					if (tokenUp.equals("DECLARE") && vars.equals("")) {
						prgIdx = 10;
					}
					
					if (tokenSeq==1 && (tokenUp.equals("BEGIN")||tokenUp.equals("IF")||tokenUp.equals("FOR")||tokenUp.equals("LOOP")
							||tokenUp.equals("CASE")||tokenUp.equals("WHILE")  )) {
						Block block = new Block(ln, tokenUp);
						blocks.push(block);	// begining of body
					}

					if (tokenUp.equals("END")) {
						if (blocks.empty()) continue;

						Block block = blocks.pop();
						block.endLine = ln;
						
						bls.add(block);
						if (block.blockType.equals("BEGIN") && blocks.size() ==0 ) {
							//System.out.println("pop3 " + block + " " + blocks.size() + " "  + this.name);
							ProcDetail item = new ProcDetail(this.name, block.startLine, block.endLine);
							if (!pd.contains(item))
								pd.add(item);
							
							StringBuffer sb = new StringBuffer();
							for (int i=block.startLine; i<block.endLine;i++) {
								sb.append(lines[i] + "\n");
//								System.out.println("  " + lines[i] +"\n");
							}
							extractTables2(sb.toString());
							//System.out.println("*** " + sb.toString());
						}
						
						if (blocks.size()==0 && this.name != null) {
							//System.out.println("params=" + params);
//							extractVariables(this.name.toUpperCase(), this.params, this.vars);
							prgIdx = 0;
							this.params = "";
							this.vars = "";
						}
					}
				}
			}
		}
		
	}
*/	
/*
	void extractTables(String text) {
//		System.out.println(text);
		
		StringTokenizer st = new StringTokenizer(text, ";");
		while (st.hasMoreTokens()) {
			String token =st.nextToken();

			StringTokenizer st2 = new StringTokenizer(token, " \t\n,()");
			
			String skipUntil = null;
			
			while (st2.hasMoreTokens()) {
				String name = st2.nextToken();
				//System.out.println(" * " + name);
				
				if (skipUntil != null && !name.equals(skipUntil)) { 
					continue;
				} else if (skipUntil != null && name.equals(skipUntil))  {
					skipUntil = null;
					continue;
				}
				
				if (name.equals("IF")) {
					skipUntil = "THEN";
					continue;
				} else if (name.equals("DECLARE")) {
					skipUntil = "BEGIN";
					continue;
				} else if (name.equals("FOR")) {
					skipUntil = "LOOP";
					continue;
				} else if (name.equals("FORALL")) {
					skipUntil = "EXCEPTIONS";
					continue;
				} else if (name.equals("ELSE") || name.equals("BEGIN")) {
					if (st2.hasMoreTokens()) 
						name = st2.nextToken();
				}
				
				if (name.equals("INSERT")) {
					name = st2.nextToken();
					name = st2.nextToken();
					//System.out.println("   " + this.name + " ****** INSERT " + name);
					String key = this.name+","+name;
					String curr = hm.get(key);
					if (curr ==null)
						hm.put(key, "I");
					else if (!key.contains("I")) {
						hm.put(key, curr+"I");
					}
				}
				if (name.equals("UPDATE")) {
					name = st2.nextToken();
					//System.out.println("   " + this.name + " ****** UPDATE " + name);
					String key = this.name+","+name;
					String curr = hm.get(key);
					if (curr ==null)
						hm.put(key, "U");
					else if (!key.contains("U")) {
						hm.put(key, curr+"U");
					}
				}
				if (name.equals("DELETE")) {
					name = st2.nextToken();
					if (name.equals("FROM"))
						name = st2.nextToken();
					//System.out.println("   " + this.name + " ****** DELETE " + name);
					String key = this.name+","+name;
					String curr = hm.get(key);
					if (curr ==null)
						hm.put(key, "D");
					else  if (!key.contains("D")) {
						hm.put(key, curr+"D");
					}
				}

				break;
			}
		}

	}
*/
	void extractTables2(String procName, String text) {
		//System.out.println("**** [[[[" +text +"]]]");
		text = text.replaceAll("\n", " ");
		text = text.replaceAll("\t", " ");
		//System.out.println("[[[[" +text +"]]]");
		
		// search for INSERT
		int start =0;
		while (true) {

			String searchStr = "INSERT";
			start = text.indexOf(searchStr, start);
			if (start <0) break;
			String prevChar = text.substring(start-1,start);
			String nextChar = text.substring(start+searchStr.length(),start+searchStr.length()+1);
//			Util.p("prevChar [["+ prevChar + "]]");
//			Util.p("nextChar [["+ nextChar + "]]");
			if (!" \n\t()".contains(prevChar) || !" \n\t()".contains(nextChar)) {
				start += searchStr.length();
				continue;
			}
			int end = text.indexOf(";", start);
			if (end <0) break;

			String tmp = text.substring(start + searchStr.length(), end);			
			ArrayList<String> cols = Util.getInsertColumn(tmp);
			//System.out.println("[" + tmp + "]");
			
			StringTokenizer st = new StringTokenizer(tmp, " (");
			int cnt=0;
			while (st.hasMoreTokens()) {
				cnt++;
				String token = st.nextToken().toUpperCase();
				if (cnt==2) {
					//System.out.println(this.name + " INSERT *** " + token);
					String key = procName.toUpperCase()+","+token;
					String curr = hm.get(key);
					if (curr ==null)
						hm.put(key, "I");
					else if (!curr.contains("I")) {
						hm.remove(key);
						hm.put(key, curr+"I");
//System.out.println("key0=" + curr);
					}
					
					HashSet<String> hs = hmIns.get(key);
					if (hs == null) {
						hs = new HashSet<String> ();
						hmIns.put(key, hs);
					}
					for (String col:cols) {
						hs.add(col);
					}
				}
			}
			
			start = end + 1;
		}
		
		// search for DELETE
		start =0;
		while (true) {
			String searchStr = "DELETE";
			start = text.indexOf(searchStr, start);
			if (start <0) break;
			String prevChar = text.substring(start-1,start);
			String nextChar = text.substring(start+searchStr.length(),start+searchStr.length()+1);
//			Util.p("prevChar [["+ prevChar + "]]");
//			Util.p("nextChar [["+ nextChar + "]]");
			if (!" \n\t()".contains(prevChar) || !" \n\t()".contains(nextChar)) {
				start += searchStr.length();
				continue;
			}
			int end = text.indexOf(";", start);
			if (end <0) break;

			String tmp = text.substring(start + searchStr.length(), end);
			ArrayList<String> cols = Util.getDeleteColumn(tmp);
//System.out.println("tmp="+tmp);			
			StringTokenizer st = new StringTokenizer(tmp, " (");
			int cnt=0;
			while (st.hasMoreTokens()) {
				cnt++;
				String token = st.nextToken().toUpperCase();
				if (token.equals("FROM")) cnt--;
				if (cnt==1) {
					String key = procName.toUpperCase()+","+token;
//System.out.println("key=" + key);
					String curr = hm.get(key);
//System.out.println("curr=" + key);
					if (curr ==null) {
						hm.put(key, "D");
//System.out.println("key1=" + "D");
					} else if (!curr.contains("D")) {
						hm.remove(key);
						hm.put(key, curr+"D");
//System.out.println("key1=" + curr);
					}
					
					HashSet<String> hs = hmDel.get(key);
					if (hs == null) {
						hs = new HashSet<String> ();
						hmDel.put(key, hs);
					}
					for (String col:cols) {
						hs.add(col);
					}
				}
			}
			
			start = end + 1;
		}
		
		// search for UPDATE
		start =0;
		while (true) {
			String searchStr = "UPDATE";
			start = text.indexOf(searchStr, start);
			if (start <0) break;
			String prevChar = text.substring(start-1,start);
			String nextChar = text.substring(start+searchStr.length(),start+searchStr.length()+1);
//			Util.p("prevChar [["+ prevChar + "]]");
//			Util.p("nextChar [["+ nextChar + "]]");
			if (!" \n\t()".contains(prevChar) || !" \n\t()".contains(nextChar)) {
				start += searchStr.length();
				continue;
			}
			int end = text.indexOf(";", start);
			if (end <0) break;

			String tmp = text.substring(start + searchStr.length(), end);
			ArrayList<String> cols = Util.getUpdateColumn(tmp);
			
			StringTokenizer st = new StringTokenizer(tmp, " (");
			int cnt=0;
			while (st.hasMoreTokens()) {
				cnt++;
				String token = st.nextToken().toUpperCase();
				if (token.equals("FROM")) cnt--;
				if (cnt==1) {
					String key = procName.toUpperCase()+","+token;
					String curr = hm.get(key);
					if (curr ==null)
						hm.put(key, "U");
					else if (!curr.contains("U")) {
						hm.remove(key);
						hm.put(key, curr+"U");
					}
					
					HashSet<String> hs = hmUpd.get(key);
					if (hs == null) {
						hs = new HashSet<String> ();
						hmUpd.put(key, hs);
					}
					for (String col:cols) {
						hs.add(col);
					}
				}
			}
			
			start = end + 1;
		}

		// search for SELECT
		start =0;
		while (true) {
			String searchStr = "SELECT";
			start = text.indexOf(searchStr, start);
			if (start <0) break;
			String prevChar = text.substring(start-1,start);
			String nextChar = text.substring(start+searchStr.length(),start+searchStr.length()+1);
//			Util.p("prevChar [["+ prevChar + "]]");
//			Util.p("nextChar [["+ nextChar + "]]");
			if (!" \n\t()".contains(prevChar) || !" \n\t()".contains(nextChar)) {
				start += searchStr.length();
				continue;
			}
			int end = text.indexOf(";", start);
			if (end <0) break;

			String tmp = text.substring(start + searchStr.length(), end);
			List<String> tables = Util.getTables(tmp);
			
			for (String tbl:tables) {
				String key = procName.toUpperCase()+","+tbl.toUpperCase();
				String curr = hm.get(key);
				if (curr ==null)
					hm.put(key, "S");
				else if (!curr.contains("S")) {
					hm.put(key, curr+"S");
				}
			}
			start = end + 1;
		}
	}
	
	
	void skipUntil(StringTokenizer st2, String matchStr) {
		while (st2.hasMoreTokens()) {
			String name = st2.nextToken();
			if (name.equals(matchStr)) break;
		}
		
		return;
	}
	
	public HashMap<String, String> getHM() {
		return this.hm;
	}
	
	public HashMap<String, HashSet<String>> getHMIns() {
		return this.hmIns;
	}
	
	public HashMap<String, HashSet<String>> getHMUpd() {
		return this.hmUpd;
	}
	
	public HashMap<String, HashSet<String>> getHMDel() {
		return this.hmDel;
	}
	
	public ArrayList<ProcDetail> getPD() {
		return this.pd;
	}
}
