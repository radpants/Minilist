require 'rubygems'
require 'data_mapper'
require 'sinatra'
require 'pp'

# - setup ------------------------------------------------------------------

configure do 
  $ROOT_DIR = "#{File.expand_path(File.dirname(__FILE__))}"
  DataMapper.setup(:default, "sqlite:///#{$ROOT_DIR}/database.sqlite")
  Dir.glob("#{$ROOT_DIR}/models/*.rb").each do |f|
    require f
  end
  DataMapper.finalize
  enable :sessions
end

helpers do
  def partial(page, options={})
    @options = options
    erb page, options.merge!(:layout => false)
  end
  
  def logged_in?
    session[:user_id] != nil
  end
end

# - view ------------------------------------------------------------------

get '/' do
  if logged_in?
    redirect '/dashboard'
  else
    redirect '/hello'
  end
end

get '/hello' do
  erb :hello
end

get '/dashboard' do
  erb :dashboard
end

# - data ------------------------------------------------------------------

get '/tasks/:list_id' do
  return nil if not logged_in?
  @list = List.get(params[:list_id])
  @list.tasks.all( :order => [:state.asc, :name.asc] ).to_json
end

get '/lists' do
  return nil if not logged_in?
  @user = User.get(session[:user_id])
  @user.lists.all( :order => [:name.asc] ).to_json
end

# - create ------------------------------------------------------------------

post '/task/create/:list_id' do
  return { :error => "Error: You are not logged in" }.to_json unless logged_in?
  
  @list = List.get(params[:list_id])
  return { :error => "Error: That list does not exist (id:#{params[:list_id]})"}.to_json if @list == nil
  
  @task = @list.tasks.new params[:task]
  if @task.save
    return { :task => @task, :error => nil }.to_json
  else
    return { :error => "Error: could not create task"}.to_json
  end  
end

post '/list/create' do
  return nil unless logged_in?
  @user = User.get(session[:user_id])
  @list = @user.lists.new params[:list]
  
  if @list.save
    return { :list => @list, :error => nil }.to_json
  else
    return { :error => "Error: could not save list"}.to_json
  end
end

# - update ------------------------------------------------------------------

post '/task/state/:id' do
  return { :error => "Error: You are not logged in" }.to_json unless logged_in?
  @task = Task.get(params[:id])
  return { :error => "Error: Couldn't find that task (id:#{params[:id]})" }.to_json if @task == nil
  
  if @task.update( :state => params[:state] )
    return { :error => nil }.to_json
  else
    return { :error => "Error: Failed to update task" }.to_json
  end
  
end

# - destroy ------------------------------------------------------------------

post '/task/destroy/:id' do
  return { :error => "Error: You are not logged in" }.to_json unless logged_in?
  @task = Task.get(params[:id])
  return { :error => "Error: No task to delete with id of #{params[:id]}" }.to_json if @task.nil?
  if @task.destroy!
    return { :error => nil }.to_json
  else
    return { :error => "Error: Could not destroy that task for some reason" }.to_json
  end  
end

post '/list/destroy/:id' do
  return { :error => "Error: You are not logged in" }.to_json unless logged_in?
  @list = List.get(params[:id])
  return { :error => "Error: No list to delete with id of #{params[:id]}" }.to_json if @list.nil?
  if @list.destroy!
    return { :error => nil }.to_json
  else
    return { :error => "Error: Could not destroy that list for some reason" }.to_json
  end
end
  

# - account ------------------------------------------------------------------

post '/login' do
  unless User.authenticate(params[:username], params[:password]).nil?
    session["user_id"] = User.first(:username => params[:username]).id
    redirect '/dashboard'
  else
    @login_errors = ["Wrong user/password combination"]
    erb :hello
  end
end

post '/signup' do
  @signup_errors = []
  if params[:username] == "" or params[:username] == nil
    @signup_errors.push "You must enter a username"
  end
  
  if params[:password] == "" or params[:password] == nil
    @signup_errors.push "You must enter a password"
  end
  
  if @signup_errors.count == 0
    @user = User.new
    @user.username = params[:username]
    @user.password = params[:password]
    if @user.save
      session["user_id"] = @user.id
      redirect '/dashboard'
    else
      @signup_errors.push("There was an error creating your account, please try again later")
      erb :hello
    end
  else
    erb :hello    
  end  
end

get '/logout' do
  session[:user_id] = nil
  redirect '/hello'
end



