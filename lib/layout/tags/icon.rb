
require 'layout/tags/a'

module Layout
  module Tags
    class Icon < A
      def self.separator
        ActiveSupport::SafeBuffer.new
      end

      attr_reader :type

      def initialize(config)
        @type = config[:type]
        super(config)
      end

      def to_s(**attributes)
        super('', class: "icon #{@type}")
      end
    end
  end
end
