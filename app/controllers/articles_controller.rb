class ArticlesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_article, only: [:show, :edit, :update, :destroy, :report]
  before_action :authorize_user!, only: [:edit, :update, :destroy]

  def index
    @articles = Article.all
  end

  def show
    if @article.status == 'public' || @article.user == current_user
      render :show
    else
      redirect_to articles_path, alert: "You are not authorized to view this article"
    end
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(article_params)
    @article.image.attach(params[:image])
    @article.save 

    if @article.save
      redirect_to @article
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @article.update(article_params)
      @article.image.attach(params[:image]).save if params[:image].present?
      redirect_to @article
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @article.destroy
    redirect_to root_path, status: :see_other
  end

  def report
    @article.reports_count = @article.reports_count + 1
    if @article.save
      redirect_to @article, notice: 'Article has been reported.'
    else
      redirect_to @article, alert: 'Article could not be reported.'
    end
  end

  private
    def article_params
      params.require(:article).permit(:title, :body, :status, :image).merge(user: current_user)
    end

    def set_article
      @article = Article.find(params[:id])
    end

    def authorize_user!
      redirect_to articles_path, alert: "You are not authorized to do this article" unless @article.user == current_user
    end
end
