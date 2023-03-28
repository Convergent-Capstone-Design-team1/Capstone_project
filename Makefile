CC = iverilog
FLAGS = -Wall -Winfloop

default: tb_CPU.v TopCPU.v PC.v BHT.v BTB.v Predictor.v Inst_mem.v Register_file.v Control.v ImmGen.v ALU_control.v ALU.v ALU_mux.v Forwarding_Unit.v Forwarding_mux.v Data_mem.v Hazard_detection.v IF_stage.v IF_ID.v ID_stage.v ID_EX.v EX_stage.v EX_MEM.v MEM_stage.v MEM_WB.v WB_stage.v Register.v
    $(CC) $(FLAGS) -o test.out tb_CPU.v PC.v BHT.v BTB.v Predictor.v Inst_mem.v Register_file.v Control.v ImmGen.v ALU_control.v ALU.v ALU_mux.v Forwarding_Unit.v Forwarding_mux.v Data_mem.v Hazard_detection.v IF_stage.v IF_ID.v ID_stage.v ID_EX.v EX_stage.v EX_MEM.v MEM_stage.v MEM_WB.v WB_stage.v Register.v TopCPU.v
    vvp test.out

    gtkwave test.vcd