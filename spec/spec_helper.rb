$:.unshift(File.expand_path('../lib', File.dirname(__FILE__)))

require 'rubygems'
require "bundler/setup"

require 'rspec'
require 'capybara'

RSpec.configure do |config|
  config.before do
    Capybara.configure do |config|
      config.default_selector = :xpath
    end
  end

  # Workaround for http://code.google.com/p/selenium/issues/detail?id=3147:
  # Rerun the example if we hit a transient "docElement is null" error
  config.around(:each) do |example|
    attempts = 0
    begin
      example.run
      # example is just a Proc, @example is the current RSpec::Core::Example
      e = @example.instance_variable_get('@exception') # usually nil
      if (defined?(Selenium::WebDriver::Error::UnknownError) && e.is_a?(Selenium::WebDriver::Error::UnknownError) &&
          e.message == 'docElement is null' && (attempts += 1) < 5)
        @example.instance_variable_set('@exception', nil)
        redo
      end
    end until true
  end
end

module SelectorSpecHelpers

  # Apply an xpath +expression+ to an +html+ fragment, and call a block with an
  # array of the Nokogiri nodes which matched.
  def query expression, html
    Nokogiri::HTML.parse(html).xpath(expression.to_s)
  end

  # Filter +nodes+ with +selector+, using the +name+ filter with +args+, and
  # call a block with the resulting nodes.
  def filter nodes, selector, name, *args
    nodes.select do |node|

      # I'd prefer to keep Capybara out of this spec, since we're only testing
      # selectors, but custom filters expect a Capybara::Node.

      n = Capybara::Node::Simple.new(node)
      selector.custom_filters[name].call(n, *args)
    end
  end
end

RSpec::Matchers.define :have_attributes do |name, values|
  match do |nodes|
    nodes.zip(values).each do |node, value|
      node[name].should == value
    end
  end
end

RSpec::Matchers.define :have_values do |values|
  match do |nodes|
    nodes.should have_attributes "value", values
  end
end

RSpec::Matchers.define :have_ids do |ids|
  match do |nodes|
    nodes.should have_attributes "id", ids
  end
end

# Required here instead of in rspec_spec to avoid RSpec deprecation warning
require 'capybara/rspec'

require 'capybara/spec/session'

alias :running :lambda

Capybara.app = TestApp
Capybara.default_wait_time = 0 # less timeout so tests run faster

module TestSessions
  RackTest = Capybara::Session.new(:rack_test, TestApp)
  Selenium = Capybara::Session.new(:selenium, TestApp)
end
