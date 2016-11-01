
require 'delegate'

require_dependency 'layout'

class Layout::Config < SimpleDelegator
  class DefaultClass; end
  DEFAULT = DefaultClass.new
  private_constant :DefaultClass
  private_constant :DEFAULT

  class Defaults

    def initialize(defaults: {}, fallback: nil)
      @defaults = defaults
      @fallback = fallback
      fail "cannot fallback to itself" if fallback.__id__ == __id__
    end

    attr_accessor :defaults
    attr_accessor :fallback

    def [](key)
      fetch(key, nil)
    end

    def fetch(key, default = DEFAULT, &block)
      return defaults[key] if defaults.key?(key)
      return fallback.fetch(key, default, &block) if fallback
      return block.call(key) if block_given?
      return default unless default.is_a?(DefaultClass)

      fail KeyError, "key not found: #{key}"
    end

    ##
    # Returns +true+ if a default was defined for the +key+, +false+ otherwise.

    def key?(key)
      defaults.key?(key) || fallback && fallback.key?(key)
    end

    def merge(defaults, &block)
      dup.merge!(defaults)
    end

    def merge!(defaults, &block)
      if defaults.is_a?(Defaults)
        merge!(defaults.defaults)
      elsif defaults
        merge!(defaults, &block)
      end

      self
    end

  end

  include Enumerable

  def initialize(defaults: {}, **args)
    create_defaults(defaults)
    super(Hash.new {|hash, key| hash[key] = @defaults[key]})

    args.each_pair do |key, value|
      self[key] = recursive_build(value)
    end
  end

  def [](key)
    return super unless defaults.key?(key)
    defaults[key].call(self)
  end

  def each
    super
    self
  end

  def each_key
    super
    self
  end

  def each_pair
    super
    self
  end

  def each_value
    super
    self
  end

  def fetch(key, default = DEFAULT, &block)
    return super unless defaults.key?(key)
    defaults.fetch(key, default, &block).call(self)
  end

  def deep_merge(config)
    dup.deep_merge!(config)
  end

  def deep_merge!(config, &block)
    defaults.merge!(config.try(:defaults) || config[:defaults])
    config.each_pair do |key, other_value|
      this_value = self[key]

      self[key] = if this_value.respond_to?(:deep_merge) && other_value.respond_to?(:each_pair)
        this_value.deep_merge!(other_value, &block)
      elsif block_given? && key?(key)
        block.call(key, this_value, other_value)
      else
        recursive_build(other_value)
      end
    end
  end

  def values_at(*)
    super.map!{|value| value.is_a?(Proc) ? value.call(self) : value}
  end

protected

  alias_method :data, :__getobj__
  attr_reader :defaults

  def create_defaults(defaults)
    @defaults = build_defaults(defaults)
  end

private

  def build_config(config)
    (config.is_a?(self.class) ? config.dup : self.class.new(**config))
      .tap {|config| config.defaults.fallback = defaults}
  end

  def build_defaults(dflts)
    Defaults.new(defaults: dflts, fallback: defaults)
  end

  def recursive_build(value)
    case value
    when Hash, self.class
      build_config(value)
    when Enumerable
      value.map(&method(:recursive_build))
    else
      value
    end
  end

end
