require 'spec_helper'

describe Capybara::Selector do
  describe '[:checkbox]' do
    let :string do
      Capybara.string <<-STRING
        <label for="beta">Alpha</label>
        <input type="checkbox" id="beta" value="A">
        <input type="checkbox" name="gamma" value="B">
        <input type="checkbox" name="gamma" value="C">
        <input type="checkbox" placeholder="delta" value="D">
      STRING
    end

    def values nodes
      nodes.map { |node| node['value'] }.sort
    end

    it "finds all checkboxes" do
      nodes = string.all(:checkbox)
      values(nodes).should == %w(A B C D)
    end

    it "finds one checkbox by id" do
      node = string.find(:checkbox, 'beta')
      node['value'].should == 'A'
    end

    it "raises when more than one checkbox was found" do
      lambda do
        string.find(:checkbox, 'gamma')
      end.should raise_error Capybara::Ambiguous
    end

    it "raises with a helpful error when no checkbox was found" do
      lambda do
        string.find(:checkbox, 'epsilon')

      end.should raise_error(
        Capybara::ElementNotFound,
        'Expected to find checkbox epsilon, but found no matches. Maybe you '\
        'meant one of: beta, gamma, delta'
      )
    end
  end
end
