package chingoo.oracle;

import java.util.ArrayList;

public class PTree {

	String name;
	ArrayList<String> path = new ArrayList<String>();

	public PTree(String name, ArrayList<String> path) {
		this.name = name;
		this.path = path;
	}
	
	public String getName() {
		return name;
	}

	public String getPackage() {
		int idx = name.indexOf(".");
		String pkg = name.substring(0, idx);
		return pkg;
	}
	
	public String getProcedure() {
		int idx = name.indexOf(".");
		String prc = name.substring(idx+1);
		return prc;
	}
	
	public ArrayList<String> getPath() {
		return path;
	}
}
