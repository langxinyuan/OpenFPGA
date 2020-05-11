`timescale 1ns/1ps

module CCFFX1 (		// need to look deeper, we should have a reset signal!!
    input D,
    input CK,
    input R,
    output Q,
    output QB);

    DFFRPQ_X1N_A9PP84TR_C14 DFFRPQ_X1N_A9PP84TR_C14_0 (.D(D), .Q(Q), .CK(CK), .R(R));
    INV_X1N_A9PP84TR_C14 INV_X1N_A9PP84TR_C14_0 (.A(Q), .Y(QB));
endmodule

module GPIO (
    output A,
    output IE,
    output OE,
    input Y, // The output that is z
    input in,
    output out,
    input mem_out);

    assign A = in;
    assign out = Y; // it is assign as if it was an input but it is not.
    assign IE = mem_out;
    INV_X1N_A9PP84TR_C14 ie_oe_inv (
        .A	(mem_out),
        .Y	(OE) );

endmodule

module dpram (
    input clk,
    input wen,
    input ren,
    input[9:0] waddr,
    input[9:0] raddr,
    input[31:0] d_in,
    output[31:0] d_out );

    wire LOW, HIGH;
    wire n_ren, n_wen;

    TIELO_X1N_A9PP84TR_C14 Llevel (
        .Y		(LOW) );

    TIEHI_X1N_A9PP84TR_C14 Hlevel (
        .Y		(HIGH) );

    INV_X1N_A9PP84TR_C14 inv_ren (
        .A	(ren),
        .Y	(n_ren) );

    INV_X1N_A9PP84TR_C14 inv_wen (
        .A	(wen),
        .Y	(n_wen) );

    mem32x1024MW4_B4 memory_0 (
        .CLKA		(clk),				// Reading Port
        .CENA		(n_ren),
        .AA			(raddr),
        .QA			(d_out),
        .DB			(d_in),				//Writing port
        .CLKB		(clk),
        .CENB		(n_wen),
        .AB			(waddr),
        .STOV		(LOW),				//Self-Time Override -> for test -> should be set to zero
        .EMAA		({LOW, HIGH, LOW}),	//Extra Margin Adjustment for port A -> can slow down pulses if not set to zero
        .EMASA		(LOW),				// = 0 if STOV = 0
        .EMAB		({LOW, HIGH, LOW}),	//Extra Margin Adjustment for port B -> can slow down pulses if not set to zero => default value is 2
        .RET1N		(HIGH) );			//Retention, active low

endmodule