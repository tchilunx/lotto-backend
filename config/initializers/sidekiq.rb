Sidekiq.configure_server do |config|
  config.on(:startup) do
    schedule_file = Rails.root.join("config", "schedule.yml")

    if File.exist?(schedule_file) && defined?(Sidekiq::Cron::Job)
      schedule = YAML.load_file(schedule_file)

      # Convertir 'class' en 'klass' pour sidekiq-cron si nécessaire
      schedule.each do |job_name, job_config|
        job_config["klass"] = job_config.delete("class") if job_config["class"]
      end

      Sidekiq::Cron::Job.load_from_hash schedule

      Rails.logger.info "=" * 50
      Rails.logger.info "Sidekiq: Chargement des jobs cron depuis schedule.yml"
      Rails.logger.info "=" * 50
      schedule.each do |job_name, job_config|
        cron = job_config["cron"] || job_config[:cron]
        klass = job_config["klass"] || job_config[:klass] || job_config["class"]
        Rails.logger.info "  - #{job_name}: #{cron} -> #{klass}"

        # Vérifier et activer le job
        job = Sidekiq::Cron::Job.find(job_name)
        if job
          job.enable! unless job.enabled?
          Rails.logger.info "    Status: #{job.status} (activé)"
        end
      end
      Rails.logger.info "=" * 50
    else
      Rails.logger.warn "Sidekiq: schedule.yml non trouvé ou Sidekiq::Cron::Job non défini"
      Rails.logger.warn "  Fichier: #{schedule_file}"
      Rails.logger.warn "  Sidekiq::Cron::Job défini: #{defined?(Sidekiq::Cron::Job)}"
    end
  end
end
