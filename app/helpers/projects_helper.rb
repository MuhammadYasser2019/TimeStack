module ProjectsHelper
  def consultant_name(fname, lname, email)
    consultant_name = email
    if fname.nil? || lname.nil?
  
    else
      consultant_name = "#{fname} #{lname}"
    end
    return consultant_name
  end
end
