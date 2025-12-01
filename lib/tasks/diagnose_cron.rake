namespace :diagnose do
  desc "Diagnostiquer pourquoi les jobs cron ne se lancent pas"
  task :cron => :environment do
    puts "\n" + "=" * 60
    puts "DIAGNOSTIC DES JOBS CRON"
    puts "=" * 60
    
    # 1. Vérifier si sidekiq-cron est disponible
    puts "\n1. Vérification de sidekiq-cron:"
    if defined?(Sidekiq::Cron::Job)
      puts "   ✅ Sidekiq::Cron::Job est défini"
    else
      puts "   ❌ Sidekiq::Cron::Job n'est PAS défini"
      puts "   → Installez la gem: bundle install"
      exit 1
    end
    
    # 2. Vérifier les jobs chargés
    puts "\n2. Jobs chargés dans Sidekiq:"
    jobs = Sidekiq::Cron::Job.all
    if jobs.empty?
      puts "   ❌ Aucun job trouvé!"
      puts "   → Les jobs ne sont pas chargés depuis schedule.yml"
      puts "   → Redémarrez Sidekiq pour charger les jobs"
    else
      puts "   ✅ #{jobs.count} job(s) trouvé(s):"
      jobs.each do |job|
        puts "\n   Job: #{job.name}"
        puts "     - Cron: #{job.cron}"
        puts "     - Classe: #{job.klass}"
        puts "     - Status: #{job.status}"
        puts "     - Activé: #{job.enabled? ? '✅' : '❌'}"
        puts "     - Dernière exécution: #{job.last_enqueue_time || 'Jamais'}"
        
        # Calculer la prochaine exécution
        begin
          next_time = job.parsed_cron.next_time
          if next_time
            puts "     - Prochaine exécution: #{next_time} (#{((next_time - Time.current) / 60).round} minutes)"
          else
            puts "     - Prochaine exécution: Non calculable"
          end
        rescue => e
          puts "     - Prochaine exécution: Erreur - #{e.message}"
        end
      end
    end
    
    # 3. Vérifier le fuseau horaire
    puts "\n3. Fuseau horaire:"
    puts "   - Time.zone: #{Time.zone.name}"
    puts "   - Heure actuelle: #{Time.current}"
    puts "   - Heure UTC: #{Time.now.utc}"
    
    # 4. Vérifier schedule.yml
    puts "\n4. Contenu de schedule.yml:"
    schedule_file = Rails.root.join("config", "schedule.yml")
    if File.exist?(schedule_file)
      schedule = YAML.load_file(schedule_file)
      puts "   ✅ Fichier trouvé"
      schedule.each do |job_name, config|
        puts "\n   #{job_name}:"
        puts "     - cron: #{config['cron']}"
        puts "     - class: #{config['class']}"
        puts "     - queue: #{config['queue']}"
        puts "     - args: #{config['args'].inspect}"
      end
    else
      puts "   ❌ Fichier non trouvé: #{schedule_file}"
    end
    
    # 5. Test manuel du worker
    puts "\n5. Test manuel du worker:"
    begin
      result = LottoDrawWorker.new.perform("evening")
      puts "   ✅ Worker fonctionne correctement"
    rescue => e
      puts "   ❌ Erreur lors du test: #{e.class} - #{e.message}"
    end
    
    # 6. Vérifier si Sidekiq est en cours d'exécution
    puts "\n6. Processus Sidekiq:"
    sidekiq_pids = `pgrep -f "sidekiq"`.strip
    if sidekiq_pids.empty?
      puts "   ❌ Sidekiq n'est PAS en cours d'exécution"
      puts "   → Lancez Sidekiq avec: bundle exec sidekiq"
    else
      puts "   ✅ Sidekiq est en cours d'exécution (PID: #{sidekiq_pids.split("\n").join(', ')})"
    end
    
    puts "\n" + "=" * 60
    puts "RECOMMANDATIONS:"
    puts "=" * 60
    
    if jobs.empty?
      puts "1. Redémarrez Sidekiq pour charger les jobs depuis schedule.yml"
    else
      jobs.each do |job|
        unless job.enabled?
          puts "1. Le job '#{job.name}' est désactivé. Activez-le avec:"
          puts "   bundle exec rails runner \"Sidekiq::Cron::Job.find('#{job.name}').enable!\""
        end
      end
    end
    
    puts "2. Vérifiez les logs de Sidekiq: tail -f log/sidekiq.log"
    puts "3. Vérifiez le dashboard Sidekiq: http://localhost:3000/sidekiq (onglet Cron)"
    puts "4. Testez manuellement: bundle exec rake lotto:draw:test[evening]"
    
    puts "\n"
  end
end

