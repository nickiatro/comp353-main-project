    
SET FOREIGN_KEY_CHECKS = 0;
SET SQL_SAFE_UPDATES = 0;

DROP TABLE IF EXISTS Person;
DROP TABLE IF EXISTS Advisor;
DROP TABLE IF EXISTS Class;
DROP TABLE IF EXISTS Course;
DROP TABLE IF EXISTS Department;
DROP TABLE IF EXISTS Grade;
DROP TABLE IF EXISTS Instructor;
DROP TABLE IF EXISTS InstructorDepartment;
DROP TABLE IF EXISTS Prerequisite;
DROP TABLE IF EXISTS Program;
DROP TABLE IF EXISTS ResearchFunding;
DROP TABLE IF EXISTS Section;
DROP TABLE IF EXISTS Student;
DROP TABLE IF EXISTS StudentAdvisor;
DROP TABLE IF EXISTS StudentDepartment;
DROP TABLE IF EXISTS StudentProgram;
DROP TABLE IF EXISTS Supervisor;
DROP TABLE IF EXISTS StudentSupervisor;
DROP TABLE IF EXISTS Term;
DROP TABLE IF EXISTS Campus;
DROP TABLE IF EXISTS Building;
DROP TABLE IF EXISTS Room;
DROP TABLE IF EXISTS Facilities;
DROP TABLE IF EXISTS Person_ID;
DROP TABLE IF EXISTS Address;
DROP TABLE IF EXISTS StudentPastDegrees;
DROP TABLE IF EXISTS IndustryExperience;
DROP TABLE IF EXISTS Contract;
DROP TABLE IF EXISTS Salary;
DROP TABLE IF EXISTS Publications;
DROP TABLE IF EXISTS Awards;
DROP TABLE IF EXISTS TA_Assignments;
DROP TABLE IF EXISTS ResearchFunding;
DROP TABLE IF Exists Func;

DROP TRIGGER IF EXISTS default_credit;
DROP TRIGGER IF EXISTS passing_grade_prereqs;
DROP TRIGGER IF EXISTS one_or_more_programs;
DROP TRIGGER IF EXISTS only_one_section_of_same_class;
DROP TRIGGER IF EXISTS no_conflicting_time_courses_instructor;
DROP TRIGGER IF EXISTS no_conflicting_time_courses_student;
DROP TRIGGER IF EXISTS grad_student_supervisor_funding_insert;
DROP TRIGGER IF EXISTS grad_student_supervisor_funding_update;
DROP TRIGGER IF EXISTS grad_student_TA_signup;
DROP TRIGGER IF EXISTS grad_student_TA_signup_hours;
DROP TRIGGER IF EXISTS lab_or_classroom_capacity;
DROP TRIGGER IF EXISTS lab_or_classroom_facilities;
DROP TRIGGER IF EXISTS thesis_based_program_must_be_grad;
DROP TRIGGER IF EXISTS student_program_matching_degree;
DROP TRIGGER IF EXISTS verify_advisor_is_instructor;
DROP TRIGGER IF EXISTS validate_student_advisor;
DROP TRIGGER IF EXISTS before_insert_class;

DROP FUNCTION IF EXISTS get_grade_letter;
DROP FUNCTION IF EXISTS get_gpa;
DROP FUNCTION IF EXISTS update_student_gpa;

DROP PROCEDURE IF EXISTS SelectAllSupervisorsInDepartment;
DROP PROCEDURE IF EXISTS SelectAllAdvisorsInDepartment;
DROP PROCEDURE IF EXISTS FindAllGraduateStudentsBySupervisor;
DROP PROCEDURE IF EXISTS FindAllTeachingAssistantAssignmentsByCourseAndTerm;
DROP PROCEDURE IF EXISTS FindTotalStudentResearchFundingByTerm;
DROP PROCEDURE IF EXISTS FindCoursesListByStudentAndTerm;
DROP PROCEDURE IF EXISTS FindInstructorCourseByTerm;
DROP PROCEDURE IF EXISTS FindStudentsByProgramAndTerm;
DROP PROCEDURE IF EXISTS FindCoursesByTermAndProgram;
DROP PROCEDURE IF EXISTS FindProgramsByDepartment;
DROP PROCEDURE IF EXISTS FindBuildingDetails;
DROP PROCEDURE IF EXISTS FindCourseDetails;
DROP PROCEDURE IF EXISTS RegisterStudentInCourse;
DROP PROCEDURE IF EXISTS DropStudentCourse;
DROP PROCEDURE IF EXISTS GetStudentReport;