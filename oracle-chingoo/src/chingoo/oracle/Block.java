package chingoo.oracle;

public class Block {

	int startLine;
	int endLine;
	String blockType;
	
	public Block(int startLine, String blockType) {
		this.startLine = startLine;
		this.blockType = blockType;
	}
	
	public String toString() {
		return blockType + " " + startLine + "-" + endLine;
	}
}
