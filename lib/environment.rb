# Copyright (c) 2009 Joshua Ballanco
#
# class Environment
#
# Abstract: The Environment class "contains" the entire simulation. It is primarily responsible for tracking and
# distributing energy and nucleotide resources to the component organisms, reclaiming those same resources from
# dead organisms, and stepping each organism at each time step of the simulation.

require 'struct'

# The GenomeForEnvironment class is used to seed the starting population of the environment.
GenomeForSpecies = Struct.new(
  :genome,       # The template sequence to base the genomes of the generated organisms off of.
  :population_frequency   # The frequency of organims with this genome in the starting population.
)

class Environment
  # The _Environment_ must be initialized with the size of the initial population, the temperature of the
  # simulation (in units of h-bond energy), and an array of structs describing the genomes to be use in creating
  # the initial organisms.
  def initialize(temperature, max_population, starting_population, *genomes_for_environment)
    # the population frequency of all the genomes must add to 1
    unless genomes_for_environment.inject(0){|total, freq| total + freq} == 1
      raise argumenterror, "population frequencies of genomes must total 1"
    end

    if starting_population > max_population
      raise argumenterror, "the starting population must be less than the maximum population"
    end

    @temperature = temperature
    @max_population = max_population
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

  # Before stepping the environment, calculate the probability that any individual organism will die due to
  # resource constraints. This is modeled as a agregate probability of $\frac{1}{(N-n)+1}$, evenly distributed
  # over the organisms in the environment, where $N$ is the carrying capacity of the environment
  # (_max_population_) and $n$ is the number of organisms currently in the environment. At each step, the
  # organism will either die and return nil or step and return self. At the end of stepping each organism, we
  # compact the array to remove dead organisms.
  def step
    p_death = (1 / ((@max_population - @organisms.length) + 1)) / @organisms.length
    @organisms.each do |organism|
      organism.step(p_death)
    end
    @organisms.compact!
  end

  def add_organism(organism)
    if @organisms.length < @max_population
      @organisms << organism
      return true
    else
      return false
    end
  end
end

# vim:sw=2 ts=2 tw=114:wrap
