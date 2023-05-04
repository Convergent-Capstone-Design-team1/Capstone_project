# Capstone_project
RISC-V 5stage pipeline CPU including branch prediction

use this code to compile : 
iverilog -s tb_CPU -o test PC.v PC_mux.v  BHT.v BTB.v Predictor.v Inst_mem.v Register_file.v Control.v ImmGen.v ALU_control.v ALU.v ALU_mux.v Forwarding_Unit.v Forwarding_mux.v Data_mem.v Hazard_detection.v IF_stage.v IF_ID.v ID_stage.v ID_EX.v EX_stage.v EX_MEM.v MEM_stage.v MEM_WB.v WB_stage.v Register.v TopCPU.v ID_EX_Flush.v EX_MEM_Flush.v Falling_edge_detector.v tb_CPU.v
