class Dog
#use DB[:conn] to connect to database
  attr_accessor :name, :breed, :id

  # def initialize(name, breed, id = nil)

  #   @id = id
  # end

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
          id INTEGER PRIMARY KEY,
          name TEXT,
          breed TEXT)
      SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
        DROP TABLE if EXISTS dogs
        SQL
      DB[:conn].execute(sql)
  end

  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    breed = row[2]

    new_pup = self.new(id: id, name: name, breed: breed)
    new_pup
  end

  def self.find_by_name(name)
      sql = "SELECT * FROM dogs WHERE dogs.name = ?"
      dog_row = DB[:conn].execute(sql, name)[0]
      #binding.pry
      new_from_db(dog_row)
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE dogs.id = ?"
    dog_row = DB[:conn].execute(sql, id)[0]
    new_from_db(dog_row)
  end

  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
    dog
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      dog_data = dog[0]
      dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end


  def save
    if self.id
      self.update
    else
      sql = <<-SQL
          INSERT INTO dogs (name, breed)
          VALUES (?,?)
          SQL
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT LAST_INSERT_ROWid() FROM dogs")[0][0]
    end
    self
  end

  def update
    sql = <<-SQL
        UPDATE dogs SET name = ?, breed = ? WHERE id = ?
        SQL
      DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  #Dog.new(name: 'dog', breed: 'dog')
end
