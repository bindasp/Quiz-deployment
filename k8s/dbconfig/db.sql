-- Users table
create table "Users"
(
    user_id  serial primary key,
    login    varchar(255),
    password varchar(255),
    email    varchar(255)
);
alter table "Users" owner to root;

-- Tests table
create table "Tests"
(
    test_id             serial primary key,
    user_id             integer references "Users"(user_id) on delete cascade,
    name                varchar(255),
    description         text,
    duration            integer,
    randomize_questions boolean,
    attempt_limit       integer
);
alter table "Tests" owner to root;

-- Questions table
create table "Questions"
(
    question_number integer not null,
    test_id         integer not null,
    content         text,
    question_type   varchar(50),
    primary key (question_number, test_id),
    foreign key (test_id) references "Tests"(test_id) on delete cascade
);
alter table "Questions" owner to root;

-- Answers table
create table "Answers"
(
    answer_number   integer not null,
    question_number integer not null,
    test_id         integer not null,
    content         text,
    is_correct      boolean,
    primary key (test_id, question_number, answer_number),
    foreign key (question_number, test_id) references "Questions"(question_number, test_id) on delete cascade
);
alter table "Answers" owner to root;

create unique index "Answers_answer_number_question_number_test_id_idx"
    on "Answers" (answer_number, question_number, test_id);

-- Attempts table
create table "Attempts"
(
    user_id         integer not null references "Users"(user_id) on delete cascade,
    test_id         integer not null references "Tests"(test_id) on delete cascade,
    start_time      timestamp,
    completion_time timestamp,
    primary key (user_id, test_id)
);
alter table "Attempts" owner to root;

create unique index "Attempts_user_id_test_id_idx"
    on "Attempts" (user_id, test_id);

-- Attempt_Answers table
create table "Attempt_Answers"
(
    user_id         integer not null,
    test_id         integer not null,
    question_number integer not null,
    answer_number   integer not null,
    primary key (user_id, test_id, question_number, answer_number),
    foreign key (user_id, test_id) references "Attempts"(user_id, test_id) on delete cascade,
    foreign key (question_number, test_id) references "Questions"(question_number, test_id) on delete cascade,
    foreign key (answer_number, question_number, test_id) references "Answers"(answer_number, question_number, test_id) on delete cascade
);
alter table "Attempt_Answers" owner to root;

create unique index "Attempt_Answers_user_id_test_id_answer_number_question_number_idx"
    on "Attempt_Answers" (user_id, test_id, answer_number, question_number);

-- Categories table
create table "Categories"
(
    category_id serial primary key,
    name        varchar(255),
    description text
);
alter table "Categories" owner to root;

-- Feedback table
create table "Feedback"
(
    user_id integer not null,
    test_id integer not null,
    comment text,
    rating  integer,
    primary key (user_id, test_id),
    foreign key (user_id, test_id) references "Attempts"(user_id, test_id) on delete cascade
);
alter table "Feedback" owner to root;

create unique index "Feedback_user_id_test_id_idx"
    on "Feedback" (user_id, test_id);

-- Test_Category table
create table "Test_Category"
(
    test_id     integer references "Tests"(test_id) on delete cascade,
    category_id integer references "Categories"(category_id) on delete cascade,
    primary key (test_id, category_id)
);
alter table "Test_Category" owner to root;
