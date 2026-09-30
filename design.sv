
// 1. HALF ADDER

module half_adder(
    input  logic a,
    input  logic b,
    output logic sum,
    output logic carry
);

    assign sum   = a ^ b;
    assign carry = a & b;

endmodule


// 2. FULL ADDER

module full_adder(
    input  logic a,
    input  logic b,
    input  logic Cin,
    output logic sum,
    output logic Cout
);

    logic x;
    logic y;
    logic z;

    half_adder HA1(
        .a(a),
        .b(b),
        .sum(x),
        .carry(y)
    );

    half_adder HA2(
        .a(x),
        .b(Cin),
        .sum(sum),
        .carry(z)
    );

    assign Cout = y | z;

endmodule


// 3. 4-BIT RIPPLE-CARRY ADDER

module RCA_4bit(
    input  logic [3:0] a,
    input  logic [3:0] b,
    input  logic       cin,
    output logic [3:0] sum
);

    logic c1, c2, c3, c4;

    full_adder FA0(
        .a(a[0]),
        .b(b[0]),
        .Cin(cin),
        .sum(sum[0]),
        .Cout(c1)
    );

    full_adder FA1(
        .a(a[1]),
        .b(b[1]),
        .Cin(c1),
        .sum(sum[1]),
        .Cout(c2)
    );

    full_adder FA2(
        .a(a[2]),
        .b(b[2]),
        .Cin(c2),
        .sum(sum[2]),
        .Cout(c3)
    );

    full_adder FA3(
        .a(a[3]),
        .b(b[3]),
        .Cin(c3),
        .sum(sum[3]),
        .Cout(c4)
    );

endmodule


// 4. ADD / SUB UNIT

module add_sub_4bit(
    input  logic signed [3:0] a,
    input  logic signed [3:0] b,
    input  logic sub,

    output logic signed [3:0] result,
    output logic overflow,
    output logic signed [4:0] full_result
);

    logic [3:0] b_modified;

    // SUB = 0 → B
    // SUB = 1 → ~B
    assign b_modified = b ^ {4{sub}};

    // ADD:
    //     A + B + 0
    //
    // SUB:
    //     A + ~B + 1
    RCA_4bit rca(
        .a(a),
        .b(b_modified),
        .cin(sub),
        .sum(result)
    );

    // Signed overflow
    always_comb begin
        if (!sub) begin

            // ADD:
            // Same-sign operands + opposite-sign result
            overflow = (a[3] == b[3]) &&
                       (result[3] != a[3]);

        end
        else begin

            // SUB:
            // Opposite-sign operands + result sign differs from A
            overflow = (a[3] != b[3]) &&
                       (result[3] != a[3]);

        end
    end

    // Reconstruct the full 5-bit signed mathematical result.

    assign full_result = {
        result[3] ^ overflow,
        result
    };

endmodule


// 5. AND UNIT

module and_unit(
    input  logic signed [3:0] a,
    input  logic signed [3:0] b,

    output logic signed [3:0] result,
    output logic overflow,
    output logic signed [4:0] full_result
);

    assign result = a & b;

    assign overflow = 1'b0;

    assign full_result = {1'b0, result};

endmodule


// 6. OR UNIT

module or_unit(
    input  logic signed [3:0] a,
    input  logic signed [3:0] b,

    output logic signed [3:0] result,
    output logic overflow,
    output logic signed [4:0] full_result
);

    assign result = a | b;

    assign overflow = 1'b0;

    assign full_result = {1'b0, result};

endmodule


// 7. XOR UNIT

module xor_unit(
    input  logic signed [3:0] a,
    input  logic signed [3:0] b,

    output logic signed [3:0] result,
    output logic overflow,
    output logic signed [4:0] full_result
);

    assign result = a ^ b;

    assign overflow = 1'b0;

    assign full_result = {1'b0, result};

endmodule


// 8. SIGNED LESS-THAN UNIT

module slt_unit(
    input  logic signed [3:0] a,
    input  logic signed [3:0] b,

    output logic signed [3:0] result,
    output logic overflow,
    output logic signed [4:0] full_result
);

    assign result = (a < b) ? 4'b0001 : 4'b0000;

    assign overflow = 1'b0;

    assign full_result = {1'b0, result};

endmodule


// 9. TOP-LEVEL 4-BIT SIGNED ALU

module ALU_4bit(
    input  logic signed [3:0] a,
    input  logic signed [3:0] b,
    input  logic [2:0] op,

    output logic signed [3:0] result,
    output logic overflow,
    output logic signed [4:0] full_result
);

    // Internal outputs from each functional unit

    logic signed [3:0] add_result;
    logic add_overflow;
    logic signed [4:0] add_full_result;

    logic signed [3:0] and_result;
    logic and_overflow;
    logic signed [4:0] and_full_result;

    logic signed [3:0] or_result;
    logic or_overflow;
    logic signed [4:0] or_full_result;

    logic signed [3:0] xor_result;
    logic xor_overflow;
    logic signed [4:0] xor_full_result;

    logic signed [3:0] slt_result;
    logic slt_overflow;
    logic signed [4:0] slt_full_result;


    // ADD / SUB
    //
    // op = 000 → ADD
    // op = 001 → SUB
    // --------------------------------------------------------

    add_sub_4bit arithmetic_unit(
        .a(a),
        .b(b),
        .sub(op == 3'b001),

        .result(add_result),
        .overflow(add_overflow),
        .full_result(add_full_result)
    );


    // AND

    and_unit and_block(
        .a(a),
        .b(b),

        .result(and_result),
        .overflow(and_overflow),
        .full_result(and_full_result)
    );


    
    // OR

    or_unit or_block(
        .a(a),
        .b(b),

        .result(or_result),
        .overflow(or_overflow),
        .full_result(or_full_result)
    );


    // XOR

    xor_unit xor_block(
        .a(a),
        .b(b),

        .result(xor_result),
        .overflow(xor_overflow),
        .full_result(xor_full_result)
    );


    // SIGNED LESS THAN

    slt_unit slt_block(
        .a(a),
        .b(b),

        .result(slt_result),
        .overflow(slt_overflow),
        .full_result(slt_full_result)
    );


    // FINAL RESULT MUX

    always_comb begin

        case (op)

            3'b000: begin      
                result      = add_result;
                overflow    = add_overflow;
                full_result = add_full_result;
            end

            3'b001: begin       
                result      = add_result;
                overflow    = add_overflow;
                full_result = add_full_result;
            end

            3'b010: begin
                result      = and_result;
                overflow    = and_overflow;
                full_result = and_full_result;
            end

            3'b011: begin       
                result      = or_result;
                overflow    = or_overflow;
                full_result = or_full_result;
            end

            3'b100: begin     
                result      = xor_result;
                overflow    = xor_overflow;
                full_result = xor_full_result;
            end

            3'b101: begin       
                result      = slt_result;
                overflow    = slt_overflow;
                full_result = slt_full_result;
            end

            default: begin
                result      = 4'b0000;
                overflow    = 1'b0;
                full_result = 5'b00000;
            end

        endcase

    end

endmodule
