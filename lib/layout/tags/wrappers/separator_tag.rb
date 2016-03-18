
require 'layout/tags/wrappers/base'

module Layout
  module Tags
    module Wrappers
      class SeparatorTag < Base

        attr_reader :spacer

        ##
        # :call-seq: new(tag, spacer)

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
