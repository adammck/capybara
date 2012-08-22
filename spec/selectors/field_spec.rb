require 'spec_helper'

describe Capybara::Selector do
  include SelectorSpecHelpers

  describe '[:field]' do
    let :selector do
      Capybara::Selector.all[:field]
    end

    describe 'all_xpath' do
      it 'finds fields' do
        html = <<-HTML
          <input type="button">
          <input type="checkbox">
          <input type="file">
          <input type="password">
          <input type="radio">
          <input type="reset">
          <input type="text">
          <textarea></textarea>
          <select></select>

          <!-- Irrelevant: -->
          <div></div>
          <span></span>
          <form></form>

          <!-- Excluded: -->
          <input type="submit">
          <input type="hidden">
          <input type="image">
        HTML

        xpath = selector.all_xpath
        nodes = query(xpath, html)

        nodes.length.should == 9
      end
    end

    describe 'find_xpath' do
      it 'finds fields by id' do
        html = <<-HTML
          <input id="a" value="1">
          <input id="b" value="2">
        HTML

        xpath = selector.find_xpath("a")
        nodes = query(xpath, html)

        nodes.should have_values %w[1]
      end

      it 'finds fields by name' do
        html = <<-HTML
          <input name="a" value="1">
          <input name="a" value="2">
          <input name="b" value="3">
        HTML

        xpath = selector.find_xpath("a")
        nodes = query(xpath, html)

        nodes.should have_values %w[1 2]
      end

      it 'finds fields by label' do
        html = <<-HTML
          <label for="a">Alpha</label>
          <input id="a" value="1">

          <label for="b">Beta</label>
          <input id="b" value="2">
        HTML

        xpath = selector.find_xpath("Alpha")
        nodes = query(xpath, html)

        nodes.should have_values %w[1]
      end
    end

    describe 'filters' do
      it 'by value (:checked, :unchecked)' do
        html = <<-HTML
          <input type="checkbox" id="a" checked="checked">
          <input type="checkbox" id="b" checked>
          <input type="whatever" id="c">
          <input type="checkbox" id="d">
        HTML

        xpath = selector.all_xpath
        nodes = query(xpath, html)

        checked_nodes = filter(nodes, selector, :checked, true)
        unchecked_nodes = filter(nodes, selector, :unchecked, true)
        not_checked_nodes = filter(nodes, selector, :checked, false)
        not_unchecked_nodes = filter(nodes, selector, :unchecked, false)

        checked_nodes.should have_ids %w[a b]
        unchecked_nodes.should have_ids %w[c d]
        not_checked_nodes.should have_ids %w[c d]
        not_unchecked_nodes.should have_ids %w[a b]
      end

      it 'by value (:with)' do
        html = <<-HTML
          <input id="a" value="1">
          <input id="b" value="1">
          <input id="c" value="2">
        HTML

        xpath = selector.all_xpath
        nodes = query(xpath, html)
        nodes_with_1 = filter(nodes, selector, :with, '1')

        nodes_with_1.should have_ids %w[a b]
      end
    end
  end
end
