
class Layout
  module Tags

    ##
    # A virtual tag that is rendered as an icon link.
    #
    # === Configuration ===
    # Configured by a Hash, supporting the following keys, as well as the
    # options supported by the A tag (except for label, which is ignored).
    # [:type]
    #     The icon type. Its _to_s_ representation is interpolated into the
    #     link's class attribute.

    class Icon < Layout::Tags::A

      ##
      # Reader for the icon type.

      attr_reader :type

      def initialize(context, config)
        @type = config[:type]
        super
      end

      def attributes(params = {})
        super(params.merge(class: join_values(:icon, type, params[:class])))
      end

      def to_s(**attributes)
        super('', **attributes)
      end

    end
  end
end
