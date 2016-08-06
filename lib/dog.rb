class Dog

  attr_accessor :id, :name, :breed

  def initialize(options)
    @name = options[:name]
    @breed = options[:breed]
    @id = nil
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      );
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE dogs;
    SQL

    DB[:conn].execute(sql)
  end

  def self.new_from_db(row)
    options = {:id => row[0], :name => row[1], :breed => row[2]}
    dog = Dog.new(options)
    dog.id = row[0][0]
    dog
  end


  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def self.create(options)
    dog = self.new(options)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?;
    SQL

    db_dog = DB[:conn].execute(sql, id)
    new_from_db(db_dog)
  end

  def self.find_by_name(dog_name)
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE name = ?;
    SQL

    db_dog = DB[:conn].execute(sql, dog_name)
    new_from_db(db_dog[0])

  end

  def self.find_or_create_by(options)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", options[:name], options[:breed])
    if !dog.empty?
      dog_data = dog[0]
      result = find_by_name(options[:name])
    else
      result = self.create(options)
    end
    result
  end

end
