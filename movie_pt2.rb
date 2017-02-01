# Name: Nick April
# Email: napril@brandeis.edu
# Date: 31st January 2016
# COSI 166B
# (PA) Movies Part 2

class MovieData

  def initialize(filename)
    @filename = filename
    @dataset = load_data(filename)
    @rating_hash = create_rating_hash()
    @user_hash = create_user_hash()
  end

  # creates an array dataset containing arrays that represent each line of u.data
  # (includes user_id, movie_id, rating and timestamp)
  def load_data(filename)
    dataset = Array.new
    file = open(filename, "r")
    file.each_line do |l|
      data = l.split(' ')
      dataset.push(data)
    end
    file.close
    dataset
  end

  #creates a hash with each movie tied with all the ratings associated with it
  def create_rating_hash()
    movie_rating_hash = Hash.new
    @dataset.each do |data|
      if !movie_rating_hash.has_key?(data[1])   # Checks if the movie_id has already been hashed
        movie_rating_hash[data[1]] = Array.new
      end
      movie_rating_hash[data[1]].push(data[2])  # Adds a new rating to the movie
    end
    movie_rating_hash
  end

  # creates a hash of users with all of the movies each has rated and the rating they gave it
  def create_user_hash()
    user_hash = Hash.new
    @dataset.each do |info|
      if !user_hash.has_key?(info[0])
        user_hash[info[0]] = Hash.new
      end
      user_hash[info[0]][info[1]] = info[2]
    end
    user_hash
  end

  # popularity is determined as the average rating received by the movie multiplied by the number
  # of ratings it received.
  def popularity(movie_id)
    total = 0.0
    number = 0.0

    movie = @rating_hash[movie_id]
    movie.each do |rating|
      rating = rating.to_i
      total += rating
      number += 1
    end

    average = total / number
    popularity = average * number

  end

  # connects each movie with it's popularity rating using the popularity method
  # returns the list of most popular movies in descending order
  def popularity_list()
    pop_hash = Hash.new
    @rating_hash.each do |id|
      pop_hash[id] = popularity(id)
    end
    pop_hash = Hash[pop_hash.sort_by{|_or_k, v| v}.reverse]
    pop_hash.keys
  end

  # similarity between two users is calculated by summing the average rating for all common movies
  def similarity(user1, user2)
    count = 0.0
    total_average_ratings = 0.0 #HERE

    @user_hash[user1].each do |mov, rat|
      rat = rat.to_i
      if @user_hash[user2].has_key?(mov)
        count += 1
        total_average_ratings += (rat + @user_hash[user2][mov].to_i) / 2
      end
    end

    if count == 0.0
      similarity = 0.0
    else
      similarity = total_average_ratings / count
    end
  end


  # calculates similarity for all the users when compared to user1
  def most_similar(user1)
    most_sim = Hash.new

    @dataset.each do |data|
      user2 = data[0]
      if !user1.equal?(user2)
        most_sim[user2] = similarity(user1, user2)
      end
    end

    most_sim = Hash[most_sim.sort_by{|k, v| v}.reverse]
    most_sim.keys
  end

  # Returns the rating a user gave a specific movie
  def rating(user, movie)
    if @user_hash[user][movie] == nil
      return 0
    else
      return @user_hash[user][movie]
    end
  end

  # Predicts what rating a user would give to a movie based on what other
  # users rated that movie
  def prediction(user, movie)
    temp = 0.0
    count = 0.0
    @user_hash.each do |u, m|
      if m.has_key?(movie)
        # puts "\n m[movie]: #{m[movie].to_i}\n"
        temp += m[movie].to_f * similarity(user, u)
        count += 1
      end
    end
    return (temp / (count * 5)).to_f
  end

  # returns the list of movies rated by a given user
  def movie(u)
    all_mov = Array.new
    @user_hash[u].each do |m,r|
      all_mov.push(movie_id)
    end
    return all_mov
  end

  #returns a listof all the users who watched a given movie_id
  def watched(m)
    all_usr = Array.new
    @user_hash.each do |u, mr|
      if mr.has_key?(m)
        all_usr.push(u)
      end
    end
    return all_usr
  end

  def test_run(k)
    count = 0
    testObj = MovieTest.new
    @dataset.each do |d|
      predict = prediction(d[0], d[1])
      testObj.load_data(d[0], d[1], d[2], predict)
      count +=1
      if count >=k
        break
      end
    end
    return testObj
  end
end


class MovieTest

  def initialize()
    @final_list = Array.new
  end

  #loads the required data to the finalList
  def load_data(user, movie, rating, predict)
    data = Array.new([user, movie, rating, predict])
    @final_list.push(data)
  end

  # returns the average predication error
  def mean()
    er = 0
    @final_list.each do |data|
      er += (data[2].to_f - data[3].to_f).abs
    end
    mean = er / @final_list.length
  end

  # returns standard deviation of the error
  def standard_dev()
    sum = 0
    average = mean()
    @final_list.each do |d|
      er = (d[2].to_f - d[3].to_f).abs
      sum += (er - average)**2
    end
    std = Math.sqrt(sum / (@final_list.length - 1))
  end

  # returns the root mean square error of the prediction
  def rms()
    sum_diff = 0
    @final_list.each do |d|
      sum_diff += (d[3].to_f - d[2].to_f)**2
    end
    rms = Math.sqrt(sum_diff / @final_list.length)
  end

  # returns an array of the predictions in the form [u,m,r,p].
  def to_a()
    @final_list
  end
end

z = MovieData.new("ml-100k/u1.base")
#
# puts "Top 10 popular movie_id are:"
# puts z.popularity_list[0..9]
# puts
# puts "Top 10 users most similar to user 7 (example) are:"
# puts z.most_similar("7")[0..9]

puts ""
puts Time.now
puts ""
t = z.test_run(800)
puts "mean prediction error: #{t.mean}"
puts "std of the error: #{t.standard_dev}"
puts "rms error of the prediction: #{t.rms}"
# puts "to_a: #{t.to_a}"
puts ""
puts Time.now
puts ""

# 8000/58 = 137
# 4000/23 = 173
# 800/5 = 160
