module CardLib
  module References
    module ClassMethods 
    end

    protected 
    def update_references_on_create   
      # FIXME: bogus blank default content is set on hard_templated cards...
      content = self.template ? self.template.content : self.content
      #warn "RUNNING UPDATE ON CREATE type = #{self.type} template = #{template.name} "
      
      WikiReference.update_on_create(self)  
      Renderer.instance.render(self, content, update_references=true)   
      expire_templatee_references
      #hard_templatees.each {|c| Renderer.instance.render(c, self.content, update_references=true) }
    end
    
    def update_references_on_update
      Renderer.instance.render(self, self.content, update_references=true) 
      expire_templatee_references
      #hard_templatees.each {|c| Renderer.instance.render(c, self.content, update_references=true) }
    end

    def update_references_on_destroy
      WikiReference.update_on_destroy(self)
      expire_templatee_references
      #hard_templatees.each {|c| Renderer.instance.render(c, c.content, update_references=true) }
    end
    
    def self.included(base)   
      super
      base.extend(ClassMethods)
      base.class_eval do           
        has_many :name_references, :class_name=>'WikiReference',
          :finder_sql=>%q{SELECT * from wiki_references w where w.referenced_name=#{ActiveRecord::Base.connection.quote(key)}}
    #    has_many :name_referencers, :through=>:name_references, :source=>:referencer
    #       :finder_sql=>%q{SELECT cards.* FROM cards INNER JOIN wiki_references ON cards.id = wiki_references.card_id    WHERE ((wiki_references.referenced_name = #{ActiveRecord::Base.connection.quote(key)})) }

        has_many :in_references,:class_name=>'WikiReference', :foreign_key=>'referenced_card_id'
        has_many :out_references,:class_name=>'WikiReference', :foreign_key=>'card_id', :dependent=>:destroy

        has_many :in_transclusions, :class_name=>'WikiReference', :foreign_key=>'referenced_card_id',:conditions=>["link_type in (?,?)",WikiReference::TRANSCLUSION, WikiReference::WANTED_TRANSCLUSION]
        has_many :out_transclusions,:class_name=>'WikiReference', :foreign_key=>'card_id',           :conditions=>["link_type in (?,?)",WikiReference::TRANSCLUSION, WikiReference::WANTED_TRANSCLUSION]

        has_many :in_links, :class_name=>'WikiReference', :foreign_key=>'referenced_card_id',:conditions=>["link_type=?",WikiReference::LINK]
        has_many :out_links,:class_name=>'WikiReference', :foreign_key=>'card_id',:conditions=>["link_type=?",WikiReference::LINK]

        has_many :referencers, :through=>:in_references
        has_many :referencees, :through=>:out_references

        has_many :transcluders, :through=>:in_transclusions, :source=>:referencer
        has_many :transcludees, :through=>:out_transclusions, :source=>:referencee

        has_many :linkers, :through=>:in_links, :source=>:referencer
        has_many :linkees, :through=>:out_links, :source=>:referencee
        
        
        after_create :update_references_on_create
        after_destroy :update_references_on_destroy
        after_update :update_references_on_update
      end
    end
  end
end
