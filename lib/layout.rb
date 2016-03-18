
require 'layout/footer'
require 'layout/header'
require 'layout/tags'

module Layout
  def self.configure(config)
    @@header = Header.new(config[:header])
    @@footer = Footer.new(config[:footer])
  end

  def self.header
    @@header
  end

  def self.footer
    @@footer
  end
end
