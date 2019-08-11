-- main project tables    
SET SQL_SAFE_UPDATES = 0;
SET GLOBAL log_bin_trust_function_creators = 1;
SET @TRIGGER_BEFORE_INSERT_CHECKS = TRUE;
SET @TRIGGER_AFTER_INSERT_CHECKS = TRUE;
SET @TRIGGER_BEFORE_UPDATE_CHECKS = TRUE;
SET @TRIGGER_AFTER_UPDATE_CHECKS = TRUE;
SET @TRIGGER_BEFORE_DELETE_CHECKS = TRUE;
SET @TRIGGER_AFTER_DELETE_CHECKS = TRUE;

CREATE TABLE Address (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    civic_number CHAR(50) NOT NULL,
    city CHAR(150) NOT NULL,
    province CHAR(5) NOT NULL,
    postal_code CHAR(100) NOT NULL
);

CREATE TABLE Person (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    first_name CHAR(100) NOT NULL,
    last_name CHAR(100) NOT NULL,
    SSN CHAR(50) NOT NULL,
    email_addr CHAR(100) NOT NULL,
    phone_number CHAR(50) NOT NULL,
    home_address_id INT UNSIGNED NOT NULL REFERENCES Address(id)
);

CREATE TABLE Campus (
    name CHAR(100) PRIMARY KEY
);

CREATE TABLE Building (
    campus_name CHAR(100) REFERENCES Campus(name),
    name CHAR(100),
    numOfFloors INT NOT NULL,
    PRIMARY KEY(name, campus_name)
);

-- two constraints: 1. has capacity > 0 only if lab or classroom
CREATE TABLE Room (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    campus_name CHAR(100) REFERENCES Campus(name),
    building_name CHAR(100) REFERENCES Building(name),
    num INT UNSIGNED,
    capacity INT UNSIGNED DEFAULT 0,
    room_type CHAR(100), -- conference_room, office, classroom, laboratory...
    floorNum INT NOT NULL,
    UNIQUE KEY (num, building_name, campus_name) -- only one room of number # per building per campus
);

CREATE TABLE Facilities (
    room_id INT NOT NULL REFERENCES Room(id),
    facility CHAR(100),
    PRIMARY KEY (room_id, facility)
);

CREATE TABLE Department (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    chairman_id INT NOT NULL REFERENCES Person(id),
    name CHAR(100) NOT NULL
);

CREATE TABLE Term (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    season ENUM("Fall", "Winter", "Summer") NOT NULL,
    year YEAR(4) NOT NULL
);

CREATE TABLE Program (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name CHAR(100) NOT NULL,
    degree ENUM("undergraduate", "graduate") NOT NULL,
    credit_req INT UNSIGNED NOT NULL DEFAULT 0,
    is_thesis_based BOOLEAN NOT NULL,
    department_id INT NOT NULL REFERENCES Department(id)
);

CREATE TABLE Course (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name CHAR(100) NOT NULL,
    code CHAR(15) NOT NULL,
    number INT NOT NULL,
    department_id INT NOT NULL REFERENCES Department(id)
);

CREATE TABLE Student (
    person_id INT NOT NULL PRIMARY KEY REFERENCES Person(id),
    gpa DECIMAL(3, 2) UNSIGNED NOT NULL,
    degree ENUM("undergraduate", "graduate") NOT NULL
);

CREATE TABLE Instructor (
    person_id INT NOT NULL PRIMARY KEY REFERENCES Person(id),
    department_id INT NOT NULL REFERENCES Department(id)
);

-- needs triggers to verify: if it is university, check if student is graduate or it's a prof. if it is CEGEP/Secondary school, needs to be an undergraduate.
CREATE TABLE StudentPastDegrees (
    person_id INT NOT NULL REFERENCES Person(id),
    institution CHAR(100) NOT NULL,
    school_type ENUM("CEGEP", "Secondary School", "University"),
    date_received DATE,
    degree_name CHAR(100),
    average DECIMAL(3, 2) UNSIGNED NOT NULL,
    PRIMARY KEY(person_id, institution, degree_name)
);

CREATE TABLE IndustryExperience (
    person_id INT NOT NULL REFERENCES Person(id),
    company_name CHAR(100) NOT NULL,
    position_name CHAR(100) NOT NULL,
    date_started DATE,
    date_ended DATE,
    salary INT UNSIGNED NOT NULL,
    PRIMARY KEY(person_id, company_name, position_name)
);

CREATE TABLE Publications (
    person_id INT NOT NULL REFERENCES Person(id),
    title CHAR(100) NOT NULL,
    journal_name CHAR(100) NOT NULL,
    date DATE NOT NULL
);

CREATE TABLE Awards(
    person_id INT NOT NULL REFERENCES Person(id),
    name CHAR(100) NOT NULL,
    date DATE NOT NULL
);

CREATE TABLE Salary(
    person_id INT NOT NULL REFERENCES Person(id),
    salary INT UNSIGNED NOT NULL,
    date_started DATE NOT NULL,
    date_ended DATE NOT NULL
);

-- renamed TeachingAssistant to Contracts to meet requirements
CREATE TABLE Contract (
    name char(100) NOT NULL, -- eg "marker", "instructor", "ta"
    course_name char(100) NOT NULL REFERENCES Course(id),
    person_id INT NOT NULL REFERENCES Person(id),
    section_id INT NOT NULL,
    num_hours INT NOT NULL,
    total_salary INT NOT NULL,
    PRIMARY KEY (person_id, section_id)
);

-- TODO: needs trigger to verify student is TA for that section
CREATE TABLE TA_Assignments (
    person_id INT NOT NULL REFERENCES Person(id),
    section_id INT NOT NULL REFERENCES Section(id),
    name CHAR(100) -- TODO: need additional content other than assignment name
);

CREATE TABLE Grade (
    gpa DECIMAL(3,2) NOT NULL,
    out_of_100 INTEGER NOT NULL,
    letter_grade CHAR(5) NOT NULL
);

-- starting from highest worth, if you are out_of_100 or above, you get letter_grade, worth gpa.
INSERT INTO Grade VALUES (4.3, 90, "A+"), (4, 85, "A"), (3.7, 80, "A-"), (3.3, 77, "B+"), (3, 73, "B"), (2.7, 70, "B-"), (2.3, 67, "C+"), (2, 63, "C"), (1.7, 60, "C-"), (1.3, 57, "D+"), (1, 53, "D"), (0.7, 50, "D-"), (0.0, 0, "FAIL");


CREATE TABLE IF NOT EXISTS func(grade CHAR(5), grade_gpa DECIMAL(3, 2));
DELETE FROM func;
INSERT INTO func VALUES ("F", 0.0);

DELIMITER $$
CREATE FUNCTION get_grade_letter (my_grade INTEGER) RETURNS CHAR(5)
BEGIN
    UPDATE func SET grade = (SELECT letter_grade FROM Grade WHERE my_grade >= Grade.out_of_100 LIMIT 1);
    RETURN (SELECT grade FROM func LIMIT 1);
END$$
DELIMITER ;

DELIMITER $$
CREATE FUNCTION get_gpa (my_grade INTEGER) RETURNS DECIMAL(3, 2)
BEGIN
    UPDATE func SET grade_gpa = (SELECT gpa FROM Grade WHERE my_grade >= Grade.out_of_100 LIMIT 1);
    RETURN (SELECT grade_gpa FROM func LIMIT 1);
END$$
DELIMITER ;

CREATE TABLE Section (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    course_id INT NOT NULL REFERENCES Course(id),
    term_id INT NOT NULL REFERENCES Term(id),
    person_id INT NOT NULL REFERENCES Person(id),
    classroom_id INT UNSIGNED REFERENCES Room(id),
    capacity INT NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL
);

CREATE TABLE Class (
    person_id INT NOT NULL REFERENCES Person(id),
    section_id INT NOT NULL REFERENCES Section(id),
    grade INT NOT NULL DEFAULT 0,
    PRIMARY KEY (person_id, section_id)
);

CREATE TABLE StudentProgram (
    person_id INT NOT NULL REFERENCES Person(id),
    program_id INT NOT NULL REFERENCES Program(id),
    PRIMARY KEY (person_id, program_id)
);

CREATE TABLE ResearchFunding (
    person_id INT PRIMARY KEY REFERENCES Person(id),
    amount FLOAT(8,2) NOT NULL DEFAULT 0,
    term_id INT NOT NULL REFERENCES Term(id)
);

CREATE TABLE Prerequisite (
    course_id INT NOT NULL REFERENCES Course(id),
    prerequisite_course_id INT NOT NULL REFERENCES Course(id),
    PRIMARY KEY (course_id, prerequisite_course_id)
);

CREATE TABLE StudentDepartment (
    person_id INT NOT NULL REFERENCES Person(id),
    department_id INT NOT NULL REFERENCES Department(id),
    PRIMARY KEY (person_id, department_id)
);

CREATE TABLE InstructorDepartment (
    person_id INT NOT NULL REFERENCES Person(id),
    department_id INT NOT NULL REFERENCES Department(id),
    PRIMARY KEY (person_id, department_id)
);

-- needs trigger: verify advisor is an instructor
CREATE TABLE Advisor (
    person_id INT NOT NULL REFERENCES Person(id),
    program_id INT NOT NULL REFERENCES Program(id),
    term_id INT NOT NULL REFERENCES Term(id),
    PRIMARY KEY (person_id, program_id, term_id)
);

-- additional trigger: student's program is in the advisor's department
CREATE TABLE StudentAdvisor (
    student_id INT NOT NULL REFERENCES Person(id),
    advisor_id INT NOT NULL REFERENCES Person(id),
    term_id INT NOT NULL REFERENCES Term(id),
    PRIMARY KEY (student_id, advisor_id, term_id)
);

CREATE TABLE Supervisor (
    person_id INT NOT NULL PRIMARY KEY REFERENCES Person(id),
    first_name CHAR(100) NOT NULL,
    last_name CHAR(100) NOT NULL,
    department_id INT NOT NULL,
    has_research_funding BOOLEAN NOT NULL -- TODO: change this.
);

CREATE TABLE StudentSupervisor (
    person_id INT NOT NULL     REFERENCES Person(id),
    supervisor_id INT NOT NULL REFERENCES Supervisor(person_id),
    granted_funding BOOLEAN DEFAULT FALSE, -- TODO: change this.
    PRIMARY KEY (person_id, supervisor_id)
);


-- triggers
DELIMITER $$
CREATE TRIGGER default_credit BEFORE INSERT ON Program FOR EACH ROW
BEGIN
    IF NEW.credit_req = 0 THEN
        IF NEW.degree = "undergraduate" THEN
            SET NEW.credit_req = 90;
        ELSE
            SET NEW.credit_req = 44;
        END IF;
    END IF;
END$$

DELIMITER $$
CREATE TRIGGER one_or_more_programs AFTER INSERT ON Department FOR EACH ROW
BEGIN
    INSERT INTO Program(name, degree, is_thesis_based, department_id) VALUES("General Program", "undergraduate", 0, NEW.id);
END$$

DELIMITER $$
CREATE TRIGGER passing_grade_prereqs BEFORE INSERT ON Class FOR EACH ROW
BEGIN
    -- doing set difference: if there remains classes in the prereqs such that student didn't take it and pass, reject this signup to the course.
    IF EXISTS (SELECT Course.course_id FROM Section, Prerequisite, Course WHERE NEW.section_id = Section.id AND Section.course_id = Prerequisite.course_id AND Prerequisite.prerequisite_course_id = Course.course_id NOT IN (SELECT course_id FROM Class, Section WHERE Class.section_id = Section.id AND Class.person_id = NEW.person_id AND Class.grade_id >= 0.7)) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "invalid action: Student does not meet prereq requirements.";
    END IF;
END$$

DELIMITER $$
CREATE TRIGGER only_one_section_of_same_class BEFORE INSERT ON Class FOR EACH ROW
BEGIN
    IF EXISTS (SELECT course_id, term_id FROM Section WHERE NEW.section_id = Section.id IN (
        SELECT 1 FROM Class, Section WHERE
        NEW.person_id = Class.person_id AND Class.section_id = Section.id)) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "invalid action: Student is already registered in this course for this term.";
    END IF;
END$$

DELIMITER $$
CREATE TRIGGER no_conflicting_time_courses_instructor BEFORE INSERT ON Section FOR EACH ROW
BEGIN
    IF EXISTS (SELECT start_time, end_time FROM Section WHERE (NEW.person_id = Section.person_id AND NEW.term_id = Section.term_id) AND ((NEW.start_time >= Section.start_time AND NEW.start_time < Section.end_time OR (NEW.start_time <= Section.start_time AND NEW.end_time > Section.end_time)))) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Instructor is already teaching a course at this time";
    END IF;
END$$

-- new section to be added = n, old sections already there = o
DELIMITER $$
CREATE TRIGGER no_conflicting_time_courses_student BEFORE INSERT ON Class FOR EACH ROW
BEGIN
    IF EXISTS  (SELECT n.start_time, n.end_time  FROM Section AS n, Section as o, Class WHERE NEW.person_id = Class.person_id AND Class.section_id = o.id AND n.id = NEW.section_id AND n.term_id = o.term_id AND ((n.start_time >= o.start_time AND n.start_time < o.end_time OR (n.start_time >= o.start_time AND n.end_time > o.end_time)))) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Student is already taking a course at this time";
    END IF;
END$$

DELIMITER $$
CREATE TRIGGER grad_student_supervisor_funding_insert BEFORE INSERT ON StudentSupervisor FOR EACH ROW
BEGIN
    IF EXISTS(SELECT * FROM Student, Supervisor WHERE NEW.supervisor_id = Supervisor.id AND Student.id = NEW.person_id AND (has_research_funding = FALSE OR Student.gpa < 3.0) AND NEW.granted_funding = TRUE) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Supervisor has no funding available, or student has insufficient GPA";
    END IF;
END$$

DELIMITER $$
CREATE TRIGGER grad_student_supervisor_funding_update BEFORE UPDATE ON StudentSupervisor FOR EACH ROW
BEGIN
    IF EXISTS(SELECT * FROM Student,Supervisor WHERE NEW.supervisor_id = Supervisor.id AND Student.id = NEW.person_id AND (has_research_funding = FALSE OR Student.gpa < 3.0) AND NEW.granted_funding = TRUE) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Supervisor has no funding available, or student has insufficient GPA";
    END IF;
END$$

DELIMITER $$
CREATE TRIGGER grad_student_TA_signup BEFORE INSERT ON Contract FOR EACH ROW
BEGIN
    IF EXISTS(SELECT * FROM Student, Contract WHERE NEW.person_id = Student.id = Contract.person_id AND (Student.gpa < 3.2 OR Student.degree = "undergraduate")) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Student has insufficient GPA, or is an undergrad.";
    END IF;
    IF EXISTS(SELECT * FROM Student, Contract WHERE NEW.person_id = Student.id = Contract.person_id GROUP BY Contract.person_id HAVING count(Contract.person_id) >= 2) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Student is teaching too many courses";
    END IF;
END$$

DELIMITER $$
CREATE TRIGGER grad_student_TA_signup_hours AFTER INSERT ON Contract FOR EACH ROW
BEGIN
    IF EXISTS(SELECT Contract.num_hours FROM Contract, Section, Term WHERE Contract.section_id = Section.id AND Section.term_id = Term.id AND NEW.person_id = Contract.person_id GROUP BY Term.year HAVING SUM(Contract.num_hours) + NEW.num_hours > 260) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Student is already teaching too many courses and cannot teach any more";
        DELETE FROM Contract WHERE Contract.person_id = NEW.person_id AND Contract.section_id = NEW.section_id AND Contract.num_hours = NEW.num_hours;
    END IF;
END$$

DELIMITER $$
CREATE TRIGGER lab_or_classroom_capacity BEFORE INSERT ON Room FOR EACH ROW
BEGIN
    IF NEW.capacity IS NOT NULL THEN
        IF NEW.capacity <= 0 AND (NEW.room_type = "laboratory" OR NEW.room_type = "classroom") THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Lab or Classroom must have a capacity > 0";
        END IF;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Lab or Classroom must have non null capacity";
    END IF;
END$$

DELIMITER $$
CREATE TRIGGER lab_or_classroom_facilities BEFORE INSERT ON Facilities FOR EACH ROW BEGIN
    IF NOT EXISTS(SELECT * FROM Room WHERE Room.id = NEW.room_id AND (Room.room_type = "classroom" OR Room.room_type = "laboratory")) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Only Lab or Classroom are allowed to have facilities. Either this room doesn't exist or isn't a lab/classroom";
    END IF;
END$$

DELIMITER $$
CREATE TRIGGER thesis_based_program_must_be_grad AFTER INSERT ON Program FOR EACH ROW BEGIN
    IF NEW.is_thesis_based IS TRUE AND NEW.degree = "undergraduate" THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Only grad programs may be thesis based";
    END IF;
END$$

DELIMITER $$
CREATE TRIGGER student_program_matching_degree BEFORE INSERT ON StudentProgram FOR EACH ROW BEGIN
    IF NOT EXISTS(Select * FROM Student, Program WHERE Student.person_id = NEW.person_id AND Program.id = New.program_id AND Student.degree = Program.degree) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Student degree type is incompatible with program degree type. Make sure both are undergrad or both are grad.";
    END IF;
END$$

DELIMITER $$
CREATE TRIGGER verify_advisor_is_instructor BEFORE INSERT ON Advisor FOR EACH ROW BEGIN
    IF NOT EXISTS(Select * FROM Instructor WHERE Instructor.person_id = NEW.person_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "This person cannot be an Advisor as he/she is not an instructor.";
    END IF;
END$$

DELIMITER $$
CREATE TRIGGER validate_student_advisor BEFORE INSERT ON StudentAdvisor FOR EACH ROW BEGIN
    IF NOT EXISTS(Select * FROM Instructor WHERE Instructor.person_id = NEW.advisor_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "The given advisor is not actually an advisor.";
    END IF;
    IF NOT EXISTS(Select * FROM Student WHERE Student.person_id = NEW.student_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "The given student is not actually a student.";
    END IF;
    IF NOT EXISTS(Select * FROM StudentProgram, Instructor WHERE StudentProgram.person_id = NEW.student_id AND Instructor.person_id = New.advisor_id AND StudentProgram.program_id = Program.id AND Program.department_id = Instructor.department_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "The given student isn't in a program that is supervised by this advisor.";
    END IF;
END$$

-- CREATE TRIGGER gpa_calculator AFTER INSERT ON Class FOR EACH ROW BEGIN
-- UPDATE Student SET Student.gpa = (
--
-- ) 
-- END$$

DELIMITER ;