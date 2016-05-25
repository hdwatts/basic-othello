class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def index
    @game = Game.last
    if @game.nil?
      @game = Game.create(turn: 1, score_p1: 2, score_p2: 2, game_board: Game.create_board(8,8))
    end
  end

  def new
    if !params[:x].nil?
      x = params[:x].to_i
      x = x + 1 if x.odd?
    else
      x = 8
    end

    if !params[:y].nil?
      y = params[:y].to_i
      y = y + 1 if y.odd?
    else
      y = 8
    end
    
    Game.create(turn: 1, score_p1: 2, score_p2: 2, game_board: Game.create_board(x, y))
    redirect_to root_path
  end

  def move
    @game = Game.last
    @game.make_move(params[:x].to_i, params[:y].to_i)
    #render template: "application/_game", layout: false
    
    json = @game.board_to_json

    render json: json
  end
end