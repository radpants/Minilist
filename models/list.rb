class List
  include DataMapper::Resource
  
  property :id, Serial
  property :name, String, :default => ""
  property :created_on, DateTime, :default => DateTime.now
  
  has n, :tasks
  
  belongs_to :user
end