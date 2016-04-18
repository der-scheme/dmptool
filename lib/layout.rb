
##
# The Layout class provides an interface for an operator-defined layout
# configuration, allowing a different header/footer per instance of this app.
#
# === Configuration ===
# Configured by a Hash, supporting the following keys.
# [:footer]
#     The Layout::Footer configuration.
# [:header]
#     The Layout::Header configuration.

class Layout

  ##
  # Reader for the page Header.

  attr_reader :header

  ##
  # Reader for the page Footer.

  attr_reader :footer

  def initialize(context)
    @header = Header.new(context, Rails.configuration.layout[:header])
    @footer = Footer.new(context, Rails.configuration.layout[:footer])
  end
end
