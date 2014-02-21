package spencer.genie;

import java.io.BufferedOutputStream;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.ObjectOutput;
import java.io.ObjectOutputStream;
import java.io.OutputStream;
import java.sql.SQLException;
import java.util.Date;
import java.util.Hashtable;

import com.esotericsoftware.kryo.Kryo;
import com.esotericsoftware.kryo.io.Input;
import com.esotericsoftware.kryo.io.Output;

public class CacheManager {

	private Hashtable<String,CacheSchema> csTable = new Hashtable<String,CacheSchema>();
	
	private static CacheManager instance = null;
	private CacheManager() {
		
	}
	
	public static CacheManager getInstance() {
		if (instance==null) instance = new CacheManager();
		
		return instance;
	}
	
	public CacheSchema getCacheSchema(Connect cn, String databaseUrl, String schemaName, String targetSchema) throws SQLException {
		String key = databaseUrl.toLowerCase() + (targetSchema==null?"":"-"+targetSchema.toLowerCase());
		CacheSchema cs = csTable.get(key);
		
		if (cs==null) {
			
			// try read from file
			cs = readSchemaToFile(key);
			if (cs!=null) {
				cs.buildHashSets();
				csTable.put(key, cs);
				return cs;
			}

			// load from database
			cs = new CacheSchema(cn, databaseUrl, schemaName, targetSchema);
			csTable.put(key, cs);
			saveSchemaToFile(cs);
		}
		
		// expire if it's too old
		if (cs !=null) {
			Date current = new Date();
			Util.p("cs.loadDate=" + cs.loadDate);
			Util.p("current Date=" + current);
			if ((current.getTime() - cs.loadDate.getTime()) > (1000 * 60 * 60 * 24)) {  // 24 hours
				Util.p("expired cs");
				cs.reload(cn);
				saveSchemaToFile(cs);
				csTable.put(key, cs);
			}
		}

		return cs;
	}
	
	public Hashtable<String,CacheSchema> getCsTable() {
		return csTable;
	}
	
	private void saveSchemaToFile(CacheSchema cs) {
		Kryo kryo = new Kryo();
		kryo.register(CacheSchema.class);
		
   		// Serialize
   		try{
   			String serFilename = cs.dbUrl;
   			serFilename = serFilename.replaceAll("[^a-zA-Z0-9\\s]", "-") +  ".schema";
   			
   			Output output = new Output(new FileOutputStream("/home/cpas-genie/cache/" + serFilename));
   		    kryo.writeObject(output, cs);
   		    output.close();
   		    
   		    Util.p("saved " + serFilename);
   	    }  
   	    catch(IOException ex){
   	    	ex.printStackTrace();
   	    }
	}

	private CacheSchema readSchemaToFile(String dbUrl) {
		CacheSchema cs = null;
		
		Kryo kryo = new Kryo();
		kryo.register(CacheSchema.class);
		
   		// Serialize
   		try{
   			String serFilename = dbUrl;
   			serFilename = serFilename.replaceAll("[^a-zA-Z0-9\\s]", "-") +  ".schema";
   		    Util.p("reading " + serFilename);
   		    
   			Input input = new Input(new FileInputStream("/home/cpas-genie/cache/" + serFilename));
   			cs = kryo.readObject(input, CacheSchema.class);
   		    input.close();
   		    
   	    }  
   	    catch(IOException ex){
   	    	//ex.printStackTrace();
   	    	cs = null;
   	    }
   		
   		return cs;
	}
	
	public void reload(Connect cn, CacheSchema cs) throws SQLException {
		cs.reload(cn);
		saveSchemaToFile(cs);
	}

}
