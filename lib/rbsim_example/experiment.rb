class Experiment < RBSim::Experiment

  def print_req_times_for(server)
    app_stats.durations(server: server) do |tags, start, stop| 
      puts "Request time #{(stop - start).in_miliseconds} ms. "
    end
  end

  def mean_req_time_for(server)
    req_times = app_stats.durations(server: server).to_a
    sum = req_times.reduce(0) do |acc, data|
      _, start, stop = *data
      acc + stop - start
    end
    sum / req_times.size
  end

end
