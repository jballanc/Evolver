# Copyright (c) 2009 Joshua Ballanco
#
# class Environment
#
# Abstract: The Environment class "contains" the entire simulation. It is primarily responsible for tracking and
# distributing energy and nucleotide resources to the component organisms, reclaiming those same resources from dead
# organisms, and stepping each organism at each time step of the simulation.

require 'struct'

# The GenomeForEnvironment class is used to seed the starting population of the environment.
GenomeForSpecies = Struct.new(
  :genome,       # The template sequence to base the genomes of the generated organisms off of.
  :population_frequency   # The frequency of organims with this genome in the starting population.
)

class Environment
  # The _Environment_ must be initialized with the size of the initial population, the temperature of the simulation
  # (in units of h-bond energy), and an array of structs describing the genomes to be use in creating the initial
  # organisms.
  def initialize(temperature, max_population, starting_population, *genomes_for_environment)
    # the population frequency of all the genomes must add to 1
    unless genomes_for_environment.inject(0){|total, freq| total + freq} == 1
      raise argumenterror, "population frequencies of genomes must total 1"
    end

    if starting_population > max_population
      raise argumenterror, "the starting population must be less than the maximum population"
    end

    @max_population
    @temperature = temperature
    @organisms = []
    genomes_for_environment.each do |genome_for_species|
      (starting_population / genome_for_species.population_frequency).round.times do
        @organisms << Organism.new(genome_for_species.genome, self)
      end
    end
  end

  # Runs the environment for _max_iterations_ rounds (default is 1000).
  def run(max_iterations=1000)
    iteration = 0
    while iteration < max_iterations
      step
    end
  end

  # Each step of the environment involves three phases:
  #   1. Step each organism in the environment
  #   2. Randomly cull organisms to maintain population just below the _max_population_
  #   3. Remove dead organisms from the environment
  def step
    @organisms.each(&:step)
  end

  def add_organism(organism)
    if @current_population < @max_population
      @organisms << organism
      return true
    else
      return false
    end
  end

end

# vim:sw=2 ts=2 tw=120:wrap
