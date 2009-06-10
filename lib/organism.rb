# Copyright (c) 2009 Joshua Ballanco
#
# class Organism
#
# Abstract: This is the base class for evolving organisms. It represents an abstract organism which is replicating its
# genome using a DNA polymerase and, when finished making the copy, replicating into two new organims.
#
# The Organism class is implemented as a finite state machine with the following states:
#   -- gather_resources:  The organism is obtaining what it needs for replication from the environment
#   -- replicate_genome:  The organism is synthesizing a new genome using its existing genome as a template
#   -- dividing:          Split into two, adding a new organism to the environment

class Organism
  # Need a way to determine if this organism is still alive.
  attr_accessor :alive

  # Initialization consists of setting the genome, polymerase to use to replicate that genome, and passing in a
  # reference to the environment in which this organism lives.
  def initialize(genome, polymerase, environment)
    @genome = genome
    @polymerase = polymerase
    @environment = environment
    @available_nucleotides = NucleotidePool.new
    @next_step = method(:gather_resources).to_proc
    @alive = true
    return self
  end

  # Step this organism.
  def step
    @next_step = @next_step.call
    return nil
  end

  def gather_resources
    until @available_nucleotides.quantity >= @genome.length
      if @environment.nucleotides_available?
        @available_nucleotides.add_nucleotides(@environment.gather_nucleotides)
      else
        return false
      end
    end
    return true
  end

  # -- TODO -- Rewrite below
  def add_next_nucleotide
    if @genome.next_position_primed?
      @polymerase.add_nucleotide_to(@genome,
                                    :at_position => @genome.next_nucleotide_position,
                                    :from_nucleotide_pool => self.available_nucleotides)
    end
  end

  def synthesize_dna
    until @genome.completed_duplication
      self.add_next_nucleotide
    end
  end

  def grow
    self.synthesize_dna
    Thread.new do
      if self.gather_resources
        self.grow
      else
        self.die
      end
    end
    return Oranism.new(@genome.copy, @genome.polymerase_gene_product, self.environment)
  end


  def die
    @dead = true
    @environment.return_nucleotides_from(self.genome)
  end
end
