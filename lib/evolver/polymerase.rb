# Copyright (c) 2009 Joshua Ballanco
#
# class Polymerase
#
# Abstract: The polymerase class describes a generic nucleotide polymerase.
# When asked to, it will add a number of new nucleotides to the nascient
# genome. The directionality of insertion depends on the directionality that
# the polymerase was initialized with. Each polymerase will always be in one
# of two states:
#   -- polymerizing:  The genome is not yet finished.
#   -- finished:      The genome has been completely replicated.

class Polymerase
  attr_reader :status

  def initialize(genome, directionality, rate, temperature)
    @status = :polymerizing
    @genome = genome
    @directionality = directionality
    unless (@directionality == :forward || @directionality == :reverse)
      raise ArgumentError, "directionality must be :forward or :reverse"
    end
    @rate = rate
    @temperature = temperature
  end

  def add_nucleotides
    if @genome.added_nucleotides > @genome.length
      @status = :finished
      return
    end
    @rate.times do
      if (rand < Math::E**(-2.0 / @temperature))
        next if @directionality == :forward
        return if @directionality == :reverse
      else
        @genome.add_nucleotide(rand < Math::E**(-1.0 / @temperature))
      end
    end
  end

  # If we're done polymerizing and the genome that we've produced is viable,
  # then return the genome. Otherwise, return nil
  def new_finished_genome
    if @status == :finished && @genome.viable?
      @genome.dup
    else
      nil
    end
  end

  # Resets the polymerase back to starting with a fresh genome to start
  # polymerizing anew.
  def reset
    @genome.reset
    @status = :polymerizing
  end

  # The report method returns a hash of properties about the polymerase
  def report
    { :status => @status,
      :directionality => @directionality,
      :rate => @rate }
  end
end

# vim:sw=2 ts=2 tw=78:wrap
