# Copyright (c) 2009-2011 Joshua Ballanco
#
# class Genome
#
# Abstract: The genome class comprises the genome of an organism. It is
# initialized with a length and some information about the sort of polymerase
# enzyme that it codes for. As it is copied (by a polymerase), it tracks
# progress and a count of the errors made. When requested, the genome can
# generate a polymerase or a copy of itself.

class Genome
  attr_reader :length, :errors
  attr_accessor :added_nucleotides

  # Initialization requires the length of the genome as well as the rate and
  # directionality of the polymerase coded for by the genome.
  def initialize(length, polymerase_rate, directionality, mutable = true)
    @length = length
    @polymerase_rate = polymerase_rate
    @directionality = directionality
    @mutable = mutable
    @added_nucleotides = 0
    @errors = 0
  end

  # This method gets called during a Genome#dup. The length of the original is
  # left unchanged, but the properties of the polymerase generated are
  # recalculated based on how many mutations occurred during replication.
  def initialize_copy(orig)
    if @mutable
      high_dev = MAX_POLY_RATE - @polymerase_rate
      low_dev = @polymerase_rate - MIN_POLY_RATE
      max_dev = (MAX_POLY_RATE - MIN_POLY_RATE) / 2.0
      mut_frac = (@errors / @length.to_f) / MAX_TOL_MUT_RATE
      mut_frac = mut_frac > 1 ? 1 : mut_frac
      @change_in_rate = (mut_frac * max_dev).round

      if @change_in_rate > high_dev
        @polymerase_rate -= @change_in_rate
      elsif @change_in_rate > low_dev
        @polymerase_rate += @change_in_rate
      elsif rand(2) == 0
        @polymerase_rate -= @change_in_rate
      else
        @polymerase_rate += @change_in_rate
      end
    end

    if (@polymerase_rate > MAX_POLY_RATE || @polymerase_rate < MIN_POLY_RATE)
      raise RuntimeError, "Polymerase Rate out of Bounds"
    end

    # At the end, we reset @added_nucleotides and @errors to 0
    self.reset
  end

  # Start over replicating the genome (e.g. if an unviable copy was made and
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

  # This method returns the viability of the replica genome being created. The
  # genome is considered viable so long as the number of nucleotides added
  # meets or exceeds the length of the genome.
  def viable?
    if @added_nucleotides >= @length
      true
    else
      false
    end
  end

  # The report method returns a hash of properties about the genome
  def report
    { :length => @length,
      :change_in_rate => @change_in_rate,
      :added_nucleotides => @added_nucleotides,
      :errors => @errors }
  end
end
