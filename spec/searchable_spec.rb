require 'searchable'

describe 'Searchable' do
  before(:each) { DBConnection.reset }
  after(:each) { DBConnection.reset }

  before(:all) do
    class Project < SQLObject
      finalize!
    end

    class Student < SQLObject
      self.table_name = 'students'

      finalize!
    end
  end

  it '#where searches with single criterion' do
    projects = Project.where(name: 'Bio Final')
    project = projects.first

    expect(projects.length).to eq(1)
    expect(project.name).to eq('Bio Final')
  end

  it '#where can return multiple objects' do
    students = Student.where(klass_id: 1)
    expect(students.length).to eq(2)
  end

  it '#where searches with multiple criteria' do
    students = Student.where(fname: 'Casey', klass_id: 1)
    expect(students.length).to eq(1)

    students = students[0]
    expect(students.fname).to eq('Casey')
    expect(students.klass_id).to eq(1)
  end

  it '#where returns [] if nothing matches the criteria' do
    expect(Student.where(fname: 'Nowhere', lname: 'Man')).to eq([])
  end
end
