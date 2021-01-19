require 'rails_helper'

RSpec.describe "archived_weeks/edit", type: :view do
  before(:each) do
    @archived_week = assign(:archived_week, ArchivedWeek.create!())
  end

  it "renders the edit archived_week form" do
    render

    assert_select "form[action=?][method=?]", archived_week_path(@archived_week), "post" do
    end
  end
end
