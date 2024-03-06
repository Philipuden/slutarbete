def connect_db()
    db = SQLite3::Database.new("db/db_recipe.db")
    db.results_as_hash = true
    return db
end