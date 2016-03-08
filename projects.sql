CREATE TABLE projects (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  student_id INTEGER,

  FOREIGN KEY(student_id) REFERENCES student(id)
);

CREATE TABLE students (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL,
  klass_id INTEGER,

  FOREIGN KEY(klass_id) REFERENCES klass(id)
);

CREATE TABLE klasses (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL
);

INSERT INTO
  klasses (id, name)
VALUES
  (1, "Biology"), (2, "Mathematics");

INSERT INTO
  students (id, fname, lname, klass_id)
VALUES
  (1, "Casey", "Ferrara", 1),
  (2, "Zach", "Gavin", 1),
  (3, "Chris", "Makrides", 2),
  (4, "Colin", "Limberger", NULL);

INSERT INTO
  projects (id, name, student_id)
VALUES
  (1, "Bio Final", 1),
  (2, "Bio Midterm", 2),
  (3, "MathHomework", 3),
  (4, "MathBonus", 3),
  (5, "Unclaimed Project", NULL);
