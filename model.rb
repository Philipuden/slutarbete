def connect_db()
    db = SQLite3::Database.new("db/db_recipe.db")
    db.results_as_hash = true
    return db
end

def recipe_new_post(title, how_to, is_public, img, id)

    if title.nil? || title.strip.empty?
        session[:error] = "Titeln på ditt recept får inte vara tomt."
        redirect("/recipe/new") 
   elsif img.nil? || img.strip.empty?
        session[:error] = "Du måste ha en bild"
        redirect("/recipe/new")
    elsif how_to.nil? || how_to.strip.empty?
        session[:error] = "Informationen om hur receptet tillagas får inte vara tomt."
        redirect("/recipe/new")
    end


    db = connect_db()
    db.execute("INSERT INTO user_recipes (name, how_to, is_public, user_id, img) VALUES (?, ?, ?, ?, ?)",title, how_to, is_public, id, img)
    redirect('/recipe')

end