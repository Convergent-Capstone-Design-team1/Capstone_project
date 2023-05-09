# Capstone_project
RISC-V 5stage pipeline CPU including branch prediction

use this code to compile CPU : 
iverilog -s tb_CPU -o test PC.v PC_mux.v BHT.v BTB.v Predictor.v Inst_mem.v Register_file.v Control.v ImmGen.v ALU_control.v ALU.v ALU_mux.v Forwarding_Unit.v Forwarding_mux.v Data_mem.v Hazard_detection.v IF_stage.v IF_ID.v ID_stage.v ID_EX.v EX_stage.v EX_MEM.v MEM_stage.v MEM_WB.v WB_stage.v Register.v TopCPU.v ID_EX_Flush.v EX_MEM_Flush.v Falling_edge_detector.v INITIAL_module.v tb_CPU.v


use this code to compile npu :
iverilog -s tb_systolic_array -o test mac.v systolic_array.v tb_systolic_array.v

use this code to compile combined module :
iverilog -s tb_combined -o test PC.v PC_mux.v BHT.v BTB.v Predictor.v Inst_mem.v Register_file.v Control.v ImmGen.v ALU_control.v ALU.v ALU_mux.v Forwarding_Unit.v Forwarding_mux.v Data_mem.v Hazard_detection.v IF_stage.v IF_ID.v ID_stage.v ID_EX.v EX_stage.v EX_MEM.v MEM_stage.v MEM_WB.v WB_stage.v Register.v TopCPU.v ID_EX_Flush.v EX_MEM_Flush.v Falling_edge_detector.v INITIAL_module.v mac.v systolic_array.v npu.v tb_combined.v