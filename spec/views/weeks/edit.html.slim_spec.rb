require 'rails_helper'

RSpec.describe "weeks/edit", type: :view do
  before(:each) do
    @week = assign(:week, Week.create!())
  end

  it "renders the edit week form" do
    render

    assert_select "form[action=?][method=?]", week_path(@week), "post" do
    end
  end
end
