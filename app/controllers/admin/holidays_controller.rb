class Admin::HolidaysController < AdminAppController
  before_action :find_obj, only: [:edit, :update, :destroy]

  def index
    @objs = Holiday.order(:date) #current year only?
  end

  def new
    @obj = Holiday.new
  end

  def create
    @obj = Holiday.new(permitted_params)
    if @obj.save
      redirect_to(admin_holidays_path, notice: 'Created!')
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @obj.update_attributes(permitted_params)
      redirect_to(admin_holidays_path, notice: 'Updated!')
    else
      render :edit
    end
  end

  def destroy
  if @obj.destroy
      redirect_to(admin_holidays_path, notice: 'Deleted!')
    else
      redirect_to(admin_holidays_path, notice: 'Unable to delete!')
    end
  end

  private
    def permitted_params
      params.require(:holiday).permit(:name, :date)
    end

    def find_obj
      @obj ||= Holiday.find(params[:id])
    end
end