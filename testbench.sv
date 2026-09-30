module tb;

    logic signed [3:0] a;
    logic signed [3:0] b;
    logic [2:0] op;

    logic signed [3:0] result;
    logic overflow;
    logic signed [4:0] full_result;

    integer total_tests;
    integer passed_tests;
    integer failed_tests;

    integer i, j;
    integer expected_math;

    logic signed [3:0] expected_result;
    logic expected_overflow;
    logic signed [4:0] expected_full;


    // ============================================================
    // DUT
    // ============================================================

    ALU_4bit dut (
        .a(a),
        .b(b),
        .op(op),
        .result(result),
        .overflow(overflow),
        .full_result(full_result)
    );


    // CHECK TASK

    task check_result(
        input logic signed [3:0] expected_result,
        input logic expected_overflow,
        input logic signed [4:0] expected_full
    );

        begin

            total_tests = total_tests + 1;

            if (result === expected_result &&
                overflow === expected_overflow &&
                full_result === expected_full) begin

                passed_tests = passed_tests + 1;

            end
            else begin

                failed_tests = failed_tests + 1;

                $display(
                    "FAIL: a=%0d b=%0d op=%03b | result=%b exp=%b | ov=%b exp=%b | full=%b exp=%b",
                    a, b, op,
                    result, expected_result,
                    overflow, expected_overflow,
                    full_result, expected_full
                );

            end

        end

    endtask


    // TESTS

    initial begin

        total_tests  = 0;
        passed_tests = 0;
        failed_tests = 0;

        for (i = -8; i <= 7; i = i + 1) begin

            for (j = -8; j <= 7; j = j + 1) begin

                a = i;
                b = j;


                // ADD

                op = 3'b000;
                #1;

                expected_math = i + j;

                expected_overflow =
                    (expected_math > 7) ||
                    (expected_math < -8);

                expected_full = expected_math;
                expected_result = expected_full[3:0];

                check_result(
                    expected_result,
                    expected_overflow,
                    expected_full
                );


                // SUB

                op = 3'b001;
                #1;

                expected_math = i - j;

                expected_overflow =
                    (expected_math > 7) ||
                    (expected_math < -8);

                expected_full = expected_math;
                expected_result = expected_full[3:0];

                check_result(
                    expected_result,
                    expected_overflow,
                    expected_full
                );


                // AND

                op = 3'b010;
                #1;

                expected_result = a & b;
                expected_overflow = 1'b0;
                expected_full = {1'b0, expected_result};

                check_result(
                    expected_result,
                    expected_overflow,
                    expected_full
                );


                // OR

                op = 3'b011;
                #1;

                expected_result = a | b;
                expected_overflow = 1'b0;
                expected_full = {1'b0, expected_result};

                check_result(
                    expected_result,
                    expected_overflow,
                    expected_full
                );


                // XOR

                op = 3'b100;
                #1;

                expected_result = a ^ b;
                expected_overflow = 1'b0;
                expected_full = {1'b0, expected_result};

                check_result(
                    expected_result,
                    expected_overflow,
                    expected_full
                );


                
                // SLT

                op = 3'b101;
                #1;

                expected_result = (a < b) ? 4'b0001 : 4'b0000;
                expected_overflow = 1'b0;
                expected_full = {1'b0, expected_result};

                check_result(
                    expected_result,
                    expected_overflow,
                    expected_full
                );

            end

        end


        // FINAL REPORT

      $display("");
        $display("ALU VERIFICATION RESULTS");
        $display("TOTAL TESTS  : %0d", total_tests);
        $display("PASSED       : %0d", passed_tests);
        $display("FAILED       : %0d", failed_tests);
        if (failed_tests == 0)
            $display("ALL TESTS PASSED!");
        else
            $display("VERIFICATION FAILED!");

        $finish;

    end

endmodule
