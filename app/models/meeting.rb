class Meeting < ActiveRecord::Base
  include Listable
  include Invitable

  resourcify :permissions, role_cname: 'Permission', role_table_name: :permission

  has_many :organisers, -> { where("permissions.name" => "organiser") }, through: :permissions, source: :members
  belongs_to :venue, class_name: "Sponsor"
  has_many :invitations, foreign_key: "meeting_id", class_name: "MeetingInvitation"

  validates :date_and_time, :venue, presence: true

  before_save :set_slug

  def title
    self.name or "#{I18n.l(date_and_time, format: :month)} Meeting"
  end

  def to_param
    slug
  end

  def date
    I18n.l(date_and_time, format: :dashboard)
  end

  def attending?(member)
    invitations.accepted.where(member: member).present?
  end

  def not_full
    invitations.accepted.count < spaces
  end

  private

  def set_slug
    self.slug = "#{I18n.l(date_and_time, format: :year_month).downcase}-#{title.parameterize}" if self.slug.nil?
  end
end
