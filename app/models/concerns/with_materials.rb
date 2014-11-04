module WithMaterials
  extend ActiveSupport::Concern

  included do
    has_many :materials, :dependent => :destroy, :as => :owner
  end

  def materials_of_kind(kind)
    case kind
    when Array
      self.materials.where("materials.kind in (:kind)", :kind => kind)
    else
      self.materials.where("materials.kind = :kind", :kind => kind)
    end
  end
  
  def materials_tagged(tag, kind)
    options = "tags.name = :tag"
    
    if kind
      if kind.is_a?(Array)
        options << " and materials.kind in (:kind)"
      else
        options << " and materials.kind = :kind"
      end
    end
    
    self.materials.joins(:taggings).joins(:tags).where(options, :tag => tag, :kind => kind)
  end
  
  def materials_not_tagged(tag, kind = nil)
    options = "(tags.name is null or tags.name <> :tag)"
    
    if kind
      if kind.is_a?(Array)
        options << " and materials.kind in (:kind)"
      else
        options << " and materials.kind = :kind"
      end
    end

    self.materials.
      joins("left outer join taggings on taggings.taggable_id = materials.id and taggings.taggable_type = 'Material'").
      joins("left outer join tags on taggings.tag_id = tags.id").
      where(options, :tag => tag, :kind => kind)
  end
  
  def materials_not_tagged_and_not_kind(tag, kind = nil)
    options = "(tags.name is null or tags.name <> :tag)"
    
    if kind
      if kind.is_a?(Array)
        options << " and materials.kind not in (:kind)"
      else
        options << " and materials.kind <> :kind"
      end
    end

    self.materials.
      joins("left outer join taggings on taggings.taggable_id = materials.id and taggings.taggable_type = 'Material'").
      joins("left outer join tags on taggings.tag_id = tags.id").
      where(options, :tag => tag, :kind => kind)
  end
end