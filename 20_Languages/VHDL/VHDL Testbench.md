---
tags:
  - concept
  - vhdl
  - testing
  - verification
category: languages
status: learning
related: "[[_VHDL]]"
date: 2025-12-02
---

# VHDL Testbench

## 📝 One-Sentence Summary
*A VHDL Testbench is a simulation file that verifies the functionality of a design (the "Unit Under Test") by generating input stimuli and checking the resulting outputs, without being synthesizable itself.*

## 💡 Analogy
*If your VHDL design (like an ALU) is a newly built **car engine**, the Testbench is the **diagnostic computer** connected to it in the lab. The diagnostic computer sends specific commands (stimuli) like "accelerate to 3000 RPM" and measures the engine's response to ensure it behaves correctly before the engine is ever put into a real car.*

## 🔑 Key Details
-   **What it is:** A VHDL entity that has **no ports** (an empty entity). It contains an instance of the design you want to test (UUT) and a process to drive signals to that design.
-   **Why it exists:** To verify that hardware logic works correctly *before* physical implementation. It allows you to simulate scenarios, catch bugs, and visualize waveforms in tools like [[ModelSim]].
-   **Core Components:**
    1.  **UUT (Unit Under Test):** The component being tested (e.g., your `alu`).
    2.  **Stimulus Process:** A VHDL `PROCESS` that applies values to the inputs over time.
    3.  **Assertions (Optional):** Statements that automatically check if the output matches the expected value.

## ⚙️ Structure & Example
*Based on the `alu_tb.vhd` code.*

### 1. The Empty Entity
A testbench has no external connections; it is a self-contained simulation universe.
```vhdl
ENTITY alu_tb IS
END alu_tb;
```
### 2. Architecture & Signal Declaration

We declare signals to connect to the UUT's ports.
``` VHDL
ARCHITECTURE behavior OF alu_tb IS
    -- Signals to connect to the ALU
    SIGNAL a, b, result : std_logic_vector(31 downto 0);
    SIGNAL alucontrol : std_logic_vector(2 downto 0);
    SIGNAL zero : std_logic;
BEGIN
```

### 3. Instantiation (The UUT)

We create an instance of the design we are testing (`work.alu`) and map our local signals to its ports.
```vhdl
    -- UUT: Unit Under Test
    UUT: ENTITY work.alu PORT MAP(
        a => a, 
        b => b, 
        alucontrol => alucontrol, 
        result => result, 
        zero => zero
    );
```

### 4. The Stimulus Process

This process generates the inputs. It uses `WAIT` statements to create time delays between test cases.
```vhdl
    stim_proc: PROCESS
    BEGIN
        -- Test Case 1: Setup Data
        a <= x"00000005"; b <= x"00000003";
        
        -- Test Case 2: ADD Operation
        alucontrol <= "010"; 
        WAIT FOR 20 ns; 

        -- Test Case 3: SUB Operation
        alucontrol <= "110"; 
        WAIT FOR 20 ns; 

        -- End simulation
        WAIT;
    END PROCESS;
END behavior;
```

## 🔗 Connections & Implementations

- **Simulation Tools:** Used with [[ModelSim]] or GHDL to view waveforms.
    
- **Your Examples:**
    
    - [[alu_tb.vhd]]: Tests arithmetic and logic operations.
        
    - [[mux2_tb.vhd]]: Tests the 2-to-1 multiplexer switching.
        
    - [[pc_tb.vhd]]: Tests the Program Counter's reset and clock edge behavior.
        
    - [[regfile_tb.vhd]]: Tests writing to and reading from register addresses.

## 👍 Pros & 👎 Cons

- **Pros:** Allows rigorous testing without hardware; essential for debugging complex logic; can be automated with assertions.
    
- **Cons:** Writing good testbenches can take as much time as the design itself; simulation speed can be slow for massive designs.
    

## See Also

- [[_VHDL]]
    
- [[VHDL: Combinational vs Sequential Logic]]
    
- [[ModelSim]]