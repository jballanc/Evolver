# Copyright (c) 2009 Joshua Ballanco
#
# class Genome
#
# Abstract: The genome class comprises the genome of an organism. It is synthesized by a polymerase object, and
# when synthesis is complete, it will generate a new polymerase object.

class Genome
  attr_reader :length, :added_nucleotides, :errors

  def initialize(length, polymerase_rate, directionality)
    @length = length
    @polymerase_rate = polymerase_rate
    @directionality = directionality
    @added_nucleotides = 0
    @errors = 0
  end

  # Creates a new genome object from the replica synthesized off of this genome as a template. Properties are
  # determined by the properties of the replica.
  def initialize_copy(orig)
    high_deviation = MAX_POLY_RATE - @polymerase_rate
    low_deviation = @polymerase_rate - MIN_POLY_RATE
    rate_deviation = (high_deviation + low_deviation) / 2.0
    change_in_rate = (((@errors / @length.to_f) / MAX_TOL_MUT_RATE) * rate_deviation).round
    if change_in_rate > high_deviation
      @polymerase_rate -= change_in_rate
    elsif change_in_rate > low_deviation
      @polymerase_rate += change_in_rate
    elsif rand(2) == 0
      @polymerase_rate -= change_in_rate
    else
      @polymerase_rate += change_in_rate
    end 

    self.reset
  end

  # Start over replicating the genome (i.e. if an unviable copy was made and discarded).
  def reset
    @added_nucleotides = 0
    @errors = 0
  end
  
  # Add a new nucleotide to the genome replica. If there was an erroneous inclusion, add to the number of errors
  # as well.
  def add_nucleotide(error = false)
    @errors += 1 if error
    @added_nucleotides += 1
  end

  # Seed a new polymerase with the directionality and rate defined by this genome.
  def translate_polymerase(temperature)
    Polymerase.new(self, @directionality, @polymerase_rate, temperature)
  end

  # The organism can tolerate up to 1/3 of its nucleotides being mutated. It would also not be viable if it wasn't
  # finished being duplicated.
  def viable?
    if @added_nucleotides >= @length && @errors < (MAX_TOL_MUT_RATE * @length)
      true
    else
      false
    end
  end

  # The _report_ method returns a hash of properties about the genome
  def report
    { :length => @length,
      :added_nucleotides => @added_nucleotides,
      :errors => @errors }
  end
end

# vim:sw=2 ts=2 tw=114:wrap
