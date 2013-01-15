require 'couchrest'

module Caster

  module MetadataStore

    private
    def init_design_doc db
      db.save_doc({
           '_id' => "_design/#{Caster.config['metadata']['design_doc_id']}",
           :views => {
               :meta_doc => {
                   :map => "function(doc) { if (doc.#{Caster.config['metadata']['key'].first[0]} == '#{Caster.config['metadata']['key'].first[1]}') emit (doc._id, doc); }"
               }
           }
       }) rescue nil
    end

    def get_metadoc db
      init_design_doc db
      db.view("#{Caster.config['metadata']['design_doc_id']}/meta_doc")['rows'][0]['value']
      rescue
        db.save_doc({ Caster.config['metadata']['key'].first[0] => Caster.config['metadata']['key'].first[1] })['id']
    end
  end
end
