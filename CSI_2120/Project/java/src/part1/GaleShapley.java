package part1;

// Project CSI2120/CSI2520
// Winter 2026
// Robert Laganiere, uottawa.ca

import java.io.*;
import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;

// this is the (incomplete) class that will generate the resident and program maps
public class GaleShapley {

	private HashMap<Integer,Resident> residents;
	private HashMap<String,Program> programs;

    // create two hash map for residents and programs
    public GaleShapley() {
        residents = new HashMap<>();
        programs = new HashMap<>();
    }
    //Residents getter
    public HashMap<Integer,Resident> getResidents() {
        return residents;
    }
    // Programs getter
    public HashMap<String,Program> getPrograms() {
        return programs;
    }

    public void loadResidents(String filename) throws IOException, NumberFormatException {
        readResidents(filename);
    }

    public void loadPrograms(String filename) throws IOException, NumberFormatException {
        readPrograms(filename);
    }

    // =========== CVS 读取 READERS START=========
	// Reads the residents csv file
	// It populates the residents HashMap
    private void readResidents(String residentsFilename) throws IOException,
													NumberFormatException {

        String line;
		residents= new HashMap<Integer,Resident>();
		BufferedReader br = new BufferedReader(new FileReader(residentsFilename));

		int residentID;
		String firstname;
		String lastname;
		String plist;
		String[] rol;

		// Read each line from the CSV file
		line = br.readLine(); // skipping first line
		while ((line = br.readLine()) != null && line.length() > 0) {

			int split;
			int i;

			// extracts the resident ID
			for (split=0; split < line.length(); split++) {
				if (line.charAt(split) == ',') {
					break;
				}
			}
			if (split > line.length()-2)
				throw new IOException("Error: Invalid line format: " + line);

			residentID= Integer.parseInt(line.substring(0,split));
			split++;

			// extracts the resident firstname
			for (i= split ; i < line.length(); i++) {
				if (line.charAt(i) == ',') {
					break;
				}
			}
			if (i > line.length()-2)
				throw new IOException("Error: Invalid line format: " + line);

			firstname= line.substring(split,i);
			split= i+1;

			// extracts the resident lastname
			for (i= split ; i < line.length(); i++) {
				if (line.charAt(i) == ',') {
					break;
				}
			}
			if (i > line.length()-2)
				throw new IOException("Error: Invalid line format: " + line);

			lastname= line.substring(split,i);
			split= i+1;

			Resident resident= new Resident(residentID,firstname,lastname);

			for (i= split ; i < line.length(); i++) {
				if (line.charAt(i) == '"') {
					break;
				}
			}

			// extracts the program list
			plist= line.substring(i+2,line.length()-2);
			String delimiter = ","; // Assuming values are separated by commas
			rol = plist.split(delimiter);

			resident.setROL(rol);

			residents.put(residentID,resident);
		}
        // Important: close the file
        br.close();
    }

	// Reads the programs csv file
	// It populates the programs HashMap
    private void readPrograms(String programsFilename) throws IOException,
													NumberFormatException {

        String line;
		programs= new HashMap<String,Program>();
		BufferedReader br = new BufferedReader(new FileReader(programsFilename));

		String programID;
		String name;
		int quota;
		String rlist;
		int[] rol;

		// Read each line from the CSV file
		line = br.readLine(); // skipping first line
		while ((line = br.readLine()) != null && line.length() > 0) {

			int split;
			int i;

			// extracts the program ID
			for (split=0; split < line.length(); split++) {
				if (line.charAt(split) == ',') {
					break;
				}
			}
			if (split > line.length()-2)
				throw new IOException("Error: Invalid line format: " + line);


			programID= line.substring(0,split);
			split++;

			// extracts the program name
			for (i= split ; i < line.length(); i++) {
				if (line.charAt(i) == ',') {
					break;
				}
			}
			if (i > line.length()-2)
				throw new IOException("Error: Invalid line format: " + line);

			name= line.substring(split,i);
			split= i+1;

			// extracts the program quota
			for (i= split ; i < line.length(); i++) {
				if (line.charAt(i) == ',') {
					break;
				}
			}
			if (i > line.length()-2)
				throw new IOException("Error: Invalid line format: " + line);

			quota= Integer.parseInt(line.substring(split,i));
			split= i+1;

			Program program= new Program(programID,name,quota);

			for (i= split ; i < line.length(); i++) {
				if (line.charAt(i) == '"') {
					break;
				}
			}

			// extracts the resident list
			rlist= line.substring(i+2,line.length()-2);
			String delimiter = ","; // Assuming values are separated by commas
			String[] rol_string = rlist.split(delimiter);
			rol= new int[rol_string.length];
			for (int j=0; j<rol_string.length; j++) {

				rol[j]= Integer.parseInt(rol_string[j]);
			}

			program.setROL(rol);

			programs.put(programID,program);
		}
        // Important: close the file
        br.close();
    }
    // ============ CVS 读取 READERS OVER ==========

    public void runMatching() {
        // Queue of available residents (unmatched + still have programs to propose to)
        ArrayDeque<Resident> queue = new ArrayDeque<>();

        // Initialize: all residents start unmatched
        for (Resident r : residents.values()) {
            if (r.hasMoreProposals()) {
                queue.add(r);
            }
        }

        // Iterative applicant-proposing Gale–Shapley
        while (!queue.isEmpty()) {

            Resident r = queue.removeFirst();

            // If already matched (can happen if added twice), skip
            if (r.isMatched()) {
                continue;
            }

            // Propose until accepted or resident exhausts their ROL
            while (r.hasMoreProposals() && !r.isMatched()) {

                String programID = r.nextProgramToPropose();

                // 如果居民列出一个未知的程序id，跳过
                // If resident listed an unknown programID, skip
                Program p = programs.get(programID);
                if (p == null) {
                    continue;
                }

                // 到此一游 Oo
                // Program decides accept/reject/evict based on its ROL and quota
                Program.AddResult result = p.addResident(r);

                if (result.isAccepted()) {
                    // If someone was evicted, they become available again
                    Resident evicted = result.getEvicted();
                    if (evicted != null && evicted.hasMoreProposals()) {
                        queue.addLast(evicted);
                    }
                    break; // r is matched now
                }
            }

            // If still unmatched but can still propose (rare), re-queue
            if (!r.isMatched() && r.hasMoreProposals()) {
                queue.addLast(r);
            }
        }
    }

    /**
     * Writes the required output file and prints the required summary lines.
     * Output columns:
     * lastname,firstname,residentID,programID,name
     *
     * Unmatched residents must use:
     * programID=XXX, name=NOT_MATCHED
     * damn...
     */
    public void writeResults(String outputFilename) throws IOException {

        ArrayList<Resident> allResidents = new ArrayList<>(residents.values());

        // Sorting is not required, but makes output easier to read
        allResidents.sort(new Comparator<Resident>() {
            @Override
            public int compare(Resident a, Resident b) {
                int c = a.getLastname().compareToIgnoreCase(b.getLastname());
                if (c != 0) return c;
                return a.getFirstname().compareToIgnoreCase(b.getFirstname());
            }
        });

        int unmatchedCount = 0;
        int availablePositions = 0;

        // Total remaining positions across all programs
        for (Program p : programs.values()) {
            availablePositions += (p.getQuota() - p.getMatchedResidents().size());
        }

        BufferedWriter bw = new BufferedWriter(new FileWriter(outputFilename));

        // Header
        bw.write("lastname,firstname,residentID,programID,name");
        bw.newLine();

        // Rows
        for (Resident r : allResidents) {
            if (!r.isMatched()) {
                unmatchedCount++;
                bw.write(r.getLastname() + "," + r.getFirstname() + "," + r.getResidentID() + ",XXX,NOT_MATCHED");
            } else {
                Program p = r.getMatchedProgram();
                bw.write(r.getLastname() + "," + r.getFirstname() + "," + r.getResidentID() + "," + p.getProgramID() + "," + p.getName());
            }
            bw.newLine();
        }

        // Required summary lines (also print to console)
        String line1 = "Number of unmatched residents: " + unmatchedCount;
        String line2 = "Number of positions available: " + availablePositions;

        System.out.println(line1);
        System.out.println(line2);

        // Also append to file (useful for submission)
        bw.write(line1);
        bw.newLine();
        bw.write(line2);
        bw.newLine();

        bw.close();
    }

}
