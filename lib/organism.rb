# Copyright (c) 2009 Joshua Ballanco
#
# class Organism
#
# Abstract: This is the base class for evolving organisms. It represents an abstract organism which is replicating
# its genome using a DNA polymerase and, when finished making the copy, replicating into two new organims.
#
# The Organism class is implemented as a finite state machine with the following states:
#   -- replicate_genome:  The organism is synthesizing a new genome using its existing genome as a template
#   -- divide:            Split into two, adding a new organism to the environment

class Organism
  # Initialization consists of setting the genome, polymerase to use to replicate that genome, and passing in a
  # reference to the environment in which this organism lives.
  def initialize(genome, environment)
    @genome = genome
    @polymerase = @genome.translate_polymerase
    @environment = environment

    # We'll start with replicating the genome:
    @next_step = method(:replicate_genome).to_proc
    return self
  end

  # Step this organism.
  def step(p_death = 0.0)
    # There is a random chance that this organism will die due to resource constraints
    if rand < p_death
      return nil
    else
      @next_step = @next_step.call
      return self
    end
  end

  # We're in the middle of creating a new genome. To do this, we allow the polymerase to add as many nucleotides
  # as it will. Following that, we query the polymerase as to its current status, and proceed based on that
  # information.
  def replicate_genome
    @polymerase.add_nucleotides
    case @polymerase.status
    when :polymerizing
      return method(:replicate_genome).to_proc
    when :done
      return method(:divide).to_proc
    end
  end

  # Once our polymerase is done synthesizing the new genome, we can create a new organism with it. Before that,
  # though, we must first check to see if the environment has available carrying capacity.
  def divide
    new_genome = @polymerase.new_finished_genome
    if @environment.available_capacity?
      if new_genome.viable?
        new_organism = Organism.new(new_genome, @environment)
        @environment.add_organism(new_organism)
      end
      @polymerase.restart
      return method(:replicate_genome).to_proc
    end
    return method(:divide).to_proc
  end
end

# vim:sw=2 ts=2 tw=114:wrap
