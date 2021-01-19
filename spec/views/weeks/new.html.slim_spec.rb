require 'rails_helper'

RSpec.describe "weeks/new", type: :view do
  before(:each) do
    assign(:week, Week.new())
  end

  it "renders new week form" do
    render

    assert_select "form[action=?][method=?]", weeks_path, "post" do
    end
  end
end
