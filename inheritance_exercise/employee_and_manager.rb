class Employee
  attr_reader :salary, :name

  def initialize(name, title, salary, boss)
    @name = name
    @title = title
    @salary = salary
    @boss = boss
    assign_manager unless boss.nil?
  end

  def bonus(multiplier)
    bonus = salary * multiplier
  end

  def assign_manager
    @boss.add_employee(self)
  end

  def has_subordinates?
    false
  end

end


class Manager < Employee

  attr_reader :employees

  def initialize(name, title, salary, boss)
    super(name, title, salary, boss)
    @employees = []
  end

  def has_subordinates?
    true
  end

  def bonus(multiplier)
    bonus = 0
    @employees.each do |child|               #child refers to subordinates
      bonus += child.salary * multiplier
      if child.has_subordinates?
        child.employees.each do |child|      #child of child
          bonus += child.salary * multiplier
        end
      end
    end
    bonus
  end

  def add_employee(employee)
    @employees << employee
  end

end

ned = Manager.new("Ned", "Founder", 1000000, nil)
darren = Manager.new("Darren", "TA Manager", 78000, ned)
shawna = Employee.new("Shawna", "TA", 12000, darren)
david = Employee.new("David", "TA", 10000, darren)

p ned.bonus(5) #500_000
# p darren.bonus(5)
# p shawna.bonus(5)
# p david.bonus(5)

puts darren.bonus(4) # 88_000
puts david.bonus(3)  # 30_000
