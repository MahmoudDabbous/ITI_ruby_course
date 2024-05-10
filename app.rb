# Day 1 Task:
# 	- Search books by:
# 		- ISBN
# 	- Display message if the input is empty or incorrect

class Book
  attr_accessor :title, :author, :isbn, :count
  def initialize(title, author, isbn)
    @title = title
    @author = author
    @isbn = isbn
    @count = 1
  end
end

class Inventory
  attr_reader :books, :name 
  def initialize(name)
    @books = begin
      if File.exist?("#{name}.txt")
        File.readlines("#{name}.txt").map do |line|
          title, author, isbn, count = line.split(", ")
          book = Book.new(title, author, isbn)
          book.count = count.to_i
          book
        end
      else
        File.new("#{name}.txt", "w")
        []
      end
    end
    @name = name
  end

  def add_books(*books)
    books.each do |book|
      existing_book = @books.find { |b| b.isbn == book.isbn }
      if existing_book
        existing_book.title = book.title
        existing_book.author = book.author
        existing_book.count += 1
      else
        @books << book
      end
    end
    save_to_file
  end

  def list_books
    @books.each do |book|
      puts "Title: #{book.title}, Author: #{book.author}, ISBN: #{book.isbn}, Count: #{book.count}"
    end
  end

  def remove_book(isbn)
    @books.each do |book|
      if book.isbn == isbn
        @books.delete(book)
      end
    end
    save_to_file
  end

  def sort_books
    @books.sort_by! { |book| book.isbn }
    save_to_file
  end

  def search_by_title(title)
    @books.each do |book|
      if book.title == title
        puts "Title: #{book.title}, Author: #{book.author}, ISBN: #{book.isbn}, Count: #{book.count}"
      end
    end
  end

  def search_by_author(author)
    @books.each do |book|
      if book.author == author
        puts "Title: #{book.title}, Author: #{book.author}, ISBN: #{book.isbn}, Count: #{book.count}"
      end
    end
  end

  def search_by_isbn(isbn)
    @books.each do |book|
      if book.isbn == isbn
        puts "Title: #{book.title}, Author: #{book.author}, ISBN: #{book.isbn}, Count: #{book.count}"
      end
    end
  end

  private

  def save_to_file
    File.open("#{name}.txt", "w") do |file|
      @books.each do |book|
        file.puts "#{book.title}, #{book.author}, #{book.isbn}, #{book.count}"
      end
    end
  end
end

if __FILE__ == $0
  inventory = Inventory.new("inventory")

  loop do
    puts "Menu:"
    puts "1. List books"
    puts "2. Add new book"
    puts "3. Remove book by ISBN"
    puts "4. Sort books by ISBN"
    puts "5. Search books by title"
    puts "6. Search books by author"
    puts "7. Search books by ISBN"
    puts "0. Exit"

    choice = gets.chomp.to_i

    case choice
      when 1
        inventory.list_books
      when 2
        puts "Enter book title:"
        title = gets.chomp0
        puts "Enter book author:"
        author = gets.chomp
        puts "Enter book ISBN:"
        isbn = gets.chomp
        book = Book.new(title, author, isbn)
        inventory.add_books(book)
      when 3
        puts "Enter book ISBN to remove:"
        isbn = gets.chomp
        inventory.remove_book(isbn)
      when 4
        inventory.sort_books
      when 5
        puts "Enter book title to search:"
        title = gets.chomp
        inventory.search_by_title(title)
      when 6
        puts "Enter book author to search:"
        author = gets.chomp
        inventory.search_by_author(author)
      when 7
        puts "Enter book ISBN to search:"
        isbn = gets.chomp
        inventory.search_by_isbn(isbn)
      when 0
        break
      else
        puts "Please try again."
    end
  end
end

