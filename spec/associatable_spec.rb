require 'associatable'

describe 'AssocOptions' do
  describe 'BelongsToOptions' do
    it 'provides defaults' do
      options = BelongsToOptions.new('klass')

      expect(options.foreign_key).to eq(:klass_id)
      expect(options.class_name).to eq('Klass')
      expect(options.primary_key).to eq(:id)
    end

    it 'allows overrides' do
      options = BelongsToOptions.new('student',
                                     foreign_key: :student_id,
                                     class_name: 'Student',
                                     primary_key: :student_id
      )

      expect(options.foreign_key).to eq(:student_id)
      expect(options.class_name).to eq('Student')
      expect(options.primary_key).to eq(:student_id)
    end
  end

  describe 'HasManyOptions' do
    it 'provides defaults' do
      options = HasManyOptions.new('projects', 'Student')

      expect(options.foreign_key).to eq(:student_id)
      expect(options.class_name).to eq('Project')
      expect(options.primary_key).to eq(:id)
    end

    it 'allows overrides' do
      options = HasManyOptions.new('projects', 'Student',
                                   foreign_key: :student_id,
                                   class_name: 'FinalProject',
                                   primary_key: :student_id
      )

      expect(options.foreign_key).to eq(:student_id)
      expect(options.class_name).to eq('FinalProject')
      expect(options.primary_key).to eq(:student_id)
    end
  end

  describe 'AssocOptions' do
    before(:all) do
      class Project < SQLObject
        self.finalize!
      end

      class Student < SQLObject
        # self.table_name = 'students'

        self.finalize!
      end
    end

    it '#model_class returns class of associated object' do
      options = BelongsToOptions.new('student')
      expect(options.model_class).to eq(Student)

      options = HasManyOptions.new('projects', 'Student')
      expect(options.model_class).to eq(Project)
    end
    
    it '#table_name returns table name of associated object' do
      options = BelongsToOptions.new('student')
      expect(options.table_name).to eq('students')

      options = HasManyOptions.new('projects', 'Student')
      expect(options.table_name).to eq('projects')
    end
  end
end

describe 'Associatable' do
  before(:each) { DBConnection.reset }
  after(:each) { DBConnection.reset }

  before(:all) do
    class Project < SQLObject
      belongs_to :student, foreign_key: :student_id

      finalize!
    end

    class Student < SQLObject
      # self.table_name = 'students'

      has_many :projects, foreign_key: :student_id
      belongs_to :klass

      finalize!
    end

    class Klass < SQLObject
      has_many :students

      finalize!
    end
  end

  describe '#belongs_to' do
    let(:midterm) { Project.find(1) }
    let(:casey) { Student.find(1) }

    it 'fetches `student` from `Project` correctly' do
      expect(midterm).to respond_to(:student)
      student = midterm.student

      expect(student).to be_instance_of(Student)
      expect(student.fname).to eq('Casey')
    end

    it 'fetches `klass` from `Student` correctly' do
      expect(casey).to respond_to(:klass)
      klass = casey.klass

      expect(klass).to be_instance_of(Klass)
      expect(klass.name).to eq('Biology')
    end

    it 'returns nil if no associated object' do
      untaken_project = Project.find(5)
      expect(untaken_project.student).to eq(nil)
    end
  end

  describe '#has_many' do
    let(:chris) { Student.find(3) }
    let(:chris_klass) { Klass.find(2) }

    it 'fetches `projects` from `Student`' do
      expect(chris).to respond_to(:projects)
      projects = chris.projects

      expect(projects.length).to eq(2)

      expected_project_names = %w(MathHomework MathBonus)
      2.times do |i|
        project = projects[i]

        expect(project).to be_instance_of(Project)
        expect(project.name).to eq(expected_project_names[i])
      end
    end

    it 'fetches `student` from `Klass`' do
      expect(chris_klass).to respond_to(:students)
      students = chris_klass.students

      expect(students.length).to eq(1)
      expect(students[0]).to be_instance_of(Student)
      expect(students[0].fname).to eq('Chris')
    end

    it 'returns an empty array if no associated items' do
      unenrolled_student = Student.find(4)
      expect(unenrolled_student.projects).to eq([])
    end
  end

  describe '::assoc_options' do
    it 'defaults to empty hash' do
      class TempClass < SQLObject
      end

      expect(TempClass.assoc_options).to eq({})
    end

    it 'stores `belongs_to` options' do
      project_assoc_options = Project.assoc_options
      student_options = project_assoc_options[:student]

      expect(student_options).to be_instance_of(BelongsToOptions)
      expect(student_options.foreign_key).to eq(:student_id)
      expect(student_options.class_name).to eq('Student')
      expect(student_options.primary_key).to eq(:id)
    end

    it 'stores options separately for each class' do
      expect(Project.assoc_options).to have_key(:student)
      expect(Student.assoc_options).to_not have_key(:student)

      expect(Student.assoc_options).to have_key(:klass)
      expect(Project.assoc_options).to_not have_key(:klass)
    end
  end

  describe '#has_one_through' do
    before(:all) do
      class Project
        has_one_through :klass, :student, :klass

        self.finalize!
      end
    end

    let(:project) { Project.find(1) }

    it 'adds getter method' do
      expect(project).to respond_to(:klass)
    end

    it 'fetches associated `klass` for a `Project`' do
      klass = project.klass

      expect(klass).to be_instance_of(Klass)
      expect(klass.name).to eq('Biology')
    end
  end
end
