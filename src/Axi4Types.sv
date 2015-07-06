package pkg_Axi4Types;

class ABeat #(int N=1, int I=1);
  bit  [I-1:0] id    ;
  bit [32-1:0] addr  ;
  bit  [4-1:0] region;
  bit  [8-1:0] len   ;
  bit  [3-1:0] size  ;
  bit  [2-1:0] burst ;
  bit          lock  ;
  bit  [4-1:0] cache ;
  bit  [3-1:0] prot  ;
  bit  [4-1:0] qos   ;
endclass: ABeat

class BBeat #(int I=1);
  bit [I-1:0] id  ;
  bit [2-1:0] resp;  
endclass: BBeat

class RBeat #(int N=1, int I=1);
  bit   [I-1:0] id  ;
  bit [8*N-1:0] data;
  bit   [2-1:0] resp;
  bit           last;
endclass: RBeat

class WBeat #(int N=1);
  bit [8*N-1:0] data;
  bit   [N-1:0] strb;
  bit           last;
endclass: WBeat

endpackage: pkg_Axi4Types
