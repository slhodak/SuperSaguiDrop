CREATE TABLE scores (
    id SERIAL PRIMARY KEY,
    user_name VARCHAR(255),
    ts INTEGER,
    saguis_saved INTEGER,
    oncas_tamed INTEGER,
    duration INTEGER,
    total_score INTEGER
);
