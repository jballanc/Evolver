# Copyright (c) 2009 Joshua Ballanco
#
# class Environment
#
# Abstract: The Environment class "contains" the entire simulation. It is primarily responsible for tracking and
# distributing energy and nucleotide resources to the component organisms, reclaiming those same resources from dead
# organisms, and stepping each organism at each time step of the simulation.

require 'struct'

# The GenomeForEnvironment class is used to seed the starting population of the environment.
GenomeForEnvironment = Struct.new(
  :genome_sequence,       # The template sequence to base the genomes of the generated organisms off of.
  :mutation_frequency,    # The frequency, per nucleotide, of a random mutation during organism generation.
  :population_frequency   # The frequency of organims with this genome in the starting population.
)

class Environment
  # The Environment must be initialized with the size of the initial population, the number of nucleotides available in
  # the environment, the temperature of the simulation (in units of H-bond energy), and an array of structs describing
  # the genomes to be use in creating the initial organisms.
  def initialize(starting_population, max_population, temperature, *genomes_for_environment)

  # Populates the environment with organisms based on the template genome set during initialization
  def populate
    @organisms = (0..starting_population).collect {
      # -- TODO -- Need to initialize organisms with genomes and polymerases. We should just generate the polymerase
      # from the genome using the genome's _translate_polymerase_ function. The question is, how do we decide the genome
      # to start with? and how do we introduce variability in the polymerase directionality?
    }
  end

  def available_capacity?
    @current_population < @max_population
  end

  def add_organism(organism)
    if available_capacity?
      @organisms << organism
    else
      raise RuntimeError, "Trying to add an organism to a full environment"
    end
  end

end
