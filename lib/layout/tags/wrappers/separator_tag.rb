
class Layout
  module Tags
    module Wrappers

      ##
      # A decorator that, if being the second argument of a concatenation by
      # addition, inserts the #spacer String between the two elements.

      class SeparatorTag < Layout::Tags::Wrappers::Base

        ##
        # Reader for the spacer String.

        attr_reader :spacer

        ##
        # :call-seq: new(tag, spacer)
        #--
        # We need the dummy double-splat parameter, as rails was producing
        # errors without it.

        def initialize(tag, spacer, **_)
          @spacer = spacer
          super(tag)
        end

        def append_to(other)
          other.to_s + @spacer + @tag.to_s
        end

      end
    end
  end
end
