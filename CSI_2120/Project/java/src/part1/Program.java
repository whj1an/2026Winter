package part1;

// Project CSI2120/CSI2520
// Winter 2026
// Robert Laganiere, uottawa.ca


/**
 * Student Name: Haojian Wang
 * Student Number: 300411829
 */

import java.util.ArrayList;
import java.util.HashMap;

// this is the (incomplete) Program class
public class Program {
	
	private String programID;
	private String name;
	private int quota;
	private int[] rol;
	
    private ArrayList<Resident> matchedResidents;

    private HashMap<Integer, Integer> rankMap;


    public Program(String id, String n, int q) {
	
		this.programID= id;
		this.name= n;
		this.quota= q;

        this.matchedResidents= new ArrayList<>();
        this.rankMap= new HashMap<>();
	}

    // the rol in order of preference, build rankMap
	public void setROL(int[] rol) {
		this.rol= rol;

        // residentID -> rank
        rankMap.clear();
        for (int i = 0; i < rol.length; i++) {
            rankMap.put(rol[i], i);

        }
	}

    // =========== getters ===========

    public int getQuota() {
        return quota;
    }

    public String getName() {
        return name;
    }

    public String getProgramID() {
        return programID;
    }

    public ArrayList<Resident> getMatchedResidents() {
        return matchedResidents;
    }

    // ------------------------------------------------

    // member(residentID): resident 是否在该 program 的 ROL 中
    public boolean member(int residentID) {
        return rankMap.containsKey(residentID);
    }

    // rank(residentID): 返回 resident 在 program ROL 的排名；不在则 -1
    public int rank(int residentID) {
        Integer r = rankMap.get(residentID);
        return (r == null) ? -1 : r;
    }

    // leastPreferred(): 返回当前 matchedResidents 中 program 最不喜欢的那位
    // “最不喜欢”= rank 最大（数字越大代表越靠后）
    public Resident leastPreferred() {
        if (matchedResidents.isEmpty()) {
            return null;
        }

        Resident worst = matchedResidents.get(0);
        for (Resident r : matchedResidents) {
            if (r.getMatchedRank() > worst.getMatchedRank()) {
                worst = r;
            }
        }
        return worst;
    }


    // ---------------------------------------
    /*
     * addResident(resident):
     *  - 若 program 不认识这个 resident（不在 program ROL），直接拒绝（return false）
     *  - 若未满 quota：接收
     *  - 若已满 quota：若更喜欢新 resident，则替换 leastPreferred
     *
     * 为了方便 GaleShapley 驱动循环，这里返回 “被踢出的 resident”（若没有踢人则返回 null）。
     * 如果新 resident 被拒绝，也返回 null，但会通过 boolean 告知是否接收。
     */
    public AddResult addResident(Resident resident) {

        int rid = resident.getResidentID();

        // 1) if 不在 program ROL 里，return
        if (!member(rid)) {
            return new AddResult(false, null);
        }

        // 计算该 resident 在 program ROL 的 rank, lees -> good
        int newRank = rank(rid);

        // 2) if 还没满 quota，do
        if (matchedResidents.size() < quota) {
            matchedResidents.add(resident);

            // refresh resident 的匹配信息
            resident.setMatchedProgram(this);
            resident.setMatchedRank(newRank);

            return new AddResult(true, null);
        }

        // 3) if 已满 quota：看是否比当前最差者更好 which one is batter
        Resident worst = leastPreferred();
        if (worst == null) {
            // 理论上不会发生（因为 size>=quota>=1)
            return new AddResult(false, null);
        }

        // 如果新 resident rank 更小 => program 更喜欢新的人
        if (newRank < worst.getMatchedRank()) {

            // 替换：把 worst 踢掉
            matchedResidents.remove(worst);
            worst.unmatch(); // 被踢出后变为 available

            // 接收新 resident
            matchedResidents.add(resident);
            resident.setMatchedProgram(this);
            resident.setMatchedRank(newRank);

            return new AddResult(true, worst);
        }

        // 4) 否则拒绝新 resident
        return new AddResult(false, null);
    }

    // 用于把“接收与否 + 被踢出的人”一起返回（非 static）
    public class AddResult {
        private boolean accepted;
        private Resident evicted;

        public AddResult(boolean accepted, Resident evicted) {
            this.accepted = accepted;
            this.evicted = evicted;
        }

        public boolean isAccepted() {
            return accepted;
        }

        public Resident getEvicted() {
            return evicted;
        }
    }

    // string representation
    @Override
	public String toString() {
      
       return "["+programID+"]: "+name+" {"+ quota+ "}" +" ("+rol.length+")";	  
	}
}