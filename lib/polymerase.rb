# Copyright (c) 2009 Joshua Ballanco
#
# class Polymerase
#
# Abstract: The polymerase class describes a generic nucleotide polymerase. When asked to, it will add a number of
# new nucleotides to the nascient genome. The directionality of insertion depends on the directionality that the
# polymerase was initialized with. Each polymerase will always be in one of two states:
#   -- polymerizing:  The genome is not yet finished.
#   -- finished:      The genome has been completely replicated.

class Polymerase
  # The current status of the polymerase:
  attr_reader :status

  def initialize(genome, directionality, rate, temperature)
    @status = :polymerizing
    @genome = genome
    @directionality = directionality
    @rate = rate
    @temperature = temperature
  end

  def add_nucleotides
    if @genome.added_nucleotides > @genome.length
      @status = :finished
      return
    end
    # -- TODO -- Depending on the polymerase speed, add a number of nucleotides. Depending on directionality, if
    # the nucleotide about to be added is not activated, then we should stop. There is also a random chance,
    # depending on temperature of the environment, that we will incorporate an incorrect nucleotide.
    @rate.times do
      if #probability that nucleotide is deactivated
        next if @directionality == :forward
        return if @directionality == :reverse
      else
        @genome.add_nucleotide(#probability that wrong nucleotide is incorporated)
      end
    end
  end

  # If we're done polymerizing and the genome that we've produced is viable, then return the genome. Otherwise,
  # return +nil+
  def new_finished_genome
    if @status == :finished && @genome.viable?
      @genome
    else
      return nil
    end
  end

  # Resets the polymerase back to starting with a fresh genome to start polymerizing anew.
  def reset
    @genome.reset
    @status = :polymerizing
  end
end

# vim:sw=2 ts=2 tw=114:wrap
