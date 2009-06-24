class Dayusage < ActiveRecord::Base
    belongs_to :node
    belongs_to :slice
    def avg_send_BW 
      "%.2f" %  read_attribute(:avg_send_BW ) 
    end
    def avg_recv_BW 
      "%.2f" %  read_attribute(:avg_recv_BW  ) 
    end
    def avg_cpu 
      "%.2f" %  read_attribute(:avg_cpu  ) 
    end

    # return the total potential CPU hours for the last 24 hours
    # active nodes * 24
    # we assume that all nodes have one CPU
    def Dayusage.day_potential_cpu
      return 24 * Node.count(:conditions => "online = 1")
    end

    # return the time since yesterday
    def Dayusage.day_time_period
      result = Dayusage.find_by_sql("select date_format(now(), '%T') as period");
      return result[0].period
    end

    # return the total number of CPU hours used in the last 24 hours
    def Dayusage.day_cpu_usage
      result = Dayusage.find_by_sql("select sum(total_activity_minutes)*sum(total_cpu)/sum(number_of_samples)/100/60 as total_cpu from dayusages where day > date_sub(now(), interval 1 day)")
      return result[0].total_cpu
    end

    # return the total number of gigbytes sent in the last 24 hours
    def Dayusage.day_send_GB_usage
      result = Dayusage.find_by_sql("select 60*sum(total_activity_minutes)*sum(total_send_BW)/sum(number_of_samples)/8 as total_send_BW from dayusages where day > date_sub(now(), interval 1 day)")
      # Bytes to GB conversion 
      return result[0].total_send_BW / 1073741824
    end

    # return the total number of gigbytes received in the last 24 hours
    def Dayusage.day_recv_GB_usage
      result = Dayusage.find_by_sql("select 60*sum(total_activity_minutes)*sum(total_recv_BW)/sum(number_of_samples)/8 as total_recv_BW from dayusages where day > date_sub(now(), interval 1 day)")
      # Bytes to GB conversion 
      return result[0].total_recv_BW / 1073741824
    end

end
