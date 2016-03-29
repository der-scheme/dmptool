
module Layout
  def self.header
    @@header ||= Header.new(Rails.configuration.layout[:header])
  end

  def self.footer
    @@footer ||= Footer.new(Rails.configuration.layout[:footer])
  end
end
