`define OKAY 2'b00
`define EXOKAY 2'b01
`define SLVERR 2'b10
`define DECERR 2'b11

module Axi4LiteMaster#(
  int unsigned N = 1,
  int unsigned I = 1
)(
  AXI4Lite intf
);
  int AWDelay;
  int WDelay ;
  int BDelay ;
  int ARDelay;
  int RDelay ;

  task ARTransaction (
    input  int          delay,
    input  bit [32-1:0] addr,
    input  bit  [3-1:0] prot
  );
    for (int i=0; i<delay; i++) @(posedge intf.ACLK);
    intf.ARVALID <= 1'b1;
    intf.ARADDR  <= addr;
    intf.ARPROT  <= prot;
    @(posedge intf.ACLK);
    while (!intf.ARREADY) @(posedge intf.ACLK);
    intf.ARVALID <= 1'b0;
  endtask: ARTransaction
  
  task RTransaction (
    input  int          delay,
    output bit [64-1:0] data,
    output bit  [3-1:0] resp
  );
    for (int i=0; i<delay; i++) @(posedge intf.ACLK);
    intf.RREADY <= 1'b1;
    while(!intf.RVALID) @(posedge intf.ACLK);
    data = intf.RDATA;
    resp = intf.RRESP;
    intf.RREADY <= 1'b0;
  endtask: RTransaction

  task AWTransaction (
    input  int          delay,
    input  bit [32-1:0] addr,
    input  bit  [3-1:0] prot
  );
    for(int i=0; i<delay; i++) @(posedge intf.ACLK);
    intf.AWVALID <= 1'b1;
    intf.AWADDR  <= addr;
    intf.AWPROT  <= prot;
    @(posedge intf.ACLK);
    while (!intf.AWREADY) @(posedge intf.ACLK);
    intf.AWVALID <= 1'b0;
  endtask: AWTransaction
  
  task WTransaction (
    input  int          delay,
    input  bit [64-1:0] data,
    input  bit  [8-1:0] strb
  );
    for(int i=0; i<delay; i++) @(posedge intf.ACLK);
    intf.WVALID <= 1'b1;
    intf.WDATA  <= data;
    intf.WSTRB  <= strb;
    @(posedge intf.ACLK);
    while (!intf.WREADY) @(posedge intf.ACLK);
    intf.WVALID <= 1'b0;
  endtask: WTransaction
  
  task BTransaction (
    input  int         delay,
    output bit [2-1:0] resp
  );
    for(int i=0; i<delay; i++) @(posedge intf.ACLK);
    intf.BREADY <= 1'b1;
    while(!intf.BVALID) @(posedge intf.ACLK);
    resp = intf.BRESP;
    intf.BREADY <= 1'b0;
  endtask: BTransaction
  
  task ReadTransaction (
    input  bit [32-1:0] addr,
    input  bit  [3-1:0] prot,
    output bit [64-1:0] data,
    output bit  [3-1:0] resp
  );
    ARTransaction(ARDelay, addr, prot);
    RTransaction(RDelay, data, resp);
  endtask: ReadTransaction
  
  task WriteTransaction (
    input  bit [32-1:0] addr,
    input  bit  [3-1:0] prot,
    input  bit [64-1:0] data,
    input  bit  [8-1:0] strb,
    output bit  [2-1:0] resp
  );
    fork
      AWTransaction(AWDelay, addr, prot);
      WTransaction(WDelay, data, strb);
    join
    BTransaction(BDelay, resp);
  endtask: WriteTransaction
  
  always @(negedge intf.ARESETn or posedge intf.ACLK)
  begin
    if (!intf.ARESETn) begin
      intf.ARVALID <= 1'b0;
      intf.ARADDR  <= 32'b0;
      intf.ARPROT  <= 3'b0;
      intf.RREADY  <= 1'b0;
      intf.AWVALID <= 1'b0;
      intf.AWADDR  <= 32'b0;
      intf.AWPROT  <= 3'b0;
      intf.WVALID  <= 1'b0;
      intf.WDATA   <= {N{8'b0}};
      intf.WSTRB   <= {N{1'b0}};
      intf.BREADY  <= 1'b0;
    end
  end
endmodule: Axi4LiteMaster

module Axi4LiteSlave #(
  int unsigned N = 1,
  int unsigned I = 1,
  int unsigned SLAVE_ADDRESS = 0,
  int unsigned SLAVE_MEM_SIZE = 4096,
  int unsigned MEMORY_MODEL_MODE = 1
)(
  AXI4Lite intf
);
  int AWDelay;
  int WDelay ;
  int BDelay ;
  int ARDelay;
  int RDelay ;
  byte Mem[];

  task ARTransaction (
    input  int          delay,
    output bit [32-1:0] addr,
    output bit  [3-1:0] prot
  );
    for(int i=0; i<delay; i++) @(posedge intf.ACLK);
    intf.ARREADY <= 1'b1;
    while (!intf.ARVALID) @(posedge intf.ACLK);
    addr = intf.ARADDR;
    prot = intf.ARPROT;
    intf.ARREADY <= 1'b0;
  endtask: ARTransaction
  
  task RTransaction (
    input  int          delay,
    input  bit [64-1:0] data,
    input  bit  [3-1:0] resp
  );
    for(int i=0; i<delay; i++) @(posedge intf.ACLK);
    intf.RVALID <= 1'b1;
    intf.RDATA  <= data;
    intf.RRESP  <= resp;
    @(posedge intf.ACLK);
    while(!intf.RREADY) @(posedge intf.ACLK);
    intf.RVALID <= 1'b0;
  endtask: RTransaction

  task AWTransaction (
    input  int          delay,
    output bit [32-1:0] addr,
    output bit  [3-1:0] prot
  );
    for(int i=0; i<delay; i++) @(posedge intf.ACLK);
    intf.AWREADY <= 1'b1;
    while (!intf.AWVALID) @(posedge intf.ACLK);
    addr = intf.AWADDR;
    prot = intf.AWPROT;
    intf.AWREADY <= 1'b0;
  endtask: AWTransaction
  
  task WTransaction (
    input  int          delay,
    output bit [64-1:0] data,
    output bit  [8-1:0] strb
  );
    for(int i=0; i<delay; i++) @(posedge intf.ACLK);
    intf.WREADY <= 1'b1;
    while (!intf.WVALID) @(posedge intf.ACLK);
    data = intf.WDATA;
    strb = intf.WSTRB;
    intf.WREADY <= 1'b0;
  endtask: WTransaction
  
  task BTransaction (
    input  int          delay,
    input  bit  [2-1:0] resp
  );
    for(int i=0; i<delay; i++) @(posedge intf.ACLK);
    intf.BVALID <= 1'b1;
    intf.BRESP  <= resp;
    @(posedge intf.ACLK);
    while(!intf.BREADY) @(posedge intf.ACLK);
    intf.BVALID <= 1'b0;
  endtask: BTransaction
  
  task ReadRequest (
    output bit [32-1:0] addr,
    output bit  [3-1:0] prot
  );
    ARTransaction(ARDelay, addr, prot);
  endtask: ReadRequest
  
  task ReadResponse (
    input  bit [31-1:0] data,
    input  bit  [2-1:0] resp
  );
    RTransaction(RDelay, data, resp);
  endtask: ReadResponse
  
  task WriteRequest (
    output bit [32-1:0] addr,
    output bit  [3-1:0] prot,
    output bit [32-1:0] data,
    output bit  [4-1:0] strb
  );
    fork
      AWTransaction(AWDelay, addr, prot);
      WTransaction (WDelay , data, strb);
    join
  endtask: WriteRequest
  
  task WriteResponse (
    input  bit [2-1:0] resp
  );
    BTransaction(BDelay, resp);
  endtask: WriteResponse
  
  task RunReadLoop;
    logic [64-1:0] data;
    logic [32-1:0] addr;
    logic [32-1:0] offset;
    logic  [2-1:0] prot;
    $display("%t RunReadLoop before forever", $time);
    forever
    begin
      ARTransaction(ARDelay, addr, prot);
      offset = addr - SLAVE_ADDRESS;
      if (N==4)
        offset = offset & 32'hFFFFFFFC;
      else
        offset = offset & 32'hFFFFFFF8;
      if (offset < SLAVE_MEM_SIZE) begin
        if (N==4)
          data = {32'b0, 
                  Mem[offset+3], Mem[offset+2], Mem[offset+1], Mem[offset]};
        else
          data = {Mem[offset+7], Mem[offset+6], Mem[offset+5], Mem[offset+4],
                  Mem[offset+3], Mem[offset+2], Mem[offset+1], Mem[offset]};
        RTransaction(RDelay, data, `OKAY); 
      end else
        RTransaction(RDelay, 64'b0, `DECERR);
    end
  endtask: RunReadLoop
  
  task RunWriteLoop;
    logic [32-1:0] addr;
    logic  [2-1:0] prot;
    logic [64-1:0] data;
    logic  [8-1:0] strb;
    logic [32-1:0] offset;
    $display("%t RunWriteLoop before forever", $time);
    forever
    begin
      fork
        AWTransaction(AWDelay, addr, prot);
        WTransaction(WDelay, data, strb);
      join
      offset = addr - SLAVE_ADDRESS;
      if (N==4)
        offset = offset & 32'hFFFFFFFC;
      else
        offset = offset & 32'hFFFFFFF8;
      if (offset < SLAVE_MEM_SIZE) begin
        if (strb[0]) Mem[offset+0] = data[7:0];
        if (strb[1]) Mem[offset+1] = data[15:8];
        if (strb[2]) Mem[offset+2] = data[23:16];
        if (strb[3]) Mem[offset+3] = data[31:24];
        if (N==8) begin
          if (strb[4]) Mem[offset+4] = data[39:32];
          if (strb[5]) Mem[offset+5] = data[47:40];
          if (strb[6]) Mem[offset+6] = data[55:48];
          if (strb[7]) Mem[offset+7] = data[63:56];
        end
        BTransaction(BDelay, `OKAY); 
      end else
        BTransaction(BDelay, `DECERR);
    end
  endtask: RunWriteLoop

  initial
  begin
    if (MEMORY_MODEL_MODE == 1) begin
      Mem = new[SLAVE_MEM_SIZE];
      while(!intf.ARESETn) @(posedge intf.ACLK);
      $display("%t Before Fork", $time);
      fork
        RunReadLoop;
        RunWriteLoop;
      join_none
    end
  end

  always @(negedge intf.ARESETn or posedge intf.ACLK)
  begin
    if (!intf.ARESETn) begin
      intf.ARREADY <= 1'b0;
      intf.RVALID  <= 1'b0;
      intf.RDATA   <= {N{8'b0}};
      intf.RRESP   <= 2'b0;
      intf.AWREADY <= 1'b0;
      intf.WREADY  <= 1'b0;
      intf.BVALID  <= 1'b0;
      intf.BRESP   <= 2'b0;
    end
  end

endmodule: Axi4LiteSlave

module Axi4LiteMonitor #(
  int unsigned N = 1,
  int unsigned I = 1
)(
  AXI4Lite intf
);

  task run;
  endtask
  
endmodule: Axi4LiteMonitor
