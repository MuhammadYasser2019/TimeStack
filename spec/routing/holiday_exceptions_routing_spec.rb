require "rails_helper"

RSpec.describe HolidayExceptionsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/holiday_exceptions").to route_to("holiday_exceptions#index")
    end

    it "routes to #new" do
      expect(:get => "/holiday_exceptions/new").to route_to("holiday_exceptions#new")
    end

    it "routes to #show" do
      expect(:get => "/holiday_exceptions/1").to route_to("holiday_exceptions#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/holiday_exceptions/1/edit").to route_to("holiday_exceptions#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/holiday_exceptions").to route_to("holiday_exceptions#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/holiday_exceptions/1").to route_to("holiday_exceptions#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/holiday_exceptions/1").to route_to("holiday_exceptions#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/holiday_exceptions/1").to route_to("holiday_exceptions#destroy", :id => "1")
    end

  end
end
