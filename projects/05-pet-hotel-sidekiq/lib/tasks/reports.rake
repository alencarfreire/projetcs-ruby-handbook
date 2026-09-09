namespace :reports do
  desc "Enfileira o relatório diário de ocupação para cada user"
  task daily: :environment do
    User.find_each do |user|
      OccupancyReportJob.perform_later(user.id)
    end
  end
end
