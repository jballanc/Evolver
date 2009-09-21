# Copyright (c) 2009 Joshua Ballanco
#
# class Environment
#
# Abstract: The Environment class contains the entire simulation. It is
# primarily responsible for tracking all of the organisms in the simulation,
# calculating the density dependent death probability, randomly culling
# organisms according to that probability, and stepping each organism at each
# time step of the simulation

# The GenomeForEnvironment class is used to seed the starting population of
# the environment.
GenomeForSpecies = Struct.new(:genome, :population_frequency)

class Environment
  attr_reader :temperature

  # The Environment must be initialized with the temperature of the simulation
  # (in units of h-bond energy), the maximum and starting populations, and a
  # GenomeForSpecies array enumerating the genomes to be use in creating the
  # initial organisms.
  def initialize(temperature,
                 max_population,
                 starting_population,
                 *genomes_for_environment)

    # Some simple sanity checks on passed in arguments
    unless genomes_for_environment.inject(0) {|total, gfe|
      Rational(total + Rational(gfe.population_frequency))
    } == 1.0
      raise ArgumentError, "population frequencies of genomes must total 1"
    end
    if starting_population > max_population
      raise ArgumentError, "The starting population must be less than the
                            maximum population"
    end

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

  # Set the number of threads to use, if we want to run the simulation
  # threaded.
  def use_threads(num_threads)
    @num_threads = num_threads
  end

  # Before stepping the environment, calculate the probability that any
  # individual organism will die due to resource constraints. This is modeled
  # as a agregate probability of $\frac{1}{(N-n)+1}$, evenly distributed over
  # the organisms in the environment, where $N$ is the carrying capacity of
  # the environment (max_population) and $n$ is the number of organisms
  # currently in the environment. At each step, determine whether or not to
  # cull an organism this round. If yes, then choose one to remove from the
  # environment at random.
  def step
    if (@num_threads && @num_threads > 1)
      @organisms.threadify(@num_threads) do |organism|
        organism.step
      end
    elsif RUBY_ENGINE =~ /macruby/
      @organisms.each do |organism|
        group = Dispatch::Group.new
        group.dispatch(Dispatch::Queue.concurrent) do
          organism.step
        end
      end
      group.wait
    else
      @organisms.each(&:step)
    end

    # This is the probability that 1 organism will die
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

# vim:sw=2 ts=2 tw=78:wrap
