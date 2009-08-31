# Copyright (c) 2009 Joshua Ballanco
#
# class Genome
#
# Abstract: The genome class comprises the genome of an organism. It is synthesized by a polymerase object, and
# when synthesis is complete, it will generate a new polymerase object.

class Genome
  attr_reader :length, :added_nucleotides, :errors

  def initialize(length, polymerase_fraction, polymerase_rate, directionality)
    @length = length
    @polymerase_fraction = polymerase_fraction
    @polymerase_rate = polymerase_rate
    @directionality = directionality
    @added_nucleotides = 0
    @errors = 0
  end

  def initialize_copy(orig)
    # From errors and polymerase_rate of orig, determine polymerase_rate
    polymerase_errors = @errors * @polymerase_fraction * # some fraction of errors will be silent
    
    @added_nucleotides = 0
    @errors = 0
  end

  def reset
    @added_nucleotides = 0
    @errors = 0
  end
  
  def add_nucleotide(correct?)
    @errors += 1 unless correct?
    @added_nucleotides += 1
  end

  def translate_polymerase(temperature)
    Polymerase.new(self, @directionality, @polymerase_rate, temperature)
  end

  def viable?
    # -- TODO -- Need to check if this genome is within allowable bounds for life
    # Proteins can tolerate ~34% AA errors...assume compact genome, correct for nucleotide -> AA errors
  end
end

# vim:sw=2 ts=2 tw=114:wrap
