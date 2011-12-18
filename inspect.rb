require 'rubygems'
require 'data_mapper'
require 'dm-migrations'
require 'pp'

$ROOT_DIR = "#{File.expand_path(File.dirname(__FILE__))}"
DataMapper.setup(:default, "sqlite:////#{$ROOT_DIR}database.sqlite")
Dir.glob("#{$ROOT_DIR}/models/*.rb").each do |f|
  require f
end

DataMapper.finalize

puts "-- USERS --------------------------"
User.all.each do |user|
  pp user
end

puts "-- LISTS --------------------------"
List.all.each do |list|
  pp list
end

puts "-- TASKS --------------------------"
Task.all.each do |task|
  pp task
end