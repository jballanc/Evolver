#!/usr/bin/env ruby1.9

Dir.glob("./*_sum*").each do |file|
  type = file[/cluster_test_(.*)_out_sum.csv/,1]
  outfile = file.gsub('sum','avg')
  File.open(outfile,'w') do |out|
    out << "#{type}_forward_num_avg,#{type}_forward_rate_avg,#{type}_reverse_num_avg,#{type}_reverse_rate_avg,#{type}_organism_num_avg,#{type}_organism_rate_avg\n"
    File.open(file, 'r') do |infile|
      infile.each do |line|
        unless line =~ /forward/
          values = line.split(',').map(&:to_f)
          (0..17).each{|i| values[i] ||= 0.0}
          out << "#{(values[0] + values[6] + values[12]) / 3},#{(values[2] + values[8] + values[14]) / 3},#{(values[1] + values[7] + values[13]) / 3},#{(values[3] + values[9] + values[15]) / 3},#{(values[4] + values[10] + values[16]) / 3},#{(values[5] + values[11] + values[17]) / 3}\n"
        end
      end
    end
  end
end
