require 'redmine'

module BOMFixQueriesPatch
  def self.included(base)
    base.send(:include, InstanceMethods)

    base.class_eval do
      unloadable
      alias_method_chain :query_to_csv, :bom
    end
  end
  
  module InstanceMethods
    def query_to_csv_with_bom(*args)
      ret = query_to_csv_without_bom(*args)
      if l(:general_csv_encoding) == "UTF-8"
        ret = "\xEF\xBB\xBF".force_encoding("UTF-8")+ret
      end
      ret
    end
  end
end

Rails.application.config.to_prepare do
  require_dependency 'queries_helper'

  unless QueriesHelper.included_modules.include? BOMFixQueriesPatch
    QueriesHelper.send(:include, BOMFixQueriesPatch)
  end
end

Redmine::Plugin.register :redmine_csv_with_bom do
  name 'Redmine CSV with BOM plugin'
  author 'Tomita Masahiro, Sergey Prosin, Yuri Rumega'
  description 'This is a plugin for Redmine to prepend BOM to CSV'
  version '0.0.2'
  url 'http://github.com/Rumega/redmine_csv_with_bom'
  author_url 'http://github.com/tmtm'
end
