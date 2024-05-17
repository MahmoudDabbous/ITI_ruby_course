class Article < ApplicationRecord
  include Visible
  before_save :check_reports_count

  has_many :comments, dependent: :destroy
  belongs_to :user

  validates :title, presence: true
  validates :body, presence: true, length: { minimum: 10 }
  validates :user, presence: true
  has_one_attached :image

  private

  def check_reports_count
    if reports_count >= 3
      self.status = 'archived'
    end
  end
end
