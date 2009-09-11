# Copyright (c) 2009 Joshua Ballanco
#
# class Genome
#
# Abstract: The genome class comprises the genome of an organism. It is
# initialized with a length and some information about the sort of polymerase
# enzyme that it codes for. As it is copied (by a polymerase), it tracks
# progress and a count of the errors made. When requested, the genome can
# generate a polymerase or a copy of itself.

class Genome
  attr_reader :length, :added_nucleotides, :errors

  # Initialization requires the length of the genome as well as the rate and
  # directionality of the polymerase coded for by the genome.
  def initialize(length, polymerase_rate, directionality)
    @length = length
    @polymerase_rate = polymerase_rate
    @directionality = directionality
    @added_nucleotides = 0
    @errors = 0
  end

  # This method gets called during a Genome#dup. The length of the original is
  # left unchanged, but the properties of the polymerase generated are
  # recalculated based on how much mutation there was during replication.
  def initialize_copy(orig)
    high_dev = MAX_POLY_RATE - @polymerase_rate
    low_dev = @polymerase_rate - MIN_POLY_RATE
    max_dev = (MAX_POLY_RATE - MIN_POLY_RATE) / 2.0
    mut_frac = (@errors / @length.to_f) / MAX_TOL_MUT_RATE
    change_in_rate = (mut_frac * mut_frac).round

    if change_in_rate > high_dev
      @polymerase_rate -= change_in_rate
    elsif change_in_rate > low_dev
      @polymerase_rate += change_in_rate
    elsif rand(2) == 0
      @polymerase_rate -= change_in_rate
    else
      @polymerase_rate += change_in_rate
    end
    
    if (@polymerase_rate > MAX_POLY_RATE || @polymerase_rate < MIN_POLY_RATE)
      raise RuntimeError, "Polymerase Rate out of Bounds"
    end

    # At the end, we reset @added_nucleotides and @errors to 0
    self.reset
  end

  # Start over replicating the genome (i.e. if an unviable copy was made and
  # discarded).
  def reset
    @added_nucleotides = 0
    @errors = 0
  end
  
  # Add a new nucleotide to the genome replica. If there was an erroneous
  # inclusion, add to the number of errors as well.
  def add_nucleotide(error = false)
    @errors += 1 if error
    @added_nucleotides += 1
  end

  # Seed a new polymerase with the directionality and rate defined by this
  # genome.
  def translate_polymerase(temperature)
    Polymerase.new(self, @directionality, @polymerase_rate, temperature)
  end

  # The organism can tolerate up to 1/3 of its nucleotides being mutated. It
  # would also not be viable if it wasn't finished being duplicated.
  def viable?
    if @added_nucleotides >= @length && @errors < (MAX_TOL_MUT_RATE * @length)
      true
    else
      false
    end
  end

  # The report method returns a hash of properties about the genome
  def report
    { :length => @length,
      :added_nucleotides => @added_nucleotides,
      :errors => @errors }
  end
end

# vim:sw=2 ts=2 tw=78:wrap
