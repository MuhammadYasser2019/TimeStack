require "rails_helper"

RSpec.describe ArchivedTimeEntriesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/archived_time_entries").to route_to("archived_time_entries#index")
    end

    it "routes to #new" do
      expect(:get => "/archived_time_entries/new").to route_to("archived_time_entries#new")
    end

    it "routes to #show" do
      expect(:get => "/archived_time_entries/1").to route_to("archived_time_entries#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/archived_time_entries/1/edit").to route_to("archived_time_entries#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/archived_time_entries").to route_to("archived_time_entries#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/archived_time_entries/1").to route_to("archived_time_entries#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/archived_time_entries/1").to route_to("archived_time_entries#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/archived_time_entries/1").to route_to("archived_time_entries#destroy", :id => "1")
    end

  end
end
