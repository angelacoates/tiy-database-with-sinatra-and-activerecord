require 'sinatra'
require 'pg'
require 'ap'

require 'sinatra/reloader' if development?

get '/' do
  erb :home
end

get '/employees' do
  employees_db = PG.connect(dbname:"tiy-database")
  @employees = employees_db.exec("select * from employees")

  erb :employees
end

get '/show_info' do
  employees_db = PG.connect(dbname:"tiy-database")

  id = params["id"]

  @employees = employees_db.exec("select * from employees where id = $1", [id])

  erb :show_info
end

# This handles creating the employee
get "/create_employee" do
  addemployee_db = PG.connect(dbname: "tiy-database")

  name = params["name"]
  phone = params["phone"]
  address = params["address"]
  position = params["position"]
  salary = params["salary"].to_i
  github = params["github"]
  slack = params["slack"]

  addemployee_db.exec("INSERT INTO employees(name, phone, address, position, salary, github, slack) VALUES($1, $2, $3, $4, $5, $6, $7)", [name, phone, address, position, salary, github, slack])

  redirect to("/employees")
end

# All /add_employee needs to do is show the user a nice form.
get "/add_employee" do
  # The template that has our form is add_employee.erb
  erb :add_employee
end

# edit_employee has to receive as a parameter the id of the person we are editing
# then it has to pull the details of that person from the database into an instance variable
# then erb a template that will show a form, but this time it needs the employee's details in the values.
get '/edit_employee' do
  employees_db = PG.connect(dbname:"tiy-database")

  id = params["id"]

  employees = employees_db.exec("select * from employees where id = $1", [id])

  @employee = employees.first

  erb :edit_employee
end

get '/update_employee' do
  update_employee_db = PG.connect(dbname: "tiy-database")

  id = params["id"]
  name = params["name"]
  phone = params["phone"]
  address = params["address"]
  position = params["position"]
  salary = params["salary"].to_i
  github = params["github"]
  slack = params["slack"]

  update_employee_db.exec("UPDATE employees SET name = $2, phone = $3, address = $4, position = $5, salary = $6, github = $7, slack = $8 where id =$1", [id, name, phone, address, position, salary, github, slack])
  redirect to("/employees")
end
