# Copyright (c) 2009 Joshua Ballanco
#
# class Polymerase
#
# Abstract: The polymerase class describes a generic nucleotide polymerase. When asked to, it will add a number of new
# nucleotides to a nascent genome based off of a template genome that is passed in during creation.

class Polymerase
  def initialize
    @template = template
    @product = Genome.new
  end
end
