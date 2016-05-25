class Game < ActiveRecord::Base
  serialize :game_board, Array

  def make_move(x,y)
    puts "prepping turn #{self.turn}"
    if move(x,y)
      self.save
      puts "move made"
      puts "prepping ai turn #{self.turn}"
      
      if get_best_move
        puts "best move made"
      else
        puts "broken best move"
        if self.turn == 2
          self.turn = 1
        else
          self.turn = 2
        end
      end

      self.save
      puts "saved"
    end
  end

  def move(x,y)
    return false if self.game_board[x][y] != 0
    
    moved = false
    moved = true if flipLeft(x-1,y,turn,1)
    moved = true if flipRight(x+1,y,turn,1)
    moved = true if flipUp(x,y-1,turn,1)
    moved = true if flipDown(x,y+1,turn,1)
    moved = true if flipLeftDown(x-1,y+1,turn,1)
    moved = true if flipRightDown(x+1,y+1,turn,1)
    moved = true if flipLeftUp(x-1,y-1,turn,1)
    moved = true if flipRightUp(x+1,y-1,turn,1)

    if moved
      self.game_board[x][y] = turn
      calc_scores
      if self.turn == 2
        self.turn = 1
      else
        self.turn = 2
      end
      self.save
      return true
    end
    return false
  end

  def valid_move(x,y,b,turn)
    if b[x][y] != 0
      return false
    end
    if turn == 2
      valid_turn = 1 
    else
      valid_turn = 2
    end

    if !b[x+1].nil? && b[x+1][y] == valid_turn
      return true
    elsif !b[x-1].nil? && b[x-1][y] == valid_turn
      return true
    elsif !b[x][y-1].nil? && b[x][y-1] == valid_turn
      return true
    elsif !b[x][y+1].nil? && b[x][y+1] == valid_turn
      return true
    elsif !b[x-1].nil? && b[x-1][y-1].nil? && b[x-1][y-1] == valid_turn
      return true
    elsif !b[x+1].nil? && !b[x+1][y-1].nil? && b[x+1][y-1] == valid_turn
      return true
    elsif !b[x+1].nil? && !b[x+1][y+1].nil? && b[x+1][y+1] == valid_turn
      return true
    elsif !b[x-1].nil? && !b[x-1][y+1].nil? && b[x-1][y+1] == valid_turn
      return true
    end
    return false
  end

  def get_best_move
    backup = Marshal.load( Marshal.dump( self.game_board ) )
    x_len = backup.size
    y_len = backup[0].size
    sc_1 = 0
    sc_2 = 0
    best_x = -1
    best_y = -1

    x_len.times do |x|
      y_len.times do |y|
        if valid_move(x,y,backup,turn)
          moved = false
          moved = true if flipLeft(x-1,y,turn,1)
          moved = true if flipRight(x+1,y,turn,1)
          moved = true if flipUp(x,y-1,turn,1)
          moved = true if flipDown(x,y+1,turn,1)
          moved = true if flipLeftDown(x-1,y+1,turn,1)
          moved = true if flipRightDown(x+1,y+1,turn,1)
          moved = true if flipLeftUp(x-1,y-1,turn,1)
          moved = true if flipRightUp(x+1,y-1,turn,1)

          if moved
            self.game_board[x][y] = turn
            calc_scores
            if x == 0 || y == 0
               self.score_p1 += 99
               self.score_p2 += 99
            end
            if x == self.game_board.size - 1 || y == self.game_board[0].size - 1
              self.score_p1 += 99
              self.score_p2 += 99
            end
            if turn == 1
              if sc_1 < self.score_p1
                sc_1 = self.score_p1
                best_x = x
                best_y = y
              end
            else
              if sc_2 < self.score_p2
                sc_2 = self.score_p2
                best_x = x
                best_y = y
              end
            end
          end
          self.game_board = backup
        end
      end
    end
    self.game_board = backup
    
    #debugger
    if move(best_x, best_y)
      return true
    end
    
    return false
  end

  def flipRightUp(x,y,turn,distance)
    if y < 0 || x >= self.game_board.size || self.game_board[x][y] == 0
      return false
    end

    if self.game_board[x][y] == turn
      return true if distance > 1
      return false
    end

    if flipRightUp(x+1, y-1, turn, distance+1)
      self.game_board[x][y] = turn
      return true
    end
    return false
  end

  def flipRightDown(x,y,turn,distance)
    if y >= self.game_board[0].size || x >= self.game_board.size || self.game_board[x][y] == 0
      return false
    end

    if self.game_board[x][y] == turn
      return true if distance > 1
      return false
    end

    if flipRightDown(x+1, y+1, turn, distance+1)
      self.game_board[x][y] = turn
      return true
    end
    return false
  end

  def flipLeftUp(x,y,turn,distance)
    if y < 0 || x < 0 || self.game_board[x][y] == 0
      return false
    end

    if self.game_board[x][y] == turn
      return true if distance > 1
      return false
    end

    if flipLeftUp(x-1, y-1, turn, distance+1)
      self.game_board[x][y] = turn
      return true
    end
    return false
  end


  def flipLeftDown(x,y,turn,distance)
    if y >= self.game_board[0].size || x < 0 || self.game_board[x][y] == 0
      return false
    end

    if self.game_board[x][y] == turn
      return true if distance > 1
      return false
    end

    if flipLeftDown(x-1, y+1, turn, distance+1)
      self.game_board[x][y] = turn
      return true
    end
    return false
  end

  def flipDown(x,y,turn,distance)
    if y >= self.game_board[0].size || self.game_board[x][y] == 0
      return false
    end

    if self.game_board[x][y] == turn
      return true if distance > 1
      return false
    end

    if flipDown(x, y+1, turn, distance+1)
      self.game_board[x][y] = turn
      return true
    end
    return false
  end

  def flipUp(x,y,turn,distance)
    if y < 0 || self.game_board[x][y] == 0
      return false
    end

    if self.game_board[x][y] == turn
      return true if distance > 1
      return false
    end

    if flipUp(x,y-1,turn, distance+1)
      self.game_board[x][y] = turn
      return true
    end
    return false
  end

  def flipRight(x,y,turn,distance)
    if x >= self.game_board.size || self.game_board[x][y] == 0
      return false
    end

    if self.game_board[x][y] == turn
      return true if distance > 1
      return false
    end

    if flipRight(x+1, y, turn, distance+1)
      self.game_board[x][y] = turn
      return true
    end
    return false
  end

  def flipLeft(x,y,turn,distance)
    if x < 0 || self.game_board[x][y] == 0
      return false
    end

    if self.game_board[x][y] == turn
      return true if distance > 1
      return false
    end

    if flipLeft(x-1, y, turn, distance+1)
      self.game_board[x][y] = turn
      return true
    end
    return false
  end

  def print_square(b, x, y)
    str = "<div class='box' data-x='#{y}' data-y='#{x}'>"

    if b[y][x] == 1
      str << "<div class='piece black'></div>"
    elsif b[y][x] == 2
      str << "<div class='piece white'></div>"
    else
      str << "<div class='piece'></div>"
    end
    str << "</div>"

    str
  end

  def print_turn
    return "Black" if self.turn == 1
    return "White" if self.turn == 2
  end

  def print_board
    b = game_board
    x_len = b.size
    y_len = b[0].size
    str = ""
    x_len.times do |x|
      str << "<div class='row'>"
      y_len.times do |y|
        str << print_square(b,x,y)
      end
      str << "</div>"
    end

    str.html_safe
  end

  def board_to_json
    hash = {board: game_board, turn: turn, score_p1: score_p1, score_p2: score_p2}
    JSON.generate(hash)
  end

  def calc_scores
    b = game_board
    x_len = b.size
    y_len = b[0].size
    sc_1 = 0
    sc_2 = 0

    x_len.times do |x|
      y_len.times do |y|
        sc_1 += 1 if b[y][x] == 1
        sc_2 += 1 if b[y][x] == 2
      end
    end

    self.score_p1 = sc_1
    self.score_p2 = sc_2
  end

  def self.create_board(x_len, y_len)
    b = []
    x_len.times do |x|
      b[x] = []
      y_len.times do |y|
        if ( x == x_len / 2 && y == y_len / 2 ) ||
           ( x == ( x_len / 2 ) - 1 && y == ( y_len / 2 ) - 1 )

          b[x] << 1
        elsif ( x == ( x_len / 2 ) - 1 && y == y_len / 2 ) ||
              ( x == ( x_len / 2) && ( y == (y_len / 2 ) -1 ) )
          b[x] << 2
        else
          b[x] << 0
        end
      end
    end

    b
  end
end
