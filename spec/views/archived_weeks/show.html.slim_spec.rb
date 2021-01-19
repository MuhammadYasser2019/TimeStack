require 'rails_helper'

RSpec.describe "archived_weeks/show", type: :view do
  before(:each) do
    @archived_week = assign(:archived_week, ArchivedWeek.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
