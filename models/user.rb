require 'digest/sha1'

class User
  include DataMapper::Resource
  
  property :id, Serial
  property :username, String, :required => true
  property :salt, String
  property :salty_pass, String
  property :email, String
  
  has n, :lists
  
  def self.random_string(len)
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    str = ""
    1.upto(len) { |i| str << chars[rand(chars.size-1)] }
    return str
  end

  def password=(pass)
    @password = pass
    self.salt = User.random_string(10)
    self.salty_pass = User.encrypt(@password, self.salt)
  end

  def self.encrypt(pass, salt)
    Digest::SHA1.hexdigest(pass + salt)
  end

  def self.authenticate(username, password)
    u = User.first(:username => username)
    return nil if u.nil?

    if User.encrypt(password, u.salt) == u.salty_pass
      return u
    end
  end
  
end


  