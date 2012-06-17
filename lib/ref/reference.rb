class Reference

  protected
  def access_field doc, accessor
    eval 'doc' << accessor.split('.').map { |field| "['#{field}']" }.to_s
  end
end