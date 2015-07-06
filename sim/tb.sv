`timescale 1ns/1ps

module tb #(
  parameter integer N = 1,
  parameter integer I = 1,
  parameter integer D = 1,
  parameter integer U = 1
);

  logic clk;
  logic resetn;
  
  initial       clk = 1'b0;
  always #(5ns) clk = ~clk;

  logic [32-1:0] data;
  logic  [2-1:0] resp;
  
  initial
  begin 
    resetn = 1'b1; 
    #(2500ns)
    @(posedge clk);
    resetn = 1'b0;
    @(posedge clk);
    Axi4Lite_M.WriteTransaction(32'h00000100, 3'b0, 32'h12345678, 4'b1011, resp);
    Axi4Lite_M.WriteTransaction(32'h12345678, 3'b0, 32'h0000abcd, 4'b1111, resp);
    Axi4Lite_M.ReadTransaction (32'h00000100, 3'b0, data                 , resp);
    Axi4Stream_S.Receive;
    Axi4Stream_M.SendRandomPacket(200);
    Axi4Stream_M.SendRandomPacket(100);
  end

  AXI4             #(.N(8), .I(1)              ) axi4         (.ACLK(clk), .ARESETn(!resetn));
  AXI4Lite         #(.N(4), .I(1)              ) axi4lite     (.ACLK(clk), .ARESETn(!resetn));
  AXI4Stream       #(.N(4)                     ) axi4stream   (.ACLK(clk), .ARESETn(!resetn));

  Axi4LiteMaster   #(.N(4), .I(1)              ) Axi4Lite_M   (.intf(axi4lite)  );
  Axi4LiteSlave    #(.N(4), .I(1)              ) Axi4Lite_S   (.intf(axi4lite)  );
  Axi4StreamMaster #(.N(4), .I(1), .D(1), .U(1)) Axi4Stream_M (.intf(axi4stream));
  Axi4StreamSlave  #(.N(4), .I(1), .D(1), .U(1)) Axi4Stream_S (.intf(axi4stream));
  Axi4MasterBFM    #(.N(8), .I(1)              ) Axi4_M       (.intf(axi4)      );
  Axi4SlaveBFM     #(.N(8), .I(1)              ) Axi4_S       (.intf(axi4)      );

endmodule: tb
