require 'rails_helper'

RSpec.describe "archived_time_entries/index", type: :view do
  before(:each) do
    assign(:archived_time_entries, [
      ArchivedTimeEntry.create!(),
      ArchivedTimeEntry.create!()
    ])
  end

  it "renders a list of archived_time_entries" do
    render
  end
end
