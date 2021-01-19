require 'rails_helper'

RSpec.describe "archived_weeks/index", type: :view do
  before(:each) do
    assign(:archived_weeks, [
      ArchivedWeek.create!(),
      ArchivedWeek.create!()
    ])
  end

  it "renders a list of archived_weeks" do
    render
  end
end
