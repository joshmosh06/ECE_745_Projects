//------------------------------------------------------------------------------
//
//  Description: wb transaction class
//
//
//  Joshua Hofmann
//  North Carolina State University
//  3/9/2020
//  Built with ModelSim 10.6c
//------------------------------------------------------------------------------
class wb_transaction extends ncsu_transaction;
  bit [WB_SLAVE_ADDR_SIZE-1:0] address;
  bit rw; // low for write High for read
  bit [WB_BYTE_SIZE-1:0] data;
  int bus_num;

  function new(string name="",
               bit [WB_SLAVE_ADDR_SIZE-1:0] address = 0,
               bit rw = 0, 
               int bus_num = 0
               ); 
    super.new(name);
    this.address = address;
    this.rw = rw;
    this.bus_num = bus_num;
  endfunction

  virtual function string convert2string();
    return {super.convert2string(),$sformatf("address:0x%x rw:%x data:0x%x ", address, rw, data)};
  endfunction

  virtual function void add_to_wave(int transaction_viewing_stream_h);
     super.add_to_wave(transaction_viewing_stream_h);
     $add_attribute(transaction_view_h,address,"address");
     $add_attribute(transaction_view_h,rw,"rw");
     //$add_attribute(transaction_view_h,data,"data");
     $end_transaction(transaction_view_h,end_time);
     $free_transaction(transaction_view_h);
  endfunction

endclass : wb_transaction