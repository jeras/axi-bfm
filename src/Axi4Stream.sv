module Axi4StreamMaster #(
  int unsigned N = 1,
  int unsigned I = 1,
  int unsigned D = 1,
  int unsigned U = 1
)(
  AXI4Stream intf
);

  task SendTransfer (
    input bit [8*N-1:0] data,
    input bit   [N-1:0] strb,
    input bit   [N-1:0] keep,
    input bit   [I-1:0] id  ,
    input bit   [D-1:0] dest,
    input bit   [U-1:0] user,
    input bit           last
  );
    intf.TVALID <= 1'b1;
    intf.TDATA <= data;
    intf.TSTRB <= strb;
    intf.TKEEP <= keep;
    intf.TID   <= id  ;
    intf.TDEST <= dest;
    intf.TUSER <= user;
    intf.TLAST <= last;
    @(posedge intf.ACLK);
    while (!intf.TREADY) @(posedge intf.ACLK);
    intf.TVALID <= 1'b0;
  endtask: SendTransfer
  
  task SendPacket (
    input byte        data[],
    input bit         strb[],
    input bit         keep[],
    input bit [I-1:0] id  ,
    input bit [D-1:0] dest,
    input bit [U-1:0] user,
    input int         length
  );
    bit [N-1:0][8-1:0] data_t;
    bit [N-1:0]        strb_t;
    bit [N-1:0]        keep_t;
    bit                last_t;
    for (int i=0; i<length/N; i++) begin
      for (int j=0; j<N; j++) begin
        data_t[j] = data[i*N+j];
        strb_t[j] = strb[i*N+j];
        keep_t[j] = keep[i*N+j];
      end
      last_t = (i== (length/N -1));
      SendTransfer(data_t, strb_t, keep_t, id, dest, user, last_t);
    end
  endtask: SendPacket
  
  task SendRandomPacket (
    input int length
  );
    byte        data[];
    bit         strb[];
    bit         keep[];
    bit [I-1:0] id  ;
    bit [D-1:0] dest;
    bit [U-1:0] user;
    data = new[length];
    strb = new[length];
    keep = new[length];
    for(int i=0; i<length; i++) begin
      data[i] = $random;
      strb[i] = $random;
      keep[i] = $random;
    end
    id   = $random();
    dest = $random();
    user = $random();
    SendPacket(data, strb, keep, id, dest, user, length);
    data.delete();
    strb.delete();
    keep.delete();
  endtask: SendRandomPacket

  always @(negedge intf.ARESETn or posedge intf.ACLK)
  begin
    if (!intf.ARESETn) begin
      intf.TVALID <= 1'b0;
      intf.TDATA  <= {N{8'b0}};
      intf.TSTRB  <= {N{1'b0}};
      intf.TKEEP  <= {N{1'b0}};
      intf.TLAST  <= 1'b0;
      intf.TID    <= {I{1'b0}};
      intf.TDEST  <= {D{1'b0}};
      intf.TUSER  <= {U{1'b0}};
    end
  end
endmodule: Axi4StreamMaster

module Axi4StreamSlave #(
  int unsigned N = 1,
  int unsigned I = 1,
  int unsigned D = 1,
  int unsigned U = 1
)(
  AXI4Stream intf
);

  task ReceiveTransfer (
    output [8*N-1:0] data,
    output   [N-1:0] strb,
    output   [N-1:0] keep,
    output   [I-1:0] id  ,
    output   [D-1:0] dest,
    output   [U-1:0] user,
    output           last
  );
    intf.TREADY <= 1'b1;
    while (!intf.TVALID) @(posedge intf.ACLK);
    data = intf.TDATA;
    strb = intf.TSTRB;
    keep = intf.TKEEP;
    id   = intf.TID  ;
    dest = intf.TDEST;
    user = intf.TUSER;
    last = intf.TLAST;
    intf.TREADY <= 1'b0;
  endtask: ReceiveTransfer
  
  task ReceivePacket (
    output byte        data[],
    output bit         strb[],
    output bit         keep[],
    output bit [I-1:0] id  ,
    output bit [D-1:0] dest,
    output bit [U-1:0] user,
    output int         length
  );
  endtask: ReceivePacket
  
  task Receive;
    intf.TREADY <= 1'b1;
  endtask: Receive
 
  always @(negedge intf.ARESETn or posedge intf.ACLK)
  begin
    if (!intf.ARESETn)
      intf.TREADY <= 1'b1;
  end

endmodule: Axi4StreamSlave

  
module Axi4StreamMonitor #(
  int unsigned N = 1,
  int unsigned I = 1,
  int unsigned D = 1,
  int unsigned U = 1
)(
  AXI4Stream intf
);

endmodule: Axi4StreamMonitor
