require 'rails_helper'

RSpec.describe "time_entries/show", type: :view do
  before(:each) do
    @time_entry = assign(:time_entry, TimeEntry.create!(
      :hours => 1,
      :comments => "Comments",
      :task => nil,
      :week => nil,
      :user => nil
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/1/)
    expect(rendered).to match(/Comments/)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
  end
end
