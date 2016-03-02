
require 'layout/tags/base'

module Layout
  module Tags
    module Wrappers
      class Base < Layout::Tags::Base

        delegate :to_s, to: :@tag

        def initialize(tag)
          @tag = tag
        end

        def append_to(other)
          other.to_s + @tag.to_s
        end

      end
    end
  end
end
