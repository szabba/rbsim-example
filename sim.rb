require 'rbsim_example'
require 'rbsim/numeric_units'

params = { }

sim = Experiment.new
sim.run './model/model.rb', params
sim.save_stats './stats/simulation.stats'

