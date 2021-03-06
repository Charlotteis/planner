class Admin::MeetingsController < Admin::ApplicationController
  before_action :set_meeting, except: [:new, :create]

  def new
    @meeting = Meeting.new
  end

  def create
    @meeting = Meeting.new(meeting_params)
    set_organisers(organiser_ids)

    if @meeting.save
      redirect_to [:admin, @meeting], notice: 'Meeting successfully created.'
    else
      render :new, notice: 'Error'
    end
  end

  def show
    @invitations = @meeting.invitations.accepted
  end

  def edit
  end

  def update
    set_organisers(organiser_ids)

    if @meeting.update_attributes(meeting_params)
      redirect_to [:admin, @meeting], notice: "You have successfully updated the details of this meeting"
    else
      render 'edit', notice: "Something went wrong"
    end
  end

  def attendees_emails
    meeting = MeetingPresenter.new(@meeting)
    return render text: meeting.attendees_emails if request.format.text?

    redirect_to admin_meeting_path(@meeting)
  end

  private

  def set_meeting
    @meeting = Meeting.find_by_slug(params[:id])
  end

  def meeting_params
    params.require(:meeting).permit(:name, :description, :slug, :date_and_time, :invitable, :spaces, :venue_id, :sponsor_id)
  end

  def organiser_ids
    params[:meeting][:organisers]
  end

  def grant_organiser_access(organiser_ids=[])
    organiser_ids.each { |id| Member.find(id).add_role(:organiser, @meeting) }
  end

  def revoke_organiser_access(organiser_ids)
    (@meeting.organisers.pluck(:id).map(&:to_s) - organiser_ids).each do |id|
      Member.find(id).revoke(:organiser, @meeting)
    end
  end

  def set_organisers(organiser_ids)
    organiser_ids.reject!(&:empty?)
    grant_organiser_access(organiser_ids)
    revoke_organiser_access(organiser_ids)
  end
end