module Capybara
  class Query
    attr_accessor :selector, :locator, :options, :find, :negative

    VALID_KEYS = [:text, :visible, :between, :count, :maximum, :minimum]

    def initialize(*args)
      @options = if args.last.is_a?(Hash) then args.pop.dup else {} end

      unless options.has_key?(:visible)
        @options[:visible] = Capybara.ignore_hidden_elements
      end

      key = args[0].is_a?(Symbol) ? args.shift : Capybara.default_selector
      @selector = Selector.all[key]
      @locator = args

      assert_valid_keys!
    end

    def has_locator?
      @locator.any?
    end

    def xpath use_locators=true
      args = use_locators ? @locator : []
      @selector.call(*args).to_s
    end

    def name; selector.name; end
    def label; selector.label or selector.name; end

    def description
      @description = "#{label} #{locator.map(&:to_s).join}"
      @description << " with text #{options[:text].inspect}" if options[:text]
      @description
    end

    def matches_filters?(node)
      if options[:text]
        regexp = options[:text].is_a?(Regexp) ? options[:text] : Regexp.escape(options[:text])
        return false if not node.text.match(regexp)
      end
      return false if options[:visible] and not node.visible?
      selector.custom_filters.each do |name, block|
        return false if options.has_key?(name) and not block.call(node, options[name])
      end
      true
    end

    def matches_count?(count)
      case
      when count.zero?
        false
      when options[:between]
        options[:between] === count
      when options[:count]
        options[:count].to_i == count
      when options[:maximum]
        options[:maximum].to_i >= count
      when options[:minimum]
        options[:minimum].to_i <= count
      else
        count > 0
      end
    end

  private

    def assert_valid_keys!
      valid_keys = VALID_KEYS + @selector.custom_filters.keys
      invalid_keys = @options.keys - valid_keys
      unless invalid_keys.empty?
        invalid_names = invalid_keys.map(&:inspect).join(", ")
        valid_names = valid_keys.map(&:inspect).join(", ")
        raise ArgumentError, "invalid keys #{invalid_names}, should be one of #{valid_names}"
      end
    end
  end
end
