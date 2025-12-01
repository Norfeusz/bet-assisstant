--
-- PostgreSQL database dump
--

\restrict VC8UA6JwLNA2m3PQIHq1KLOnR8pIBp4aClSGZUFvKQKPuOUfKculDcLlrOMyppw

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
8	["2"]	2025-07-01	2025-12-01	pending	{}	0	0	0	7500	\N	\N	\N	\N	2025-12-01 18:48:57.981997+01	2025-12-01 18:48:57.981997+01	f	new_matches
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
\.


--
-- Name: import_jobs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.import_jobs_id_seq', 8, true);


--
-- Name: matches_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.matches_id_seq', 143, true);


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

\unrestrict VC8UA6JwLNA2m3PQIHq1KLOnR8pIBp4aClSGZUFvKQKPuOUfKculDcLlrOMyppw

