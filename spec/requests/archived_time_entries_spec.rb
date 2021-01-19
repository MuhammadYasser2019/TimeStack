require 'rails_helper'

RSpec.describe "ArchivedTimeEntries", type: :request do
  describe "GET /archived_time_entries" do
    it "works! (now write some real specs)" do
      get archived_time_entries_path
      expect(response).to have_http_status(200)
    end
  end
end
