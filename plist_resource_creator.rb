#!/usr/bin/env ruby

require 'yaml'
require 'plist'
require 'fileutils'

def get_current_directory
	File.dirname(File.expand_path(__FILE__))
end

class Fixture_Path_Builder
	def get_fixture_directory
		begin
			#process
			yaml_hash = YAML.load_file('.bekindrewind.yml')
			# yaml_hash = YAML.load_file('nothing.yml')
			yaml_hash['fixture_path']
		rescue
			return 'Fixtures'
		end
	end
	def full_final_fixture_path
		File.join(get_current_directory, self.get_fixture_directory)
	end
end

class Plist_Resource_Builder
	def initialize
		puts 'initialize'
		@plist_subdirectory_path = File.join(get_current_directory, 'BeKindRewind/Assets')
		@full_plist_path = File.join(@plist_subdirectory_path, 'BeKindRewind.plist')
		if File.exist?(@full_plist_path) then 
			File.delete(@full_plist_path)
		end
	end
	def plist_contents(fixture_path)
		puts 'plist_contents'
		Hash["fixture_path" => fixture_path]
	end
	def create_plist(fixture_path)
		puts 'create_plist'
		if not File.exist?(@full_plist_path) then
			FileUtils.mkdir_p(@plist_subdirectory_path)
		end
		File.open(@full_plist_path, 'w') {|f| f.write(self.plist_contents(fixture_path).to_plist) }
	end
end



fixture_path_builder = Fixture_Path_Builder.new
fixture_path = fixture_path_builder.full_final_fixture_path
puts fixture_path

plist_resource_builder = Plist_Resource_Builder.new
plist_resource_builder.create_plist(fixture_path)