-- main project tables
CREATE TABLE Campus (
    name CHAR(100) PRIMARY KEY
);

CREATE TABLE Building (
    campus_name CHAR(100) REFERENCES Campus(name),
    name CHAR(100),
    PRIMARY KEY(name, campus_name)
);

-- two constraints: 1. has capacity > 0 only if lab or classroom
CREATE TABLE Room (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    campus_name CHAR(100) REFERENCES Campus(name),
    building_name CHAR(100) REFERENCES Building(name),
    num INT UNSIGNED,
    capacity INT UNSIGNED DEFAULT 0,
    room_type CHAR(100),
    UNIQUE KEY (num, building_name, campus_name) -- only one room of number # per building per campus
);
--
-- 2. has facilities only if lab or classroom
CREATE TABLE Facilities (
    room_id INT NOT NULL REFERENCES Room(id),
    facility CHAR(100),
    PRIMARY KEY (room_id, facility)
);


CREATE TABLE Department (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
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
    department_id INT NOT NULL,
    CONSTRAINT FK_Department_Program FOREIGN KEY (department_id) REFERENCES Department(id)
);

CREATE TABLE Course (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name CHAR(100) NOT NULL,
    code CHAR(15) NOT NULL,
    number INT NOT NULL,
    department_id INT NOT NULL,
    CONSTRAINT FK_Department_Course FOREIGN KEY (department_id) REFERENCES Department(id)
);

CREATE TABLE Address (
    id INT UNSIGNED NOT NULL PRIMARY KEY,
    civic_number INT UNSIGNED NOT NULL,
    city INT UNSIGNED NOT NULL,
    province CHAR(2) NOT NULL,
    postal_code CHAR(100) NOT NULL
);

CREATE TABLE Person_ID (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY
);

CREATE TABLE Student (
    person_id INT NOT NULL PRIMARY KEY REFERENCES Person_ID(id),
    first_name CHAR(100) NOT NULL,
    last_name CHAR(100) NOT NULL,
    email_addr CHAR(100) NOT NULL,
    home_address_id INT UNSIGNED NOT NULL REFERENCES Address(id),
    SSN INT UNSIGNED NOT NULL,
    phone_number INT UNSIGNED NOT NULL,
    gpa DECIMAL(3, 2) UNSIGNED NOT NULL,
    degree ENUM("undergraduate", "graduate") NOT NULL
);

CREATE TABLE Instructor (
    person_id INT NOT NULL PRIMARY KEY REFERENCES Person_ID(id),
    first_name CHAR(100) NOT NULL,
    last_name CHAR(100) NOT NULL,
    SSN INT UNSIGNED NOT NULL,
    email_addr CHAR(100) NOT NULL,
    phone_number INT UNSIGNED NOT NULL,
    home_address_id INT UNSIGNED NOT NULL REFERENCES Address(id)
);

-- needs triggers to verify: if it is university, check if student is graduate or it's a prof. if it is CEGEP/Secondary school, needs to be an undergraduate.
CREATE TABLE StudentPastDegrees (
    person_id INT NOT NULL REFERENCES Person_ID(id),
    institution CHAR(100) NOT NULL,
    school_type ENUM("CEGEP", "Secondary School", "University"),
    date_received DATE,
    degree_name CHAR(100),
    average DECIMAL(3, 2) UNSIGNED NOT NULL,
    PRIMARY KEY(person_id, institution, degree_name)
);

CREATE TABLE IndustryExperience (
    person_id INT NOT NULL REFERENCES Person_ID(id),
    company_name CHAR(100) NOT NULL,
    position_name CHAR(100) NOT NULL,
    date_started DATE,
    date_ended DATE,
    salary INT UNSIGNED NOT NULL,
    PRIMARY KEY(person_id, company_name, position_name)
);

CREATE TABLE Publications (
    person_id INT NOT NULL REFERENCES Person_ID(id),
    title CHAR(100) NOT NULL,
    journal_name CHAR(100) NOT NULL,
    date DATE NOT NULL
);

CREATE TABLE Awards(
    person_id INT NOT NULL REFERENCES Person_ID(id),
    name CHAR(100) NOT NULL,
    date DATE NOT NULL
);

CREATE TABLE Salary(
    person_id INT NOT NULL REFERENCES Person_ID(id),
    salary INT UNSIGNED NOT NULL,
    date_started DATE NOT NULL,
    date_ended DATE NOT NULL
);

-- renamed TeachingAssistant to Contracts to meet requirements
CREATE TABLE Contract(
    name char(100) NOT NULL, -- eg "marker", "instructor", "ta"
    course_name char(100) NOT NULL,
    person_id INT NOT NULL,
    section_id INT NOT NULL,
    num_hours INT NOT NULL,
    total_salary INT NOT NULL,
    PRIMARY KEY (person_id, section_id),
    CONSTRAINT FK_Student_Contract FOREIGN KEY (person_id) REFERENCES Person_ID(id),
    CONSTRAINT FK_Course_Contract FOREIGN KEY (section_id) REFERENCES Course(id)
);
-- needs trigger to verify student is TA for that section
CREATE TABLE TA_Assignments (
    person_id INT NOT NULL REFERENCES Person_ID(id),
    section_id INT NOT NULL REFERENCES Section(id),
    name CHAR(100)
);

CREATE TABLE Grade (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    letter_grade CHAR(5) NOT NULL,
    gpa DECIMAL(3,2) NOT NULL
);

CREATE TABLE Section (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    course_id INT NOT NULL,
    term_id INT NOT NULL,
    person_id INT NOT NULL,
    classroom_id INT UNSIGNED REFERENCES Room(id),
    capacity INT NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    CONSTRAINT FK_Course_Section FOREIGN KEY (course_id) REFERENCES Course(id),
    CONSTRAINT FK_Term_Section FOREIGN KEY (term_id) REFERENCES Term(id),
    CONSTRAINT FK_Instructor_Section FOREIGN KEY (person_id) REFERENCES Person_ID(id)
);

CREATE TABLE Class (
    person_id INT NOT NULL,
    section_id INT NOT NULL,
    grade_id INT NOT NULL,
    PRIMARY KEY (person_id, section_id),
    CONSTRAINT FK_Student_Class FOREIGN KEY (person_id) REFERENCES Person_ID(id),
    CONSTRAINT FK_Section_Class FOREIGN KEY (section_id) REFERENCES Section(id),
    CONSTRAINT FK_Grade_Class FOREIGN KEY (grade_id) REFERENCES Grade(id)
);

CREATE TABLE StudentProgram (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    person_id INT NOT NULL,
    program_id INT NOT NULL,
    CONSTRAINT FK_Student_StudentProgram FOREIGN KEY (person_id) REFERENCES Person_ID(id),
    CONSTRAINT FK_Program_StudentProgram FOREIGN KEY (program_id) REFERENCES Program(id)
);

CREATE TABLE ResearchFunding (
    person_id INT PRIMARY KEY,
    CONSTRAINT FK_Student_ResearchFunding FOREIGN KEY (person_id) REFERENCES Person_ID(id)
);

CREATE TABLE Prerequisite (
    course_id INT NOT NULL,
    prerequisite_course_id INT NOT NULL,
    PRIMARY KEY (course_id, prerequisite_course_id),
    CONSTRAINT FK_Course_Prequisite_Base FOREIGN KEY (course_id) REFERENCES Course(id),
    CONSTRAINT FK_Course_Prequisite FOREIGN KEY (prerequisite_course_id) REFERENCES Course(id)
);

CREATE TABLE StudentDepartment (
    person_id INT NOT NULL,
    department_id INT NOT NULL,
    PRIMARY KEY (person_id, department_id),
    CONSTRAINT FK_Student_StudentDepartment FOREIGN KEY (person_id) REFERENCES Person_ID(id),
    CONSTRAINT FK_Department_StudentDepartment FOREIGN KEY (department_id) REFERENCES Department(id)
);

CREATE TABLE InstructorDepartment (
    person_id INT NOT NULL,
    department_id INT NOT NULL,
    PRIMARY KEY (person_id, department_id),
    CONSTRAINT FK_Instructor_InstructorDepartment FOREIGN KEY (person_id) REFERENCES Person_ID(id),
    CONSTRAINT FK_Department_InstructorDepartment FOREIGN KEY (department_id) REFERENCES Department(id)
);

-- needs trigger: verify advisor is an instructor
CREATE TABLE Advisor (
    id INT NOT NULL PRIMARY KEY,
    first_name CHAR(100) NOT NULL,
    last_name CHAR(100) NOT NULL,
    CONSTRAINT FK_Advisor_Person FOREIGN KEY (id) REFERENCES Person_ID(id)
);

-- additional trigger: student's program is in the advisor's department
CREATE TABLE StudentAdvisor (
    student_program_id INT NOT NULL,
    advisor_id INT NOT NULL,
    term_id INT NOT NULL,
    CONSTRAINT FK_StudentProgram_StudentAdvisor FOREIGN KEY (student_program_id) REFERENCES StudentProgram(id),
    CONSTRAINT FK_Advisor_StudentAdvisor FOREIGN KEY (advisor_id) REFERENCES Advisor(id),
    CONSTRAINT FK_Term_StudentAdvisor FOREIGN KEY (term_id) REFERENCES Term(id)
);

CREATE TABLE Supervisor (
    person_id INT NOT NULL PRIMARY KEY,
    first_name CHAR(100) NOT NULL,
    last_name CHAR(100) NOT NULL,
    department_id INT NOT NULL,
    has_research_funding BOOLEAN NOT NULL,
    CONSTRAINT FK_Supervisor_Person FOREIGN KEY (person_id) REFERENCES Person_ID(id)
);

CREATE TABLE StudentSupervisor (
    person_id INT NOT NULL,
    supervisor_id INT NOT NULL,
    granted_funding BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (person_id, supervisor_id),
    CONSTRAINT FK_Student_StudentSupervisor FOREIGN KEY (person_id) REFERENCES Person_ID(id),
    CONSTRAINT FK_Supervisor_StudentSupervisor FOREIGN KEY (supervisor_id) REFERENCES Supervisor(person_id)
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
    IF EXISTS (SELECT gpa FROM Grade, Class, Section, Course, Prerequisite WHERE
    NEW.section_id = Section.id AND NEW.person_id = Class.person_id AND Section.course_id = Prerequisite.course_id AND Class.grade_id = Grade.id AND gpa < 0.7) THEN
    SET NEW.person_id = -1;
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


DELIMITER ;
