# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

require "relaxo/test_records"

describe Relaxo do
	with ".connect" do
		include Relaxo::TemporaryDatabase
		
		it "can connect to a new database" do
			expect(database).to be_a Relaxo::Database
			expect(database.branch).to be == "main"
		end
		
		it "can connect to a new database with an alternative branch name" do
			Relaxo.connect(database_path, branch: "development")
			
			expect(database).to be_a Relaxo::Database
			expect(database.branch).to be == "development"
		end
	end
end
