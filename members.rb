require "sinatra"
require "erb"

enable :sessions
use Rack::MethodOverride

def replace_name(filename, new_name, old_name)
  list = File.read(filename).split("\n")
  index = list.index(old_name)
  list[index] = new_name
  File.open(filename, "w+") do |file|
    file.puts(list)
  end
end

def save_name(file, string)
  File.open(file, "a") do |file|
    file.puts(string)
  end
end

class Validator
  def initialize(name, list)
    @name = name.to_s
    @list = list
  end

  def valid?
    validate
    @message.nil?
  end

  def message
    @message
  end

  private

    def validate
      if @name.empty?
        @message = "You need to enter a name."
      elsif @list.include?(@name)
        @message = "#{@name} is already included in the list."
      end
    end

end

get "/members" do
  @name = params["name"]
  @list = File.read("members.txt").split("\n")
  erb :index
end

get "/members/new" do
  erb :form
end

get "/members/:name" do
  @message = session.delete(:message)
  @name = params["name"]
  erb :show
end

post "/members" do
  @name = params["name"]
  @list = File.read("members.txt").split("\n")
  validator = Validator.new(@name, @list)
  if validator.valid?
    File.open("members.txt", "a+") do |file|
      file.puts(@name)
    end
    session[:message] = "Successfully signed up!"
    redirect "/members/#{@name}"
  else
    @message = validator.message
    erb :form
  end
end

get "/members/:name/edit" do
  @name = params["name"]
  erb :edit
end

put "/members/:name" do
  @name = params["name"]
  @new_name = params["new_name"]
  @list = File.read("members.txt").split("\n")
  validator = Validator.new(@new_name, @list)
  if validator.valid?
    replace_name("members.txt", @new_name, @name)
    session[:message] = "Successfully edited!"
    redirect "/members/#{@new_name}"
  else
    @message = validator.message
    erb :edit
  end
end

get "/members/:name/delete" do
  @name = params["name"]
  erb :delete
end

delete "/members/:name" do
  @name = params["name"]
  @list = File.read("members.txt").split("\n")
  @list = @list - [@name]
  File.open("members.txt", "w+") do |file|
    file.puts(@list)
  end
  redirect "/members"
end
