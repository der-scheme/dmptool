
##
# The Layout module provides an interface for an operator-defined layout
# configuration, allowing a different header/footer per instance of this app.
#
# === Configuration ===
# Configured by a Hash, supporting the following keys.
# [:footer]
#     The Layout::Footer configuration.
# [:header]
#     The Layout::Header configuration.

module Layout

  ##
  # Returns the page Header.

  def self.header
    @@header ||= Header.new(Rails.configuration.layout[:header])
  end

  ##
  # Returns the page Footer.

  def self.footer
    @@footer ||= Footer.new(Rails.configuration.layout[:footer])
  end
end
