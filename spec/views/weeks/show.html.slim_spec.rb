require 'rails_helper'

RSpec.describe "weeks/show", type: :view do
  before(:each) do
    @week = assign(:week, Week.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
