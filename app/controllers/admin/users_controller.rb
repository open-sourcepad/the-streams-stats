class Admin::UsersController < AdminAppController
  before_action :find_obj, only: [:edit, :update, :destroy]

  def index
    @objs = User.order(:name)
  end

  def new
    @obj = User.new
  end

  def create
    @obj = User.new(permitted_params)
    if @obj.save
      redirect_to(admin_users_path, notice: 'Created!')
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @obj.update_attributes(permitted_params)
      redirect_to(admin_users_path, notice: 'Updated!')
    else
      render :edit
    end
  end

  def destroy
    redirect_to(admin_users_path, notice: 'Unable to delete!')
    # if @obj.destroy
    #   redirect_to(admin_users_path, notice: 'Deleted!')
    # else
    #   redirect_to(admin_users_path, notice: 'Unable to delete!')
    # end
  end

  private
    def permitted_params
      params.require(:user).permit(:name, :uuid, :role)
    end

    def find_obj
      @obj ||= User.find(params[:id])
    end
end