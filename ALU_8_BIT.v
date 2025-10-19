//  Parameterized ALU with Flags & Extended Operations

module alu #(
    parameter WIDTH = 8   // Parameterized bit width ,makes our ALU configurable (8-bit, 16-bit, etc.).
)(
    input  [WIDTH-1:0] A, B,   // 8-bit input operands.
    input  [3:0] ALU_Sel,     // 4-bit select for more ops
    output reg [WIDTH-1:0] ALU_Out,
    output reg CarryOut,             //Flags (CarryOut, ZeroFlag, etc.) are status signals used in verification and CPUs.
    output reg ZeroFlag,             //  zeroflag is high  when  output is zero
    output reg OverflowFlag,
    output reg NegativeFlag            // NegativeFlag -Result is negative - MSB = 1
);

    // Internal temporary variable for operations
    reg [WIDTH:0] tmp;

    always @(*)   //This means the ALU reacts combinationally — whenever any input changes, the output updates automatically.
 
   begin
        // Default values
        CarryOut     = 0;
        OverflowFlag = 0;
        NegativeFlag = 0;
        ZeroFlag     = 0;

        case (ALU_Sel)
            4'b0000: begin  // Addition
                tmp = A + B;
                ALU_Out = tmp[WIDTH-1:0];
                CarryOut = tmp[WIDTH];   // CarryOut bit tells us if there was a carry beyond 8 bits.
                OverflowFlag = (A[WIDTH-1] == B[WIDTH-1]) && (ALU_Out[WIDTH-1] != A[WIDTH-1]);  // OverflowFlag tells us if signed overflow occurred (useful for 2’s complement arithmetic).
            end
            4'b0001: begin  // Subtraction
                tmp = A - B;
                ALU_Out = tmp[WIDTH-1:0];
                CarryOut = tmp[WIDTH];
                OverflowFlag = (A[WIDTH-1] != B[WIDTH-1]) && (ALU_Out[WIDTH-1] != A[WIDTH-1]);
            end
            4'b0010: ALU_Out = A & B;   // AND
            4'b0011: ALU_Out = A | B;   // OR
            4'b0100: ALU_Out = A ^ B;   // XOR
            4'b0101: ALU_Out = ~(A);    // NOT
            4'b0110: ALU_Out = A << 1;  // Left Shift (Multiply by 2)
            4'b0111: ALU_Out = A >> 1;  // Right Shift (Divide by 2)
            4'b1000: ALU_Out = A * B;   // Multiplication
            4'b1001: ALU_Out = (B != 0) ? (A / B) : 0; // Division (avoid divide by zero) (B != 0) — a good verification practice to prevent undefined behavior.
            4'b1010: ALU_Out = (A == B) ? 8'h01 : 8'h00; // Equal compare
            4'b1011: ALU_Out = (A > B)  ? 8'h01 : 8'h00; // Greater compare
            4'b1100: ALU_Out = (A < B)  ? 8'h01 : 8'h00; // Less compare
            default: ALU_Out = 0;
        endcase

        // Set flags
        ZeroFlag     = (ALU_Out == 0);
        NegativeFlag = ALU_Out[WIDTH-1];
    end
endmodule
