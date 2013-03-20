package chingoo.oracle;

import java.util.ArrayList;

public class ChingooManager {

	private static ChingooManager instance = null;
	ArrayList<Connect> sessions = new ArrayList<Connect>();
	
	private ChingooManager() {
		
	}
	
	public static ChingooManager getInstance() {
		if (instance==null) {
			instance = new ChingooManager();
		}
		return instance;
	}
	
	public void addSession(Connect cn) {
		sessions.add(cn);
	}
	
	public void removeSession(Connect cn) {
		sessions.remove(cn);
	}
	
	public ArrayList<Connect> getSessions() {
		return sessions;
	}
}
