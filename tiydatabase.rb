require 'sinatra'
require 'pg'
require 'ap'
require 'sinatra/reloader' if development?
require 'active_record'

ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Base.establish_connection(
adapter: "postgresql" ,
database: "tiy-database"
)

class Employee < ActiveRecord::Base
  self.primary_key = "id"
end

after do
  ActiveRecord::Base.connection.close
end

get '/' do
  erb :home
end

get '/employees' do
  @employees = Employee.all

  erb :employees
end

get '/show_info' do

  @employee = Employee.find_by(id: params["id"])
  if @employee
    erb :show_info
  else
    erb :no_employee_found
  end
end

get "/add_employee" do
  erb :add_employee
end

get '/create_employee' do

  Employee.create(params)
  redirect ('/')
end

get '/edit_employee' do
  database = PG.connect(dbname: "tiy-database")

  @employee = Employee.find(params["id"])

  erb :edit_employee
end

get '/update_employee' do

  database = PG.connect(dbname: "tiy-database")

  @employee = Employee.find(params["id"])
  @employee.update_attributes(params)

  redirect to('/employees')
end

get '/searched' do
  search = params['search']
  @employees = Employee.where("name like ? or github = ?", "%#{search}%", search)
  if @employees.any?
    erb :employees
  else
    erb :no_employee_found
  end
end

get '/delete' do
  database = PG.connect(dbname: "tiy-database")
  @employee = Employee.find(params["id"])
  @employee.destroy
  redirect ('/employees')
end
