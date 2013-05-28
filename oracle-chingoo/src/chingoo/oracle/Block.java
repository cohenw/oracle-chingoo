package chingoo.oracle;

public class Block {

	int startLine;
	int endLine;
	String blockType;
	String blockName;
	
	public Block(int startLine, String blockType, String blockName) {
		this.startLine = startLine;
		this.blockType = blockType;
		this.blockName = blockName;
	}
	
	public Block(int startLine, String blockType) {
		this(startLine, blockType, null);
	}
	
	public String toString() {
		return blockType + " "+ startLine + "-" + endLine + " " + blockName;
	}
}
