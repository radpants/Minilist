require 'rubygems'
require 'data_mapper'
require 'dm-migrations'

$ROOT_DIR = "#{File.expand_path(File.dirname(__FILE__))}"
DataMapper.setup(:default, "sqlite:////#{$ROOT_DIR}database.sqlite")
Dir.glob("#{$ROOT_DIR}/models/*.rb").each do |f|
  require f
end

DataMapper.finalize
DataMapper.auto_upgrade!



# User.all.destroy!
# Task.all.destroy!
# List.all.destroy!