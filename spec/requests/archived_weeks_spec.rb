require 'rails_helper'

RSpec.describe "ArchivedWeeks", type: :request do
  describe "GET /archived_weeks" do
    it "works! (now write some real specs)" do
      get archived_weeks_path
      expect(response).to have_http_status(200)
    end
  end
end
