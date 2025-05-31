require 'rails_helper'

RSpec.describe "/<%= plural_table_name %>", type: :request do
  let(:<%= singular_table_name %>) { create(:<%= singular_table_name %>) }

  describe "GET /index" do
    it "returns http success" do
      get securial.<%= class_name.pluralize.downcase %>_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get securial.<%= class_name.downcase %>_path(<%= singular_table_name %>)
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      let(:valid_attributes) {
        attributes_for(:<%= singular_table_name %>)
      }

      it "creates a new <%= class_name %>" do
        expect {
          post securial.<%= class_name.pluralize.downcase %>_path, params: { <%= singular_table_name %>: valid_attributes }
        }.to change(Securial::<%= class_name %>, :count).by(1)
      end

      it "returns http created" do
        post securial.<%= class_name.pluralize.downcase %>_path, params: { <%= singular_table_name %>: valid_attributes }
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "PUT /update" do
    context "with valid parameters" do
      let(:new_attributes) {
        attributes_for(:<%= singular_table_name %>)
      }

      it "updates the requested <%= singular_table_name %>" do
        put securial.<%= class_name.downcase %>_path(<%= singular_table_name %>), params: { <%= singular_table_name %>: new_attributes }
        <%= singular_table_name %>.reload
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested <%= singular_table_name %>" do
      <%= singular_table_name %> # Create the record
      expect {
        delete securial.<%= class_name.downcase %>_path(<%= singular_table_name %>)
      }.to change(Securial::<%= class_name %>, :count).by(-1)
    end
  end
end