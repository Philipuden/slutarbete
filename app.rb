require 'sinatra'
require 'sinatra/reloader'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'sinatra/flash'
require_relative './model.rb'

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
    db = connect_db()
    result = db.execute("SELECT * FROM users WHERE username = ?",username).first
    pwdigest = result["pwdigest"]
    id = result["id"]
    if (BCrypt::Password.new(pwdigest) == password)
      session[:id] = id
      session[:username] = username
      redirect('/')
    else
      "fel lösen eller användarnamn"
    end
end

get ('/logout') do
    session[:id] = nil
    session[:username] = nil
    flash[:notice] = "Du har blivit utloggad"
    redirect('/')
end

post('/user/new') do
    username = params[:username]
    password = params[:password]
    password_confirm = params[:password_confirmation]
    if (password == password_confirm)
        password_digest = BCrypt::Password.create(password)
        db = connect_db()
        db.execute("INSERT INTO users (username,pwdigest) VALUES (?,?)",username,password_digest)
        id = db.execute("SELECT id FROM users WHERE username = ?",username).first
        session[:id] = id
        session[:username] = username
        redirect('/')
    else
        "Lösenordet matchar inte"
    end
end

get('/recipe') do
    db = connect_db()
    id = session[:id]
    result = db.execute("SELECT * FROM user_recipes")
    result_temp = db.execute("SELECT recipe_id FROM favourites WHERE users_id = ?",id)
    result2 = result_temp.to_s
    slim(:"recipe/index",locals:{recipes:result, result:result2})
end

get('/my_recipe') do
    if session[:id] != nil
        db = connect_db()
        id = session[:id]
        result = db.execute("SELECT * FROM user_recipes WHERE user_id = ?",id)
        slim(:"recipe/my_recipe",locals:{recipes:result})
    else
        slim(:login)
    end
end
  
get('/recipe/new') do
    slim(:"recipe/new")
end

get('/favourites') do
    if session[:id] != nil
        db = connect_db()
        id = session[:id]
        favourites = db.execute("SELECT user_recipes.name, favourites.recipe_id FROM favourites INNER JOIN user_recipes ON favourites.recipe_id = user_recipes.recipeId WHERE users_id = ?", id)
        p favourites
        slim(:"recipe/favourites",locals:{favourites:favourites})
    else
        slim(:login)
    end
end

post('/favourites') do
    id = session[:id]
    recipeId = params[:favourite_recipeId]
    db = connect_db()
    db.execute("INSERT INTO favourites (recipe_id, users_id) VALUES (?, ?)",recipeId, id )
    redirect('/recipe')
end

post('/favourites_delete') do
    id = session[:id]
    recipeId = params[:favourite_recipeId]
    db = connect_db()
    p recipeId
    db.execute("DELETE FROM favourites WHERE recipe_id = ? AND users_id = ?",recipeId, id )
    redirect('/recipe')
end

post ('/search') do
    query = params[:query]
    db = connect_db()
    query_string = "%#{query}%"
    session[:results] = db.execute("SELECT recipeId, name FROM user_recipes WHERE name LIKE ?", query_string)
    redirect('/search_result')
end

get ('/search_result') do
    slim (:"recipe/search_result")
end
  
post('/recipe/new') do
    title = params[:title].to_s
    how_to = params[:how_to].to_s
    is_public = params[:is_public].to_s
    img = params[:img][:tempfile].read if params[:img]
    id = session[:id]
    recipe_new_post(title, how_to, is_public, img, id)
end
  
post('/recipe/:id/delete') do
    id = params[:id].to_i
    db = connect_db()
    db.execute("DELETE FROM user_recipes WHERE recipeId = ?",id)
    redirect('/recipe')
end
  
post('/recipe/:id/update') do
    id = params[:id].to_i
    db = connect_db()
    title = params[:title].to_s
    how_to = params[:how_to].to_s
    is_public = params[:is_public].to_s
    img = params[:img][:tempfile].read if params[:img]
    db.execute("UPDATE user_recipes SET name = ?, how_to = ?, is_public = ?, img = ? WHERE recipeID = ?",title,how_to,is_public,id,img)
    redirect("/recipe")
end
  
get('/recipe/:id/edit') do
    id = params[:id].to_i
    db = connect_db()
    result = db.execute("SELECT * FROM user_recipes WHERE recipeId = ?",id).first
    slim(:"recipe/edit", locals:{recipes:result})
end
  
  
get('/recipe/:id') do
    id = params[:id].to_i
    db = connect_db()
    result = db.execute("SELECT * FROM user_recipes WHERE recipeId = ?",id).first
    slim(:"recipe/show",locals:{result:result})
end