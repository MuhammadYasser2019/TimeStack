require 'rails_helper'

RSpec.describe "archived_weeks/new", type: :view do
  before(:each) do
    assign(:archived_week, ArchivedWeek.new())
  end

  it "renders new archived_week form" do
    render

    assert_select "form[action=?][method=?]", archived_weeks_path, "post" do
    end
  end
end
