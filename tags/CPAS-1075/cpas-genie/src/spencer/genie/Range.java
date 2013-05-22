package spencer.genie;

public class Range {
	public int start;
	public int end;
	public char type;
	
	public Range(int s, int e, char t) {
		start = s;
		end = e;
		type = t;
	}
	
	public String toString() {
		return start + "," + end + "," + type;
	}
	
}