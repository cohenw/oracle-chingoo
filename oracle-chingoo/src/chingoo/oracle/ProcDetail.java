package chingoo.oracle;

public class ProcDetail {

	String procedureName;
	int startLine;
	int endLine;
	String procedureLabel;

	public ProcDetail(String name, int start, int end) {
		this.procedureName = name.toUpperCase();
		this.startLine = start;
		this.endLine = end;
		this.procedureLabel = name;
	}

	public String getProcedureName() {
		return procedureName;
	}

	public int getStartLine() {
		return startLine;
	}

	public int getEndLine() {
		return endLine;
	}

	public String getProcedureLabel() {
		return procedureLabel;
	}
	
	public String toString() {
		return this.procedureName + ":" + this.startLine + "-" + this.endLine + ":" + this.procedureLabel;
	}
}
