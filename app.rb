require 'sinatra'
require 'sinatra/reloader'
require 'slim'
require 'sqlite3'
require 'bcrypt'

enable :sessions

get('/') do
    slim(:index)
end

get('/showlogin') do
    slim(:login)
  end
  
get('/registrering') do
    slim(:register)
end

post('/login') do
    username = params[:username]
    password = params[:password]
    p username
    p password
    db = SQLite3::Database.new('db/db_todos.db')
    db.results_as_hash = true
    result = db.execute("SELECT * FROM users WHERE username = ?",username).first
    pwdigest = result["pwdigest"]
  
    p pwdigest
    id = result["id"]
    if (BCrypt::Password.new(pwdigest) == password)
      session[:id] = id
      redirect('/todos')
    else
      "fel lösen eller användarnamn"
    end
end

post('/user/new') do
    username = params[:username]
    password = params[:password]
    password_confirm = params[:password_confirmation]
    if (password == password_confirm)
        password_digest = BCrypt::Password.create(password)
        db = SQLite3::Database.new('db/db_todos.db')
        db.execute("INSERT INTO users (username,pwdigest) VALUES (?,?)",username,password_digest)
        redirect('/')
    else
        "Lösenordet matchar inte"
    end
end