class Task
  include DataMapper::Resource
  
  property :id, Serial
  property :name, String, :default => ""
  property :created_on, DateTime, :default => DateTime.now
  property :state, Enum[:incomplete, :completed, :logged], :default => :incomplete
  
  belongs_to :list
end