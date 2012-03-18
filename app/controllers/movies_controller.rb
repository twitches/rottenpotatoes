class MoviesController < ApplicationController
  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  @@session_keys = [:ratings, :sort]

  def index
    @all_ratings = Movie.ratings
    # Grab the subset of our param and session keys that we care about.
    param_keys = params.keys & @@session_keys
    session_keys = session.keys & @@session_keys
    if (param_keys | session_keys).size != param_keys.size
      # There are session parameters that aren't in params.
      params.update(Hash[session_keys.zip(session.values_at(session_keys))])
      redirect_to
    end
    # Update our session parameters
    session.update(params)

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
