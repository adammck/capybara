require 'spec_helper'

describe Capybara::Selector do
  include SelectorSpecHelpers

  describe '[:checkbox]' do
    let :selector do
      Capybara::Selector.all[:checkbox]
    end

    let :string do
      Capybara.string <<-STRING
        <label for="beta">Alpha</label>
        <input type="checkbox" id="beta" value="A">
        <input type="checkbox" name="gamma" value="B">
        <input type="checkbox" name="gamma" value="C">
        <input type="checkbox" placeholder="delta" value="D">
      STRING
    end

    describe 'all_xpath' do
      it "finds all checkboxes" do
        html = <<-HTML
          <input type="checkbox" value="1">
          <input type="checkbox" value="2">
          <input type="checkbox" value="3">

          <!-- Irrelevant: -->
          <textarea></textarea>
          <input type="text">
          <form></form>
        HTML

        xpath = selector.all_xpath
        nodes = query(xpath, html)

        nodes.should have_values %w[1 2 3]
      end
    end

    describe 'find_xpath' do
      it "finds checkboxes by id" do
        html = <<-HTML
          <input type="checkbox" id="a" value="1">
          <input type="checkbox" id="b" value="2">
        HTML

        xpath = selector.find_xpath "a"
        nodes = query(xpath, html)

        nodes.should have_values %w[1]
      end

      it "finds checkboxes by name" do
        html = <<-HTML
          <input type="checkbox" name="a" value="1">
          <input type="checkbox" name="a" value="2">
          <input type="checkbox" name="b" value="3">
          <input type="text" name="a" value="4">
        HTML

        xpath = selector.find_xpath "a"
        nodes = query(xpath, html)

        nodes.should have_values %w[1 2]
      end

      it "finds checkboxes by label" do
        html = <<-HTML
          <label for="a">Alpha</label>
          <input type="checkbox" id="a" value="1">

          <label for="b">Beta</label>
          <input type="checkbox" id="b" value="2">
        HTML

        xpath = selector.find_xpath "Alpha"
        nodes = query(xpath, html)

        nodes.should have_values %w[1]
      end
    end
  end
end
