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
    db = SQLite3::Database.new('db/db_recipe.db')
    db.results_as_hash = true
    result = db.execute("SELECT * FROM users WHERE username = ?",username).first
    pwdigest = result["pwdigest"]
    id = result["id"]
    if (BCrypt::Password.new(pwdigest) == password)
      session[:id] = id
      redirect('/')
    else
      "fel lösen eller användarnamn"
    end
end

get ('/logout') do
    session[:id] = nil
    redirect('/')
end

post('/user/new') do
    username = params[:username]
    password = params[:password]
    password_confirm = params[:password_confirmation]
    if (password == password_confirm)
        password_digest = BCrypt::Password.create(password)
        db = SQLite3::Database.new('db/db_recipe.db')
        db.execute("INSERT INTO users (username,pwdigest) VALUES (?,?)",username,password_digest)
        redirect('/')
    else
        "Lösenordet matchar inte"
    end
end

get('/recipe') do
    db = SQLite3::Database.new("db/db_recipe.db")
    db.results_as_hash = true
    result = db.execute("SELECT * FROM user_recipes")
    @id = session[:id]
    slim(:"recipe/index",locals:{recipes:result})
end
  
get('/recipe/new') do
    slim(:"recipe/new")
end
  
post('/recipe/new') do
    title = params[:title].to_s
    how_to = params[:how_to].to_s
    is_public = params[:operator].to_s
    id = session[:id]
    db = SQLite3::Database.new("db/db_recipe.db")
    db.execute("INSERT INTO user_recipes (name, how_to, is_public, user_id) VALUES (?, ?, ?, ?)",title, how_to, is_public, id)
    redirect('/recipe')
end
  
post('/recipe/:id/delete') do
    id = params[:id].to_i
    db = SQLite3::Database.new("db/db_recipe.db")
    db.execute("DELETE FROM user_recipes WHERE recipeId = ?",id)
    redirect('/recipe')
end
  
post('/recipe/:id/update') do
    id = params[:id].to_i
    db = SQLite3::Database.new("db/db_recipe.db")
    title = params[:title]
    artist_id = params[:how_to].to_s
    db.execute("UPDATE user_recipes SET name = ?, how_to = ? WHERE recipeID = ?",title,artist_id,id)
    redirect("/recipe")
end
  
get('/recipe/:id/edit') do
    id = params[:id].to_i
    db = SQLite3::Database.new("db/db_recipe.db")
    db.results_as_hash = true
    result = db.execute("SELECT * FROM user_recipes WHERE recipeId = ?",id).first
    slim(:"recipe/edit", locals:{recipes:result})
end
  
  
get('/recipe/:id') do
    id = params[:id].to_i
    db = SQLite3::Database.new("db/db_recipe.db")
    db.results_as_hash = true
    result = db.execute("SELECT * FROM user_recipes WHERE recipeId = ?",id).first
    slim(:"recipe/show",locals:{result:result})
end