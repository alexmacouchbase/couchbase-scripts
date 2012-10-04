import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.net.URI;
import java.util.LinkedList;
import java.util.List;
import java.util.concurrent.TimeUnit;
import com.couchbase.client.CouchbaseClient;

public class vbucket_populate {
	/*
	 * This class is used to ensure that each vbucket in Couchbase has at least 2 keys.
	 * 
	 * Dependencies:
	 * - This class must be built against the Couchbase Java client availalbe here: http://www.couchbase.com/develop/java/current
	 * - vbucket-populate-keys - this file contains 2048 keys that this class will insert into a specific bucket into couchbase.
	 * 	 the keys are setup so that they will hash consistently to two keys for each of the 1024 vbuckets in a couchbase bucket.
	 * 
	 * Usage:
	 * java -jar vbucket_populate.jar <IP of node in cluster> <full path to key file> <bucket name> <bucket password>
	 * - IP of node in cluster: Can be any node in couchbase
	 * - full path to key file: full path to the vbucket-populate-keys file
	 * - bucket name: Name of the bucket
	 * - bucket password: if password is not used simply add in ""
	 * 
	 */
	
	public static void main(String[] args) {
			
			if (args.length != 4) {
				System.out.println("Usage: java -jar vbucket_populate.jar <IP of node in cluster> <full path to key file> <bucket name> <bucket password>");
				System.exit(1);
				
			}
			String serverIp = args[0];
			String fileLocation = args[1];
			String bucketName = args[2];
			String bucketPass = args[3];
		
		// Connection details for Couchbase
		List<URI> uris = new LinkedList<URI>();
		uris.add(URI.create("http://" + serverIp + ":8091/pools"));

	    CouchbaseClient client = null;
	    try {
	    	client = new CouchbaseClient(uris, bucketName, bucketPass);
	    }   
	    catch (Exception e) {
	      System.err.println("except: connect: " + e.getMessage());
	      System.exit(-1);
	    }   
		try {
			FileReader input = new FileReader(fileLocation);
			BufferedReader bufRead = new BufferedReader(input);
			String line = bufRead.readLine();
			int count = 1;
			while (line != null) {
				System.out.println("Adding key #" + count + ": " + line);
					client.set(line, 129600, "1");
					line = bufRead.readLine();
					count++;					
			}
			bufRead.close();
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
	    client.shutdown(3, TimeUnit.SECONDS);
	}
}

