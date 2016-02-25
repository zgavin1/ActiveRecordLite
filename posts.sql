CREATE TABLE countries (
	id INTEGER PRIMARY KEY,
	name VARCHAR(255) NOT NULL
);

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  username VARCHAR(255) NOT NULL,
  country_id INTEGER,

  FOREIGN KEY(country_id) REFERENCES country(id)
);

CREATE TABLE posts (
  id INTEGER PRIMARY KEY,
  body VARCHAR(255) NOT NULL,
  author_id INTEGER,

  FOREIGN KEY(author_id) REFERENCES user(id)
);


INSERT INTO
	countries (id, name)
VALUES
	(1, "Portugal"),
	(2, "Nepal"),
	(3, "New Zealand"),
	(4, "Dominican Republic")

INSERT INTO
	users (id, username, country_id)
VALUES
	(1, "Manny", 4),
	(2, "Pedroia", 2),
	(3, "Ortiz", 4),
	(4, "Bogaerts", 3),
	(5, "Mookie", 1)

INSERT INTO
	posts (id, body, author_id)
VALUES
	(1, "I'm Manny!", 1),
	(2, "Pedroia here!", 2),
	(3, "Manny again!", 1),
	(4, "Big Papi in the house", 3),
	(5, "Bogaertsssssss", 4),
	(6, "Don't forget Mookie", 5) 