class Admin::DayOffsController < AdminAppController
  before_action :find_obj, only: [:edit, :update, :destroy]

  def index
    @objs = DayOff.order(start_date: :desc)
  end

  def new
    @obj = DayOff.new
  end

  def create
    @obj = DayOff.new(permitted_params)
    if @obj.save
      redirect_to(admin_day_offs_path, notice: 'Created!')
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @obj.update_attributes(permitted_params)
      redirect_to(admin_day_offs_path, notice: 'Updated!')
    else
      render :edit
    end
  end

  def destroy
  if @obj.destroy
      redirect_to(admin_day_offs_path, notice: 'Deleted!')
    else
      redirect_to(admin_day_offs_path, notice: 'Unable to delete!')
    end
  end

  private
    def permitted_params
      params.require(:day_off).permit(:user, :start_date, :end_date, :status, :reason, :note)
    end

    def find_obj
      @obj ||= DayOff.find(params[:id])
    end
end