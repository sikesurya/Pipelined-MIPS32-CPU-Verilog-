
module pipe_MIPS32(clk1, clk2);

    input clk1, clk2;   //two phase clock
    reg[31:0] PC, IF_ID_IR, IF_ID_NPC;
    reg[31:0] ID_EX_IR, ID_EX_NPC, ID_EX_A, ID_EX_B, ID_EX_Imm;
    reg[2:0] ID_EX_type, EX_MEM_type, MEM_WB_type;
    reg[31:0] EX_MEM_IR, EX_MEM_ALUout, EX_MEM_B;
    reg EX_MEM_cond;
    reg[31:0] MEM_WB_IR, MEM_WB_ALUout, MEM_WB_LMD;
    
    reg[31:0] Reg [0:31]; // 32x32 Register bank
    reg[31:0] Mem [0:1023]; // 1024x32 memory (1024 words of 32 bits each)
    
    parameter ADD = 6'b000000, SUB = 6'b000001, AND = 6'b000010, OR = 6'b000011,
              SLT = 6'b000100, MUL = 6'b000101, HLT = 6'b111111, LW = 6'b001000,
              SW = 6'b001001, ADDI = 6'b001010, SUBI = 6'b001011, SLTI = 6'b001100,
              BNEQZ = 6'b001101, BEQZ = 6'b001110;
              
    parameter RR_ALU = 3'b000, RM_ALU = 3'b001, LOAD = 3'b010, STORE = 3'b011, 
              BRANCH = 3'b100, HALT = 3'b101;
              
    reg HALTED; ///Set after HALT instruction is completed in WB stage
    
    reg TAKEN_BRANCH; //Set after its decided to take a branch. Its required to disable instructions after branch
    
    /*
    Instruction Style:
    [31:26] opcode, 
    [25:21] rs,
    [21:16] rt,
    [15:11] rd
    */
    
    //// THE STAGES
    
    // IF - INSTRUCTION FETCH STAGE
    
    always@(posedge clk1)
    begin
        if(HALTED == 0) 
        begin
            if(((EX_MEM_IR[31:26] == BEQZ) && (EX_MEM_cond == 1)) || ((EX_MEM_IR[31:26] == BNEQZ) && (EX_MEM_cond == 0)))  // cond = (A == 0)
                begin
                
                IF_ID_IR        <= #2 Mem[EX_MEM_ALUout];
                TAKEN_BRANCH    <= #2 1'b1;
                IF_ID_NPC       <= #2 EX_MEM_ALUout + 1;
                PC              <= #2 EX_MEM_ALUout + 1;
      
                end
                
                else begin  //normak sequencer execution if no branch, fetch instruction from PC, Incerement PC and NPC both by 1
                
                IF_ID_IR        <= #2 Mem[PC];
                IF_ID_NPC       <= #2 PC + 1;
                PC              <= #2 PC + 1;

                end
        end 
    end
    
    
    // ID - INSTRUCTION DECODE STAGE
    
    // 1. We actually decode the instruction (implied in the case statements
    // 2. Prefecthing 2 source registers
    // 3. Sign-extending the 16bit offset
    
    always@(posedge clk2) begin
        if(HALTED == 0)
        begin
            if(IF_ID_IR[25:21] == 5'b00000) ID_EX_A <= 0;   //checking if 'rs' is 0, if yes register bank is not accessed, straight away assign 0 to A;
            else ID_EX_A <= #2 Reg[IF_ID_IR[25:21]]; //  else, whatever 5 bit register is present in 'rs', is loaded to 'A'
            
            if (IF_ID_IR[20:16] == 5'b00000) ID_EX_B <= 0;
            else ID_EX_B <= #2 Reg[IF_ID_IR[20:16]];   // 'rt' is loaded into 'B'
             
            //simply forward the remaining stuff:
            ID_EX_NPC <= #2 IF_ID_NPC;
            ID_EX_IR <= #2 IF_ID_IR;
            ID_EX_Imm <= #2 {{16{IF_ID_IR[15]}}, IF_ID_IR[15:0]};   //sign extension: the sign bit(15th index) is just repeated 16 times on MSB side, hence getting 32 bits in total            
            
            case (IF_ID_IR[31:26]) //case on opcode
                ADD, SUB, AND, OR, SLT, MUL :       ID_EX_type <= #2 RR_ALU;
                ADDI, SUBI, SLTI :                  ID_EX_type <= #2 RM_ALU;
                LW :                                ID_EX_type <= #2 LOAD;
                SW :                                ID_EX_type <= #2 STORE;
                BNEQZ, BEQZ :                       ID_EX_type <= #2 BRANCH;
                HLT :                               ID_EX_type <= #2 HALT;
                default:                            ID_EX_type <= #2 HALT;
                
            endcase 
      
        end
    end
    
    
    
    
    // EX - EXECUTE STAGE
    
    always@(posedge clk1) 
    begin
        if(HALTED == 0)
            begin
                //forwarding some stuff as is:
                EX_MEM_type         <= #2 ID_EX_type;
                EX_MEM_IR           <= #2 ID_EX_IR;
                TAKEN_BRANCH        <= #2 0;
                
                case(ID_EX_type)  // ALU Operations begin !!
                    RR_ALU: begin
                                case(ID_EX_IR[31:26])
                                ADD: EX_MEM_ALUout      <= #2 ID_EX_A + ID_EX_B;
                                SUB: EX_MEM_ALUout      <= #2 ID_EX_A - ID_EX_B;    
                                AND: EX_MEM_ALUout      <= #2 ID_EX_A & ID_EX_B;
                                OR: EX_MEM_ALUout       <= #2 ID_EX_A | ID_EX_B;
                                SLT: EX_MEM_ALUout      <= #2 ID_EX_A < ID_EX_B;
                                MUL: EX_MEM_ALUout      <= #2 ID_EX_A * ID_EX_B;
                                default: EX_MEM_ALUout  <= #2 32'hxxxxxxxx;
                                endcase    
                            end
                    RM_ALU: begin
                                case(ID_EX_IR[31:26])
                                ADDI: EX_MEM_ALUout      <= #2 ID_EX_A + ID_EX_Imm;
                                SUBI: EX_MEM_ALUout      <= #2 ID_EX_A - ID_EX_Imm;    
                                SLTI: EX_MEM_ALUout      <= #2 ID_EX_A < ID_EX_Imm;
                                default: EX_MEM_ALUout   <= #2 32'hxxxxxxxx;
                                endcase    
                            end
                            
                    LOAD, STORE: begin
                                    EX_MEM_ALUout       <= #2 ID_EX_A + ID_EX_Imm; //calculating address of memory
                                    EX_MEM_B            <= #2 ID_EX_B;  //forward B
                                 end
                            
                    BRANCH: begin
                                EX_MEM_ALUout           <= #2 ID_EX_NPC + ID_EX_Imm;  //calculating target address of the branch by adding PC to offset
                                EX_MEM_cond             <= #2 (ID_EX_A == 0);
                            end
                endcase
            end
    end
    
    
    /// MEM STAGE
    
    always@(posedge clk2) 
    begin
        if(HALTED == 0)
        begin
            MEM_WB_type <= #2 EX_MEM_type;
            MEM_WB_IR   <= #2 EX_MEM_IR;
    
            case(EX_MEM_type)
                RR_ALU, RM_ALU :  MEM_WB_ALUout <= #2 EX_MEM_ALUout;
                LOAD:             MEM_WB_LMD    <= #2 Mem[EX_MEM_ALUout]; 
                STORE:      if(TAKEN_BRANCH == 0) //disable write if TAKEN_BRANCH == 1
                                Mem[EX_MEM_ALUout] <= #2 EX_MEM_B;
            endcase
        end
    end 
    
    /// WB - WRITEBACK STAGE
    
    always@(posedge clk1)
    begin
        if(TAKEN_BRANCH == 0)  //disable write if branch is taken
        begin
            case(MEM_WB_type) 
                RR_ALU: Reg[MEM_WB_IR[15:11]] <= #2 MEM_WB_ALUout;  // 'rd' is stored in IR[15:11], so ALU out is stored here
                RM_ALU: Reg[MEM_WB_IR[20:16]] <= #2 MEM_WB_ALUout;  //'rt'
                LOAD:   Reg[MEM_WB_IR[20:16]] <= #2 MEM_WB_LMD;  //'rt'
                HALT:   HALTED                <= #2 1'b1;
            endcase
        end
    end
    
    
  
endmodule
