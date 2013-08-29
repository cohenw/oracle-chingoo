package spencer.genie;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.Stack;
import java.util.StringTokenizer;

public class PlsqlAnalyzer {

	private String delim = " \t(),;";
	private String name;
	private String type;
	private String returnType;
	private HashSet<String> hs = new HashSet<String>();
	int cntProc = 0;
	
	String params = "";
	String vars = "";

	Stack<Block> blocks = new Stack<Block>();
	ArrayList<Block> bls = new ArrayList<Block>();
	
	public int prgIdx = 0;	// internal process index

	public PlsqlAnalyzer(String str) {
		String[] lines = str.split("\r\n|\r|\n");
		analyze(lines);
	}
	
	private void analyze(String lines[]) {
		// analyze the plsql source code
		int ln = 0;
		boolean skipNextLoop = false;
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
				} else if (tokenUp.equals("FUNCTION")) {
					this.type = "FUNCTION";
					prgIdx = 1;
				} else if (tokenUp.equals("TRIGGER")) {
					this.type = "TRIGGER";
					prgIdx = 1;
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
					
					if (tokenSeq==1 && (tokenUp.equals("BEGIN")||tokenUp.equals("IF")||tokenUp.equals("FOR")||tokenUp.equals("CASE")||tokenUp.equals("WHILE")||tokenUp.equals("LOOP"))) {
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
						//System.out.println("pop " + block + " " + blocks.size() + " "  + this.name);
						
						if (blocks.size()==0 && this.name != null) {
							//System.out.println("params=" + params);
//							extractVariables(this.name.toUpperCase(), this.params, this.vars);
							//System.out.println("vars=" + this.vars);
							//System.out.println("params=" + this.params);
							extractVariables("P" + cntProc, this.params, this.vars);
							prgIdx = 0;
							this.params = "";
							this.vars = "";
						}
					}
				}
			}
		}
		
		//System.out.println("vars=" + this.vars + " " + blocks.size());
		if (blocks.size() >0) {
			extractVariables("P" + cntProc, this.params, this.vars);	
		}
		//System.out.println("hs=" + hs);
	}

	private void extractVariables(String procName, String params, String variables) {

		// extract variable names - param, var, cursor
		StringTokenizer st = new StringTokenizer(this.params, ",");
		while (st.hasMoreTokens()) {
			String token =st.nextToken();
			StringTokenizer st2 = new StringTokenizer(token, " \t\n");
			if (st2.hasMoreTokens()) {
				String name = st2.nextToken();
				hs.add(procName + "-" + name.toUpperCase());
			}
		}

		st = new StringTokenizer(this.vars, ";");
		while (st.hasMoreTokens()) {
			String token =st.nextToken();
			StringTokenizer st2 = new StringTokenizer(token, " \t\n");
			if (st2.hasMoreTokens()) {
				String name = st2.nextToken();
				if (name.equalsIgnoreCase("CURSOR")) {
					if (st2.hasMoreTokens()) {
						name = st2.nextToken();
					}
				}
				hs.add(procName + "-" + name.toUpperCase());
			}
		}
		
		// extra process for cursorvariable
		st = new StringTokenizer(this.vars, ";");
		while (st.hasMoreTokens()) {
			String token =st.nextToken();
			int idx = token.indexOf("CURSOR ");
			if (idx >=0) {
				//System.out.println("c=" + token);
				int start = token.indexOf("(", idx+ 6);
				if (start >= 0) {
					int end = token.indexOf(")", start);
					if (end >= 0) {
						String tmp = token.substring(start+1, end).trim();
						//System.out.println("cs=[" + tmp + "]");
					
						String[] pars = tmp.split(",");
						for (String par:pars) {
							String val = par.trim();
							int j = val.indexOf(" ");
							if (j>=0) val = val.substring(0, j);
							//System.out.println("val=[" + val +"]");
							hs.add(procName + "-" + val.trim().toUpperCase());
						}
					}
				}
			}
		}
		
		//System.out.println("hs"+hs);
	}
	
	public String getName() {
		return name;
	}

	public String getType() {
		return type;
	}

	public String getReturnType() {
		return returnType;
	}
	
	public HashSet<String> getVariables() {
		return this.hs;
	}
}
