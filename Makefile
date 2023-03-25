# Makefile for compiling and running testbenches using Icarus Verilog

# List of Verilog files to be compiled
VERILOG_FILES = PC.v BHT.v BTB.v Predictor.v Inst_mem.v Register_file.v Control.v ImmGen.v ALU_control.v ALU.v ALU_mux.v Forwarding_Unit.v Forwarding_mux.v Data_mem.v Hazard_detection.v IF_stage.v IF_ID.v ID_stage.v ID_EX.v EX_stage.v EX_MEM.v MEM_stage.v MEM_WB.v WB_stage.v Register.v TopCPU.v tb_CPU.v

# Testbench file
TESTBENCH = tb_CPU.v

# Name of the compiled binary
BINARY = sim

# Compile Verilog files into a binary
$(BINARY): $(VERILOG_FILES)
   iverilog -o $(BINARY) $(VERILOG_FILES)

# Run the simulation
run: $(BINARY)
   ./$(BINARY)

# Clean up the binary and any generated files
clean:
   rm -f $(BINARY) *.vcd