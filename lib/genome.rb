# Copyright (c) 2009 Joshua Ballanco
#
# class Genome
#
# Abstract: The genome class comprises the genome of an organism. It is synthesized by a polymerase object, and
# when synthesis is complete, it will generate a new polymerase object.

class Genome
  def initialize
    # As a simplification, we only store the sequence of one strand of the genome. This is valid because we are
    # going to assume a standard leading-strand/lagging-strand replication fork, and we will also assume that the
    # polymerase doing each is identical to the other.
    @sequence = Array.new
  end
  
  def synthesize_nucleotide(nucleotide)
    @sequence.push nucleotide
  end
  
  def translate_polymerase
    # -- TODO -- Here we need logic on how to determine properties of the polymerase produced from features of the
    # genome. We'll base these features off of a reference sequence.
  end

  def viable?
    # -- TODO -- Need to check if this genome is within allowable bounds for life
  end
end

# vim:sw=2 ts=2 tw=114:wrap
