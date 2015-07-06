`timescale 1ns/1ps

module tb #(
  parameter integer N = 1,
  parameter integer I = 1,
  parameter integer D = 1,
  parameter integer U = 1
);

  logic Clk;
  logic Rst;
  
  initial       Clk = 1'b0;
  always #(5ns) Clk = ~Clk;

  
  reg [32-1:0] data;
  reg  [2-1:0] resp;
  
  initial
  begin 
    Rst = 1'b1; 
    #(2500ns)
    @(posedge Clk);
    Rst = 1'b0;
  end
  
  initial
  begin
    // Wait for end of reset
    @(negedge Rst);
    @(posedge Clk);
    Axi4Lite_M.WriteTransaction(32'h00000100, 3'b0, 32'h12345678, 4'b1011, resp);
    Axi4Lite_M.WriteTransaction(32'h12345678, 3'b0, 32'h0000abcd, 4'b1111, resp);
    Axi4Lite_M.ReadTransaction (32'h00000100, 3'b0, data                 , resp);
    Axi4Stream_S.Receive;
    Axi4Stream_M.SendRandomPacket(200);
    Axi4Stream_M.SendRandomPacket(100);
  end

  AXI4       #(.N(8), .I(1)) axi4       (.ACLK(Clk), .ARESETn(!Rst));
  AXI4Lite   #(.N(4), .I(1)) axi4lite   (.ACLK(Clk), .ARESETn(!Rst));
  AXI4Stream #(.N(4)       ) axi4stream (.ACLK(Clk), .ARESETn(!Rst));

  Axi4LiteMaster   #(.N(4), .I(1)              ) Axi4Lite_M   (.intf(axi4lite)  );
  Axi4LiteSlave    #(.N(4), .I(1)              ) Axi4Lite_S   (.intf(axi4lite)  );
  Axi4StreamMaster #(.N(4), .I(1), .D(1), .U(1)) Axi4Stream_M (.intf(axi4stream));
  Axi4StreamSlave  #(.N(4), .I(1), .D(1), .U(1)) Axi4Stream_S (.intf(axi4stream));
  Axi4MasterBFM    #(.N(8), .I(1)              ) Axi4_M       (.intf(axi4)      );
  Axi4SlaveBFM     #(.N(8), .I(1)              ) Axi4_S       (.intf(axi4)      );

endmodule: tb
