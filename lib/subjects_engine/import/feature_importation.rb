require 'kmaps_engine/import/feature_importation'

module SubjectsEngine
  class FeatureImportation < KmapsEngine::FeatureImportation
    # Currently supported fields:
    # features.fid, features.old_pid, features.position, feature_names.delete, feature_names.is_primary.delete
    # i.feature_names.existing_name
    # i.feature_names.name, i.feature_names.position, i.feature_names.is_primary,
    # i.languages.code/name, i.writing_systems.code/name, i.alt_spelling_systems.code/name
    # i.phonetic_systems.code/name, i.orthographic_systems.code/name, BOTH DEPRECATED, INSTEAD USE: i.feature_name_relations.relationship.code
    # i.feature_name_relations.parent_node, i.feature_name_relations.is_translation, 
    # i.feature_name_relations.is_phonetic, i.feature_name_relations.is_orthographic, BOTH DEPRECATED AND USELESS
    # i.geo_code_types.code/name, i.feature_geo_codes.geo_code_value, i.feature_geo_codes.info_source.id/code,
    # feature_relations.delete, [i.]feature_relations.related_feature.fid, [i.]feature_relations.type.code,
    # [i.]perspectives.code/name, feature_relations.replace
    # descriptions.delete, [i.]descriptions.title, [i.]descriptions.content, [i.]descriptions.author.fullname


    # Fields that accept time_units:
    # features, i.feature_names[.j], [i.]feature_types[.j], i.kmaps[.j], [i.]kXXX[.j], i.feature_geo_codes[.j], [i.]feature_relations[.j], [i.]shapes[.j]

    # time_units fields supported:
    # .time_units.[start.|end.]date, .time_units.[start.|end.]certainty_id, .time_units.season_id,
    # .time_units.calendar_id, .time_units.frequency_id

    # Fields that accept info_source:
    # [i.]feature_names[.j], [i.]feature_types[.j], i.feature_geo_codes[.j], [i.]kXXX[.j], i.kmaps[.j], [i.]feature_relations[.j], [i.]shapes[.j]

    # info_source fields:
    # .info_source.id/code, info_source.note
    # When info source is a document: .info_source[.i].volume, info_source[.i].pages
    # When info source is an online resource: .info_source[.i].path, .info_source[.i].name

    # Fields that accept note:
    # [i.]feature_names[.j], i.kmaps[.j], [i.]kXXX[.j], [i.]feature_types[.j], [i.]feature_relations[.j], [i.]shapes[.j], i.feature_geo_codes[.j]

    # Note fields:
    # .note

    def do_feature_import(filename:, task_code:, from:, to:, log_level:)
      puts "#{Time.now}: Starting importation."
      task = ImportationTask.find_by(task_code: task_code)
      task = ImportationTask.create(:task_code => task_code) if task.nil?
      self.log = ActiveSupport::Logger.new("log/import_#{task_code}_#{Rails.env}.log")
      self.log.level = log_level.nil? ? Rails.logger.level : log_level.to_i
      self.log.debug "#{Time.now}: Starting importation."
      self.spreadsheet = task.spreadsheets.find_by(filename: filename)
      self.spreadsheet = task.spreadsheets.create(:filename => filename, :imported_at => Time.now) if self.spreadsheet.nil?
      interval = 100
      rows = CSV.read(filename, headers: true, col_sep: "\t")
      current = from.blank? ? 0 : from.to_i
      to_i = to.blank? ? rows.size : to.to_i
      ipc_reader, ipc_writer = IO.pipe('ASCII-8BIT')
      ipc_writer.set_encoding('ASCII-8BIT')
      puts "#{Time.now}: Processing features..."
      STDOUT.flush
      while current<to_i
        limit = current + interval
        limit = to_i if limit > to_i
        limit = rows.size if limit > rows.size
        sid = Spawnling.new do
          begin
            self.log.debug { "#{Time.now}: Spawning sub-process #{Process.pid}." }
            ipc_reader.close
            feature_ids_with_changed_relations = Array.new
            features_ids_to_cache = Array.new
            for i in current...limit
              row = rows[i]
              self.fields = row.to_hash.delete_if{ |key, value| value.blank? }
              self.fields.each_value(&:strip!)
              next unless self.get_feature(i+1)
              self.progress_bar(i, to_i, self.feature.pid)
              features_ids_to_cache << self.feature.id
              self.process_feature
              self.process_names(44)
              self.process_geocodes(4)
              feature_ids_with_changed_relations += self.process_feature_relations(15)
              self.process_descriptions(3)
              self.process_captions(2)
              self.process_summaries(2)
              self.feature.update_attributes({:is_blank => false, :is_public => true})
              #rescue  Exception => e
              #  puts "Something went wrong with feature #{self.feature.pid}!"
              #  puts e.to_s
              #end
              if self.fields.empty?
                self.log.debug { "#{Time.now}: #{self.feature.pid} processed." }
              else
                self.log.warn { "#{Time.now}: #{self.feature.pid}: the following fields have been ignored: #{self.fields.keys.join(', ')}" }
              end
            end
            ipc_hash = {for_relations: feature_ids_with_changed_relations, to_cache: features_ids_to_cache}
            data = Marshal.dump(ipc_hash)
            ipc_writer.puts(data.length)
            ipc_writer.write(data)
            ipc_writer.flush
            ipc_writer.close
          rescue Exception => e
            STDOUT.flush
            self.log.fatal { "#{Time.now}: An error occured when processing #{Process.pid}:" }
            self.log.fatal { e.message }
            self.log.fatal { e.backtrace.join("\n") }
          end
        end
        Spawnling.wait([sid])
        current = limit
      end
      ipc_writer.close
      sid = Spawnling.new do
        begin
          self.log.debug { "#{Time.now}: Spawning sub-process #{Process.pid}." }
          puts "#{Time.now}: Updating hierarchies for changed relations..."
          STDOUT.flush
          # running triggers on feature_relation
          feature_ids_with_changed_relations = Array.new
          features_ids_to_cache = Array.new
          while size_s = ipc_reader.gets do
            size = size_s.to_i
            data = ipc_reader.read(size)
            ipc_hash = Marshal.load(data)
            feature_ids_with_changed_relations += ipc_hash[:for_relations]
            features_ids_to_cache += ipc_hash[:to_cache]
          end
          feature_ids_with_changed_relations.uniq!
          self.log.debug { "#{Time.now}: Will update hierarchy for the following feature ids (NOT FIDS):\n#{feature_ids_with_changed_relations.to_s}." }
          features_ids_to_cache += feature_ids_with_changed_relations
          features_ids_to_cache.uniq!
          self.log.debug { "#{Time.now}: Will reindex the following feature ids (NOT FIDS):\n#{features_ids_to_cache.to_s}." }
          feature_ids_with_changed_relations.each_index do |i|
            id = feature_ids_with_changed_relations[i]
            feature = Feature.find(id)
            self.progress_bar(i, feature_ids_with_changed_relations.size, feature.pid)
            #this has to be added to places dictionary!!!
            #feature.update_cached_feature_relation_categories
            feature.update_hierarchy
            self.log.debug { "#{Time.now}: Updated hierarchy for #{feature.fid}." }
          end
          puts "#{Time.now}: Reindexing changed features..."
          STDOUT.flush
          features_ids_to_cache.each_index do |i|
            id = features_ids_to_cache[i]
            feature = Feature.find(id)
            self.progress_bar(i, features_ids_to_cache.size, feature.pid)
            feature.index
            self.log.debug "#{Time.now}: Reindexed feature #{feature.fid}."
          end
          Feature.commit
          puts "#{Time.now}: Importation done."
          self.log.debug "#{Time.now}: Importation done."
          STDOUT.flush
        rescue Exception => e
          STDOUT.flush
          self.log.fatal { "#{Time.now}: An error occured when processing #{Process.pid}:" }
          self.log.fatal { e.message }
          self.log.fatal { e.backtrace.join("\n") }
        end
      end
      Spawnling.wait([sid])
    end    
  end
end