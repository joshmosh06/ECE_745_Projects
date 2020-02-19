//------------------------------------------------------------------------------
//
//  Description: I2c Slave interface that impments I2C functionality
//
//
//  Joshua Hofmann
//  North Carolina State University
//  1/29/2020
//  Built with ModelSim 10.6c
//------------------------------------------------------------------------------
import i2c_op::*;

interface automatic i2c_if (
  // System signals
  input wire rst_i,
  // Slave signals
  input wire scl,
  input wire sda,
  output wire sda_o
  );
  //paramenters

  bit setSDA = 0;
  bit sda_val = 1;
  bit repeated_start = 0;

  //reset interface
  always @ (negedge rst_i or posedge rst_i) begin
    setSDA = 0;
    sda_val = 1;
    repeated_start = 0;
  end

  //******************************************************************************
  //
  //  wait_for_i2c_transfer()
  //  Description: Waits for i2c transfer to begin and captures write data if
  //               write is occuring otheriwse returns immeditely with read/write bit set
  //
  //******************************************************************************
  task wait_for_i2c_transfer (
    output i2c_op_t	op,
    output bit [I2C_BYTE_SIZE-1:0]	write_data []
    );
    op.rw = 0;
    op.address = 0;

    //Skip checking for start if repeated start
    if(!repeated_start) begin
      do begin
      @(negedge sda);
      end
      while(scl != 1'b1);
    end
     
    //Start Condition Met
    //Obtain slave address and rw data
    obtain_slave_address_and_RW(op.address,op.rw);

    //if write
    if(op.rw == 1'b0) begin
      aquire_data_from_bus(op.rw,1'b1, write_data);
    end
  endtask

  //******************************************************************************
  //
  //  aquire_data_from_bus()
  //  Description: snoops data from bus
  //
  //******************************************************************************
  task aquire_data_from_bus(
    input bit rw,
    input bit ACK,
    output bit [I2C_BYTE_SIZE-1:0]	data []
    );
    int j;
    int bytecount;
    bit stop;
    int data_position;
    bit [I2C_BYTE_SIZE-1:0]	temp_data [];
    j = 0;
    bytecount = 0;
    temp_data = new[bytecount+1] (temp_data);
    stop = 0;
    data_position = I2C_BYTE_SIZE-1;
    //Capture Bus data - MSB is transmitted First, ACK bit transmitted Every byte(8 bits)
    while(~stop) begin
      @(posedge scl) begin
          //Store Bus data , Increment bit counter
          temp_data[bytecount][data_position] = sda_val && sda;
          //move Position counter
          data_position--;
          j++;
          if(j % 8 == 0 && j != 0) begin
            //Acknowledge
            if(ACK) begin
              set_sda(1'b0);
            end
            else begin
              @(posedge scl) ;
              //wait a cycle for ACK
            end
            //reset bit counter to count for next byte
            bytecount++;
            data_position = I2C_BYTE_SIZE -1;
            //create new array of a larger size and copy elements from old array
            temp_data = new[bytecount+1] (temp_data);
            j = 0;
            end
      end
      check_for_stop(stop);
    end
    data = new[temp_data.size()-1];
    for(j = 0; j < temp_data.size()-1; j++) begin
      data[j] = temp_data[j];
    end
  endtask

  //******************************************************************************
  //
  //  check_for_stop()
  //  Description: Stop is set high if the stop condition is detected
  //               Repeated_start is set high if a repeated start condition is detected
  //
  //******************************************************************************
  task check_for_stop(
    output bit stop
    );
    //check for end
    @(negedge scl or posedge sda or negedge sda) begin
      if(scl && !setSDA) 
        //stop condition met (stop occured finished current operation)
        stop = 1'b1;
      else
        stop = 1'b0;
    end
  endtask

  always begin
    while(repeated_start == 1'b0) begin
    @ (negedge sda) 
      if(scl && !setSDA) begin
      //start condition met
      repeated_start = 1'b1;
      end
    end
    @ (posedge scl) 
    repeated_start = 1'b0;
  end

  //******************************************************************************
  //
  //  obtain_slave_address_and_RW()
  //  Description: Task that extracts Slave address and RW from sda line after strart condition detected
  //
  //******************************************************************************
  task obtain_slave_address_and_RW(
    output bit [I2C_SLAVE_ADDR_SIZE-1:0] address,
    output bit rw
    );
    int addr_pos;
    int i;
    rw = 0;
    address = 0;
    addr_pos = I2C_SLAVE_ADDR_SIZE-1;
    // byte size + 1 for ack bit
    for(i = I2C_BYTE_SIZE+1; i > 0; i--) begin
      @(posedge scl) begin
          if(i == 1) begin
            //set_sda(1'b0);
          end
          else if(i == 2) begin
            rw = sda;
          end
          else begin
            //address is MSB first
            address[addr_pos] = sda;
            addr_pos--;
            end
        end
     end
  endtask

  //******************************************************************************
  //
  //  provide_read_data()
  //  Description: Provide output from slave after read transcation is known
  //
  //******************************************************************************
  task provide_read_data (
    input	bit	[I2C_BYTE_SIZE-1:0]	read_data []
    );
    int i;
    int j;
    for(i = 0; i < read_data.size(); i++) begin
      for(j = I2C_BYTE_SIZE-1; j >= 0; j--) begin
        set_sda(read_data[i][j]);
      end
        @(posedge scl) begin
        //receive ACK from master
        // if(sda == 1'b0)
        //   //Acknowledged
        //   //$display("ACK");
        // else
        //   //not Acknowledged
        // //  $display("NACK");
        end
    end
  endtask

  //******************************************************************************
  //
  //  set_sda()
  //  Description: Temporarly drive the SDA line to provide data or
  //
  //******************************************************************************
  task set_sda(
    input bit val
    );
    sda_val = val;
    @(posedge scl) begin
      setSDA = 1;
      end
    @(negedge scl) begin
      setSDA = 0;
      sda_val = 1;
    end
  endtask

  //******************************************************************************
  //
  //  monitor()
  //  Description: Provides data Observed
  //
  //******************************************************************************
  task	monitor	(
    output bit	[I2C_SLAVE_ADDR_SIZE-1:0]		addr,
    output i2c_op_t	                    op,
    output bit	[I2C_BYTE_SIZE-1:0]	  data	[]
    );

    wait_for_i2c_transfer(.op(op), .write_data(data));
    addr = op.address;
    //if write wait_for_i2c_transfer will capture write data, else capture read data provided by slave here.
    if(op.rw == 1'b1) begin
      aquire_data_from_bus(op.rw,1'b0,data);
    end
  endtask

  assign sda_o = setSDA ? sda_val : 1'b1;
endinterface
