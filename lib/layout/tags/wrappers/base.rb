
class Layout
  module Tags
    module Wrappers

      ##
      # A decorator class for other tags.

      class Base < Layout::Tags::Base

        delegate :context, to: :@tag
        delegate :if, to: :@tag
        delegate :render?, to: :@tag
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
