require "rails_helper"

module Securial
  RSpec.describe ApplicationRecord do
    let(:test_model_class) do
      Class.new(ApplicationRecord) do
        self.table_name = "securial_roles"
      end
    end

    before do
      stub_const("Securial::TestModel", test_model_class)
    end

    describe "#generate_uuid_v7" do
      before do
        allow(Random).to receive(:uuid_v7).and_call_original
      end

      let(:test_model) { TestModel.new }

      context "with blank id field" do
        it "generates a UUIDv7 string before creation" do
          test_model.save
          expect(test_model.id).to be_present
          expect(test_model.id).to match(/^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i)
        end
      end

      context "with pre-existing id" do
        it "preserves the existing id value" do
          existing_id = Random.uuid_v7
          test_model.id = existing_id
          test_model.save
          expect(test_model.id).to eq(existing_id)
        end
      end

      context "with string column type" do
        before do
          allow(test_model.class).to receive(:type_for_attribute)
            .with(:id)
            .and_return(ActiveRecord::Type::String.new)
        end

        it "generates a new UUID" do
          test_model.save
          expect(Random).to have_received(:uuid_v7).once
        end
      end

      context "when id column type is not string" do
        before do
          column_type = instance_double(ActiveRecord::Type::Value)
          allow(column_type).to receive(:type).and_return(:integer)

          allow(test_model.class).to receive(:type_for_attribute)
            .with(:id)
            .and_return(column_type)
        end

        let(:test_model) { TestModel.new(id: 3) }

        it "returns early without generating uuid" do
          test_model.save
          expect(Random).not_to have_received(:uuid_v7)
        end

        it "preserves the original id value" do
          test_model.save
          expect(test_model.id).to eq("3")
        end
      end
    end
  end
end
