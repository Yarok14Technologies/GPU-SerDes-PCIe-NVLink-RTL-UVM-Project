`ifndef BER_STRESS_SEQ_SV
`define BER_STRESS_SEQ_SV

class ber_stress_seq extends uvm_sequence #(serdes_item);

  `uvm_object_utils(ber_stress_seq)

  // Tunable parameters for stress
  real ber_level;        // Bit Error Rate
  int  num_packets;
  int  retrain_after_err;

  function new(string name = "ber_stress_seq");
    super.new(name);
    ber_level = 1e-6;      // exaggerated for simulation
    num_packets = 1000;
    retrain_after_err = 1; // trigger retrain on error
  endfunction

  task body();
    serdes_item item;
    int pkt_cnt;
    int err_cnt = 0;

    `uvm_info(get_type_name(),
      $sformatf("Starting BER stress: BER=%0e, packets=%0d",
                 ber_level, num_packets), UVM_MEDIUM);

    for (pkt_cnt = 0; pkt_cnt < num_packets; pkt_cnt++) begin

      item = serdes_item::type_id::create("item");

      start_item(item);

      // Generate random serial bit
      item.serial_bit = $urandom_range(0,1);

      // Probabilistic BER injection (flip bit)
      if ($urandom_real() < ber_level) begin
        item.serial_bit = ~item.serial_bit;
        err_cnt++;
        `uvm_warning(get_type_name(),
          $sformatf("Injected BER at packet %0d", pkt_cnt));

        if (retrain_after_err) begin
          `uvm_info(get_type_name(),
            "Triggering retrain due to BER", UVM_LOW);
          // You can connect this to DUT/LTSSM via config DB or TLM port
        end
      end

      finish_item(item);

      // Small inter-packet delay (helps waveform readability)
      #10;
    end

    `uvm_info(get_type_name(),
      $sformatf("BER stress complete. Total errors=%0d", err_cnt),
      UVM_MEDIUM);
  endtask

endclass

`endif
