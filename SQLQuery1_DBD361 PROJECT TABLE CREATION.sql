CREATE DATABASE Eletsa_Secondary_School_DB
GO

USE Eletsa_Secondary_School_DB;
GO

----TABLE CREATION

CREATE TABLE Staff (
Staff_ID INT IDENTITY(1,1) PRIMARY KEY,
First_Name VARCHAR(50) NOT NULL,
Last_Name VARCHAR(50) NOT NULL,
Role VARCHAR(50) CHECK ( Role IN ('Teacher', 'Principal', 'Admin', 'Support', 'Cleaner', 'Security Guard', 'Chef','Food Server')) NOT NULL,
Phone_Number VARCHAR(10) UNIQUE NOT NULL,
Email VARCHAR (100) UNIQUE NOT NULL
);
GO

CREATE TABLE Students(
Student_ID INT IDENTITY(1,1) PRIMARY KEY,
First_Name VARCHAR(50) NOT NULL,
Last_Name VARCHAR(50) NOT NULL,
Date_Of_Birth DATE NOT NULL,
Gender CHAR(1) CHECK ( Gender IN ( 'M', 'F')),
Grade_Level INT CHECK (Grade_Level BETWEEN 8 AND 12),
Enrollment_Status VARCHAR(20) CHECK (Enrollment_Status IN ('New', 'Transferred', 'Active')),
Parent_ID INT FOREIGN KEY REFERENCES Parents(Parent_ID)
);
GO

CREATE TABLE Parents(
Parent_ID INT IDENTITY(1,1) PRIMARY KEY,
First_Name VARCHAR(50) NOT NULL,
Last_Name VARCHAR(50) NOT NULL,
Phone_Number VARCHAR(10) UNIQUE NOT NULL,
Email VARCHAR(100) UNIQUE NOT NULL
);
GO

CREATE TABLE Classes(
Class_ID INT IDENTITY(1,1) PRIMARY KEY,
Grade_Level INT CHECK( Grade_Level BETWEEN 8 AND 12),
Class_Name VARCHAR(20) NOT NULL,
Teacher_ID INT FOREIGN KEY REFERENCES Staff(Staff_ID)
);
GO

CREATE TABLE Exams(
Exam_ID INT IDENTITY(1,1) PRIMARY KEY,
Exam_Name VARCHAR(50) NOT NULL,
Exam_Date DATE NOT NULL,
Grade_Level INT CHECK( Grade_Level BETWEEN 8 AND 12)
);
GO

CREATE TABLE Student_Exam(
Student_Exam_ID INT IDENTITY(1,1) NOT NULL,
Exam_ID INT FOREIGN KEY REFERENCES Exams(Exam_ID),
Student_ID INT FOREIGN KEY REFERENCES Students(Student_ID),
Score INT CHECK (Score BETWEEN 0 AND 100)
);
GO

CREATE TABLE Subjects(
Subject_ID INT IDENTITY(1,1) PRIMARY KEY,
Subject_Name VARCHAR(50) NOT NULL,
Teacher_ID INT FOREIGN KEY REFERENCES Staff(Staff_ID)
);
GO

CREATE TABLE Student_Subject(
Student_Subject_ID INT IDENTITY(1,1) PRIMARY KEY,
Student_ID INT FOREIGN KEY REFERENCES Students(Student_ID),
Subject_ID INT FOREIGN KEY REFERENCES Subjects(Subject_ID)
);
GO

CREATE TABLE Fees(
Fees_ID INT IDENTITY(1,1) PRIMARY KEY,
Student_ID INT FOREIGN KEY REFERENCES Students(Student_ID),
Amount DECIMAL(10,2) NOT NULL,
Account_Status VARCHAR(20) CHECK (Account_Status IN ('Pending', 'Paid')),
Due_Date DATE NOT NULL
);
GO

CREATE TABLE Attendance(
Attendance_ID INT IDENTITY(1,1) PRIMARY KEY,
Student_ID INT FOREIGN KEY REFERENCES Students(Student_ID),
Date_Of_Attendance DATE NOT NULL,
Attendance_Status VARCHAR(20) CHECK (Attendance_Status IN ('Present', 'Absent'))
);
GO

CREATE TABLE Teachers(
Teacher_ID INT IDENTITY(1,1) PRIMARY KEY,
First_Name VARCHAR(50) NOT NULL,
Last_Name VARCHAR(50) NOT NULL,
Phone_Number VARCHAR(10) UNIQUE NOT NULL,
Email VARCHAR (100) UNIQUE NOT NULL,
Department_ID INT NOT NULL,
CONSTRAINT FK_Teacher_Department FOREIGN KEY (Department_ID) REFERENCES Department(Department_ID),
Subject_ID INT FOREIGN KEY REFERENCES Subjects(Subject_ID)
);
GO

CREATE TABLE Department(
Department_ID INT IDENTITY(1,1) PRIMARY KEY,
 Department_Name VARCHAR(100) NOT NULL UNIQUE CHECK (Department_Name IN ('Junior Department', 'Science Department', 'History Department', 'Business Studies Department')),
 Grade_Level VARCHAR(10) NOT NULL CHECK (Grade_Level IN ('8-9', '10-12'))
);
GO

CREATE TABLE Streams(
Streams_ID INT IDENTITY(1,1) PRIMARY KEY,
Stream_Name VARCHAR(50) NOT NULL UNIQUE CHECK (Stream_Name IN ('Science', 'History', 'Business Studies')),
Grade_Level VARCHAR(10) NOT NULL CHECK (Grade_Level = '10-12')
);
GO

ALTER TABLE Department  
ADD Head_Teacher_ID INT NULL,  
CONSTRAINT FK_Department_Head FOREIGN KEY (Head_Teacher_ID) REFERENCES Teachers(Teacher_ID);
GO

----VIEWS
--1)Student_Details View:This view retrieves detailed student information along with their parent/guardian details.
CREATE VIEW Student_Details AS 
SELECT
S.Student_ID, S.First_Name, S.Last_Name, S.Grade_Level, S.Enrollment_Status, 
P.First_Name AS Parent_First_Name, P.Last_Name AS Parent_Last_Name, P.Phone_Number, P.Email
FROM Students S
JOIN Parents P ON S.Parent_ID = P.Parent_ID;
GO

--2)Unpaid_Students View: This view lists students who have outstanding fees.
CREATE VIEW Unpaid_Students AS  
SELECT 
S.Student_ID, S.First_Name, S.Last_Name, S.Grade_Level, 
F.Amount, F.Account_Status, F.Due_Date
FROM Students S
JOIN Fees F ON S.Student_ID = F.Student_ID
WHERE F.Account_Status = 'Pending';
GO

 ----DYNAMIC PROCEDURES
 --1)GetStudentExamScores Procedure: This procedure retrieves a student's exam scores based on their StudentID.
CREATE PROCEDURE GetStudentExamScores
    @StudentID INT
AS
BEGIN
 SELECT 
E.Exam_Name, SE.Score
FROM Student_Exam SE
JOIN Exams E ON SE.Exam_ID = E.Exam_ID
WHERE SE.Student_ID = @StudentID;
END;
GO

--2)2️⃣ UpdateFeeStatus Procedure: This procedure updates a student’s fee status to 'Paid'.
CREATE PROCEDURE UpdateFeeStatus  
    @StudentID INT  
AS  
BEGIN  
 UPDATE Fees  
SET Account_Status = 'Paid'  
WHERE Student_ID = @StudentID;  
END;  
GO

--3)3️⃣ GetStudentsByGrade Procedure: This procedure retrieves all students from a specific grade level.
CREATE PROCEDURE GetStudentsByGrade  
    @GradeLevel INT  
AS  
BEGIN  
    DECLARE @sql NVARCHAR(MAX);  
    SET @sql = 'SELECT Student_ID, First_Name, Last_Name, Grade_Level FROM Students WHERE Grade_Level = ' + CAST(@GradeLevel AS NVARCHAR(10));  
    EXEC sp_executesql @sql;  
END;

EXEC GetStudentsByGrade @GradeLevel = 12;
GO

--4)UpdateEnrollmentStatus Procedure: This procedure updates a student’s enrollment status (e.g., "Active", "Inactive", "Graduated").
CREATE PROCEDURE UpdateEnrollmentStatus  
    @StudentID INT,  
    @NewStatus NVARCHAR(20)  
AS  
BEGIN  
    DECLARE @sql NVARCHAR(MAX);  
    SET @sql = 'UPDATE Students SET Enrollment_Status = @NewStatus WHERE Student_ID = @StudentID';  
    EXEC sp_executesql @sql, N'@StudentID INT, @NewStatus NVARCHAR(20)', @StudentID, @NewStatus;  
END;


----INSERTING DATA INTO TABLES


INSERT INTO Staff (First_Name, Last_Name, Role, Phone_Number, Email)  
VALUES  
('Thando', 'Mokgatho', 'Teacher', '0710957109', 'thando.mokgatho@eletsa.outlook.com'),  
('Bokamoso', 'Boikanyo', 'Principal', '0794605276', 'bokamoso.boikanyo@eletsa.outlook.com'),  
('Kagiso', 'Mashao', 'Admin', '0813645451', 'kagiso.mashao@eletsa.outlook.com'),  
('Omontle', 'Masedi', 'Support', '0677764524', 'omontle.masedi@eletsa.outlook.com'),  
('Amogelang', 'Mokoena', 'Cleaner', '0659071466', 'amogelang.mokoena@eletsa.outlook.com'),  
('Tumelo', 'Mnisi', 'Security Guard', '0664529848', 'tumelo.mnisi@eletsa.outlook.com'),  
('Tshegofatso', 'Malepe', 'Chef', '0711227128', 'tshegofatso.malepe@eletsa.outlook.com'),  
('Oratile', 'Kekana', 'Food Server', '0699429026', 'oratile.kekana@eletsa.outlook.com');  
GO

INSERT INTO Students (First_Name, Last_Name, Date_Of_Birth, Gender, Grade_Level, Enrollment_Status, Parent_ID) VALUES
('Karabo', 'Phala', '2011-08-11', 'F', 8, 'New', 1),
('Tebogo', 'Aphane', '2010-10-20', 'M', 9, 'Active', 2),
('Tshepo', 'Selomi', '2009-02-15', 'M', 10, 'Transferred', 3),
('Reitumetse', 'Matlou', '2008-05-27', 'F', 11, 'Active', 4),
('Palesa', 'Seletse', '2007-11-12', 'F', 12, 'Active', 5);
GO

INSERT INTO Parents (First_Name, Last_Name, Phone_Number, Email) VALUES
('Dorcas', 'Phala', '0766231632', 'phaladorcas31@gmail.com'),
('Nkele', 'Aphane', '0726449946', 'aphanenkele22@gmail.com'),
('Mogomotsi', 'Selomi', '0631734432', 'selomimogomotsi12@gmail.com'),
('Mary', 'Matlou', '0724431213', 'matloumary36@gmail.com'),
('Senzo', 'Seletse', '0827458383', 'seletsesenzo42@gmail.com');
GO

INSERT INTO Department (Department_Name, Grade_Level)  
VALUES  
('Junior Department', '8-9'),  
('Science Department', '10-12'),  
('History Department', '10-12'),  
('Business Studies Department', '10-12');  
GO


INSERT INTO Teachers (First_Name, Last_Name, Phone_Number, Email, Department_ID)  
VALUES  
('Samuel', 'Matomela', '0763108528', 'samuel.matomela@outlook.com', 3),
('Tshenolo', 'Motloung', '0867890123', 'tshenolo.motloung@outlook.com', 4),  
('Tshepiso', 'Chauke', '0878901234', 'tshepiso.chauke@outlook.com', 5),
('Tumisho', 'Motshegwa', '0834472236', 'tumisho.motshegwa@outlook.com', 6);
GO

UPDATE Department
SET Head_Teacher_ID = 3
WHERE Department_Name = 'Junior Department';

UPDATE Department
SET Head_Teacher_ID = 4
WHERE Department_Name = 'Science Department';

UPDATE Department
SET Head_Teacher_ID = 5
WHERE Department_Name = 'History Department';

UPDATE Department
SET Head_Teacher_ID = 6
WHERE Department_Name = 'Business Studies Department';

INSERT INTO Classes (Grade_Level, Class_Name, Teacher_ID)  
VALUES  
(8, '8A', 3),  
(9, '9B', 3),  
(10, '10C', 4),
(11, '11D', 5),
(12, '12E', 6);
GO

INSERT INTO Subjects (Subject_Name, Teacher_ID)  
VALUES  
('Creative arts',3),
('Technology', 3),
('Mathematics', 4),  
('Physics', 4),  
('History',	5),
('Geography', 5),
('Accounting', 6),
('Business', 6);
GO

INSERT INTO Student_Subject (Student_ID, Subject_ID)  
VALUES  
(2, 1),  
(2, 2),
(3,3),
(4,4),
(5, 5);  
GO

INSERT INTO Exams (Exam_Name, Exam_Date, Grade_Level)  
VALUES  
('Mid-Term Mathematics', '2024-06-15', 8),  
('Final Physics', '2024-11-20', 10),  
('History Test', '2024-09-05', 9);  
GO

INSERT INTO Student_Exam (Exam_ID, Student_ID, Score)  
VALUES  
(1, 2, 85),  
(2, 3, 74),  
(3, 4, 91);  
GO

INSERT INTO Fees (Student_ID, Amount, Account_Status, Due_Date)  
VALUES  
(2, 5000.00, 'Pending', '2024-07-01'),  
(3, 5200.00, 'Paid', '2024-06-01'),  
(4, 4800.00, 'Pending', '2024-08-01');  
GO

INSERT INTO Attendance (Student_ID, Date_Of_Attendance, Attendance_Status)  
VALUES  
(2, '2024-03-30', 'Present'),  
(3, '2024-03-30', 'Absent'),  
(4, '2024-03-30', 'Present');  
GO

INSERT INTO Streams (Stream_Name, Grade_Level)  
VALUES  
('Science', '10-12'),  
('History', '10-12'),  
('Business Studies', '10-12');  
GO

---Verification of the queries/tables
SELECT * FROM Staff;
SELECT * FROM Subjects;
SELECT * FROM Teachers;
SELECT * FROM Parents;
SELECT * FROM Students;
SELECT * FROM Attendance;
SELECT * FROM Fees;
SELECT * FROM Student_Subject;
SELECT * FROM Exams;
SELECT * FROM Student_Exam;
SELECT * FROM Department;
SELECT * FROM Streams;

-------QUERIES

----1) Get Students with Pending Fees
BEGIN TRY
SELECT 
    Student.First_Name AS StudentFirstName, 
    Student.Last_Name AS StudentLastName, 
    Fee.Amount AS FeeAmount, 
    Fee.Due_Date AS FeeDueDate
FROM Students AS Student
JOIN Fees AS Fee ON Student.Student_ID = Fee.Student_ID
WHERE Fee.Account_Status = 'Pending';
END TRY
BEGIN CATCH
    SELECT ERROR_MESSAGE() AS ErrorMessage;
END CATCH;

------2)Get Students that Paid Fees
BEGIN TRY
SELECT 
    Student.First_Name AS StudentFirstName, 
    Student.Last_Name AS StudentLastName, 
    Fee.Amount AS FeeAmount, 
    Fee.Due_Date AS FeeDueDate
FROM Students AS Student
JOIN Fees AS Fee ON Student.Student_ID = Fee.Student_ID
WHERE Fee.Account_Status = 'Paid';
END TRY
BEGIN CATCH
    SELECT ERROR_MESSAGE() AS ErrorMessage;
END CATCH;

----3) Get Teachers by Subject
BEGIN TRY
SELECT 
    Teacher.First_Name AS TeacherFirstName, 
    Teacher.Last_Name AS TeacherLastName, 
    Subject.Subject_Name AS SubjectName
FROM Teachers AS Teacher
JOIN Subjects AS Subject ON Teacher.Subject_ID = Subject.Subject_ID
WHERE Subject.Subject_Name = 'Mathematics';
END TRY
BEGIN CATCH
    SELECT ERROR_MESSAGE() AS ErrorMessage;
END CATCH;

----4)Get Student Exam Scores
BEGIN TRY
SELECT 
    Student.First_Name AS StudentFirstName, 
    Student.Last_Name AS StudentLastName, 
    Exam.Exam_Name AS ExamName, 
    StudentExam.Score AS StudentExamScore
FROM Student_Exam AS StudentExam
JOIN Students AS Student ON StudentExam.Student_ID = Student.Student_ID
JOIN Exams AS Exam ON StudentExam.Exam_ID = Exam.Exam_ID
WHERE Exam.Exam_Name = 'Math Midterm';
END TRY
BEGIN CATCH
    SELECT ERROR_MESSAGE() AS ErrorMessage;
END CATCH;




