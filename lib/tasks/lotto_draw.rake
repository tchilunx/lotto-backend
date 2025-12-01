namespace :lotto do
  namespace :draw do
    desc "Lister les tirages planifiés dans Sidekiq Cron"
    task :list_scheduled => :environment do
      if defined?(Sidekiq::Cron::Job)
        jobs = Sidekiq::Cron::Job.all
        if jobs.any?
          puts "\n=== Jobs Cron Planifiés ==="
          jobs.each do |job|
            puts "\nNom: #{job.name}"
            puts "  Cron: #{job.cron}"
            puts "  Classe: #{job.klass}"
            begin
              puts "  Queue: #{job.que || job.queue_name || 'default'}"
            rescue
              puts "  Queue: default"
            end
            puts "  Args: #{job.args.inspect}"
            puts "  Status: #{job.status}"
            puts "  Dernière exécution: #{job.last_enqueue_time || 'Jamais'}"
            begin
              next_time = job.next_time
              puts "  Prochaine exécution: #{next_time || 'Non planifié'}"
            rescue
              puts "  Prochaine exécution: (non disponible)"
            end
          end
        else
          puts "❌ Aucun job cron trouvé!"
          puts "   Vérifiez que Sidekiq est en cours d'exécution et que schedule.yml est chargé."
        end
      else
        puts "❌ Sidekiq::Cron::Job n'est pas défini."
        puts "   Assurez-vous que la gem sidekiq-cron est installée."
      end
    end

    desc "Recharger les jobs depuis schedule.yml"
    task :reload => :environment do
      if defined?(Sidekiq::Cron::Job)
        schedule_file = Rails.root.join("config", "schedule.yml")
        if File.exist?(schedule_file)
          # Supprimer les anciens jobs
          Sidekiq::Cron::Job.all.each(&:destroy)
          
          # Charger les nouveaux jobs
          schedule = YAML.load_file(schedule_file)
          Sidekiq::Cron::Job.load_from_hash schedule
          
          puts "✅ #{schedule.keys.count} jobs rechargés depuis schedule.yml:"
          schedule.keys.each do |job_name|
            puts "   - #{job_name}"
          end
        else
          puts "❌ schedule.yml non trouvé à #{schedule_file}"
        end
      else
        puts "❌ Sidekiq::Cron::Job n'est pas défini."
      end
    end

    desc "Tester manuellement un tirage [session=morning|evening]"
    task :test, [:session] => :environment do |t, args|
      session = args[:session] || "evening"
      puts "🧪 Test du tirage pour la session: #{session}"
      
      begin
        draw = LottoDrawService.generate_draw(session, Date.today)
        puts "✅ Tirage créé avec succès!"
        puts "   ID: #{draw.id}"
        puts "   Numéros: #{draw.numbers.inspect}"
        puts "   Date: #{draw.draw_date}"
        puts "   Session: #{draw.session}"
      rescue LottoDrawService::DrawAlreadyExistsError => e
        puts "⚠️  #{e.message}"
        existing_draw = LottoDraw.find_by(session: session, draw_date: Date.today)
        if existing_draw
          puts "   Tirage existant: ID #{existing_draw.id}, Numéros: #{existing_draw.numbers.inspect}"
        end
      rescue => e
        puts "❌ Erreur: #{e.class} - #{e.message}"
        puts e.backtrace.first(5).join("\n")
      end
    end

    desc "Lancer le worker manuellement [session=morning|evening]"
    task :run_worker, [:session] => :environment do |t, args|
      session = args[:session] || "evening"
      puts "🚀 Lancement du worker pour la session: #{session}"
      
      begin
        LottoDrawWorker.new.perform(session)
        puts "✅ Worker exécuté avec succès!"
      rescue => e
        puts "❌ Erreur: #{e.class} - #{e.message}"
        puts e.backtrace.first(10).join("\n")
      end
    end
  end
end

