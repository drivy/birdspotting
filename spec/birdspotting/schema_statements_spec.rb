RSpec.describe Birdspotting::SchemaStatements do
  let(:instance) do
    ActiveRecord::Migration.new.tap { |o| o.version = version }
  end

  let(:table_name) { :posts }
  let(:column_name) { :author }
  let(:type) { :string }
  let(:version) { 123 }
  let(:options) { {} }

  describe "#add_column" do
    subject(:add_column) { instance.add_column(table_name, column_name, type, options) }

    let(:options) { { after: :id } }

    context "without after or first option set" do
      let(:options) { {} }

      it "raises" do
        expect { add_column }.to raise_exception(Birdspotting::ColumnPositionMissingError)
      end
    end

    context "with after or first option set" do
      it "adds the column" do
        expect_any_instance_of(ActiveRecord::Migration).to receive(:say_with_time)
        expect { add_column }.not_to raise_exception
      end
    end

    context "for a string/text type column" do
      it "give us a warning message" do
        expect_any_instance_of(ActiveRecord::Migration).to receive(:say_with_time)
        expect(STDERR).to receive(:puts).with(/You are dealing with a string/m)
        add_column
      end
    end
  end

  describe "#rename_column" do
    subject(:rename_column) do
      instance.rename_column(table_name, column_name, "new_column_name", options)
    end

    it "raises" do
      expect { rename_column }.to raise_exception(Birdspotting::RenameColumnForbiddenError)
    end

    context "with bypass" do
      let(:options) { { bypass_schema_statements_check: true } }

      it "removes the column" do
        expect_any_instance_of(ActiveRecord::Migration).to receive(:say_with_time)
        expect { rename_column }.not_to raise_exception
      end
    end
  end

  describe "#remove_column" do
    subject(:remove_column) { instance.remove_column(table_name, column_name, type, options) }

    context "with unknown model" do
      it "raises" do
        expect { remove_column }.to raise_exception(Birdspotting::ModelNotFoundError)
      end
    end

    context "with existing model" do
      let(:column) { instance_double("Column", name: column_name.to_s) }
      let(:columns) { [] }

      before do
        stub_const(table_name.to_s.classify, Class.new, columns: columns)
        allow(table_name.to_s.classify.constantize).to receive(:columns).and_return(columns)
      end

      context "without bypass" do
        let(:options) { {} }

        context "with active columns" do
          let(:columns) { [column] }

          it "raises" do
            expect { remove_column }.to raise_exception(Birdspotting::RemoveColumnForbiddenError)
          end
        end

        context "with ignored columns" do
          let(:columns) { [] }

          it "removes the column" do
            expect_any_instance_of(ActiveRecord::Migration).to receive(:say_with_time)
            expect { remove_column }.not_to raise_exception
          end
        end
      end

      context "with bypass" do
        let(:options) { { bypass_schema_statements_check: true } }

        it "removes the column" do
          expect_any_instance_of(ActiveRecord::Migration).to receive(:say_with_time)
          expect { remove_column }.not_to raise_exception
        end
      end
    end
  end
end
