# Copyright (c) 2009 Joshua Ballanco
#
# class Environment
#
# Abstract: The Environment class contains the entire simulation. It is
# primarily responsible for tracking all of the organisms in the simulation,
# calculating the density dependent death probability, randomly culling
# organisms according to that probability, and stepping each organism at each
# time step of the simulation

# The GenomeForEnvironment struct is used to seed the starting population of
# the environment.
GenomeForSpecies = Struct.new(:genome, :population_frequency)

class Environment
  attr_reader :temperature

  # The Environment must be initialized with the temperature of the
  # simulation, the maximum and starting populations, and a GenomeForSpecies
  # array enumerating the genomes to be use in creating the initial organisms.
  def initialize(temperature,
                 max_population,
                 starting_population,
                 *genomes_for_environment)

    # Some simple sanity checks on passed in arguments
    #unless genomes_for_environment.inject(0) {|total, gfe|
    #  Rational(total + Rational(gfe.population_frequency))
    #} == 1.0
    #  raise ArgumentError, "population frequencies of genomes must total 1"
    #end
    if starting_population > max_population
      raise ArgumentError, "The starting population must be less than the
                            maximum population"
    end

    # Set the environments parameters
    @temperature = temperature
    @max_population = max_population
    @organisms = []

    # Populate the environment
    genomes_for_environment.each do |genome_for_species|
      (starting_population * genome_for_species.population_frequency)
      .round.times do
        @organisms << Organism.new(genome_for_species.genome.dup, self)
      end
    end
  end

  # Runs the environment for iterations steps (default is 1000).
  def run(iterations=1000)
    iterations.times { step }
  end

  # Step each organism, then calculate the culling probability based on the
  # current population as a fraction the maximum population. The probability
  # is calculated as $\frac{1}{(N-n)+1}$ where $N$ is the maximum population
  # of the environment and $n$ is the current number of organisms in the
  # environment. This probability is applied itteratively until no organism is
  # culled.
  def step
    @organisms.each(&:step)

    while (rand < (1.0 / ((@max_population - @organisms.length) + 1)))
      @organisms.delete_at(rand(@organisms.length))
    end
  end

  # The add_organism method attempts to add an organism to the environment.
  # If there adequate capacity, the organism is added and the method returns
  # true. If the environment is currently full, then nothing is done and
  # the method returns false.
  def add_organism(organism)
    if @organisms.length < @max_population
      @organisms << organism
      return true
    else
      return false
    end
  end

  # The report method returns a hash containing the values for this
  # environment as well as the results of iterating over the @organisms
  # array and calling each organism's report method in turn.
  def report
    { :temperature => @temperature,
      :max_population => @max_population,
      :current_population => @organisms.length,
      :organisms => @organisms.collect{|organism| organism.report}
    }
  end
end
