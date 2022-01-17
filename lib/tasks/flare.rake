require 'kmaps_engine/flare_utils'
require 'uri'

namespace :subjects_engine do
  namespace :flare do
    desc "Create solr documents in filesystem. rake subjects_engine:flare:fs_reindex_all [FROM=fid] [TO=fid] [FIDS=fid1,fid2,...] [DAYLIGHT=daylight] [LOG_LEVEL=0..5]"
    task fs_reindex_all: :environment do
      pathname = Pathname.new(SubjectsIntegration::Feature.get_url)
      KmapsEngine::FlareUtils.new("log/reindexing_#{Rails.env}.log", ENV['LOG_LEVEL']).reindex_all(from: ENV['FROM'], to: ENV['TO'], fids: ENV['FIDS'], daylight: ENV['DAYLIGHT']) do |f|
        URI.open(pathname.join('solr', "#{f.fid}.json").to_s, read_timeout: 360)
      end
    end
  end
end