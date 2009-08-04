# Copyright (c) 2009 Joshua Ballanco
#
# class Polymerase
#
# Abstract: The polymerase class describes a generic nucleotide polymerase. When asked to, it will add a number of new
# nucleotides to a nascent genome based off of a template genome that is passed in during creation.

class Polymerase
  # The current status of the polymerase:
  attr_reader :status

  def initialize
    @template = template
    @product = Genome.new
    @status = :polymerizing
  end

  def add_nucleotides
    # -- TODO -- Depending on the polymerase speed, add a number of nucleotides. Depending on directionality, if the
    # nucleotide about to be added is not activated, then we should stop. There is also a random chance, depending on
    # temperature of the environment, that we will incorporate an incorrect nucleotide.
  end

  # Returns the product genome, assuming it's already complete. If the genome is not finished, throws an error.
  def new_finished_genome
    if @status == :finished
      return @product
    else
      return nil
    end
  end

  # Once we're done, and we've retrieved the new genome, we can start again.
  def restart
    @product = Genome.new
    @status = :polymerizing
  end
end

# vim:sw=2 ts=2 tw=120:wrap
