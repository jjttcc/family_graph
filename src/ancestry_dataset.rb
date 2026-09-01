require 'set'

class AncestryDataset
  public

  def initialize(target_person, all_people)
    @all_people = all_people
    @ancestor_ids = collect_ancestor_ids(target_person)
  end

  def ancestor_ids
    @ancestor_ids
  end

  def roots
    @all_people.select { |id, p| @ancestor_ids.member?(id) && p.parents.empty? }.values
  end


  def subset(yaml_path)
    DataLoader.load_subset(yaml_path, @ancestor_ids)
  end

  private

  def collect_ancestor_ids(person, set = Set.new)
    unless set.member?(person.id)
      set.add(person.id)
      # Traverse parents and spouses to ensure complete graph
      person.parents.each { |p| collect_ancestor_ids(p, set) }
      person.spouses.each { |s| collect_ancestor_ids(s, set) }
    end
    set
  end
end
