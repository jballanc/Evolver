# Copyright (c) 2009 Joshua Ballanco
#
# class Environment
#
# Abstract: The Environment class "contains" the entire simulation. It is primarily responsible for tracking and
# distributing energy and nucleotide resources to the component organisms, reclaiming those same resources from dead
# organisms, and stepping each organism at each time step of the simulation.

class Environment
  def initialize(starting_population, starting_nucleotides, starting_energy)
    # Populate the environment with organisms
    @organisms = (0..starting_population).collect {
      # -- TODO -- Need to initialize organisms with genomes and polymerases. We should just generate the polymerase
      # from the genome using the genome's _translate_polymerase_ function. The question is, how do we decide the genome
      # to start with? and how do we introduce variability in the polymerase directionality?
    }
  end
end
