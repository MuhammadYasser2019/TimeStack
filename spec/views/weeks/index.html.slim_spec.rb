require 'rails_helper'

RSpec.describe "weeks/index", type: :view do
  before(:each) do
    assign(:weeks, [
      Week.create!(),
      Week.create!()
    ])
  end

  it "renders a list of weeks" do
    render
  end
end
