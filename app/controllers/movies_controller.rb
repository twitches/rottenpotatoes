class MoviesController < ApplicationController
  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  @@session_keys = %w[ratings sort]
  def get_session(hsh)
    valid = @@session_keys.
      select {|key| hsh.has_key? key}.
      map { |key| [key, hsh[key]]}
    Hash[valid]
  end

  def index
    @all_ratings = Movie.ratings
    valid_params = get_session(params)
    valid_session = get_session(session)
    if (valid_params.keys | valid_session.keys).size != valid_params.size
      # There are session parameters that aren't in params.
      valid_session.update(valid_params)
      redirect_to params.merge! valid_session
    end
    session.update(valid_params)

    # Kind of need this to be set.
    if session[:ratings]
      @ratings = session[:ratings]
    else
      @ratings = Hash[@all_ratings.zip([1]*@all_ratings.size)]
    end
    sort = session[:sort] ? session[:sort].to_sym : nil
    @movies = Movie.order(sort).
      find_all_by_rating(@ratings.keys)
    @header_class = { sort => 'hilite'}
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
