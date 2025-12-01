--
-- PostgreSQL database dump
--

\restrict I2BzrQBFX4tEn9SHfO4GiFolpZsUUnDp6DhPqx1BVtTbYIUzxfFQR1izvKgPZUd

-- Dumped from database version 18.1
-- Dumped by pg_dump version 18.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

DROP INDEX IF EXISTS public.matches_fixture_id_key;
DROP INDEX IF EXISTS public.import_jobs_status_idx;
DROP INDEX IF EXISTS public.import_jobs_created_at_idx;
DROP INDEX IF EXISTS public.idx_matches_teams;
DROP INDEX IF EXISTS public.idx_matches_fixture_id;
DROP INDEX IF EXISTS public.idx_matches_date;
DROP INDEX IF EXISTS public.idx_matches_created_at;
DROP INDEX IF EXISTS public.idx_matches_country_league;
DROP INDEX IF EXISTS public.idx_import_jobs_job_type;
ALTER TABLE IF EXISTS ONLY public.matches DROP CONSTRAINT IF EXISTS matches_pkey;
ALTER TABLE IF EXISTS ONLY public.import_jobs DROP CONSTRAINT IF EXISTS import_jobs_pkey;
ALTER TABLE IF EXISTS ONLY public._prisma_migrations DROP CONSTRAINT IF EXISTS _prisma_migrations_pkey;
ALTER TABLE IF EXISTS public.matches ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.import_jobs ALTER COLUMN id DROP DEFAULT;
DROP SEQUENCE IF EXISTS public.matches_id_seq;
DROP TABLE IF EXISTS public.matches;
DROP SEQUENCE IF EXISTS public.import_jobs_id_seq;
DROP TABLE IF EXISTS public.import_jobs;
DROP TABLE IF EXISTS public._prisma_migrations;
DROP TYPE IF EXISTS public.match_result_enum;
DROP TYPE IF EXISTS public.job_type_enum;
DROP TYPE IF EXISTS public.job_status_enum;
-- *not* dropping schema, since initdb creates it
--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

-- *not* creating schema, since initdb creates it


--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS '';


--
-- Name: job_status_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.job_status_enum AS ENUM (
    'in_queue',
    'pending',
    'running',
    'paused',
    'completed',
    'failed',
    'rate_limited'
);


--
-- Name: job_type_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.job_type_enum AS ENUM (
    'new_matches',
    'update_results'
);


--
-- Name: match_result_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.match_result_enum AS ENUM (
    'h-win',
    'draw',
    'a-win'
);


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: _prisma_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public._prisma_migrations (
    id character varying(36) NOT NULL,
    checksum character varying(64) NOT NULL,
    finished_at timestamp with time zone,
    migration_name character varying(255) NOT NULL,
    logs text,
    rolled_back_at timestamp with time zone,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    applied_steps_count integer DEFAULT 0 NOT NULL
);


--
-- Name: import_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.import_jobs (
    id integer NOT NULL,
    leagues jsonb NOT NULL,
    date_from date NOT NULL,
    date_to date NOT NULL,
    status public.job_status_enum DEFAULT 'in_queue'::public.job_status_enum NOT NULL,
    progress jsonb DEFAULT '{}'::jsonb,
    total_matches integer DEFAULT 0,
    imported_matches integer DEFAULT 0,
    failed_matches integer DEFAULT 0,
    rate_limit_remaining integer DEFAULT 7500,
    rate_limit_reset_at timestamp with time zone,
    error_message text,
    started_at timestamp with time zone,
    completed_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    hidden boolean DEFAULT false,
    job_type public.job_type_enum DEFAULT 'new_matches'::public.job_type_enum NOT NULL
);


--
-- Name: import_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.import_jobs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: import_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.import_jobs_id_seq OWNED BY public.import_jobs.id;


--
-- Name: matches; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.matches (
    id integer NOT NULL,
    fixture_id integer,
    match_date date NOT NULL,
    country character varying(100) NOT NULL,
    league character varying(150) NOT NULL,
    home_team character varying(100) NOT NULL,
    away_team character varying(100) NOT NULL,
    result public.match_result_enum,
    home_goals integer DEFAULT 0,
    away_goals integer DEFAULT 0,
    home_shots integer DEFAULT 0,
    home_shots_on_target integer DEFAULT 0,
    away_shots integer DEFAULT 0,
    away_shots_on_target integer DEFAULT 0,
    home_corners integer DEFAULT 0,
    away_corners integer DEFAULT 0,
    home_offsides integer DEFAULT 0,
    away_offsides integer DEFAULT 0,
    home_y_cards integer DEFAULT 0,
    away_y_cards integer DEFAULT 0,
    home_r_cards integer DEFAULT 0,
    away_r_cards integer DEFAULT 0,
    home_possession numeric(5,2) DEFAULT 0.00,
    away_possession numeric(5,2) DEFAULT 0.00,
    home_fouls integer DEFAULT 0,
    away_fouls integer DEFAULT 0,
    home_odds numeric(6,2),
    draw_odds numeric(6,2),
    away_odds numeric(6,2),
    standing_home integer,
    standing_away integer,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP,
    home_xg numeric(5,2),
    away_xg numeric(5,2),
    home_goals_ht integer DEFAULT 0,
    away_goals_ht integer DEFAULT 0,
    result_ht character varying(10),
    is_finished character varying(3) DEFAULT 'yes'::character varying
);


--
-- Name: matches_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.matches_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: matches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.matches_id_seq OWNED BY public.matches.id;


--
-- Name: import_jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.import_jobs ALTER COLUMN id SET DEFAULT nextval('public.import_jobs_id_seq'::regclass);


--
-- Name: matches id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.matches ALTER COLUMN id SET DEFAULT nextval('public.matches_id_seq'::regclass);


--
-- Data for Name: _prisma_migrations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) FROM stdin;
ac823a3d-bcd5-47e2-9f59-95f48d3c7d47	19057fe0800a095fe2c590795ffec0be0792fab363c26e85530e1901670d6dcf	\N	20251201000000_add_job_type	A migration failed to apply. New migrations cannot be applied before the error is recovered from. Read more about how to resolve migration issues in a production database: https://pris.ly/d/migrate-resolve\n\nMigration name: 20251201000000_add_job_type\n\nDatabase error code: 42710\n\nDatabase error:\nBŁĄD: typ "job_type_enum" już istnieje\n\nDbError { severity: "BŁĄD", parsed_severity: Some(Error), code: SqlState(E42710), message: "typ \\"job_type_enum\\" już istnieje", detail: None, hint: None, position: None, where_: None, schema: None, table: None, column: None, datatype: None, constraint: None, file: Some("typecmds.c"), line: Some(1213), routine: Some("DefineEnum") }\n\n   0: sql_schema_connector::apply_migration::apply_script\n           with migration_name="20251201000000_add_job_type"\n             at schema-engine\\connectors\\sql-schema-connector\\src\\apply_migration.rs:113\n   1: schema_commands::commands::apply_migrations::Applying migration\n           with migration_name="20251201000000_add_job_type"\n             at schema-engine\\commands\\src\\commands\\apply_migrations.rs:95\n   2: schema_core::state::ApplyMigrations\n             at schema-engine\\core\\src\\state.rs:260	2025-12-01 18:33:06.257904+01	2025-12-01 18:32:02.288006+01	0
406faf53-2cf9-4abe-8006-e98fe3bfade2	7b5829a6dea4b805e9108097566411c8d1f50e5be68f7d2689b82e2a7e3061e7	2025-11-23 23:06:17.778551+01	20251111000000_initial_schema	\N	\N	2025-11-23 23:06:17.663632+01	1
aba98ede-5e03-41ef-9fb1-5bc502ddaa10	a6f137329f270f76614644b0bd794dadff675a49c42c9c850007a34068c8fd82	2025-11-23 23:10:36.333205+01	20251120000001_add_hidden_column		\N	2025-11-23 23:10:36.333205+01	0
709eb92e-c357-4feb-bc70-08e8b4ad6735	3b92a55c2171c0cc1e65b10f5a210b1b70e5b9215f4ac5fa1fae81adcb311d70	2025-11-23 23:18:24.534174+01	20251120000003_add_in_queue_status	\N	\N	2025-11-23 23:18:24.50485+01	1
b6502e3c-5fd7-4207-affb-9a0f6a543894	0f0e882cfead2ac75950a046d234a9d4838d7690466f916cf770ad74c71c69df	\N	20251120000002_add_import_jobs	A migration failed to apply. New migrations cannot be applied before the error is recovered from. Read more about how to resolve migration issues in a production database: https://pris.ly/d/migrate-resolve\n\nMigration name: 20251120000002_add_import_jobs\n\nDatabase error code: 42710\n\nDatabase error:\nBŁĄD: typ "job_status_enum" już istnieje\n\nDbError { severity: "BŁĄD", parsed_severity: Some(Error), code: SqlState(E42710), message: "typ \\"job_status_enum\\" już istnieje", detail: None, hint: None, position: None, where_: None, schema: None, table: None, column: None, datatype: None, constraint: None, file: Some("typecmds.c"), line: Some(1213), routine: Some("DefineEnum") }\n\n   0: sql_schema_connector::apply_migration::apply_script\n           with migration_name="20251120000002_add_import_jobs"\n             at schema-engine\\connectors\\sql-schema-connector\\src\\apply_migration.rs:113\n   1: schema_commands::commands::apply_migrations::Applying migration\n           with migration_name="20251120000002_add_import_jobs"\n             at schema-engine\\commands\\src\\commands\\apply_migrations.rs:95\n   2: schema_core::state::ApplyMigrations\n             at schema-engine\\core\\src\\state.rs:260	2025-11-23 23:13:43.084002+01	2025-11-23 23:11:06.381091+01	0
2ceb8856-c644-46a5-9dbd-17ed0385126d	0f0e882cfead2ac75950a046d234a9d4838d7690466f916cf770ad74c71c69df	2025-11-23 23:13:43.089134+01	20251120000002_add_import_jobs		\N	2025-11-23 23:13:43.089134+01	0
a7d917bf-6fed-47c2-9c6f-179639165604	bca3431e86ccd3f6652d9ff7303bcc08f47ccd0a534344b62d208cdad58a19c2	\N	20251120000003_add_in_queue_status	A migration failed to apply. New migrations cannot be applied before the error is recovered from. Read more about how to resolve migration issues in a production database: https://pris.ly/d/migrate-resolve\n\nMigration name: 20251120000003_add_in_queue_status\n\nDatabase error code: 55P04\n\nDatabase error:\nBŁĄD: unsafe use of new value "in_queue" of enum type job_status_enum\nHINT: Nowe wertości wyliczeniowe muszą być zatwierdzone zanim zostaną użyte.\n\nDbError { severity: "BŁĄD", parsed_severity: Some(Error), code: SqlState(E55P04), message: "unsafe use of new value \\"in_queue\\" of enum type job_status_enum", detail: None, hint: Some("Nowe wertości wyliczeniowe muszą być zatwierdzone zanim zostaną użyte."), position: None, where_: None, schema: None, table: None, column: None, datatype: None, constraint: None, file: Some("enum.c"), line: Some(102), routine: Some("check_safe_enum_use") }\n\n   0: sql_schema_connector::apply_migration::apply_script\n           with migration_name="20251120000003_add_in_queue_status"\n             at schema-engine\\connectors\\sql-schema-connector\\src\\apply_migration.rs:113\n   1: schema_commands::commands::apply_migrations::Applying migration\n           with migration_name="20251120000003_add_in_queue_status"\n             at schema-engine\\commands\\src\\commands\\apply_migrations.rs:95\n   2: schema_core::state::ApplyMigrations\n             at schema-engine\\core\\src\\state.rs:260	2025-11-23 23:17:59.923131+01	2025-11-23 23:14:47.883819+01	0
89b3b485-f0d1-4667-9a79-33c3e01d5f1f	19057fe0800a095fe2c590795ffec0be0792fab363c26e85530e1901670d6dcf	2025-12-01 18:33:06.259661+01	20251201000000_add_job_type		\N	2025-12-01 18:33:06.259661+01	0
bd51e53d-f3f7-45a4-b17a-2efd0a9ab85d	65b099d15da6bd44ae4be8c398a3b0e41c2daddb31c628ffd0eff089864506f6	2025-11-23 23:18:24.543338+01	20251120000003_add_in_queue_status_part2	\N	\N	2025-11-23 23:18:24.535406+01	1
8460f15b-7764-43d9-8281-8ce1b0150dd2	b0c240ae57c7978b07557eef9b3098b6c427e83d759b32f0d72c2fe5554c684b	2025-11-23 23:18:24.560704+01	20251120000004_add_job_type	\N	\N	2025-11-23 23:18:24.544648+01	1
aa33466f-72a7-4f3f-b395-308108b88f88	5bb42562aa1346bea0d552989daf8274e8dd0d62345029797153ee3a0709794d	2025-11-23 23:18:24.604642+01	20251120000005_fix_timezone	\N	\N	2025-11-23 23:18:24.563648+01	1
\.


--
-- Data for Name: import_jobs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.import_jobs (id, leagues, date_from, date_to, status, progress, total_matches, imported_matches, failed_matches, rate_limit_remaining, rate_limit_reset_at, error_message, started_at, completed_at, created_at, updated_at, hidden, job_type) FROM stdin;
8	["2"]	2025-07-01	2025-12-01	completed	{"completed_leagues": [2]}	0	164	0	299	\N	\N	\N	2025-12-01 19:08:25.904195+01	2025-12-01 18:48:57.981997+01	2025-12-01 19:08:25.904195+01	f	new_matches
9	["3", "15", "531", "848", "106", "107", "109"]	2025-07-01	2025-12-01	completed	{"completed_leagues": [3, 15, 531, 848, 106, 107, 109]}	0	955	0	125	2025-12-01 23:04:46.462+01	\N	\N	2025-12-01 23:05:05.211003+01	2025-12-01 19:02:34.75213+01	2025-12-01 23:05:05.211003+01	f	new_matches
10	["39", "42", "40", "41", "45", "43", "140", "141", "436", "435", "875", "876", "877", "878", "879", "143"]	2025-07-01	2025-12-01	pending	{}	0	0	0	7500	\N	\N	\N	\N	2025-12-01 19:03:01.14205+01	2025-12-01 23:05:05.212847+01	f	new_matches
11	["135", "136", "137", "138", "942", "943", "78", "79", "81", "80"]	2025-07-01	2025-12-01	in_queue	{}	0	0	0	7500	\N	\N	\N	\N	2025-12-01 19:03:36.519277+01	2025-12-01 19:03:36.519277+01	f	new_matches
12	["61", "62", "63", "66", "94", "95", "144", "145", "88", "89", "203", "204"]	2025-07-01	2025-12-01	in_queue	{}	0	0	0	7500	\N	\N	\N	\N	2025-12-01 19:04:32.146282+01	2025-12-01 19:04:32.146282+01	f	new_matches
13	["186", "307", "308", "128", "129", "342", "188", "1202", "218", "219", "419", "116", "117", "344", "72", "71", "172"]	2025-07-01	2025-12-01	in_queue	{}	0	0	0	7500	\N	\N	\N	\N	2025-12-01 19:04:54.521857+01	2025-12-01 19:04:54.521857+01	f	new_matches
14	["265", "169", "210", "211", "318", "346", "345", "119", "120", "233", "242", "329", "363", "197", "494", "339"]	2025-07-01	2025-12-01	in_queue	{}	0	0	0	7500	\N	\N	\N	\N	2025-12-01 19:05:22.289881+01	2025-12-01 19:05:22.289881+01	f	new_matches
15	["234", "274", "542", "291", "407", "98", "99", "305", "240", "239", "292", "293", "162", "361", "261"]	2025-07-01	2025-12-01	in_queue	{}	0	0	0	7500	\N	\N	\N	\N	2025-12-01 19:05:46.03362+01	2025-12-01 19:05:46.03362+01	f	new_matches
16	["262", "263", "103", "104", "955", "304", "252", "281", "288", "283", "284", "286", "506", "332", "373"]	2025-07-01	2025-12-01	in_queue	{}	0	0	0	7500	\N	\N	\N	\N	2025-12-01 19:06:18.134007+01	2025-12-01 19:06:18.134007+01	f	new_matches
17	["179", "183", "180", "207", "208", "114", "113", "296", "591", "585", "333", "269", "268", "270", "253", "369", "110", "271", "301"]	2025-07-01	2025-12-01	in_queue	{}	0	0	0	7500	\N	\N	\N	\N	2025-12-01 19:06:46.269704+01	2025-12-01 19:06:46.269704+01	f	new_matches
\.


--
-- Data for Name: matches; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.matches (id, fixture_id, match_date, country, league, home_team, away_team, result, home_goals, away_goals, home_shots, home_shots_on_target, away_shots, away_shots_on_target, home_corners, away_corners, home_offsides, away_offsides, home_y_cards, away_y_cards, home_r_cards, away_r_cards, home_possession, away_possession, home_fouls, away_fouls, home_odds, draw_odds, away_odds, standing_home, standing_away, created_at, home_xg, away_xg, home_goals_ht, away_goals_ht, result_ht, is_finished) FROM stdin;
1	1451092	2025-11-25	World	UEFA Champions League	Ajax	Benfica	a-win	0	1	4	1	6	2	3	2	0	0	0	0	0	0	63.00	37.00	8	4	3.50	3.55	2.02	36	35	2025-11-25 19:57:04.81256	0.44	0.31	0	1	a-win	no
2	1451093	2025-11-25	World	UEFA Champions League	Galatasaray	Union St. Gilloise	draw	0	0	9	1	10	2	2	5	1	3	1	1	0	0	59.00	41.00	5	7	1.69	4.00	4.50	9	28	2025-11-25 19:57:05.00598	0.48	0.49	0	0	draw	no
3	1451096	2025-11-25	World	UEFA Champions League	Chelsea	Barcelona	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2.20	3.70	2.98	12	11	2025-11-25 19:57:05.215524	\N	\N	0	0	draw	no
4	1451094	2025-11-25	World	UEFA Champions League	Manchester City	Bayer Leverkusen	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.26	5.70	11.00	4	21	2025-11-25 19:57:05.421386	\N	\N	0	0	draw	no
5	1451095	2025-11-25	World	UEFA Champions League	Marseille	Newcastle	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3.00	3.35	2.34	25	6	2025-11-25 19:57:05.613	\N	\N	0	0	draw	no
6	1451098	2025-11-25	World	UEFA Champions League	Borussia Dortmund	Villarreal	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.82	3.75	4.10	14	32	2025-11-25 19:57:05.818377	\N	\N	0	0	draw	no
7	1451100	2025-11-25	World	UEFA Champions League	Bodo/Glimt	Juventus	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3.05	3.65	2.20	29	26	2025-11-25 19:57:06.056227	\N	\N	0	0	draw	no
8	1451097	2025-11-25	World	UEFA Champions League	Napoli	Qarabag	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.26	5.80	10.25	24	15	2025-11-25 19:57:06.257098	\N	\N	0	0	draw	no
9	1451099	2025-11-25	World	UEFA Champions League	Slavia Praha	Athletic Club	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3.10	3.30	2.32	30	27	2025-11-25 19:57:06.451348	\N	\N	0	0	draw	no
10	1451101	2025-11-26	World	UEFA Champions League	FC Copenhagen	Kairat Almaty	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.33	5.00	9.00	33	34	2025-11-25 19:57:06.660919	\N	\N	0	0	draw	no
11	1451102	2025-11-26	World	UEFA Champions League	Pafos	Monaco	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5.00	3.90	1.65	20	19	2025-11-25 19:57:06.860692	\N	\N	0	0	draw	no
12	1451109	2025-11-26	World	UEFA Champions League	Liverpool	PSV Eindhoven	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.30	6.00	7.80	8	18	2025-11-25 19:57:07.059027	\N	\N	0	0	draw	no
13	1451107	2025-11-26	World	UEFA Champions League	Arsenal	Bayern München	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2.20	3.50	3.15	2	1	2025-11-25 19:57:07.264017	\N	\N	0	0	draw	no
14	1451105	2025-11-26	World	UEFA Champions League	Paris Saint Germain	Tottenham	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.34	5.10	8.60	5	10	2025-11-25 19:57:07.458215	\N	\N	0	0	draw	no
15	1451108	2025-11-26	World	UEFA Champions League	Eintracht Frankfurt	Atalanta	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2.58	3.50	2.58	23	16	2025-11-25 19:57:07.642728	\N	\N	0	0	draw	no
16	1451106	2025-11-26	World	UEFA Champions League	Sporting CP	Club Brugge KV	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.61	4.10	5.20	13	22	2025-11-25 19:57:07.847626	\N	\N	0	0	draw	no
17	1451104	2025-11-26	World	UEFA Champions League	Atletico Madrid	Inter	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2.28	3.40	3.05	17	3	2025-11-25 19:57:08.049914	\N	\N	0	0	draw	no
18	1451103	2025-11-26	World	UEFA Champions League	Olympiakos Piraeus	Real Madrid	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7.00	4.70	1.42	31	7	2025-11-25 19:57:08.272718	\N	\N	0	0	draw	no
19	1451239	2025-11-27	World	UEFA Europa League	Aston Villa	BSC Young Boys	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.20	6.40	15.00	6	22	2025-11-25 19:57:09.653896	\N	\N	0	0	draw	no
20	1451236	2025-11-27	World	UEFA Europa League	Lille	Dinamo Zagreb	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.54	4.20	5.80	19	12	2025-11-25 19:57:09.848092	\N	\N	0	0	draw	no
21	1451231	2025-11-27	World	UEFA Europa League	Feyenoord	Celtic	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.69	4.00	4.45	29	27	2025-11-25 19:57:10.054946	\N	\N	0	0	draw	no
22	1451238	2025-11-27	World	UEFA Europa League	FC Porto	Nice	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.40	4.60	7.80	14	35	2025-11-25 19:57:10.253789	\N	\N	0	0	draw	no
23	1451235	2025-11-27	World	UEFA Europa League	AS Roma	FC Midtjylland	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.44	4.40	7.20	18	1	2025-11-25 19:57:10.44959	\N	\N	0	0	draw	no
24	1451233	2025-11-27	World	UEFA Europa League	Ludogorets	Celta Vigo	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5.00	3.55	1.73	30	4	2025-11-25 19:57:10.643843	\N	\N	0	0	draw	no
25	1451237	2025-11-27	World	UEFA Europa League	Plzen	SC Freiburg	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3.15	3.30	2.26	8	2	2025-11-25 19:57:10.83992	\N	\N	0	0	draw	no
26	1451234	2025-11-27	World	UEFA Europa League	Fenerbahce	Ferencvarosi TC	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.51	4.45	5.75	15	3	2025-11-25 19:57:11.040265	\N	\N	0	0	draw	no
27	1451232	2025-11-27	World	UEFA Europa League	PAOK	Brann	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.57	4.20	5.40	10	11	2025-11-25 19:57:11.229664	\N	\N	0	0	draw	no
28	1451246	2025-11-27	World	UEFA Europa League	Nottingham Forest	Malmo FF	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.20	6.00	15.00	23	33	2025-11-25 19:57:11.427759	\N	\N	0	0	draw	no
29	1451241	2025-11-27	World	UEFA Europa League	Rangers	SC Braga	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3.20	3.30	2.24	36	5	2025-11-25 19:57:11.608222	\N	\N	0	0	draw	no
30	1451242	2025-11-27	World	UEFA Europa League	GO Ahead Eagles	VfB Stuttgart	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6.75	4.40	1.46	21	20	2025-11-25 19:57:11.802821	\N	\N	0	0	draw	no
31	1451240	2025-11-27	World	UEFA Europa League	Bologna	Red Bull Salzburg	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.37	4.60	8.60	24	28	2025-11-25 19:57:12.001743	\N	\N	0	0	draw	no
32	1451244	2025-11-27	World	UEFA Europa League	Real Betis	Utrecht	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.34	4.85	9.25	9	32	2025-11-25 19:57:12.19374	\N	\N	0	0	draw	no
33	1451243	2025-11-27	World	UEFA Europa League	FK Crvena Zvezda	FCSB	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.42	4.45	7.60	26	31	2025-11-25 19:57:12.407365	\N	\N	0	0	draw	no
34	1451248	2025-11-27	World	UEFA Europa League	Maccabi Tel Aviv	Lyon	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4.45	3.80	1.75	34	7	2025-11-25 19:57:12.606804	\N	\N	0	0	draw	no
35	1451245	2025-11-27	World	UEFA Europa League	Panathinaikos	Sturm Graz	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.69	3.60	5.25	16	25	2025-11-25 19:57:12.795731	\N	\N	0	0	draw	no
36	1451247	2025-11-27	World	UEFA Europa League	Genk	FC Basel 1893	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.95	3.75	3.55	13	17	2025-11-25 19:57:13.028784	\N	\N	0	0	draw	no
37	1451405	2025-11-27	World	UEFA Europa Conference League	AZ Alkmaar	Shelbourne	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.21	5.90	15.00	27	30	2025-11-25 19:57:16.655246	\N	\N	0	0	draw	no
38	1451408	2025-11-27	World	UEFA Europa Conference League	Lech Poznan	Lausanne	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.89	3.90	3.60	23	5	2025-11-25 19:57:16.866433	\N	\N	0	0	draw	no
39	1451404	2025-11-27	World	UEFA Europa Conference League	Zrinjski	BK Hacken	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2.54	3.35	2.74	26	28	2025-11-25 19:57:17.058776	\N	\N	0	0	draw	no
40	1451406	2025-11-27	World	UEFA Europa Conference League	Universitatea Craiova	FSV Mainz 05	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4.40	3.55	1.81	20	3	2025-11-25 19:57:17.244428	\N	\N	0	0	draw	no
41	1451407	2025-11-27	World	UEFA Europa Conference League	Slovan Bratislava	Rayo Vallecano	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4.80	3.90	1.68	34	6	2025-11-25 19:57:17.443045	\N	\N	0	0	draw	no
42	1451411	2025-11-27	World	UEFA Europa Conference League	Sigma Olomouc	Celje	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2.42	3.35	2.88	19	2	2025-11-25 19:57:17.641537	\N	\N	0	0	draw	no
43	1451409	2025-11-27	World	UEFA Europa Conference League	Omonia Nicosia	Dynamo Kyiv	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2.22	3.25	3.35	29	24	2025-11-25 19:57:17.835896	\N	\N	0	0	draw	no
44	1451412	2025-11-27	World	UEFA Europa Conference League	Raków Częstochowa	Rapid Vienna	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.81	3.45	4.60	12	36	2025-11-25 19:57:18.042835	\N	\N	0	0	draw	no
45	1451410	2025-11-27	World	UEFA Europa Conference League	Hamrun Spartans	Lincoln Red Imps FC	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.62	3.90	5.30	35	22	2025-11-25 19:57:18.247966	\N	\N	0	0	draw	no
46	1451419	2025-11-27	World	UEFA Europa Conference League	Strasbourg	Crystal Palace	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4.30	3.50	1.84	7	9	2025-11-25 19:57:18.44076	\N	\N	0	0	draw	no
47	1451418	2025-11-27	World	UEFA Europa Conference League	Aberdeen	FC Noah	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2.14	3.50	3.30	33	17	2025-11-25 19:57:18.640703	\N	\N	0	0	draw	no
48	1451420	2025-11-27	World	UEFA Europa Conference League	Breidablik	Samsunspor	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4.75	4.10	1.64	32	1	2025-11-25 19:57:18.825983	\N	\N	0	0	draw	no
49	1451421	2025-11-27	World	UEFA Europa Conference League	Jagiellonia	KuPS	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.53	4.20	5.90	14	11	2025-11-25 19:57:19.016451	\N	\N	0	0	draw	no
50	1451415	2025-11-27	World	UEFA Europa Conference League	Legia Warszawa	Sparta Praha	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2.45	3.40	2.80	25	16	2025-11-25 19:57:19.185226	\N	\N	0	0	draw	no
51	1451416	2025-11-27	World	UEFA Europa Conference League	Fiorentina	AEK Athens FC	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.72	3.60	5.00	8	15	2025-11-25 19:57:19.387573	\N	\N	0	0	draw	no
52	1451417	2025-11-27	World	UEFA Europa Conference League	HNK Rijeka	AEK Larnaca	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2.28	3.30	3.15	18	4	2025-11-25 19:57:19.578389	\N	\N	0	0	draw	no
53	1451414	2025-11-27	World	UEFA Europa Conference League	Shamrock Rovers	Shakhtar Donetsk	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7.50	4.50	1.42	31	10	2025-11-25 19:57:19.767252	\N	\N	0	0	draw	no
54	1451413	2025-11-27	World	UEFA Europa Conference League	Drita	Shkendija	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	13	21	2025-11-25 19:57:19.929447	\N	\N	0	0	draw	no
55	1395956	2025-11-26	Poland	II Liga - East	Sokół Kleczew	ŁKS Łódź II	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.60	3.60	4.60	11	17	2025-11-25 19:57:23.499799	\N	\N	0	0	draw	no
56	1386206	2025-11-27	England	League Two	Grimsby	Tranmere	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.73	3.70	4.50	9	16	2025-11-25 19:57:26.068564	\N	\N	0	0	draw	no
57	1386747	2025-11-25	England	Championship	Watford	Preston	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.81	3.45	4.60	11	5	2025-11-25 19:57:27.478519	\N	\N	0	0	draw	no
58	1386746	2025-11-25	England	Championship	Hull City	Ipswich	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4.80	3.80	1.70	6	8	2025-11-25 19:57:27.676496	\N	\N	0	0	draw	no
59	1386748	2025-11-25	England	Championship	Middlesbrough	Coventry	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2.72	3.35	2.54	2	1	2025-11-25 19:57:27.872609	\N	\N	0	0	draw	no
60	1386754	2025-11-25	England	Championship	Norwich	Oxford United	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.86	3.55	4.10	23	21	2025-11-25 19:57:28.078183	\N	\N	0	0	draw	no
61	1386745	2025-11-25	England	Championship	Stoke City	Charlton	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.74	3.60	4.80	3	13	2025-11-25 19:57:28.266576	\N	\N	0	0	draw	no
62	1386749	2025-11-25	England	Championship	Swansea	Derby	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2.14	3.10	3.70	20	12	2025-11-25 19:57:28.437185	\N	\N	0	0	draw	no
63	1386750	2025-11-25	England	Championship	Southampton	Leicester	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.89	3.60	3.90	16	10	2025-11-25 19:57:28.632317	\N	\N	0	0	draw	no
64	1386744	2025-11-26	England	Championship	Millwall	Sheffield Wednesday	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.69	3.70	5.10	7	24	2025-11-25 19:57:28.818846	\N	\N	0	0	draw	no
65	1386743	2025-11-26	England	Championship	Sheffield Utd	Portsmouth	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.77	3.55	4.65	22	19	2025-11-25 19:57:29.02116	\N	\N	0	0	draw	no
66	1386752	2025-11-26	England	Championship	Blackburn	QPR	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2.15	3.35	3.40	18	15	2025-11-25 19:57:29.237558	\N	\N	0	0	draw	no
67	1386753	2025-11-26	England	Championship	Wrexham	Bristol City	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2.52	3.25	2.82	14	4	2025-11-25 19:57:29.417412	\N	\N	0	0	draw	no
68	1386751	2025-11-26	England	Championship	West Brom	Birmingham	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2.74	3.05	2.74	17	9	2025-11-25 19:57:29.615139	\N	\N	0	0	draw	no
69	1387243	2025-11-25	England	League One	Peterborough	Stevenage	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2.34	3.10	3.10	21	6	2025-11-25 19:57:30.978547	\N	\N	0	0	draw	no
70	1387240	2025-11-25	England	League One	Luton	Huddersfield	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2.22	3.25	3.20	12	7	2025-11-25 19:57:31.138792	\N	\N	0	0	draw	no
71	1391897	2025-11-26	Spain	Segunda División	AD Ceuta FC	Almeria	draw	0	0	4	2	9	3	0	1	1	2	1	2	0	0	47.00	53.00	8	8	\N	\N	\N	17	4	2025-11-25 19:57:35.816181	\N	\N	1	1	draw	no
72	1439489	2025-11-26	Italy	Serie C - Girone B	Gubbio	Juventus U23	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.95	2.95	3.95	12	14	2025-11-25 19:57:50.458992	\N	\N	0	0	draw	no
73	1389215	2025-11-25	France	Ligue 2	Bastia	Laval	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2.20	3.00	3.55	18	17	2025-11-25 19:57:58.580486	\N	\N	0	0	draw	no
74	1382080	2025-11-25	Netherlands	Eerste Divisie	ADO Den Haag	De Graafschap	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.48	4.80	5.40	1	7	2025-11-25 19:58:07.788848	\N	\N	0	0	draw	no
75	1382082	2025-11-25	Netherlands	Eerste Divisie	Vitesse	Jong PSV U21	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.95	4.10	3.20	20	3	2025-11-25 19:58:07.985218	\N	\N	0	0	draw	no
76	1382081	2025-11-25	Netherlands	Eerste Divisie	Roda	Dordrecht	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.73	3.90	4.20	4	11	2025-11-25 19:58:08.19923	\N	\N	0	0	draw	no
77	1382083	2025-11-25	Netherlands	Eerste Divisie	Waalwijk	MVV	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.28	5.75	9.00	8	18	2025-11-25 19:58:08.408559	\N	\N	0	0	draw	no
78	1437369	2025-11-27	Saudi-Arabia	Division 1	Abha	Al Bukayriyah	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.77	3.30	4.33	1	5	2025-11-25 19:58:14.190215	\N	\N	0	0	draw	no
79	1437370	2025-11-27	Saudi-Arabia	Division 1	Al-Adalah	Al Ula	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5.75	4.10	1.45	16	2	2025-11-25 19:58:14.36968	\N	\N	0	0	draw	no
80	1437371	2025-11-27	Saudi-Arabia	Division 1	Jeddah Club	Al Jandal	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.80	3.25	4.00	8	11	2025-11-25 19:58:14.53879	\N	\N	0	0	draw	no
81	1486753	2025-11-25	Argentina	Liga Profesional Argentina	Union Santa Fe	Gimnasia L.P.	a-win	1	2	22	7	6	3	6	3	0	0	2	4	0	0	64.00	36.00	9	12	1.73	3.35	5.50	2	\N	2025-11-25 19:58:15.916486	1.09	1.31	0	2	a-win	yes
82	1486750	2025-11-27	Argentina	Liga Profesional Argentina	Lanus	Tigre	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2.02	3.00	4.33	\N	7	2025-11-25 19:58:16.106654	\N	\N	0	0	draw	no
83	1423824	2025-11-25	Armenia	Premier League	Pyunik Yerevan	Ararat-Armenia	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2.45	3.00	2.75	4	1	2025-11-25 19:58:18.552256	\N	\N	1	0	h-win	yes
84	1378582	2025-11-26	Belarus	1. Division	ABFF U19	Gomel II	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	15	2025-11-25 19:58:26.559898	\N	\N	0	0	draw	no
85	1477878	2025-11-26	Belarus	1. Division	Dinamo Minsk II	Osipovichy	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	13	17	2025-11-25 19:58:26.727427	\N	\N	0	0	draw	no
86	1478022	2025-11-25	Brazil	Serie A	Internacional	Santos	draw	1	1	24	4	4	2	5	0	0	2	0	2	0	0	54.00	46.00	13	10	2.14	3.30	3.50	15	17	2025-11-25 19:58:30.370693	1.33	0.19	1	0	h-win	yes
87	1478032	2025-11-26	Brazil	Serie A	Gremio	Palmeiras	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2.18	3.25	3.40	12	2	2025-11-25 19:58:30.597847	\N	\N	0	0	draw	no
88	1478027	2025-11-26	Brazil	Serie A	Atletico-MG	Flamengo	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4.00	3.30	1.98	11	1	2025-11-25 19:58:30.793111	\N	\N	0	0	draw	no
89	1478028	2025-11-26	Brazil	Serie A	RB Bragantino	Fortaleza EC	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.91	3.55	3.95	9	18	2025-11-25 19:58:30.995917	\N	\N	0	0	draw	no
90	1478031	2025-11-28	Brazil	Serie A	Fluminense	Sao Paulo	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.91	3.20	4.45	7	8	2025-11-25 19:58:31.190687	\N	\N	0	0	draw	no
91	1488176	2025-11-26	Chile	Primera División	San Marcos de Arica	Cobreloa	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2.55	3.00	2.70	\N	\N	2025-11-25 19:58:33.674458	\N	\N	0	0	draw	no
92	1488177	2025-11-27	Chile	Primera División	Concepción	Deportes Copiapo	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-25 19:58:33.835987	\N	\N	0	0	draw	no
93	1418890	2025-11-25	Egypt	Premier League	Pyramids FC	El Mokawloon	h-win	2	0	11	4	6	0	4	6	4	2	3	3	0	0	70.00	30.00	10	8	1.38	4.10	8.20	2	18	2025-11-25 19:58:44.143579	\N	\N	1	0	h-win	yes
94	1482192	2025-11-25	Ethiopia	Premier League	Adama Kenema	Bahardar	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3.45	2.70	2.15	6	9	2025-11-25 19:58:47.734363	\N	\N	0	0	draw	yes
95	1482191	2025-11-25	Ethiopia	Premier League	Welayta Dicha	Welwalo Adigrat Uni	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.75	3.00	4.60	16	20	2025-11-25 19:58:47.907965	\N	\N	1	1	draw	yes
96	1482308	2025-11-25	Ethiopia	Premier League	Ethiopian Medhin	Negelle Arsi	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2.25	2.70	3.30	12	10	2025-11-25 19:58:48.091109	\N	\N	0	0	draw	yes
97	1482193	2025-11-26	Ethiopia	Premier League	Mekelakeya	Sidama Bunna	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2.62	2.50	2.88	3	1	2025-11-25 19:58:48.252734	\N	\N	0	0	draw	no
98	1482195	2025-11-26	Ethiopia	Premier League	Mebrat Hayl	Kedus Giorgis	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3.20	2.50	2.40	7	5	2025-11-25 19:58:48.416426	\N	\N	0	0	draw	no
99	1482194	2025-11-26	Ethiopia	Premier League	Awassa Kenema	Fasil Ketema	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2.50	2.50	3.00	2	4	2025-11-25 19:58:48.577362	\N	\N	0	0	draw	no
100	1482309	2025-11-26	Ethiopia	Premier League	Sheger Ketema	Ethiopia Bunna	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2.75	2.80	2.50	11	17	2025-11-25 19:58:48.733286	\N	\N	0	0	draw	no
101	1482196	2025-11-27	Ethiopia	Premier League	Dire Dawa Kenema	Suhul Shire	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8	14	2025-11-25 19:58:48.899864	\N	\N	0	0	draw	no
102	1482197	2025-11-27	Ethiopia	Premier League	Mekelle Kenema	Ethiopia Nigd Bank	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	18	13	2025-11-25 19:58:49.057354	\N	\N	0	0	draw	no
103	1482198	2025-11-27	Ethiopia	Premier League	Hadiya Hosaena	Arba Minch Kenema	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	15	19	2025-11-25 19:58:49.137169	\N	\N	0	0	draw	no
104	1390764	2025-11-27	Guatemala	Liga Nacional	Municipal	Guastatoya	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	11	2025-11-25 20:13:54.778873	\N	\N	0	0	draw	no
105	1486113	2025-11-26	Honduras	Liga Nacional	Platense FC	Olancho	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7	6	2025-11-25 20:13:56.27058	\N	\N	0	0	draw	no
106	1486114	2025-11-27	Honduras	Liga Nacional	Juticalpa	Victoria	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8	11	2025-11-25 20:13:56.4242	\N	\N	0	0	draw	no
107	1486115	2025-11-27	Honduras	Liga Nacional	Real Espana	Génesis	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	9	2025-11-25 20:13:56.572427	\N	\N	0	0	draw	no
108	1486116	2025-11-28	Honduras	Liga Nacional	Atlético Choloma	CD Marathon	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	10	2	2025-11-25 20:13:56.727375	\N	\N	0	0	draw	no
109	1403680	2025-11-27	Indonesia	Liga 1	Persik Kediri	Semen Padang	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.67	3.55	4.60	13	17	2025-11-25 20:13:58.124886	\N	\N	0	0	draw	no
110	1403679	2025-11-27	Indonesia	Liga 1	PSBS Biak Numfor	Persijap	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3.50	3.25	1.95	15	16	2025-11-25 20:13:58.399876	\N	\N	0	0	draw	no
111	1486240	2025-11-27	Iran	Azadegan League	Ario Eslamshahr	Saipa	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	11	3	2025-11-25 20:14:00.866503	\N	\N	0	0	draw	no
112	1486241	2025-11-27	Iran	Azadegan League	Naft Bandar Abbas	Navad Urmia	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	13	7	2025-11-25 20:14:01.021746	\N	\N	0	0	draw	no
113	1487902	2025-11-26	Colombia	Primera A	Santa Fe	Deportes Tolima	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2.34	2.96	3.40	7	2	2025-11-25 20:14:07.99768	\N	\N	0	0	draw	no
114	1487903	2025-11-27	Colombia	Primera A	Bucaramanga	Fortaleza FC	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.81	3.40	4.70	4	6	2025-11-25 20:14:08.190227	\N	\N	0	0	draw	no
115	1487904	2025-11-27	Colombia	Primera A	Atletico Nacional	Junior	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.58	4.00	5.60	3	5	2025-11-25 20:14:08.425001	\N	\N	0	0	draw	no
116	1488145	2025-11-27	South-Korea	K League 2	Seoul E-Land FC	Seongnam FC	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2.05	3.35	3.30	4	5	2025-11-25 20:14:10.879753	\N	\N	0	0	draw	no
117	1392925	2025-11-25	Costa-Rica	Primera División	Perez Zeledon	CS Cartagines	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2.40	3.10	2.75	5	3	2025-11-25 20:14:12.244499	\N	\N	1	2	a-win	yes
118	1393519	2025-11-26	Luxembourg	National Division	FC Differdange 03	Rodange 91	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	14	2025-11-25 20:14:14.70853	\N	\N	0	0	draw	no
119	1393538	2025-11-26	Luxembourg	National Division	Swift Hesperange	Racing FC Union Luxembourg	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3.25	3.35	2.05	9	13	2025-11-25 20:14:14.882352	\N	\N	0	0	draw	no
120	1488194	2025-11-27	Mexico	Liga MX	FC Juarez	Toluca	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3.60	3.45	2.04	8	1	2025-11-25 20:14:16.276207	\N	\N	0	0	draw	no
121	1486000	2025-11-27	Mexico	Liga MX	Monterrey	Club America	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2.72	3.35	2.55	5	4	2025-11-25 20:14:16.487101	\N	\N	0	0	draw	no
122	1487900	2025-11-27	Mexico	Liga MX	Club Tijuana	Tigres UANL	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3.65	3.65	1.92	7	2	2025-11-25 20:14:16.646171	\N	\N	0	0	draw	no
123	1488139	2025-11-26	Norway	1. Division	Aalesund	Egersund	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	5	2025-11-25 20:14:20.231508	\N	\N	0	0	draw	no
124	1396936	2025-11-26	Paraguay	Division Profesional - Clausura	Sportivo Ameliano	Sportivo Trinidense	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2.92	3.05	2.38	11	4	2025-11-25 20:14:23.890367	\N	\N	0	0	draw	no
125	1396940	2025-11-26	Paraguay	Division Profesional - Clausura	Olimpia	2 de Mayo	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.88	3.35	3.90	7	5	2025-11-25 20:14:24.082891	\N	\N	0	0	draw	no
126	1396938	2025-11-27	Paraguay	Division Profesional - Clausura	Libertad Asuncion	General Caballero	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.78	3.40	4.30	10	9	2025-11-25 20:14:24.242578	\N	\N	0	0	draw	no
127	1396935	2025-11-28	Paraguay	Division Profesional - Clausura	Deportivo Recoleta	Nacional Asuncion	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3.30	3.25	2.08	6	3	2025-11-25 20:14:24.426163	\N	\N	0	0	draw	no
128	1429569	2025-11-25	South-Africa	Premier Soccer League	Orlando Pirates	Chippa United	h-win	1	0	20	5	5	3	6	1	2	1	1	3	0	0	66.00	34.00	8	11	1.27	4.90	13.00	2	16	2025-11-25 20:14:26.889869	\N	\N	0	0	draw	no
129	1429573	2025-11-26	South-Africa	Premier Soccer League	Orbit College	Stellenbosch	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3.95	2.90	2.12	13	15	2025-11-25 20:14:27.048977	\N	\N	0	0	draw	no
130	1429572	2025-11-26	South-Africa	Premier Soccer League	Magesi	Kaizer Chiefs	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3.70	2.86	2.22	14	4	2025-11-25 20:14:27.213446	\N	\N	0	0	draw	no
131	1418300	2025-11-25	Romania	Liga II	Politehnica Iasi	Chindia Targoviste	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2.20	3.20	3.00	9	11	2025-11-25 20:14:29.6666	\N	\N	0	0	draw	yes
132	1382730	2025-11-25	Scotland	Premiership	Motherwell	Hibernian	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2.52	3.35	2.74	6	3	2025-11-25 20:14:35.46118	\N	\N	0	0	draw	no
133	1383109	2025-11-25	Scotland	League One	Alloa Athletic	Inverness CT	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4.50	3.60	1.67	3	1	2025-11-25 20:14:36.819709	\N	\N	0	0	draw	no
134	1382935	2025-11-25	Scotland	Championship	Partick	Dunfermline	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.87	3.20	4.10	2	5	2025-11-25 20:14:38.182338	\N	\N	0	0	draw	no
135	1382360	2025-11-26	Switzerland	Super League	FC Lugano	FC ST. Gallen	draw	0	0	7	1	8	1	2	2	1	0	1	1	0	0	62.00	38.00	5	9	2.00	3.65	3.45	5	3	2025-11-25 20:14:39.533602	\N	\N	1	0	h-win	no
136	1476710	2025-11-25	Uganda	Premier League	Maroons	Lugazi	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.85	3.20	4.00	11	9	2025-11-25 20:14:46.41325	\N	\N	2	0	h-win	yes
137	1476712	2025-11-25	Uganda	Premier League	UPDF	SC Villa	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3.00	2.85	2.25	14	1	2025-11-25 20:14:46.582922	\N	\N	0	0	draw	yes
138	1476715	2025-11-25	Uganda	Premier League	NEC	Calvary	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.18	4.80	14.00	13	16	2025-11-25 20:14:46.74425	\N	\N	0	0	draw	yes
139	1476779	2025-11-26	Uganda	Premier League	URA	Buhimba Saints	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	10	2025-11-25 20:14:46.900062	\N	\N	0	0	draw	no
140	1476714	2025-11-26	Uganda	Premier League	Express	Vipers	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8	7	2025-11-25 20:14:47.0525	\N	\N	0	0	draw	no
141	1476764	2025-11-27	Uganda	Premier League	BUL	Entebbe UPPC	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	5	2025-11-25 20:14:47.209891	\N	\N	0	0	draw	no
142	1476711	2025-11-27	Uganda	Premier League	Police	Kitara	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	4	2025-11-25 20:14:47.368771	\N	\N	0	0	draw	no
143	1485789	2025-11-25	USA	Major League Soccer	San Diego	Minnesota United FC	h-win	1	0	9	1	11	4	5	1	1	1	2	4	0	0	71.00	29.00	14	14	1.58	4.20	5.30	1	4	2025-11-25 20:14:53.134033	0.70	0.79	0	0	draw	yes
144	1383422	2025-07-08	World	UEFA Champions League	KuPS	Milsami Orhei	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 18:57:33.931862	\N	\N	0	0	draw	yes
145	1383423	2025-07-08	World	UEFA Champions League	Saburtalo	Malmo FF	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 18:57:34.211397	\N	\N	0	1	a-win	yes
146	1383424	2025-07-08	World	UEFA Champions League	FC Noah	Buducnost Podgorica	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 18:57:34.512694	\N	\N	0	0	draw	yes
147	1383425	2025-07-08	World	UEFA Champions League	FC Levadia Tallinn	Rīgas FS	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 18:57:34.753116	\N	\N	0	0	draw	yes
148	1383426	2025-07-08	World	UEFA Champions League	Olimpija Ljubljana	Kairat Almaty	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 18:57:34.918073	\N	\N	0	0	draw	yes
149	1383428	2025-07-08	World	UEFA Champions League	The New Saints	Shkendija	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 18:57:35.134448	\N	\N	0	0	draw	yes
150	1383429	2025-07-08	World	UEFA Champions League	Vikingur Gota	Lincoln Red Imps FC	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 18:57:35.394638	\N	\N	2	3	a-win	yes
151	1383427	2025-07-08	World	UEFA Champions League	Drita	FC Differdange 03	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 18:57:35.557365	\N	\N	0	0	draw	yes
152	1383431	2025-07-08	World	UEFA Champions League	Egnatia Rrogozhinë	Breidablik	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 18:57:35.720904	\N	\N	0	0	draw	yes
153	1383430	2025-07-08	World	UEFA Champions League	Virtus	Zrinjski	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 18:57:35.920408	\N	\N	0	1	a-win	yes
154	1383432	2025-07-09	World	UEFA Champions League	FK Zalgiris Vilnius	Hamrun Spartans	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 18:57:36.12831	\N	\N	0	0	draw	yes
155	1383434	2025-07-09	World	UEFA Champions League	FCSB	Inter Club d'Escaldes	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 18:57:36.291506	\N	\N	2	0	h-win	yes
156	1383433	2025-07-09	World	UEFA Champions League	Ludogorets	Dinamo Minsk	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 18:57:36.492089	\N	\N	0	0	draw	yes
157	1383435	2025-07-09	World	UEFA Champions League	Shelbourne	Linfield	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 18:57:36.734134	\N	\N	0	0	draw	yes
158	1383436	2025-07-15	World	UEFA Champions League	Kairat Almaty	Olimpija Ljubljana	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 18:57:36.999974	\N	\N	2	0	h-win	yes
159	1383437	2025-07-15	World	UEFA Champions League	Lincoln Red Imps FC	Vikingur Gota	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 18:57:37.315281	\N	\N	0	0	draw	yes
160	1383440	2025-07-15	World	UEFA Champions League	Malmo FF	Saburtalo	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 18:57:37.555464	\N	\N	0	0	draw	yes
161	1383438	2025-07-15	World	UEFA Champions League	Milsami Orhei	KuPS	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 18:57:37.815366	\N	\N	0	0	draw	yes
162	1383441	2025-07-15	World	UEFA Champions League	Rīgas FS	FC Levadia Tallinn	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 18:57:38.107738	\N	\N	0	0	draw	yes
163	1383439	2025-07-15	World	UEFA Champions League	Hamrun Spartans	FK Zalgiris Vilnius	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 18:57:38.354176	\N	\N	2	0	h-win	yes
164	1383443	2025-07-15	World	UEFA Champions League	Shkendija	The New Saints	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 18:57:38.644031	\N	\N	1	1	draw	yes
165	1383442	2025-07-15	World	UEFA Champions League	FC Differdange 03	Drita	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 18:57:38.937443	\N	\N	1	2	a-win	yes
166	1383444	2025-07-15	World	UEFA Champions League	Inter Club d'Escaldes	FCSB	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 18:57:39.200797	\N	\N	0	0	draw	yes
167	1383446	2025-07-15	World	UEFA Champions League	Breidablik	Egnatia Rrogozhinë	h-win	5	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 18:57:39.550124	\N	\N	4	0	h-win	yes
168	1383447	2025-07-15	World	UEFA Champions League	Buducnost Podgorica	FC Noah	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 18:57:39.890127	\N	\N	0	2	a-win	yes
169	1383445	2025-07-15	World	UEFA Champions League	Zrinjski	Virtus	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 18:57:40.129235	\N	\N	1	0	h-win	yes
170	1383449	2025-07-16	World	UEFA Champions League	Dinamo Minsk	Ludogorets	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 18:57:40.397343	\N	\N	0	1	a-win	yes
171	1383448	2025-07-16	World	UEFA Champions League	Linfield	Shelbourne	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 18:57:40.652967	\N	\N	1	1	draw	yes
172	1405443	2025-07-22	World	UEFA Champions League	KuPS	Kairat Almaty	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 18:57:40.83505	\N	\N	0	0	draw	yes
173	1405445	2025-07-22	World	UEFA Champions League	Lincoln Red Imps FC	FK Crvena Zvezda	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 18:57:41.011502	\N	\N	0	1	a-win	yes
174	1405446	2025-07-22	World	UEFA Champions League	FC Noah	Ferencvarosi TC	a-win	1	2	10	3	10	5	2	5	1	0	2	0	0	1	56.00	44.00	11	9	\N	\N	\N	\N	\N	2025-12-01 18:57:41.187733	\N	\N	1	1	draw	yes
175	1405448	2025-07-22	World	UEFA Champions League	FC Copenhagen	Drita	h-win	2	0	16	5	8	1	6	3	1	1	1	3	0	0	65.00	35.00	9	10	\N	\N	\N	\N	\N	2025-12-01 18:57:41.400023	\N	\N	0	0	draw	yes
176	1383450	2025-07-22	World	UEFA Champions League	Plzen	Servette FC	a-win	0	1	25	9	6	2	9	3	2	3	0	0	0	0	62.00	38.00	5	10	\N	\N	\N	\N	\N	2025-12-01 18:57:41.595191	\N	\N	0	1	a-win	yes
177	1383451	2025-07-22	World	UEFA Champions League	Pafos	Maccabi Tel Aviv	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 18:57:41.808595	\N	\N	0	0	draw	yes
178	1405447	2025-07-22	World	UEFA Champions League	Rīgas FS	Malmo FF	a-win	1	4	\N	\N	\N	\N	\N	\N	\N	\N	0	0	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 18:57:42.008105	\N	\N	1	2	a-win	yes
179	1405449	2025-07-22	World	UEFA Champions League	Hamrun Spartans	Dynamo Kyiv	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 18:57:42.232649	\N	\N	0	1	a-win	yes
180	1405450	2025-07-22	World	UEFA Champions League	Shkendija	FCSB	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 18:57:42.459944	\N	\N	0	0	draw	yes
181	1405451	2025-07-22	World	UEFA Champions League	Slovan Bratislava	Zrinjski	h-win	4	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 18:57:42.668645	\N	\N	2	0	h-win	yes
182	1405452	2025-07-22	World	UEFA Champions League	Lech Poznan	Breidablik	h-win	7	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 18:57:42.911226	\N	\N	5	1	h-win	yes
183	1383452	2025-07-22	World	UEFA Champions League	Rangers	Panathinaikos	h-win	2	0	16	5	14	4	3	6	1	0	2	2	0	1	75.00	25.00	10	12	\N	\N	\N	\N	\N	2025-12-01 18:57:43.131727	\N	\N	0	0	draw	yes
184	1405453	2025-07-22	World	UEFA Champions League	HNK Rijeka	Ludogorets	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 18:57:43.371409	\N	\N	0	0	draw	yes
185	1383453	2025-07-23	World	UEFA Champions League	Brann	Red Bull Salzburg	a-win	1	4	8	2	22	10	1	7	1	5	4	1	0	0	47.00	53.00	10	18	\N	\N	\N	\N	\N	2025-12-01 18:57:43.656728	\N	\N	1	0	h-win	yes
186	1405444	2025-07-23	World	UEFA Champions League	Shelbourne	Qarabag	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 18:57:43.924244	\N	\N	0	1	a-win	yes
187	1405454	2025-07-29	World	UEFA Champions League	Kairat Almaty	KuPS	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 18:57:44.204705	\N	\N	3	0	h-win	yes
188	1405457	2025-07-29	World	UEFA Champions League	Dynamo Kyiv	Hamrun Spartans	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 18:57:44.501522	\N	\N	2	0	h-win	yes
189	1405456	2025-07-29	World	UEFA Champions League	Drita	FC Copenhagen	a-win	0	1	9	2	9	4	3	5	0	2	0	3	1	0	36.00	64.00	13	19	\N	\N	\N	\N	\N	2025-12-01 18:57:44.723216	\N	\N	0	1	a-win	yes
190	1405458	2025-07-29	World	UEFA Champions League	Zrinjski	Slovan Bratislava	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 18:57:44.976905	\N	\N	0	0	draw	yes
191	1405459	2025-07-29	World	UEFA Champions League	FK Crvena Zvezda	Lincoln Red Imps FC	h-win	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 18:57:45.28268	\N	\N	4	0	h-win	yes
192	1405460	2025-07-30	World	UEFA Champions League	Qarabag	Shelbourne	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 18:57:45.533001	\N	\N	1	0	h-win	yes
193	1405461	2025-07-30	World	UEFA Champions League	Malmo FF	Rīgas FS	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 18:57:45.810431	\N	\N	1	0	h-win	yes
194	1405462	2025-07-30	World	UEFA Champions League	FCSB	Shkendija	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 18:57:46.073266	\N	\N	1	1	draw	yes
195	1405455	2025-07-30	World	UEFA Champions League	Ludogorets	HNK Rijeka	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 18:57:46.287884	\N	\N	1	0	h-win	yes
196	1383454	2025-07-30	World	UEFA Champions League	Maccabi Tel Aviv	Pafos	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 18:57:46.455141	\N	\N	0	1	a-win	yes
197	1383455	2025-07-30	World	UEFA Champions League	Panathinaikos	Rangers	draw	1	1	20	6	10	3	9	5	2	1	1	2	0	0	44.00	56.00	11	13	\N	\N	\N	\N	\N	2025-12-01 18:57:46.623329	\N	\N	0	0	draw	yes
198	1405463	2025-07-30	World	UEFA Champions League	Ferencvarosi TC	FC Noah	h-win	4	3	15	6	10	7	3	1	5	1	2	4	0	0	48.00	52.00	15	14	\N	\N	\N	\N	\N	2025-12-01 18:57:46.782948	\N	\N	2	2	draw	yes
199	1405464	2025-07-30	World	UEFA Champions League	Breidablik	Lech Poznan	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 18:57:46.945773	\N	\N	0	1	a-win	yes
200	1383456	2025-07-30	World	UEFA Champions League	Red Bull Salzburg	Brann	draw	1	1	11	4	10	5	2	2	2	3	5	6	0	0	37.00	63.00	19	11	\N	\N	\N	\N	\N	2025-12-01 18:57:47.139223	\N	\N	1	1	draw	yes
201	1383457	2025-07-30	World	UEFA Champions League	Servette FC	Plzen	a-win	1	3	17	5	14	8	8	4	1	1	4	1	1	1	59.00	41.00	11	11	\N	\N	\N	\N	\N	2025-12-01 18:57:47.356917	\N	\N	1	2	a-win	yes
202	1421137	2025-08-05	World	UEFA Champions League	Malmo FF	FC Copenhagen	draw	0	0	4	0	10	1	0	7	1	1	1	2	0	0	51.00	49.00	7	16	\N	\N	\N	\N	\N	2025-12-01 18:57:47.591312	\N	\N	0	0	draw	yes
203	1421138	2025-08-05	World	UEFA Champions League	Dynamo Kyiv	Pafos	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 18:57:47.777084	\N	\N	0	0	draw	yes
204	1421139	2025-08-05	World	UEFA Champions League	Shkendija	Qarabag	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 18:57:47.97114	\N	\N	0	1	a-win	yes
205	1421140	2025-08-05	World	UEFA Champions League	Rangers	Plzen	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 18:57:48.162768	\N	\N	2	0	h-win	yes
206	1419568	2025-08-06	World	UEFA Champions League	Kairat Almaty	Slovan Bratislava	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 18:57:48.344954	\N	\N	0	0	draw	yes
207	1421141	2025-08-06	World	UEFA Champions League	Red Bull Salzburg	Club Brugge KV	a-win	0	1	20	5	12	5	6	6	1	1	1	1	0	0	46.00	54.00	6	3	\N	\N	\N	\N	\N	2025-12-01 18:57:48.525078	\N	\N	0	0	draw	yes
208	1421142	2025-08-06	World	UEFA Champions League	Ludogorets	Ferencvarosi TC	draw	0	0	10	0	17	2	2	9	1	3	1	3	0	0	41.00	59.00	12	14	\N	\N	\N	\N	\N	2025-12-01 18:57:48.705264	\N	\N	0	0	draw	yes
209	1421143	2025-08-06	World	UEFA Champions League	Lech Poznan	FK Crvena Zvezda	a-win	1	3	11	4	12	6	4	4	1	3	1	1	0	0	59.00	41.00	13	11	\N	\N	\N	\N	\N	2025-12-01 18:57:48.898842	\N	\N	1	1	draw	yes
210	1414143	2025-08-06	World	UEFA Champions League	Nice	Benfica	a-win	0	2	12	2	14	6	4	5	1	3	3	1	0	0	47.00	53.00	9	14	\N	\N	\N	\N	\N	2025-12-01 18:57:49.120818	\N	\N	0	0	draw	yes
211	1414142	2025-08-06	World	UEFA Champions League	Feyenoord	Fenerbahçe	h-win	2	1	13	3	8	2	3	5	0	4	2	0	0	0	44.00	56.00	16	15	\N	\N	\N	\N	\N	2025-12-01 18:57:49.372297	\N	\N	1	0	h-win	yes
212	1421144	2025-08-12	World	UEFA Champions League	Qarabag	Shkendija	h-win	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 18:57:49.645058	\N	\N	4	1	h-win	yes
213	1421148	2025-08-12	World	UEFA Champions League	FC Copenhagen	Malmo FF	h-win	5	0	12	8	7	3	2	1	3	1	0	2	0	0	53.00	47.00	15	6	\N	\N	\N	\N	\N	2025-12-01 18:57:49.88735	\N	\N	2	0	h-win	yes
214	1421146	2025-08-12	World	UEFA Champions League	Plzen	Rangers	h-win	2	1	27	10	9	2	6	3	2	0	1	2	0	0	41.00	59.00	15	11	\N	\N	\N	\N	\N	2025-12-01 18:57:50.189007	\N	\N	1	0	h-win	yes
215	1414144	2025-08-12	World	UEFA Champions League	Fenerbahçe	Feyenoord	h-win	5	2	14	8	16	8	5	7	1	0	2	2	0	0	47.00	53.00	18	14	\N	\N	\N	\N	\N	2025-12-01 18:57:50.510385	\N	\N	2	1	h-win	yes
216	1421145	2025-08-12	World	UEFA Champions League	Pafos	Dynamo Kyiv	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 18:57:50.833073	\N	\N	1	0	h-win	yes
217	1421147	2025-08-12	World	UEFA Champions League	Club Brugge KV	Red Bull Salzburg	h-win	3	2	23	9	12	3	8	3	1	1	1	0	0	0	55.00	45.00	7	4	\N	\N	\N	\N	\N	2025-12-01 18:57:51.130218	\N	\N	0	2	a-win	yes
218	1421149	2025-08-12	World	UEFA Champions League	Ferencvarosi TC	Ludogorets	h-win	3	0	15	6	11	4	5	4	0	1	3	4	0	0	41.00	59.00	15	14	\N	\N	\N	\N	\N	2025-12-01 18:57:51.361409	\N	\N	1	0	h-win	yes
219	1419569	2025-08-12	World	UEFA Champions League	Slovan Bratislava	Kairat Almaty	h-win	1	0	16	2	14	6	6	5	1	3	7	4	0	0	55.00	45.00	29	23	\N	\N	\N	\N	\N	2025-12-01 18:57:51.577031	\N	\N	1	0	h-win	yes
220	1414145	2025-08-12	World	UEFA Champions League	Benfica	Nice	h-win	2	0	21	5	9	0	6	6	2	2	1	2	0	0	58.00	42.00	9	13	\N	\N	\N	\N	\N	2025-12-01 18:57:51.807494	\N	\N	2	0	h-win	yes
221	1421150	2025-08-12	World	UEFA Champions League	FK Crvena Zvezda	Lech Poznan	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 18:57:52.054841	\N	\N	1	0	h-win	yes
222	1435547	2025-08-19	World	UEFA Champions League	Rangers	Club Brugge KV	a-win	1	3	15	1	10	7	9	9	0	2	3	1	0	0	53.00	47.00	11	9	\N	\N	\N	\N	\N	2025-12-01 18:57:52.240611	\N	\N	0	3	a-win	yes
223	1435546	2025-08-19	World	UEFA Champions League	FK Crvena Zvezda	Pafos	a-win	1	2	25	6	14	3	13	4	0	0	1	1	0	0	57.00	43.00	9	17	\N	\N	\N	\N	\N	2025-12-01 18:57:52.575328	\N	\N	0	1	a-win	yes
224	1435545	2025-08-19	World	UEFA Champions League	Ferencvarosi TC	Qarabag	a-win	1	3	12	4	11	4	4	3	0	2	2	1	0	0	44.00	56.00	20	8	\N	\N	\N	\N	\N	2025-12-01 18:57:52.805004	\N	\N	1	0	h-win	yes
225	1435549	2025-08-20	World	UEFA Champions League	Celtic	Kairat Almaty	draw	0	0	11	3	8	0	15	3	0	3	2	3	0	0	75.00	25.00	12	9	\N	\N	\N	\N	\N	2025-12-01 18:57:52.995385	\N	\N	0	0	draw	yes
226	1424397	2025-08-20	World	UEFA Champions League	Bodo/Glimt	Sturm Graz	h-win	5	0	17	6	8	1	5	1	2	0	1	2	0	0	58.00	42.00	12	12	\N	\N	\N	\N	\N	2025-12-01 18:57:53.228796	\N	\N	3	0	h-win	yes
227	1435548	2025-08-20	World	UEFA Champions League	FC Basel 1893	FC Copenhagen	draw	1	1	11	6	11	4	2	3	0	2	5	3	1	0	46.00	54.00	11	12	\N	\N	\N	\N	\N	2025-12-01 18:57:53.458221	\N	\N	1	1	draw	yes
228	1435550	2025-08-20	World	UEFA Champions League	Fenerbahçe	Benfica	draw	0	0	13	6	9	3	4	4	2	0	3	5	0	1	54.00	46.00	16	18	\N	\N	\N	\N	\N	2025-12-01 18:57:53.703653	\N	\N	0	0	draw	yes
229	1435551	2025-08-26	World	UEFA Champions League	Kairat Almaty	Celtic	draw	0	0	12	4	11	5	5	7	3	0	0	1	0	0	33.00	67.00	12	19	\N	\N	\N	\N	\N	2025-12-01 18:57:53.909199	\N	\N	0	0	draw	yes
230	1424398	2025-08-26	World	UEFA Champions League	Sturm Graz	Bodo/Glimt	h-win	2	1	18	8	10	5	3	8	3	1	2	1	0	0	51.00	49.00	12	13	\N	\N	\N	\N	\N	2025-12-01 18:57:54.14829	\N	\N	1	1	draw	yes
231	1435552	2025-08-26	World	UEFA Champions League	Pafos	FK Crvena Zvezda	draw	1	1	11	5	12	3	3	3	1	3	3	3	0	0	50.00	50.00	17	17	\N	\N	\N	\N	\N	2025-12-01 18:57:54.37652	\N	\N	0	0	draw	yes
232	1435553	2025-08-27	World	UEFA Champions League	Qarabag	Ferencvarosi TC	a-win	2	3	10	2	17	6	1	2	3	1	3	3	0	0	41.00	59.00	14	21	\N	\N	\N	\N	\N	2025-12-01 18:57:54.596113	\N	\N	2	1	h-win	yes
233	1435556	2025-08-27	World	UEFA Champions League	Benfica	Fenerbahçe	h-win	1	0	15	3	6	0	4	1	4	4	2	4	0	1	53.00	47.00	11	20	\N	\N	\N	\N	\N	2025-12-01 18:57:54.777421	\N	\N	1	0	h-win	yes
234	1435554	2025-08-27	World	UEFA Champions League	FC Copenhagen	FC Basel 1893	h-win	2	0	11	7	20	5	3	6	1	3	1	0	0	0	43.00	57.00	25	15	\N	\N	\N	\N	\N	2025-12-01 18:57:55.00305	\N	\N	0	0	draw	yes
235	1435555	2025-08-27	World	UEFA Champions League	Club Brugge KV	Rangers	h-win	6	0	32	16	3	1	10	1	0	0	1	1	0	1	72.00	28.00	4	6	\N	\N	\N	\N	\N	2025-12-01 18:57:55.278208	\N	\N	5	0	h-win	yes
236	1451020	2025-09-16	World	UEFA Champions League	PSV Eindhoven	Union St. Gilloise	a-win	1	3	10	3	18	8	7	7	0	8	0	0	0	0	63.00	37.00	9	9	\N	\N	\N	\N	\N	2025-12-01 18:57:55.583004	2.52	3.34	0	2	a-win	yes
991	1421942	2025-08-25	Poland	I Liga	Tychy 71	Stal Mielec	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:47.418396	\N	\N	0	1	a-win	yes
237	1451021	2025-09-16	World	UEFA Champions League	Athletic Club	Arsenal	a-win	0	2	11	2	11	6	2	2	0	2	1	3	0	0	38.00	62.00	18	15	\N	\N	\N	\N	\N	2025-12-01 18:57:55.918787	0.35	1.28	0	0	draw	yes
238	1451023	2025-09-16	World	UEFA Champions League	Tottenham	Villarreal	h-win	1	0	9	1	10	0	3	3	1	1	4	3	0	0	58.00	42.00	14	13	\N	\N	\N	\N	\N	2025-12-01 18:57:56.216814	0.54	0.48	1	0	h-win	yes
239	1451025	2025-09-16	World	UEFA Champions League	Benfica	Qarabag	a-win	2	3	14	3	10	5	8	3	1	1	0	0	0	0	53.00	47.00	11	6	\N	\N	\N	\N	\N	2025-12-01 18:57:56.477316	1.38	1.52	2	1	h-win	yes
240	1451022	2025-09-16	World	UEFA Champions League	Juventus	Borussia Dortmund	draw	4	4	19	7	10	5	4	2	4	0	0	1	0	0	52.00	48.00	13	8	\N	\N	\N	\N	\N	2025-12-01 18:57:56.710535	1.92	1.71	0	0	draw	yes
241	1451024	2025-09-16	World	UEFA Champions League	Real Madrid	Marseille	h-win	2	1	28	15	15	5	9	4	1	3	3	2	1	0	43.00	57.00	9	14	\N	\N	\N	\N	\N	2025-12-01 18:57:56.866891	3.65	0.73	1	1	draw	yes
242	1451026	2025-09-17	World	UEFA Champions League	Olympiakos Piraeus	Pafos	draw	0	0	18	3	6	1	9	0	2	1	3	3	0	1	69.00	31.00	15	14	\N	\N	\N	\N	\N	2025-12-01 18:57:57.027084	1.52	0.30	0	0	draw	yes
243	1451027	2025-09-17	World	UEFA Champions League	Slavia Praha	Bodo/Glimt	draw	2	2	26	11	11	10	8	4	5	0	2	3	0	0	46.00	54.00	13	11	\N	\N	\N	\N	\N	2025-12-01 18:57:57.189755	3.98	2.52	1	0	h-win	yes
244	1451030	2025-09-17	World	UEFA Champions League	Liverpool	Atletico Madrid	h-win	3	2	20	6	10	4	7	6	1	2	1	2	0	0	56.00	44.00	7	9	\N	\N	\N	\N	\N	2025-12-01 18:57:57.343875	2.60	0.61	2	1	h-win	yes
245	1451029	2025-09-17	World	UEFA Champions League	Paris Saint Germain	Atalanta	h-win	4	0	22	13	7	2	6	1	3	2	0	1	0	0	67.00	33.00	5	11	\N	\N	\N	\N	\N	2025-12-01 18:57:57.516096	3.48	0.55	2	0	h-win	yes
246	1451031	2025-09-17	World	UEFA Champions League	Bayern München	Chelsea	h-win	3	1	16	5	9	3	6	2	4	3	3	1	0	0	56.00	44.00	12	7	\N	\N	\N	\N	\N	2025-12-01 18:57:57.676986	2.07	0.73	2	1	h-win	yes
247	1451028	2025-09-17	World	UEFA Champions League	Ajax	Inter	a-win	0	2	7	2	14	4	3	5	2	1	1	2	0	0	56.00	44.00	15	17	\N	\N	\N	\N	\N	2025-12-01 18:57:57.841759	1.26	1.24	0	1	a-win	yes
248	1451033	2025-09-18	World	UEFA Champions League	FC Copenhagen	Bayer Leverkusen	draw	2	2	12	7	15	4	4	5	0	0	3	2	0	0	36.00	64.00	14	13	\N	\N	\N	\N	\N	2025-12-01 18:57:58.002354	1.89	1.21	1	0	h-win	yes
249	1451032	2025-09-18	World	UEFA Champions League	Club Brugge KV	Monaco	h-win	4	1	26	10	13	5	4	5	0	1	2	2	0	0	49.00	51.00	11	9	\N	\N	\N	\N	\N	2025-12-01 18:57:58.189944	3.15	1.45	3	0	h-win	yes
250	1451036	2025-09-18	World	UEFA Champions League	Newcastle	Barcelona	a-win	1	2	10	6	19	5	6	4	3	0	2	4	0	0	36.00	64.00	11	12	\N	\N	\N	\N	\N	2025-12-01 18:57:58.358987	1.46	1.31	0	0	draw	yes
251	1451037	2025-09-18	World	UEFA Champions League	Manchester City	Napoli	h-win	2	0	23	8	1	1	9	2	1	1	0	1	0	1	74.00	26.00	3	4	\N	\N	\N	\N	\N	2025-12-01 18:57:58.595269	2.18	0.17	0	0	draw	yes
252	1451034	2025-09-18	World	UEFA Champions League	Eintracht Frankfurt	Galatasaray	h-win	5	1	11	5	14	5	4	3	1	0	1	0	0	0	38.00	62.00	10	13	\N	\N	\N	\N	\N	2025-12-01 18:57:58.761703	1.21	1.09	3	1	h-win	yes
253	1451035	2025-09-18	World	UEFA Champions League	Sporting CP	Kairat Almaty	h-win	4	1	21	8	9	4	8	3	0	1	4	2	0	0	64.00	36.00	14	11	\N	\N	\N	\N	\N	2025-12-01 18:57:58.915358	4.25	0.70	1	0	h-win	yes
254	1451039	2025-09-30	World	UEFA Champions League	Atalanta	Club Brugge KV	h-win	2	1	20	3	7	2	7	1	1	0	2	0	0	0	48.00	52.00	8	10	\N	\N	\N	\N	\N	2025-12-01 18:57:59.08463	2.96	0.86	0	1	a-win	yes
255	1451038	2025-09-30	World	UEFA Champions League	Kairat Almaty	Real Madrid	a-win	0	5	11	4	20	12	3	6	1	0	2	0	0	0	33.00	67.00	6	9	\N	\N	\N	\N	\N	2025-12-01 18:57:59.277726	0.43	3.54	0	1	a-win	yes
256	1451042	2025-09-30	World	UEFA Champions League	Chelsea	Benfica	h-win	1	0	8	3	9	3	3	5	1	2	4	5	1	0	56.00	44.00	13	14	\N	\N	\N	\N	\N	2025-12-01 18:57:59.486869	0.93	0.85	1	0	h-win	yes
257	1451041	2025-09-30	World	UEFA Champions League	Marseille	Ajax	h-win	4	0	9	6	13	2	0	7	0	2	2	3	0	0	48.00	52.00	18	12	\N	\N	\N	\N	\N	2025-12-01 18:57:59.783695	1.13	0.80	3	0	h-win	yes
258	1451044	2025-09-30	World	UEFA Champions League	Bodo/Glimt	Tottenham	draw	2	2	18	4	8	3	4	5	3	2	2	2	0	0	52.00	48.00	11	7	\N	\N	\N	\N	\N	2025-12-01 18:58:00.042994	2.52	1.46	0	0	draw	yes
259	1451043	2025-09-30	World	UEFA Champions League	Inter	Slavia Praha	h-win	3	0	21	6	3	1	5	0	0	0	2	1	0	0	57.00	43.00	13	17	\N	\N	\N	\N	\N	2025-12-01 18:58:00.290947	3.99	0.11	2	0	h-win	yes
260	1451040	2025-09-30	World	UEFA Champions League	Atletico Madrid	Eintracht Frankfurt	h-win	5	1	18	12	6	2	5	2	2	0	1	1	0	0	51.00	49.00	11	6	\N	\N	\N	\N	\N	2025-12-01 18:58:00.516489	4.44	0.59	3	0	h-win	yes
261	1451046	2025-09-30	World	UEFA Champions League	Galatasaray	Liverpool	h-win	1	0	9	4	16	4	3	7	2	1	5	3	0	0	33.00	67.00	12	14	\N	\N	\N	\N	\N	2025-12-01 18:58:00.726952	1.34	1.81	1	0	h-win	yes
262	1451045	2025-09-30	World	UEFA Champions League	Pafos	Bayern München	a-win	1	5	6	2	26	15	2	6	0	0	1	0	0	0	33.00	67.00	11	9	\N	\N	\N	\N	\N	2025-12-01 18:58:00.884898	0.39	4.54	1	4	a-win	yes
263	1451047	2025-10-01	World	UEFA Champions League	Qarabag	FC Copenhagen	h-win	2	0	10	6	12	4	4	7	2	4	3	1	0	0	49.00	51.00	10	20	\N	\N	\N	\N	\N	2025-12-01 18:58:01.047227	1.91	0.98	1	0	h-win	yes
264	1451048	2025-10-01	World	UEFA Champions League	Union St. Gilloise	Newcastle	a-win	0	4	17	6	13	6	7	5	1	0	4	1	0	0	43.00	57.00	15	8	\N	\N	\N	\N	\N	2025-12-01 18:58:01.286902	0.88	2.76	0	2	a-win	yes
265	1451052	2025-10-01	World	UEFA Champions League	Arsenal	Olympiakos Piraeus	h-win	2	0	16	5	10	3	3	5	2	4	3	1	0	0	61.00	39.00	14	17	\N	\N	\N	\N	\N	2025-12-01 18:58:01.551381	2.90	0.50	1	0	h-win	yes
266	1451051	2025-10-01	World	UEFA Champions League	Monaco	Manchester City	draw	2	2	8	3	18	6	7	3	0	2	1	5	0	0	29.00	71.00	9	13	\N	\N	\N	\N	\N	2025-12-01 18:58:01.778296	1.45	1.54	1	2	a-win	yes
267	1451049	2025-10-01	World	UEFA Champions League	Borussia Dortmund	Athletic Club	h-win	4	1	13	8	6	3	4	0	3	3	1	2	0	0	52.00	48.00	14	15	\N	\N	\N	\N	\N	2025-12-01 18:58:02.02631	1.18	0.95	1	0	h-win	yes
268	1451054	2025-10-01	World	UEFA Champions League	Bayer Leverkusen	PSV Eindhoven	draw	1	1	14	4	6	1	7	4	2	2	0	2	0	0	46.00	54.00	8	11	\N	\N	\N	\N	\N	2025-12-01 18:58:02.277275	1.74	0.49	0	0	draw	yes
269	1451053	2025-10-01	World	UEFA Champions League	Napoli	Sporting CP	h-win	2	1	12	3	8	4	7	2	1	0	0	0	0	0	51.00	49.00	16	9	\N	\N	\N	\N	\N	2025-12-01 18:58:02.54315	0.88	1.35	1	0	h-win	yes
270	1451050	2025-10-01	World	UEFA Champions League	Barcelona	Paris Saint Germain	a-win	1	2	12	3	16	7	4	9	0	2	4	2	0	0	47.00	53.00	12	14	\N	\N	\N	\N	\N	2025-12-01 18:58:02.778363	1.27	1.67	1	1	draw	yes
271	1451055	2025-10-01	World	UEFA Champions League	Villarreal	Juventus	draw	2	2	17	6	13	4	4	3	1	1	1	3	0	0	45.00	55.00	7	19	\N	\N	\N	\N	\N	2025-12-01 18:58:03.035763	1.72	1.60	1	0	h-win	yes
272	1451057	2025-10-21	World	UEFA Champions League	Barcelona	Olympiakos Piraeus	h-win	6	1	14	7	5	2	7	2	2	1	1	4	0	1	73.00	27.00	7	10	\N	\N	\N	\N	\N	2025-12-01 18:58:03.303699	2.48	1.00	2	0	h-win	yes
273	1451056	2025-10-21	World	UEFA Champions League	Kairat Almaty	Pafos	draw	0	0	22	2	9	6	6	4	1	3	3	1	0	1	69.00	31.00	11	9	\N	\N	\N	\N	\N	2025-12-01 18:58:03.501143	1.26	1.76	0	0	draw	yes
274	1451064	2025-10-21	World	UEFA Champions League	Newcastle	Benfica	h-win	3	0	19	10	7	2	12	8	2	1	1	1	0	0	52.00	48.00	16	7	\N	\N	\N	\N	\N	2025-12-01 18:58:03.667703	2.63	0.33	1	0	h-win	yes
275	1451061	2025-10-21	World	UEFA Champions League	Arsenal	Atletico Madrid	h-win	4	0	19	8	11	1	3	4	2	0	1	2	0	0	52.00	48.00	14	10	\N	\N	\N	\N	\N	2025-12-01 18:58:03.89284	2.19	0.67	0	0	draw	yes
276	1451060	2025-10-21	World	UEFA Champions League	Bayer Leverkusen	Paris Saint Germain	a-win	2	7	6	3	24	8	3	4	3	0	2	1	1	1	29.00	71.00	8	6	\N	\N	\N	\N	\N	2025-12-01 18:58:04.099828	2.50	2.86	1	4	a-win	yes
277	1451059	2025-10-21	World	UEFA Champions League	PSV Eindhoven	Napoli	h-win	6	2	19	8	10	2	4	8	2	1	4	1	0	1	59.00	41.00	11	9	\N	\N	\N	\N	\N	2025-12-01 18:58:04.310597	2.89	1.16	2	1	h-win	yes
278	1451062	2025-10-21	World	UEFA Champions League	FC Copenhagen	Borussia Dortmund	a-win	2	4	11	4	9	5	4	7	0	0	2	1	0	0	36.00	64.00	10	7	\N	\N	\N	\N	\N	2025-12-01 18:58:04.486777	0.82	1.64	1	1	draw	yes
279	1451063	2025-10-21	World	UEFA Champions League	Villarreal	Manchester City	a-win	0	2	11	2	10	6	1	3	0	0	4	2	0	0	34.00	66.00	17	15	\N	\N	\N	\N	\N	2025-12-01 18:58:04.66118	1.28	1.34	0	2	a-win	yes
280	1451058	2025-10-21	World	UEFA Champions League	Union St. Gilloise	Inter	a-win	0	4	15	6	21	7	3	4	4	0	1	1	0	0	30.00	70.00	15	6	\N	\N	\N	\N	\N	2025-12-01 18:58:04.834129	0.95	4.54	0	2	a-win	yes
281	1451066	2025-10-22	World	UEFA Champions League	Athletic Club	Qarabag	h-win	3	1	21	5	9	4	8	3	1	0	0	0	0	0	60.00	40.00	14	5	\N	\N	\N	\N	\N	2025-12-01 18:58:04.989471	3.47	0.52	1	1	draw	yes
282	1451065	2025-10-22	World	UEFA Champions League	Galatasaray	Bodo/Glimt	h-win	3	1	23	11	8	2	7	4	3	1	1	1	0	0	38.00	62.00	10	7	\N	\N	\N	\N	\N	2025-12-01 18:58:05.165137	4.09	1.41	2	0	h-win	yes
283	1451070	2025-10-22	World	UEFA Champions League	Chelsea	Ajax	h-win	5	1	22	10	2	1	11	0	3	1	2	1	0	1	66.00	34.00	15	6	\N	\N	\N	\N	\N	2025-12-01 18:58:05.335203	3.65	1.05	4	1	h-win	yes
284	1451067	2025-10-22	World	UEFA Champions League	Monaco	Tottenham	draw	0	0	23	8	11	2	5	4	1	1	0	1	0	0	56.00	44.00	25	0	\N	\N	\N	\N	\N	2025-12-01 18:58:05.515455	2.45	0.88	0	0	draw	yes
285	1451073	2025-10-22	World	UEFA Champions League	Bayern München	Club Brugge KV	h-win	4	0	26	13	5	2	9	1	1	0	1	0	0	0	63.00	37.00	14	3	\N	\N	\N	\N	\N	2025-12-01 18:58:05.703773	4.20	0.25	3	0	h-win	yes
286	1451069	2025-10-22	World	UEFA Champions League	Eintracht Frankfurt	Liverpool	a-win	1	5	4	1	18	14	2	10	1	3	2	0	0	0	35.00	65.00	4	5	\N	\N	\N	\N	\N	2025-12-01 18:58:05.97507	0.23	3.26	1	3	a-win	yes
287	1451072	2025-10-22	World	UEFA Champions League	Sporting CP	Marseille	h-win	2	1	14	7	10	3	3	1	2	0	2	4	0	1	53.00	47.00	11	16	\N	\N	\N	\N	\N	2025-12-01 18:58:06.229874	1.11	0.54	0	1	a-win	yes
288	1451071	2025-10-22	World	UEFA Champions League	Atalanta	Slavia Praha	draw	0	0	22	5	16	4	6	3	5	3	3	2	0	0	56.00	44.00	8	15	\N	\N	\N	\N	\N	2025-12-01 18:58:06.421302	2.59	0.73	0	0	draw	yes
289	1451068	2025-10-22	World	UEFA Champions League	Real Madrid	Juventus	h-win	1	0	28	10	13	4	13	7	1	2	1	0	0	0	66.00	34.00	10	18	\N	\N	\N	\N	\N	2025-12-01 18:58:06.63276	2.69	0.59	0	0	draw	yes
290	1451074	2025-11-04	World	UEFA Champions League	Napoli	Eintracht Frankfurt	draw	0	0	18	3	7	3	5	3	1	0	2	1	0	0	64.00	36.00	12	10	\N	\N	\N	20	28	2025-12-01 18:58:06.944107	1.85	0.36	0	0	draw	yes
291	1451075	2025-11-04	World	UEFA Champions League	Slavia Praha	Arsenal	a-win	0	3	9	1	14	8	4	7	5	0	3	4	0	0	43.00	57.00	31	0	\N	\N	\N	31	1	2025-12-01 18:58:07.083679	0.47	1.81	0	1	a-win	yes
292	1451077	2025-11-04	World	UEFA Champions League	Liverpool	Real Madrid	h-win	1	0	17	9	8	2	4	2	2	0	1	4	0	0	39.00	61.00	16	11	\N	\N	\N	13	5	2025-12-01 18:58:07.24476	2.51	0.45	0	0	draw	yes
293	1451076	2025-11-04	World	UEFA Champions League	Tottenham	FC Copenhagen	h-win	4	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16	29	2025-12-01 18:58:07.258563	\N	\N	1	0	h-win	yes
294	1451081	2025-11-04	World	UEFA Champions League	Paris Saint Germain	Bayern München	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	3	2025-12-01 18:58:07.271084	\N	\N	0	2	a-win	yes
295	1451080	2025-11-04	World	UEFA Champions League	Bodo/Glimt	Monaco	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	32	23	2025-12-01 18:58:07.285137	\N	\N	0	1	a-win	yes
296	1451082	2025-11-04	World	UEFA Champions League	Juventus	Sporting CP	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	22	8	2025-12-01 18:58:07.301796	\N	\N	1	1	draw	yes
297	1451079	2025-11-04	World	UEFA Champions League	Atletico Madrid	Union St. Gilloise	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	25	2025-12-01 18:58:07.318104	\N	\N	1	0	h-win	yes
298	1451078	2025-11-04	World	UEFA Champions League	Olympiakos Piraeus	PSV Eindhoven	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	33	15	2025-12-01 18:58:07.331912	\N	\N	1	0	h-win	yes
299	1451083	2025-11-05	World	UEFA Champions League	Qarabag	Chelsea	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	19	7	2025-12-01 18:58:07.347154	\N	\N	2	1	h-win	yes
300	1451084	2025-11-05	World	UEFA Champions League	Pafos	Villarreal	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	24	34	2025-12-01 18:58:07.362814	\N	\N	0	0	draw	yes
301	1451088	2025-11-05	World	UEFA Champions League	Newcastle	Athletic Club	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	11	27	2025-12-01 18:58:07.377829	\N	\N	1	0	h-win	yes
302	1451085	2025-11-05	World	UEFA Champions League	Manchester City	Borussia Dortmund	h-win	4	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	6	2025-12-01 18:58:07.393084	\N	\N	2	0	h-win	yes
303	1451091	2025-11-05	World	UEFA Champions League	Marseille	Atalanta	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	21	10	2025-12-01 18:58:07.406695	\N	\N	0	0	draw	yes
304	1451087	2025-11-05	World	UEFA Champions League	Ajax	Galatasaray	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	36	14	2025-12-01 18:58:07.422662	\N	\N	0	0	draw	yes
305	1451089	2025-11-05	World	UEFA Champions League	Benfica	Bayer Leverkusen	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	30	17	2025-12-01 18:58:07.437976	\N	\N	0	0	draw	yes
306	1451090	2025-11-05	World	UEFA Champions League	Inter	Kairat Almaty	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	35	2025-12-01 18:58:07.450325	\N	\N	1	0	h-win	yes
307	1451086	2025-11-05	World	UEFA Champions League	Club Brugge KV	Barcelona	draw	3	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	26	18	2025-12-01 18:58:07.46578	\N	\N	2	1	h-win	yes
308	1383540	2025-07-10	World	UEFA Europa League	Sabah FA	Celje	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	0	2	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 19:08:30.750885	\N	\N	2	1	h-win	yes
309	1383541	2025-07-10	World	UEFA Europa League	AEK Larnaca	FK Partizan	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	1	2	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 19:08:30.943409	\N	\N	0	0	draw	yes
310	1383543	2025-07-10	World	UEFA Europa League	Sheriff Tiraspol	Prishtina	h-win	4	0	\N	\N	\N	\N	\N	\N	\N	\N	0	2	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 19:08:31.112578	\N	\N	2	0	h-win	yes
311	1383542	2025-07-10	World	UEFA Europa League	Paks	CFR 1907 Cluj	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	2	1	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 19:08:31.294733	\N	\N	0	0	draw	yes
312	1383544	2025-07-10	World	UEFA Europa League	Levski Sofia	Hapoel Beer Sheva	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	3	5	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 19:08:31.466802	\N	\N	0	0	draw	yes
313	1383545	2025-07-10	World	UEFA Europa League	Shakhtar Donetsk	Ilves	h-win	6	0	\N	\N	\N	\N	\N	\N	\N	\N	0	0	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 19:08:31.61662	\N	\N	2	0	h-win	yes
314	1383546	2025-07-10	World	UEFA Europa League	Spartak Trnava	BK Hacken	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	5	2	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 19:08:31.777109	\N	\N	0	0	draw	yes
315	1383547	2025-07-10	World	UEFA Europa League	Legia Warszawa	Aktobe	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	0	1	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 19:08:31.958731	\N	\N	1	0	h-win	yes
316	1383549	2025-07-17	World	UEFA Europa League	Ilves	Shakhtar Donetsk	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	1	1	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 19:08:32.287682	\N	\N	0	0	draw	yes
317	1383548	2025-07-17	World	UEFA Europa League	Aktobe	Legia Warszawa	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	3	0	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 19:08:32.538808	\N	\N	0	0	draw	yes
318	1383551	2025-07-17	World	UEFA Europa League	BK Hacken	Spartak Trnava	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	3	2	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 19:08:32.703623	\N	\N	1	0	h-win	yes
319	1383550	2025-07-17	World	UEFA Europa League	CFR 1907 Cluj	Paks	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	2	1	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 19:08:32.84961	\N	\N	1	0	h-win	yes
320	1383553	2025-07-17	World	UEFA Europa League	Hapoel Beer Sheva	Levski Sofia	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	4	1	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 19:08:33.028614	\N	\N	0	0	draw	yes
321	1383552	2025-07-17	World	UEFA Europa League	Prishtina	Sheriff Tiraspol	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	1	2	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 19:08:33.209514	\N	\N	0	0	draw	yes
322	1383554	2025-07-17	World	UEFA Europa League	Celje	Sabah FA	draw	3	3	\N	\N	\N	\N	\N	\N	\N	\N	4	4	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 19:08:33.400726	\N	\N	1	1	draw	yes
323	1383555	2025-07-17	World	UEFA Europa League	FK Partizan	AEK Larnaca	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	3	2	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 19:08:33.615704	\N	\N	0	0	draw	yes
324	1410068	2025-07-24	World	UEFA Europa League	Sheriff Tiraspol	Utrecht	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	3	1	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 19:08:33.835816	\N	\N	1	1	draw	yes
325	1410069	2025-07-24	World	UEFA Europa League	Baník Ostrava	Legia Warszawa	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	1	2	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 19:08:34.074532	\N	\N	1	1	draw	yes
326	1383556	2025-07-24	World	UEFA Europa League	FC Midtjylland	Hibernian	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	1	4	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 19:08:34.27508	\N	\N	0	1	a-win	yes
327	1410070	2025-07-24	World	UEFA Europa League	Levski Sofia	SC Braga	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	2	3	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 19:08:34.498091	\N	\N	0	0	draw	yes
328	1410072	2025-07-24	World	UEFA Europa League	Beşiktaş	Shakhtar Donetsk	a-win	2	4	\N	\N	\N	\N	\N	\N	\N	\N	3	1	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 19:08:34.760926	\N	\N	1	2	a-win	yes
329	1410071	2025-07-24	World	UEFA Europa League	Anderlecht	BK Hacken	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	2	3	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 19:08:35.027052	\N	\N	1	0	h-win	yes
330	1410073	2025-07-24	World	UEFA Europa League	Celje	AEK Larnaca	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	3	3	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 19:08:35.313551	\N	\N	1	0	h-win	yes
331	1410074	2025-07-24	World	UEFA Europa League	FC Lugano	CFR 1907 Cluj	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	2	2	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 19:08:35.576054	\N	\N	0	0	draw	yes
332	1410076	2025-07-31	World	UEFA Europa League	AEK Larnaca	Celje	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	1	1	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 19:08:35.804476	\N	\N	1	0	h-win	yes
333	1410077	2025-07-31	World	UEFA Europa League	BK Hacken	Anderlecht	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	1	6	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 19:08:36.051476	\N	\N	1	0	h-win	yes
334	1410078	2025-07-31	World	UEFA Europa League	CFR 1907 Cluj	FC Lugano	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	4	4	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 19:08:36.299538	\N	\N	0	0	draw	yes
335	1410079	2025-07-31	World	UEFA Europa League	Utrecht	Sheriff Tiraspol	h-win	4	1	\N	\N	\N	\N	\N	\N	\N	\N	0	0	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 19:08:36.50569	\N	\N	1	0	h-win	yes
336	1410075	2025-07-31	World	UEFA Europa League	Shakhtar Donetsk	Beşiktaş	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	6	3	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 19:08:36.77758	\N	\N	2	0	h-win	yes
337	1410080	2025-07-31	World	UEFA Europa League	SC Braga	Levski Sofia	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	0	3	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 19:08:37.096554	\N	\N	0	0	draw	yes
338	1383557	2025-07-31	World	UEFA Europa League	Hibernian	FC Midtjylland	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	4	3	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 19:08:37.358709	\N	\N	0	0	draw	yes
339	1410081	2025-07-31	World	UEFA Europa League	Legia Warszawa	Baník Ostrava	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	3	0	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 19:08:37.659494	\N	\N	0	1	a-win	yes
340	1421215	2025-08-05	World	UEFA Europa League	Hamrun Spartans	Maccabi Tel Aviv	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	3	3	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 19:08:37.919798	\N	\N	0	0	draw	yes
341	1421213	2025-08-06	World	UEFA Europa League	Rīgas FS	KuPS	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	1	0	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 19:08:38.208354	\N	\N	0	2	a-win	yes
342	1421212	2025-08-06	World	UEFA Europa League	HNK Rijeka	Shelbourne	a-win	1	2	0	7	0	2	6	1	0	1	0	0	0	0	68.00	32.00	7	7	\N	\N	\N	\N	\N	2025-12-01 19:08:38.487668	\N	\N	0	0	draw	yes
343	1421219	2025-08-07	World	UEFA Europa League	Lincoln Red Imps FC	FC Noah	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	1	7	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 19:08:38.819753	\N	\N	1	1	draw	yes
344	1421210	2025-08-07	World	UEFA Europa League	Fredrikstad	FC Midtjylland	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	0	1	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 19:08:39.047512	\N	\N	0	2	a-win	yes
345	1421214	2025-08-07	World	UEFA Europa League	AEK Larnaca	Legia Warszawa	h-win	4	1	\N	\N	\N	\N	\N	\N	\N	\N	1	4	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 19:08:39.303673	\N	\N	1	1	draw	yes
346	1421209	2025-08-07	World	UEFA Europa League	CFR 1907 Cluj	SC Braga	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	2	0	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 19:08:39.607986	\N	\N	1	1	draw	yes
347	1421211	2025-08-07	World	UEFA Europa League	BK Hacken	Brann	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	1	3	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 19:08:39.927582	\N	\N	0	1	a-win	yes
348	1413127	2025-08-07	World	UEFA Europa League	PAOK	Wolfsberger AC	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	4	1	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 19:08:40.204672	\N	\N	0	0	draw	yes
349	1421220	2025-08-07	World	UEFA Europa League	Zrinjski	Breidablik	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	1	0	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 19:08:40.449822	\N	\N	0	1	a-win	yes
350	1421218	2025-08-07	World	UEFA Europa League	Panathinaikos	Shakhtar Donetsk	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	2	1	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 19:08:40.639045	\N	\N	0	0	draw	yes
351	1421217	2025-08-07	World	UEFA Europa League	FCSB	Drita	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	1	3	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 19:08:40.841985	\N	\N	0	1	a-win	yes
352	1421216	2025-08-07	World	UEFA Europa League	Servette FC	Utrecht	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	2	2	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 19:08:41.068696	\N	\N	1	0	h-win	yes
353	1421222	2025-08-12	World	UEFA Europa League	Shelbourne	HNK Rijeka	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	0	1	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 19:08:41.322048	\N	\N	0	1	a-win	yes
354	1421228	2025-08-14	World	UEFA Europa League	KuPS	Rīgas FS	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	3	3	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 19:08:41.5678	\N	\N	0	0	draw	yes
355	1423465	2025-08-14	World	UEFA Europa League	FC Midtjylland	Fredrikstad	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	1	1	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 19:08:41.773254	\N	\N	2	0	h-win	yes
356	1421225	2025-08-14	World	UEFA Europa League	Brann	BK Hacken	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	2	5	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 19:08:41.917238	\N	\N	0	1	a-win	yes
357	1413128	2025-08-14	World	UEFA Europa League	Wolfsberger AC	PAOK	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	5	2	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 19:08:42.142069	\N	\N	0	0	draw	yes
358	1421224	2025-08-14	World	UEFA Europa League	FC Noah	Lincoln Red Imps FC	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	2	3	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 19:08:42.349587	\N	\N	0	0	draw	yes
359	1421229	2025-08-14	World	UEFA Europa League	Breidablik	Zrinjski	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	4	1	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 19:08:42.613432	\N	\N	0	1	a-win	yes
360	1421230	2025-08-14	World	UEFA Europa League	Utrecht	Servette FC	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	4	4	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 19:08:42.862818	\N	\N	0	0	draw	yes
361	1421227	2025-08-14	World	UEFA Europa League	Shakhtar Donetsk	Panathinaikos	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	4	6	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 19:08:43.085808	\N	\N	0	0	draw	yes
362	1421226	2025-08-14	World	UEFA Europa League	Maccabi Tel Aviv	Hamrun Spartans	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	1	3	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 19:08:43.347668	\N	\N	2	1	h-win	yes
363	1421221	2025-08-14	World	UEFA Europa League	Drita	FCSB	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	2	2	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 19:08:43.614804	\N	\N	0	2	a-win	yes
364	1421223	2025-08-14	World	UEFA Europa League	SC Braga	CFR 1907 Cluj	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	0	1	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 19:08:43.911262	\N	\N	2	0	h-win	yes
365	1421231	2025-08-14	World	UEFA Europa League	Legia Warszawa	AEK Larnaca	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	4	6	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 19:08:44.251479	\N	\N	2	0	h-win	yes
992	1381588	2025-08-29	Poland	I Liga	Slask Wroclaw	Tychy 71	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:47.576474	\N	\N	0	0	draw	yes
366	1437226	2025-08-21	World	UEFA Europa League	FC Midtjylland	KuPS	h-win	4	0	13	9	4	2	4	5	0	1	1	2	0	0	48.00	52.00	11	10	\N	\N	\N	\N	\N	2025-12-01 19:08:44.528265	\N	\N	2	0	h-win	yes
367	1437228	2025-08-21	World	UEFA Europa League	Brann	AEK Larnaca	h-win	2	1	15	10	8	3	6	5	0	0	2	3	0	0	60.00	40.00	16	11	\N	\N	\N	\N	\N	2025-12-01 19:08:44.835539	\N	\N	1	1	draw	yes
368	1437227	2025-08-21	World	UEFA Europa League	Malmo FF	Sigma Olomouc	h-win	3	0	12	4	8	2	9	3	1	4	2	3	0	0	50.00	50.00	11	10	\N	\N	\N	\N	\N	2025-12-01 19:08:45.139947	\N	\N	2	0	h-win	yes
369	1437229	2025-08-21	World	UEFA Europa League	Zrinjski	Utrecht	a-win	0	2	12	3	12	7	6	2	1	0	5	3	1	0	52.00	48.00	10	9	\N	\N	\N	\N	\N	2025-12-01 19:08:45.519387	\N	\N	0	1	a-win	yes
370	1436776	2025-08-21	World	UEFA Europa League	Maccabi Tel Aviv	Dynamo Kyiv	h-win	3	1	21	11	11	3	6	5	2	2	1	4	0	1	63.00	37.00	12	11	\N	\N	\N	\N	\N	2025-12-01 19:08:45.852305	\N	\N	1	1	draw	yes
371	1436778	2025-08-21	World	UEFA Europa League	Shkendija	Ludogorets	h-win	2	1	14	4	14	4	4	2	4	2	2	1	0	0	\N	\N	8	17	\N	\N	\N	\N	\N	2025-12-01 19:08:46.167356	\N	\N	1	1	draw	yes
372	1436779	2025-08-21	World	UEFA Europa League	Panathinaikos	Samsunspor	h-win	2	1	10	5	7	3	8	4	0	4	2	2	0	0	49.00	51.00	10	9	\N	\N	\N	\N	\N	2025-12-01 19:08:46.468177	\N	\N	0	0	draw	yes
373	1436777	2025-08-21	World	UEFA Europa League	Slovan Bratislava	BSC Young Boys	a-win	0	1	6	0	4	2	9	5	3	2	3	2	0	0	48.00	52.00	14	23	\N	\N	\N	\N	\N	2025-12-01 19:08:46.769857	\N	\N	0	1	a-win	yes
374	1436775	2025-08-21	World	UEFA Europa League	Lech Poznan	Genk	a-win	1	5	14	7	19	11	3	5	0	1	1	3	0	0	40.00	60.00	5	5	\N	\N	\N	\N	\N	2025-12-01 19:08:47.004029	\N	\N	1	4	a-win	yes
375	1436774	2025-08-21	World	UEFA Europa League	Aberdeen	FCSB	draw	2	2	29	9	11	6	4	3	1	0	4	2	0	1	49.00	51.00	14	9	\N	\N	\N	\N	\N	2025-12-01 19:08:47.249625	\N	\N	0	1	a-win	yes
376	1436773	2025-08-21	World	UEFA Europa League	HNK Rijeka	PAOK	h-win	1	0	15	7	11	3	4	2	3	1	2	5	0	0	60.00	40.00	13	16	\N	\N	\N	\N	\N	2025-12-01 19:08:47.505643	\N	\N	1	0	h-win	yes
377	1437230	2025-08-21	World	UEFA Europa League	Lincoln Red Imps FC	SC Braga	a-win	0	4	2	1	11	4	0	4	3	2	2	1	0	0	\N	\N	12	12	\N	\N	\N	\N	\N	2025-12-01 19:08:47.756231	\N	\N	0	2	a-win	yes
378	1437231	2025-08-27	World	UEFA Europa League	AEK Larnaca	Brann	a-win	0	4	9	0	11	6	4	3	4	3	0	2	1	0	51.00	49.00	9	13	\N	\N	\N	\N	\N	2025-12-01 19:08:47.970511	\N	\N	0	1	a-win	yes
379	1437233	2025-08-28	World	UEFA Europa League	KuPS	FC Midtjylland	a-win	0	2	8	6	30	8	1	10	1	1	0	0	1	0	40.00	60.00	8	7	\N	\N	\N	\N	\N	2025-12-01 19:08:48.21858	\N	\N	0	0	draw	yes
380	1436780	2025-08-28	World	UEFA Europa League	Sigma Olomouc	Malmo FF	a-win	0	2	13	2	12	7	10	2	0	2	2	3	0	0	58.00	42.00	19	18	\N	\N	\N	\N	\N	2025-12-01 19:08:48.434192	\N	\N	0	0	draw	yes
381	1437234	2025-08-28	World	UEFA Europa League	Samsunspor	Panathinaikos	draw	0	0	10	3	7	2	7	3	3	0	3	3	0	0	56.00	44.00	16	11	\N	\N	\N	\N	\N	2025-12-01 19:08:48.589606	\N	\N	0	0	draw	yes
382	1436783	2025-08-28	World	UEFA Europa League	Ludogorets	Shkendija	h-win	4	1	28	11	8	1	4	4	2	2	1	3	0	0	62.00	38.00	14	12	\N	\N	\N	\N	\N	2025-12-01 19:08:48.755167	\N	\N	2	0	h-win	yes
383	1437235	2025-08-28	World	UEFA Europa League	PAOK	HNK Rijeka	h-win	5	0	16	13	4	1	6	2	0	2	0	2	0	1	59.00	41.00	12	10	\N	\N	\N	\N	\N	2025-12-01 19:08:48.915705	\N	\N	2	0	h-win	yes
384	1437232	2025-08-28	World	UEFA Europa League	Utrecht	Zrinjski	draw	0	0	7	1	4	1	4	7	0	1	2	3	0	0	48.00	52.00	12	9	\N	\N	\N	\N	\N	2025-12-01 19:08:49.066632	\N	\N	0	0	draw	yes
385	1436785	2025-08-28	World	UEFA Europa League	BSC Young Boys	Slovan Bratislava	h-win	3	2	10	5	17	7	7	4	1	1	2	0	0	0	51.00	49.00	12	7	\N	\N	\N	\N	\N	2025-12-01 19:08:49.231683	\N	\N	2	1	h-win	yes
386	1436784	2025-08-28	World	UEFA Europa League	Dynamo Kyiv	Maccabi Tel Aviv	h-win	1	0	6	2	4	2	8	7	2	2	1	2	0	0	52.00	48.00	14	14	\N	\N	\N	\N	\N	2025-12-01 19:08:49.386462	\N	\N	1	0	h-win	yes
387	1436781	2025-08-28	World	UEFA Europa League	Genk	Lech Poznan	a-win	1	2	12	4	8	2	8	4	2	0	1	1	0	0	64.00	36.00	15	12	\N	\N	\N	\N	\N	2025-12-01 19:08:49.60165	\N	\N	1	1	draw	yes
388	1436782	2025-08-28	World	UEFA Europa League	FCSB	Aberdeen	h-win	3	0	8	4	6	2	4	3	1	1	1	5	0	1	64.00	36.00	11	16	\N	\N	\N	\N	\N	2025-12-01 19:08:49.795726	\N	\N	1	0	h-win	yes
389	1437236	2025-08-28	World	UEFA Europa League	SC Braga	Lincoln Red Imps FC	h-win	5	1	20	11	4	2	4	3	1	1	1	3	0	0	57.00	43.00	8	10	\N	\N	\N	\N	\N	2025-12-01 19:08:50.121806	\N	\N	3	0	h-win	yes
390	1451164	2025-09-24	World	UEFA Europa League	FC Midtjylland	Sturm Graz	h-win	2	0	7	5	11	4	4	3	5	0	3	2	0	0	53.00	47.00	16	16	\N	\N	\N	\N	\N	2025-12-01 19:08:50.367372	0.56	0.91	1	0	h-win	yes
391	1451165	2025-09-24	World	UEFA Europa League	PAOK	Maccabi Tel Aviv	draw	0	0	18	5	9	3	9	3	1	1	1	3	0	0	55.00	45.00	14	18	\N	\N	\N	\N	\N	2025-12-01 19:08:50.603147	1.43	1.56	0	0	draw	yes
392	1451171	2025-09-24	World	UEFA Europa League	Nice	AS Roma	a-win	1	2	7	2	12	4	3	5	2	3	0	5	0	0	43.00	57.00	9	19	\N	\N	\N	\N	\N	2025-12-01 19:08:50.938506	0.96	0.80	0	0	draw	yes
393	1451166	2025-09-24	World	UEFA Europa League	SC Freiburg	FC Basel 1893	h-win	2	1	15	5	15	4	4	4	0	0	2	2	0	0	48.00	52.00	10	16	\N	\N	\N	\N	\N	2025-12-01 19:08:51.244836	0.92	1.10	1	0	h-win	yes
394	1451172	2025-09-24	World	UEFA Europa League	SC Braga	Feyenoord	h-win	1	0	8	2	5	1	7	2	0	4	1	2	0	0	45.00	55.00	10	15	\N	\N	\N	\N	\N	2025-12-01 19:08:51.527514	0.68	0.27	0	0	draw	yes
395	1451168	2025-09-24	World	UEFA Europa League	Malmo FF	Ludogorets	a-win	1	2	10	5	21	10	2	3	0	2	3	3	0	0	60.00	40.00	9	14	\N	\N	\N	\N	\N	2025-12-01 19:08:51.762336	0.65	2.92	0	2	a-win	yes
396	1451170	2025-09-24	World	UEFA Europa League	Real Betis	Nottingham Forest	draw	2	2	9	4	16	6	3	3	0	1	3	2	0	0	56.00	44.00	16	16	\N	\N	\N	\N	\N	2025-12-01 19:08:52.004167	0.49	3.27	1	2	a-win	yes
397	1451167	2025-09-24	World	UEFA Europa League	FK Crvena Zvezda	Celtic	draw	1	1	16	4	8	6	8	4	3	2	2	2	0	0	47.00	53.00	12	10	\N	\N	\N	\N	\N	2025-12-01 19:08:52.159429	1.61	1.68	0	0	draw	yes
398	1451169	2025-09-24	World	UEFA Europa League	Dinamo Zagreb	Fenerbahçe	h-win	3	1	11	3	6	2	5	6	1	1	2	3	0	0	42.00	58.00	7	8	\N	\N	\N	\N	\N	2025-12-01 19:08:52.320774	1.50	0.17	1	1	draw	yes
399	1451174	2025-09-25	World	UEFA Europa League	Lille	Brann	h-win	2	1	17	4	12	3	11	4	3	0	1	2	0	0	55.00	45.00	7	12	\N	\N	\N	\N	\N	2025-12-01 19:08:52.494659	1.57	0.77	0	0	draw	yes
400	1451173	2025-09-25	World	UEFA Europa League	GO Ahead Eagles	FCSB	a-win	0	1	17	7	8	6	7	1	0	1	1	5	0	0	73.00	27.00	9	14	\N	\N	\N	\N	\N	2025-12-01 19:08:52.696824	1.30	0.56	0	1	a-win	yes
401	1451176	2025-09-25	World	UEFA Europa League	Aston Villa	Bologna	h-win	1	0	12	4	17	7	8	3	2	9	2	2	0	0	47.00	53.00	16	14	\N	\N	\N	\N	\N	2025-12-01 19:08:52.916516	1.24	1.10	1	0	h-win	yes
402	1452153	2025-09-25	World	UEFA Europa League	VfB Stuttgart	Celta Vigo	h-win	2	1	19	6	8	1	9	2	2	1	2	2	0	0	59.00	41.00	12	13	\N	\N	\N	\N	\N	2025-12-01 19:08:53.102847	1.54	0.53	0	0	draw	yes
403	1452154	2025-09-25	World	UEFA Europa League	Utrecht	Lyon	a-win	0	1	11	2	12	4	4	5	1	4	2	4	0	0	38.00	62.00	19	13	\N	\N	\N	\N	\N	2025-12-01 19:08:53.279079	1.14	1.00	0	0	draw	yes
404	1451179	2025-09-25	World	UEFA Europa League	Rangers	Genk	a-win	0	1	11	2	18	4	4	2	1	4	1	3	1	0	54.00	46.00	13	16	\N	\N	\N	\N	\N	2025-12-01 19:08:53.439005	1.01	2.94	0	0	draw	yes
405	1451177	2025-09-25	World	UEFA Europa League	BSC Young Boys	Panathinaikos	a-win	1	4	19	3	18	6	9	4	3	2	1	0	0	0	59.00	41.00	14	6	\N	\N	\N	\N	\N	2025-12-01 19:08:53.615544	1.14	1.17	1	3	a-win	yes
406	1451175	2025-09-25	World	UEFA Europa League	Red Bull Salzburg	FC Porto	a-win	0	1	14	3	15	3	2	8	2	2	4	1	0	0	43.00	57.00	14	8	\N	\N	\N	\N	\N	2025-12-01 19:08:53.862858	1.26	1.41	0	0	draw	yes
407	1451178	2025-09-25	World	UEFA Europa League	Ferencvarosi TC	Plzen	draw	1	1	10	2	9	3	3	3	0	0	4	2	1	0	53.00	47.00	21	17	\N	\N	\N	\N	\N	2025-12-01 19:08:54.115772	0.93	0.67	0	1	a-win	yes
408	1451180	2025-10-02	World	UEFA Europa League	Celtic	SC Braga	a-win	0	2	9	3	13	6	7	5	1	2	2	1	0	0	56.00	44.00	15	9	\N	\N	\N	\N	\N	2025-12-01 19:08:54.342578	0.65	1.05	0	1	a-win	yes
409	1451185	2025-10-02	World	UEFA Europa League	Brann	Utrecht	h-win	1	0	11	3	6	2	4	3	2	3	2	2	0	0	45.00	55.00	16	11	\N	\N	\N	\N	\N	2025-12-01 19:08:54.5584	0.66	0.51	1	0	h-win	yes
410	1451188	2025-10-02	World	UEFA Europa League	AS Roma	Lille	a-win	0	1	20	6	9	5	6	3	0	1	0	4	0	0	50.00	50.00	19	13	\N	\N	\N	\N	\N	2025-12-01 19:08:54.777521	2.20	1.49	0	1	a-win	yes
411	1451183	2025-10-02	World	UEFA Europa League	Bologna	SC Freiburg	draw	1	1	8	3	12	6	2	8	2	3	2	2	0	0	55.00	45.00	16	18	\N	\N	\N	\N	\N	2025-12-01 19:08:54.932338	0.79	2.08	1	0	h-win	yes
412	1451186	2025-10-02	World	UEFA Europa League	FCSB	BSC Young Boys	a-win	0	2	17	3	16	9	8	3	1	0	1	3	0	0	51.00	49.00	11	18	\N	\N	\N	\N	\N	2025-12-01 19:08:55.12346	0.69	1.50	0	2	a-win	yes
413	1451182	2025-10-02	World	UEFA Europa League	Ludogorets	Real Betis	a-win	0	2	13	2	12	2	6	5	2	5	1	3	0	0	53.00	47.00	8	15	\N	\N	\N	\N	\N	2025-12-01 19:08:55.333406	0.44	0.75	0	1	a-win	yes
414	1451187	2025-10-02	World	UEFA Europa League	Plzen	Malmo FF	h-win	3	0	14	7	8	1	3	6	4	2	2	4	1	2	59.00	41.00	12	16	\N	\N	\N	\N	\N	2025-12-01 19:08:55.514006	2.17	0.36	2	0	h-win	yes
415	1451184	2025-10-02	World	UEFA Europa League	Fenerbahçe	Nice	h-win	2	1	17	5	10	3	3	4	3	0	3	1	0	0	59.00	41.00	12	17	\N	\N	\N	\N	\N	2025-12-01 19:08:55.702203	1.52	1.29	2	1	h-win	yes
416	1451181	2025-10-02	World	UEFA Europa League	Panathinaikos	GO Ahead Eagles	a-win	1	2	33	9	7	4	14	3	0	1	1	1	0	0	64.00	36.00	8	12	\N	\N	\N	\N	\N	2025-12-01 19:08:55.969265	2.23	1.02	0	0	draw	yes
417	1451194	2025-10-02	World	UEFA Europa League	Nottingham Forest	FC Midtjylland	a-win	2	3	22	9	8	5	10	8	3	2	3	2	0	0	61.00	39.00	14	15	\N	\N	\N	\N	\N	2025-12-01 19:08:56.268029	2.05	2.10	1	2	a-win	yes
418	1451191	2025-10-02	World	UEFA Europa League	Lyon	Red Bull Salzburg	h-win	2	0	15	6	11	5	2	1	0	2	1	1	0	0	65.00	35.00	10	14	\N	\N	\N	\N	\N	2025-12-01 19:08:56.476634	3.21	0.51	1	0	h-win	yes
419	1452155	2025-10-02	World	UEFA Europa League	Feyenoord	Aston Villa	a-win	0	2	19	8	6	3	8	1	2	2	3	3	0	0	41.00	59.00	17	10	\N	\N	\N	\N	\N	2025-12-01 19:08:56.65727	1.47	0.63	0	0	draw	yes
420	1451192	2025-10-02	World	UEFA Europa League	FC Porto	FK Crvena Zvezda	h-win	2	1	18	4	9	2	5	3	1	1	3	2	0	0	50.00	50.00	11	8	\N	\N	\N	\N	\N	2025-12-01 19:08:56.847748	2.65	0.53	1	1	draw	yes
421	1451196	2025-10-02	World	UEFA Europa League	Celta Vigo	PAOK	h-win	3	1	15	9	5	2	5	1	2	1	3	2	0	0	63.00	37.00	9	13	\N	\N	\N	\N	\N	2025-12-01 19:08:57.040567	2.70	0.75	1	1	draw	yes
422	1451189	2025-10-02	World	UEFA Europa League	FC Basel 1893	VfB Stuttgart	h-win	2	0	12	4	29	7	1	9	0	1	3	0	0	0	35.00	65.00	19	10	\N	\N	\N	\N	\N	2025-12-01 19:08:57.242417	1.43	2.54	1	0	h-win	yes
423	1451193	2025-10-02	World	UEFA Europa League	Maccabi Tel Aviv	Dinamo Zagreb	a-win	1	3	11	4	6	5	5	3	2	2	1	1	0	0	50.00	50.00	8	11	\N	\N	\N	\N	\N	2025-12-01 19:08:57.476437	0.59	0.69	1	2	a-win	yes
424	1451195	2025-10-02	World	UEFA Europa League	Sturm Graz	Rangers	h-win	2	1	16	8	16	10	3	7	1	0	2	1	0	0	41.00	59.00	20	13	\N	\N	\N	\N	\N	2025-12-01 19:08:57.660754	1.64	1.87	2	0	h-win	yes
425	1451190	2025-10-02	World	UEFA Europa League	Genk	Ferencvarosi TC	a-win	0	1	13	3	8	5	5	3	3	2	0	3	0	0	63.00	37.00	8	16	\N	\N	\N	\N	\N	2025-12-01 19:08:57.885886	1.19	1.18	0	1	a-win	yes
426	1451203	2025-10-23	World	UEFA Europa League	Lyon	FC Basel 1893	h-win	2	0	18	6	10	3	4	2	3	0	1	1	0	0	61.00	39.00	12	12	\N	\N	\N	\N	\N	2025-12-01 19:08:58.035645	2.47	1.19	1	0	h-win	yes
427	1451204	2025-10-23	World	UEFA Europa League	SC Braga	FK Crvena Zvezda	h-win	2	0	11	4	9	3	2	2	2	3	0	1	0	0	50.00	50.00	13	5	\N	\N	\N	\N	\N	2025-12-01 19:08:58.212782	1.73	0.41	1	0	h-win	yes
428	1451198	2025-10-23	World	UEFA Europa League	Brann	Rangers	h-win	3	0	13	5	9	1	3	5	0	2	1	2	0	0	53.00	47.00	10	10	\N	\N	\N	\N	\N	2025-12-01 19:08:58.377412	2.33	1.27	1	0	h-win	yes
429	1451199	2025-10-23	World	UEFA Europa League	GO Ahead Eagles	Aston Villa	h-win	2	1	5	3	18	7	1	10	5	1	2	0	0	0	30.00	70.00	22	0	\N	\N	\N	\N	\N	2025-12-01 19:08:58.545576	0.83	2.82	1	1	draw	yes
430	1451205	2025-10-23	World	UEFA Europa League	FCSB	Bologna	a-win	1	2	9	6	21	7	4	10	1	1	3	5	0	0	46.00	54.00	18	20	\N	\N	\N	\N	\N	2025-12-01 19:08:58.690903	0.66	1.72	0	2	a-win	yes
431	1451202	2025-10-23	World	UEFA Europa League	Red Bull Salzburg	Ferencvarosi TC	a-win	2	3	16	4	13	7	5	2	3	1	0	3	0	0	54.00	46.00	12	13	\N	\N	\N	\N	\N	2025-12-01 19:08:58.844514	1.30	2.77	1	0	h-win	yes
432	1451197	2025-10-23	World	UEFA Europa League	Fenerbahçe	VfB Stuttgart	h-win	1	0	19	7	11	2	4	7	2	0	6	4	0	0	35.00	65.00	11	15	\N	\N	\N	\N	\N	2025-12-01 19:08:59.00491	1.79	1.00	1	0	h-win	yes
433	1451200	2025-10-23	World	UEFA Europa League	Genk	Real Betis	draw	0	0	5	1	10	3	2	1	3	2	1	3	0	0	44.00	56.00	12	12	\N	\N	\N	\N	\N	2025-12-01 19:08:59.199382	0.23	0.79	0	0	draw	yes
434	1451210	2025-10-23	World	UEFA Europa League	Nottingham Forest	FC Porto	h-win	2	0	8	3	10	2	3	8	0	2	2	2	0	0	51.00	49.00	13	15	\N	\N	\N	\N	\N	2025-12-01 19:08:59.445688	2.09	0.60	1	0	h-win	yes
435	1451212	2025-10-23	World	UEFA Europa League	Lille	PAOK	a-win	3	4	22	11	8	7	13	2	3	0	1	5	0	1	65.00	35.00	7	15	\N	\N	\N	\N	\N	2025-12-01 19:08:59.693579	1.59	2.40	0	3	a-win	yes
436	1452156	2025-10-23	World	UEFA Europa League	SC Freiburg	Utrecht	h-win	2	0	14	7	11	2	5	4	1	0	0	1	0	0	52.00	48.00	12	11	\N	\N	\N	\N	\N	2025-12-01 19:08:59.979741	1.56	0.97	2	0	h-win	yes
437	1451201	2025-10-23	World	UEFA Europa League	Feyenoord	Panathinaikos	h-win	3	1	18	8	12	5	3	2	3	6	1	5	0	0	50.00	50.00	18	9	\N	\N	\N	\N	\N	2025-12-01 19:09:00.253875	2.63	1.13	1	1	draw	yes
438	1451208	2025-10-23	World	UEFA Europa League	Celtic	Sturm Graz	h-win	2	1	20	7	8	1	9	2	1	7	1	1	0	1	66.00	34.00	16	16	\N	\N	\N	\N	\N	2025-12-01 19:09:00.493802	4.02	0.46	0	1	a-win	yes
439	1451213	2025-10-23	World	UEFA Europa League	Malmo FF	Dinamo Zagreb	draw	1	1	6	3	21	5	3	10	1	1	1	2	0	0	25.00	75.00	6	9	\N	\N	\N	\N	\N	2025-12-01 19:09:00.740091	0.63	2.45	1	0	h-win	yes
480	1383467	2025-07-10	World	UEFA Europa Conference League	Racing FC Union Luxembourg	Dila	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:11.439022	\N	\N	0	0	draw	yes
440	1451209	2025-10-23	World	UEFA Europa League	AS Roma	Plzen	a-win	1	2	20	8	6	2	10	3	1	2	2	5	0	0	68.00	32.00	12	19	\N	\N	\N	\N	\N	2025-12-01 19:09:00.989327	2.28	0.16	0	2	a-win	yes
441	1451206	2025-10-23	World	UEFA Europa League	Celta Vigo	Nice	h-win	2	1	25	6	9	3	7	4	3	0	1	4	0	1	65.00	35.00	20	7	\N	\N	\N	\N	\N	2025-12-01 19:09:01.240333	1.31	1.18	1	1	draw	yes
442	1451207	2025-10-23	World	UEFA Europa League	BSC Young Boys	Ludogorets	h-win	3	2	15	6	15	4	3	2	3	2	2	1	0	0	59.00	41.00	9	9	\N	\N	\N	\N	\N	2025-12-01 19:09:01.481631	4.36	0.99	1	1	draw	yes
443	1451211	2025-10-23	World	UEFA Europa League	Maccabi Tel Aviv	FC Midtjylland	a-win	0	3	12	3	12	4	4	6	1	2	0	4	0	0	44.00	56.00	10	14	\N	\N	\N	\N	\N	2025-12-01 19:09:01.674152	0.95	1.44	0	1	a-win	yes
444	1451214	2025-11-06	World	UEFA Europa League	Nice	SC Freiburg	a-win	1	3	17	4	16	7	5	4	1	1	1	2	0	0	60.00	40.00	9	14	\N	\N	\N	36	4	2025-12-01 19:09:01.980452	1.79	2.13	1	3	a-win	yes
445	1451217	2025-11-06	World	UEFA Europa League	Utrecht	FC Porto	draw	1	1	11	3	19	8	2	7	0	1	3	5	1	0	25.00	75.00	16	12	\N	\N	\N	32	8	2025-12-01 19:09:02.216542	0.54	1.22	0	0	draw	yes
446	1451221	2025-11-06	World	UEFA Europa League	Malmo FF	Panathinaikos	a-win	0	1	12	2	11	4	4	2	2	0	2	4	0	0	57.00	43.00	12	17	\N	\N	\N	34	14	2025-12-01 19:09:02.398011	1.42	1.36	0	0	draw	yes
447	1452157	2025-11-06	World	UEFA Europa League	FC Midtjylland	Celtic	h-win	3	1	24	12	5	3	4	4	1	0	0	3	0	0	60.00	40.00	13	14	\N	\N	\N	2	21	2025-12-01 19:09:02.557552	2.73	0.98	3	0	h-win	yes
448	1451220	2025-11-06	World	UEFA Europa League	FC Basel 1893	FCSB	h-win	3	1	25	9	14	7	8	5	3	2	2	3	0	1	67.00	33.00	13	15	\N	\N	\N	24	31	2025-12-01 19:09:02.744578	3.91	1.16	1	0	h-win	yes
449	1451216	2025-11-06	World	UEFA Europa League	Red Bull Salzburg	GO Ahead Eagles	h-win	2	0	17	8	10	2	3	4	1	2	0	2	0	0	43.00	57.00	7	7	\N	\N	\N	29	27	2025-12-01 19:09:02.948005	2.33	1.37	0	0	draw	yes
450	1451219	2025-11-06	World	UEFA Europa League	FK Crvena Zvezda	Lille	h-win	1	0	11	3	11	3	5	3	3	0	3	4	0	0	40.00	60.00	17	15	\N	\N	\N	22	11	2025-12-01 19:09:03.178398	1.71	1.58	0	0	draw	yes
451	1451218	2025-11-06	World	UEFA Europa League	Dinamo Zagreb	Celta Vigo	a-win	0	3	10	5	8	3	5	2	3	3	0	0	0	0	59.00	41.00	6	12	\N	\N	\N	23	10	2025-12-01 19:09:03.476224	0.75	1.44	0	3	a-win	yes
452	1451215	2025-11-06	World	UEFA Europa League	Sturm Graz	Nottingham Forest	draw	0	0	3	2	9	2	0	4	2	2	1	1	0	0	42.00	58.00	17	13	\N	\N	\N	28	16	2025-12-01 19:09:03.768751	0.09	1.70	0	0	draw	yes
453	1451230	2025-11-06	World	UEFA Europa League	Aston Villa	Maccabi Tel Aviv	h-win	2	0	14	8	6	3	3	1	2	2	0	2	0	0	66.00	34.00	12	18	\N	\N	\N	3	35	2025-12-01 19:09:04.029047	2.07	1.10	1	0	h-win	yes
454	1451228	2025-11-06	World	UEFA Europa League	VfB Stuttgart	Feyenoord	h-win	2	0	13	6	12	4	2	5	0	1	4	4	0	0	53.00	47.00	26	22	\N	\N	\N	12	30	2025-12-01 19:09:04.323409	1.73	0.89	0	0	draw	yes
455	1451226	2025-11-06	World	UEFA Europa League	SC Braga	Genk	a-win	3	4	20	6	9	8	9	2	1	1	2	1	0	0	63.00	37.00	6	14	\N	\N	\N	7	9	2025-12-01 19:09:04.582414	2.55	1.09	1	1	draw	yes
456	1451222	2025-11-06	World	UEFA Europa League	Rangers	AS Roma	a-win	0	2	11	2	14	3	2	6	2	3	0	0	0	0	40.00	60.00	11	17	\N	\N	\N	33	15	2025-12-01 19:09:04.686003	0.91	2.05	0	2	a-win	yes
457	1451225	2025-11-06	World	UEFA Europa League	Bologna	Brann	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	18	19	2025-12-01 19:09:04.693189	\N	\N	0	0	draw	yes
458	1451227	2025-11-06	World	UEFA Europa League	Real Betis	Lyon	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	1	2025-12-01 19:09:04.698938	\N	\N	2	0	h-win	yes
459	1451223	2025-11-06	World	UEFA Europa League	Plzen	Fenerbahçe	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	13	20	2025-12-01 19:09:04.707633	\N	\N	0	0	draw	yes
460	1451229	2025-11-06	World	UEFA Europa League	PAOK	BSC Young Boys	h-win	4	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	17	26	2025-12-01 19:09:04.713558	\N	\N	0	0	draw	yes
461	1451224	2025-11-06	World	UEFA Europa League	Ferencvarosi TC	Ludogorets	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	25	2025-12-01 19:09:04.719634	\N	\N	1	0	h-win	yes
462	1386548	2025-07-01	World	FIFA Club World Cup	Manchester City	Al-Hilal Saudi FC	a-win	3	4	30	15	17	6	19	4	0	2	3	1	0	0	69.00	31.00	17	7	\N	\N	\N	\N	\N	2025-12-01 20:12:05.702108	\N	\N	1	0	h-win	yes
463	1386549	2025-07-01	World	FIFA Club World Cup	Real Madrid	Juventus	h-win	1	0	21	11	6	2	11	4	0	2	1	0	0	0	57.00	43.00	11	5	\N	\N	\N	\N	\N	2025-12-01 20:12:05.87147	\N	\N	0	0	draw	yes
464	1386550	2025-07-02	World	FIFA Club World Cup	Borussia Dortmund	Monterrey	h-win	2	1	6	3	14	7	3	5	5	2	2	0	0	0	42.00	58.00	13	9	\N	\N	\N	\N	\N	2025-12-01 20:12:06.043978	\N	\N	2	0	h-win	yes
465	1390817	2025-07-04	World	FIFA Club World Cup	Fluminense	Al-Hilal Saudi FC	h-win	2	1	10	3	15	4	4	12	3	1	3	4	0	0	43.00	57.00	13	12	\N	\N	\N	\N	\N	2025-12-01 20:12:06.207485	\N	\N	1	0	h-win	yes
466	1390026	2025-07-05	World	FIFA Club World Cup	Palmeiras	Chelsea	a-win	1	2	7	2	19	6	3	10	3	0	1	3	0	0	37.00	63.00	14	16	\N	\N	\N	\N	\N	2025-12-01 20:12:06.385456	\N	\N	0	1	a-win	yes
467	1390797	2025-07-05	World	FIFA Club World Cup	Paris Saint Germain	Bayern München	h-win	2	0	11	5	13	5	0	4	0	3	1	1	2	0	46.00	54.00	12	13	\N	\N	\N	\N	\N	2025-12-01 20:12:06.673942	\N	\N	0	0	draw	yes
468	1390818	2025-07-05	World	FIFA Club World Cup	Real Madrid	Borussia Dortmund	h-win	3	2	15	8	12	5	3	3	1	1	1	2	1	0	48.00	52.00	10	6	\N	\N	\N	\N	\N	2025-12-01 20:12:06.841411	\N	\N	2	0	h-win	yes
469	1392812	2025-07-08	World	FIFA Club World Cup	Fluminense	Chelsea	a-win	0	2	12	3	17	5	3	4	2	4	2	1	0	0	46.00	54.00	11	11	\N	\N	\N	\N	\N	2025-12-01 20:12:06.993477	\N	\N	0	1	a-win	yes
470	1392813	2025-07-09	World	FIFA Club World Cup	Paris Saint Germain	Real Madrid	h-win	4	0	17	7	11	2	3	6	4	0	1	2	0	0	68.00	32.00	9	9	\N	\N	\N	\N	\N	2025-12-01 20:12:07.173181	\N	\N	3	0	h-win	yes
471	1399365	2025-07-13	World	FIFA Club World Cup	Chelsea	Paris Saint Germain	h-win	3	0	10	5	8	6	3	5	3	2	4	2	0	1	34.00	66.00	15	12	\N	\N	\N	\N	\N	2025-12-01 20:12:07.336628	\N	\N	3	0	h-win	yes
472	1377400	2025-08-13	World	UEFA Super Cup	Paris Saint Germain	Tottenham	draw	2	2	12	3	13	5	7	2	2	4	3	2	0	0	74.00	26.00	12	12	\N	\N	\N	\N	\N	2025-12-01 20:12:08.675961	\N	\N	0	1	a-win	yes
473	1383458	2025-07-08	World	UEFA Europa Conference League	St Joseph S Fc	Cliftonville FC	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:10.007732	\N	\N	0	1	a-win	yes
474	1383459	2025-07-08	World	UEFA Europa Conference League	Floriana	Haverfordwest County AFC	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:10.168799	\N	\N	1	1	draw	yes
475	1383460	2025-07-10	World	UEFA Europa Conference League	Atlètic Club d'Escaldes	F91 Dudelange	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:10.320263	\N	\N	2	0	h-win	yes
476	1383462	2025-07-10	World	UEFA Europa Conference League	Magpies	Paide	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:10.747491	\N	\N	1	2	a-win	yes
477	1383465	2025-07-10	World	UEFA Europa Conference League	Torpedo Kutaisi	Ordabasy	h-win	4	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:10.965439	\N	\N	2	2	draw	yes
478	1383464	2025-07-10	World	UEFA Europa Conference League	SJK	KI Klaksvik	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:11.122505	\N	\N	0	1	a-win	yes
479	1383466	2025-07-10	World	UEFA Europa Conference League	Kauno Žalgiris	Penybont	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:11.289085	\N	\N	2	0	h-win	yes
481	1383468	2025-07-10	World	UEFA Europa Conference League	FC Urartu	Neman	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:11.598946	\N	\N	0	0	draw	yes
482	1383469	2025-07-10	World	UEFA Europa Conference League	Kalju Nomme	Partizani	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:11.752078	\N	\N	0	0	draw	yes
483	1383470	2025-07-10	World	UEFA Europa Conference League	Torpedo Zhodino	FK Rabotnicki	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:11.930342	\N	\N	1	0	h-win	yes
484	1383473	2025-07-10	World	UEFA Europa Conference League	Birkirkara	Petrocub	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:12.093192	\N	\N	0	0	draw	yes
485	1383472	2025-07-10	World	UEFA Europa Conference League	Vllaznia Shkodër	BFC Daugavpils	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:12.256628	\N	\N	0	0	draw	yes
486	1383471	2025-07-10	World	UEFA Europa Conference League	Dečić	Sileks	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:12.582583	\N	\N	1	0	h-win	yes
487	1383463	2025-07-10	World	UEFA Europa Conference League	Malisheva	Vikingur Reykjavik	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:12.763995	\N	\N	0	1	a-win	yes
488	1383476	2025-07-10	World	UEFA Europa Conference League	Vardar Skopje	La Fiorita	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:12.92648	\N	\N	0	0	draw	yes
489	1383475	2025-07-10	World	UEFA Europa Conference League	Zeljeznicar Sarajevo	Koper	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:13.080886	\N	\N	0	1	a-win	yes
490	1383474	2025-07-10	World	UEFA Europa Conference League	Sutjeska	Dinamo Brest	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:13.255938	\N	\N	0	1	a-win	yes
491	1383478	2025-07-10	World	UEFA Europa Conference League	NSI Runavik	HJK helsinki	h-win	4	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:13.41142	\N	\N	2	0	h-win	yes
492	1383477	2025-07-10	World	UEFA Europa Conference League	St Patrick's Athl.	Hegelmann Litauen	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:13.571856	\N	\N	0	0	draw	yes
493	1383461	2025-07-10	World	UEFA Europa Conference League	Tre Fiori	Pyunik Yerevan	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:13.732598	\N	\N	0	0	draw	yes
494	1383480	2025-07-10	World	UEFA Europa Conference League	Borac Banja Luka	FC Santa Coloma	a-win	1	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:13.897208	\N	\N	0	3	a-win	yes
495	1383479	2025-07-10	World	UEFA Europa Conference League	Larne	Auda	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:14.045636	\N	\N	0	0	draw	yes
496	1383481	2025-07-10	World	UEFA Europa Conference League	Valur Reykjavik	Flora Tallinn	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:14.212652	\N	\N	3	0	h-win	yes
497	1383482	2025-07-16	World	UEFA Europa Conference League	Auda	Larne	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:14.37419	\N	\N	1	0	h-win	yes
498	1383483	2025-07-17	World	UEFA Europa Conference League	BFC Daugavpils	Vllaznia Shkodër	a-win	2	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:14.571842	\N	\N	2	2	draw	yes
499	1383488	2025-07-17	World	UEFA Europa Conference League	FC Santa Coloma	Borac Banja Luka	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:14.738016	\N	\N	0	0	draw	yes
500	1383489	2025-07-17	World	UEFA Europa Conference League	HJK helsinki	NSI Runavik	h-win	5	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:14.933985	\N	\N	1	0	h-win	yes
501	1383484	2025-07-17	World	UEFA Europa Conference League	FK Rabotnicki	Torpedo Zhodino	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:15.1085	\N	\N	0	1	a-win	yes
502	1383491	2025-07-17	World	UEFA Europa Conference League	Flora Tallinn	Valur Reykjavik	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:15.272443	\N	\N	1	1	draw	yes
503	1383490	2025-07-17	World	UEFA Europa Conference League	Ordabasy	Torpedo Kutaisi	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:15.43581	\N	\N	0	1	a-win	yes
504	1383487	2025-07-17	World	UEFA Europa Conference League	Pyunik Yerevan	Tre Fiori	h-win	5	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:15.595167	\N	\N	3	0	h-win	yes
505	1383485	2025-07-17	World	UEFA Europa Conference League	Dila	Racing FC Union Luxembourg	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:15.775137	\N	\N	0	0	draw	yes
506	1383486	2025-07-17	World	UEFA Europa Conference League	Hegelmann Litauen	St Patrick's Athl.	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:16.000408	\N	\N	0	1	a-win	yes
507	1383492	2025-07-17	World	UEFA Europa Conference League	Paide	Magpies	h-win	4	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:16.183297	\N	\N	1	0	h-win	yes
508	1383497	2025-07-17	World	UEFA Europa Conference League	F91 Dudelange	Atlètic Club d'Escaldes	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:16.365875	\N	\N	1	1	draw	yes
509	1383496	2025-07-17	World	UEFA Europa Conference League	Penybont	Kauno Žalgiris	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:16.527982	\N	\N	1	1	draw	yes
510	1383493	2025-07-17	World	UEFA Europa Conference League	Haverfordwest County AFC	Floriana	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:16.680719	\N	\N	2	2	draw	yes
511	1383495	2025-07-17	World	UEFA Europa Conference League	Petrocub	Birkirkara	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:16.843802	\N	\N	1	0	h-win	yes
512	1383494	2025-07-17	World	UEFA Europa Conference League	Sileks	Dečić	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:17.009582	\N	\N	1	1	draw	yes
513	1383498	2025-07-17	World	UEFA Europa Conference League	Koper	Zeljeznicar Sarajevo	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:17.163269	\N	\N	3	1	h-win	yes
514	1383499	2025-07-17	World	UEFA Europa Conference League	Neman	FC Urartu	h-win	4	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:17.320667	\N	\N	1	0	h-win	yes
515	1383500	2025-07-17	World	UEFA Europa Conference League	Partizani	Kalju Nomme	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:17.47656	\N	\N	0	0	draw	yes
516	1383501	2025-07-17	World	UEFA Europa Conference League	Dinamo Brest	Sutjeska	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:17.642303	\N	\N	0	0	draw	yes
517	1383503	2025-07-17	World	UEFA Europa Conference League	Vikingur Reykjavik	Malisheva	h-win	8	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:17.799266	\N	\N	5	0	h-win	yes
518	1383504	2025-07-17	World	UEFA Europa Conference League	KI Klaksvik	SJK	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:17.971565	\N	\N	0	0	draw	yes
519	1383502	2025-07-17	World	UEFA Europa Conference League	Cliftonville FC	St Joseph S Fc	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:18.189463	\N	\N	1	1	draw	yes
520	1383505	2025-07-17	World	UEFA Europa Conference League	La Fiorita	Vardar Skopje	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:18.35651	\N	\N	1	0	h-win	yes
521	1410004	2025-07-22	World	UEFA Europa Conference League	Ballkani	Floriana	h-win	4	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:18.509354	\N	\N	3	2	h-win	yes
522	1383506	2025-07-23	World	UEFA Europa Conference League	Zira	HNK Hajduk Split	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:18.66803	\N	\N	1	0	h-win	yes
523	1410005	2025-07-23	World	UEFA Europa Conference League	FC Levadia Tallinn	Saburtalo	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:18.817763	\N	\N	0	0	draw	yes
524	1383514	2025-07-23	World	UEFA Europa Conference League	Silkeborg	KA Akureyri	draw	1	1	16	8	6	2	3	5	1	3	3	0	0	0	65.00	35.00	8	7	\N	\N	\N	\N	\N	2025-12-01 20:12:18.978463	\N	\N	1	0	h-win	yes
525	1410006	2025-07-23	World	UEFA Europa Conference League	The New Saints	FC Differdange 03	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:19.126997	\N	\N	0	1	a-win	yes
526	1410007	2025-07-23	World	UEFA Europa Conference League	Olimpija Ljubljana	Inter Club d'Escaldes	h-win	4	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:19.27954	\N	\N	0	1	a-win	yes
527	1410008	2025-07-23	World	UEFA Europa Conference League	Buducnost Podgorica	Milsami Orhei	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:19.452654	\N	\N	0	0	draw	yes
528	1383532	2025-07-24	World	UEFA Europa Conference League	FC Astana	Zimbru	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:19.624616	\N	\N	0	1	a-win	yes
529	1410009	2025-07-24	World	UEFA Europa Conference League	Atlètic Club d'Escaldes	Dinamo Tirana	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:19.777544	\N	\N	1	0	h-win	yes
530	1410018	2025-07-24	World	UEFA Europa Conference League	Paide	AIK Stockholm	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:19.933178	\N	\N	0	1	a-win	yes
531	1383522	2025-07-24	World	UEFA Europa Conference League	Rosenborg	Banga	h-win	5	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:20.321985	\N	\N	1	0	h-win	yes
532	1410014	2025-07-24	World	UEFA Europa Conference League	FK Zalgiris Vilnius	Linfield	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:20.569622	\N	\N	0	0	draw	yes
533	1410011	2025-07-24	World	UEFA Europa Conference League	St Joseph S Fc	Shamrock Rovers	a-win	0	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:20.792013	\N	\N	0	1	a-win	yes
534	1410016	2025-07-24	World	UEFA Europa Conference League	Pyunik Yerevan	Gyori ETO FC	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:20.992678	\N	\N	1	0	h-win	yes
535	1410012	2025-07-24	World	UEFA Europa Conference League	Ilves	AZ Alkmaar	h-win	4	3	14	7	23	8	4	9	0	0	0	2	0	0	35.00	65.00	7	8	\N	\N	\N	\N	\N	2025-12-01 20:12:21.153644	\N	\N	2	1	h-win	yes
536	1410017	2025-07-24	World	UEFA Europa Conference League	Arda Kardzhali	HJK helsinki	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:21.302825	\N	\N	0	0	draw	yes
537	1383518	2025-07-24	World	UEFA Europa Conference League	Aris	Puskas Academy	h-win	3	2	17	5	7	4	1	2	0	1	3	3	0	0	39.00	61.00	15	16	\N	\N	\N	\N	\N	2025-12-01 20:12:21.463809	\N	\N	2	0	h-win	yes
538	1383510	2025-07-24	World	UEFA Europa Conference League	Ararat-Armenia	Universitatea Cluj	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:21.651159	\N	\N	0	0	draw	yes
539	1410015	2025-07-24	World	UEFA Europa Conference League	Kauno Žalgiris	Valur Reykjavik	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:21.823895	\N	\N	0	0	draw	yes
540	1410010	2025-07-24	World	UEFA Europa Conference League	Hibernians	Spartak Trnava	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:21.986312	\N	\N	0	1	a-win	yes
541	1410013	2025-07-24	World	UEFA Europa Conference League	Aktobe	Sparta Praha	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:22.18415	\N	\N	1	0	h-win	yes
542	1383508	2025-07-24	World	UEFA Europa Conference League	Araz	Aris Thessalonikis	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:22.355343	\N	\N	0	0	draw	yes
543	1383511	2025-07-24	World	UEFA Europa Conference League	Hammarby FF	Charleroi	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:22.54386	\N	\N	0	0	draw	yes
544	1410020	2025-07-24	World	UEFA Europa Conference League	Viking	Koper	h-win	7	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:22.729947	\N	\N	1	0	h-win	yes
545	1383512	2025-07-24	World	UEFA Europa Conference League	Cherno More Varna	Başakşehir	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:22.903257	\N	\N	0	0	draw	yes
546	1410021	2025-07-24	World	UEFA Europa Conference League	Petrocub	Sabah FA	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:23.063778	\N	\N	0	0	draw	yes
547	1383507	2025-07-24	World	UEFA Europa Conference League	Novi Pazar	Jagiellonia	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:23.219253	\N	\N	1	1	draw	yes
548	1410019	2025-07-24	World	UEFA Europa Conference League	Omonia Nicosia	Torpedo Kutaisi	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:23.374289	\N	\N	1	0	h-win	yes
549	1410024	2025-07-24	World	UEFA Europa Conference League	Oleksandria	FK Partizan	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:23.58337	\N	\N	0	1	a-win	yes
550	1410022	2025-07-24	World	UEFA Europa Conference League	Polessya	FC Santa Coloma	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:23.735024	\N	\N	1	2	a-win	yes
551	1410023	2025-07-24	World	UEFA Europa Conference League	Riga	Dila	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:23.932193	\N	\N	1	0	h-win	yes
552	1383520	2025-07-24	World	UEFA Europa Conference League	FC Vaduz	Dungannon Swifts	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:24.116413	\N	\N	0	0	draw	yes
553	1410025	2025-07-24	World	UEFA Europa Conference League	Torpedo Zhodino	Maccabi Haifa	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:24.279345	\N	\N	0	1	a-win	yes
554	1412428	2025-07-24	World	UEFA Europa Conference League	AEK Athens FC	Hapoel Beer Sheva	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:24.50137	\N	\N	0	0	draw	yes
555	1383521	2025-07-24	World	UEFA Europa Conference League	NK Varazdin	Santa Clara	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:24.740466	\N	\N	1	0	h-win	yes
556	1410028	2025-07-24	World	UEFA Europa Conference League	Paks	Maribor	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:24.943926	\N	\N	0	0	draw	yes
557	1410026	2025-07-24	World	UEFA Europa Conference League	Radnicki 1923	KI Klaksvik	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:25.120616	\N	\N	0	0	draw	yes
558	1410027	2025-07-24	World	UEFA Europa Conference League	FK Košice	Neman	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:25.308668	\N	\N	2	0	h-win	yes
559	1410030	2025-07-24	World	UEFA Europa Conference League	Vardar Skopje	Lausanne	h-win	2	1	11	6	7	2	6	3	2	1	2	2	0	0	42.00	58.00	8	5	\N	\N	\N	\N	\N	2025-12-01 20:12:25.463707	\N	\N	1	0	h-win	yes
560	1383519	2025-07-24	World	UEFA Europa Conference League	Austria Vienna	Spaeri	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:25.624366	\N	\N	1	0	h-win	yes
561	1412427	2025-07-24	World	UEFA Europa Conference League	Sutjeska	Beitar Jerusalem	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:25.78516	\N	\N	1	1	draw	yes
562	1410029	2025-07-24	World	UEFA Europa Conference League	Vllaznia Shkodër	Vikingur Reykjavik	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:25.944797	\N	\N	0	1	a-win	yes
563	1410031	2025-07-24	World	UEFA Europa Conference League	Dinamo Minsk	Egnatia Rrogozhinë	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:26.123684	\N	\N	0	1	a-win	yes
564	1383516	2025-07-24	World	UEFA Europa Conference League	Dundee Utd	UNA Strassen	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:26.310446	\N	\N	0	0	draw	yes
565	1410032	2025-07-24	World	UEFA Europa Conference League	St Patrick's Athl.	Kalju Nomme	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:26.504372	\N	\N	0	0	draw	yes
566	1383515	2025-07-24	World	UEFA Europa Conference League	HB	Brondby	draw	1	1	13	4	22	5	2	6	1	2	1	1	0	0	34.00	66.00	7	9	\N	\N	\N	\N	\N	2025-12-01 20:12:26.68931	\N	\N	0	0	draw	yes
567	1383513	2025-07-24	World	UEFA Europa Conference League	FK Sarajevo	Universitatea Craiova	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:26.890819	\N	\N	2	0	h-win	yes
568	1383517	2025-07-24	World	UEFA Europa Conference League	Raków Częstochowa	Žilina	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:27.099401	\N	\N	0	0	draw	yes
569	1410033	2025-07-24	World	UEFA Europa Conference League	Dečić	Rapid Vienna	a-win	0	2	6	1	11	3	7	10	4	2	3	3	0	0	48.00	52.00	13	24	\N	\N	\N	\N	\N	2025-12-01 20:12:27.297492	\N	\N	0	2	a-win	yes
570	1410034	2025-07-24	World	UEFA Europa Conference League	Larne	Prishtina	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:27.471745	\N	\N	0	0	draw	yes
571	1410035	2025-07-29	World	UEFA Europa Conference League	Saburtalo	FC Levadia Tallinn	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:27.65333	\N	\N	1	0	h-win	yes
572	1410036	2025-07-29	World	UEFA Europa Conference League	FC Differdange 03	The New Saints	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:27.824912	\N	\N	0	0	draw	yes
573	1410037	2025-07-29	World	UEFA Europa Conference League	Inter Club d'Escaldes	Olimpija Ljubljana	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:27.987594	\N	\N	0	1	a-win	yes
574	1410039	2025-07-31	World	UEFA Europa Conference League	Spartak Trnava	Hibernians	h-win	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:28.159868	\N	\N	2	1	h-win	yes
575	1410043	2025-07-31	World	UEFA Europa Conference League	FC Santa Coloma	Polessya	a-win	1	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:28.322049	\N	\N	0	1	a-win	yes
576	1410041	2025-07-31	World	UEFA Europa Conference League	HJK helsinki	Arda Kardzhali	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:28.540761	\N	\N	1	1	draw	yes
577	1410048	2025-07-31	World	UEFA Europa Conference League	Gyori ETO FC	Pyunik Yerevan	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:28.713382	\N	\N	1	0	h-win	yes
578	1410040	2025-07-31	World	UEFA Europa Conference League	Dila	Riga	draw	3	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:28.88544	\N	\N	1	1	draw	yes
579	1383537	2025-07-31	World	UEFA Europa Conference League	Banga	Rosenborg	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:29.068319	\N	\N	0	0	draw	yes
580	1410042	2025-07-31	World	UEFA Europa Conference League	Sabah FA	Petrocub	h-win	4	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:29.223334	\N	\N	4	1	h-win	yes
581	1383524	2025-07-31	World	UEFA Europa Conference League	Spaeri	Austria Vienna	a-win	0	5	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:29.403462	\N	\N	0	3	a-win	yes
582	1410045	2025-07-31	World	UEFA Europa Conference League	AZ Alkmaar	Ilves	h-win	5	0	27	16	7	2	9	1	4	1	3	2	0	0	57.00	43.00	15	9	\N	\N	\N	\N	\N	2025-12-01 20:12:29.579389	\N	\N	4	0	h-win	yes
583	1410044	2025-07-31	World	UEFA Europa Conference League	Kalju Nomme	St Patrick's Athl.	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:29.779439	\N	\N	1	0	h-win	yes
584	1410047	2025-07-31	World	UEFA Europa Conference League	AIK Stockholm	Paide	h-win	6	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:30.009669	\N	\N	3	0	h-win	yes
585	1410049	2025-07-31	World	UEFA Europa Conference League	Torpedo Kutaisi	Omonia Nicosia	a-win	0	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:30.27902	\N	\N	0	1	a-win	yes
586	1410046	2025-07-31	World	UEFA Europa Conference League	Milsami Orhei	Buducnost Podgorica	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:30.467422	\N	\N	0	0	draw	yes
587	1383526	2025-07-31	World	UEFA Europa Conference League	UNA Strassen	Dundee Utd	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:30.622319	\N	\N	0	0	draw	yes
588	1383534	2025-07-31	World	UEFA Europa Conference League	Universitatea Cluj	Ararat-Armenia	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:30.791267	\N	\N	1	0	h-win	yes
589	1383509	2025-07-31	World	UEFA Europa Conference League	Zimbru	FC Astana	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:30.957552	\N	\N	0	2	a-win	yes
590	1383533	2025-07-31	World	UEFA Europa Conference League	Brondby	HB	h-win	1	0	28	5	10	2	12	1	2	0	0	2	0	0	66.00	34.00	9	12	\N	\N	\N	\N	\N	2025-12-01 20:12:31.103604	\N	\N	1	0	h-win	yes
591	1383539	2025-07-31	World	UEFA Europa Conference League	Universitatea Craiova	FK Sarajevo	h-win	4	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:31.272965	\N	\N	0	0	draw	yes
592	1410050	2025-07-31	World	UEFA Europa Conference League	Beitar Jerusalem	Sutjeska	h-win	5	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:31.450598	\N	\N	2	2	draw	yes
593	1383527	2025-07-31	World	UEFA Europa Conference League	Başakşehir	Cherno More Varna	h-win	4	0	13	6	10	4	4	8	0	1	0	3	0	0	70.00	30.00	7	10	\N	\N	\N	\N	\N	2025-12-01 20:12:31.625419	\N	\N	3	0	h-win	yes
594	1383531	2025-07-31	World	UEFA Europa Conference League	Santa Clara	NK Varazdin	h-win	2	0	0	6	0	3	11	3	2	2	2	4	0	0	51.00	49.00	19	17	\N	\N	\N	\N	\N	2025-12-01 20:12:31.78674	\N	\N	1	0	h-win	yes
595	1383529	2025-07-31	World	UEFA Europa Conference League	KA Akureyri	Silkeborg	a-win	2	3	21	7	22	7	5	5	0	3	3	1	0	0	37.00	63.00	16	19	\N	\N	\N	\N	\N	2025-12-01 20:12:31.96734	\N	\N	1	0	h-win	yes
596	1410038	2025-07-31	World	UEFA Europa Conference League	Neman	FK Košice	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:32.147102	\N	\N	0	0	draw	yes
597	1410052	2025-07-31	World	UEFA Europa Conference League	Maribor	Paks	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:32.348681	\N	\N	1	0	h-win	yes
598	1410053	2025-07-31	World	UEFA Europa Conference League	Hapoel Beer Sheva	AEK Athens FC	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:32.571964	\N	\N	0	0	draw	yes
599	1410054	2025-07-31	World	UEFA Europa Conference League	Sparta Praha	Aktobe	h-win	4	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:32.743776	\N	\N	0	0	draw	yes
600	1410057	2025-07-31	World	UEFA Europa Conference League	Prishtina	Larne	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:32.911756	\N	\N	1	0	h-win	yes
601	1383535	2025-07-31	World	UEFA Europa Conference League	Charleroi	Hammarby FF	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:33.066789	\N	\N	0	1	a-win	yes
602	1383523	2025-07-31	World	UEFA Europa Conference League	Puskas Academy	Aris	a-win	0	2	6	1	21	9	4	7	3	0	4	1	1	0	48.00	52.00	12	18	\N	\N	\N	\N	\N	2025-12-01 20:12:33.231589	\N	\N	0	0	draw	yes
603	1410056	2025-07-31	World	UEFA Europa Conference League	Maccabi Haifa	Torpedo Zhodino	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:33.404262	\N	\N	2	0	h-win	yes
604	1410055	2025-07-31	World	UEFA Europa Conference League	Koper	Viking	a-win	3	5	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:33.619756	\N	\N	2	1	h-win	yes
605	1383538	2025-07-31	World	UEFA Europa Conference League	Jagiellonia	Novi Pazar	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:33.811461	\N	\N	0	0	draw	yes
606	1410058	2025-07-31	World	UEFA Europa Conference League	Lausanne	Vardar Skopje	h-win	5	0	16	9	8	3	4	3	1	5	2	1	0	0	57.00	43.00	12	13	\N	\N	\N	\N	\N	2025-12-01 20:12:34.020277	\N	\N	3	0	h-win	yes
607	1383525	2025-07-31	World	UEFA Europa Conference League	Aris Thessalonikis	Araz	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.196058	\N	\N	0	2	a-win	yes
608	1410059	2025-07-31	World	UEFA Europa Conference League	Valur Reykjavik	Kauno Žalgiris	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.36675	\N	\N	1	1	draw	yes
609	1410060	2025-07-31	World	UEFA Europa Conference League	Rapid Vienna	Dečić	h-win	4	2	26	7	10	3	6	5	2	0	0	1	0	0	64.00	36.00	6	7	\N	\N	\N	\N	\N	2025-12-01 20:12:34.570495	\N	\N	2	0	h-win	yes
610	1383536	2025-07-31	World	UEFA Europa Conference League	Žilina	Raków Częstochowa	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.577653	\N	\N	1	1	draw	yes
611	1410062	2025-07-31	World	UEFA Europa Conference League	Vikingur Reykjavik	Vllaznia Shkodër	h-win	4	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.582788	\N	\N	1	1	draw	yes
612	1410061	2025-07-31	World	UEFA Europa Conference League	Linfield	FK Zalgiris Vilnius	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.589831	\N	\N	2	0	h-win	yes
613	1410064	2025-07-31	World	UEFA Europa Conference League	KI Klaksvik	Radnicki 1923	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.5947	\N	\N	1	0	h-win	yes
614	1410063	2025-07-31	World	UEFA Europa Conference League	Dinamo Tirana	Atlètic Club d'Escaldes	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.602189	\N	\N	1	0	h-win	yes
615	1410051	2025-07-31	World	UEFA Europa Conference League	Floriana	Ballkani	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.607116	\N	\N	1	1	draw	yes
616	1383528	2025-07-31	World	UEFA Europa Conference League	Dungannon Swifts	FC Vaduz	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.611881	\N	\N	0	0	draw	yes
617	1410065	2025-07-31	World	UEFA Europa Conference League	FK Partizan	Oleksandria	h-win	4	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.619114	\N	\N	3	0	h-win	yes
618	1383530	2025-07-31	World	UEFA Europa Conference League	HNK Hajduk Split	Zira	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.624241	\N	\N	1	0	h-win	yes
619	1410066	2025-07-31	World	UEFA Europa Conference League	Shamrock Rovers	St Joseph S Fc	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.633116	\N	\N	0	0	draw	yes
620	1410067	2025-07-31	World	UEFA Europa Conference League	Egnatia Rrogozhinë	Dinamo Minsk	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.639151	\N	\N	0	0	draw	yes
621	1421174	2025-08-05	World	UEFA Europa Conference League	KI Klaksvik	Neman	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.645077	\N	\N	2	0	h-win	yes
622	1423750	2025-08-07	World	UEFA Europa Conference League	Rosenborg	Hammarby FF	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.653366	\N	\N	0	0	draw	yes
623	1421160	2025-08-07	World	UEFA Europa Conference League	Milsami Orhei	Virtus	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.659197	\N	\N	1	0	h-win	yes
624	1421172	2025-08-07	World	UEFA Europa Conference League	Aris	AEK Athens FC	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.670789	\N	\N	2	2	draw	yes
625	1421167	2025-08-07	World	UEFA Europa Conference League	Kauno Žalgiris	Arda Kardzhali	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.676938	\N	\N	0	0	draw	yes
626	1421175	2025-08-07	World	UEFA Europa Conference League	Araz	Omonia Nicosia	a-win	0	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.683978	\N	\N	0	2	a-win	yes
627	1421169	2025-08-07	World	UEFA Europa Conference League	Baník Ostrava	Austria Vienna	h-win	4	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.688581	\N	\N	2	1	h-win	yes
628	1421155	2025-08-07	World	UEFA Europa Conference League	AIK Stockholm	Gyori ETO FC	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.695356	\N	\N	2	0	h-win	yes
629	1421163	2025-08-07	World	UEFA Europa Conference League	Viking	Başakşehir	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.700086	\N	\N	1	0	h-win	yes
630	1421162	2025-08-07	World	UEFA Europa Conference League	Silkeborg	Jagiellonia	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.704644	\N	\N	0	1	a-win	yes
631	1421156	2025-08-07	World	UEFA Europa Conference League	Riga	Beitar Jerusalem	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.71168	\N	\N	0	0	draw	yes
632	1421158	2025-08-07	World	UEFA Europa Conference League	AZ Alkmaar	FC Vaduz	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.716693	\N	\N	1	0	h-win	yes
633	1421178	2025-08-07	World	UEFA Europa Conference League	Anderlecht	Sheriff Tiraspol	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.720976	\N	\N	1	0	h-win	yes
634	1421170	2025-08-07	World	UEFA Europa Conference League	Vikingur Gota	Linfield	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.727911	\N	\N	1	1	draw	yes
635	1421168	2025-08-07	World	UEFA Europa Conference League	Sparta Praha	Ararat-Armenia	h-win	4	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.732712	\N	\N	2	1	h-win	yes
636	1421173	2025-08-07	World	UEFA Europa Conference League	Levski Sofia	Sabah FA	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.737441	\N	\N	0	0	draw	yes
637	1421179	2025-08-07	World	UEFA Europa Conference League	Olimpija Ljubljana	Egnatia Rrogozhinë	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.745089	\N	\N	0	0	draw	yes
638	1419570	2025-08-07	World	UEFA Europa Conference League	FC Differdange 03	FC Levadia Tallinn	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.749969	\N	\N	1	2	a-win	yes
639	1421153	2025-08-07	World	UEFA Europa Conference League	Polessya	Paks	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.75476	\N	\N	2	0	h-win	yes
640	1421159	2025-08-07	World	UEFA Europa Conference League	Lausanne	FC Astana	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.761579	\N	\N	2	0	h-win	yes
641	1421157	2025-08-07	World	UEFA Europa Conference League	FC Lugano	Celje	a-win	0	5	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.766402	\N	\N	0	2	a-win	yes
642	1421154	2025-08-07	World	UEFA Europa Conference League	Universitatea Craiova	Spartak Trnava	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.773099	\N	\N	0	0	draw	yes
643	1421161	2025-08-07	World	UEFA Europa Conference League	Ballkani	Shamrock Rovers	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.778272	\N	\N	0	0	draw	yes
644	1421164	2025-08-07	World	UEFA Europa Conference League	Vikingur Reykjavik	Brondby	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.783097	\N	\N	1	0	h-win	yes
645	1421176	2025-08-07	World	UEFA Europa Conference League	St Patrick's Athl.	Beşiktaş	a-win	1	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.78992	\N	\N	0	4	a-win	yes
646	1421171	2025-08-07	World	UEFA Europa Conference League	FK Partizan	Hibernian	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.794848	\N	\N	0	1	a-win	yes
647	1421180	2025-08-07	World	UEFA Europa Conference League	HNK Hajduk Split	Dinamo Tirana	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.799921	\N	\N	0	1	a-win	yes
648	1421177	2025-08-07	World	UEFA Europa Conference League	Rapid Vienna	Dundee Utd	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.807328	\N	\N	2	1	h-win	yes
649	1421166	2025-08-07	World	UEFA Europa Conference League	Raków Częstochowa	Maccabi Haifa	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.812267	\N	\N	0	0	draw	yes
650	1421165	2025-08-07	World	UEFA Europa Conference League	Larne	Santa Clara	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.817115	\N	\N	0	3	a-win	yes
651	1421208	2025-08-13	World	UEFA Europa Conference League	Başakşehir	Viking	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.823501	\N	\N	1	1	draw	yes
652	1421188	2025-08-14	World	UEFA Europa Conference League	FC Astana	Lausanne	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.828329	\N	\N	0	0	draw	yes
653	1421197	2025-08-14	World	UEFA Europa Conference League	Ararat-Armenia	Sparta Praha	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.835775	\N	\N	1	1	draw	yes
654	1421207	2025-08-14	World	UEFA Europa Conference League	Sabah FA	Levski Sofia	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.840947	\N	\N	0	1	a-win	yes
655	1419571	2025-08-14	World	UEFA Europa Conference League	FC Levadia Tallinn	FC Differdange 03	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.845701	\N	\N	0	0	draw	yes
656	1421204	2025-08-14	World	UEFA Europa Conference League	Hammarby FF	Rosenborg	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.85313	\N	\N	0	0	draw	yes
657	1421198	2025-08-14	World	UEFA Europa Conference League	Sheriff Tiraspol	Anderlecht	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.857943	\N	\N	0	0	draw	yes
658	1421185	2025-08-14	World	UEFA Europa Conference League	Paks	Polessya	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.863237	\N	\N	1	0	h-win	yes
659	1421201	2025-08-14	World	UEFA Europa Conference League	Gyori ETO FC	AIK Stockholm	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.869819	\N	\N	1	0	h-win	yes
660	1421202	2025-08-14	World	UEFA Europa Conference League	Omonia Nicosia	Araz	h-win	5	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.874637	\N	\N	4	0	h-win	yes
661	1421187	2025-08-14	World	UEFA Europa Conference League	Brondby	Vikingur Reykjavik	h-win	4	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.879475	\N	\N	1	0	h-win	yes
662	1421196	2025-08-14	World	UEFA Europa Conference League	Beitar Jerusalem	Riga	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.886252	\N	\N	2	0	h-win	yes
663	1421186	2025-08-14	World	UEFA Europa Conference League	FC Vaduz	AZ Alkmaar	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.891222	\N	\N	0	0	draw	yes
664	1421192	2025-08-14	World	UEFA Europa Conference League	Arda Kardzhali	Kauno Žalgiris	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.898131	\N	\N	2	0	h-win	yes
665	1421189	2025-08-14	World	UEFA Europa Conference League	Neman	KI Klaksvik	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.903401	\N	\N	0	0	draw	yes
666	1421184	2025-08-14	World	UEFA Europa Conference League	Beşiktaş	St Patrick's Athl.	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.908808	\N	\N	1	2	a-win	yes
667	1421203	2025-08-14	World	UEFA Europa Conference League	AEK Athens FC	Aris	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.915783	\N	\N	0	0	draw	yes
668	1421182	2025-08-14	World	UEFA Europa Conference League	Maccabi Haifa	Raków Częstochowa	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.921155	\N	\N	0	1	a-win	yes
669	1421181	2025-08-14	World	UEFA Europa Conference League	Celje	FC Lugano	a-win	2	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.92617	\N	\N	1	1	draw	yes
670	1421183	2025-08-14	World	UEFA Europa Conference League	Jagiellonia	Silkeborg	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.932769	\N	\N	2	0	h-win	yes
671	1421199	2025-08-14	World	UEFA Europa Conference League	Spartak Trnava	Universitatea Craiova	h-win	4	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.937887	\N	\N	1	1	draw	yes
672	1423751	2025-08-14	World	UEFA Europa Conference League	Linfield	Vikingur Gota	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.94465	\N	\N	2	0	h-win	yes
673	1421195	2025-08-14	World	UEFA Europa Conference League	Dundee Utd	Rapid Vienna	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.949541	\N	\N	2	0	h-win	yes
674	1421205	2025-08-14	World	UEFA Europa Conference League	Dinamo Tirana	HNK Hajduk Split	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.954673	\N	\N	1	0	h-win	yes
675	1421191	2025-08-14	World	UEFA Europa Conference League	Santa Clara	Larne	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.961646	\N	\N	0	0	draw	yes
676	1421200	2025-08-14	World	UEFA Europa Conference League	Hibernian	FK Partizan	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.9665	\N	\N	0	2	a-win	yes
677	1421193	2025-08-14	World	UEFA Europa Conference League	Austria Vienna	Baník Ostrava	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.971328	\N	\N	0	1	a-win	yes
678	1421190	2025-08-14	World	UEFA Europa Conference League	Shamrock Rovers	Ballkani	h-win	4	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.978303	\N	\N	1	0	h-win	yes
679	1421206	2025-08-14	World	UEFA Europa Conference League	Egnatia Rrogozhinë	Olimpija Ljubljana	a-win	2	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.983081	\N	\N	1	1	draw	yes
680	1421194	2025-08-14	World	UEFA Europa Conference League	Virtus	Milsami Orhei	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.987895	\N	\N	0	0	draw	yes
681	1438686	2025-08-21	World	UEFA Europa Conference League	Rosenborg	FSV Mainz 05	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:34.995247	\N	\N	1	1	draw	yes
682	1438687	2025-08-21	World	UEFA Europa Conference League	BK Hacken	CFR 1907 Cluj	h-win	7	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.000073	\N	\N	4	1	h-win	yes
683	1438688	2025-08-21	World	UEFA Europa Conference League	Wolfsberger AC	Omonia Nicosia	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.004881	\N	\N	1	1	draw	yes
684	1438690	2025-08-21	World	UEFA Europa Conference League	Gyori ETO FC	Rapid Vienna	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.011754	\N	\N	0	0	draw	yes
685	1438689	2025-08-21	World	UEFA Europa Conference League	Hamrun Spartans	Rīgas FS	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.016597	\N	\N	0	0	draw	yes
686	1438691	2025-08-21	World	UEFA Europa Conference League	Başakşehir	Universitatea Craiova	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.023372	\N	\N	0	1	a-win	yes
687	1438698	2025-08-21	World	UEFA Europa Conference League	Strasbourg	Brondby	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.028472	\N	\N	0	0	draw	yes
688	1438701	2025-08-21	World	UEFA Europa Conference League	Breidablik	Virtus	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.033208	\N	\N	1	1	draw	yes
689	1438696	2025-08-21	World	UEFA Europa Conference League	Neman	Rayo Vallecano	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.040133	\N	\N	0	0	draw	yes
690	1438695	2025-08-21	World	UEFA Europa Conference League	Shakhtar Donetsk	Servette FC	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.045252	\N	\N	0	1	a-win	yes
691	1438693	2025-08-21	World	UEFA Europa Conference League	Anderlecht	AEK Athens FC	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.050722	\N	\N	1	0	h-win	yes
692	1438697	2025-08-21	World	UEFA Europa Conference League	Sparta Praha	Riga	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.058486	\N	\N	1	0	h-win	yes
693	1438694	2025-08-21	World	UEFA Europa Conference League	Levski Sofia	AZ Alkmaar	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.063486	\N	\N	0	0	draw	yes
694	1438699	2025-08-21	World	UEFA Europa Conference League	Olimpija Ljubljana	FC Noah	a-win	1	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.070388	\N	\N	0	2	a-win	yes
695	1438700	2025-08-21	World	UEFA Europa Conference League	Celje	Baník Ostrava	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.075317	\N	\N	1	0	h-win	yes
696	1438692	2025-08-21	World	UEFA Europa Conference League	Polessya	Fiorentina	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.080211	\N	\N	0	2	a-win	yes
697	1438702	2025-08-21	World	UEFA Europa Conference League	Drita	FC Differdange 03	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.087153	\N	\N	1	0	h-win	yes
698	1438704	2025-08-21	World	UEFA Europa Conference League	Jagiellonia	Dinamo Tirana	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.091988	\N	\N	2	0	h-win	yes
699	1438703	2025-08-21	World	UEFA Europa Conference League	Lausanne	Beşiktaş	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.097047	\N	\N	0	1	a-win	yes
700	1438705	2025-08-21	World	UEFA Europa Conference League	Shelbourne	Linfield	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.103904	\N	\N	1	0	h-win	yes
701	1438706	2025-08-21	World	UEFA Europa Conference League	Crystal Palace	Fredrikstad	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.108867	\N	\N	0	0	draw	yes
702	1438708	2025-08-21	World	UEFA Europa Conference League	Santa Clara	Shamrock Rovers	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.113844	\N	\N	1	1	draw	yes
703	1438707	2025-08-21	World	UEFA Europa Conference League	Hibernian	Legia Warszawa	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.120684	\N	\N	0	2	a-win	yes
704	1438709	2025-08-21	World	UEFA Europa Conference League	Raków Częstochowa	Arda Kardzhali	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.125536	\N	\N	1	0	h-win	yes
705	1438710	2025-08-27	World	UEFA Europa Conference League	Riga	Sparta Praha	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.130298	\N	\N	0	0	draw	yes
706	1438711	2025-08-28	World	UEFA Europa Conference League	Fredrikstad	Crystal Palace	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.137461	\N	\N	0	0	draw	yes
707	1438713	2025-08-28	World	UEFA Europa Conference League	Omonia Nicosia	Wolfsberger AC	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.142319	\N	\N	1	0	h-win	yes
708	1438712	2025-08-28	World	UEFA Europa Conference League	FC Noah	Olimpija Ljubljana	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.149194	\N	\N	2	0	h-win	yes
709	1438714	2025-08-28	World	UEFA Europa Conference League	Beşiktaş	Lausanne	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.154206	\N	\N	0	1	a-win	yes
710	1438815	2025-08-28	World	UEFA Europa Conference League	Rapid Vienna	Gyori ETO FC	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.158996	\N	\N	1	0	h-win	yes
711	1438715	2025-08-28	World	UEFA Europa Conference League	Rīgas FS	Hamrun Spartans	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.166499	\N	\N	1	1	draw	yes
712	1438816	2025-08-28	World	UEFA Europa Conference League	AZ Alkmaar	Levski Sofia	h-win	4	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.171566	\N	\N	3	0	h-win	yes
713	1438818	2025-08-28	World	UEFA Europa Conference League	Universitatea Craiova	Başakşehir	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.176645	\N	\N	2	1	h-win	yes
714	1438817	2025-08-28	World	UEFA Europa Conference League	CFR 1907 Cluj	BK Hacken	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.183505	\N	\N	0	0	draw	yes
715	1438822	2025-08-28	World	UEFA Europa Conference League	Brondby	Strasbourg	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.18852	\N	\N	1	2	a-win	yes
716	1438819	2025-08-28	World	UEFA Europa Conference League	Fiorentina	Polessya	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.195249	\N	\N	0	2	a-win	yes
717	1438820	2025-08-28	World	UEFA Europa Conference League	AEK Athens FC	Anderlecht	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.200303	\N	\N	1	0	h-win	yes
718	1438825	2025-08-28	World	UEFA Europa Conference League	FC Differdange 03	Drita	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.205384	\N	\N	0	0	draw	yes
719	1438821	2025-08-28	World	UEFA Europa Conference League	Rayo Vallecano	Neman	h-win	4	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.21226	\N	\N	0	0	draw	yes
720	1438823	2025-08-28	World	UEFA Europa Conference League	Arda Kardzhali	Raków Częstochowa	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.217056	\N	\N	0	1	a-win	yes
721	1438824	2025-08-28	World	UEFA Europa Conference League	Baník Ostrava	Celje	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.222517	\N	\N	0	2	a-win	yes
722	1438827	2025-08-28	World	UEFA Europa Conference League	Linfield	Shelbourne	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.229679	\N	\N	0	2	a-win	yes
723	1438826	2025-08-28	World	UEFA Europa Conference League	Dinamo Tirana	Jagiellonia	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.234567	\N	\N	0	0	draw	yes
724	1438829	2025-08-28	World	UEFA Europa Conference League	FSV Mainz 05	Rosenborg	h-win	4	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.241671	\N	\N	3	1	h-win	yes
725	1438830	2025-08-28	World	UEFA Europa Conference League	Legia Warszawa	Hibernian	draw	3	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.246656	\N	\N	1	0	h-win	yes
726	1438831	2025-08-28	World	UEFA Europa Conference League	Shamrock Rovers	Santa Clara	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.251401	\N	\N	0	0	draw	yes
727	1438828	2025-08-28	World	UEFA Europa Conference League	Servette FC	Shakhtar Donetsk	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.258475	\N	\N	0	0	draw	yes
728	1438832	2025-08-28	World	UEFA Europa Conference League	Virtus	Breidablik	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.263303	\N	\N	1	1	draw	yes
729	1451357	2025-10-02	World	UEFA Europa Conference League	Jagiellonia	Hamrun Spartans	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.26804	\N	\N	0	0	draw	yes
730	1451356	2025-10-02	World	UEFA Europa Conference League	Lech Poznan	Rapid Vienna	h-win	4	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.275268	\N	\N	3	0	h-win	yes
731	1451358	2025-10-02	World	UEFA Europa Conference League	Dynamo Kyiv	Crystal Palace	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.280703	\N	\N	0	1	a-win	yes
732	1451354	2025-10-02	World	UEFA Europa Conference League	Zrinjski	Lincoln Red Imps FC	h-win	5	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.287316	\N	\N	3	0	h-win	yes
733	1451361	2025-10-02	World	UEFA Europa Conference League	Rayo Vallecano	Shkendija	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.292559	\N	\N	2	0	h-win	yes
734	1452158	2025-10-02	World	UEFA Europa Conference League	Lausanne	Breidablik	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.297376	\N	\N	3	0	h-win	yes
735	1451359	2025-10-02	World	UEFA Europa Conference League	KuPS	Drita	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.304544	\N	\N	0	0	draw	yes
736	1451355	2025-10-02	World	UEFA Europa Conference League	Omonia Nicosia	FSV Mainz 05	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.309617	\N	\N	0	0	draw	yes
737	1451360	2025-10-02	World	UEFA Europa Conference League	FC Noah	HNK Rijeka	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.314406	\N	\N	1	0	h-win	yes
738	1451363	2025-10-02	World	UEFA Europa Conference League	Aberdeen	Shakhtar Donetsk	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.321271	\N	\N	1	1	draw	yes
739	1451364	2025-10-02	World	UEFA Europa Conference League	Legia Warszawa	Samsunspor	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.326324	\N	\N	0	1	a-win	yes
740	1451365	2025-10-02	World	UEFA Europa Conference League	Fiorentina	Sigma Olomouc	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.331861	\N	\N	1	0	h-win	yes
741	1451367	2025-10-02	World	UEFA Europa Conference League	AEK Larnaca	AZ Alkmaar	h-win	4	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.337951	\N	\N	1	0	h-win	yes
742	1451369	2025-10-02	World	UEFA Europa Conference League	Sparta Praha	Shamrock Rovers	h-win	4	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.342752	\N	\N	2	0	h-win	yes
743	1452159	2025-10-02	World	UEFA Europa Conference League	Slovan Bratislava	Strasbourg	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.349734	\N	\N	0	2	a-win	yes
744	1451366	2025-10-02	World	UEFA Europa Conference League	Raków Częstochowa	Universitatea Craiova	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.354722	\N	\N	0	0	draw	yes
745	1451362	2025-10-02	World	UEFA Europa Conference League	Shelbourne	BK Hacken	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.359504	\N	\N	0	0	draw	yes
746	1451368	2025-10-02	World	UEFA Europa Conference League	Celje	AEK Athens FC	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.367406	\N	\N	1	1	draw	yes
747	1451373	2025-10-23	World	UEFA Europa Conference League	Strasbourg	Jagiellonia	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.372217	\N	\N	0	0	draw	yes
748	1451378	2025-10-23	World	UEFA Europa Conference League	AZ Alkmaar	Slovan Bratislava	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.376992	\N	\N	1	0	h-win	yes
749	1451370	2025-10-23	World	UEFA Europa Conference League	Breidablik	KuPS	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.383831	\N	\N	0	0	draw	yes
750	1451371	2025-10-23	World	UEFA Europa Conference League	BK Hacken	Rayo Vallecano	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.388739	\N	\N	1	1	draw	yes
751	1451376	2025-10-23	World	UEFA Europa Conference League	Shakhtar Donetsk	Legia Warszawa	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.394304	\N	\N	0	1	a-win	yes
752	1452160	2025-10-23	World	UEFA Europa Conference League	AEK Athens FC	Aberdeen	h-win	6	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.400968	\N	\N	3	0	h-win	yes
753	1451375	2025-10-23	World	UEFA Europa Conference League	Shkendija	Shelbourne	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.405806	\N	\N	0	0	draw	yes
754	1451374	2025-10-23	World	UEFA Europa Conference League	Rapid Vienna	Fiorentina	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.412657	\N	\N	0	1	a-win	yes
755	1451377	2025-10-23	World	UEFA Europa Conference League	Drita	Omonia Nicosia	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.417808	\N	\N	1	1	draw	yes
756	1451385	2025-10-23	World	UEFA Europa Conference League	Crystal Palace	AEK Larnaca	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.422728	\N	\N	0	0	draw	yes
757	1451383	2025-10-23	World	UEFA Europa Conference League	FSV Mainz 05	Zrinjski	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.429631	\N	\N	1	0	h-win	yes
758	1451381	2025-10-23	World	UEFA Europa Conference League	Universitatea Craiova	FC Noah	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.434741	\N	\N	1	0	h-win	yes
759	1451386	2025-10-23	World	UEFA Europa Conference League	Shamrock Rovers	Celje	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.43957	\N	\N	0	2	a-win	yes
760	1451379	2025-10-23	World	UEFA Europa Conference League	Lincoln Red Imps FC	Lech Poznan	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.44651	\N	\N	1	0	h-win	yes
761	1451380	2025-10-23	World	UEFA Europa Conference League	Sigma Olomouc	Raków Częstochowa	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.451822	\N	\N	0	0	draw	yes
762	1451382	2025-10-23	World	UEFA Europa Conference League	Samsunspor	Dynamo Kyiv	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.456649	\N	\N	2	0	h-win	yes
763	1451384	2025-10-23	World	UEFA Europa Conference League	Hamrun Spartans	Lausanne	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.463272	\N	\N	0	1	a-win	yes
764	1451372	2025-10-24	World	UEFA Europa Conference League	HNK Rijeka	Sparta Praha	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.468081	\N	\N	0	0	draw	yes
765	1451394	2025-11-06	World	UEFA Europa Conference League	FSV Mainz 05	Fiorentina	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.47686	\N	\N	0	1	a-win	yes
766	1451388	2025-11-06	World	UEFA Europa Conference League	Shakhtar Donetsk	Breidablik	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.483211	\N	\N	1	0	h-win	yes
767	1451387	2025-11-06	World	UEFA Europa Conference League	AEK Athens FC	Shamrock Rovers	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.492361	\N	\N	0	1	a-win	yes
768	1451392	2025-11-06	World	UEFA Europa Conference League	AEK Larnaca	Aberdeen	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.498611	\N	\N	0	0	draw	yes
769	1451390	2025-11-06	World	UEFA Europa Conference League	Sparta Praha	Raków Częstochowa	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.506736	\N	\N	0	0	draw	yes
770	1452161	2025-11-06	World	UEFA Europa Conference League	KuPS	Slovan Bratislava	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.513182	\N	\N	1	1	draw	yes
771	1451393	2025-11-06	World	UEFA Europa Conference League	Samsunspor	Hamrun Spartans	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.52165	\N	\N	1	0	h-win	yes
772	1451389	2025-11-06	World	UEFA Europa Conference League	FC Noah	Sigma Olomouc	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.528121	\N	\N	1	2	a-win	yes
773	1451391	2025-11-06	World	UEFA Europa Conference League	Celje	Legia Warszawa	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.534316	\N	\N	0	1	a-win	yes
774	1451401	2025-11-06	World	UEFA Europa Conference League	Crystal Palace	AZ Alkmaar	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.543513	\N	\N	2	0	h-win	yes
775	1451399	2025-11-06	World	UEFA Europa Conference League	BK Hacken	Strasbourg	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.550235	\N	\N	0	1	a-win	yes
776	1451397	2025-11-06	World	UEFA Europa Conference League	Dynamo Kyiv	Zrinjski	h-win	6	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.559001	\N	\N	1	0	h-win	yes
777	1451396	2025-11-06	World	UEFA Europa Conference League	Shkendija	Jagiellonia	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.565156	\N	\N	0	0	draw	yes
778	1451398	2025-11-06	World	UEFA Europa Conference League	Lincoln Red Imps FC	HNK Rijeka	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.573149	\N	\N	0	1	a-win	yes
779	1451402	2025-11-06	World	UEFA Europa Conference League	Rayo Vallecano	Lech Poznan	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.579602	\N	\N	0	2	a-win	yes
780	1451403	2025-11-06	World	UEFA Europa Conference League	Rapid Vienna	Universitatea Craiova	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.587774	\N	\N	0	1	a-win	yes
781	1451395	2025-11-06	World	UEFA Europa Conference League	Lausanne	Omonia Nicosia	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.594388	\N	\N	1	1	draw	yes
782	1451400	2025-11-06	World	UEFA Europa Conference League	Shelbourne	Drita	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 20:12:35.602607	\N	\N	0	0	draw	yes
783	1380386	2025-07-18	Poland	Ekstraklasa	Jagiellonia	Nieciecza	a-win	0	4	13	4	18	6	3	8	4	1	1	0	0	0	64.00	36.00	7	10	\N	\N	\N	\N	\N	2025-12-01 21:06:37.93583	1.00	2.40	0	3	a-win	yes
784	1380387	2025-07-18	Poland	Ekstraklasa	Lech Poznan	Cracovia Krakow	a-win	1	4	10	2	7	5	5	0	3	1	1	2	0	0	75.00	25.00	10	12	\N	\N	\N	\N	\N	2025-12-01 21:06:38.098769	1.10	1.01	1	2	a-win	yes
785	1380391	2025-07-19	Poland	Ekstraklasa	Widzew Łódź	Zaglebie Lubin	h-win	1	0	15	4	11	2	8	6	1	3	3	4	0	0	53.00	47.00	8	20	\N	\N	\N	\N	\N	2025-12-01 21:06:38.265238	0.53	0.65	1	0	h-win	yes
786	1380392	2025-07-19	Poland	Ekstraklasa	Wisla Plock	Korona Kielce	h-win	2	0	22	8	5	1	7	1	1	4	1	3	0	2	64.00	36.00	12	13	\N	\N	\N	\N	\N	2025-12-01 21:06:38.43554	3.08	0.09	1	0	h-win	yes
787	1380384	2025-07-19	Poland	Ekstraklasa	GKS Katowice	Raków Częstochowa	a-win	0	1	3	0	18	4	3	6	2	0	1	1	0	0	49.00	51.00	7	14	\N	\N	\N	\N	\N	2025-12-01 21:06:38.634548	0.23	2.38	0	0	draw	yes
788	1380385	2025-07-20	Poland	Ekstraklasa	Gornik Zabrze	Lechia Gdansk	h-win	2	1	21	6	15	6	6	3	1	1	1	1	0	0	53.00	47.00	8	10	\N	\N	\N	\N	\N	2025-12-01 21:06:38.801089	2.23	2.06	1	0	h-win	yes
789	1380389	2025-07-20	Poland	Ekstraklasa	Motor Lublin	Arka Gdynia	h-win	1	0	17	5	9	1	8	8	3	3	2	4	0	0	60.00	40.00	14	11	\N	\N	\N	\N	\N	2025-12-01 21:06:38.97736	1.83	0.93	0	0	draw	yes
790	1380390	2025-07-20	Poland	Ekstraklasa	Radomiak Radom	Pogon Szczecin	h-win	5	1	15	8	6	1	4	4	2	5	1	1	0	0	43.00	57.00	8	9	\N	\N	\N	\N	\N	2025-12-01 21:06:39.14927	1.19	1.30	1	0	h-win	yes
791	1380394	2025-07-25	Poland	Ekstraklasa	Cracovia Krakow	Nieciecza	h-win	2	0	14	3	7	4	5	6	1	0	3	5	0	0	46.00	54.00	16	16	\N	\N	\N	\N	\N	2025-12-01 21:06:39.329248	1.35	0.68	1	0	h-win	yes
792	1380393	2025-07-25	Poland	Ekstraklasa	Arka Gdynia	Radomiak Radom	draw	1	1	10	4	15	3	5	4	3	2	1	3	0	0	49.00	51.00	16	12	\N	\N	\N	\N	\N	2025-12-01 21:06:39.520446	0.73	0.75	1	0	h-win	yes
793	1380399	2025-07-26	Poland	Ekstraklasa	Piast Gliwice	Gornik Zabrze	a-win	0	1	10	0	8	4	6	2	2	0	2	1	0	0	62.00	38.00	13	8	\N	\N	\N	\N	\N	2025-12-01 21:06:39.757134	0.49	0.38	0	0	draw	yes
794	1380400	2025-07-26	Poland	Ekstraklasa	Pogon Szczecin	Motor Lublin	h-win	4	1	19	5	20	8	6	8	0	1	2	1	0	0	42.00	58.00	11	8	\N	\N	\N	\N	\N	2025-12-01 21:06:40.021834	2.26	1.92	2	1	h-win	yes
795	1380398	2025-07-26	Poland	Ekstraklasa	Lechia Gdansk	Lech Poznan	a-win	3	4	16	7	21	11	9	10	0	0	3	3	0	0	40.00	60.00	13	11	\N	\N	\N	\N	\N	2025-12-01 21:06:40.225575	1.95	3.73	2	0	h-win	yes
796	1380401	2025-07-27	Poland	Ekstraklasa	Raków Częstochowa	Wisla Plock	a-win	1	2	11	3	11	5	6	3	0	1	4	4	0	0	61.00	39.00	17	21	\N	\N	\N	\N	\N	2025-12-01 21:06:40.463514	1.23	2.31	1	1	draw	yes
797	1380396	2025-07-27	Poland	Ekstraklasa	Jagiellonia	Widzew Łódź	h-win	3	2	12	5	18	7	4	2	4	1	2	3	0	0	59.00	41.00	12	18	\N	\N	\N	\N	\N	2025-12-01 21:06:40.757198	1.29	2.33	1	1	draw	yes
798	1380397	2025-07-27	Poland	Ekstraklasa	Korona Kielce	Legia Warszawa	a-win	0	2	18	2	17	5	13	7	0	2	0	1	0	0	52.00	48.00	8	15	\N	\N	\N	\N	\N	2025-12-01 21:06:41.044875	1.29	2.54	0	1	a-win	yes
799	1380395	2025-07-28	Poland	Ekstraklasa	GKS Katowice	Zaglebie Lubin	draw	2	2	20	8	20	3	14	8	1	2	1	1	0	0	56.00	44.00	9	16	\N	\N	\N	\N	\N	2025-12-01 21:06:41.247076	1.75	2.53	0	2	a-win	yes
800	1380410	2025-08-01	Poland	Ekstraklasa	Zaglebie Lubin	Korona Kielce	draw	1	1	8	2	17	5	7	8	1	2	2	2	0	0	46.00	54.00	15	19	\N	\N	\N	\N	\N	2025-12-01 21:06:41.481297	1.11	1.86	0	0	draw	yes
801	1380409	2025-08-01	Poland	Ekstraklasa	Wisla Plock	Piast Gliwice	h-win	2	0	10	3	6	1	8	6	4	0	2	4	0	0	30.00	70.00	10	11	\N	\N	\N	\N	\N	2025-12-01 21:06:41.789246	1.43	0.66	1	0	h-win	yes
802	1380407	2025-08-02	Poland	Ekstraklasa	Nieciecza	Pogon Szczecin	draw	1	1	16	7	12	2	6	9	2	0	0	2	0	0	42.00	58.00	8	14	\N	\N	\N	\N	\N	2025-12-01 21:06:42.106018	1.64	1.26	1	0	h-win	yes
803	1380408	2025-08-02	Poland	Ekstraklasa	Widzew Łódź	GKS Katowice	h-win	3	0	21	4	8	3	8	6	0	2	4	2	0	0	43.00	57.00	6	7	\N	\N	\N	\N	\N	2025-12-01 21:06:42.438132	2.18	1.02	1	0	h-win	yes
804	1380403	2025-08-02	Poland	Ekstraklasa	Lech Poznan	Gornik Zabrze	h-win	2	1	12	5	12	1	6	8	0	1	2	1	0	0	56.00	44.00	9	5	\N	\N	\N	\N	\N	2025-12-01 21:06:42.786049	1.99	0.42	0	0	draw	yes
805	1380402	2025-08-03	Poland	Ekstraklasa	Cracovia Krakow	Lechia Gdansk	draw	2	2	19	6	11	2	5	4	0	0	3	2	0	0	56.00	44.00	13	13	\N	\N	\N	\N	\N	2025-12-01 21:06:43.09223	\N	\N	1	1	draw	yes
806	1380406	2025-08-03	Poland	Ekstraklasa	Radomiak Radom	Raków Częstochowa	h-win	3	1	12	6	12	5	1	7	0	3	3	3	0	0	36.00	64.00	20	14	\N	\N	\N	\N	\N	2025-12-01 21:06:43.418171	\N	\N	0	0	draw	yes
807	1380404	2025-08-03	Poland	Ekstraklasa	Legia Warszawa	Arka Gdynia	draw	0	0	20	3	6	0	13	4	1	1	3	3	0	0	63.00	37.00	19	13	\N	\N	\N	\N	\N	2025-12-01 21:06:43.762017	\N	\N	0	0	draw	yes
808	1380414	2025-08-08	Poland	Ekstraklasa	Korona Kielce	Radomiak Radom	h-win	3	0	13	3	7	3	2	5	3	2	5	3	0	0	43.00	57.00	15	16	\N	\N	\N	\N	\N	2025-12-01 21:06:44.058166	1.88	0.59	2	0	h-win	yes
809	1380412	2025-08-08	Poland	Ekstraklasa	Gornik Zabrze	Nieciecza	a-win	0	1	25	5	7	2	7	2	1	0	3	3	0	0	62.00	38.00	12	15	\N	\N	\N	\N	\N	2025-12-01 21:06:44.32313	1.87	0.66	0	1	a-win	yes
810	1380411	2025-08-09	Poland	Ekstraklasa	Arka Gdynia	Pogon Szczecin	h-win	2	1	11	5	13	3	6	5	1	0	3	3	0	0	44.00	56.00	13	14	\N	\N	\N	\N	\N	2025-12-01 21:06:44.583139	\N	\N	1	1	draw	yes
811	1380419	2025-08-09	Poland	Ekstraklasa	Widzew Łódź	Wisla Plock	draw	1	1	15	6	5	1	5	0	1	1	2	3	0	0	61.00	39.00	7	12	\N	\N	\N	\N	\N	2025-12-01 21:06:44.826054	\N	\N	1	1	draw	yes
812	1380413	2025-08-10	Poland	Ekstraklasa	Jagiellonia	Cracovia Krakow	h-win	5	2	15	8	12	4	10	5	1	1	2	3	0	1	63.00	37.00	14	17	\N	\N	\N	\N	\N	2025-12-01 21:06:45.03603	\N	\N	1	2	a-win	yes
813	1380416	2025-08-10	Poland	Ekstraklasa	Legia Warszawa	GKS Katowice	h-win	3	1	20	7	7	6	5	7	1	1	3	1	0	0	58.00	42.00	11	13	\N	\N	\N	\N	\N	2025-12-01 21:06:45.250103	\N	\N	1	0	h-win	yes
814	1380415	2025-08-11	Poland	Ekstraklasa	Lechia Gdansk	Motor Lublin	draw	3	3	18	9	14	4	3	8	0	2	2	2	0	0	53.00	47.00	11	12	\N	\N	\N	\N	\N	2025-12-01 21:06:45.415155	2.60	0.99	2	2	draw	yes
815	1380428	2025-08-15	Poland	Ekstraklasa	Zaglebie Lubin	Lechia Gdansk	h-win	6	2	22	9	7	2	5	4	1	0	0	0	0	0	41.00	59.00	6	9	\N	\N	\N	\N	\N	2025-12-01 21:06:45.644077	\N	\N	2	1	h-win	yes
816	1380420	2025-08-15	Poland	Ekstraklasa	Cracovia Krakow	Widzew Łódź	h-win	1	0	10	2	12	3	7	8	1	0	2	1	0	0	44.00	56.00	16	11	\N	\N	\N	\N	\N	2025-12-01 21:06:45.902973	\N	\N	0	0	draw	yes
817	1380423	2025-08-16	Poland	Ekstraklasa	Motor Lublin	Piast Gliwice	draw	0	0	8	1	17	4	7	6	4	5	4	2	1	0	41.00	59.00	17	16	\N	\N	\N	\N	\N	2025-12-01 21:06:46.237646	\N	\N	0	0	draw	yes
818	1380421	2025-08-16	Poland	Ekstraklasa	GKS Katowice	Arka Gdynia	h-win	4	1	24	10	12	3	8	5	1	0	1	4	0	0	42.00	58.00	19	12	\N	\N	\N	\N	\N	2025-12-01 21:06:46.640926	\N	\N	2	1	h-win	yes
819	1380422	2025-08-16	Poland	Ekstraklasa	Lech Poznan	Korona Kielce	draw	1	1	18	8	16	2	6	0	2	2	1	1	0	0	65.00	35.00	12	10	\N	\N	\N	\N	\N	2025-12-01 21:06:46.989531	\N	\N	0	0	draw	yes
820	1380424	2025-08-17	Poland	Ekstraklasa	Pogon Szczecin	Gornik Zabrze	a-win	0	3	14	3	20	6	6	9	1	1	2	0	0	0	53.00	47.00	11	16	\N	\N	\N	\N	\N	2025-12-01 21:06:47.237387	\N	\N	0	0	draw	yes
821	1380425	2025-08-17	Poland	Ekstraklasa	Radomiak Radom	Jagiellonia	a-win	1	2	11	5	15	5	6	7	3	3	6	1	0	0	40.00	60.00	21	12	\N	\N	\N	\N	\N	2025-12-01 21:06:47.496174	\N	\N	1	1	draw	yes
822	1380427	2025-08-17	Poland	Ekstraklasa	Wisla Plock	Legia Warszawa	h-win	1	0	10	4	23	3	3	9	1	1	0	1	0	0	34.00	66.00	5	9	\N	\N	\N	\N	\N	2025-12-01 21:06:47.761159	\N	\N	1	0	h-win	yes
823	1380426	2025-08-17	Poland	Ekstraklasa	Nieciecza	Raków Częstochowa	a-win	2	3	9	3	17	10	6	2	1	0	2	4	0	0	47.00	53.00	17	14	\N	\N	\N	\N	\N	2025-12-01 21:06:48.07884	\N	\N	1	1	draw	yes
824	1380434	2025-08-22	Poland	Ekstraklasa	Radomiak Radom	Nieciecza	draw	1	1	17	4	13	2	2	5	3	3	1	2	0	0	62.00	38.00	12	11	\N	\N	\N	\N	\N	2025-12-01 21:06:48.430367	\N	\N	1	1	draw	yes
825	1380436	2025-08-22	Poland	Ekstraklasa	Widzew Łódź	Pogon Szczecin	a-win	1	2	13	4	8	4	2	0	2	2	1	4	1	0	55.00	45.00	5	16	\N	\N	\N	\N	\N	2025-12-01 21:06:48.749239	\N	\N	1	1	draw	yes
826	1380430	2025-08-23	Poland	Ekstraklasa	Korona Kielce	Motor Lublin	h-win	2	0	17	8	13	2	5	6	1	1	4	5	0	0	32.00	68.00	15	13	\N	\N	\N	\N	\N	2025-12-01 21:06:48.992037	\N	\N	0	0	draw	yes
827	1380429	2025-08-23	Poland	Ekstraklasa	Gornik Zabrze	GKS Katowice	h-win	3	0	18	6	10	1	2	4	0	0	0	1	0	0	51.00	49.00	9	11	\N	\N	\N	\N	\N	2025-12-01 21:06:49.267081	\N	\N	1	0	h-win	yes
828	1380433	2025-08-24	Poland	Ekstraklasa	Piast Gliwice	Cracovia Krakow	draw	0	0	14	1	8	2	4	2	1	0	1	0	0	0	60.00	40.00	20	17	\N	\N	\N	\N	\N	2025-12-01 21:06:49.764669	\N	\N	0	0	draw	yes
829	1380431	2025-08-24	Poland	Ekstraklasa	Lechia Gdansk	Arka Gdynia	h-win	1	0	12	3	7	1	4	4	2	0	2	3	0	0	53.00	47.00	10	12	\N	\N	\N	\N	\N	2025-12-01 21:06:50.205991	\N	\N	0	0	draw	yes
830	1380437	2025-08-25	Poland	Ekstraklasa	Wisla Plock	Zaglebie Lubin	h-win	2	1	15	4	8	3	4	3	2	1	1	0	0	0	58.00	42.00	15	9	\N	\N	\N	\N	\N	2025-12-01 21:06:50.684776	1.81	0.39	0	1	a-win	yes
831	1380438	2025-08-29	Poland	Ekstraklasa	Arka Gdynia	Wisla Plock	h-win	1	0	8	2	18	4	0	5	1	1	1	2	0	0	51.00	49.00	12	10	\N	\N	\N	\N	\N	2025-12-01 21:06:51.111889	\N	\N	0	0	draw	yes
832	1380440	2025-08-29	Poland	Ekstraklasa	GKS Katowice	Radomiak Radom	h-win	3	2	18	8	9	4	8	4	3	1	3	6	0	0	47.00	53.00	16	21	\N	\N	\N	\N	\N	2025-12-01 21:06:51.45101	\N	\N	2	2	draw	yes
833	1380445	2025-08-30	Poland	Ekstraklasa	Nieciecza	Korona Kielce	a-win	1	3	8	5	24	9	3	1	2	1	0	2	0	0	46.00	54.00	13	12	\N	\N	\N	\N	\N	2025-12-01 21:06:51.849023	\N	\N	1	0	h-win	yes
834	1380446	2025-08-30	Poland	Ekstraklasa	Zaglebie Lubin	Piast Gliwice	draw	2	2	11	2	15	5	3	5	2	3	3	3	0	0	30.00	70.00	15	9	\N	\N	\N	\N	\N	2025-12-01 21:06:52.193	\N	\N	1	1	draw	yes
835	1380441	2025-08-30	Poland	Ekstraklasa	Gornik Zabrze	Motor Lublin	a-win	0	1	18	3	10	3	10	5	2	1	5	4	0	0	58.00	42.00	9	14	\N	\N	\N	\N	\N	2025-12-01 21:06:52.629473	\N	\N	0	0	draw	yes
836	1380442	2025-08-31	Poland	Ekstraklasa	Jagiellonia	Lechia Gdansk	h-win	2	0	12	4	14	3	1	5	2	0	4	4	0	0	52.00	48.00	13	20	\N	\N	\N	\N	\N	2025-12-01 21:06:52.921928	\N	\N	2	0	h-win	yes
837	1380443	2025-08-31	Poland	Ekstraklasa	Lech Poznan	Widzew Łódź	h-win	2	1	13	5	15	3	5	7	1	6	3	0	0	0	51.00	49.00	10	8	\N	\N	\N	\N	\N	2025-12-01 21:06:53.181068	\N	\N	1	0	h-win	yes
838	1380444	2025-08-31	Poland	Ekstraklasa	Pogon Szczecin	Raków Częstochowa	h-win	2	0	8	3	18	3	1	14	3	2	4	3	0	0	45.00	55.00	16	10	\N	\N	\N	\N	\N	2025-12-01 21:06:53.393002	\N	\N	0	0	draw	yes
839	1380439	2025-08-31	Poland	Ekstraklasa	Cracovia Krakow	Legia Warszawa	h-win	2	1	2	2	13	5	2	5	1	1	4	2	0	0	56.00	44.00	13	17	\N	\N	\N	\N	\N	2025-12-01 21:06:53.637289	\N	\N	1	0	h-win	yes
840	1380448	2025-09-12	Poland	Ekstraklasa	Lechia Gdansk	GKS Katowice	h-win	2	0	13	3	11	3	2	5	0	0	3	1	0	0	42.00	58.00	8	10	\N	\N	\N	\N	\N	2025-12-01 21:06:53.826061	1.77	0.32	1	0	h-win	yes
841	1380449	2025-09-12	Poland	Ekstraklasa	Lech Poznan	Zaglebie Lubin	a-win	1	2	26	6	10	4	7	6	0	4	3	3	0	0	64.00	36.00	11	9	\N	\N	\N	\N	\N	2025-12-01 21:06:54.047996	3.34	0.78	1	1	draw	yes
842	1380447	2025-09-13	Poland	Ekstraklasa	Korona Kielce	Pogon Szczecin	h-win	1	0	17	6	21	10	12	7	5	2	1	1	0	0	45.00	55.00	9	11	\N	\N	\N	\N	\N	2025-12-01 21:06:54.330049	\N	\N	1	0	h-win	yes
843	1380452	2025-09-13	Poland	Ekstraklasa	Piast Gliwice	Jagiellonia	draw	1	1	15	4	11	6	4	1	2	1	6	3	1	0	53.00	47.00	11	13	\N	\N	\N	\N	\N	2025-12-01 21:06:54.540505	\N	\N	0	0	draw	yes
844	1380451	2025-09-14	Poland	Ekstraklasa	Motor Lublin	Nieciecza	draw	1	1	14	2	10	6	5	4	4	1	2	4	0	0	51.00	49.00	16	13	\N	\N	\N	\N	\N	2025-12-01 21:06:54.757024	\N	\N	1	0	h-win	yes
845	1380450	2025-09-14	Poland	Ekstraklasa	Legia Warszawa	Radomiak Radom	h-win	4	1	13	6	12	4	5	5	0	0	1	2	0	0	55.00	45.00	17	15	\N	\N	\N	\N	\N	2025-12-01 21:06:54.955068	\N	\N	1	0	h-win	yes
846	1380454	2025-09-14	Poland	Ekstraklasa	Widzew Łódź	Arka Gdynia	h-win	2	0	14	8	13	5	1	2	1	3	0	1	0	0	49.00	51.00	4	16	\N	\N	\N	\N	\N	2025-12-01 21:06:55.149991	\N	\N	1	0	h-win	yes
847	1380453	2025-09-15	Poland	Ekstraklasa	Raków Częstochowa	Gornik Zabrze	a-win	0	1	9	1	16	7	3	6	2	0	1	6	0	0	67.00	33.00	7	16	\N	\N	\N	\N	\N	2025-12-01 21:06:55.331027	\N	\N	0	1	a-win	yes
848	1380457	2025-09-19	Poland	Ekstraklasa	GKS Katowice	Cracovia Krakow	a-win	0	3	16	5	13	6	11	3	0	0	2	1	0	0	58.00	42.00	6	13	\N	\N	\N	\N	\N	2025-12-01 21:06:55.506982	\N	\N	0	2	a-win	yes
849	1380459	2025-09-19	Poland	Ekstraklasa	Wisla Plock	Jagiellonia	a-win	0	1	17	4	12	9	4	5	3	3	0	2	0	0	41.00	59.00	13	8	\N	\N	\N	\N	\N	2025-12-01 21:06:55.724957	\N	\N	0	0	draw	yes
850	1380461	2025-09-20	Poland	Ekstraklasa	Radomiak Radom	Piast Gliwice	h-win	1	0	16	4	11	2	3	2	1	1	0	1	0	0	40.00	60.00	21	13	\N	\N	\N	\N	\N	2025-12-01 21:06:55.965751	\N	\N	0	0	draw	yes
851	1380456	2025-09-20	Poland	Ekstraklasa	Arka Gdynia	Korona Kielce	draw	0	0	11	3	9	0	4	6	1	0	3	2	0	0	49.00	51.00	12	15	\N	\N	\N	\N	\N	2025-12-01 21:06:56.211067	\N	\N	0	0	draw	yes
852	1380463	2025-09-20	Poland	Ekstraklasa	Nieciecza	Lech Poznan	a-win	0	2	13	2	18	9	3	10	0	2	1	1	0	0	54.00	46.00	7	7	\N	\N	\N	\N	\N	2025-12-01 21:06:56.458156	\N	\N	0	1	a-win	yes
853	1380462	2025-09-20	Poland	Ekstraklasa	Raków Częstochowa	Legia Warszawa	draw	1	1	7	3	16	2	1	2	2	0	1	3	0	0	40.00	60.00	15	18	\N	\N	\N	\N	\N	2025-12-01 21:06:56.755033	\N	\N	1	1	draw	yes
854	1380464	2025-09-21	Poland	Ekstraklasa	Zaglebie Lubin	Motor Lublin	draw	2	2	10	3	15	6	6	5	2	3	3	4	0	0	44.00	56.00	14	15	\N	\N	\N	\N	\N	2025-12-01 21:06:57.067063	\N	\N	1	0	h-win	yes
855	1380460	2025-09-21	Poland	Ekstraklasa	Pogon Szczecin	Lechia Gdansk	a-win	3	4	22	10	12	9	4	4	1	0	3	3	0	0	59.00	41.00	9	11	\N	\N	\N	\N	\N	2025-12-01 21:06:57.406941	\N	\N	2	1	h-win	yes
856	1380458	2025-09-21	Poland	Ekstraklasa	Gornik Zabrze	Widzew Łódź	h-win	3	2	17	7	11	5	6	4	2	0	4	1	0	0	50.00	50.00	16	11	\N	\N	\N	\N	\N	2025-12-01 21:06:57.789259	\N	\N	2	1	h-win	yes
857	1380435	2025-09-24	Poland	Ekstraklasa	Raków Częstochowa	Lech Poznan	draw	2	2	16	7	10	3	6	2	4	1	3	1	0	1	64.00	36.00	10	15	\N	\N	\N	\N	\N	2025-12-01 21:06:58.125792	\N	\N	0	2	a-win	yes
858	1380432	2025-09-24	Poland	Ekstraklasa	Legia Warszawa	Jagiellonia	draw	0	0	20	7	4	1	2	2	0	6	1	3	0	0	51.00	49.00	19	16	\N	\N	\N	\N	\N	2025-12-01 21:06:58.5316	\N	\N	0	0	draw	yes
859	1380472	2025-09-26	Poland	Ekstraklasa	Wisla Plock	GKS Katowice	draw	1	1	11	5	10	5	4	2	1	2	1	1	0	0	46.00	54.00	14	11	\N	\N	\N	\N	\N	2025-12-01 21:06:58.879178	\N	\N	1	0	h-win	yes
860	1380466	2025-09-27	Poland	Ekstraklasa	Korona Kielce	Lechia Gdansk	h-win	3	0	17	7	10	3	6	5	1	0	2	1	0	1	44.00	56.00	12	13	\N	\N	\N	\N	\N	2025-12-01 21:06:59.172794	\N	\N	1	0	h-win	yes
861	1380470	2025-09-27	Poland	Ekstraklasa	Piast Gliwice	Nieciecza	h-win	4	2	20	7	22	7	2	7	1	2	1	3	1	0	48.00	52.00	7	15	\N	\N	\N	\N	\N	2025-12-01 21:06:59.464945	\N	\N	1	2	a-win	yes
862	1380465	2025-09-27	Poland	Ekstraklasa	Cracovia Krakow	Gornik Zabrze	draw	1	1	13	3	10	2	6	7	1	0	1	2	0	0	64.00	36.00	4	10	\N	\N	\N	\N	\N	2025-12-01 21:06:59.75341	\N	\N	0	0	draw	yes
863	1380471	2025-09-28	Poland	Ekstraklasa	Widzew Łódź	Raków Częstochowa	a-win	0	1	6	1	21	6	3	3	3	0	3	4	0	0	38.00	62.00	11	17	\N	\N	\N	\N	\N	2025-12-01 21:07:00.131325	\N	\N	0	0	draw	yes
864	1380467	2025-09-28	Poland	Ekstraklasa	Lech Poznan	Jagiellonia	draw	2	2	13	6	15	3	5	10	0	1	1	4	0	0	53.00	47.00	10	13	\N	\N	\N	\N	\N	2025-12-01 21:07:00.430888	\N	\N	0	1	a-win	yes
865	1380468	2025-09-28	Poland	Ekstraklasa	Legia Warszawa	Pogon Szczecin	h-win	1	0	14	6	6	1	6	1	3	2	2	3	0	0	55.00	45.00	17	15	\N	\N	\N	\N	\N	2025-12-01 21:07:00.609517	\N	\N	1	0	h-win	yes
866	1380473	2025-09-29	Poland	Ekstraklasa	Zaglebie Lubin	Arka Gdynia	h-win	4	0	9	6	9	2	2	2	0	2	0	3	0	0	40.00	60.00	15	16	\N	\N	\N	\N	\N	2025-12-01 21:07:00.817593	\N	\N	4	0	h-win	yes
867	1380469	2025-09-29	Poland	Ekstraklasa	Motor Lublin	Radomiak Radom	draw	2	2	11	4	20	5	5	3	2	0	1	3	0	0	55.00	45.00	10	14	\N	\N	\N	\N	\N	2025-12-01 21:07:01.011704	\N	\N	0	1	a-win	yes
868	1380478	2025-10-03	Poland	Ekstraklasa	Lechia Gdansk	Wisla Plock	draw	1	1	12	5	9	1	3	4	2	0	1	3	0	0	56.00	44.00	7	11	\N	\N	\N	\N	\N	2025-12-01 21:07:01.151902	0.82	0.96	1	0	h-win	yes
869	1380479	2025-10-03	Poland	Ekstraklasa	Pogon Szczecin	Piast Gliwice	h-win	2	1	28	10	8	2	6	1	2	1	2	1	0	0	48.00	52.00	11	16	\N	\N	\N	\N	\N	2025-12-01 21:07:01.283257	5.25	1.06	1	1	draw	yes
870	1380482	2025-10-04	Poland	Ekstraklasa	Nieciecza	Widzew Łódź	a-win	2	4	9	4	14	10	3	4	0	1	1	2	0	0	53.00	47.00	15	16	\N	\N	\N	\N	\N	2025-12-01 21:07:01.45975	0.91	1.88	1	1	draw	yes
871	1380480	2025-10-04	Poland	Ekstraklasa	Radomiak Radom	Zaglebie Lubin	h-win	3	1	17	5	18	7	5	6	1	4	0	3	0	0	50.00	50.00	11	13	\N	\N	\N	\N	\N	2025-12-01 21:07:01.626866	1.86	1.60	2	0	h-win	yes
872	1380474	2025-10-04	Poland	Ekstraklasa	Arka Gdynia	Cracovia Krakow	h-win	2	1	8	3	13	1	4	6	2	2	0	2	0	0	37.00	63.00	20	17	\N	\N	\N	\N	\N	2025-12-01 21:07:01.796375	0.72	1.07	1	0	h-win	yes
873	1380477	2025-10-05	Poland	Ekstraklasa	Jagiellonia	Korona Kielce	h-win	3	1	18	6	14	3	7	7	1	3	1	1	0	0	69.00	31.00	9	10	\N	\N	\N	\N	\N	2025-12-01 21:07:01.977068	2.13	0.93	1	0	h-win	yes
874	1380481	2025-10-05	Poland	Ekstraklasa	Raków Częstochowa	Motor Lublin	h-win	2	0	22	8	5	2	4	5	2	2	1	3	1	0	54.00	46.00	12	15	\N	\N	\N	\N	\N	2025-12-01 21:07:02.147748	3.02	0.36	1	0	h-win	yes
875	1380475	2025-10-05	Poland	Ekstraklasa	GKS Katowice	Lech Poznan	a-win	0	1	14	5	11	3	6	2	4	0	1	3	0	0	43.00	57.00	15	17	\N	\N	\N	\N	\N	2025-12-01 21:07:02.310189	1.82	1.98	0	1	a-win	yes
876	1380476	2025-10-05	Poland	Ekstraklasa	Gornik Zabrze	Legia Warszawa	h-win	3	1	9	6	15	3	0	6	2	0	1	1	0	0	39.00	61.00	10	10	\N	\N	\N	\N	\N	2025-12-01 21:07:02.531837	1.33	1.05	2	0	h-win	yes
877	1380487	2025-10-17	Poland	Ekstraklasa	Motor Lublin	GKS Katowice	a-win	2	5	18	6	15	4	10	2	0	2	2	3	1	0	51.00	49.00	10	14	\N	\N	\N	\N	\N	2025-12-01 21:07:02.767057	1.79	1.83	2	2	draw	yes
878	1380489	2025-10-17	Poland	Ekstraklasa	Widzew Łódź	Radomiak Radom	h-win	3	2	18	6	19	6	2	4	1	4	2	2	0	0	48.00	52.00	18	19	\N	\N	\N	\N	\N	2025-12-01 21:07:03.018684	2.74	1.73	2	1	h-win	yes
879	1380485	2025-10-18	Poland	Ekstraklasa	Korona Kielce	Gornik Zabrze	draw	1	1	12	4	16	3	9	7	3	1	2	0	0	0	43.00	57.00	7	12	\N	\N	\N	\N	\N	2025-12-01 21:07:03.280006	2.35	1.06	1	0	h-win	yes
880	1380484	2025-10-18	Poland	Ekstraklasa	Jagiellonia	Arka Gdynia	h-win	4	0	18	7	8	1	3	5	2	1	1	1	0	0	55.00	45.00	8	10	\N	\N	\N	\N	\N	2025-12-01 21:07:03.635237	2.65	0.78	1	0	h-win	yes
881	1380483	2025-10-18	Poland	Ekstraklasa	Cracovia Krakow	Raków Częstochowa	h-win	2	0	17	4	3	1	5	2	2	2	3	4	0	0	42.00	58.00	17	3	\N	\N	\N	\N	\N	2025-12-01 21:07:03.93222	1.74	0.12	1	0	h-win	yes
882	1380488	2025-10-19	Poland	Ekstraklasa	Piast Gliwice	Lechia Gdansk	a-win	1	2	15	3	9	3	9	6	2	0	2	3	0	0	62.00	38.00	15	9	\N	\N	\N	\N	\N	2025-12-01 21:07:04.221258	\N	\N	0	1	a-win	yes
883	1380486	2025-10-19	Poland	Ekstraklasa	Lech Poznan	Pogon Szczecin	draw	2	2	26	12	16	6	9	4	6	5	1	0	0	0	66.00	34.00	26	16	\N	\N	\N	\N	\N	2025-12-01 21:07:04.503267	2.52	1.78	0	1	a-win	yes
884	1380491	2025-10-19	Poland	Ekstraklasa	Zaglebie Lubin	Legia Warszawa	h-win	3	1	16	5	12	2	3	4	3	1	1	1	0	1	35.00	65.00	16	12	\N	\N	\N	\N	\N	2025-12-01 21:07:04.806292	1.64	0.94	2	0	h-win	yes
885	1380490	2025-10-20	Poland	Ekstraklasa	Wisla Plock	Nieciecza	h-win	3	1	20	7	14	2	6	5	1	2	0	1	0	0	55.00	45.00	6	9	\N	\N	\N	\N	\N	2025-12-01 21:07:05.189144	2.18	2.08	3	0	h-win	yes
886	1380500	2025-10-24	Poland	Ekstraklasa	Nieciecza	Zaglebie Lubin	draw	1	1	14	3	13	6	7	5	1	0	3	2	0	1	54.00	46.00	9	12	\N	\N	\N	\N	\N	2025-12-01 21:07:05.352712	1.12	1.51	0	0	draw	yes
887	1380496	2025-10-24	Poland	Ekstraklasa	Motor Lublin	Widzew Łódź	h-win	3	0	16	5	13	4	5	4	6	1	1	2	0	0	46.00	54.00	8	12	\N	\N	\N	\N	\N	2025-12-01 21:07:05.491275	2.18	0.92	1	0	h-win	yes
888	1380492	2025-10-25	Poland	Ekstraklasa	Arka Gdynia	Piast Gliwice	h-win	2	1	6	3	23	4	4	10	1	0	2	4	0	0	37.00	63.00	17	13	\N	\N	\N	\N	\N	2025-12-01 21:07:05.659845	\N	\N	2	1	h-win	yes
889	1380497	2025-10-25	Poland	Ekstraklasa	Pogon Szczecin	Cracovia Krakow	h-win	2	1	11	3	17	7	8	3	2	0	2	4	0	0	56.00	44.00	10	13	\N	\N	\N	\N	\N	2025-12-01 21:07:05.891816	\N	\N	0	1	a-win	yes
890	1380493	2025-10-25	Poland	Ekstraklasa	GKS Katowice	Korona Kielce	h-win	1	0	14	4	14	3	3	3	2	1	4	3	0	0	40.00	60.00	16	8	\N	\N	\N	\N	\N	2025-12-01 21:07:06.223117	\N	\N	0	0	draw	yes
891	1380499	2025-10-26	Poland	Ekstraklasa	Raków Częstochowa	Lechia Gdansk	h-win	2	1	10	4	10	5	4	4	4	0	2	3	1	0	43.00	57.00	3	17	\N	\N	\N	\N	\N	2025-12-01 21:07:06.481244	\N	\N	1	1	draw	yes
892	1380494	2025-10-26	Poland	Ekstraklasa	Gornik Zabrze	Jagiellonia	h-win	2	1	22	6	15	3	5	4	1	1	0	1	0	0	41.00	59.00	8	6	\N	\N	\N	\N	\N	2025-12-01 21:07:06.747594	\N	\N	1	1	draw	yes
893	1380495	2025-10-26	Poland	Ekstraklasa	Legia Warszawa	Lech Poznan	draw	0	0	13	4	12	2	8	5	1	4	1	2	0	0	48.00	52.00	16	13	\N	\N	\N	\N	\N	2025-12-01 21:07:06.999542	\N	\N	0	0	draw	yes
894	1380498	2025-10-27	Poland	Ekstraklasa	Radomiak Radom	Wisla Plock	draw	1	1	19	2	9	3	4	5	2	1	1	1	0	0	55.00	45.00	16	13	\N	\N	\N	\N	\N	2025-12-01 21:07:07.273928	\N	\N	1	1	draw	yes
895	1380507	2025-10-31	Poland	Ekstraklasa	Nieciecza	GKS Katowice	a-win	0	3	18	7	11	7	7	2	1	4	1	2	0	0	66.00	34.00	13	18	\N	\N	\N	\N	\N	2025-12-01 21:07:07.559837	2.08	2.15	0	1	a-win	yes
896	1380506	2025-10-31	Poland	Ekstraklasa	Piast Gliwice	Korona Kielce	draw	0	0	10	2	20	4	7	9	0	1	2	1	1	0	49.00	51.00	13	8	\N	\N	\N	\N	\N	2025-12-01 21:07:07.903379	0.44	1.74	0	0	draw	yes
897	1380502	2025-11-02	Poland	Ekstraklasa	Gornik Zabrze	Arka Gdynia	h-win	5	1	29	11	8	2	10	2	0	1	1	3	0	0	53.00	47.00	9	10	\N	\N	\N	1	15	2025-12-01 21:07:08.332691	\N	\N	1	0	h-win	yes
898	1380505	2025-11-02	Poland	Ekstraklasa	Lech Poznan	Motor Lublin	draw	2	2	18	3	8	2	6	2	1	2	2	1	0	0	60.00	40.00	10	15	\N	\N	\N	7	10	2025-12-01 21:07:08.611207	\N	\N	2	2	draw	yes
899	1380503	2025-11-02	Poland	Ekstraklasa	Jagiellonia	Raków Częstochowa	a-win	1	2	26	6	10	5	5	4	0	1	5	2	0	0	67.00	33.00	19	17	\N	\N	\N	2	4	2025-12-01 21:07:08.875806	\N	\N	0	1	a-win	yes
900	1380508	2025-11-02	Poland	Ekstraklasa	Widzew Łódź	Legia Warszawa	draw	1	1	10	3	20	3	3	8	3	0	3	3	0	0	42.00	58.00	10	13	\N	\N	\N	11	14	2025-12-01 21:07:09.113236	\N	\N	0	0	draw	yes
901	1380509	2025-11-03	Poland	Ekstraklasa	Wisla Plock	Pogon Szczecin	h-win	2	0	15	5	22	9	6	8	0	1	1	1	0	0	32.00	68.00	5	7	\N	\N	\N	3	12	2025-12-01 21:07:09.336575	2.20	1.28	1	0	h-win	yes
902	1380504	2025-11-03	Poland	Ekstraklasa	Lechia Gdansk	Radomiak Radom	a-win	1	2	14	4	11	5	8	4	2	1	2	4	0	0	47.00	53.00	11	12	\N	\N	\N	16	5	2025-12-01 21:07:09.551066	1.27	1.36	0	1	a-win	yes
903	1380501	2025-11-03	Poland	Ekstraklasa	Cracovia Krakow	Zaglebie Lubin	draw	0	0	14	3	8	3	2	0	3	0	0	0	0	0	68.00	32.00	11	11	\N	\N	\N	6	9	2025-12-01 21:07:09.799399	1.18	0.28	0	0	draw	yes
904	1380517	2025-11-07	Poland	Ekstraklasa	Radomiak Radom	Cracovia Krakow	h-win	3	0	12	8	4	2	5	3	1	2	2	3	0	0	51.00	49.00	12	17	\N	\N	\N	5	6	2025-12-01 21:07:10.095891	2.43	0.56	0	0	draw	yes
905	1380518	2025-11-07	Poland	Ekstraklasa	Zaglebie Lubin	Gornik Zabrze	h-win	2	0	6	3	15	2	1	12	1	1	4	1	0	0	30.00	70.00	12	12	\N	\N	\N	9	1	2025-12-01 21:07:10.370425	1.54	0.83	1	0	h-win	yes
906	1380513	2025-11-08	Poland	Ekstraklasa	Lechia Gdansk	Widzew Łódź	h-win	2	1	14	3	9	3	5	3	2	1	2	4	0	0	52.00	48.00	14	11	\N	\N	\N	16	11	2025-12-01 21:07:10.622627	1.29	1.29	0	0	draw	yes
907	1380515	2025-11-08	Poland	Ekstraklasa	Motor Lublin	Wisla Plock	draw	1	1	14	4	10	2	5	1	2	0	3	6	0	0	64.00	36.00	18	14	\N	\N	\N	10	3	2025-12-01 21:07:10.844011	3.36	0.79	1	0	h-win	yes
908	1380511	2025-11-08	Poland	Ekstraklasa	GKS Katowice	Piast Gliwice	a-win	1	3	9	3	17	6	3	3	2	0	2	2	0	0	54.00	46.00	10	16	\N	\N	\N	13	18	2025-12-01 21:07:11.07606	0.83	1.51	0	2	a-win	yes
909	1380514	2025-11-09	Poland	Ekstraklasa	Legia Warszawa	Nieciecza	a-win	1	2	23	6	13	7	11	2	2	3	1	4	0	0	70.00	30.00	13	17	\N	\N	\N	14	17	2025-12-01 21:07:11.309005	1.38	1.48	0	1	a-win	yes
910	1380512	2025-11-09	Poland	Ekstraklasa	Korona Kielce	Raków Częstochowa	a-win	1	4	12	2	7	5	5	0	2	0	3	2	0	0	49.00	51.00	15	9	\N	\N	\N	8	4	2025-12-01 21:07:11.548672	1.18	2.13	1	2	a-win	yes
911	1380516	2025-11-09	Poland	Ekstraklasa	Pogon Szczecin	Jagiellonia	a-win	1	2	35	10	11	5	10	1	0	1	2	1	0	0	39.00	61.00	8	9	\N	\N	\N	12	2	2025-12-01 21:07:11.771644	4.00	2.11	1	1	draw	yes
912	1380510	2025-11-09	Poland	Ekstraklasa	Arka Gdynia	Lech Poznan	h-win	3	1	19	7	13	6	3	3	2	1	3	3	0	1	44.00	56.00	19	16	\N	\N	\N	15	7	2025-12-01 21:07:12.052323	1.34	2.67	0	1	a-win	yes
913	1380526	2025-11-21	Poland	Ekstraklasa	Nieciecza	Arka Gdynia	h-win	2	0	7	4	11	2	1	2	0	4	3	4	0	1	51.00	49.00	12	20	\N	\N	\N	17	15	2025-12-01 21:07:12.320787	0.70	1.49	1	0	h-win	yes
914	1380520	2025-11-21	Poland	Ekstraklasa	Gornik Zabrze	Wisla Plock	draw	1	1	17	3	7	1	4	1	2	0	1	3	0	0	59.00	41.00	12	10	\N	\N	\N	1	3	2025-12-01 21:07:12.596082	1.37	0.95	0	0	draw	yes
915	1380519	2025-11-22	Poland	Ekstraklasa	Cracovia Krakow	Motor Lublin	a-win	1	2	9	2	6	5	4	7	2	1	3	1	0	0	57.00	43.00	16	15	\N	\N	\N	6	10	2025-12-01 21:07:12.813816	0.39	0.52	0	0	draw	yes
916	1380525	2025-11-22	Poland	Ekstraklasa	Raków Częstochowa	Piast Gliwice	a-win	1	3	12	3	13	5	3	2	1	1	0	2	0	0	58.00	42.00	5	11	\N	\N	\N	4	18	2025-12-01 21:07:13.042686	1.47	1.62	0	1	a-win	yes
917	1380523	2025-11-22	Poland	Ekstraklasa	Legia Warszawa	Lechia Gdansk	draw	2	2	13	3	17	5	6	2	0	1	4	0	0	0	54.00	46.00	12	2	\N	\N	\N	14	16	2025-12-01 21:07:13.211321	0.91	2.57	0	1	a-win	yes
918	1380522	2025-11-23	Poland	Ekstraklasa	Lech Poznan	Radomiak Radom	h-win	4	1	13	5	23	5	5	5	2	0	0	2	0	0	53.00	47.00	8	14	\N	\N	\N	7	5	2025-12-01 21:07:13.405199	2.98	1.29	1	0	h-win	yes
919	1380527	2025-11-23	Poland	Ekstraklasa	Widzew Łódź	Korona Kielce	a-win	1	3	22	5	13	5	5	4	1	2	6	4	1	0	57.00	43.00	9	9	\N	\N	\N	11	8	2025-12-01 21:07:13.678026	2.84	2.71	0	2	a-win	yes
920	1380524	2025-11-24	Poland	Ekstraklasa	Pogon Szczecin	Zaglebie Lubin	h-win	5	1	13	6	16	5	4	2	0	2	2	1	0	0	51.00	49.00	13	9	1.83	3.75	4.00	12	9	2025-12-01 21:07:13.983856	2.83	1.65	3	0	h-win	yes
921	1380533	2025-11-28	Poland	Ekstraklasa	Piast Gliwice	Widzew Łódź	a-win	0	2	24	3	10	4	10	4	3	1	1	3	0	0	68.00	32.00	8	12	2.30	3.20	3.20	18	11	2025-12-01 21:07:14.341904	1.94	2.11	0	1	a-win	yes
922	1380534	2025-11-28	Poland	Ekstraklasa	Radomiak Radom	Gornik Zabrze	h-win	4	0	19	8	9	2	4	0	1	2	3	2	0	0	48.00	52.00	19	11	2.64	3.30	2.64	5	1	2025-12-01 21:07:14.697451	2.31	0.24	2	0	h-win	yes
923	1380531	2025-11-29	Poland	Ekstraklasa	Lechia Gdansk	Nieciecza	h-win	5	1	15	8	4	3	4	2	2	0	1	2	0	0	55.00	45.00	14	9	1.61	4.20	5.00	16	17	2025-12-01 21:07:15.023715	\N	\N	2	1	h-win	yes
924	1380530	2025-11-29	Poland	Ekstraklasa	Korona Kielce	Cracovia Krakow	a-win	0	1	16	4	10	3	5	4	2	3	0	3	0	0	53.00	47.00	15	15	2.38	3.10	3.15	8	6	2025-12-01 21:07:15.206031	\N	\N	0	0	draw	yes
925	1380529	2025-11-29	Poland	Ekstraklasa	GKS Katowice	Pogon Szczecin	h-win	2	0	9	5	27	3	3	7	1	0	0	0	0	0	23.00	77.00	17	10	2.96	3.55	2.26	13	12	2025-12-01 21:07:15.393006	\N	\N	2	0	h-win	yes
926	1380528	2025-11-30	Poland	Ekstraklasa	Arka Gdynia	Raków Częstochowa	a-win	1	4	6	2	17	6	3	4	1	1	1	3	1	0	37.00	63.00	12	14	4.45	3.20	1.91	15	4	2025-12-01 21:07:15.553363	\N	\N	0	3	a-win	yes
927	1380536	2025-11-30	Poland	Ekstraklasa	Zaglebie Lubin	Jagiellonia	draw	0	0	9	4	19	4	2	5	3	4	2	3	0	0	27.00	73.00	17	18	3.30	3.45	2.14	9	2	2025-12-01 21:07:15.711849	\N	\N	0	0	draw	yes
928	1380535	2025-11-30	Poland	Ekstraklasa	Wisla Plock	Lech Poznan	draw	0	0	7	2	25	2	2	15	2	1	0	2	0	0	32.00	68.00	8	13	3.05	3.45	2.24	3	7	2025-12-01 21:07:15.911528	\N	\N	0	0	draw	yes
929	1380532	2025-12-01	Poland	Ekstraklasa	Motor Lublin	Legia Warszawa	draw	1	1	4	1	14	4	5	1	2	0	0	3	0	0	50.00	50.00	9	22	3.05	3.45	2.26	10	14	2025-12-01 21:07:16.058729	\N	\N	1	1	draw	yes
930	1381524	2025-07-18	Poland	I Liga	Slask Wroclaw	Wieczysta Kraków	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:36.185178	\N	\N	1	0	h-win	yes
931	1381521	2025-07-18	Poland	I Liga	ŁKS Łódź	Znicz Pruszków	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:36.377662	\N	\N	1	0	h-win	yes
932	1381519	2025-07-19	Poland	I Liga	Pogoń Grod. Mazowiecki	Stal Rzeszów	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:36.534691	\N	\N	2	0	h-win	yes
933	1381520	2025-07-19	Poland	I Liga	Górnik Łęczna	Polonia Bytom	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:36.724736	\N	\N	0	1	a-win	yes
934	1381526	2025-07-19	Poland	I Liga	Tychy 71	Miedz Legnica	h-win	4	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:36.90964	\N	\N	0	0	draw	yes
935	1381525	2025-07-20	Poland	I Liga	Stal Mielec	Wisla Krakow	a-win	0	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:37.058539	\N	\N	0	2	a-win	yes
936	1381518	2025-07-20	Poland	I Liga	Chrobry Głogów	Odra Opole	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:37.237289	\N	\N	1	0	h-win	yes
937	1381522	2025-07-20	Poland	I Liga	Pogoń Siedlce	Polonia Warszawa	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:37.458381	\N	\N	1	0	h-win	yes
938	1381523	2025-07-21	Poland	I Liga	Puszcza Niepołomice	Ruch Chorzów	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:37.732427	\N	\N	0	0	draw	yes
939	1381531	2025-07-25	Poland	I Liga	Znicz Pruszków	Stal Mielec	a-win	4	5	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:37.994351	\N	\N	1	2	a-win	yes
940	1381534	2025-07-25	Poland	I Liga	Stal Rzeszów	Slask Wroclaw	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:38.221538	\N	\N	1	1	draw	yes
941	1381535	2025-07-26	Poland	I Liga	Wisla Krakow	ŁKS Łódź	h-win	5	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:38.517313	\N	\N	4	0	h-win	yes
942	1381532	2025-07-26	Poland	I Liga	Puszcza Niepołomice	Pogoń Grod. Mazowiecki	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:38.686871	\N	\N	1	1	draw	yes
943	1381527	2025-07-26	Poland	I Liga	Chrobry Głogów	Polonia Bytom	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:38.853765	\N	\N	0	1	a-win	yes
944	1381528	2025-07-27	Poland	I Liga	Wieczysta Kraków	Pogoń Siedlce	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:39.024456	\N	\N	2	1	h-win	yes
945	1381533	2025-07-27	Poland	I Liga	Ruch Chorzów	Górnik Łęczna	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:39.187261	\N	\N	1	0	h-win	yes
946	1381530	2025-07-27	Poland	I Liga	Polonia Warszawa	Tychy 71	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:39.423187	\N	\N	1	1	draw	yes
947	1381529	2025-07-28	Poland	I Liga	Odra Opole	Miedz Legnica	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:39.744783	\N	\N	2	1	h-win	yes
948	1381537	2025-08-01	Poland	I Liga	Wieczysta Kraków	Znicz Pruszków	h-win	4	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:40.009545	\N	\N	1	0	h-win	yes
949	1381539	2025-08-01	Poland	I Liga	ŁKS Łódź	Polonia Bytom	h-win	5	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:40.199739	\N	\N	1	0	h-win	yes
950	1381536	2025-08-02	Poland	I Liga	Pogoń Grod. Mazowiecki	Miedz Legnica	h-win	4	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:40.361595	\N	\N	2	0	h-win	yes
951	1381542	2025-08-02	Poland	I Liga	Stal Rzeszów	Chrobry Głogów	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:40.545497	\N	\N	0	1	a-win	yes
952	1381543	2025-08-02	Poland	I Liga	Stal Mielec	Polonia Warszawa	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:40.724183	\N	\N	0	2	a-win	yes
953	1381541	2025-08-03	Poland	I Liga	Slask Wroclaw	Ruch Chorzów	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:40.937696	\N	\N	3	1	h-win	yes
954	1381540	2025-08-03	Poland	I Liga	Pogoń Siedlce	Odra Opole	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:41.102491	\N	\N	0	0	draw	yes
955	1381538	2025-08-03	Poland	I Liga	Górnik Łęczna	Puszcza Niepołomice	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:41.266064	\N	\N	2	1	h-win	yes
956	1381544	2025-08-04	Poland	I Liga	Tychy 71	Wisla Krakow	a-win	3	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:41.440909	\N	\N	1	1	draw	yes
957	1381550	2025-08-08	Poland	I Liga	Ruch Chorzów	Pogoń Siedlce	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:41.617752	\N	\N	0	2	a-win	yes
958	1381551	2025-08-08	Poland	I Liga	Slask Wroclaw	Miedz Legnica	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:41.798482	\N	\N	1	1	draw	yes
959	1381545	2025-08-09	Poland	I Liga	Chrobry Głogów	ŁKS Łódź	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:42.007869	\N	\N	0	0	draw	yes
960	1381552	2025-08-09	Poland	I Liga	Stal Mielec	Górnik Łęczna	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:42.189911	\N	\N	0	1	a-win	yes
961	1381547	2025-08-09	Poland	I Liga	Polonia Bytom	Stal Rzeszów	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:42.374702	\N	\N	0	1	a-win	yes
962	1381553	2025-08-10	Poland	I Liga	Wisla Krakow	Pogoń Grod. Mazowiecki	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:42.581685	\N	\N	3	1	h-win	yes
963	1381546	2025-08-10	Poland	I Liga	Odra Opole	Tychy 71	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:42.766831	\N	\N	0	0	draw	yes
964	1381548	2025-08-10	Poland	I Liga	Znicz Pruszków	Polonia Warszawa	a-win	1	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:42.933573	\N	\N	0	1	a-win	yes
965	1381549	2025-08-11	Poland	I Liga	Puszcza Niepołomice	Wieczysta Kraków	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:43.08979	\N	\N	0	0	draw	yes
966	1381557	2025-08-15	Poland	I Liga	ŁKS Łódź	Stal Mielec	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:43.259293	\N	\N	1	0	h-win	yes
967	1381560	2025-08-15	Poland	I Liga	Polonia Warszawa	Ruch Chorzów	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:43.410483	\N	\N	0	0	draw	yes
968	1381556	2025-08-16	Poland	I Liga	Chrobry Głogów	Miedz Legnica	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:43.573456	\N	\N	1	0	h-win	yes
969	1381561	2025-08-16	Poland	I Liga	Stal Rzeszów	Puszcza Niepołomice	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:43.758325	\N	\N	1	2	a-win	yes
970	1381554	2025-08-16	Poland	I Liga	Pogoń Grod. Mazowiecki	Znicz Pruszków	h-win	4	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:43.921608	\N	\N	3	1	h-win	yes
971	1381558	2025-08-17	Poland	I Liga	Odra Opole	Slask Wroclaw	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:44.116674	\N	\N	0	0	draw	yes
972	1381562	2025-08-17	Poland	I Liga	Tychy 71	Górnik Łęczna	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:44.29744	\N	\N	2	1	h-win	yes
973	1381559	2025-08-17	Poland	I Liga	Pogoń Siedlce	Polonia Bytom	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:44.469586	\N	\N	0	0	draw	yes
974	1381565	2025-08-19	Poland	I Liga	Miedz Legnica	ŁKS Łódź	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:44.638015	\N	\N	2	0	h-win	yes
975	1381567	2025-08-19	Poland	I Liga	Polonia Warszawa	Wieczysta Kraków	a-win	1	6	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:44.800718	\N	\N	0	2	a-win	yes
976	1381568	2025-08-19	Poland	I Liga	Znicz Pruszków	Wisla Krakow	a-win	0	7	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:44.961627	\N	\N	0	3	a-win	yes
977	1381563	2025-08-20	Poland	I Liga	Chrobry Głogów	Slask Wroclaw	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:45.126382	\N	\N	0	2	a-win	yes
978	1381566	2025-08-20	Poland	I Liga	Polonia Bytom	Pogoń Grod. Mazowiecki	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:45.281603	\N	\N	1	0	h-win	yes
979	1381570	2025-08-20	Poland	I Liga	Ruch Chorzów	Stal Rzeszów	h-win	4	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:45.444284	\N	\N	2	0	h-win	yes
980	1381569	2025-08-21	Poland	I Liga	Puszcza Niepołomice	Tychy 71	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:45.609567	\N	\N	1	0	h-win	yes
981	1381571	2025-08-21	Poland	I Liga	Stal Mielec	Odra Opole	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:45.748689	\N	\N	0	0	draw	yes
982	1381564	2025-08-21	Poland	I Liga	Górnik Łęczna	Pogoń Siedlce	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:45.922556	\N	\N	0	1	a-win	yes
983	1381574	2025-08-23	Poland	I Liga	ŁKS Łódź	Polonia Warszawa	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:46.071848	\N	\N	0	2	a-win	yes
984	1381578	2025-08-23	Poland	I Liga	Stal Rzeszów	Miedz Legnica	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:46.228872	\N	\N	0	0	draw	yes
985	1381572	2025-08-23	Poland	I Liga	Pogoń Grod. Mazowiecki	Chrobry Głogów	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:46.397912	\N	\N	0	0	draw	yes
986	1381575	2025-08-24	Poland	I Liga	Odra Opole	Znicz Pruszków	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:46.553888	\N	\N	0	1	a-win	yes
987	1381580	2025-08-24	Poland	I Liga	Wisla Krakow	Slask Wroclaw	h-win	5	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:46.708413	\N	\N	2	0	h-win	yes
988	1381577	2025-08-24	Poland	I Liga	Ruch Chorzów	Polonia Bytom	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:46.870563	\N	\N	0	0	draw	yes
989	1381576	2025-08-24	Poland	I Liga	Pogoń Siedlce	Puszcza Niepołomice	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:47.019624	\N	\N	0	0	draw	yes
990	1421941	2025-08-25	Poland	I Liga	Wieczysta Kraków	Górnik Łęczna	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:47.201724	\N	\N	1	0	h-win	yes
993	1381582	2025-08-29	Poland	I Liga	Miedz Legnica	Wisla Krakow	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:47.792313	\N	\N	1	0	h-win	yes
994	1381584	2025-08-30	Poland	I Liga	Polonia Bytom	Wieczysta Kraków	h-win	4	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:48.011333	\N	\N	3	1	h-win	yes
995	1381581	2025-08-30	Poland	I Liga	Górnik Łęczna	Stal Rzeszów	a-win	0	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:48.194162	\N	\N	0	2	a-win	yes
996	1381586	2025-08-30	Poland	I Liga	Znicz Pruszków	Pogoń Siedlce	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:48.381566	\N	\N	0	0	draw	yes
997	1381585	2025-08-30	Poland	I Liga	Polonia Warszawa	Pogoń Grod. Mazowiecki	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:48.56734	\N	\N	2	1	h-win	yes
998	1381589	2025-08-31	Poland	I Liga	Stal Mielec	Ruch Chorzów	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:48.762331	\N	\N	1	0	h-win	yes
999	1381583	2025-08-31	Poland	I Liga	Odra Opole	ŁKS Łódź	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:48.993199	\N	\N	0	0	draw	yes
1000	1381587	2025-08-31	Poland	I Liga	Puszcza Niepołomice	Chrobry Głogów	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:49.189706	\N	\N	0	0	draw	yes
1001	1381597	2025-09-12	Poland	I Liga	Tychy 71	Polonia Bytom	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:49.38276	\N	\N	1	1	draw	yes
1002	1381590	2025-09-12	Poland	I Liga	Chrobry Głogów	Pogoń Siedlce	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:49.563592	\N	\N	0	0	draw	yes
1003	1381595	2025-09-13	Poland	I Liga	Slask Wroclaw	Puszcza Niepołomice	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:49.746478	\N	\N	0	0	draw	yes
1004	1381598	2025-09-13	Poland	I Liga	Wisla Krakow	Odra Opole	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:49.935537	\N	\N	1	1	draw	yes
1005	1381596	2025-09-13	Poland	I Liga	Stal Rzeszów	Znicz Pruszków	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:50.11791	\N	\N	1	0	h-win	yes
1006	1381593	2025-09-14	Poland	I Liga	Miedz Legnica	Polonia Warszawa	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:50.281574	\N	\N	0	1	a-win	yes
1007	1381594	2025-09-14	Poland	I Liga	Ruch Chorzów	ŁKS Łódź	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:50.450567	\N	\N	2	0	h-win	yes
1008	1381591	2025-09-14	Poland	I Liga	Pogoń Grod. Mazowiecki	Górnik Łęczna	draw	3	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:50.615545	\N	\N	1	2	a-win	yes
1009	1381592	2025-09-15	Poland	I Liga	Wieczysta Kraków	Stal Mielec	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:50.775578	\N	\N	2	0	h-win	yes
1010	1381601	2025-09-19	Poland	I Liga	Odra Opole	Stal Rzeszów	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:50.967489	\N	\N	2	1	h-win	yes
1011	1381607	2025-09-19	Poland	I Liga	Stal Mielec	Pogoń Grod. Mazowiecki	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:51.16251	\N	\N	1	1	draw	yes
1012	1381602	2025-09-20	Poland	I Liga	Pogoń Siedlce	Slask Wroclaw	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:51.365565	\N	\N	2	1	h-win	yes
1013	1381603	2025-09-20	Poland	I Liga	Polonia Bytom	Miedz Legnica	h-win	4	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:51.632661	\N	\N	3	0	h-win	yes
1014	1381604	2025-09-20	Poland	I Liga	Polonia Warszawa	Puszcza Niepołomice	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:51.918723	\N	\N	0	2	a-win	yes
1015	1381599	2025-09-21	Poland	I Liga	Górnik Łęczna	Wisla Krakow	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:52.18039	\N	\N	1	0	h-win	yes
1016	1381605	2025-09-21	Poland	I Liga	Znicz Pruszków	Tychy 71	h-win	4	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:52.472777	\N	\N	2	0	h-win	yes
1017	1381600	2025-09-21	Poland	I Liga	ŁKS Łódź	Wieczysta Kraków	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:52.727247	\N	\N	0	0	draw	yes
1018	1381606	2025-09-22	Poland	I Liga	Ruch Chorzów	Chrobry Głogów	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:52.972589	\N	\N	1	1	draw	yes
1019	1381613	2025-09-26	Poland	I Liga	Slask Wroclaw	Polonia Warszawa	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:53.217465	\N	\N	1	0	h-win	yes
1020	1381612	2025-09-27	Poland	I Liga	Puszcza Niepołomice	Odra Opole	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:53.430275	\N	\N	0	0	draw	yes
1021	1381615	2025-09-27	Poland	I Liga	Tychy 71	Pogoń Siedlce	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:53.693515	\N	\N	0	1	a-win	yes
1022	1381614	2025-09-27	Poland	I Liga	Stal Rzeszów	Stal Mielec	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:53.86065	\N	\N	1	0	h-win	yes
1023	1381611	2025-09-28	Poland	I Liga	Miedz Legnica	Znicz Pruszków	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:54.033195	\N	\N	1	1	draw	yes
1024	1381610	2025-09-28	Poland	I Liga	Wieczysta Kraków	Ruch Chorzów	h-win	4	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:54.226552	\N	\N	1	1	draw	yes
1025	1381608	2025-09-28	Poland	I Liga	Chrobry Głogów	Górnik Łęczna	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:54.380694	\N	\N	0	0	draw	yes
1026	1381609	2025-09-29	Poland	I Liga	Pogoń Grod. Mazowiecki	ŁKS Łódź	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:54.549622	\N	\N	2	0	h-win	yes
1027	1381616	2025-09-29	Poland	I Liga	Wisla Krakow	Polonia Bytom	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:54.744341	\N	\N	0	0	draw	yes
1028	1381555	2025-10-02	Poland	I Liga	Wieczysta Kraków	Wisla Krakow	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:54.925502	\N	\N	1	0	h-win	yes
1029	1381624	2025-10-03	Poland	I Liga	Stal Mielec	Chrobry Głogów	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:55.172341	\N	\N	0	0	draw	yes
1030	1381622	2025-10-03	Poland	I Liga	Polonia Warszawa	Stal Rzeszów	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:55.432255	\N	\N	0	2	a-win	yes
1031	1381620	2025-10-04	Poland	I Liga	Pogoń Siedlce	Pogoń Grod. Mazowiecki	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:55.693557	\N	\N	1	2	a-win	yes
1032	1381623	2025-10-04	Poland	I Liga	Znicz Pruszków	Slask Wroclaw	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:55.985535	\N	\N	2	0	h-win	yes
1033	1381621	2025-10-04	Poland	I Liga	Polonia Bytom	Puszcza Niepołomice	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:56.313236	\N	\N	1	1	draw	yes
1034	1381619	2025-10-05	Poland	I Liga	Odra Opole	Wieczysta Kraków	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:56.569721	\N	\N	0	0	draw	yes
1035	1381618	2025-10-05	Poland	I Liga	ŁKS Łódź	Tychy 71	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:56.86309	\N	\N	1	0	h-win	yes
1036	1381617	2025-10-05	Poland	I Liga	Górnik Łęczna	Miedz Legnica	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:57.132659	\N	\N	0	0	draw	yes
1037	1381625	2025-10-05	Poland	I Liga	Wisla Krakow	Ruch Chorzów	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:57.43283	\N	\N	1	0	h-win	yes
1038	1381627	2025-10-17	Poland	I Liga	Pogoń Grod. Mazowiecki	Ruch Chorzów	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:57.71455	\N	\N	1	1	draw	yes
1039	1381629	2025-10-17	Poland	I Liga	Miedz Legnica	Pogoń Siedlce	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:57.993157	\N	\N	1	2	a-win	yes
1040	1381626	2025-10-18	Poland	I Liga	Chrobry Głogów	Polonia Warszawa	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:58.221103	\N	\N	0	0	draw	yes
1041	1381634	2025-10-18	Poland	I Liga	Tychy 71	Wieczysta Kraków	draw	3	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:58.436131	\N	\N	1	2	a-win	yes
1042	1381633	2025-10-18	Poland	I Liga	Stal Rzeszów	ŁKS Łódź	a-win	1	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:58.602236	\N	\N	0	3	a-win	yes
1043	1381630	2025-10-19	Poland	I Liga	Polonia Bytom	Odra Opole	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:58.782292	\N	\N	0	0	draw	yes
1044	1381632	2025-10-19	Poland	I Liga	Slask Wroclaw	Stal Mielec	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:58.93914	\N	\N	2	0	h-win	yes
1045	1381628	2025-10-19	Poland	I Liga	Górnik Łęczna	Znicz Pruszków	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:59.115811	\N	\N	0	0	draw	yes
1046	1381631	2025-10-20	Poland	I Liga	Puszcza Niepołomice	Wisla Krakow	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:59.338321	\N	\N	0	3	a-win	yes
1047	1381639	2025-10-24	Poland	I Liga	Znicz Pruszków	Puszcza Niepołomice	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:59.517094	\N	\N	0	1	a-win	yes
1048	1381636	2025-10-24	Poland	I Liga	Odra Opole	Ruch Chorzów	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:59.694199	\N	\N	0	1	a-win	yes
1049	1381640	2025-10-25	Poland	I Liga	Slask Wroclaw	Górnik Łęczna	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:16:59.891513	\N	\N	1	0	h-win	yes
1050	1381637	2025-10-25	Poland	I Liga	Pogoń Siedlce	ŁKS Łódź	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:17:00.079212	\N	\N	1	1	draw	yes
1051	1381638	2025-10-25	Poland	I Liga	Polonia Warszawa	Polonia Bytom	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:17:00.266278	\N	\N	0	0	draw	yes
1052	1381642	2025-10-26	Poland	I Liga	Tychy 71	Chrobry Głogów	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:17:00.527496	\N	\N	0	1	a-win	yes
1053	1381643	2025-10-26	Poland	I Liga	Wisla Krakow	Stal Rzeszów	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:17:00.68246	\N	\N	1	0	h-win	yes
1054	1381641	2025-10-26	Poland	I Liga	Stal Mielec	Miedz Legnica	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:17:00.875264	\N	\N	1	0	h-win	yes
1055	1381635	2025-10-27	Poland	I Liga	Wieczysta Kraków	Pogoń Grod. Mazowiecki	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:17:01.0281	\N	\N	2	1	h-win	yes
1056	1381652	2025-10-31	Poland	I Liga	Górnik Łęczna	Polonia Warszawa	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:17:01.196387	\N	\N	1	2	a-win	yes
1057	1381650	2025-10-31	Poland	I Liga	Ruch Chorzów	Tychy 71	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 22:17:01.366362	\N	\N	2	0	h-win	yes
1058	1381651	2025-11-02	Poland	I Liga	Stal Rzeszów	Pogoń Siedlce	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	13	2025-12-01 22:17:01.604485	\N	\N	0	0	draw	yes
1059	1381644	2025-11-02	Poland	I Liga	Chrobry Głogów	Wisla Krakow	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	1	2025-12-01 22:17:01.766182	\N	\N	0	1	a-win	yes
1060	1381648	2025-11-02	Poland	I Liga	Polonia Bytom	Znicz Pruszków	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	15	2025-12-01 22:17:01.935286	\N	\N	1	0	h-win	yes
1061	1381646	2025-11-02	Poland	I Liga	Miedz Legnica	Wieczysta Kraków	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	10	8	2025-12-01 22:17:02.099415	\N	\N	1	0	h-win	yes
1062	1381647	2025-11-03	Poland	I Liga	ŁKS Łódź	Slask Wroclaw	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	11	6	2025-12-01 22:17:02.273577	\N	\N	0	0	draw	yes
1063	1381645	2025-11-03	Poland	I Liga	Pogoń Grod. Mazowiecki	Odra Opole	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	12	2025-12-01 22:17:02.434296	\N	\N	1	1	draw	yes
1064	1381649	2025-11-05	Poland	I Liga	Puszcza Niepołomice	Stal Mielec	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	14	16	2025-12-01 22:17:02.59749	\N	\N	1	0	h-win	yes
1065	1381654	2025-11-07	Poland	I Liga	Ruch Chorzów	Miedz Legnica	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	10	2025-12-01 22:17:02.756407	\N	\N	2	1	h-win	yes
1066	1381657	2025-11-07	Poland	I Liga	Znicz Pruszków	Chrobry Głogów	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	15	4	2025-12-01 22:17:02.930483	\N	\N	0	0	draw	yes
1067	1381661	2025-11-08	Poland	I Liga	Wisla Krakow	Polonia Warszawa	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	7	2025-12-01 22:17:03.098234	\N	\N	1	1	draw	yes
1068	1381659	2025-11-08	Poland	I Liga	Stal Mielec	Pogoń Siedlce	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16	13	2025-12-01 22:17:03.262784	\N	\N	0	0	draw	yes
1069	1381655	2025-11-08	Poland	I Liga	ŁKS Łódź	Puszcza Niepołomice	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	11	14	2025-12-01 22:17:03.428509	\N	\N	0	1	a-win	yes
1070	1381653	2025-11-08	Poland	I Liga	Wieczysta Kraków	Stal Rzeszów	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8	5	2025-12-01 22:17:03.629173	\N	\N	0	0	draw	yes
1071	1381656	2025-11-09	Poland	I Liga	Odra Opole	Górnik Łęczna	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	18	2025-12-01 22:17:03.841289	\N	\N	1	1	draw	yes
1072	1381658	2025-11-09	Poland	I Liga	Slask Wroclaw	Polonia Bytom	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	3	2025-12-01 22:17:04.060418	\N	\N	0	2	a-win	yes
1073	1381660	2025-11-09	Poland	I Liga	Tychy 71	Pogoń Grod. Mazowiecki	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	17	2	2025-12-01 22:17:04.285748	\N	\N	1	2	a-win	yes
1074	1381668	2025-11-21	Poland	I Liga	Puszcza Niepołomice	Miedz Legnica	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	14	10	2025-12-01 22:17:04.476534	\N	\N	0	1	a-win	yes
1075	1381663	2025-11-21	Poland	I Liga	Pogoń Grod. Mazowiecki	Slask Wroclaw	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	6	2025-12-01 22:17:04.636645	\N	\N	1	2	a-win	yes
1076	1381662	2025-11-22	Poland	I Liga	Chrobry Głogów	Wieczysta Kraków	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	8	2025-12-01 22:17:04.83241	\N	\N	1	2	a-win	yes
1077	1381670	2025-11-22	Poland	I Liga	Stal Rzeszów	Tychy 71	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	17	2025-12-01 22:17:04.999437	\N	\N	1	1	draw	yes
1078	1381666	2025-11-22	Poland	I Liga	Polonia Bytom	Stal Mielec	h-win	4	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	16	2025-12-01 22:17:05.093144	\N	\N	2	1	h-win	yes
1079	1381669	2025-11-23	Poland	I Liga	Ruch Chorzów	Znicz Pruszków	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	15	2025-12-01 22:17:05.100217	\N	\N	0	1	a-win	yes
1080	1381665	2025-11-23	Poland	I Liga	Pogoń Siedlce	Wisla Krakow	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	13	1	2025-12-01 22:17:05.106936	\N	\N	0	0	draw	yes
1081	1381664	2025-11-23	Poland	I Liga	Górnik Łęczna	ŁKS Łódź	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	18	11	2025-12-01 22:17:05.115768	\N	\N	0	1	a-win	yes
1082	1381667	2025-11-23	Poland	I Liga	Polonia Warszawa	Odra Opole	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7	12	2025-12-01 22:17:05.121942	\N	\N	0	0	draw	yes
1083	1381674	2025-11-28	Poland	I Liga	Polonia Bytom	Górnik Łęczna	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	18	2025-12-01 22:17:05.131676	\N	\N	0	1	a-win	yes
1084	1381672	2025-11-28	Poland	I Liga	Miedz Legnica	Tychy 71	h-win	6	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	10	17	2025-12-01 22:17:05.138754	\N	\N	4	1	h-win	yes
1085	1381673	2025-11-29	Poland	I Liga	Odra Opole	Chrobry Głogów	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	4	2025-12-01 22:17:05.147976	\N	\N	0	0	draw	yes
1086	1381677	2025-11-29	Poland	I Liga	Ruch Chorzów	Puszcza Niepołomice	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	14	2025-12-01 22:17:05.154716	\N	\N	2	0	h-win	yes
1087	1381675	2025-11-29	Poland	I Liga	Polonia Warszawa	Pogoń Siedlce	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7	13	2025-12-01 22:17:05.162591	\N	\N	1	0	h-win	yes
1088	1381676	2025-11-30	Poland	I Liga	Znicz Pruszków	ŁKS Łódź	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	15	11	2025-12-01 22:17:05.169435	\N	\N	1	1	draw	yes
1089	1381671	2025-11-30	Poland	I Liga	Wieczysta Kraków	Slask Wroclaw	draw	3	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8	6	2025-12-01 22:17:05.178174	\N	\N	2	2	draw	yes
1090	1381679	2025-11-30	Poland	I Liga	Wisla Krakow	Stal Mielec	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	16	2025-12-01 22:17:05.185175	\N	\N	3	0	h-win	yes
1091	1381678	2025-12-01	Poland	I Liga	Stal Rzeszów	Pogoń Grod. Mazowiecki	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	2	2025-12-01 22:17:05.193792	\N	\N	1	0	h-win	yes
1092	1395817	2025-07-25	Poland	II Liga - East	Świt Skolwin	Kalisz	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:48.588634	\N	\N	0	0	draw	yes
1093	1395811	2025-07-25	Poland	II Liga - East	Podbeskidzie	Sandecja Nowy Sącz	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:48.665358	\N	\N	0	1	a-win	yes
1094	1395812	2025-07-25	Poland	II Liga - East	Olimpia Grudziądz	Stal Stalowa Wola	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:48.743655	\N	\N	0	0	draw	yes
1095	1395813	2025-07-26	Poland	II Liga - East	Podhale Nowy Targ	Jastrzębie	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:48.821954	\N	\N	1	0	h-win	yes
1096	1395816	2025-07-26	Poland	II Liga - East	Śląsk Wrocław II	Rekord Bielsko-Biała	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:48.907026	\N	\N	0	0	draw	yes
1097	1395814	2025-07-26	Poland	II Liga - East	Hutnik Kraków	ŁKS Łódź II	h-win	4	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:48.998256	\N	\N	3	0	h-win	yes
1098	1395818	2025-07-27	Poland	II Liga - East	Sokół Kleczew	Zaglebie Sosnowiec	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:49.078694	\N	\N	1	1	draw	yes
1099	1395815	2025-07-27	Poland	II Liga - East	Resovia Rzeszów	Chojniczanka Chojnice	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:49.153754	\N	\N	1	0	h-win	yes
1100	1395819	2025-07-27	Poland	II Liga - East	Unia Skierniewice	Warta Poznań	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:49.23891	\N	\N	0	1	a-win	yes
1101	1395820	2025-08-01	Poland	II Liga - East	Rekord Bielsko-Biała	Podhale Nowy Targ	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:49.320533	\N	\N	0	1	a-win	yes
1102	1395827	2025-08-01	Poland	II Liga - East	Stal Stalowa Wola	Podbeskidzie	h-win	5	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:49.422029	\N	\N	3	0	h-win	yes
1103	1395826	2025-08-02	Poland	II Liga - East	Śląsk Wrocław II	Hutnik Kraków	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:49.521882	\N	\N	0	0	draw	yes
1104	1395824	2025-08-02	Poland	II Liga - East	Sandecja Nowy Sącz	Świt Skolwin	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:49.604086	\N	\N	2	1	h-win	yes
1105	1395828	2025-08-02	Poland	II Liga - East	Zaglebie Sosnowiec	Resovia Rzeszów	a-win	1	5	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:49.681944	\N	\N	1	2	a-win	yes
1106	1395822	2025-08-02	Poland	II Liga - East	Jastrzębie	ŁKS Łódź II	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:49.767679	\N	\N	0	1	a-win	yes
1107	1395825	2025-08-02	Poland	II Liga - East	Unia Skierniewice	Olimpia Grudziądz	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:49.853595	\N	\N	1	1	draw	yes
1108	1395823	2025-08-03	Poland	II Liga - East	Kalisz	Sokół Kleczew	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:49.932556	\N	\N	0	0	draw	yes
1109	1395821	2025-08-03	Poland	II Liga - East	Chojniczanka Chojnice	Warta Poznań	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:50.012901	\N	\N	1	0	h-win	yes
1110	1395833	2025-08-08	Poland	II Liga - East	Podbeskidzie	Śląsk Wrocław II	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:50.095775	\N	\N	0	0	draw	yes
1111	1395829	2025-08-09	Poland	II Liga - East	Hutnik Kraków	Resovia Rzeszów	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:50.17726	\N	\N	1	1	draw	yes
1112	1395834	2025-08-09	Poland	II Liga - East	Sandecja Nowy Sącz	Rekord Bielsko-Biała	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:50.25122	\N	\N	1	0	h-win	yes
1113	1395830	2025-08-09	Poland	II Liga - East	Sokół Kleczew	Jastrzębie	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:50.33651	\N	\N	2	0	h-win	yes
1114	1395836	2025-08-09	Poland	II Liga - East	Stal Stalowa Wola	Kalisz	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:50.416404	\N	\N	1	0	h-win	yes
1115	1395831	2025-08-10	Poland	II Liga - East	ŁKS Łódź II	Chojniczanka Chojnice	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:50.498241	\N	\N	0	0	draw	yes
1116	1395835	2025-08-10	Poland	II Liga - East	Świt Skolwin	Warta Poznań	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:50.589154	\N	\N	1	1	draw	yes
1117	1395832	2025-08-10	Poland	II Liga - East	Olimpia Grudziądz	Podhale Nowy Targ	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:50.671617	\N	\N	0	1	a-win	yes
1118	1395837	2025-08-10	Poland	II Liga - East	Zaglebie Sosnowiec	Unia Skierniewice	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:50.764411	\N	\N	0	1	a-win	yes
1119	1395840	2025-08-15	Poland	II Liga - East	Jastrzębie	Sandecja Nowy Sącz	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:50.841212	\N	\N	2	2	draw	yes
1120	1395839	2025-08-15	Poland	II Liga - East	Chojniczanka Chojnice	Podbeskidzie	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:50.930596	\N	\N	0	0	draw	yes
1121	1395838	2025-08-15	Poland	II Liga - East	Rekord Bielsko-Biała	Sokół Kleczew	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:51.023912	\N	\N	2	0	h-win	yes
1122	1395844	2025-08-15	Poland	II Liga - East	Resovia Rzeszów	Olimpia Grudziądz	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:51.133218	\N	\N	1	1	draw	yes
1123	1395845	2025-08-15	Poland	II Liga - East	Unia Skierniewice	Świt Skolwin	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:51.228417	\N	\N	0	1	a-win	yes
1124	1395846	2025-08-16	Poland	II Liga - East	Śląsk Wrocław II	Zaglebie Sosnowiec	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:51.39367	\N	\N	0	1	a-win	yes
1125	1395842	2025-08-17	Poland	II Liga - East	ŁKS Łódź II	Warta Poznań	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:51.485272	\N	\N	0	0	draw	yes
1126	1395843	2025-08-17	Poland	II Liga - East	Podhale Nowy Targ	Stal Stalowa Wola	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:51.561862	\N	\N	0	1	a-win	yes
1127	1395841	2025-08-17	Poland	II Liga - East	Kalisz	Hutnik Kraków	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:51.642732	\N	\N	0	0	draw	yes
1128	1395855	2025-08-22	Poland	II Liga - East	Rekord Bielsko-Biała	Warta Poznań	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:51.732279	\N	\N	1	0	h-win	yes
1129	1396000	2025-08-22	Poland	II Liga - East	Rekord Bielsko-Biała	Warta Poznań	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:51.828228	\N	\N	1	0	h-win	yes
1130	1395849	2025-08-22	Poland	II Liga - East	Sokół Kleczew	Resovia Rzeszów	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:51.917152	\N	\N	1	0	h-win	yes
1131	1395854	2025-08-22	Poland	II Liga - East	Stal Stalowa Wola	Unia Skierniewice	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:51.997939	\N	\N	1	1	draw	yes
1132	1395852	2025-08-23	Poland	II Liga - East	Podhale Nowy Targ	Zaglebie Sosnowiec	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:52.075568	\N	\N	1	1	draw	yes
1133	1395848	2025-08-23	Poland	II Liga - East	Hutnik Kraków	Sandecja Nowy Sącz	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:52.169142	\N	\N	0	0	draw	yes
1134	1395853	2025-08-23	Poland	II Liga - East	Świt Skolwin	Jastrzębie	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:52.251397	\N	\N	2	0	h-win	yes
1135	1395847	2025-08-23	Poland	II Liga - East	Chojniczanka Chojnice	Kalisz	draw	3	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:52.338959	\N	\N	1	0	h-win	yes
1136	1395851	2025-08-23	Poland	II Liga - East	Podbeskidzie	ŁKS Łódź II	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:52.441145	\N	\N	0	0	draw	yes
1137	1395850	2025-08-24	Poland	II Liga - East	Olimpia Grudziądz	Śląsk Wrocław II	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:52.565423	\N	\N	2	0	h-win	yes
1138	1395859	2025-08-29	Poland	II Liga - East	Resovia Rzeszów	Podhale Nowy Targ	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:52.646438	\N	\N	0	0	draw	yes
1139	1395861	2025-08-29	Poland	II Liga - East	Unia Skierniewice	Rekord Bielsko-Biała	h-win	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:52.739059	\N	\N	2	0	h-win	yes
1140	1395858	2025-08-30	Poland	II Liga - East	Podbeskidzie	Hutnik Kraków	draw	3	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:52.826323	\N	\N	2	2	draw	yes
1141	1395857	2025-08-30	Poland	II Liga - East	Kalisz	ŁKS Łódź II	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:52.926179	\N	\N	0	0	draw	yes
1142	1395862	2025-08-30	Poland	II Liga - East	Śląsk Wrocław II	Stal Stalowa Wola	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:53.017332	\N	\N	2	2	draw	yes
1143	1395856	2025-08-30	Poland	II Liga - East	Jastrzębie	Warta Poznań	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:53.108003	\N	\N	1	0	h-win	yes
1144	1395864	2025-08-31	Poland	II Liga - East	Zaglebie Sosnowiec	Olimpia Grudziądz	draw	3	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:53.207717	\N	\N	1	2	a-win	yes
1145	1395860	2025-08-31	Poland	II Liga - East	Sandecja Nowy Sącz	Chojniczanka Chojnice	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:53.34622	\N	\N	1	1	draw	yes
1146	1395863	2025-09-03	Poland	II Liga - East	Świt Skolwin	Sokół Kleczew	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:53.430371	\N	\N	1	1	draw	yes
1147	1395871	2025-09-05	Poland	II Liga - East	Resovia Rzeszów	Śląsk Wrocław II	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:53.522022	\N	\N	1	1	draw	yes
1148	1395870	2025-09-06	Poland	II Liga - East	Podhale Nowy Targ	Unia Skierniewice	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:53.609326	\N	\N	1	0	h-win	yes
1149	1395865	2025-09-06	Poland	II Liga - East	Rekord Bielsko-Biała	Kalisz	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:53.698422	\N	\N	0	1	a-win	yes
1150	1395873	2025-09-07	Poland	II Liga - East	Warta Poznań	Zaglebie Sosnowiec	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:53.788084	\N	\N	0	0	draw	yes
1151	1395872	2025-09-07	Poland	II Liga - East	Stal Stalowa Wola	Świt Skolwin	h-win	5	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:53.878368	\N	\N	2	2	draw	yes
1152	1395877	2025-09-12	Poland	II Liga - East	Sokół Kleczew	Podhale Nowy Targ	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:53.970701	\N	\N	0	1	a-win	yes
1153	1395878	2025-09-12	Poland	II Liga - East	ŁKS Łódź II	Olimpia Grudziądz	a-win	2	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:54.068427	\N	\N	1	2	a-win	yes
1154	1395880	2025-09-12	Poland	II Liga - East	Unia Skierniewice	Hutnik Kraków	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:54.160703	\N	\N	1	0	h-win	yes
1155	1395875	2025-09-13	Poland	II Liga - East	Jastrzębie	Chojniczanka Chojnice	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:54.266677	\N	\N	0	0	draw	yes
1156	1395874	2025-09-13	Poland	II Liga - East	Rekord Bielsko-Biała	Zaglebie Sosnowiec	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:54.346478	\N	\N	1	2	a-win	yes
1157	1395879	2025-09-13	Poland	II Liga - East	Sandecja Nowy Sącz	Stal Stalowa Wola	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:54.441189	\N	\N	1	1	draw	yes
1158	1395882	2025-09-14	Poland	II Liga - East	Świt Skolwin	Resovia Rzeszów	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:54.53541	\N	\N	1	1	draw	yes
1159	1395881	2025-09-14	Poland	II Liga - East	Śląsk Wrocław II	Warta Poznań	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:54.628296	\N	\N	0	0	draw	yes
1160	1395876	2025-09-14	Poland	II Liga - East	Kalisz	Podbeskidzie	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:54.711987	\N	\N	0	1	a-win	yes
1161	1395868	2025-09-16	Poland	II Liga - East	ŁKS Łódź II	Sandecja Nowy Sącz	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:54.801607	\N	\N	1	0	h-win	yes
1162	1395867	2025-09-17	Poland	II Liga - East	Hutnik Kraków	Jastrzębie	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:54.88236	\N	\N	0	0	draw	yes
1163	1395866	2025-09-17	Poland	II Liga - East	Chojniczanka Chojnice	Sokół Kleczew	a-win	1	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:54.962166	\N	\N	0	1	a-win	yes
1164	1395869	2025-09-17	Poland	II Liga - East	Olimpia Grudziądz	Podbeskidzie	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:55.05511	\N	\N	0	0	draw	yes
1165	1395891	2025-09-19	Poland	II Liga - East	Zaglebie Sosnowiec	Świt Skolwin	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:55.146284	\N	\N	0	0	draw	yes
1166	1395889	2025-09-19	Poland	II Liga - East	Stal Stalowa Wola	ŁKS Łódź II	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:55.236512	\N	\N	1	1	draw	yes
1167	1395890	2025-09-20	Poland	II Liga - East	Warta Poznań	Sokół Kleczew	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:55.321946	\N	\N	2	1	h-win	yes
1168	1395884	2025-09-20	Poland	II Liga - East	Hutnik Kraków	Rekord Bielsko-Biała	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:55.420477	\N	\N	0	0	draw	yes
1169	1395883	2025-09-20	Poland	II Liga - East	Chojniczanka Chojnice	Śląsk Wrocław II	a-win	2	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:55.526197	\N	\N	1	0	h-win	yes
1170	1395886	2025-09-20	Poland	II Liga - East	Podbeskidzie	Unia Skierniewice	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:55.631178	\N	\N	2	0	h-win	yes
1171	1395885	2025-09-20	Poland	II Liga - East	Olimpia Grudziądz	Jastrzębie	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:55.711429	\N	\N	1	0	h-win	yes
1172	1395887	2025-09-21	Poland	II Liga - East	Podhale Nowy Targ	Kalisz	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:55.796745	\N	\N	1	1	draw	yes
1173	1395888	2025-09-21	Poland	II Liga - East	Resovia Rzeszów	Sandecja Nowy Sącz	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:55.882465	\N	\N	0	1	a-win	yes
1174	1395900	2025-09-26	Poland	II Liga - East	Warta Poznań	Stal Stalowa Wola	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:55.982136	\N	\N	1	0	h-win	yes
1175	1395894	2025-09-27	Poland	II Liga - East	Kalisz	Olimpia Grudziądz	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:56.062318	\N	\N	0	0	draw	yes
1176	1395898	2025-09-27	Poland	II Liga - East	Śląsk Wrocław II	Podhale Nowy Targ	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:56.146004	\N	\N	0	0	draw	yes
1177	1395899	2025-09-27	Poland	II Liga - East	Świt Skolwin	Chojniczanka Chojnice	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:56.231836	\N	\N	1	1	draw	yes
1178	1395897	2025-09-27	Poland	II Liga - East	Sandecja Nowy Sącz	Unia Skierniewice	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:56.311519	\N	\N	1	1	draw	yes
1179	1395895	2025-09-28	Poland	II Liga - East	Sokół Kleczew	Hutnik Kraków	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:56.393111	\N	\N	2	0	h-win	yes
1180	1395893	2025-09-28	Poland	II Liga - East	Jastrzębie	Resovia Rzeszów	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:56.47282	\N	\N	0	0	draw	yes
1181	1396048	2025-09-28	Poland	II Liga - East	Podbeskidzie	Rekord Bielsko-Biała	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:56.553122	\N	\N	1	2	a-win	yes
1182	1395896	2025-09-29	Poland	II Liga - East	ŁKS Łódź II	Zaglebie Sosnowiec	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:56.635167	\N	\N	1	2	a-win	yes
1183	1395902	2025-10-03	Poland	II Liga - East	Kalisz	Sandecja Nowy Sącz	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:56.719003	\N	\N	1	0	h-win	yes
1184	1395905	2025-10-04	Poland	II Liga - East	Podhale Nowy Targ	ŁKS Łódź II	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:56.80098	\N	\N	1	0	h-win	yes
1185	1395904	2025-10-04	Poland	II Liga - East	Podbeskidzie	Warta Poznań	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:56.890746	\N	\N	0	1	a-win	yes
1186	1395907	2025-10-04	Poland	II Liga - East	Unia Skierniewice	Śląsk Wrocław II	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:56.991595	\N	\N	0	1	a-win	yes
1187	1395908	2025-10-05	Poland	II Liga - East	Stal Stalowa Wola	Chojniczanka Chojnice	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:57.0707	\N	\N	1	1	draw	yes
1188	1395901	2025-10-05	Poland	II Liga - East	Hutnik Kraków	Świt Skolwin	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:57.153074	\N	\N	1	1	draw	yes
1189	1395906	2025-10-05	Poland	II Liga - East	Resovia Rzeszów	Rekord Bielsko-Biała	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:57.236602	\N	\N	1	0	h-win	yes
1190	1395909	2025-10-05	Poland	II Liga - East	Zaglebie Sosnowiec	Jastrzębie	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:57.322987	\N	\N	0	0	draw	yes
1191	1395903	2025-10-05	Poland	II Liga - East	Olimpia Grudziądz	Sokół Kleczew	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:57.405796	\N	\N	0	0	draw	yes
1192	1395914	2025-10-10	Poland	II Liga - East	ŁKS Łódź II	Resovia Rzeszów	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:57.487959	\N	\N	0	0	draw	yes
1193	1395917	2025-10-11	Poland	II Liga - East	Warta Poznań	Olimpia Grudziądz	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:57.567756	\N	\N	1	1	draw	yes
1194	1395916	2025-10-11	Poland	II Liga - East	Świt Skolwin	Podhale Nowy Targ	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:57.64245	\N	\N	2	0	h-win	yes
1195	1395913	2025-10-11	Poland	II Liga - East	Sokół Kleczew	Unia Skierniewice	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:57.730784	\N	\N	0	2	a-win	yes
1196	1395912	2025-10-11	Poland	II Liga - East	Jastrzębie	Kalisz	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:57.807032	\N	\N	0	0	draw	yes
1197	1395910	2025-10-12	Poland	II Liga - East	Rekord Bielsko-Biała	Stal Stalowa Wola	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:57.896749	\N	\N	1	0	h-win	yes
1198	1395927	2025-10-17	Poland	II Liga - East	Warta Poznań	Hutnik Kraków	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:57.98687	\N	\N	1	0	h-win	yes
1199	1395924	2025-10-17	Poland	II Liga - East	Unia Skierniewice	Jastrzębie	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:58.077564	\N	\N	1	0	h-win	yes
1200	1395923	2025-10-18	Poland	II Liga - East	Podhale Nowy Targ	Sandecja Nowy Sącz	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:58.490706	\N	\N	1	0	h-win	yes
1201	1395925	2025-10-18	Poland	II Liga - East	Śląsk Wrocław II	Sokół Kleczew	a-win	2	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:58.571706	\N	\N	0	3	a-win	yes
1202	1395919	2025-10-18	Poland	II Liga - East	Kalisz	Resovia Rzeszów	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:58.66044	\N	\N	0	0	draw	yes
1203	1395921	2025-10-19	Poland	II Liga - East	Olimpia Grudziądz	Chojniczanka Chojnice	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:58.745269	\N	\N	1	1	draw	yes
1204	1395922	2025-10-19	Poland	II Liga - East	Podbeskidzie	Świt Skolwin	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:58.831546	\N	\N	0	0	draw	yes
1205	1395920	2025-10-19	Poland	II Liga - East	ŁKS Łódź II	Rekord Bielsko-Biała	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:58.91078	\N	\N	0	2	a-win	yes
1206	1395926	2025-10-19	Poland	II Liga - East	Stal Stalowa Wola	Zaglebie Sosnowiec	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:59.045283	\N	\N	0	0	draw	yes
1207	1395915	2025-10-21	Poland	II Liga - East	Sandecja Nowy Sącz	Śląsk Wrocław II	a-win	0	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:59.172691	\N	\N	0	2	a-win	yes
1208	1395911	2025-10-22	Poland	II Liga - East	Chojniczanka Chojnice	Hutnik Kraków	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:59.262041	\N	\N	1	1	draw	yes
1209	1395918	2025-10-22	Poland	II Liga - East	Zaglebie Sosnowiec	Podbeskidzie	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:59.356719	\N	\N	1	0	h-win	yes
1210	1395936	2025-10-24	Poland	II Liga - East	Świt Skolwin	ŁKS Łódź II	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:59.443232	\N	\N	2	0	h-win	yes
1211	1395932	2025-10-24	Poland	II Liga - East	Kalisz	Śląsk Wrocław II	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:59.525558	\N	\N	0	0	draw	yes
1212	1395931	2025-10-25	Poland	II Liga - East	Hutnik Kraków	Zaglebie Sosnowiec	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:59.606382	\N	\N	0	0	draw	yes
1213	1395930	2025-10-25	Poland	II Liga - East	Jastrzębie	Podbeskidzie	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:59.696999	\N	\N	1	1	draw	yes
1214	1395928	2025-10-25	Poland	II Liga - East	Rekord Bielsko-Biała	Olimpia Grudziądz	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:59.776337	\N	\N	0	2	a-win	yes
1215	1395929	2025-10-25	Poland	II Liga - East	Chojniczanka Chojnice	Podhale Nowy Targ	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:59.856964	\N	\N	0	0	draw	yes
1216	1395933	2025-10-26	Poland	II Liga - East	Sokół Kleczew	Stal Stalowa Wola	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:04:59.943485	\N	\N	1	0	h-win	yes
1217	1395935	2025-10-26	Poland	II Liga - East	Sandecja Nowy Sącz	Warta Poznań	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:05:00.034965	\N	\N	0	0	draw	yes
1218	1395934	2025-10-26	Poland	II Liga - East	Resovia Rzeszów	Unia Skierniewice	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:05:00.127924	\N	\N	0	1	a-win	yes
1219	1395938	2025-10-31	Poland	II Liga - East	Sokół Kleczew	Podbeskidzie	h-win	5	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:05:00.212346	\N	\N	3	1	h-win	yes
1220	1395937	2025-10-31	Poland	II Liga - East	Rekord Bielsko-Biała	Jastrzębie	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:05:00.297766	\N	\N	1	2	a-win	yes
1221	1395942	2025-10-31	Poland	II Liga - East	Śląsk Wrocław II	Świt Skolwin	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:05:00.382837	\N	\N	2	1	h-win	yes
1222	1395943	2025-10-31	Poland	II Liga - East	Stal Stalowa Wola	Resovia Rzeszów	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:05:00.467243	\N	\N	0	0	draw	yes
1223	1395944	2025-10-31	Poland	II Liga - East	Warta Poznań	Kalisz	h-win	4	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:05:00.556073	\N	\N	0	1	a-win	yes
1224	1395941	2025-10-31	Poland	II Liga - East	Unia Skierniewice	ŁKS Łódź II	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:05:00.637162	\N	\N	2	0	h-win	yes
1225	1395945	2025-10-31	Poland	II Liga - East	Zaglebie Sosnowiec	Chojniczanka Chojnice	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-12-01 23:05:00.726639	\N	\N	0	0	draw	yes
1226	1395940	2025-11-02	Poland	II Liga - East	Podhale Nowy Targ	Hutnik Kraków	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	14	2025-12-01 23:05:00.955637	\N	\N	0	0	draw	yes
1227	1395939	2025-11-02	Poland	II Liga - East	Olimpia Grudziądz	Sandecja Nowy Sącz	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	11	2025-12-01 23:05:01.046733	\N	\N	1	0	h-win	yes
1228	1395946	2025-11-07	Poland	II Liga - East	Chojniczanka Chojnice	Unia Skierniewice	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	10	1	2025-12-01 23:05:01.14664	\N	\N	0	1	a-win	yes
1229	1395952	2025-11-07	Poland	II Liga - East	Sandecja Nowy Sącz	Sokół Kleczew	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	11	12	2025-12-01 23:05:01.239029	\N	\N	0	1	a-win	yes
1230	1395947	2025-11-08	Poland	II Liga - East	Jastrzębie	Stal Stalowa Wola	a-win	1	5	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	18	6	2025-12-01 23:05:01.321787	\N	\N	0	2	a-win	yes
1231	1395953	2025-11-08	Poland	II Liga - East	Świt Skolwin	Rekord Bielsko-Biała	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	15	2025-12-01 23:05:01.409082	\N	\N	1	2	a-win	yes
1232	1395954	2025-11-08	Poland	II Liga - East	Warta Poznań	Podhale Nowy Targ	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	3	2025-12-01 23:05:01.49729	\N	\N	0	0	draw	yes
1233	1395948	2025-11-09	Poland	II Liga - East	Hutnik Kraków	Olimpia Grudziądz	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	14	4	2025-12-01 23:05:01.582277	\N	\N	1	1	draw	yes
1234	1395951	2025-11-09	Poland	II Liga - East	Podbeskidzie	Resovia Rzeszów	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8	7	2025-12-01 23:05:01.671601	\N	\N	1	0	h-win	yes
1235	1395949	2025-11-09	Poland	II Liga - East	Kalisz	Zaglebie Sosnowiec	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16	13	2025-12-01 23:05:01.771399	\N	\N	1	0	h-win	yes
1236	1395950	2025-11-10	Poland	II Liga - East	ŁKS Łódź II	Śląsk Wrocław II	a-win	1	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	17	9	2025-12-01 23:05:01.859688	\N	\N	0	2	a-win	yes
1237	1395962	2025-11-14	Poland	II Liga - East	Stal Stalowa Wola	Hutnik Kraków	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	14	2025-12-01 23:05:01.944883	\N	\N	1	1	draw	yes
1238	1395957	2025-11-15	Poland	II Liga - East	Olimpia Grudziądz	Świt Skolwin	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	5	2025-12-01 23:05:02.046516	\N	\N	0	1	a-win	yes
1239	1395958	2025-11-16	Poland	II Liga - East	Podhale Nowy Targ	Podbeskidzie	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	8	2025-12-01 23:05:02.128103	\N	\N	1	0	h-win	yes
1240	1395961	2025-11-16	Poland	II Liga - East	Śląsk Wrocław II	Jastrzębie	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	18	2025-12-01 23:05:02.229799	\N	\N	1	2	a-win	yes
1241	1395955	2025-11-16	Poland	II Liga - East	Rekord Bielsko-Biała	Chojniczanka Chojnice	a-win	0	5	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	15	10	2025-12-01 23:05:02.317631	\N	\N	0	3	a-win	yes
1242	1395960	2025-11-16	Poland	II Liga - East	Unia Skierniewice	Kalisz	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	16	2025-12-01 23:05:02.397971	\N	\N	1	1	draw	yes
1243	1395959	2025-11-16	Poland	II Liga - East	Resovia Rzeszów	Warta Poznań	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7	2	2025-12-01 23:05:02.485626	\N	\N	0	1	a-win	yes
1244	1395968	2025-11-21	Poland	II Liga - East	ŁKS Łódź II	Hutnik Kraków	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	17	14	2025-12-01 23:05:02.567884	\N	\N	0	0	draw	yes
1245	1395972	2025-11-21	Poland	II Liga - East	Zaglebie Sosnowiec	Sokół Kleczew	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	13	12	2025-12-01 23:05:02.652335	\N	\N	0	1	a-win	yes
1246	1395967	2025-11-22	Poland	II Liga - East	Kalisz	Świt Skolwin	a-win	3	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16	5	2025-12-01 23:05:02.741897	\N	\N	0	1	a-win	yes
1247	1395966	2025-11-22	Poland	II Liga - East	Jastrzębie	Podhale Nowy Targ	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	18	3	2025-12-01 23:05:02.822468	\N	\N	0	2	a-win	yes
1248	1395964	2025-11-22	Poland	II Liga - East	Rekord Bielsko-Biała	Śląsk Wrocław II	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	15	9	2025-12-01 23:05:02.938257	\N	\N	0	1	a-win	yes
1249	1395971	2025-11-22	Poland	II Liga - East	Warta Poznań	Unia Skierniewice	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	1	2025-12-01 23:05:03.031083	\N	\N	0	1	a-win	yes
1250	1395965	2025-11-22	Poland	II Liga - East	Chojniczanka Chojnice	Resovia Rzeszów	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	10	7	2025-12-01 23:05:03.130253	\N	\N	1	0	h-win	yes
1251	1395969	2025-11-23	Poland	II Liga - East	Sandecja Nowy Sącz	Podbeskidzie	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	11	8	2025-12-01 23:05:03.221273	\N	\N	0	0	draw	yes
1252	1395970	2025-11-23	Poland	II Liga - East	Stal Stalowa Wola	Olimpia Grudziądz	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	4	2025-12-01 23:05:03.309853	\N	\N	1	0	h-win	yes
1253	1395979	2025-11-28	Poland	II Liga - East	Resovia Rzeszów	Zaglebie Sosnowiec	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7	13	2025-12-01 23:05:03.395496	\N	\N	1	0	h-win	yes
1254	1395981	2025-11-29	Poland	II Liga - East	Warta Poznań	Chojniczanka Chojnice	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	10	2025-12-01 23:05:03.48794	\N	\N	1	0	h-win	yes
1255	1395978	2025-11-29	Poland	II Liga - East	Podhale Nowy Targ	Rekord Bielsko-Biała	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	15	2025-12-01 23:05:03.576201	\N	\N	1	0	h-win	yes
1256	1395975	2025-11-29	Poland	II Liga - East	ŁKS Łódź II	Jastrzębie	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	17	18	2025-12-01 23:05:03.663844	\N	\N	0	0	draw	yes
1257	1395976	2025-11-30	Poland	II Liga - East	Olimpia Grudziądz	Unia Skierniewice	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	1	2025-12-01 23:05:03.765279	\N	\N	0	0	draw	yes
1258	1395980	2025-11-30	Poland	II Liga - East	Świt Skolwin	Sandecja Nowy Sącz	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	11	2025-12-01 23:05:03.855491	\N	\N	0	0	draw	yes
1259	1395973	2025-11-30	Poland	II Liga - East	Hutnik Kraków	Śląsk Wrocław II	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	14	9	2025-12-01 23:05:03.937113	\N	\N	1	0	h-win	yes
1260	1395974	2025-11-30	Poland	II Liga - East	Sokół Kleczew	Kalisz	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	16	2025-12-01 23:05:04.016832	\N	\N	0	0	draw	yes
1261	1395977	2025-11-30	Poland	II Liga - East	Podbeskidzie	Stal Stalowa Wola	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8	6	2025-12-01 23:05:04.102692	\N	\N	1	1	draw	yes
1262	1395963	2025-11-15	Poland	II Liga - East	Zaglebie Sosnowiec	Sandecja Nowy Sącz	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	13	11	2025-12-01 23:05:04.190919	\N	\N	0	0	draw	no
\.


--
-- Name: import_jobs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.import_jobs_id_seq', 17, true);


--
-- Name: matches_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.matches_id_seq', 1262, true);


--
-- Name: _prisma_migrations _prisma_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public._prisma_migrations
    ADD CONSTRAINT _prisma_migrations_pkey PRIMARY KEY (id);


--
-- Name: import_jobs import_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.import_jobs
    ADD CONSTRAINT import_jobs_pkey PRIMARY KEY (id);


--
-- Name: matches matches_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.matches
    ADD CONSTRAINT matches_pkey PRIMARY KEY (id);


--
-- Name: idx_import_jobs_job_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_import_jobs_job_type ON public.import_jobs USING btree (job_type);


--
-- Name: idx_matches_country_league; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_matches_country_league ON public.matches USING btree (country, league);


--
-- Name: idx_matches_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_matches_created_at ON public.matches USING btree (created_at);


--
-- Name: idx_matches_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_matches_date ON public.matches USING btree (match_date);


--
-- Name: idx_matches_fixture_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_matches_fixture_id ON public.matches USING btree (fixture_id);


--
-- Name: idx_matches_teams; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_matches_teams ON public.matches USING btree (home_team, away_team);


--
-- Name: import_jobs_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX import_jobs_created_at_idx ON public.import_jobs USING btree (created_at DESC);


--
-- Name: import_jobs_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX import_jobs_status_idx ON public.import_jobs USING btree (status);


--
-- Name: matches_fixture_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX matches_fixture_id_key ON public.matches USING btree (fixture_id);


--
-- PostgreSQL database dump complete
--

\unrestrict I2BzrQBFX4tEn9SHfO4GiFolpZsUUnDp6DhPqx1BVtTbYIUzxfFQR1izvKgPZUd

