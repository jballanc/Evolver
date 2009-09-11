# Copyright (c) 2009 Joshua Ballanco
#
# class Organism
#
# Abstract: This is the base class for evolving organisms. It represents an
# abstract organism which is replicating its genome using a DNA polymerase
# and, when finished making the copy, replicating into two new organims.
#
# The Organism class is implemented as a finite state machine with the
# following states:
#   -- replicate_genome:  The organism is synthesizing a new genome using its
#                         existing genome as a template
#   -- divide:            Split into two, adding a new organism to the
#                         environment (if capacity for it exists)

class Organism
  # Initialization consists of setting the genome, translating a polymerase
  # from that genome, and passing in a reference to the environment in which
  # this organism lives.
  def initialize(genome, environment)
    @genome = genome
    @environment = environment
    @polymerase = @genome.translate_polymerase(@environment.temperature)

    # We'll start with replicating the genome:
    @next_step = method(:replicate_genome).to_proc
  end

  # Step this organism and set the next step to the return value
  def step
    @next_step = @next_step.call
    return self
  end

  # We're in the middle of creating a new genome. To do this, we allow the
  # polymerase to add as many nucleotides as it will. Following that, we query
  # the polymerase as to its current status, and proceed based on that
  # information.
  def replicate_genome
    @polymerase.add_nucleotides
    case @polymerase.status
    when :polymerizing
      return method(:replicate_genome).to_proc
    when :finished
      return method(:divide).to_proc
    end
  end

  # In order to divide, we first extract the new genome. If the new genome has
  # too many errors, then we reset and try again. Then, we create a new organism
  # from the genome and attempt to insert it into the environment. If there is
  # no room, we keep trying until there is (or we are randomly killed). Once
  # we've put the new organism in the environment, reset and start replicating
  # again.
  def divide
    @new_genome ||= @polymerase.new_finished_genome
    unless @new_genome
      @polymerase.reset
      return method(:replicate_genome).to_proc
    end
    
    @new_organism ||= Organism.new(@new_genome, @environment)
    if @environment.add_organism(@new_organism)
      @new_genome = nil
      @new_organism = nil
      @polymerase.reset
      return method(:replicate_genome).to_proc
    end

    return method(:divide).to_proc
  end

  # The report method returns details about the organism's genome and
  # polymerase
  def report
    { :genome => @genome.report,
      :polymerase => @polymerase.report }
  end
end

# vim:sw=2 ts=2 tw=78:wrap
