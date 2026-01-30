package part1;

/**
 * @author Haojian Wang 300411829
 */

import java.util.ArrayList;
import java.util.List;

public class Resident {
    private int id;
    private String firstName;
    private String lastName;
    private List<String> rol;
    private Program matchedProgram;
    private int matchedRank;

    public Resident(int id, String firstName, String lastName, List<String> rol) {
        this.id = id;
        this.firstName = firstName;
        this.lastName = lastName;
        this.rol = rol;
        this.matchedProgram = null; //初始状态 initial state
        this.matchedRank = -1;
    }

    //getters
    public int getId() {
        return id;
    }

    public String getFirstName() {
        return firstName;
    }

    public String getLastName() {
        return lastName;
    }

    public List<String> getRol() {
        return rol;
    }

    public Program getMatchedProgram() {
        return matchedProgram;
    }

    //setters
    public void setMatchedRank(int matchedRank) {
        this.matchedRank = matchedRank;
    }

    public void setMatchedProgram(Program matchedProgram) {
        this.matchedProgram = matchedProgram;
    }

}
