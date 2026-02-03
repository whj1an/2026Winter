package part1;

/*
 * Student Name: Haojian Wang
 * Student Number: 300411829
 */

import java.util.Arrays;

public class Resident {

    // ========== Profs' ==========
    private int residentID;
    private String firstname;
    private String lastname;

    // Resident（program IDs），例如 ["NRS","HEP","MMI"] ???
    private String[] rol;

    // if 匹配到的 Program；else 未匹配则为 null
    private Program matchedProgram;

    // resident 在 matchedProgram 的 ROL 中的排名（数值越小越好），未匹配可用 -1
    private int matchedRank;

    // ========== Assistance ==========
    // 记录这个 resident 下一次要向 rol 的第几个 program 提案
    // mark this resident as for next which program will be chosen for rol
    private int nextProposalIndex;

    public Resident(int id, String fname, String lname) {
        this.residentID = id;
        this.firstname = fname;
        this.lastname = lname;

        // 初始状态：未匹配 Initial States
        this.matchedProgram = null;
        this.matchedRank = -1;

        // 初始从 rol[0] 开始提案 Start rol[0]
        this.nextProposalIndex = 0;
    }

    // 设置 ROL（从 CSV 读出来后调用）ROL Setter, used after reading CSV
    public void setROL(String[] rol) {
        this.rol = rol;
    }

    // ================== getters / setters ==================

    public int getResidentID() {
        return residentID;
    }

    public String getFirstname() {
        return firstname;
    }

    public String getLastname() {
        return lastname;
    }

    public String[] getRol() {
        return rol;
    }

    public Program getMatchedProgram() {
        return matchedProgram;
    }

    public int getMatchedRank() {
        return matchedRank;
    }

    public void setMatchedProgram(Program p) {
        this.matchedProgram = p;
    }

    public void setMatchedRank(int rank) {
        this.matchedRank = rank;
    }


    // ========== 迭代 Gale–Shapley ==========
    // Additional
    // if programs, resident continues
    public boolean hasMoreProposals() {
        return rol != null && nextProposalIndex < rol.length;
    }

    // 取出下一所要申请的 programID，并把指针往后移动
    // if no 可申请的，return null
    public String nextProgramToPropose() {
        if (!hasMoreProposals()) {
            return null;
        }
        String programID = rol[nextProposalIndex];
        nextProposalIndex++;
        return programID;
    }

    // 当 resident 被 program 踢出时：取消匹配（回到 available 状态）
    public void unmatch() {
        this.matchedProgram = null;
        this.matchedRank = -1;
    }

    // 判断是否已经匹配 case for whether has been chosen
    public boolean isMatched() {
        return matchedProgram != null;
    }

    // string representation
    @Override
    public String toString() {
        return "[" + residentID + "]: " + firstname + " " + lastname
                + " ROL=" + (rol == null ? "null" : Arrays.toString(rol));
    }
}