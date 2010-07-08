class Dayusagesummary < ActiveRecord::Base
    belongs_to :node
    belongs_to :slice

comma do
  slice_id
  node_id
  day
  nitems
  total_activity_minutes
  avg_cpu
  avg_send_BW
  avg_recv_BW
  total_cpu
  total_send_BW
  total_recv_BW
  max_cpu
  max_send_BW
  max_recv_BW
  number_of_samples
  avg_pctmem
  max_pctmem
  avg_phymem
  max_phymem
  avg_virmem
  max_virmem
  avg_procs
  max_procs
  avg_runprocs
  max_runprocs
end

end
