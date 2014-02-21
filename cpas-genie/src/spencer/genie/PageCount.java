package spencer.genie;

public class PageCount {
	String page;
	int count=0;
	
	public String getPage() {
		return page;
	}
	public void setPage(String page) {
		this.page = page;
	}
	public int getCount() {
		return count;
	}
	public void addCount() {
		count++;
	}
	public void setCount(int count) {
		this.count = count;
	}
}