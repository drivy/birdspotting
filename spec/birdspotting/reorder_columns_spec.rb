RSpec.describe Birdspotting::ReorderColumns do
  subject(:reorder_columns_for) { instance.reorder_columns_for(table_name, ordered_columns) }

  let(:instance) do
    ActiveRecord::Migration.new.tap do |o|
      o.version = version
      o.class.include(described_class)
    end
  end
  let(:table_name) { :posts }
  let(:version) { 123 }
  let(:ordered_columns) { %w[subject author body] }
  let(:columns) do
    [
      instance_double("Column", name: "author"),
      instance_double("Column", name: "subject"),
      instance_double("Column", name: "body"),
    ]
  end
  let(:connection) { instance_double("connection") }
  let(:connection_config) { { adapter: adapter } }
  let(:adapter) { "mysql2" }
  let(:show_create_table) do
    {
      "posts" => <<~SQL,
        CREATE TABLE `posts` (\n  `id` bigint(20) NOT NULL AUTO_INCREMENT,\n  `author` int(11) DEFAULT NULL,\n  `body` text,\n  `subject` varchar(255) DEFAULT NULL,\n  `posted_at` datetime DEFAULT NULL,\n  `created_at` datetime NOT NULL,\n  `updated_at` datetime NOT NULL,\n  PRIMARY KEY (`id`)\n) ENGINE=InnoDB DEFAULT CHARSET=utf8
      SQL
    }
  end

  before do
    allow(ActiveRecord::Base).to receive(:connection).and_return(connection)
    allow(ActiveRecord::Base).to receive(:connection_config).and_return(connection_config)
  end

  it "reorder the columns" do
    expect(connection).to receive(:execute)
      .once.with("SHOW CREATE TABLE `#{table_name}`").and_return(show_create_table)
    expect(connection).to receive(:columns).with(table_name).and_return(columns)
    expect(connection).to receive(:execute).twice
    reorder_columns_for
  end

  context "with unsupported database" do
    let(:adapter) { "pg" }

    it "raises" do
      expect { reorder_columns_for }.to raise_exception(Birdspotting::UnsupportedAdapterError)
    end
  end

  context "with missing columns" do
    let(:ordered_columns) { %w[subject author] }

    it "raises" do
      expect(connection).to receive(:columns).with(table_name).and_return(columns)
      expect { reorder_columns_for }.to raise_exception(Birdspotting::MismatchedColumnsError)
    end
  end

  context "with extra columns" do
    let(:ordered_columns) { %w[subject author review] }

    it "raises" do
      expect(connection).to receive(:columns).with(table_name).and_return(columns)
      expect { reorder_columns_for }.to raise_exception(Birdspotting::MismatchedColumnsError)
    end
  end
end
