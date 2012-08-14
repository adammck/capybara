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

    let :selector do
      Capybara::Selector.all[:checkbox]
    end

    def apply expression
      string.native.xpath(expression.to_s)
    end

    def values nodes
      nodes.map { |node| node['value'] }.sort
    end

    describe 'all_xpath' do
      it "finds all checkboxes" do
        nodes = apply selector.all_xpath
        values(nodes).should == %w(A B C D)
      end
    end

    describe 'find_xpath' do
      it "finds checkboxes by id" do
        nodes = apply selector.find_xpath('beta')
        values(nodes).should == %w(A)
      end

      it "finds checkboxes by name" do
        nodes = apply selector.find_xpath('gamma')
        values(nodes).should == %w(B C)
      end

      it "finds checkboxes by placeholder" do
        nodes = apply selector.find_xpath('delta')
        values(nodes).should == %w(D)
      end

      it "finds checkboxes by label" do
        nodes = apply selector.find_xpath('Alpha')
        values(nodes).should == %w(A)
      end
    end
  end
end
