package part1;

/**
 * Student Name: Haojian Wang
 * Student Number: 300411829
 * CSI 2120 - Project Part 1
 */

import java.io.IOException;

public class StableMatching {
    public static void main(String[] args) {
        if ( args.length < 2 ) {
            System.out.println("Usage: java part1.StableMatching <residents.csv> <programs.csv> [output.txt]");
            return;
        }

        String residentsFile = args[0];
        String programsFile = args[1];

        String outputFile = ( args.length >= 3 ) ? args[2] :"output.txt";

        try {
            GaleShapley gs = new GaleShapley();
            gs.loadResidents(residentsFile);
            gs.loadPrograms(programsFile);

            // Run iterative Gale–Shapley algorithm
            gs.runMatching();

            // Write required output file + print required summary lines
            gs.writeResults(outputFile);

        } catch (IOException e) {
            System.err.println("I/O Error: " + e.getMessage());
        } catch (NumberFormatException e) {
            System.err.println("Number Format Error: " + e.getMessage());
        } catch (Exception e) {
            System.err.println("Unexpected Error: " + e.getMessage());
        }
    }
}
