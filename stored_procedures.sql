-- vi.Give details of a specific building (this include address of the building,
-- number of floors, number of rooms in each floor, and details of each room
-- such as room type, capacity of the room and existing facilities in the room
-- if it is a classroom or a lab.

DELIMITER $$
CREATE PROCEDURE FindBuildingDetails(IN building VARCHAR(100))
 BEGIN
	SELECT DISTINCT
		BuildingName.name AS building,    
		CONCAT(Address.civic_number, ' ', Address.city, ', ', Address.province, ' ', Address.postal_code) AS address,
		BuildingName.numOfFloors AS num_of_floors,
		r.room_type,
		r.capacity,
		Facilities.facility,
		r.floorNum AS floor_num,
		(SELECT COUNT(*) FROM Room WHERE Room.floorNum = r.floorNum AND Room.campus_name LIKE CONCAT('%',  r.campus_name, '%') AND  Room.building_name LIKE CONCAT('%',  r.building_name, '%')) AS num_rooms_on_floor
	FROM Room r
		INNER JOIN Building BuildingCampus ON r.campus_name LIKE CONCAT('%',  BuildingCampus.campus_name, '%')
		INNER JOIN Building BuildingName ON r.building_name LIKE CONCAT('%',  BuildingName.name, '%') 
		LEFT JOIN Facilities ON r.id = Facilities.room_id
		INNER JOIN Address ON BuildingName.address_id = Address.id
	WHERE BuildingName.name LIKE CONCAT('%', building, '%');
 END $$

-- vii.
DELIMITER $$
CREATE PROCEDURE FindProgramsByDepartment(IN department VARCHAR(100))
 BEGIN
	SELECT
		Program.name AS program,
		Program.credit_req AS num_of_credits,
		Department.name AS department
	FROM Program
		INNER JOIN Department ON Program.department_id = Department.id
	WHERE Department.name LIKE CONCAT('%', department, '%');
 END $$

-- viii. Get a list of all courses offered in a given term by a specific program.
CREATE PROCEDURE FindCoursesByTermAndProgram(IN season VARCHAR(100), IN year INT, IN program VARCHAR(100))
 BEGIN
	SELECT DISTINCT
		Course.name AS course,
		CONCAT(Term.season, ' ', Term.year) AS term,
		Program.name AS program
	FROM Section
		INNER JOIN Course ON Section.course_id = Course.id
		INNER JOIN Department ON Course.department_id = Department.id
		INNER JOIN Program ON Department.id = Program.department_id
		INNER JOIN Term ON Section.term_id = Term.id
	WHERE 
		Term.season LIKE CONCAT('%', @season, '%') AND Term.year LIKE CONCAT('%', @year, '%')
	AND
		Program.name LIKE CONCAT('%', @program, '%');
 END $$

-- ix. Get the details of all the courses offered by a specific department for a
-- specific term. Details include Course name, section, room location, start
-- and end time, professor teaching the course, max class capacity and
-- number of enrolled students.

DELIMITER $$
CREATE PROCEDURE FindCourseDetails(IN department VARCHAR(100), IN season VARCHAR(100), IN year INT)
 BEGIN
	SELECT 
		Course.name AS course,
		Section.id AS section,
		CONCAT(Room.building_name, ' ', Room.num) AS room_location,
		Section.start_time,
		Section.end_time,
		CONCAT(Person.first_name, ' ', Person.last_name) AS professor,
		Section.capacity AS max_class_capacity,
		(SELECT COUNT(*) FROM Class WHERE Class.section_id = Section.id) AS num_enrolled_students
	FROM Section
		INNER JOIN Course ON Section.course_id = Course.id
		INNER JOIN Room ON Section.classroom_id = Room.id
		INNER JOIN Person ON Section.person_id = Person.id
		INNER JOIN Term ON Section.term_id = Term.id
		INNER JOIN Department ON Course.department_id = Department.id
	WHERE Department.name LIKE CONCAT('%', department, '%') AND Term.season LIKE CONCAT('%', season, '%') AND Term.year LIKE CONCAT('%', year, '%');
 END $$

-- x. Find ID, first name and last name of all the students who are enrolled in a specific program in a given term.
DELIMITER $$
CREATE PROCEDURE FindStudentsByProgramAndTerm(IN season VARCHAR(100), IN year INT, IN program VARCHAR(100))
 BEGIN
	SELECT
		Person.id AS ID,
		Person.first_name AS first_name,
		Person.last_name AS last_name,
		Program.name AS Program,
		CONCAT(Term.season, ' ', Term.year) AS term
	FROM StudentAdvisor
		INNER JOIN StudentProgram ON StudentAdvisor.student_program_id = StudentProgram.id
		INNER JOIN Term ON StudentAdvisor.term_id = Term.id
		INNER JOIN Person ON StudentProgram.person_id = Person.id
		INNER JOIN Program ON StudentProgram.program_id = Program.id
	WHERE 
		Term.season LIKE CONCAT('%', @season, '%') AND Term.year LIKE CONCAT('%', @year, '%')
	AND
		Program.name LIKE CONCAT('%', @program, '%');
 END $$

-- xi. Find the name of all the instructors who taught a given course on a specific term.
DELIMITER $$
CREATE PROCEDURE FindInstructorCourseByTerm(IN season VARCHAR(100), IN year INT, IN courseName VARCHAR(100), IN code VARCHAR(100), IN number INT)
 BEGIN
		SELECT
		CONCAT(Person.first_name, ' ', Person.last_name) AS instructor,
		Course.name AS course,
		CONCAT(Course.code, ' ', Course.number) AS course_code, 
		CONCAT(Term.season, ' ', Term.year) AS term
	FROM Section
		INNER JOIN Person ON Section.person_id = Person.id
		INNER JOIN Course ON Section.course_id = Course.id
		INNER JOIN Term ON Section.term_id = Term.id
	WHERE 
		Term.season LIKE CONCAT('%', season, '%') AND Term.year LIKE CONCAT('%', year, '%')
	AND
		(Course.name LIKE CONCAT('%', courseName, '%') OR (Course.code LIKE CONCAT('%', code, '%') AND Course.number LIKE CONCAT('%', number, '%')));
 END $$

-- xii. Give a list of all supervisors in a given department.
DELIMITER //
CREATE PROCEDURE SelectAllSupervisorsInDepartment(IN department VARCHAR(100))
 BEGIN
 SELECT CONCAT(Supervisor.first_name, " ", Supervisor.last_name) AS Supervisor
	FROM Supervisor 
	INNER JOIN Department ON Supervisor.department_id = Department.id
	WHERE Department.name LIKE CONCAT('%', department, '%');
 END //

-- xiii. Give a list of all the advisors in a given department.
DELIMITER $$
CREATE PROCEDURE SelectAllAdvisorsInDepartment(IN department VARCHAR(100))
 BEGIN
 SELECT CONCAT(Person.first_name, " ", Person.last_name) AS Advisor
	FROM Advisor 
		INNER JOIN Department ON Advisor.department_id = Department.id
		INNER JOIN Person ON Advisor.person_id = Person.Id
	WHERE Department.name LIKE CONCAT('%', department, '%');
 END $$

-- xiv. Find the name and IDs of all the graduate students who are supervised by a specific Professor.
DELIMITER $$
CREATE PROCEDURE FindAllGraduateStudentsBySupervisor(IN professor VARCHAR(100))
 BEGIN
	 SELECT 
		StudentPerson.id AS student_id,
		CONCAT(StudentPerson.first_name, ' ', StudentPerson.last_name) AS student_name,
		Student.degree AS degree,
		CONCAT(InstructorPerson.first_name, ' ', InstructorPerson.last_name) AS supervisor    
	FROM StudentSupervisor
		INNER JOIN Person StudentPerson ON StudentPerson.id = StudentSupervisor.person_id
		INNER JOIN Student ON Student.person_id = StudentSupervisor.person_id
		INNER JOIN Person InstructorPerson ON InstructorPerson.id = StudentSupervisor.supervisor_id
	WHERE Student.degree = 'graduate' AND (InstructorPerson.first_name LIKE CONCAT('%', professor, '%') OR InstructorPerson.last_name LIKE CONCAT('%', professor, '%'));
 END $$

 -- xv. Find the ID, name and assignment mandate of all the graduate students
-- who are assigned as teaching assistants to a specific course on a given term.
DELIMITER $$
CREATE PROCEDURE FindAllTeachingAssistantAssignmentsByCourseAndTerm(IN course VARCHAR(100), IN code INT, IN season VARCHAR(100), IN year INT)
 BEGIN
	SELECT
		Person.id AS student_id,
		CONCAT(Person.first_name, ' ', Person.last_name) AS student_name,
		CONCAT(Course.code, ' ', Course.number) AS Course,
		Section.id AS Section,
		Contract.num_hours,
		Contract.total_salary,
		CONCAT(Term.season, ' ', Term.year) AS Term
	FROM TA_Assignments
		INNER JOIN Person ON Person.id = TA_Assignments.person_id
		INNER JOIN Section ON Section.id = TA_Assignments.section_id
		INNER JOIN Student ON Student.person_id = Person.id
		INNER JOIN Term ON Term.id = Section.term_id
		INNER JOIN Course ON Course.id = Section.course_id
		INNER JOIN Contract ON Contract.section_id = TA_Assignments.section_id
	WHERE 
		Student.degree = 'graduate' 
		AND (Course.code LIKE CONCAT('%', course, '%') AND Course.number LIKE CONCAT('%', code, '%'))
		AND (Term.season LIKE CONCAT('%', season, '%') AND Term.year LIKE CONCAT('%', year, '%'));
 END $$

 -- xvi. Find the name, IDs and total amount of funds received by all the graduate students who received research funds in a given term.
 DELIMITER $$
CREATE PROCEDURE FindTotalStudentResearchFundingByTerm(IN season VARCHAR(100), IN year INT)
 BEGIN
	SELECT
		Person.id AS student_id,
		CONCAT(Person.first_name, ' ', Person.last_name) AS student_name,
		SUM(ResearchFunding.amount) AS total_funding
	FROM ResearchFunding
		INNER JOIN Student ON ResearchFunding.person_id = Student.person_id
		INNER JOIN Person ON Person.id = ResearchFunding.person_id
		INNER JOIN Term ON ResearchFunding.term_id = Term.id
	WHERE 
		Student.degree = 'graduate' 
		AND (Term.season LIKE CONCAT('%', season, '%') AND Term.year LIKE CONCAT('%', year, '%'))
	GROUP BY Person.id;
 END $$

-- xix. Give a list of courses taken by a specific student in a given term.
DELIMITER $$
CREATE PROCEDURE FindCoursesListByStudentAndTerm(IN season VARCHAR(100), IN year INT, IN firstName VARCHAR(100), IN lastName VARCHAR(100))
 BEGIN
	SELECT
		CONCAT(Person.first_name, ' ', Person.last_name) AS student,
		Course.name AS course,
		CONCAT(Term.season, ' ', Term.year) AS term    
	FROM Class
		INNER JOIN Section ON Class.section_id = Section.id
		INNER JOIN Course ON Section.course_id = Course.id
		INNER JOIN Person ON Class.person_id = Person.id
		INNER JOIN Term ON Section.term_id = Term.id    
	WHERE 
		(Term.season LIKE CONCAT('%', season, '%') AND Term.year LIKE CONCAT('%', year, '%')
	AND
		(Person.first_name LIKE CONCAT('%', firstName, '%') AND Person.last_name LIKE CONCAT('%', lastName, '%')));
 END $$

-- xx. Register a student in a specific course.

DELIMITER $$
CREATE PROCEDURE RegisterStudentInCourse(IN student_id INT, IN section_id INT)
 BEGIN
	INSERT INTO Class (person_id, section_id, grade) VALUES (student_id, section_id, 0);
 END $$
 
 -- xxi. Drop a course for a specific student.
 DELIMITER $$
CREATE PROCEDURE DropStudentCourse(IN student_id INT, IN section_id INT)
 BEGIN
	DELETE FROM Class WHERE person_id = student_id AND section_id = section_id;
 END $$

-- xxii. Give a detailed report for a specific student (This include personal data, academic history, courses taken and grades received for each course, GPA, etc.)
DELIMITER $$
CREATE PROCEDURE GetStudentReport(IN firstName CHAR(100), IN lastName CHAR(100))
 BEGIN
	SELECT
		Student.person_id AS student_id,
		CONCAT(Person.first_name, ' ', Person.last_name) AS student,
		Student.gpa,
		Student.degree,
		Person.SSN,
		Person.email_addr AS email,
		Person.phone_number AS phone,
		CONCAT(Address.civic_number, ' ', Address.City, ', ', Address.province, ' ', Address.postal_code) AS address
	FROM Student
		INNER JOIN Person ON Student.person_id = Person.id
		INNER JOIN Address ON Person.home_address_id = Address.id
	WHERE Person.first_name LIKE CONCAT('%', firstName, '%') OR Person.last_name LIKE CONCAT('%', lastName, '%');

	SELECT
		CONCAT(Person.first_name, ' ', Person.last_name) AS student,
		StudentPastDegrees.institution,
		StudentPastDegrees.school_type,
		StudentPastDegrees.date_received,
		StudentPastDegrees.degree_name,
		StudentPastDegrees.average
	FROM StudentPastDegrees
		INNER JOIN Person ON StudentPastDegrees.person_id = Person.id
	WHERE Person.first_name LIKE CONCAT('%', firstName, '%') OR Person.last_name LIKE CONCAT('%', lastName, '%');

	SELECT
		Person.id AS student_id,
		CONCAT(Person.first_name, ' ', Person.last_name) AS student,
		Course.name AS course,
		Class.grade AS GPA,
		(SELECT letter_grade FROM Grade WHERE gpa = Class.grade) AS Grade
	FROM Class
		INNER JOIN Person ON Class.person_id = Person.id
		INNER JOIN Section ON Class.section_id = Section.id
		INNER JOIN Course ON Section.course_id = Course.id
	WHERE Person.first_name LIKE CONCAT('%', firstName, '%') OR Person.last_name LIKE CONCAT('%', lastName, '%');
 END $$