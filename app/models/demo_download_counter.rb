class DemoDownloadCounter

  attr_accessor :demo, :user

  def initialize(demo, user)
    self.demo = demo
    self.user = user
  end

  def count_download
    if user.present? && !demo.downloaded_by_user?(user)
      track_user_downloaded_demo && demo.increment_download_count!
    end
  end

  def track_user_downloaded_demo
    download = DemoDownload.new({user: user, demo: demo})
    download.save
  end

end
