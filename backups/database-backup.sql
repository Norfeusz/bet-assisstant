--
-- PostgreSQL database dump
--

\restrict at3PF190QJfncTuMgoIwnligdJLNYB8qPeAvfb26DTM5OGVbnGmdNgvwD1pPpVw

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
DROP TYPE IF EXISTS public.job_status_enum;
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
    hidden boolean DEFAULT false
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
877a639a-93fa-406b-81c9-ce0fde411e4f	7b5829a6dea4b805e9108097566411c8d1f50e5be68f7d2689b82e2a7e3061e7	2025-11-19 21:28:18.359529+01	20251111000000_initial_schema	\N	\N	2025-11-19 21:28:18.329161+01	1
\.


--
-- Data for Name: import_jobs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.import_jobs (id, leagues, date_from, date_to, status, progress, total_matches, imported_matches, failed_matches, rate_limit_remaining, rate_limit_reset_at, error_message, started_at, completed_at, created_at, updated_at, hidden) FROM stdin;
31	["2", "3", "15", "531", "848", "106", "107", "109", "39", "42", "40", "41", "45", "43"]	2025-08-01	2025-11-24	completed	{"completed_leagues": [2, 3, 15, 531, 848, 106, 107, 109, 39, 42, 40, 41, 45, 43]}	0	1963	0	299	\N	\N	\N	2025-11-20 21:06:09.228523+01	2025-11-20 15:01:47.594723+01	2025-11-20 21:06:09.228523+01	f
33	["135", "136", "137", "138", "942", "943"]	2025-08-01	2025-11-24	in_queue	{}	0	0	0	7500	\N	\N	\N	\N	2025-11-20 20:38:32.849411+01	2025-11-20 20:38:32.849411+01	f
32	["140", "141", "436", "435", "875", "876", "877", "878", "879", "143"]	2025-08-01	2025-11-24	pending	{}	0	0	0	7500	\N	\N	\N	\N	2025-11-20 15:40:40.415306+01	2025-11-20 21:06:09.235223+01	f
\.


--
-- Data for Name: matches; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.matches (id, fixture_id, match_date, country, league, home_team, away_team, result, home_goals, away_goals, home_shots, home_shots_on_target, away_shots, away_shots_on_target, home_corners, away_corners, home_offsides, away_offsides, home_y_cards, away_y_cards, home_r_cards, away_r_cards, home_possession, away_possession, home_fouls, away_fouls, home_odds, draw_odds, away_odds, standing_home, standing_away, created_at, home_xg, away_xg, home_goals_ht, away_goals_ht, result_ht, is_finished) FROM stdin;
2043	1391400	2025-07-06	Uruguay	Primera División - Apertura	Penarol	Club Nacional	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	\N	2025-11-20 10:19:57.845785	\N	\N	0	0	draw	yes
2044	1486756	2025-07-06	Uruguay	Primera División - Clausura	Penarol	Club Nacional	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	2	2025-11-20 10:19:59.20269	\N	\N	0	0	draw	yes
5	1383426	2025-07-08	World	UEFA Champions League	Olimpija Ljubljana	Kairat Almaty	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	34	2025-11-19 23:20:50.320481	\N	\N	0	0	draw	yes
6	1383428	2025-07-08	World	UEFA Champions League	The New Saints	Shkendija	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:20:50.508756	\N	\N	0	0	draw	yes
7	1383429	2025-07-08	World	UEFA Champions League	Vikingur Gota	Lincoln Red Imps FC	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:20:50.691041	\N	\N	2	3	a-win	yes
8	1383427	2025-07-08	World	UEFA Champions League	Drita	FC Differdange 03	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:20:50.896063	\N	\N	0	0	draw	yes
10	1383430	2025-07-08	World	UEFA Champions League	Virtus	Zrinjski	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:20:51.265532	\N	\N	0	1	a-win	yes
11	1383432	2025-07-09	World	UEFA Champions League	FK Zalgiris Vilnius	Hamrun Spartans	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:20:51.439457	\N	\N	0	0	draw	yes
12	1383434	2025-07-09	World	UEFA Champions League	FCSB	Inter Club d'Escaldes	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:20:51.614466	\N	\N	2	0	h-win	yes
13	1383433	2025-07-09	World	UEFA Champions League	Ludogorets	Dinamo Minsk	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:20:51.784476	\N	\N	0	0	draw	yes
14	1383435	2025-07-09	World	UEFA Champions League	Shelbourne	Linfield	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:20:52.000291	\N	\N	0	0	draw	yes
15	1383436	2025-07-15	World	UEFA Champions League	Kairat Almaty	Olimpija Ljubljana	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	34	\N	2025-11-19 23:20:52.170823	\N	\N	2	0	h-win	yes
16	1383437	2025-07-15	World	UEFA Champions League	Lincoln Red Imps FC	Vikingur Gota	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:20:52.321092	\N	\N	0	0	draw	yes
17	1383440	2025-07-15	World	UEFA Champions League	Malmo FF	Saburtalo	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:20:52.491383	\N	\N	0	0	draw	yes
18	1383438	2025-07-15	World	UEFA Champions League	Milsami Orhei	KuPS	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:20:52.664887	\N	\N	0	0	draw	yes
19	1383441	2025-07-15	World	UEFA Champions League	Rīgas FS	FC Levadia Tallinn	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:20:52.85558	\N	\N	0	0	draw	yes
20	1383439	2025-07-15	World	UEFA Champions League	Hamrun Spartans	FK Zalgiris Vilnius	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:20:53.033747	\N	\N	2	0	h-win	yes
21	1383443	2025-07-15	World	UEFA Champions League	Shkendija	The New Saints	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:20:53.216136	\N	\N	1	1	draw	yes
22	1383442	2025-07-15	World	UEFA Champions League	FC Differdange 03	Drita	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:20:53.386781	\N	\N	1	2	a-win	yes
23	1383444	2025-07-15	World	UEFA Champions League	Inter Club d'Escaldes	FCSB	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:20:53.545759	\N	\N	0	0	draw	yes
24	1383446	2025-07-15	World	UEFA Champions League	Breidablik	Egnatia Rrogozhinë	h-win	5	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:20:53.746379	\N	\N	4	0	h-win	yes
25	1383447	2025-07-15	World	UEFA Champions League	Buducnost Podgorica	FC Noah	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:20:53.905708	\N	\N	0	2	a-win	yes
26	1383445	2025-07-15	World	UEFA Champions League	Zrinjski	Virtus	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:20:54.070863	\N	\N	1	0	h-win	yes
27	1383449	2025-07-16	World	UEFA Champions League	Dinamo Minsk	Ludogorets	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:20:54.257462	\N	\N	0	1	a-win	yes
28	1383448	2025-07-16	World	UEFA Champions League	Linfield	Shelbourne	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:20:54.508317	\N	\N	1	1	draw	yes
29	1405443	2025-07-22	World	UEFA Champions League	KuPS	Kairat Almaty	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	34	2025-11-19 23:20:54.693666	\N	\N	0	0	draw	yes
30	1405445	2025-07-22	World	UEFA Champions League	Lincoln Red Imps FC	FK Crvena Zvezda	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:20:54.88223	\N	\N	0	1	a-win	yes
31	1405446	2025-07-22	World	UEFA Champions League	FC Noah	Ferencvarosi TC	a-win	1	2	10	3	10	5	2	5	1	0	2	0	0	1	56.00	44.00	11	9	\N	\N	\N	\N	\N	2025-11-19 23:20:55.058148	\N	\N	1	1	draw	yes
32	1405448	2025-07-22	World	UEFA Champions League	FC Copenhagen	Drita	h-win	2	0	16	5	8	1	6	3	1	1	1	3	0	0	65.00	35.00	9	10	\N	\N	\N	33	\N	2025-11-19 23:20:55.242616	\N	\N	0	0	draw	yes
34	1383451	2025-07-22	World	UEFA Champions League	Pafos	Maccabi Tel Aviv	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	20	\N	2025-11-19 23:20:55.598485	\N	\N	0	0	draw	yes
35	1405447	2025-07-22	World	UEFA Champions League	Rīgas FS	Malmo FF	a-win	1	4	\N	\N	\N	\N	\N	\N	\N	\N	0	0	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:20:55.764801	\N	\N	1	2	a-win	yes
36	1405449	2025-07-22	World	UEFA Champions League	Hamrun Spartans	Dynamo Kyiv	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:20:55.949761	\N	\N	0	1	a-win	yes
37	1405450	2025-07-22	World	UEFA Champions League	Shkendija	FCSB	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:20:56.121	\N	\N	0	0	draw	yes
38	1405451	2025-07-22	World	UEFA Champions League	Slovan Bratislava	Zrinjski	h-win	4	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:20:56.311431	\N	\N	2	0	h-win	yes
39	1405452	2025-07-22	World	UEFA Champions League	Lech Poznan	Breidablik	h-win	7	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:20:56.509865	\N	\N	5	1	h-win	yes
40	1383452	2025-07-22	World	UEFA Champions League	Rangers	Panathinaikos	h-win	2	0	16	5	14	4	3	6	1	0	2	2	0	1	75.00	25.00	10	12	\N	\N	\N	\N	\N	2025-11-19 23:20:56.718663	\N	\N	0	0	draw	yes
41	1405453	2025-07-22	World	UEFA Champions League	HNK Rijeka	Ludogorets	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:20:56.884763	\N	\N	0	0	draw	yes
42	1383453	2025-07-23	World	UEFA Champions League	Brann	Red Bull Salzburg	a-win	1	4	8	2	22	10	1	7	1	5	4	1	0	0	47.00	53.00	10	18	\N	\N	\N	\N	\N	2025-11-19 23:20:57.083243	\N	\N	1	0	h-win	yes
43	1405444	2025-07-23	World	UEFA Champions League	Shelbourne	Qarabag	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	15	2025-11-19 23:20:57.26539	\N	\N	0	1	a-win	yes
44	1405454	2025-07-29	World	UEFA Champions League	Kairat Almaty	KuPS	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	34	\N	2025-11-19 23:20:57.432305	\N	\N	3	0	h-win	yes
45	1405457	2025-07-29	World	UEFA Champions League	Dynamo Kyiv	Hamrun Spartans	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:20:57.607937	\N	\N	2	0	h-win	yes
46	1405456	2025-07-29	World	UEFA Champions League	Drita	FC Copenhagen	a-win	0	1	9	2	9	4	3	5	0	2	0	3	1	0	36.00	64.00	13	19	\N	\N	\N	\N	33	2025-11-19 23:20:57.790169	\N	\N	0	1	a-win	yes
47	1405458	2025-07-29	World	UEFA Champions League	Zrinjski	Slovan Bratislava	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:20:57.957072	\N	\N	0	0	draw	yes
48	1405459	2025-07-29	World	UEFA Champions League	FK Crvena Zvezda	Lincoln Red Imps FC	h-win	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:20:58.155758	\N	\N	4	0	h-win	yes
49	1405460	2025-07-30	World	UEFA Champions League	Qarabag	Shelbourne	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	15	\N	2025-11-19 23:20:58.335498	\N	\N	1	0	h-win	yes
50	1405461	2025-07-30	World	UEFA Champions League	Malmo FF	Rīgas FS	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:20:58.505004	\N	\N	1	0	h-win	yes
51	1405462	2025-07-30	World	UEFA Champions League	FCSB	Shkendija	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:20:58.68141	\N	\N	1	1	draw	yes
52	1405455	2025-07-30	World	UEFA Champions League	Ludogorets	HNK Rijeka	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:20:58.848722	\N	\N	1	0	h-win	yes
2	1383423	2025-07-08	World	UEFA Champions League	Saburtalo	Malmo FF	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:20:49.811469	\N	\N	0	1	a-win	yes
3	1383424	2025-07-08	World	UEFA Champions League	FC Noah	Buducnost Podgorica	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:20:49.978366	\N	\N	0	0	draw	yes
4	1383425	2025-07-08	World	UEFA Champions League	FC Levadia Tallinn	Rīgas FS	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:20:50.157313	\N	\N	0	0	draw	yes
2045	1326509	2025-07-04	USA	Major League Soccer	New York City FC	Toronto FC	h-win	3	1	11	6	10	2	5	6	0	1	1	4	0	0	55.00	45.00	10	12	\N	\N	\N	\N	\N	2025-11-20 10:20:00.582998	1.66	1.38	1	0	h-win	yes
57	1383456	2025-07-30	World	UEFA Champions League	Red Bull Salzburg	Brann	draw	1	1	11	4	10	5	2	2	2	3	5	6	0	0	37.00	63.00	19	11	\N	\N	\N	\N	\N	2025-11-19 23:20:59.695872	\N	\N	1	1	draw	yes
58	1383457	2025-07-30	World	UEFA Champions League	Servette FC	Plzen	a-win	1	3	17	5	14	8	8	4	1	1	4	1	1	1	59.00	41.00	11	11	\N	\N	\N	\N	\N	2025-11-19 23:20:59.916687	\N	\N	1	2	a-win	yes
59	1383540	2025-07-10	World	UEFA Europa League	Sabah FA	Celje	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	0	2	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:01.312604	\N	\N	2	1	h-win	yes
60	1383541	2025-07-10	World	UEFA Europa League	AEK Larnaca	FK Partizan	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	1	2	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:01.494904	\N	\N	0	0	draw	yes
61	1383543	2025-07-10	World	UEFA Europa League	Sheriff Tiraspol	Prishtina	h-win	4	0	\N	\N	\N	\N	\N	\N	\N	\N	0	2	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:01.680431	\N	\N	2	0	h-win	yes
56	1405464	2025-07-30	World	UEFA Champions League	Breidablik	Lech Poznan	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:20:59.520733	\N	\N	0	1	a-win	yes
62	1383542	2025-07-10	World	UEFA Europa League	Paks	CFR 1907 Cluj	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	2	1	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:01.874184	\N	\N	0	0	draw	yes
63	1383544	2025-07-10	World	UEFA Europa League	Levski Sofia	Hapoel Beer Sheva	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	3	5	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:02.078174	\N	\N	0	0	draw	yes
64	1383545	2025-07-10	World	UEFA Europa League	Shakhtar Donetsk	Ilves	h-win	6	0	\N	\N	\N	\N	\N	\N	\N	\N	0	0	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:02.268115	\N	\N	2	0	h-win	yes
65	1383546	2025-07-10	World	UEFA Europa League	Spartak Trnava	BK Hacken	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	5	2	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:02.465338	\N	\N	0	0	draw	yes
66	1383547	2025-07-10	World	UEFA Europa League	Legia Warszawa	Aktobe	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	0	1	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:02.622573	\N	\N	1	0	h-win	yes
67	1383549	2025-07-17	World	UEFA Europa League	Ilves	Shakhtar Donetsk	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	1	1	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:02.80211	\N	\N	0	0	draw	yes
68	1383548	2025-07-17	World	UEFA Europa League	Aktobe	Legia Warszawa	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	3	0	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:02.958125	\N	\N	0	0	draw	yes
69	1383551	2025-07-17	World	UEFA Europa League	BK Hacken	Spartak Trnava	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	3	2	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:03.152092	\N	\N	1	0	h-win	yes
70	1383550	2025-07-17	World	UEFA Europa League	CFR 1907 Cluj	Paks	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	2	1	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:03.326733	\N	\N	1	0	h-win	yes
71	1383553	2025-07-17	World	UEFA Europa League	Hapoel Beer Sheva	Levski Sofia	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	4	1	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:03.513055	\N	\N	0	0	draw	yes
72	1383552	2025-07-17	World	UEFA Europa League	Prishtina	Sheriff Tiraspol	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	1	2	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:03.695228	\N	\N	0	0	draw	yes
73	1383554	2025-07-17	World	UEFA Europa League	Celje	Sabah FA	draw	3	3	\N	\N	\N	\N	\N	\N	\N	\N	4	4	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:03.871992	\N	\N	1	1	draw	yes
74	1383555	2025-07-17	World	UEFA Europa League	FK Partizan	AEK Larnaca	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	3	2	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:04.070819	\N	\N	0	0	draw	yes
75	1410068	2025-07-24	World	UEFA Europa League	Sheriff Tiraspol	Utrecht	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	3	1	0	0	\N	\N	\N	\N	\N	\N	\N	\N	32	2025-11-19 23:21:04.256873	\N	\N	1	1	draw	yes
76	1410069	2025-07-24	World	UEFA Europa League	Baník Ostrava	Legia Warszawa	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	1	2	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:04.432999	\N	\N	1	1	draw	yes
77	1383556	2025-07-24	World	UEFA Europa League	FC Midtjylland	Hibernian	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	1	4	0	0	\N	\N	\N	\N	\N	\N	\N	1	\N	2025-11-19 23:21:04.608322	\N	\N	0	1	a-win	yes
78	1410070	2025-07-24	World	UEFA Europa League	Levski Sofia	SC Braga	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	2	3	0	0	\N	\N	\N	\N	\N	\N	\N	\N	5	2025-11-19 23:21:04.79913	\N	\N	0	0	draw	yes
79	1410072	2025-07-24	World	UEFA Europa League	Besiktas	Shakhtar Donetsk	a-win	2	4	\N	\N	\N	\N	\N	\N	\N	\N	3	1	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:04.946696	\N	\N	1	2	a-win	yes
80	1410071	2025-07-24	World	UEFA Europa League	Anderlecht	BK Hacken	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	2	3	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:05.16304	\N	\N	1	0	h-win	yes
81	1410073	2025-07-24	World	UEFA Europa League	Celje	AEK Larnaca	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	3	3	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:05.33709	\N	\N	1	0	h-win	yes
82	1410074	2025-07-24	World	UEFA Europa League	FC Lugano	CFR 1907 Cluj	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	2	2	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:05.51915	\N	\N	0	0	draw	yes
83	1410076	2025-07-31	World	UEFA Europa League	AEK Larnaca	Celje	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	1	1	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:05.680589	\N	\N	1	0	h-win	yes
84	1410077	2025-07-31	World	UEFA Europa League	BK Hacken	Anderlecht	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	1	6	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:05.857985	\N	\N	1	0	h-win	yes
85	1410078	2025-07-31	World	UEFA Europa League	CFR 1907 Cluj	FC Lugano	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	4	4	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:06.038464	\N	\N	0	0	draw	yes
87	1410075	2025-07-31	World	UEFA Europa League	Shakhtar Donetsk	Besiktas	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	6	3	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:06.423628	\N	\N	2	0	h-win	yes
88	1410080	2025-07-31	World	UEFA Europa League	SC Braga	Levski Sofia	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	0	3	0	0	\N	\N	\N	\N	\N	\N	\N	5	\N	2025-11-19 23:21:06.626996	\N	\N	0	0	draw	yes
89	1383557	2025-07-31	World	UEFA Europa League	Hibernian	FC Midtjylland	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	4	3	0	0	\N	\N	\N	\N	\N	\N	\N	\N	1	2025-11-19 23:21:06.789191	\N	\N	0	0	draw	yes
90	1410081	2025-07-31	World	UEFA Europa League	Legia Warszawa	Baník Ostrava	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	3	0	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:07.042358	\N	\N	0	1	a-win	yes
91	1386548	2025-07-01	World	FIFA Club World Cup	Manchester City	Al-Hilal Saudi FC	a-win	3	4	30	15	17	6	19	4	0	2	3	1	0	0	69.00	31.00	17	7	\N	\N	\N	\N	\N	2025-11-19 23:21:08.380785	\N	\N	1	0	h-win	yes
92	1386549	2025-07-01	World	FIFA Club World Cup	Real Madrid	Juventus	h-win	1	0	21	11	6	2	11	4	0	2	1	0	0	0	57.00	43.00	11	5	\N	\N	\N	\N	\N	2025-11-19 23:21:08.567904	\N	\N	0	0	draw	yes
93	1386550	2025-07-02	World	FIFA Club World Cup	Borussia Dortmund	Monterrey	h-win	2	1	6	3	14	7	3	5	5	2	2	0	0	0	42.00	58.00	13	9	\N	\N	\N	\N	\N	2025-11-19 23:21:08.734378	\N	\N	2	0	h-win	yes
94	1390817	2025-07-04	World	FIFA Club World Cup	Fluminense	Al-Hilal Saudi FC	h-win	2	1	10	3	15	4	4	12	3	1	3	4	0	0	43.00	57.00	13	12	\N	\N	\N	\N	\N	2025-11-19 23:21:08.950673	\N	\N	1	0	h-win	yes
95	1390026	2025-07-05	World	FIFA Club World Cup	Palmeiras	Chelsea	a-win	1	2	7	2	19	6	3	10	3	0	1	3	0	0	37.00	63.00	14	16	\N	\N	\N	1	\N	2025-11-19 23:21:09.164077	\N	\N	0	1	a-win	yes
96	1390797	2025-07-05	World	FIFA Club World Cup	Paris Saint Germain	Bayern München	h-win	2	0	11	5	13	5	0	4	0	3	1	1	2	0	46.00	54.00	12	13	\N	\N	\N	\N	\N	2025-11-19 23:21:09.34746	\N	\N	0	0	draw	yes
97	1390818	2025-07-05	World	FIFA Club World Cup	Real Madrid	Borussia Dortmund	h-win	3	2	15	8	12	5	3	3	1	1	1	2	1	0	48.00	52.00	10	6	\N	\N	\N	\N	\N	2025-11-19 23:21:09.503973	\N	\N	2	0	h-win	yes
98	1392812	2025-07-08	World	FIFA Club World Cup	Fluminense	Chelsea	a-win	0	2	12	3	17	5	3	4	2	4	2	1	0	0	46.00	54.00	11	11	\N	\N	\N	\N	\N	2025-11-19 23:21:09.701703	\N	\N	0	1	a-win	yes
54	1383455	2025-07-30	World	UEFA Champions League	Panathinaikos	Rangers	draw	1	1	20	6	10	3	9	5	2	1	1	2	0	0	44.00	56.00	11	13	\N	\N	\N	\N	\N	2025-11-19 23:20:59.162429	\N	\N	0	0	draw	yes
55	1405463	2025-07-30	World	UEFA Champions League	Ferencvarosi TC	FC Noah	h-win	4	3	15	6	10	7	3	1	5	1	2	4	0	0	48.00	52.00	15	14	\N	\N	\N	\N	\N	2025-11-19 23:20:59.340311	\N	\N	2	2	draw	yes
2046	1326510	2025-07-05	USA	Major League Soccer	FC Dallas	Minnesota United FC	a-win	1	2	15	6	16	6	4	8	1	0	1	2	0	0	53.00	47.00	10	10	\N	\N	\N	7	4	2025-11-20 10:20:00.7713	1.30	2.55	0	1	a-win	yes
3999	1419471	2025-08-02	England	FA Cup	AFC Whyteleafe	Chipstead	h-win	5	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.969662	\N	\N	0	0	draw	yes
102	1383459	2025-07-08	World	UEFA Europa Conference League	Floriana	Haverfordwest County AFC	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:12.741173	\N	\N	1	1	draw	yes
103	1383460	2025-07-10	World	UEFA Europa Conference League	Atlètic Club d'Escaldes	F91 Dudelange	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:12.93893	\N	\N	2	0	h-win	yes
104	1383462	2025-07-10	World	UEFA Europa Conference League	Magpies	Paide	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:13.158703	\N	\N	1	2	a-win	yes
105	1383465	2025-07-10	World	UEFA Europa Conference League	Torpedo Kutaisi	Ordabasy	h-win	4	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:13.36467	\N	\N	2	2	draw	yes
106	1383464	2025-07-10	World	UEFA Europa Conference League	SJK	KI Klaksvik	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:13.541026	\N	\N	0	1	a-win	yes
107	1383466	2025-07-10	World	UEFA Europa Conference League	Kauno Žalgiris	Penybont	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:13.739381	\N	\N	2	0	h-win	yes
108	1383467	2025-07-10	World	UEFA Europa Conference League	Racing FC Union Luxembourg	Dila	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:13.917992	\N	\N	0	0	draw	yes
109	1383468	2025-07-10	World	UEFA Europa Conference League	FC Urartu	Neman	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:14.103694	\N	\N	0	0	draw	yes
110	1383469	2025-07-10	World	UEFA Europa Conference League	Kalju Nomme	Partizani	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:14.267051	\N	\N	0	0	draw	yes
111	1383470	2025-07-10	World	UEFA Europa Conference League	Torpedo Zhodino	FK Rabotnicki	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:14.442594	\N	\N	1	0	h-win	yes
112	1383473	2025-07-10	World	UEFA Europa Conference League	Birkirkara	Petrocub	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:14.630204	\N	\N	0	0	draw	yes
113	1383472	2025-07-10	World	UEFA Europa Conference League	Vllaznia Shkodër	BFC Daugavpils	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:14.830555	\N	\N	0	0	draw	yes
114	1383471	2025-07-10	World	UEFA Europa Conference League	Dečić	Sileks	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:15.014536	\N	\N	1	0	h-win	yes
115	1383463	2025-07-10	World	UEFA Europa Conference League	Malisheva	Vikingur Reykjavik	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:15.203129	\N	\N	0	1	a-win	yes
116	1383476	2025-07-10	World	UEFA Europa Conference League	Vardar Skopje	La Fiorita	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:15.377506	\N	\N	0	0	draw	yes
117	1383475	2025-07-10	World	UEFA Europa Conference League	Zeljeznicar Sarajevo	Koper	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:15.674649	\N	\N	0	1	a-win	yes
118	1383474	2025-07-10	World	UEFA Europa Conference League	Sutjeska	Dinamo Brest	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:15.850535	\N	\N	0	1	a-win	yes
120	1383477	2025-07-10	World	UEFA Europa Conference League	St Patrick's Athl.	Hegelmann Litauen	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:16.271503	\N	\N	0	0	draw	yes
121	1383461	2025-07-10	World	UEFA Europa Conference League	Tre Fiori	Pyunik Yerevan	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:16.489028	\N	\N	0	0	draw	yes
122	1383480	2025-07-10	World	UEFA Europa Conference League	Borac Banja Luka	FC Santa Coloma	a-win	1	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:16.668332	\N	\N	0	3	a-win	yes
123	1383479	2025-07-10	World	UEFA Europa Conference League	Larne	Auda	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:16.848304	\N	\N	0	0	draw	yes
124	1383481	2025-07-10	World	UEFA Europa Conference League	Valur Reykjavik	Flora Tallinn	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:17.0323	\N	\N	3	0	h-win	yes
125	1383482	2025-07-16	World	UEFA Europa Conference League	Auda	Larne	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:17.22979	\N	\N	1	0	h-win	yes
126	1383483	2025-07-17	World	UEFA Europa Conference League	BFC Daugavpils	Vllaznia Shkodër	a-win	2	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:17.403643	\N	\N	2	2	draw	yes
127	1383488	2025-07-17	World	UEFA Europa Conference League	FC Santa Coloma	Borac Banja Luka	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:17.584065	\N	\N	0	0	draw	yes
128	1383489	2025-07-17	World	UEFA Europa Conference League	HJK helsinki	NSI Runavik	h-win	5	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:17.760545	\N	\N	1	0	h-win	yes
129	1383484	2025-07-17	World	UEFA Europa Conference League	FK Rabotnicki	Torpedo Zhodino	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:17.979789	\N	\N	0	1	a-win	yes
130	1383491	2025-07-17	World	UEFA Europa Conference League	Flora Tallinn	Valur Reykjavik	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:18.151448	\N	\N	1	1	draw	yes
131	1383490	2025-07-17	World	UEFA Europa Conference League	Ordabasy	Torpedo Kutaisi	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:18.322439	\N	\N	0	1	a-win	yes
132	1383487	2025-07-17	World	UEFA Europa Conference League	Pyunik Yerevan	Tre Fiori	h-win	5	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:18.494447	\N	\N	3	0	h-win	yes
133	1383485	2025-07-17	World	UEFA Europa Conference League	Dila	Racing FC Union Luxembourg	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:18.667617	\N	\N	0	0	draw	yes
134	1383486	2025-07-17	World	UEFA Europa Conference League	Hegelmann Litauen	St Patrick's Athl.	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:18.890823	\N	\N	0	1	a-win	yes
135	1383492	2025-07-17	World	UEFA Europa Conference League	Paide	Magpies	h-win	4	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:19.08264	\N	\N	1	0	h-win	yes
136	1383497	2025-07-17	World	UEFA Europa Conference League	F91 Dudelange	Atlètic Club d'Escaldes	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:19.266133	\N	\N	1	1	draw	yes
137	1383496	2025-07-17	World	UEFA Europa Conference League	Penybont	Kauno Žalgiris	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:19.424717	\N	\N	1	1	draw	yes
138	1383493	2025-07-17	World	UEFA Europa Conference League	Haverfordwest County AFC	Floriana	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:19.578829	\N	\N	2	2	draw	yes
139	1383495	2025-07-17	World	UEFA Europa Conference League	Petrocub	Birkirkara	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:19.743635	\N	\N	1	0	h-win	yes
140	1383494	2025-07-17	World	UEFA Europa Conference League	Sileks	Dečić	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:19.987073	\N	\N	1	1	draw	yes
141	1383498	2025-07-17	World	UEFA Europa Conference League	Koper	Zeljeznicar Sarajevo	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:20.157145	\N	\N	3	1	h-win	yes
142	1383499	2025-07-17	World	UEFA Europa Conference League	Neman	FC Urartu	h-win	4	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:20.3328	\N	\N	1	0	h-win	yes
143	1383500	2025-07-17	World	UEFA Europa Conference League	Partizani	Kalju Nomme	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:20.520733	\N	\N	0	0	draw	yes
144	1383501	2025-07-17	World	UEFA Europa Conference League	Dinamo Brest	Sutjeska	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:20.675171	\N	\N	0	0	draw	yes
145	1383503	2025-07-17	World	UEFA Europa Conference League	Vikingur Reykjavik	Malisheva	h-win	8	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:20.854286	\N	\N	5	0	h-win	yes
146	1383504	2025-07-17	World	UEFA Europa Conference League	KI Klaksvik	SJK	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:20.949526	\N	\N	0	0	draw	yes
147	1383502	2025-07-17	World	UEFA Europa Conference League	Cliftonville FC	St Joseph S Fc	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:20.960798	\N	\N	1	1	draw	yes
148	1383505	2025-07-17	World	UEFA Europa Conference League	La Fiorita	Vardar Skopje	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:20.976866	\N	\N	1	0	h-win	yes
149	1410004	2025-07-22	World	UEFA Europa Conference League	Ballkani	Floriana	h-win	4	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:20.990714	\N	\N	3	2	h-win	yes
101	1383458	2025-07-08	World	UEFA Europa Conference League	St Joseph S Fc	Cliftonville FC	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:12.562669	\N	\N	0	1	a-win	yes
2313	1451198	2025-10-23	World	UEFA Europa League	Brann	Rangers	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	11	36	2025-11-20 11:02:23.0103	\N	\N	1	0	h-win	yes
153	1410006	2025-07-23	World	UEFA Europa Conference League	The New Saints	FC Differdange 03	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.022778	\N	\N	0	1	a-win	yes
154	1410007	2025-07-23	World	UEFA Europa Conference League	Olimpija Ljubljana	Inter Club d'Escaldes	h-win	4	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.029516	\N	\N	0	1	a-win	yes
155	1410008	2025-07-23	World	UEFA Europa Conference League	Buducnost Podgorica	Milsami Orhei	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.03421	\N	\N	0	0	draw	yes
156	1383532	2025-07-24	World	UEFA Europa Conference League	FC Astana	Zimbru	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.03856	\N	\N	0	1	a-win	yes
157	1410009	2025-07-24	World	UEFA Europa Conference League	Atlètic Club d'Escaldes	Dinamo Tirana	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.045411	\N	\N	1	0	h-win	yes
158	1410018	2025-07-24	World	UEFA Europa Conference League	Paide	AIK Stockholm	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.049426	\N	\N	0	1	a-win	yes
159	1383522	2025-07-24	World	UEFA Europa Conference League	Rosenborg	Banga	h-win	5	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.053324	\N	\N	1	0	h-win	yes
160	1410014	2025-07-24	World	UEFA Europa Conference League	FK Zalgiris Vilnius	Linfield	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.059691	\N	\N	0	0	draw	yes
161	1410011	2025-07-24	World	UEFA Europa Conference League	St Joseph S Fc	Shamrock Rovers	a-win	0	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	31	2025-11-19 23:21:21.063602	\N	\N	0	1	a-win	yes
162	1410016	2025-07-24	World	UEFA Europa Conference League	Pyunik Yerevan	Gyori ETO FC	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.067806	\N	\N	1	0	h-win	yes
163	1410012	2025-07-24	World	UEFA Europa Conference League	Ilves	AZ Alkmaar	h-win	4	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	27	2025-11-19 23:21:21.074417	\N	\N	2	1	h-win	yes
164	1410017	2025-07-24	World	UEFA Europa Conference League	Arda Kardzhali	HJK helsinki	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.078756	\N	\N	0	0	draw	yes
165	1383518	2025-07-24	World	UEFA Europa Conference League	Aris	Puskas Academy	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.08265	\N	\N	2	0	h-win	yes
166	1383510	2025-07-24	World	UEFA Europa Conference League	Ararat-Armenia	Universitatea Cluj	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.086439	\N	\N	0	0	draw	yes
167	1410015	2025-07-24	World	UEFA Europa Conference League	Kauno Žalgiris	Valur Reykjavik	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.094924	\N	\N	0	0	draw	yes
168	1410010	2025-07-24	World	UEFA Europa Conference League	Hibernians	Spartak Trnava	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.099144	\N	\N	0	1	a-win	yes
169	1410013	2025-07-24	World	UEFA Europa Conference League	Aktobe	Sparta Praha	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16	2025-11-19 23:21:21.106478	\N	\N	1	0	h-win	yes
170	1383508	2025-07-24	World	UEFA Europa Conference League	Araz	Aris Thessalonikis	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.110853	\N	\N	0	0	draw	yes
171	1383511	2025-07-24	World	UEFA Europa Conference League	Hammarby FF	Charleroi	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.115415	\N	\N	0	0	draw	yes
172	1410020	2025-07-24	World	UEFA Europa Conference League	Viking	Koper	h-win	7	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.121954	\N	\N	1	0	h-win	yes
173	1383512	2025-07-24	World	UEFA Europa Conference League	Cherno More Varna	Istanbul Basaksehir	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.126884	\N	\N	0	0	draw	yes
174	1410021	2025-07-24	World	UEFA Europa Conference League	Petrocub	Sabah FA	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.131908	\N	\N	0	0	draw	yes
175	1383507	2025-07-24	World	UEFA Europa Conference League	Novi Pazar	Jagiellonia	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	14	2025-11-19 23:21:21.138962	\N	\N	1	1	draw	yes
176	1410019	2025-07-24	World	UEFA Europa Conference League	Omonia Nicosia	Torpedo Kutaisi	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	29	\N	2025-11-19 23:21:21.143846	\N	\N	1	0	h-win	yes
177	1410024	2025-07-24	World	UEFA Europa Conference League	Oleksandria	FK Partizan	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.148453	\N	\N	0	1	a-win	yes
178	1410022	2025-07-24	World	UEFA Europa Conference League	Polessya	FC Santa Coloma	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.154658	\N	\N	1	2	a-win	yes
179	1410023	2025-07-24	World	UEFA Europa Conference League	Riga	Dila	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.159485	\N	\N	1	0	h-win	yes
181	1410025	2025-07-24	World	UEFA Europa Conference League	Torpedo Zhodino	Maccabi Haifa	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.171419	\N	\N	0	1	a-win	yes
182	1412428	2025-07-24	World	UEFA Europa Conference League	AEK Athens FC	Hapoel Beer Sheva	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	15	\N	2025-11-19 23:21:21.176342	\N	\N	0	0	draw	yes
183	1383521	2025-07-24	World	UEFA Europa Conference League	NK Varazdin	Santa Clara	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.183365	\N	\N	1	0	h-win	yes
184	1410028	2025-07-24	World	UEFA Europa Conference League	Paks	Maribor	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.188112	\N	\N	0	0	draw	yes
185	1410026	2025-07-24	World	UEFA Europa Conference League	Radnicki 1923	KI Klaksvik	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.19283	\N	\N	0	0	draw	yes
186	1410027	2025-07-24	World	UEFA Europa Conference League	FK Košice	Neman	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.200125	\N	\N	2	0	h-win	yes
187	1410030	2025-07-24	World	UEFA Europa Conference League	Vardar Skopje	Lausanne	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	2025-11-19 23:21:21.20474	\N	\N	1	0	h-win	yes
188	1383519	2025-07-24	World	UEFA Europa Conference League	Austria Vienna	Spaeri	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.209658	\N	\N	1	0	h-win	yes
189	1412427	2025-07-24	World	UEFA Europa Conference League	Sutjeska	Beitar Jerusalem	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.21605	\N	\N	1	1	draw	yes
190	1410029	2025-07-24	World	UEFA Europa Conference League	Vllaznia Shkodër	Vikingur Reykjavik	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.220582	\N	\N	0	1	a-win	yes
191	1410031	2025-07-24	World	UEFA Europa Conference League	Dinamo Minsk	Egnatia Rrogozhinë	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.225263	\N	\N	0	1	a-win	yes
192	1383516	2025-07-24	World	UEFA Europa Conference League	Dundee Utd	UNA Strassen	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.232575	\N	\N	0	0	draw	yes
193	1410032	2025-07-24	World	UEFA Europa Conference League	St Patrick's Athl.	Kalju Nomme	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.23724	\N	\N	0	0	draw	yes
194	1383515	2025-07-24	World	UEFA Europa Conference League	HB	Brondby	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.242433	\N	\N	0	0	draw	yes
195	1383513	2025-07-24	World	UEFA Europa Conference League	FK Sarajevo	Universitatea Craiova	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	20	2025-11-19 23:21:21.248161	\N	\N	2	0	h-win	yes
196	1383517	2025-07-24	World	UEFA Europa Conference League	Raków Częstochowa	Žilina	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	\N	2025-11-19 23:21:21.252397	\N	\N	0	0	draw	yes
197	1410033	2025-07-24	World	UEFA Europa Conference League	Dečić	Rapid Vienna	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	36	2025-11-19 23:21:21.256597	\N	\N	0	2	a-win	yes
198	1410034	2025-07-24	World	UEFA Europa Conference League	Larne	Prishtina	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.263357	\N	\N	0	0	draw	yes
199	1410035	2025-07-29	World	UEFA Europa Conference League	Saburtalo	FC Levadia Tallinn	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.267823	\N	\N	1	0	h-win	yes
200	1410036	2025-07-29	World	UEFA Europa Conference League	FC Differdange 03	The New Saints	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.272184	\N	\N	0	0	draw	yes
151	1410005	2025-07-23	World	UEFA Europa Conference League	FC Levadia Tallinn	Saburtalo	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.007448	\N	\N	0	0	draw	yes
152	1383514	2025-07-23	World	UEFA Europa Conference League	Silkeborg	KA Akureyri	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.018005	\N	\N	1	0	h-win	yes
2314	1451199	2025-10-23	World	UEFA Europa League	GO Ahead Eagles	Aston Villa	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	21	6	2025-11-20 11:02:23.015819	\N	\N	1	1	draw	yes
201	1410037	2025-07-29	World	UEFA Europa Conference League	Inter Club d'Escaldes	Olimpija Ljubljana	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.278563	\N	\N	0	1	a-win	yes
202	1410039	2025-07-31	World	UEFA Europa Conference League	Spartak Trnava	Hibernians	h-win	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.283256	\N	\N	2	1	h-win	yes
203	1410043	2025-07-31	World	UEFA Europa Conference League	FC Santa Coloma	Polessya	a-win	1	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.288182	\N	\N	0	1	a-win	yes
204	1410041	2025-07-31	World	UEFA Europa Conference League	HJK helsinki	Arda Kardzhali	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.295362	\N	\N	1	1	draw	yes
205	1410048	2025-07-31	World	UEFA Europa Conference League	Gyori ETO FC	Pyunik Yerevan	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.299879	\N	\N	1	0	h-win	yes
206	1410040	2025-07-31	World	UEFA Europa Conference League	Dila	Riga	draw	3	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.304193	\N	\N	1	1	draw	yes
207	1383537	2025-07-31	World	UEFA Europa Conference League	Banga	Rosenborg	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.310598	\N	\N	0	0	draw	yes
208	1410042	2025-07-31	World	UEFA Europa Conference League	Sabah FA	Petrocub	h-win	4	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.315115	\N	\N	4	1	h-win	yes
209	1383524	2025-07-31	World	UEFA Europa Conference League	Spaeri	Austria Vienna	a-win	0	5	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.319405	\N	\N	0	3	a-win	yes
210	1410045	2025-07-31	World	UEFA Europa Conference League	AZ Alkmaar	Ilves	h-win	5	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	27	\N	2025-11-19 23:21:21.326831	\N	\N	4	0	h-win	yes
211	1410044	2025-07-31	World	UEFA Europa Conference League	Kalju Nomme	St Patrick's Athl.	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.331268	\N	\N	1	0	h-win	yes
212	1410047	2025-07-31	World	UEFA Europa Conference League	AIK Stockholm	Paide	h-win	6	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.335584	\N	\N	3	0	h-win	yes
213	1410049	2025-07-31	World	UEFA Europa Conference League	Torpedo Kutaisi	Omonia Nicosia	a-win	0	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	29	2025-11-19 23:21:21.342207	\N	\N	0	1	a-win	yes
214	1410046	2025-07-31	World	UEFA Europa Conference League	Milsami Orhei	Buducnost Podgorica	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.346517	\N	\N	0	0	draw	yes
215	1383526	2025-07-31	World	UEFA Europa Conference League	UNA Strassen	Dundee Utd	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.35079	\N	\N	0	0	draw	yes
216	1383534	2025-07-31	World	UEFA Europa Conference League	Universitatea Cluj	Ararat-Armenia	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.357228	\N	\N	1	0	h-win	yes
217	1383509	2025-07-31	World	UEFA Europa Conference League	Zimbru	FC Astana	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.361689	\N	\N	0	2	a-win	yes
218	1383533	2025-07-31	World	UEFA Europa Conference League	Brondby	HB	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.365989	\N	\N	1	0	h-win	yes
219	1383539	2025-07-31	World	UEFA Europa Conference League	Universitatea Craiova	FK Sarajevo	h-win	4	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	20	\N	2025-11-19 23:21:21.372283	\N	\N	0	0	draw	yes
220	1410050	2025-07-31	World	UEFA Europa Conference League	Beitar Jerusalem	Sutjeska	h-win	5	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.37741	\N	\N	2	2	draw	yes
222	1383531	2025-07-31	World	UEFA Europa Conference League	Santa Clara	NK Varazdin	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.388547	\N	\N	1	0	h-win	yes
223	1383529	2025-07-31	World	UEFA Europa Conference League	KA Akureyri	Silkeborg	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.393507	\N	\N	1	0	h-win	yes
224	1410038	2025-07-31	World	UEFA Europa Conference League	Neman	FK Košice	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.397778	\N	\N	0	0	draw	yes
225	1410052	2025-07-31	World	UEFA Europa Conference League	Maribor	Paks	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.404237	\N	\N	1	0	h-win	yes
226	1410053	2025-07-31	World	UEFA Europa Conference League	Hapoel Beer Sheva	AEK Athens FC	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	15	2025-11-19 23:21:21.408873	\N	\N	0	0	draw	yes
227	1410054	2025-07-31	World	UEFA Europa Conference League	Sparta Praha	Aktobe	h-win	4	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16	\N	2025-11-19 23:21:21.413405	\N	\N	0	0	draw	yes
228	1410057	2025-07-31	World	UEFA Europa Conference League	Prishtina	Larne	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.420154	\N	\N	1	0	h-win	yes
229	1383535	2025-07-31	World	UEFA Europa Conference League	Charleroi	Hammarby FF	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.424921	\N	\N	0	1	a-win	yes
230	1383523	2025-07-31	World	UEFA Europa Conference League	Puskas Academy	Aris	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.429423	\N	\N	0	0	draw	yes
231	1410056	2025-07-31	World	UEFA Europa Conference League	Maccabi Haifa	Torpedo Zhodino	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.43623	\N	\N	2	0	h-win	yes
232	1410055	2025-07-31	World	UEFA Europa Conference League	Koper	Viking	a-win	3	5	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.440759	\N	\N	2	1	h-win	yes
233	1383538	2025-07-31	World	UEFA Europa Conference League	Jagiellonia	Novi Pazar	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	14	\N	2025-11-19 23:21:21.44542	\N	\N	0	0	draw	yes
234	1410058	2025-07-31	World	UEFA Europa Conference League	Lausanne	Vardar Skopje	h-win	5	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	\N	2025-11-19 23:21:21.452073	\N	\N	3	0	h-win	yes
235	1383525	2025-07-31	World	UEFA Europa Conference League	Aris Thessalonikis	Araz	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.456723	\N	\N	0	2	a-win	yes
236	1410059	2025-07-31	World	UEFA Europa Conference League	Valur Reykjavik	Kauno Žalgiris	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.461303	\N	\N	1	1	draw	yes
237	1410060	2025-07-31	World	UEFA Europa Conference League	Rapid Vienna	Dečić	h-win	4	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	36	\N	2025-11-19 23:21:21.467781	\N	\N	2	0	h-win	yes
238	1383536	2025-07-31	World	UEFA Europa Conference League	Žilina	Raków Częstochowa	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	2025-11-19 23:21:21.472314	\N	\N	1	1	draw	yes
239	1410062	2025-07-31	World	UEFA Europa Conference League	Vikingur Reykjavik	Vllaznia Shkodër	h-win	4	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.476957	\N	\N	1	1	draw	yes
240	1410061	2025-07-31	World	UEFA Europa Conference League	Linfield	FK Zalgiris Vilnius	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.483776	\N	\N	2	0	h-win	yes
241	1410064	2025-07-31	World	UEFA Europa Conference League	KI Klaksvik	Radnicki 1923	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.488184	\N	\N	1	0	h-win	yes
242	1410063	2025-07-31	World	UEFA Europa Conference League	Dinamo Tirana	Atlètic Club d'Escaldes	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.492887	\N	\N	1	0	h-win	yes
243	1410051	2025-07-31	World	UEFA Europa Conference League	Floriana	Ballkani	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.498898	\N	\N	1	1	draw	yes
244	1383528	2025-07-31	World	UEFA Europa Conference League	Dungannon Swifts	FC Vaduz	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.503398	\N	\N	0	0	draw	yes
245	1410065	2025-07-31	World	UEFA Europa Conference League	FK Partizan	Oleksandria	h-win	4	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.507705	\N	\N	3	0	h-win	yes
246	1383530	2025-07-31	World	UEFA Europa Conference League	HNK Hajduk Split	Zira	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.514279	\N	\N	1	0	h-win	yes
247	1410066	2025-07-31	World	UEFA Europa Conference League	Shamrock Rovers	St Joseph S Fc	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	31	\N	2025-11-19 23:21:21.518669	\N	\N	0	0	draw	yes
248	1410067	2025-07-31	World	UEFA Europa Conference League	Egnatia Rrogozhinë	Dinamo Minsk	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.523004	\N	\N	0	0	draw	yes
9	1383431	2025-07-08	World	UEFA Champions League	Egnatia Rrogozhinë	Breidablik	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:20:51.084385	\N	\N	0	0	draw	yes
33	1383450	2025-07-22	World	UEFA Champions League	Plzen	Servette FC	a-win	0	1	25	9	6	2	9	3	2	3	0	0	0	0	62.00	38.00	5	10	\N	\N	\N	\N	\N	2025-11-19 23:20:55.420294	\N	\N	0	1	a-win	yes
2047	1326511	2025-07-05	USA	Major League Soccer	Colorado Rapids	Sporting Kansas City	a-win	1	2	24	8	5	2	10	2	1	0	0	4	0	0	67.00	33.00	7	15	\N	\N	\N	11	15	2025-11-20 10:20:00.947774	4.17	1.05	0	1	a-win	yes
2048	1326512	2025-07-05	USA	Major League Soccer	Los Angeles Galaxy	Vancouver Whitecaps	h-win	3	0	12	8	5	1	6	7	2	0	1	6	0	1	56.00	44.00	7	17	\N	\N	\N	14	2	2025-11-20 10:20:01.141975	1.52	0.48	1	0	h-win	yes
2049	1326513	2025-07-06	USA	Major League Soccer	Charlotte	Orlando City SC	draw	2	2	11	5	15	6	2	6	3	3	2	4	0	0	33.00	67.00	15	12	\N	\N	\N	\N	\N	2025-11-20 10:20:01.338934	0.81	2.35	1	0	h-win	yes
2050	1326516	2025-07-06	USA	Major League Soccer	CF Montreal	Inter Miami	a-win	1	4	13	8	15	10	5	2	0	2	1	2	0	0	42.00	58.00	12	14	\N	\N	\N	\N	\N	2025-11-20 10:20:01.511498	1.98	2.93	1	2	a-win	yes
2051	1326515	2025-07-06	USA	Major League Soccer	DC United	Atlanta United FC	draw	0	0	9	2	6	1	3	0	1	1	1	4	0	0	40.00	60.00	9	12	\N	\N	\N	\N	\N	2025-11-20 10:20:01.689235	0.65	0.63	0	0	draw	yes
2052	1326514	2025-07-06	USA	Major League Soccer	FC Cincinnati	Chicago Fire	h-win	2	1	13	4	15	5	1	10	3	2	2	2	0	0	47.00	53.00	8	13	\N	\N	\N	\N	\N	2025-11-20 10:20:01.913043	0.99	0.78	1	0	h-win	yes
2053	1326518	2025-07-06	USA	Major League Soccer	Nashville SC	Philadelphia Union	h-win	1	0	12	4	11	3	4	3	2	1	1	4	1	0	50.00	50.00	12	12	\N	\N	\N	\N	\N	2025-11-20 10:20:02.154181	2.48	1.20	0	0	draw	yes
2054	1326519	2025-07-06	USA	Major League Soccer	Real Salt Lake	St. Louis City	h-win	3	2	15	6	18	6	5	10	1	1	1	1	0	0	49.00	51.00	10	8	\N	\N	\N	9	13	2025-11-20 10:20:02.345699	1.61	2.03	2	0	h-win	yes
2055	1326521	2025-07-06	USA	Major League Soccer	San Jose Earthquakes	New York Red Bulls	draw	1	1	15	3	10	4	9	7	3	4	3	4	1	1	58.00	42.00	9	13	\N	\N	\N	10	\N	2025-11-20 10:20:02.5331	1.43	0.77	0	1	a-win	yes
1	1383422	2025-07-08	World	UEFA Champions League	KuPS	Milsami Orhei	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:20:49.645968	\N	\N	0	0	draw	yes
53	1383454	2025-07-30	World	UEFA Champions League	Maccabi Tel Aviv	Pafos	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	20	2025-11-19 23:20:59.006337	\N	\N	0	1	a-win	yes
86	1410079	2025-07-31	World	UEFA Europa League	Utrecht	Sheriff Tiraspol	h-win	4	1	\N	\N	\N	\N	\N	\N	\N	\N	0	0	0	0	\N	\N	\N	\N	\N	\N	\N	32	\N	2025-11-19 23:21:06.227748	\N	\N	1	0	h-win	yes
99	1392813	2025-07-09	World	FIFA Club World Cup	Paris Saint Germain	Real Madrid	h-win	4	0	17	7	11	2	3	6	4	0	1	2	0	0	68.00	32.00	9	9	\N	\N	\N	\N	\N	2025-11-19 23:21:09.880203	\N	\N	3	0	h-win	yes
100	1399365	2025-07-13	World	FIFA Club World Cup	Chelsea	Paris Saint Germain	h-win	3	0	10	5	8	6	3	5	3	2	4	2	0	1	34.00	66.00	15	12	\N	\N	\N	\N	\N	2025-11-19 23:21:10.055027	\N	\N	3	0	h-win	yes
119	1383478	2025-07-10	World	UEFA Europa Conference League	NSI Runavik	HJK helsinki	h-win	4	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:16.085029	\N	\N	2	0	h-win	yes
150	1383506	2025-07-23	World	UEFA Europa Conference League	Zira	HNK Hajduk Split	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.000698	\N	\N	1	0	h-win	yes
180	1383520	2025-07-24	World	UEFA Europa Conference League	FC Vaduz	Dungannon Swifts	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.163925	\N	\N	0	0	draw	yes
221	1383527	2025-07-31	World	UEFA Europa Conference League	Istanbul Basaksehir	Cherno More Varna	h-win	4	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-19 23:21:21.381703	\N	\N	3	0	h-win	yes
1051	1348922	2025-07-02	Uzbekistan	Super League	Dinamo Samarqand	Neftchi	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	1	2025-11-20 02:00:02.107001	\N	\N	0	1	a-win	yes
1052	1348984	2025-07-03	Uzbekistan	Super League	Shortan	Qizilqum	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16	9	2025-11-20 02:00:02.807661	\N	\N	1	1	draw	yes
1053	1348983	2025-07-04	Uzbekistan	Super League	Sogdiana	Kokand-1912	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8	11	2025-11-20 02:00:03.468503	\N	\N	2	0	h-win	yes
1054	1348986	2025-07-04	Uzbekistan	Super League	Surkhon	Buxoro	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	10	14	2025-11-20 02:00:04.258766	\N	\N	0	0	draw	yes
1055	1348981	2025-07-05	Uzbekistan	Super League	Andijan	Bunyodkor	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	5	2025-11-20 02:00:05.049093	\N	\N	0	1	a-win	yes
1056	1348982	2025-07-05	Uzbekistan	Super League	Mash'al	Olmaliq	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	13	6	2025-11-20 02:00:05.365721	\N	\N	0	1	a-win	yes
1057	1348985	2025-07-06	Uzbekistan	Super League	Pakhtakor	Navbahor	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	7	2025-11-20 02:00:05.652508	\N	\N	1	0	h-win	yes
1058	1348979	2025-07-06	Uzbekistan	Super League	Dinamo Samarqand	Nasaf	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	2	2025-11-20 02:00:06.210893	\N	\N	2	1	h-win	yes
1059	1348980	2025-07-07	Uzbekistan	Super League	Neftchi	Xorazm	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	15	2025-11-20 02:00:06.770989	\N	\N	1	0	h-win	yes
1060	1380178	2025-07-25	Hungary	NB I	Ujpest	Diosgyori VTK	h-win	3	1	18	5	9	2	2	4	3	4	2	4	0	1	57.00	43.00	14	14	\N	\N	\N	9	10	2025-11-20 02:00:09.973439	\N	\N	2	0	h-win	yes
1061	1380179	2025-07-26	Hungary	NB I	Zalaegerszegi TE	Debreceni VSC	draw	3	3	16	5	18	6	10	3	1	2	1	2	0	0	57.00	43.00	14	12	\N	\N	\N	8	3	2025-11-20 02:00:10.404399	\N	\N	2	1	h-win	yes
1062	1380175	2025-07-26	Hungary	NB I	MTK Budapest	Ferencvarosi TC	draw	1	1	10	6	18	3	3	6	0	3	1	1	0	0	40.00	60.00	14	7	\N	\N	\N	4	2	2025-11-20 02:00:10.890394	\N	\N	0	1	a-win	yes
1063	1380176	2025-07-27	Hungary	NB I	Nyiregyhaza	Kisvarda FC	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	11	5	2025-11-20 02:00:11.420708	\N	\N	0	1	a-win	yes
1064	1380177	2025-07-27	Hungary	NB I	Paks	Gyori ETO FC	draw	3	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	6	2025-11-20 02:00:11.970497	\N	\N	1	2	a-win	yes
1065	1380174	2025-07-27	Hungary	NB I	Puskas Academy	Kazincbarcikai	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7	12	2025-11-20 02:00:12.422452	\N	\N	0	0	draw	yes
1066	1380386	2025-07-18	Poland	Ekstraklasa	Jagiellonia	Nieciecza	a-win	0	4	13	4	18	6	3	8	4	1	1	0	0	0	64.00	36.00	7	10	\N	\N	\N	2	17	2025-11-20 02:00:21.870594	1.09	2.52	0	3	a-win	yes
1067	1380387	2025-07-18	Poland	Ekstraklasa	Lech Poznan	Cracovia Krakow	a-win	1	4	10	2	7	5	5	0	3	1	1	2	0	0	75.00	25.00	10	12	\N	\N	\N	8	6	2025-11-20 02:00:22.101307	1.10	1.01	1	2	a-win	yes
1068	1380391	2025-07-19	Poland	Ekstraklasa	Widzew Łódź	Zaglebie Lubin	h-win	1	0	16	4	11	2	8	6	1	3	3	4	0	0	53.00	47.00	8	20	\N	\N	\N	12	7	2025-11-20 02:00:22.312905	\N	\N	1	0	h-win	yes
1069	1380392	2025-07-19	Poland	Ekstraklasa	Wisla Plock	Korona Kielce	h-win	2	0	22	8	5	1	7	1	1	4	1	3	0	2	64.00	36.00	12	13	\N	\N	\N	3	9	2025-11-20 02:00:22.561744	\N	\N	1	0	h-win	yes
1070	1380384	2025-07-19	Poland	Ekstraklasa	GKS Katowice	Raków Częstochowa	a-win	0	1	3	0	18	4	3	6	1	0	1	1	0	0	49.00	51.00	8	14	\N	\N	\N	14	4	2025-11-20 02:00:22.764472	\N	\N	0	0	draw	yes
2056	1326520	2025-07-06	USA	Major League Soccer	Portland Timbers	New England Revolution	h-win	2	1	14	5	13	4	5	8	0	4	0	0	0	0	51.00	49.00	6	9	\N	\N	\N	8	\N	2025-11-20 10:20:02.726405	0.99	1.61	1	1	draw	yes
2057	1326729	2025-07-06	USA	Major League Soccer	San Diego	Houston Dynamo	a-win	3	4	14	7	7	5	5	2	1	1	1	6	0	0	59.00	41.00	8	15	\N	\N	\N	1	12	2025-11-20 10:20:02.904562	1.67	1.55	1	2	a-win	yes
2058	1326522	2025-07-06	USA	Major League Soccer	Seattle Sounders	Columbus Crew	draw	1	1	8	2	9	3	2	1	1	2	4	3	1	0	43.00	57.00	13	10	\N	\N	\N	5	\N	2025-11-20 10:20:03.089661	1.68	0.84	1	1	draw	yes
2059	1326523	2025-07-10	USA	Major League Soccer	New England Revolution	Inter Miami	a-win	1	2	16	6	13	3	5	3	3	0	1	3	0	0	44.00	56.00	11	11	\N	\N	\N	\N	\N	2025-11-20 10:20:03.276391	1.40	1.12	0	2	a-win	yes
1071	1380385	2025-07-20	Poland	Ekstraklasa	Gornik Zabrze	Lechia Gdansk	h-win	2	1	21	6	15	6	6	3	1	1	0	1	0	0	52.00	48.00	8	10	\N	\N	\N	1	16	2025-11-20 02:00:23.023986	\N	\N	1	0	h-win	yes
1072	1380389	2025-07-20	Poland	Ekstraklasa	Motor Lublin	Arka Gdynia	h-win	1	0	17	5	10	1	8	8	3	3	2	4	0	0	60.00	40.00	14	11	\N	\N	\N	15	10	2025-11-20 02:00:23.244699	\N	\N	0	0	draw	yes
1073	1380390	2025-07-20	Poland	Ekstraklasa	Radomiak Radom	Pogon Szczecin	h-win	5	1	14	7	6	1	4	4	2	5	1	1	0	0	43.00	57.00	8	9	\N	\N	\N	5	13	2025-11-20 02:00:23.416505	\N	\N	1	0	h-win	yes
1074	1380394	2025-07-25	Poland	Ekstraklasa	Cracovia Krakow	Nieciecza	h-win	2	0	14	3	7	4	5	6	1	0	3	5	0	0	46.00	54.00	16	16	\N	\N	\N	6	17	2025-11-20 02:00:23.597352	1.35	0.68	1	0	h-win	yes
1075	1380393	2025-07-25	Poland	Ekstraklasa	Arka Gdynia	Radomiak Radom	draw	1	1	10	4	14	3	5	4	3	2	1	3	0	0	49.00	51.00	16	12	\N	\N	\N	10	5	2025-11-20 02:00:23.76959	0.79	0.73	1	0	h-win	yes
1076	1380399	2025-07-26	Poland	Ekstraklasa	Piast Gliwice	Gornik Zabrze	a-win	0	1	10	0	8	4	6	2	2	0	2	1	0	0	62.00	38.00	13	8	\N	\N	\N	18	1	2025-11-20 02:00:23.975291	0.49	0.38	0	0	draw	yes
1077	1380400	2025-07-26	Poland	Ekstraklasa	Pogon Szczecin	Motor Lublin	h-win	4	1	19	5	20	8	6	8	0	1	2	1	0	0	42.00	58.00	11	8	\N	\N	\N	13	15	2025-11-20 02:00:24.186042	2.34	1.92	2	1	h-win	yes
1078	1380398	2025-07-26	Poland	Ekstraklasa	Lechia Gdansk	Lech Poznan	a-win	3	4	16	7	21	11	9	10	0	0	3	3	0	0	40.00	60.00	13	11	\N	\N	\N	16	8	2025-11-20 02:00:24.420183	1.95	3.73	2	0	h-win	yes
1079	1380401	2025-07-27	Poland	Ekstraklasa	Raków Częstochowa	Wisla Plock	a-win	1	2	10	3	11	5	6	3	0	1	4	4	0	0	60.00	40.00	17	21	\N	\N	\N	4	3	2025-11-20 02:00:24.632584	\N	\N	1	1	draw	yes
1080	1380396	2025-07-27	Poland	Ekstraklasa	Jagiellonia	Widzew Łódź	h-win	3	2	11	4	18	7	4	2	4	1	2	3	0	0	59.00	41.00	12	18	\N	\N	\N	2	12	2025-11-20 02:00:24.863864	\N	\N	1	1	draw	yes
1081	1380397	2025-07-27	Poland	Ekstraklasa	Korona Kielce	Legia Warszawa	a-win	0	2	18	2	17	5	13	7	0	2	0	1	0	0	53.00	47.00	8	15	\N	\N	\N	9	11	2025-11-20 02:00:25.085699	\N	\N	0	1	a-win	yes
1082	1380395	2025-07-28	Poland	Ekstraklasa	GKS Katowice	Zaglebie Lubin	draw	2	2	20	8	20	3	14	8	1	2	1	1	0	0	56.00	44.00	9	16	\N	\N	\N	14	7	2025-11-20 02:00:25.316185	1.75	2.53	0	2	a-win	yes
3589	1387103	2025-08-01	England	League One	Luton	AFC Wimbledon	h-win	1	0	6	1	2	0	5	2	3	6	1	1	0	0	65.00	35.00	10	11	\N	\N	\N	8	7	2025-11-20 18:16:43.518271	\N	\N	0	0	draw	yes
3590	1387104	2025-08-02	England	League One	Cardiff	Peterborough	h-win	2	1	17	6	7	3	4	2	1	1	3	1	0	0	57.00	43.00	18	10	\N	\N	\N	5	23	2025-11-20 18:16:43.743096	\N	\N	0	1	a-win	yes
3591	1387109	2025-08-02	England	League One	Huddersfield	Leyton Orient	h-win	3	0	14	8	14	3	6	3	4	1	3	0	0	0	44.00	56.00	11	14	\N	\N	\N	10	16	2025-11-20 18:16:43.939723	\N	\N	1	0	h-win	yes
3592	1387113	2025-08-02	England	League One	Wigan	Northampton	h-win	3	1	20	8	8	4	9	3	1	2	0	2	0	0	50.00	50.00	11	11	\N	\N	\N	17	15	2025-11-20 18:16:44.131326	\N	\N	2	0	h-win	yes
3593	1387112	2025-08-02	England	League One	Rotherham	Port Vale	h-win	2	1	11	4	18	4	6	3	1	2	3	1	1	1	47.00	53.00	9	8	\N	\N	\N	11	22	2025-11-20 18:16:44.333659	\N	\N	2	0	h-win	yes
3594	1387107	2025-08-02	England	League One	Burton Albion	Mansfield Town	h-win	2	1	13	5	13	3	1	7	0	1	2	2	0	0	39.00	61.00	13	15	\N	\N	\N	12	9	2025-11-20 18:16:44.52642	\N	\N	1	0	h-win	yes
3595	1387106	2025-08-02	England	League One	Bradford	Wycombe	h-win	2	1	12	6	11	3	2	6	2	2	3	4	0	0	31.00	69.00	23	13	\N	\N	\N	3	14	2025-11-20 18:16:44.775669	\N	\N	2	0	h-win	yes
3596	1387108	2025-08-02	England	League One	Doncaster	Exeter City	h-win	1	0	14	3	2	0	7	1	2	2	0	0	0	0	65.00	35.00	11	10	\N	\N	\N	19	20	2025-11-20 18:16:44.983481	\N	\N	0	0	draw	yes
3597	1387105	2025-08-02	England	League One	Blackpool	Stevenage	a-win	2	3	8	2	7	4	2	2	2	3	1	4	0	0	66.00	34.00	15	19	\N	\N	\N	21	6	2025-11-20 18:16:45.174737	\N	\N	1	2	a-win	yes
3598	1387111	2025-08-02	England	League One	Plymouth	Barnsley	a-win	1	3	15	3	12	7	9	5	2	0	2	5	0	1	53.00	47.00	9	18	\N	\N	\N	24	13	2025-11-20 18:16:45.373868	\N	\N	0	2	a-win	yes
3599	1387110	2025-08-02	England	League One	Lincoln	Reading	h-win	2	0	6	2	9	3	3	9	3	1	1	0	0	0	34.00	66.00	14	4	\N	\N	\N	2	18	2025-11-20 18:16:45.56846	\N	\N	1	0	h-win	yes
3600	1387114	2025-08-03	England	League One	Stockport County	Bolton	h-win	2	0	5	2	15	2	9	7	2	2	2	1	0	0	45.00	55.00	13	13	\N	\N	\N	1	4	2025-11-20 18:16:45.746204	\N	\N	1	0	h-win	yes
3601	1387126	2025-08-07	England	League One	Port Vale	Cardiff	draw	0	0	16	1	8	1	5	4	3	1	3	1	0	0	39.00	61.00	13	6	\N	\N	\N	22	5	2025-11-20 18:16:45.917936	\N	\N	0	0	draw	yes
3602	1387123	2025-08-09	England	League One	Reading	Huddersfield	a-win	0	2	8	2	12	6	4	10	0	1	4	2	0	0	49.00	51.00	15	12	\N	\N	\N	18	10	2025-11-20 18:16:46.134798	\N	\N	0	0	draw	yes
3603	1387122	2025-08-09	England	League One	Peterborough	Luton	a-win	0	2	6	2	8	3	3	6	2	5	2	2	0	0	49.00	51.00	15	12	\N	\N	\N	23	8	2025-11-20 18:16:46.339579	\N	\N	0	0	draw	yes
3604	1387117	2025-08-09	England	League One	Bolton	Plymouth	h-win	2	0	13	2	3	0	8	3	4	8	2	4	0	0	39.00	61.00	16	9	\N	\N	\N	4	24	2025-11-20 18:16:46.52815	\N	\N	1	0	h-win	yes
3605	1387116	2025-08-09	England	League One	Barnsley	Burton Albion	h-win	3	2	13	7	8	3	7	4	2	2	3	1	0	0	68.00	32.00	16	14	\N	\N	\N	13	12	2025-11-20 18:16:46.738228	\N	\N	0	2	a-win	yes
3606	1387115	2025-08-09	England	League One	AFC Wimbledon	Lincoln	h-win	2	0	16	3	2	0	6	3	1	2	0	0	0	1	55.00	45.00	11	15	\N	\N	\N	7	2	2025-11-20 18:16:46.939604	\N	\N	1	0	h-win	yes
3607	1387121	2025-08-09	England	League One	Northampton	Bradford	draw	0	0	4	1	14	2	6	3	1	1	2	5	0	0	53.00	47.00	10	14	\N	\N	\N	15	3	2025-11-20 18:16:47.120759	\N	\N	0	0	draw	yes
1110	1382426	2025-07-25	Belgium	Jupiler Pro League	Antwerp	Union St. Gilloise	draw	1	1	8	4	17	8	2	5	5	1	3	3	0	0	43.00	57.00	9	16	\N	\N	\N	14	1	2025-11-20 02:01:10.479709	0.52	2.19	1	0	h-win	yes
1111	1382427	2025-07-26	Belgium	Jupiler Pro League	Dender	Cercle Brugge	draw	0	0	11	3	10	2	3	3	4	4	0	2	0	0	54.00	46.00	13	13	\N	\N	\N	16	15	2025-11-20 02:01:10.654619	1.21	1.25	0	0	draw	yes
1112	1382428	2025-07-26	Belgium	Jupiler Pro League	Zulte Waregem	KV Mechelen	draw	1	1	21	5	7	2	9	6	0	0	3	3	0	0	56.00	44.00	8	8	\N	\N	\N	8	6	2025-11-20 02:01:10.825889	2.08	0.50	0	1	a-win	yes
1113	1382429	2025-07-26	Belgium	Jupiler Pro League	RAAL La Louvière	Standard Liege	a-win	0	2	14	2	9	4	6	1	1	2	2	1	0	0	45.00	55.00	15	12	\N	\N	\N	11	10	2025-11-20 02:01:11.034702	0.84	1.73	0	2	a-win	yes
1114	1382430	2025-07-27	Belgium	Jupiler Pro League	Anderlecht	KVC Westerlo	h-win	5	2	25	10	10	4	8	3	5	0	4	2	0	0	48.00	52.00	14	14	\N	\N	\N	3	12	2025-11-20 02:01:11.228879	2.58	0.81	2	0	h-win	yes
1192	1331375	2025-07-13	Argentina	Primera Nacional	Colon Santa Fe	Almirante Brown	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 02:01:34.915	\N	\N	1	0	h-win	yes
1115	1382431	2025-07-27	Belgium	Jupiler Pro League	OH Leuven	Charleroi	draw	2	2	7	3	15	7	4	8	2	5	2	2	0	0	44.00	56.00	15	14	\N	\N	\N	13	9	2025-11-20 02:01:11.415138	1.20	1.31	1	0	h-win	yes
1116	1382432	2025-07-27	Belgium	Jupiler Pro League	Club Brugge KV	Genk	h-win	2	1	18	4	17	10	8	6	2	0	1	2	1	0	56.00	44.00	10	7	\N	\N	\N	2	7	2025-11-20 02:01:11.614602	2.00	0.88	0	1	a-win	yes
1117	1382433	2025-07-27	Belgium	Jupiler Pro League	St. Truiden	Gent	h-win	3	1	14	5	12	2	4	6	0	4	1	1	0	0	48.00	52.00	13	9	\N	\N	\N	4	5	2025-11-20 02:01:11.813908	1.26	1.58	0	0	draw	yes
3608	1387125	2025-08-09	England	League One	Wycombe	Stockport County	a-win	1	2	14	6	9	3	8	4	5	1	3	1	0	0	58.00	42.00	8	11	\N	\N	\N	14	1	2025-11-20 18:16:47.333766	\N	\N	0	1	a-win	yes
3609	1387118	2025-08-09	England	League One	Exeter City	Blackpool	h-win	4	1	17	7	10	3	6	5	0	0	1	1	0	0	44.00	56.00	16	8	\N	\N	\N	20	21	2025-11-20 18:16:47.525124	\N	\N	2	1	h-win	yes
3610	1387124	2025-08-09	England	League One	Stevenage	Rotherham	h-win	1	0	12	2	5	0	5	5	1	0	3	2	0	0	44.00	56.00	10	16	\N	\N	\N	6	11	2025-11-20 18:16:47.684395	\N	\N	1	0	h-win	yes
3611	1387119	2025-08-09	England	League One	Leyton Orient	Wigan	h-win	2	0	14	5	4	0	2	3	3	1	0	1	0	1	52.00	48.00	15	8	\N	\N	\N	16	17	2025-11-20 18:16:47.863526	\N	\N	1	0	h-win	yes
3612	1387120	2025-08-09	England	League One	Mansfield Town	Doncaster	a-win	1	2	7	3	13	2	2	5	0	0	2	1	0	0	41.00	59.00	14	10	\N	\N	\N	9	19	2025-11-20 18:16:48.045157	\N	\N	0	0	draw	yes
3613	1387130	2025-08-16	England	League One	Burton Albion	Port Vale	draw	0	0	14	4	13	0	9	3	1	1	4	1	0	1	62.00	38.00	14	10	\N	\N	\N	12	22	2025-11-20 18:16:48.252812	\N	\N	0	0	draw	yes
3614	1387132	2025-08-16	England	League One	Exeter City	Mansfield Town	a-win	1	2	5	4	7	3	3	4	5	0	2	1	0	0	60.00	40.00	11	9	\N	\N	\N	20	9	2025-11-20 18:16:48.458452	\N	\N	0	1	a-win	yes
3615	1387138	2025-08-16	England	League One	Cardiff	Rotherham	h-win	3	0	13	6	1	1	7	0	1	2	2	3	0	0	76.00	24.00	16	15	\N	\N	\N	5	11	2025-11-20 18:16:48.650129	\N	\N	1	0	h-win	yes
3616	1387135	2025-08-16	England	League One	Reading	AFC Wimbledon	a-win	1	2	14	3	8	2	3	5	1	2	1	1	0	0	60.00	40.00	6	6	\N	\N	\N	18	7	2025-11-20 18:16:48.85914	\N	\N	0	1	a-win	yes
3617	1387137	2025-08-16	England	League One	Wigan	Peterborough	h-win	2	0	10	4	15	2	3	10	4	1	1	2	0	0	30.00	70.00	12	18	\N	\N	\N	17	23	2025-11-20 18:16:49.054148	\N	\N	2	0	h-win	yes
3618	1387127	2025-08-16	England	League One	Barnsley	Bolton	draw	1	1	5	2	17	7	3	2	7	4	4	2	1	0	44.00	56.00	14	15	\N	\N	\N	13	4	2025-11-20 18:16:49.231071	\N	\N	0	0	draw	yes
3619	1387129	2025-08-16	England	League One	Bradford	Luton	h-win	2	1	13	7	9	3	2	9	4	0	2	2	0	0	38.00	62.00	12	15	\N	\N	\N	3	8	2025-11-20 18:16:49.412378	\N	\N	1	0	h-win	yes
3620	1387131	2025-08-16	England	League One	Doncaster	Wycombe	draw	1	1	10	1	8	3	6	3	1	7	3	2	0	0	46.00	54.00	13	14	\N	\N	\N	19	14	2025-11-20 18:16:49.598718	\N	\N	0	0	draw	yes
3621	1387128	2025-08-16	England	League One	Blackpool	Huddersfield	h-win	3	2	8	4	17	3	1	7	1	2	0	2	1	0	23.00	77.00	10	17	\N	\N	\N	21	10	2025-11-20 18:16:49.813276	\N	\N	3	2	h-win	yes
3622	1387136	2025-08-16	England	League One	Stevenage	Northampton	h-win	2	0	10	3	9	0	2	6	2	3	2	0	0	0	48.00	52.00	13	16	\N	\N	\N	6	15	2025-11-20 18:16:50.015168	\N	\N	0	0	draw	yes
3623	1387133	2025-08-16	England	League One	Leyton Orient	Stockport County	draw	2	2	13	2	8	4	6	4	0	1	2	2	0	0	71.00	29.00	9	11	\N	\N	\N	16	1	2025-11-20 18:16:50.211342	\N	\N	0	2	a-win	yes
3624	1387134	2025-08-16	England	League One	Lincoln	Plymouth	h-win	3	2	14	8	15	4	4	5	2	1	6	5	0	1	35.00	65.00	15	11	\N	\N	\N	2	24	2025-11-20 18:16:50.386775	\N	\N	1	0	h-win	yes
3625	1387140	2025-08-19	England	League One	Huddersfield	Doncaster	h-win	2	0	11	7	12	3	7	6	5	1	3	3	0	0	50.00	50.00	14	19	\N	\N	\N	10	19	2025-11-20 18:16:50.57613	\N	\N	0	0	draw	yes
3626	1387150	2025-08-19	England	League One	AFC Wimbledon	Cardiff	a-win	0	1	16	2	16	1	5	2	1	0	2	2	0	0	33.00	67.00	10	11	\N	\N	\N	7	5	2025-11-20 18:16:50.752021	\N	\N	0	0	draw	yes
3627	1387143	2025-08-19	England	League One	Northampton	Lincoln	a-win	0	1	10	3	3	1	6	1	1	2	3	4	0	0	61.00	39.00	9	13	\N	\N	\N	15	2	2025-11-20 18:16:50.919768	\N	\N	0	1	a-win	yes
3628	1387144	2025-08-19	England	League One	Peterborough	Barnsley	a-win	0	1	7	1	15	5	2	5	0	1	1	3	0	0	44.00	56.00	13	11	\N	\N	\N	23	13	2025-11-20 18:16:51.134573	\N	\N	0	1	a-win	yes
3629	1387146	2025-08-19	England	League One	Port Vale	Stevenage	a-win	1	2	15	6	11	3	4	2	1	1	1	2	0	0	50.00	50.00	11	13	\N	\N	\N	22	6	2025-11-20 18:16:51.336002	\N	\N	1	0	h-win	yes
3630	1387145	2025-08-19	England	League One	Plymouth	Leyton Orient	a-win	0	1	12	5	10	5	4	2	2	3	1	2	0	0	52.00	48.00	7	12	\N	\N	\N	24	16	2025-11-20 18:16:51.574063	\N	\N	0	0	draw	yes
3631	1387149	2025-08-19	England	League One	Wycombe	Exeter City	a-win	0	1	19	8	6	1	6	7	3	1	4	3	0	0	63.00	37.00	10	8	\N	\N	\N	14	20	2025-11-20 18:16:51.74935	\N	\N	0	0	draw	yes
3632	1387141	2025-08-19	England	League One	Luton	Wigan	h-win	1	0	13	4	9	3	8	4	3	5	1	2	0	0	66.00	34.00	7	12	\N	\N	\N	8	17	2025-11-20 18:16:51.96422	\N	\N	1	0	h-win	yes
3633	1387142	2025-08-19	England	League One	Mansfield Town	Blackpool	h-win	2	0	15	6	6	1	4	0	1	2	0	0	0	0	50.00	50.00	13	13	\N	\N	\N	9	21	2025-11-20 18:16:52.19109	\N	\N	0	0	draw	yes
3634	1387148	2025-08-19	England	League One	Stockport County	Bradford	a-win	1	2	19	8	10	3	8	8	1	5	1	2	0	0	66.00	34.00	9	10	\N	\N	\N	1	3	2025-11-20 18:16:52.376559	\N	\N	1	0	h-win	yes
3635	1387139	2025-08-20	England	League One	Bolton	Reading	draw	1	1	21	4	5	2	3	1	2	3	0	5	0	0	64.00	36.00	9	21	\N	\N	\N	4	18	2025-11-20 18:16:52.614007	\N	\N	0	0	draw	yes
3636	1387159	2025-08-23	England	League One	Rotherham	Wigan	draw	2	2	12	5	13	5	4	6	0	0	1	3	0	0	47.00	53.00	13	13	\N	\N	\N	11	17	2025-11-20 18:16:52.853804	\N	\N	0	1	a-win	yes
3637	1387162	2025-08-23	England	League One	Luton	Cardiff	a-win	0	1	23	7	16	3	5	8	1	2	2	1	0	0	38.00	62.00	11	10	\N	\N	\N	8	5	2025-11-20 18:16:53.110124	\N	\N	0	0	draw	yes
1193	1331363	2025-07-13	Argentina	Primera Nacional	Deportivo Madryn	Almagro	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	16	2025-11-20 02:01:34.920453	\N	\N	0	1	a-win	yes
3638	1387153	2025-08-23	England	League One	Huddersfield	Stevenage	h-win	1	0	12	6	11	4	7	4	0	1	2	1	0	0	61.00	39.00	8	16	\N	\N	\N	10	6	2025-11-20 18:16:53.324635	\N	\N	0	0	draw	yes
3639	1387152	2025-08-23	England	League One	Bolton	Lincoln	draw	1	1	18	6	5	3	13	2	2	5	2	2	0	0	74.00	26.00	11	13	\N	\N	\N	4	2	2025-11-20 18:16:53.539236	\N	\N	0	1	a-win	yes
3640	1387151	2025-08-23	England	League One	AFC Wimbledon	Barnsley	h-win	2	0	16	5	16	3	3	3	1	2	2	1	0	0	40.00	60.00	11	9	\N	\N	\N	7	13	2025-11-20 18:16:53.761993	\N	\N	1	0	h-win	yes
3641	1387155	2025-08-23	England	League One	Northampton	Exeter City	h-win	2	0	10	3	6	1	1	4	1	5	0	4	0	0	36.00	64.00	9	15	\N	\N	\N	15	20	2025-11-20 18:16:53.97211	\N	\N	2	0	h-win	yes
3642	1387156	2025-08-23	England	League One	Peterborough	Bradford	draw	1	1	12	4	15	4	8	6	1	1	1	1	0	0	61.00	39.00	10	20	\N	\N	\N	23	3	2025-11-20 18:16:54.138449	\N	\N	0	0	draw	yes
3643	1387158	2025-08-23	England	League One	Port Vale	Doncaster	a-win	0	1	13	3	6	1	7	6	2	3	1	2	0	0	45.00	55.00	10	7	\N	\N	\N	22	19	2025-11-20 18:16:54.364635	\N	\N	0	0	draw	yes
3644	1387157	2025-08-23	England	League One	Plymouth	Blackpool	h-win	1	0	14	3	9	2	4	4	0	1	1	3	0	0	59.00	41.00	13	9	\N	\N	\N	24	21	2025-11-20 18:16:54.570129	\N	\N	0	0	draw	yes
3645	1387161	2025-08-23	England	League One	Wycombe	Reading	draw	2	2	14	6	16	6	5	8	0	2	1	3	0	0	54.00	46.00	10	12	\N	\N	\N	14	18	2025-11-20 18:16:54.7551	\N	\N	1	2	a-win	yes
3646	1387154	2025-08-23	England	League One	Mansfield Town	Leyton Orient	h-win	4	1	18	5	8	3	7	7	0	1	2	2	0	1	45.00	55.00	7	15	\N	\N	\N	9	16	2025-11-20 18:16:54.929147	\N	\N	2	1	h-win	yes
3647	1387160	2025-08-23	England	League One	Stockport County	Burton Albion	h-win	2	1	14	5	20	3	4	8	3	1	3	0	1	0	46.00	54.00	9	8	\N	\N	\N	1	12	2025-11-20 18:16:55.11414	\N	\N	0	1	a-win	yes
3648	1387174	2025-08-30	England	League One	Cardiff	Plymouth	h-win	4	0	16	10	8	3	5	5	1	1	3	1	0	0	55.00	45.00	14	6	\N	\N	\N	5	24	2025-11-20 18:16:55.374319	\N	\N	2	0	h-win	yes
3649	1387167	2025-08-30	England	League One	Doncaster	Rotherham	h-win	1	0	13	3	14	3	2	6	3	2	3	1	0	0	58.00	42.00	12	13	\N	\N	\N	19	11	2025-11-20 18:16:55.573094	\N	\N	1	0	h-win	yes
3650	1387171	2025-08-30	England	League One	Reading	Port Vale	h-win	1	0	11	5	14	3	2	6	1	4	2	2	0	0	48.00	52.00	12	12	\N	\N	\N	18	22	2025-11-20 18:16:55.77342	\N	\N	0	0	draw	yes
3651	1387173	2025-08-30	England	League One	Wigan	Stockport County	draw	1	1	13	3	8	3	2	3	3	0	1	2	0	0	57.00	43.00	7	10	\N	\N	\N	17	1	2025-11-20 18:16:55.999619	\N	\N	0	1	a-win	yes
3652	1387163	2025-08-30	England	League One	Barnsley	Huddersfield	h-win	3	1	7	5	9	1	3	6	4	4	1	2	0	1	62.00	38.00	8	13	\N	\N	\N	13	10	2025-11-20 18:16:56.25331	\N	\N	2	0	h-win	yes
3653	1387166	2025-08-30	England	League One	Burton Albion	Luton	a-win	0	3	8	3	12	6	6	4	0	1	0	1	0	0	49.00	51.00	9	10	\N	\N	\N	12	8	2025-11-20 18:16:56.451698	\N	\N	0	2	a-win	yes
3654	1387165	2025-08-30	England	League One	Bradford	AFC Wimbledon	h-win	3	2	16	6	13	4	7	2	2	1	0	1	0	0	45.00	55.00	9	13	\N	\N	\N	3	7	2025-11-20 18:16:56.619844	\N	\N	1	1	draw	yes
3655	1387164	2025-08-30	England	League One	Blackpool	Bolton	draw	1	1	6	1	17	4	0	5	2	1	1	2	0	0	28.00	72.00	15	11	\N	\N	\N	21	4	2025-11-20 18:16:56.822106	\N	\N	1	0	h-win	yes
3656	1387168	2025-08-30	England	League One	Exeter City	Peterborough	h-win	3	0	12	5	6	1	5	5	5	1	3	2	0	0	46.00	54.00	23	9	\N	\N	\N	20	23	2025-11-20 18:16:57.00133	\N	\N	1	0	h-win	yes
1163	1331340	2025-07-01	Argentina	Primera Nacional	Colon Santa Fe	Atletico Mitre	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 02:01:33.693073	\N	\N	0	0	draw	yes
1164	1331341	2025-07-05	Argentina	Primera Nacional	Los Andes	Colegiales	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	13	9	2025-11-20 02:01:33.870573	\N	\N	0	0	draw	yes
1165	1331357	2025-07-05	Argentina	Primera Nacional	San Telmo	Estudiantes de Rio Cuarto	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 02:01:34.058522	\N	\N	0	0	draw	yes
1166	1331346	2025-07-05	Argentina	Primera Nacional	Almagro	Deportivo Maipu	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16	7	2025-11-20 02:01:34.264708	\N	\N	0	1	a-win	yes
1167	1331345	2025-07-05	Argentina	Primera Nacional	San Miguel	Deportivo Madryn	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	1	2025-11-20 02:01:34.425232	\N	\N	1	1	draw	yes
1168	1331347	2025-07-06	Argentina	Primera Nacional	Ferro Carril Oeste	Gimnasia Y Tiro	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	4	2025-11-20 02:01:34.585537	\N	\N	0	0	draw	yes
1169	1331342	2025-07-06	Argentina	Primera Nacional	Atlanta	Arsenal Sarandi	h-win	4	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	17	2025-11-20 02:01:34.667646	\N	\N	1	0	h-win	yes
1170	1331350	2025-07-06	Argentina	Primera Nacional	Nueva Chicago	Atletico Mitre	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 02:01:34.679794	\N	\N	1	0	h-win	yes
1171	1331358	2025-07-06	Argentina	Primera Nacional	Chacarita Juniors	Defensores De Belgrano	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 02:01:34.695809	\N	\N	0	1	a-win	yes
1172	1331348	2025-07-06	Argentina	Primera Nacional	Patronato	Tristan Suarez	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8	3	2025-11-20 02:01:34.712713	\N	\N	0	0	draw	yes
1173	1331356	2025-07-06	Argentina	Primera Nacional	Agropecuario	Talleres Remedios	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 02:01:34.729146	\N	\N	1	1	draw	yes
1174	1331354	2025-07-06	Argentina	Primera Nacional	Gimnasia M.	CA Estudiantes	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 02:01:34.746245	\N	\N	0	0	draw	yes
1175	1331355	2025-07-06	Argentina	Primera Nacional	Gimnasia Jujuy	Deportivo Moron	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 02:01:34.762603	\N	\N	0	0	draw	yes
1176	1331351	2025-07-06	Argentina	Primera Nacional	Chaco For Ever	Colon Santa Fe	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 02:01:34.775857	\N	\N	0	0	draw	yes
1177	1331343	2025-07-06	Argentina	Primera Nacional	Racing Cordoba	All Boys	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	11	10	2025-11-20 02:01:34.786501	\N	\N	0	0	draw	yes
1178	1331353	2025-07-06	Argentina	Primera Nacional	Central Norte	Defensores Unidos	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 02:01:34.799434	\N	\N	2	0	h-win	yes
1179	1331349	2025-07-06	Argentina	Primera Nacional	Club Atlético Güemes	San Martin Tucuman	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	14	6	2025-11-20 02:01:34.80866	\N	\N	0	0	draw	yes
1180	1331352	2025-07-07	Argentina	Primera Nacional	Almirante Brown	Temperley	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 02:01:34.82432	\N	\N	0	0	draw	yes
1181	1331361	2025-07-12	Argentina	Primera Nacional	Gimnasia Y Tiro	Patronato	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	8	2025-11-20 02:01:34.836569	\N	\N	1	0	h-win	yes
1182	1331365	2025-07-12	Argentina	Primera Nacional	All Boys	Quilmes	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	10	15	2025-11-20 02:01:34.843819	\N	\N	0	0	draw	yes
1183	1331370	2025-07-12	Argentina	Primera Nacional	Talleres Remedios	San Telmo	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 02:01:34.855919	\N	\N	0	0	draw	yes
1184	1331360	2025-07-12	Argentina	Primera Nacional	Tristan Suarez	Club Atlético Güemes	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	14	2025-11-20 02:01:34.861757	\N	\N	0	0	draw	yes
1185	1331367	2025-07-12	Argentina	Primera Nacional	Colegiales	Atlanta	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	2	2025-11-20 02:01:34.869338	\N	\N	2	0	h-win	yes
1186	1331371	2025-07-12	Argentina	Primera Nacional	Deportivo Moron	Agropecuario	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 02:01:34.874322	\N	\N	0	0	draw	yes
1187	1331374	2025-07-12	Argentina	Primera Nacional	Temperley	Central Norte	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 02:01:34.880941	\N	\N	0	0	draw	yes
1188	1331373	2025-07-12	Argentina	Primera Nacional	Defensores Unidos	Gimnasia M.	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 02:01:34.888621	\N	\N	0	0	draw	yes
1189	1331372	2025-07-12	Argentina	Primera Nacional	CA Estudiantes	Gimnasia Jujuy	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 02:01:34.893984	\N	\N	0	0	draw	yes
1190	1331359	2025-07-13	Argentina	Primera Nacional	San Martin Tucuman	Los Andes	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	13	2025-11-20 02:01:34.901673	\N	\N	1	0	h-win	yes
1191	1331368	2025-07-13	Argentina	Primera Nacional	Defensores De Belgrano	Nueva Chicago	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 02:01:34.907279	\N	\N	1	1	draw	yes
3657	1387172	2025-08-30	England	League One	Stevenage	Wycombe	h-win	1	0	9	5	10	0	5	2	0	3	2	2	0	0	39.00	61.00	14	11	\N	\N	\N	6	14	2025-11-20 18:16:57.173909	\N	\N	1	0	h-win	yes
3658	1387169	2025-08-30	England	League One	Leyton Orient	Northampton	a-win	0	1	7	4	8	4	6	6	2	0	5	0	0	0	66.00	34.00	17	9	\N	\N	\N	16	15	2025-11-20 18:16:57.352577	\N	\N	0	0	draw	yes
1194	1331366	2025-07-13	Argentina	Primera Nacional	Arsenal Sarandi	Racing Cordoba	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	17	11	2025-11-20 02:01:34.926064	\N	\N	1	1	draw	yes
1195	1331362	2025-07-13	Argentina	Primera Nacional	Deportivo Maipu	Ferro Carril Oeste	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7	12	2025-11-20 02:01:34.933179	\N	\N	2	1	h-win	yes
1196	1331364	2025-07-13	Argentina	Primera Nacional	Alvarado	San Miguel	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	18	5	2025-11-20 02:01:34.938787	\N	\N	0	0	draw	yes
1197	1331376	2025-07-13	Argentina	Primera Nacional	Atletico Mitre	Chaco For Ever	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 02:01:34.943999	\N	\N	0	0	draw	yes
1198	1331369	2025-07-13	Argentina	Primera Nacional	Estudiantes de Rio Cuarto	Chacarita Juniors	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 02:01:34.952113	\N	\N	1	0	h-win	yes
1199	1331392	2025-07-19	Argentina	Primera Nacional	San Telmo	Deportivo Moron	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 02:01:34.958101	\N	\N	1	1	draw	yes
1200	1331381	2025-07-19	Argentina	Primera Nacional	Almagro	Alvarado	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16	18	2025-11-20 02:01:34.963734	\N	\N	0	0	draw	yes
1201	1331380	2025-07-19	Argentina	Primera Nacional	San Miguel	All Boys	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	10	2025-11-20 02:01:34.971133	\N	\N	1	0	h-win	yes
1202	1331385	2025-07-19	Argentina	Primera Nacional	San Martin Tucuman	Tristan Suarez	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	3	2025-11-20 02:01:34.977543	\N	\N	1	1	draw	yes
1203	1331379	2025-07-19	Argentina	Primera Nacional	Quilmes	Arsenal Sarandi	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	15	17	2025-11-20 02:01:34.98596	\N	\N	2	1	h-win	yes
1204	1331377	2025-07-19	Argentina	Primera Nacional	Los Andes	Atlanta	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	13	2	2025-11-20 02:01:34.992263	\N	\N	2	0	h-win	yes
1205	1331382	2025-07-20	Argentina	Primera Nacional	Ferro Carril Oeste	Deportivo Madryn	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	1	2025-11-20 02:01:34.999939	\N	\N	0	0	draw	yes
1206	1331393	2025-07-20	Argentina	Primera Nacional	Chacarita Juniors	Talleres Remedios	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 02:01:35.005744	\N	\N	1	1	draw	yes
1207	1331389	2025-07-20	Argentina	Primera Nacional	Gimnasia M.	Temperley	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 02:01:35.011383	\N	\N	0	0	draw	yes
1208	1331383	2025-07-20	Argentina	Primera Nacional	Patronato	Deportivo Maipu	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8	7	2025-11-20 02:01:35.020289	\N	\N	0	0	draw	yes
1209	1331384	2025-07-20	Argentina	Primera Nacional	Club Atlético Güemes	Gimnasia Y Tiro	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	14	4	2025-11-20 02:01:35.026046	\N	\N	0	0	draw	yes
1210	1331387	2025-07-20	Argentina	Primera Nacional	Almirante Brown	Atletico Mitre	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 02:01:35.034045	\N	\N	1	0	h-win	yes
1211	1331390	2025-07-20	Argentina	Primera Nacional	Gimnasia Jujuy	Defensores Unidos	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 02:01:35.040914	\N	\N	0	0	draw	yes
1212	1331394	2025-07-20	Argentina	Primera Nacional	Defensores De Belgrano	Estudiantes de Rio Cuarto	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 02:01:35.046586	\N	\N	0	0	draw	yes
1213	1331378	2025-07-20	Argentina	Primera Nacional	Racing Cordoba	Colegiales	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	11	9	2025-11-20 02:01:35.054959	\N	\N	1	0	h-win	yes
1214	1331386	2025-07-20	Argentina	Primera Nacional	Nueva Chicago	Chaco For Ever	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 02:01:35.06075	\N	\N	0	0	draw	yes
1215	1331388	2025-07-20	Argentina	Primera Nacional	Central Norte	Colon Santa Fe	a-win	3	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 02:01:35.069101	\N	\N	1	4	a-win	yes
1216	1331391	2025-07-21	Argentina	Primera Nacional	Agropecuario	CA Estudiantes	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 02:01:35.074519	\N	\N	1	1	draw	yes
1217	1331402	2025-07-26	Argentina	Primera Nacional	Colegiales	Quilmes	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	15	2025-11-20 02:01:35.082725	\N	\N	0	0	draw	yes
1218	1331396	2025-07-26	Argentina	Primera Nacional	Gimnasia Y Tiro	San Martin Tucuman	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	6	2025-11-20 02:01:35.088671	\N	\N	1	0	h-win	yes
1219	1331395	2025-07-26	Argentina	Primera Nacional	Tristan Suarez	Los Andes	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	13	2025-11-20 02:01:35.094398	\N	\N	2	1	h-win	yes
1220	1331398	2025-07-26	Argentina	Primera Nacional	Deportivo Madryn	Patronato	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	8	2025-11-20 02:01:35.103012	\N	\N	1	0	h-win	yes
1221	1331400	2025-07-26	Argentina	Primera Nacional	All Boys	Almagro	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	10	16	2025-11-20 02:01:35.108939	\N	\N	1	0	h-win	yes
1222	1331405	2025-07-26	Argentina	Primera Nacional	Talleres Remedios	Defensores De Belgrano	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 02:01:35.117321	\N	\N	1	0	h-win	yes
1223	1331406	2025-07-26	Argentina	Primera Nacional	Deportivo Moron	Chacarita Juniors	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 02:01:35.123278	\N	\N	0	2	a-win	yes
1224	1331407	2025-07-27	Argentina	Primera Nacional	CA Estudiantes	San Telmo	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 02:01:35.129267	\N	\N	1	0	h-win	yes
1225	1331401	2025-07-27	Argentina	Primera Nacional	Arsenal Sarandi	San Miguel	h-win	5	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	17	5	2025-11-20 02:01:35.137886	\N	\N	1	0	h-win	yes
1226	1331399	2025-07-27	Argentina	Primera Nacional	Alvarado	Ferro Carril Oeste	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	18	12	2025-11-20 02:01:35.143702	\N	\N	1	0	h-win	yes
1227	1331409	2025-07-27	Argentina	Primera Nacional	Temperley	Gimnasia Jujuy	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 02:01:35.152385	\N	\N	1	0	h-win	yes
1228	1331411	2025-07-27	Argentina	Primera Nacional	Atletico Mitre	Central Norte	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 02:01:35.1581	\N	\N	0	2	a-win	yes
1229	1331408	2025-07-27	Argentina	Primera Nacional	Defensores Unidos	Agropecuario	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 02:01:35.166735	\N	\N	0	1	a-win	yes
1230	1331397	2025-07-27	Argentina	Primera Nacional	Deportivo Maipu	Club Atlético Güemes	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7	14	2025-11-20 02:01:35.172728	\N	\N	1	0	h-win	yes
1231	1331410	2025-07-27	Argentina	Primera Nacional	Colon Santa Fe	Gimnasia M.	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 02:01:35.178429	\N	\N	0	2	a-win	yes
1232	1331404	2025-07-27	Argentina	Primera Nacional	Estudiantes de Rio Cuarto	Nueva Chicago	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 02:01:35.187283	\N	\N	0	1	a-win	yes
1233	1331412	2025-07-27	Argentina	Primera Nacional	Chaco For Ever	Almirante Brown	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 02:01:35.193139	\N	\N	0	0	draw	yes
1234	1331403	2025-07-29	Argentina	Primera Nacional	Atlanta	Racing Cordoba	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	11	2025-11-20 02:01:35.201223	\N	\N	2	0	h-win	yes
1235	1331328	2025-07-30	Argentina	Primera Nacional	Deportivo Madryn	Quilmes	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	15	2025-11-20 02:01:35.207117	\N	\N	2	0	h-win	yes
1236	1331333	2025-07-31	Argentina	Primera Nacional	Defensores De Belgrano	San Telmo	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 02:01:35.212753	\N	\N	0	1	a-win	yes
1237	1356922	2025-07-03	Belarus	Premier League	ML Vitebsk	Dinamo Minsk	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	2	2025-11-20 03:13:35.482933	\N	\N	2	0	h-win	yes
1238	1356924	2025-07-04	Belarus	Premier League	Torpedo Zhodino	Molodechno-DYuSSh 4	h-win	4	1	\N	\N	\N	\N	\N	\N	\N	\N	0	1	0	0	\N	\N	\N	\N	\N	\N	\N	5	16	2025-11-20 03:13:35.647199	\N	\N	1	1	draw	yes
1239	1356921	2025-07-04	Belarus	Premier League	Dinamo Brest	FC Slutsk	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	0	1	0	0	\N	\N	\N	\N	\N	\N	\N	4	15	2025-11-20 03:13:35.834161	\N	\N	2	0	h-win	yes
1240	1356925	2025-07-04	Belarus	Premier League	Neman	FC Isloch Minsk R.	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	3	4	0	0	\N	\N	\N	\N	\N	\N	\N	8	6	2025-11-20 03:13:36.018921	\N	\N	1	0	h-win	yes
1241	1356923	2025-07-05	Belarus	Premier League	Smorgon	FC Gomel	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	1	3	0	0	\N	\N	\N	\N	\N	\N	\N	14	9	2025-11-20 03:13:36.201764	\N	\N	0	0	draw	yes
1242	1356926	2025-07-05	Belarus	Premier League	Slavia Mozyr	FC Vitebsk	h-win	4	0	\N	\N	\N	\N	\N	\N	\N	\N	1	3	0	0	\N	\N	\N	\N	\N	\N	\N	3	11	2025-11-20 03:13:36.403923	\N	\N	2	0	h-win	yes
1243	1356927	2025-07-05	Belarus	Premier League	Bate Borisov	FC Minsk	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	0	1	0	0	\N	\N	\N	\N	\N	\N	\N	10	7	2025-11-20 03:13:36.583832	\N	\N	0	1	a-win	yes
1244	1356920	2025-07-06	Belarus	Premier League	Arsenal	Naftan	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	1	0	0	0	\N	\N	\N	\N	\N	\N	\N	12	13	2025-11-20 03:13:36.775644	\N	\N	0	0	draw	yes
1245	1378527	2025-07-04	Belarus	1. Division	Ostrovets FC	Gomel II	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	10	15	2025-11-20 03:13:38.154932	\N	\N	0	1	a-win	yes
1246	1378417	2025-07-05	Belarus	1. Division	Belshina	Niva	a-win	2	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	7	2025-11-20 03:13:38.34408	\N	\N	2	1	h-win	yes
1247	1378525	2025-07-05	Belarus	1. Division	Lida	ABFF U19	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	13	2025-11-20 03:13:38.53749	\N	\N	0	1	a-win	yes
1248	1378420	2025-07-05	Belarus	1. Division	Lokomotiv Gomel	Uni Minsk	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	14	2025-11-20 03:13:38.71804	\N	\N	1	0	h-win	yes
1249	1378421	2025-07-05	Belarus	1. Division	Volna	Orsha	h-win	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	16	2025-11-20 03:13:38.910057	\N	\N	3	0	h-win	yes
1250	1378524	2025-07-06	Belarus	1. Division	Dinamo Minsk II	BATE II	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	8	2025-11-20 03:13:39.097327	\N	\N	0	0	draw	yes
1251	1378418	2025-07-06	Belarus	1. Division	Bumprom	FC Dnepr Mogilev	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	2	2025-11-20 03:13:39.29374	\N	\N	0	0	draw	yes
1252	1378526	2025-07-06	Belarus	1. Division	Minsk II	Baranovichi	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	11	1	2025-11-20 03:13:39.49234	\N	\N	1	0	h-win	yes
1253	1377193	2025-07-13	Belarus	1. Division	Gomel II	ABFF U19	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	15	13	2025-11-20 03:13:39.666998	\N	\N	0	0	draw	yes
1254	1378531	2025-07-18	Belarus	1. Division	Niva	Dinamo Minsk II	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7	12	2025-11-20 03:13:39.875841	\N	\N	1	0	h-win	yes
1255	1378423	2025-07-18	Belarus	1. Division	Orsha	FC Dnepr Mogilev	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16	2	2025-11-20 03:13:40.067952	\N	\N	0	0	draw	yes
1256	1378529	2025-07-19	Belarus	1. Division	ABFF U19	Lokomotiv Gomel	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	13	4	2025-11-20 03:13:40.254054	\N	\N	2	2	draw	yes
1257	1378425	2025-07-19	Belarus	1. Division	Slonim	Uni Minsk	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	18	14	2025-11-20 03:13:40.439125	\N	\N	1	0	h-win	yes
1258	1378530	2025-07-19	Belarus	1. Division	Gomel II	Minsk II	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	15	11	2025-11-20 03:13:40.655545	\N	\N	0	1	a-win	yes
1259	1378426	2025-07-19	Belarus	1. Division	Volna	Ostrovets FC	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	10	2025-11-20 03:13:40.844603	\N	\N	1	1	draw	yes
1260	1378528	2025-07-19	Belarus	1. Division	BATE II	Bumprom	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8	5	2025-11-20 03:13:41.005506	\N	\N	0	2	a-win	yes
1261	1378424	2025-07-20	Belarus	1. Division	Osipovichy	Belshina	a-win	0	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	17	3	2025-11-20 03:13:41.202788	\N	\N	0	2	a-win	yes
1262	1378422	2025-07-20	Belarus	1. Division	Baranovichi	Lida	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	6	2025-11-20 03:13:41.401637	\N	\N	2	1	h-win	yes
1263	1378536	2025-07-25	Belarus	1. Division	Minsk II	Volna	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	11	9	2025-11-20 03:13:41.586163	\N	\N	0	1	a-win	yes
1264	1378429	2025-07-26	Belarus	1. Division	Lokomotiv Gomel	Baranovichi	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	1	2025-11-20 03:13:41.757118	\N	\N	0	0	draw	yes
1265	1378535	2025-07-26	Belarus	1. Division	Lida	Gomel II	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	15	2025-11-20 03:13:41.922471	\N	\N	2	0	h-win	yes
1266	1378534	2025-07-26	Belarus	1. Division	Slonim	ABFF U19	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	18	13	2025-11-20 03:13:42.080699	\N	\N	0	2	a-win	yes
1267	1378430	2025-07-26	Belarus	1. Division	Ostrovets FC	Orsha	h-win	6	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	10	16	2025-11-20 03:13:42.246807	\N	\N	2	2	draw	yes
1268	1378532	2025-07-26	Belarus	1. Division	Osipovichy	Dinamo Minsk II	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	17	12	2025-11-20 03:13:42.438647	\N	\N	1	1	draw	yes
1269	1378428	2025-07-26	Belarus	1. Division	Bumprom	Niva	h-win	4	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	7	2025-11-20 03:13:42.641771	\N	\N	3	0	h-win	yes
1270	1378427	2025-07-27	Belarus	1. Division	Belshina	Uni Minsk	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	14	2025-11-20 03:13:42.838987	\N	\N	1	0	h-win	yes
1271	1378533	2025-07-28	Belarus	1. Division	FC Dnepr Mogilev	BATE II	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	8	2025-11-20 03:13:43.033402	\N	\N	0	1	a-win	yes
1272	1378419	2025-07-05	Belarus	1. Division	Slonim	Osipovichy	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 03:13:43.221474	\N	\N	1	1	draw	no
1273	1378264	2025-07-01	Bolivia	Primera División	Guabirá	Independiente Petrolero	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	6	2025-11-20 03:13:44.582652	\N	\N	0	0	draw	yes
1274	1378265	2025-07-05	Bolivia	Primera División	Real Tomayapo	San Antonio Bulo Bulo	draw	1	1	12	3	20	5	6	6	2	0	5	2	1	0	43.00	57.00	13	7	\N	\N	\N	11	7	2025-11-20 03:13:44.760017	0.58	3.13	0	0	draw	yes
1275	1378266	2025-07-06	Bolivia	Primera División	Universitario de Vinto	Aurora	a-win	1	2	13	4	18	6	5	7	0	5	2	3	1	0	45.00	55.00	13	7	\N	\N	\N	13	16	2025-11-20 03:13:44.931052	\N	\N	1	0	h-win	yes
1276	1378267	2025-07-06	Bolivia	Primera División	Always Ready	The Strongest	h-win	7	2	14	11	9	4	3	2	2	1	2	3	0	0	53.00	47.00	8	12	\N	\N	\N	1	2	2025-11-20 03:13:45.100065	\N	\N	2	1	h-win	yes
1277	1378268	2025-07-06	Bolivia	Primera División	Gualberto Villarroel SJ	Oriente Petrolero	h-win	5	1	17	9	5	1	7	6	5	1	0	1	0	1	53.00	47.00	7	7	\N	\N	\N	8	10	2025-11-20 03:13:45.279838	\N	\N	3	0	h-win	yes
1278	1378269	2025-07-07	Bolivia	Primera División	Blooming	Real Oruro	h-win	4	2	22	11	11	5	9	0	1	1	4	5	0	1	64.00	36.00	21	20	\N	\N	\N	4	12	2025-11-20 03:13:45.457204	\N	\N	1	1	draw	yes
1279	1378270	2025-07-07	Bolivia	Primera División	ABB	Nacional Potosí	draw	2	2	10	2	16	7	0	5	2	4	6	4	2	1	48.00	52.00	13	12	\N	\N	\N	14	9	2025-11-20 03:13:45.633114	\N	\N	1	2	a-win	yes
1280	1378271	2025-07-08	Bolivia	Primera División	Bolívar	Independiente Petrolero	h-win	4	0	27	10	6	0	9	2	0	4	2	3	0	2	68.00	32.00	7	22	\N	\N	\N	3	6	2025-11-20 03:13:45.824722	\N	\N	2	0	h-win	yes
1281	1378272	2025-07-08	Bolivia	Primera División	Jorge Wilstermann	Guabirá	draw	1	1	16	5	12	3	7	4	1	1	1	1	0	0	57.00	43.00	11	14	\N	\N	\N	15	5	2025-11-20 03:13:46.00184	1.41	0.90	1	1	draw	yes
1282	1378273	2025-07-12	Bolivia	Primera División	Guabirá	Always Ready	h-win	5	0	17	8	9	7	3	5	1	1	1	4	0	2	50.00	50.00	15	8	\N	\N	\N	5	1	2025-11-20 03:13:46.182199	2.91	0.29	3	0	h-win	yes
1283	1378274	2025-07-12	Bolivia	Primera División	Independiente Petrolero	Universitario de Vinto	draw	1	1	14	4	8	4	6	7	3	2	1	2	0	0	48.00	52.00	16	14	\N	\N	\N	6	13	2025-11-20 03:13:46.3635	1.47	0.62	0	0	draw	yes
1284	1378275	2025-07-12	Bolivia	Primera División	The Strongest	Real Tomayapo	h-win	6	0	21	11	6	2	5	0	3	1	1	3	0	1	57.00	43.00	14	9	\N	\N	\N	2	11	2025-11-20 03:13:46.540668	4.00	0.19	2	0	h-win	yes
1285	1378277	2025-07-13	Bolivia	Primera División	Gualberto Villarroel SJ	Jorge Wilstermann	h-win	2	1	15	5	12	3	6	0	0	0	3	5	0	1	55.00	45.00	12	13	\N	\N	\N	8	15	2025-11-20 03:13:46.71857	1.19	1.08	1	0	h-win	yes
1286	1378278	2025-07-14	Bolivia	Primera División	Oriente Petrolero	ABB	draw	3	3	22	9	14	3	8	8	2	2	6	4	1	0	50.00	50.00	18	9	\N	\N	\N	10	14	2025-11-20 03:13:46.896243	3.36	0.77	2	0	h-win	yes
1287	1378279	2025-07-15	Bolivia	Primera División	Nacional Potosí	Real Oruro	a-win	2	3	8	5	21	10	4	6	3	1	5	5	1	0	51.00	49.00	18	10	\N	\N	\N	9	12	2025-11-20 03:13:47.075415	1.51	2.77	2	1	h-win	yes
1288	1378281	2025-07-19	Bolivia	Primera División	ABB	Aurora	h-win	2	1	7	3	17	6	1	7	1	3	3	4	1	0	37.00	63.00	9	13	\N	\N	\N	14	16	2025-11-20 03:13:47.250013	\N	\N	2	1	h-win	yes
1289	1378282	2025-07-19	Bolivia	Primera División	Bolívar	Oriente Petrolero	h-win	1	0	17	5	12	3	8	5	3	5	5	2	0	0	67.00	33.00	16	12	\N	\N	\N	3	10	2025-11-20 03:13:47.432983	\N	\N	0	0	draw	yes
1290	1378283	2025-07-20	Bolivia	Primera División	Universitario de Vinto	Gualberto Villarroel SJ	h-win	4	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	13	8	2025-11-20 03:13:47.619103	\N	\N	4	0	h-win	yes
1291	1378285	2025-07-20	Bolivia	Primera División	Real Oruro	San Antonio Bulo Bulo	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	7	2025-11-20 03:13:47.807603	\N	\N	0	0	draw	yes
1292	1378284	2025-07-20	Bolivia	Primera División	Always Ready	Independiente Petrolero	h-win	5	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	6	2025-11-20 03:13:47.997945	\N	\N	3	0	h-win	yes
1293	1378286	2025-07-21	Bolivia	Primera División	Jorge Wilstermann	The Strongest	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	15	2	2025-11-20 03:13:48.181818	\N	\N	1	1	draw	yes
1294	1378287	2025-07-22	Bolivia	Primera División	Blooming	Guabirá	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	5	2025-11-20 03:13:48.366935	\N	\N	1	0	h-win	yes
1295	1378288	2025-07-23	Bolivia	Primera División	Real Tomayapo	Nacional Potosí	a-win	0	1	11	4	16	4	7	8	1	1	2	2	0	0	48.00	52.00	12	13	\N	\N	\N	11	9	2025-11-20 03:13:48.549007	\N	\N	0	0	draw	yes
1296	1378247	2025-07-29	Bolivia	Primera División	ABB	Independiente Petrolero	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	14	6	2025-11-20 03:13:48.73628	\N	\N	0	2	a-win	yes
1297	1370697	2025-07-30	Bolivia	Primera División	Nacional Potosí	Oriente Petrolero	h-win	4	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	10	2025-11-20 03:13:48.899779	\N	\N	2	0	h-win	yes
1298	1353392	2025-07-01	Brazil	Serie B	Cuiaba	Botafogo SP	a-win	0	1	16	3	12	3	5	3	2	1	2	2	0	0	66.00	34.00	12	16	\N	\N	\N	11	16	2025-11-20 03:13:50.251832	1.67	1.71	0	0	draw	yes
1299	1353402	2025-07-04	Brazil	Serie B	Atletico Goianiense	CRB	h-win	2	1	15	4	20	4	2	5	1	0	4	1	0	0	41.00	59.00	17	10	\N	\N	\N	10	8	2025-11-20 03:13:50.457916	1.54	1.62	1	1	draw	yes
1300	1353400	2025-07-05	Brazil	Serie B	Coritiba	Volta Redonda	h-win	2	0	11	5	17	7	3	5	1	1	6	2	0	0	39.00	61.00	24	21	\N	\N	\N	1	19	2025-11-20 03:13:50.635815	2.11	2.07	2	0	h-win	yes
1301	1353403	2025-07-05	Brazil	Serie B	remo	Cuiaba	draw	0	0	10	4	8	3	7	5	1	1	2	7	0	0	62.00	38.00	8	16	\N	\N	\N	6	11	2025-11-20 03:13:50.822782	0.63	0.36	0	0	draw	yes
1302	1353404	2025-07-06	Brazil	Serie B	Avai	Paysandu	draw	0	0	18	5	3	1	2	1	1	0	1	3	0	0	70.00	30.00	12	22	\N	\N	\N	9	20	2025-11-20 03:13:51.007722	2.01	0.10	0	0	draw	yes
1303	1353406	2025-07-06	Brazil	Serie B	Amazonas	Atletico Paranaense	a-win	0	1	9	1	15	4	3	5	0	2	3	1	1	0	58.00	42.00	14	11	\N	\N	\N	18	2	2025-11-20 03:13:51.186615	0.37	1.33	0	1	a-win	yes
1304	1353408	2025-07-06	Brazil	Serie B	Ferroviária	Vila Nova	a-win	1	3	16	3	15	9	7	8	0	1	3	1	0	0	61.00	39.00	14	13	\N	\N	\N	17	13	2025-11-20 03:13:51.361971	1.48	2.56	1	1	draw	yes
1305	1353409	2025-07-06	Brazil	Serie B	Botafogo SP	Novorizontino	draw	0	0	18	6	3	2	8	2	1	2	2	2	0	0	53.00	47.00	13	5	\N	\N	\N	16	7	2025-11-20 03:13:51.540565	1.13	0.26	0	0	draw	yes
1306	1353405	2025-07-08	Brazil	Serie B	Operario-PR	Chapecoense-sc	a-win	1	2	19	7	12	6	1	2	1	3	1	4	0	0	55.00	45.00	12	12	\N	\N	\N	14	5	2025-11-20 03:13:51.717716	2.15	1.63	1	0	h-win	yes
1307	1353407	2025-07-08	Brazil	Serie B	America Mineiro	Athletic Club	a-win	0	1	19	1	12	6	8	9	2	1	2	1	0	0	55.00	45.00	14	11	\N	\N	\N	12	15	2025-11-20 03:13:51.893645	0.96	0.77	0	1	a-win	yes
1308	1353401	2025-07-09	Brazil	Serie B	Goias	Criciuma	draw	1	1	12	3	14	2	8	6	1	1	3	4	1	0	51.00	49.00	23	14	\N	\N	\N	4	3	2025-11-20 03:13:52.079778	1.61	0.49	0	1	a-win	yes
1309	1353416	2025-07-11	Brazil	Serie B	CRB	Coritiba	a-win	0	1	30	10	6	3	10	2	1	0	5	5	0	0	66.00	34.00	13	14	\N	\N	\N	8	1	2025-11-20 03:13:52.261865	1.66	1.14	0	0	draw	yes
1310	1353411	2025-07-12	Brazil	Serie B	Vila Nova	Operario-PR	draw	0	0	10	5	6	3	5	0	1	1	3	3	0	0	46.00	54.00	19	18	\N	\N	\N	13	14	2025-11-20 03:13:52.428297	0.83	1.07	0	0	draw	yes
1311	1353418	2025-07-12	Brazil	Serie B	Novorizontino	America Mineiro	h-win	3	1	19	5	17	7	2	3	3	0	1	3	0	0	54.00	46.00	15	10	\N	\N	\N	7	12	2025-11-20 03:13:52.589894	2.47	2.03	1	1	draw	yes
1312	1353413	2025-07-12	Brazil	Serie B	Paysandu	Atletico Goianiense	draw	2	2	12	5	18	8	11	6	2	1	4	4	0	0	45.00	55.00	18	16	\N	\N	\N	20	10	2025-11-20 03:13:52.773438	0.51	2.39	1	2	a-win	yes
1313	1353410	2025-07-13	Brazil	Serie B	Atletico Paranaense	Goias	a-win	0	1	21	2	7	4	8	2	1	0	1	3	0	0	69.00	31.00	10	15	\N	\N	\N	2	4	2025-11-20 03:13:52.955902	1.15	0.87	0	0	draw	yes
1314	1353415	2025-07-13	Brazil	Serie B	Criciuma	Ferroviária	h-win	2	1	16	8	11	3	12	2	1	3	3	4	0	0	51.00	49.00	20	11	\N	\N	\N	3	17	2025-11-20 03:13:53.1466	1.76	1.40	1	1	draw	yes
1315	1353414	2025-07-13	Brazil	Serie B	Chapecoense-sc	remo	draw	1	1	14	8	10	3	6	4	0	1	3	3	1	0	46.00	54.00	12	11	\N	\N	\N	5	6	2025-11-20 03:13:53.324484	2.35	0.35	0	0	draw	yes
1316	1353417	2025-07-15	Brazil	Serie B	Athletic Club	Avai	h-win	4	0	9	7	9	0	5	7	2	5	3	2	0	1	54.00	46.00	11	7	\N	\N	\N	15	9	2025-11-20 03:13:53.492798	1.01	0.69	2	0	h-win	yes
1317	1353419	2025-07-15	Brazil	Serie B	Botafogo SP	Volta Redonda	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16	19	2025-11-20 03:13:53.682864	\N	\N	0	0	draw	yes
1318	1353412	2025-07-16	Brazil	Serie B	Cuiaba	Amazonas	h-win	3	1	8	4	14	5	1	7	3	3	1	4	0	0	42.00	58.00	12	15	\N	\N	\N	11	18	2025-11-20 03:13:53.875389	1.72	0.29	2	1	h-win	yes
1319	1353425	2025-07-18	Brazil	Serie B	Operario-PR	CRB	draw	1	1	18	3	9	2	5	5	2	3	3	1	1	1	61.00	39.00	11	15	\N	\N	\N	14	8	2025-11-20 03:13:54.031295	\N	\N	1	1	draw	yes
1320	1353423	2025-07-18	Brazil	Serie B	remo	Novorizontino	draw	1	1	10	2	17	4	5	7	2	3	3	2	0	0	52.00	48.00	10	13	\N	\N	\N	6	7	2025-11-20 03:13:54.202315	\N	\N	1	1	draw	yes
1321	1353422	2025-07-19	Brazil	Serie B	Atletico Goianiense	Criciuma	a-win	0	1	9	2	8	2	4	2	3	3	0	2	0	0	56.00	44.00	4	16	\N	\N	\N	10	3	2025-11-20 03:13:54.405807	\N	\N	0	0	draw	yes
1322	1353428	2025-07-19	Brazil	Serie B	Ferroviária	Athletic Club	a-win	1	2	9	5	7	2	2	2	5	1	7	2	4	0	40.00	60.00	16	15	\N	\N	\N	17	15	2025-11-20 03:13:54.589736	1.13	1.52	1	1	draw	yes
1323	1353421	2025-07-19	Brazil	Serie B	Goias	Cuiaba	h-win	3	1	14	4	7	3	2	5	2	0	4	3	0	1	65.00	35.00	14	9	\N	\N	\N	4	11	2025-11-20 03:13:54.782398	1.44	0.83	1	0	h-win	yes
1324	1353424	2025-07-19	Brazil	Serie B	Avai	Vila Nova	draw	1	1	20	6	13	5	10	6	0	0	0	3	0	0	47.00	53.00	12	16	\N	\N	\N	9	13	2025-11-20 03:13:54.971831	1.31	1.16	0	0	draw	yes
1325	1353420	2025-07-19	Brazil	Serie B	Coritiba	Paysandu	a-win	2	5	20	3	12	6	10	2	4	0	4	2	0	0	67.00	33.00	16	12	\N	\N	\N	1	20	2025-11-20 03:13:55.171961	2.16	1.45	1	3	a-win	yes
1326	1353429	2025-07-20	Brazil	Serie B	Volta Redonda	Atletico Paranaense	h-win	3	2	14	6	14	4	3	4	1	1	3	5	0	1	42.00	58.00	17	19	\N	\N	\N	19	2	2025-11-20 03:13:55.354107	0.93	1.46	0	2	a-win	yes
1327	1353426	2025-07-20	Brazil	Serie B	Amazonas	Botafogo SP	h-win	3	0	12	3	9	3	1	7	0	1	2	1	0	0	42.00	58.00	15	12	\N	\N	\N	18	16	2025-11-20 03:13:55.538044	\N	\N	1	0	h-win	yes
1328	1353427	2025-07-20	Brazil	Serie B	America Mineiro	Chapecoense-sc	a-win	0	1	25	7	11	4	7	3	1	4	1	3	0	0	66.00	34.00	12	11	\N	\N	\N	12	5	2025-11-20 03:13:55.73212	\N	\N	0	1	a-win	yes
1329	1353435	2025-07-23	Brazil	Serie B	Operario-PR	Atletico Goianiense	h-win	3	0	11	5	3	3	3	2	1	3	3	6	0	2	54.00	46.00	14	26	\N	\N	\N	14	10	2025-11-20 03:13:55.909906	\N	\N	0	0	draw	yes
1330	1353430	2025-07-23	Brazil	Serie B	Atletico Paranaense	Ferroviária	draw	1	1	27	8	7	2	11	1	1	3	1	4	0	0	59.00	41.00	13	14	\N	\N	\N	2	17	2025-11-20 03:13:56.09208	\N	\N	0	0	draw	yes
1331	1353437	2025-07-23	Brazil	Serie B	Athletic Club	Coritiba	draw	1	1	6	3	5	5	5	3	1	3	2	3	0	0	42.00	58.00	14	18	\N	\N	\N	15	1	2025-11-20 03:13:56.289918	\N	\N	1	1	draw	yes
1332	1353431	2025-07-23	Brazil	Serie B	Vila Nova	CRB	h-win	2	0	13	6	23	6	5	7	1	1	2	2	0	0	28.00	72.00	12	12	\N	\N	\N	13	8	2025-11-20 03:13:56.473856	\N	\N	1	0	h-win	yes
1333	1353434	2025-07-24	Brazil	Serie B	Chapecoense-sc	Volta Redonda	h-win	4	2	23	8	17	4	7	5	3	0	2	3	0	0	49.00	51.00	12	15	\N	\N	\N	5	19	2025-11-20 03:13:56.659897	\N	\N	3	1	h-win	yes
1334	1353438	2025-07-24	Brazil	Serie B	Novorizontino	Goias	h-win	1	0	13	3	15	6	3	8	5	1	4	2	0	0	47.00	53.00	11	12	\N	\N	\N	7	4	2025-11-20 03:13:56.843551	\N	\N	1	0	h-win	yes
1335	1353432	2025-07-24	Brazil	Serie B	Cuiaba	America Mineiro	h-win	3	1	8	5	13	5	2	9	1	1	3	2	0	1	34.00	66.00	8	11	\N	\N	\N	11	12	2025-11-20 03:13:57.027134	\N	\N	1	1	draw	yes
1336	1353436	2025-07-24	Brazil	Serie B	Amazonas	Paysandu	draw	1	1	22	4	11	2	13	3	1	4	3	0	0	1	68.00	32.00	13	6	\N	\N	\N	18	20	2025-11-20 03:13:57.21151	\N	\N	0	1	a-win	yes
1337	1353439	2025-07-25	Brazil	Serie B	Botafogo SP	Criciuma	a-win	0	2	18	4	13	5	6	5	1	0	1	2	0	0	58.00	42.00	16	10	\N	\N	\N	16	3	2025-11-20 03:13:57.395548	\N	\N	0	1	a-win	yes
1338	1353433	2025-07-25	Brazil	Serie B	remo	Avai	h-win	2	1	13	7	17	6	7	2	0	0	3	1	0	1	50.00	50.00	9	15	\N	\N	\N	6	9	2025-11-20 03:13:57.586885	1.29	0.99	2	1	h-win	yes
1339	1353448	2025-07-26	Brazil	Serie B	Ferroviária	Operario-PR	draw	0	0	7	3	27	6	4	16	0	4	4	2	1	0	23.00	77.00	9	16	\N	\N	\N	17	14	2025-11-20 03:13:57.761464	1.07	1.60	0	0	draw	yes
1340	1353446	2025-07-27	Brazil	Serie B	CRB	Novorizontino	h-win	4	0	17	6	19	5	3	10	1	2	2	3	0	0	50.00	50.00	11	12	\N	\N	\N	8	7	2025-11-20 03:13:57.936679	2.55	0.69	1	0	h-win	yes
1341	1353440	2025-07-27	Brazil	Serie B	Coritiba	Amazonas	draw	1	1	11	4	5	2	8	2	1	0	3	3	0	0	53.00	47.00	15	13	\N	\N	\N	1	18	2025-11-20 03:13:58.113759	\N	\N	1	0	h-win	yes
1342	1353449	2025-07-27	Brazil	Serie B	Volta Redonda	Vila Nova	h-win	2	1	17	5	12	3	4	6	2	0	1	0	0	0	43.00	57.00	19	16	\N	\N	\N	19	13	2025-11-20 03:13:58.289056	\N	\N	1	0	h-win	yes
1343	1353447	2025-07-27	Brazil	Serie B	America Mineiro	Atletico Paranaense	draw	2	2	11	3	9	5	4	2	1	2	2	1	0	0	54.00	46.00	13	17	\N	\N	\N	12	2	2025-11-20 03:13:58.474904	\N	\N	0	1	a-win	yes
1344	1353442	2025-07-28	Brazil	Serie B	Atletico Goianiense	Chapecoense-sc	draw	0	0	13	3	6	1	3	3	3	0	4	1	0	0	55.00	45.00	17	20	\N	\N	\N	10	5	2025-11-20 03:13:58.65212	\N	\N	0	0	draw	yes
1345	1353444	2025-07-29	Brazil	Serie B	Avai	Botafogo SP	h-win	5	0	11	7	14	2	3	4	0	0	1	1	0	0	51.00	49.00	13	10	\N	\N	\N	9	16	2025-11-20 03:13:58.832997	\N	\N	4	0	h-win	yes
1346	1353443	2025-07-29	Brazil	Serie B	Paysandu	Athletic Club	draw	1	1	16	6	15	6	6	6	2	1	4	3	0	0	46.00	54.00	11	18	\N	\N	\N	20	15	2025-11-20 03:13:59.012083	\N	\N	1	1	draw	yes
1347	1353445	2025-07-30	Brazil	Serie B	Criciuma	Cuiaba	h-win	1	0	11	2	6	0	1	4	0	5	5	1	0	0	44.00	56.00	19	18	\N	\N	\N	3	11	2025-11-20 03:13:59.195342	\N	\N	1	0	h-win	yes
1348	1353441	2025-07-30	Brazil	Serie B	Goias	remo	draw	1	1	28	9	7	2	11	3	0	2	1	2	0	1	65.00	35.00	9	10	\N	\N	\N	4	6	2025-11-20 03:13:59.368237	\N	\N	0	1	a-win	yes
1349	1351169	2025-07-12	Brazil	Serie A	Internacional	Vitoria	h-win	1	0	20	3	11	4	2	5	2	1	2	1	0	0	63.00	37.00	15	14	\N	\N	\N	15	17	2025-11-20 03:14:00.737293	1.90	0.88	0	0	draw	yes
1350	1351163	2025-07-12	Brazil	Serie A	Flamengo	Sao Paulo	h-win	2	0	22	10	6	0	7	1	0	2	2	2	0	0	61.00	39.00	12	9	\N	\N	\N	1	9	2025-11-20 03:14:00.923687	1.30	0.25	0	0	draw	yes
1351	1351164	2025-07-12	Brazil	Serie A	Vasco DA Gama	Botafogo	a-win	0	2	11	5	21	6	5	3	0	1	2	2	0	0	66.00	34.00	12	14	\N	\N	\N	11	5	2025-11-20 03:14:01.100424	0.53	3.17	0	0	draw	yes
1352	1351170	2025-07-13	Brazil	Serie A	Bahia	Atletico-MG	h-win	2	1	18	5	10	2	4	7	0	0	2	2	0	0	47.00	53.00	12	11	\N	\N	\N	6	10	2025-11-20 03:14:01.260501	0.67	0.35	0	0	draw	yes
1353	1351165	2025-07-14	Brazil	Serie A	Corinthians	RB Bragantino	a-win	1	2	13	8	9	5	10	2	3	0	6	5	0	0	62.00	38.00	18	16	\N	\N	\N	13	8	2025-11-20 03:14:01.343686	2.34	1.78	0	1	a-win	yes
1354	1351168	2025-07-14	Brazil	Serie A	Cruzeiro	Gremio	h-win	4	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	14	2025-11-20 03:14:01.351306	\N	\N	2	0	h-win	yes
1355	1351171	2025-07-14	Brazil	Serie A	Fortaleza EC	Ceara	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	19	12	2025-11-20 03:14:01.360715	\N	\N	0	0	draw	yes
1356	1351172	2025-07-15	Brazil	Serie A	Juventude	Sport Recife	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	18	20	2025-11-20 03:14:01.368009	\N	\N	1	0	h-win	yes
1357	1351175	2025-07-17	Brazil	Serie A	Palmeiras	Mirassol	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	4	2025-11-20 03:14:01.379121	\N	\N	0	0	draw	yes
1358	1351181	2025-07-17	Brazil	Serie A	Ceara	Corinthians	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	13	2025-11-20 03:14:01.386712	\N	\N	0	0	draw	yes
1359	1351176	2025-07-17	Brazil	Serie A	Santos	Flamengo	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16	1	2025-11-20 03:14:01.3967	\N	\N	0	0	draw	yes
1360	1351174	2025-07-17	Brazil	Serie A	Botafogo	Vitoria	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	17	2025-11-20 03:14:01.403201	\N	\N	0	0	draw	yes
1361	1351177	2025-07-17	Brazil	Serie A	RB Bragantino	Sao Paulo	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8	9	2025-11-20 03:14:01.41187	\N	\N	1	1	draw	yes
1362	1351173	2025-07-18	Brazil	Serie A	Fluminense	Cruzeiro	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7	3	2025-11-20 03:14:01.417012	\N	\N	0	2	a-win	yes
1363	1351191	2025-07-19	Brazil	Serie A	Fortaleza EC	Bahia	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	19	6	2025-11-20 03:14:01.422942	\N	\N	1	0	h-win	yes
1364	1351184	2025-07-19	Brazil	Serie A	Vasco DA Gama	Gremio	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	11	14	2025-11-20 03:14:01.432222	\N	\N	0	0	draw	yes
1365	1351187	2025-07-19	Brazil	Serie A	Mirassol	Santos	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	16	2025-11-20 03:14:01.437447	\N	\N	0	0	draw	yes
1366	1351186	2025-07-20	Brazil	Serie A	Sao Paulo	Corinthians	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	13	2025-11-20 03:14:01.444358	\N	\N	2	0	h-win	yes
1367	1351189	2025-07-20	Brazil	Serie A	Internacional	Ceara	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	15	12	2025-11-20 03:14:01.455264	\N	\N	1	0	h-win	yes
1368	1351188	2025-07-20	Brazil	Serie A	Cruzeiro	Juventude	h-win	4	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	18	2025-11-20 03:14:01.461974	\N	\N	1	0	h-win	yes
1369	1351190	2025-07-20	Brazil	Serie A	Vitoria	RB Bragantino	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	17	8	2025-11-20 03:14:01.46938	\N	\N	1	0	h-win	yes
1370	1351185	2025-07-20	Brazil	Serie A	Palmeiras	Atletico-MG	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	10	2025-11-20 03:14:01.478586	\N	\N	1	1	draw	yes
1371	1351192	2025-07-20	Brazil	Serie A	Sport Recife	Botafogo	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	20	5	2025-11-20 03:14:01.486317	\N	\N	0	0	draw	yes
1372	1351183	2025-07-21	Brazil	Serie A	Flamengo	Fluminense	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	7	2025-11-20 03:14:01.494923	\N	\N	0	0	draw	yes
1373	1351193	2025-07-24	Brazil	Serie A	Fluminense	Palmeiras	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7	2	2025-11-20 03:14:01.501028	\N	\N	1	1	draw	yes
1374	1351201	2025-07-24	Brazil	Serie A	Ceara	Mirassol	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	4	2025-11-20 03:14:01.507875	\N	\N	0	2	a-win	yes
1375	1351195	2025-07-24	Brazil	Serie A	Corinthians	Cruzeiro	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	13	3	2025-11-20 03:14:01.514206	\N	\N	0	0	draw	yes
1376	1351196	2025-07-24	Brazil	Serie A	Santos	Internacional	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16	15	2025-11-20 03:14:01.519893	\N	\N	0	1	a-win	yes
1377	1351200	2025-07-24	Brazil	Serie A	Vitoria	Sport Recife	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	17	20	2025-11-20 03:14:01.532678	\N	\N	0	0	draw	yes
1378	1351197	2025-07-24	Brazil	Serie A	RB Bragantino	Flamengo	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8	1	2025-11-20 03:14:01.546918	\N	\N	0	0	draw	yes
1379	1351202	2025-07-25	Brazil	Serie A	Juventude	Sao Paulo	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	18	9	2025-11-20 03:14:01.557147	\N	\N	0	0	draw	yes
1380	1351204	2025-07-26	Brazil	Serie A	Botafogo	Corinthians	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	13	2025-11-20 03:14:01.563944	\N	\N	1	0	h-win	yes
1381	1351212	2025-07-26	Brazil	Serie A	Sport Recife	Santos	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	20	16	2025-11-20 03:14:01.572518	\N	\N	1	0	h-win	yes
1382	1351211	2025-07-26	Brazil	Serie A	Fortaleza EC	RB Bragantino	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	19	8	2025-11-20 03:14:01.580931	\N	\N	2	1	h-win	yes
1383	1351207	2025-07-26	Brazil	Serie A	Mirassol	Vitoria	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	17	2025-11-20 03:14:01.58975	\N	\N	1	1	draw	yes
1384	1351205	2025-07-27	Brazil	Serie A	Palmeiras	Gremio	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	14	2025-11-20 03:14:01.597826	\N	\N	1	0	h-win	yes
1385	1351206	2025-07-27	Brazil	Serie A	Sao Paulo	Fluminense	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	7	2025-11-20 03:14:01.610681	\N	\N	1	0	h-win	yes
1386	1351208	2025-07-27	Brazil	Serie A	Cruzeiro	Ceara	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	12	2025-11-20 03:14:01.616944	\N	\N	1	1	draw	yes
1387	1351210	2025-07-27	Brazil	Serie A	Bahia	Juventude	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	18	2025-11-20 03:14:01.624793	\N	\N	1	0	h-win	yes
1388	1351209	2025-07-27	Brazil	Serie A	Internacional	Vasco DA Gama	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	15	11	2025-11-20 03:14:01.630621	\N	\N	0	1	a-win	yes
1389	1351203	2025-07-28	Brazil	Serie A	Flamengo	Atletico-MG	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	10	2025-11-20 03:14:01.636086	\N	\N	0	0	draw	yes
1390	1351179	2025-07-30	Brazil	Serie A	Gremio	Fortaleza EC	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	14	19	2025-11-20 03:14:01.643563	\N	\N	2	1	h-win	yes
1391	1388005	2025-07-18	Bulgaria	First League	CSKA 1948	Arda Kardzhali	h-win	1	0	13	3	9	3	3	2	0	2	2	3	0	1	55.00	45.00	14	10	\N	\N	\N	2	12	2025-11-20 04:13:40.489928	0.69	2.10	0	0	draw	yes
1392	1388008	2025-07-18	Bulgaria	First League	Lokomotiv Sofia	Cherno More Varna	draw	1	1	12	4	15	5	7	3	2	1	0	1	0	0	39.00	61.00	11	8	\N	\N	\N	11	3	2025-11-20 04:13:40.680117	2.03	1.52	1	1	draw	yes
1393	1388009	2025-07-19	Bulgaria	First League	Ludogorets	Septemvri Sofia	h-win	5	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	14	2025-11-20 04:13:40.862339	\N	\N	1	0	h-win	yes
1394	1388004	2025-07-19	Bulgaria	First League	Botev Plovdiv	CSKA Sofia	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	6	2025-11-20 04:13:41.047076	\N	\N	1	1	draw	yes
1395	1388010	2025-07-20	Bulgaria	First League	Slavia Sofia	Botev Vratsa	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8	7	2025-11-20 04:13:41.222509	\N	\N	0	2	a-win	yes
1396	1388006	2025-07-20	Bulgaria	First League	Levski Sofia	Montana	h-win	5	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	15	2025-11-20 04:13:41.39052	\N	\N	2	0	h-win	yes
1397	1388007	2025-07-21	Bulgaria	First League	Lokomotiv Plovdiv	Dobrudzha	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	16	2025-11-20 04:13:41.562394	\N	\N	1	0	h-win	yes
1398	1388011	2025-07-21	Bulgaria	First League	Spartak Varna	Beroe	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	10	13	2025-11-20 04:13:41.743478	\N	\N	0	0	draw	yes
1399	1388014	2025-07-25	Bulgaria	First League	Botev Vratsa	Ludogorets	a-win	0	1	6	1	14	5	0	9	1	0	6	4	0	0	24.00	76.00	14	9	\N	\N	\N	7	5	2025-11-20 04:13:41.930741	0.26	0.94	0	0	draw	yes
1400	1388013	2025-07-26	Bulgaria	First League	Beroe	CSKA 1948	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	13	2	2025-11-20 04:13:42.083222	\N	\N	1	0	h-win	yes
1401	1388016	2025-07-26	Bulgaria	First League	CSKA Sofia	Spartak Varna	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	10	2025-11-20 04:13:42.290087	\N	\N	1	0	h-win	yes
1402	1388015	2025-07-27	Bulgaria	First League	Cherno More Varna	Botev Plovdiv	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	9	2025-11-20 04:13:42.479321	\N	\N	2	0	h-win	yes
1403	1388019	2025-07-27	Bulgaria	First League	Septemvri Sofia	Levski Sofia	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	14	1	2025-11-20 04:13:42.647404	\N	\N	1	0	h-win	yes
1404	1388012	2025-07-27	Bulgaria	First League	Arda Kardzhali	Lokomotiv Sofia	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	11	2025-11-20 04:13:42.823235	\N	\N	1	0	h-win	yes
1405	1388017	2025-07-28	Bulgaria	First League	Dobrudzha	Slavia Sofia	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16	8	2025-11-20 04:13:43.019244	\N	\N	1	1	draw	yes
1406	1388018	2025-07-28	Bulgaria	First League	Montana	Lokomotiv Plovdiv	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	15	4	2025-11-20 04:13:43.198478	\N	\N	1	1	draw	yes
1407	1339030	2025-07-05	Chile	Primera División	Union Espanola	Universidad de Chile	a-win	0	2	10	2	12	4	4	3	7	3	4	4	0	1	57.00	43.00	12	18	\N	\N	\N	15	4	2025-11-20 04:13:44.520779	\N	\N	0	1	a-win	yes
1408	1339038	2025-07-06	Chile	Primera División	U. Catolica	Colo Colo	h-win	2	0	9	6	3	1	3	1	2	2	2	1	0	0	46.00	54.00	17	11	\N	\N	\N	2	8	2025-11-20 04:13:44.697701	\N	\N	0	0	draw	yes
1409	1339054	2025-07-12	Chile	Primera División	Universidad de Chile	Colo Colo	h-win	2	1	10	4	10	4	1	4	0	2	5	4	1	1	44.00	56.00	14	17	\N	\N	\N	4	8	2025-11-20 04:13:44.862762	\N	\N	1	1	draw	yes
1410	1339129	2025-07-19	Chile	Primera División	Everton de Vina	Deportes Limache	draw	0	0	18	4	7	0	6	5	3	3	1	2	0	0	64.00	36.00	9	12	\N	\N	\N	13	14	2025-11-20 04:13:45.023631	0.59	0.38	0	0	draw	yes
1411	1339131	2025-07-19	Chile	Primera División	Union Espanola	Union La Calera	h-win	3	1	12	4	3	1	10	2	2	2	1	4	0	2	46.00	54.00	6	15	\N	\N	\N	15	11	2025-11-20 04:13:45.195355	1.62	0.80	0	1	a-win	yes
1412	1339126	2025-07-19	Chile	Primera División	Colo Colo	D. La Serena	h-win	2	1	18	7	11	6	7	4	0	2	1	3	0	0	61.00	39.00	10	14	\N	\N	\N	8	12	2025-11-20 04:13:45.394385	1.85	1.27	0	0	draw	yes
1413	1339128	2025-07-19	Chile	Primera División	Coquimbo Unido	Deportes Iquique	h-win	4	1	16	8	9	0	6	2	0	1	4	3	0	0	47.00	53.00	9	12	\N	\N	\N	1	16	2025-11-20 04:13:45.557729	2.97	0.55	1	1	draw	yes
1414	1339130	2025-07-20	Chile	Primera División	A. Italiano	U. Catolica	draw	1	1	9	2	11	3	2	5	2	0	3	5	0	1	50.00	50.00	16	14	\N	\N	\N	7	2	2025-11-20 04:13:45.729783	1.20	1.14	0	1	a-win	yes
1415	1339132	2025-07-20	Chile	Primera División	Nublense	Universidad de Chile	draw	2	2	9	4	10	5	1	3	5	0	1	4	0	0	41.00	59.00	11	10	\N	\N	\N	10	4	2025-11-20 04:13:45.914233	1.94	1.71	0	0	draw	yes
1416	1339133	2025-07-22	Chile	Primera División	Huachipato	O'Higgins	h-win	2	1	14	8	17	4	6	4	0	0	2	2	0	1	52.00	48.00	9	17	\N	\N	\N	9	3	2025-11-20 04:13:46.092709	\N	\N	0	1	a-win	yes
1417	1339139	2025-07-26	Chile	Primera División	Deportes Limache	Nublense	a-win	0	1	15	2	19	5	4	6	2	2	3	4	0	0	45.00	55.00	15	15	\N	\N	\N	14	10	2025-11-20 04:13:46.262143	\N	\N	0	0	draw	yes
1418	1339136	2025-07-26	Chile	Primera División	D. La Serena	Cobresal	a-win	0	2	18	3	13	5	11	4	3	3	3	3	0	0	70.00	30.00	9	10	\N	\N	\N	12	6	2025-11-20 04:13:46.43943	1.60	1.78	0	1	a-win	yes
1419	1339138	2025-07-26	Chile	Primera División	Everton de Vina	Huachipato	h-win	4	1	18	7	5	2	4	8	0	3	5	3	0	0	50.00	50.00	13	7	\N	\N	\N	13	9	2025-11-20 04:13:46.617443	2.53	1.02	3	1	h-win	yes
1420	1339141	2025-07-27	Chile	Primera División	O'Higgins	Colo Colo	draw	1	1	16	4	1	1	4	0	1	3	0	5	1	1	57.00	43.00	7	12	\N	\N	\N	3	8	2025-11-20 04:13:46.816898	\N	\N	0	1	a-win	yes
1421	1339140	2025-07-27	Chile	Primera División	Palestino	Union Espanola	h-win	1	0	14	6	13	6	7	2	5	2	3	4	0	1	61.00	39.00	14	17	\N	\N	\N	5	15	2025-11-20 04:13:46.98018	\N	\N	0	0	draw	yes
1422	1339134	2025-07-27	Chile	Primera División	U. Catolica	Coquimbo Unido	a-win	0	3	4	0	17	8	1	6	0	2	5	2	1	0	60.00	40.00	13	10	\N	\N	\N	2	1	2025-11-20 04:13:47.161341	\N	\N	0	2	a-win	yes
1423	1339135	2025-07-28	Chile	Primera División	Deportes Iquique	A. Italiano	h-win	1	0	12	3	16	5	2	6	3	5	1	1	0	0	38.00	62.00	8	10	\N	\N	\N	16	7	2025-11-20 04:13:47.340114	\N	\N	0	0	draw	yes
1424	1339137	2025-07-29	Chile	Primera División	Union La Calera	Universidad de Chile	a-win	0	4	4	2	15	6	4	3	1	0	3	2	1	0	30.00	70.00	7	12	\N	\N	\N	11	4	2025-11-20 04:13:47.518684	\N	\N	0	3	a-win	yes
1425	1341028	2025-07-18	China	Super League	Changchun Yatai	SHANGHAI SIPG	a-win	1	3	14	3	12	7	3	3	3	2	1	2	0	0	39.00	61.00	17	9	\N	\N	\N	16	1	2025-11-20 04:13:48.885319	1.56	1.61	0	1	a-win	yes
1426	1341027	2025-07-18	China	Super League	Wuhan Three Towns	Qingdao Youth Island	draw	1	1	14	4	10	3	11	3	0	3	0	0	0	0	50.00	50.00	10	12	\N	\N	\N	13	9	2025-11-20 04:13:49.053776	0.72	0.71	1	0	h-win	yes
1427	1341029	2025-07-18	China	Super League	Tianjin Teda	Chengdu Better City	h-win	2	1	6	3	14	5	3	3	0	5	1	5	0	1	37.00	63.00	13	12	\N	\N	\N	6	3	2025-11-20 04:13:49.205159	1.41	2.01	0	0	draw	yes
1428	1341030	2025-07-18	China	Super League	Hangzhou Greentown	Yunnan Yukun	h-win	3	1	24	11	11	3	7	8	2	0	4	1	0	0	54.00	46.00	15	13	\N	\N	\N	7	8	2025-11-20 04:13:49.371567	2.40	0.35	0	1	a-win	yes
1429	1341031	2025-07-19	China	Super League	Dalian Zhixing	Shandong Luneng	h-win	2	0	11	8	13	5	7	8	2	1	2	1	0	0	42.00	58.00	14	13	\N	\N	\N	11	5	2025-11-20 04:13:49.542206	0.80	1.13	1	0	h-win	yes
1430	1341033	2025-07-19	China	Super League	Beijing Guoan	Shanghai Shenhua	a-win	1	3	12	1	16	7	8	2	2	3	1	3	0	0	72.00	28.00	16	14	\N	\N	\N	4	2	2025-11-20 04:13:49.720134	1.32	2.12	1	2	a-win	yes
1431	1341032	2025-07-19	China	Super League	Sichuan Jiuniu	Qingdao Jonoon	h-win	4	0	19	8	16	2	5	7	4	4	0	1	0	0	46.00	54.00	8	8	\N	\N	\N	12	14	2025-11-20 04:13:49.895688	3.19	1.36	2	0	h-win	yes
1432	1341034	2025-07-19	China	Super League	Henan Jianye	Meizhou Kejia	draw	1	1	16	6	9	2	9	5	1	2	2	1	1	0	51.00	49.00	12	13	\N	\N	\N	10	15	2025-11-20 04:13:50.069351	2.51	1.38	0	0	draw	yes
1433	1341035	2025-07-26	China	Super League	SHANGHAI SIPG	Qingdao Youth Island	draw	2	2	14	5	11	3	6	2	3	2	1	2	0	0	66.00	34.00	9	17	\N	\N	\N	1	9	2025-11-20 04:13:50.248539	3.16	1.48	1	0	h-win	yes
1434	1341036	2025-07-26	China	Super League	Chengdu Better City	Beijing Guoan	h-win	2	0	19	8	8	2	4	4	4	2	0	1	0	0	35.00	65.00	7	19	\N	\N	\N	3	4	2025-11-20 04:13:50.442182	2.26	1.02	1	0	h-win	yes
1435	1341037	2025-07-26	China	Super League	Yunnan Yukun	Sichuan Jiuniu	h-win	3	1	17	5	10	3	4	6	2	2	0	1	0	0	45.00	55.00	14	15	\N	\N	\N	8	12	2025-11-20 04:13:50.62232	3.57	0.87	2	1	h-win	yes
1436	1341039	2025-07-27	China	Super League	Changchun Yatai	Dalian Zhixing	a-win	0	2	8	4	16	7	3	2	3	5	3	2	0	0	57.00	43.00	15	12	\N	\N	\N	16	11	2025-11-20 04:13:50.805271	0.63	1.39	0	1	a-win	yes
1437	1341038	2025-07-27	China	Super League	Qingdao Jonoon	Tianjin Teda	h-win	2	0	14	6	10	3	3	3	2	5	6	2	1	0	44.00	56.00	18	18	\N	\N	\N	14	6	2025-11-20 04:13:50.981361	2.34	1.01	1	0	h-win	yes
1438	1341041	2025-07-27	China	Super League	Shanghai Shenhua	Henan Jianye	h-win	3	2	19	9	10	4	7	3	4	0	2	2	0	0	47.00	53.00	16	10	\N	\N	\N	2	10	2025-11-20 04:13:51.164335	2.38	1.34	2	1	h-win	yes
1439	1341040	2025-07-27	China	Super League	Hangzhou Greentown	Wuhan Three Towns	h-win	3	2	17	8	12	6	7	2	1	0	0	3	0	0	55.00	45.00	18	18	\N	\N	\N	7	13	2025-11-20 04:13:51.345569	1.23	1.49	0	1	a-win	yes
1440	1341042	2025-07-27	China	Super League	Shandong Luneng	Meizhou Kejia	h-win	3	0	26	10	3	1	9	2	1	0	2	3	0	0	69.00	31.00	10	13	\N	\N	\N	5	15	2025-11-20 04:13:51.537272	3.38	0.37	0	0	draw	yes
1441	1384414	2025-07-18	Czech-Republic	FNL	Sparta Praha II	Baník Ostrava II	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	14	5	2025-11-20 04:13:56.202389	\N	\N	0	0	draw	yes
1442	1402769	2025-07-18	Czech-Republic	FNL	Příbram	Opava	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	4	2025-11-20 04:13:56.383294	\N	\N	0	1	a-win	yes
1443	1384417	2025-07-18	Czech-Republic	FNL	Vlašim	Slavia Praha II	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	15	7	2025-11-20 04:13:56.551438	\N	\N	0	0	draw	yes
1444	1384416	2025-07-18	Czech-Republic	FNL	Ústí nad Labem	Vysočina Jihlava	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	11	2025-11-20 04:13:56.732106	\N	\N	1	1	draw	yes
1445	1384411	2025-07-18	Czech-Republic	FNL	České Budějovice	Zbrojovka Brno	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	10	1	2025-11-20 04:13:56.905152	\N	\N	0	1	a-win	yes
1446	1384415	2025-07-19	Czech-Republic	FNL	Táborsko	Prostějov	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	12	2025-11-20 04:13:57.091272	\N	\N	1	0	h-win	yes
1447	1384412	2025-07-19	Czech-Republic	FNL	Hanácká	Viktoria Žižkov	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16	8	2025-11-20 04:13:57.268057	\N	\N	0	0	draw	yes
1448	1384423	2025-07-25	Czech-Republic	FNL	Prostějov	Chrudim	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	13	2025-11-20 04:13:57.448455	\N	\N	0	0	draw	yes
1449	1384420	2025-07-25	Czech-Republic	FNL	Vysočina Jihlava	Táborsko	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	11	2	2025-11-20 04:13:57.612312	\N	\N	0	1	a-win	yes
1450	1384419	2025-07-25	Czech-Republic	FNL	Zbrojovka Brno	Sparta Praha II	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	14	2025-11-20 04:13:57.796142	\N	\N	1	0	h-win	yes
1451	1384425	2025-07-25	Czech-Republic	FNL	Ústí nad Labem	Vlašim	h-win	4	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	15	2025-11-20 04:13:57.984443	\N	\N	3	1	h-win	yes
1452	1384421	2025-07-26	Czech-Republic	FNL	Opava	České Budějovice	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	10	2025-11-20 04:13:58.16484	\N	\N	2	0	h-win	yes
1453	1402771	2025-07-27	Czech-Republic	FNL	Viktoria Žižkov	Příbram	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8	6	2025-11-20 04:13:58.346221	\N	\N	2	0	h-win	yes
1454	1384424	2025-07-27	Czech-Republic	FNL	Slavia Praha II	Artis	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7	3	2025-11-20 04:13:58.511325	\N	\N	1	0	h-win	yes
1455	1384433	2025-07-30	Czech-Republic	FNL	Sparta Praha II	Slavia Praha II	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	14	7	2025-11-20 04:13:58.694477	\N	\N	1	0	h-win	yes
1456	1384427	2025-07-30	Czech-Republic	FNL	Artis	Vysočina Jihlava	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	11	2025-11-20 04:13:58.876898	\N	\N	0	1	a-win	yes
1457	1402772	2025-07-30	Czech-Republic	FNL	Příbram	Zbrojovka Brno	a-win	2	7	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	1	2025-11-20 04:13:59.047378	\N	\N	0	2	a-win	yes
1458	1384429	2025-07-30	Czech-Republic	FNL	Chrudim	Viktoria Žižkov	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	13	8	2025-11-20 04:13:59.209363	\N	\N	0	1	a-win	yes
1459	1384432	2025-07-30	Czech-Republic	FNL	Prostějov	Opava	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	4	2025-11-20 04:13:59.397681	\N	\N	0	0	draw	yes
1460	1384434	2025-07-30	Czech-Republic	FNL	Táborsko	Vlašim	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	15	2025-11-20 04:13:59.583118	\N	\N	2	1	h-win	yes
1461	1384428	2025-07-30	Czech-Republic	FNL	České Budějovice	Baník Ostrava II	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	10	5	2025-11-20 04:13:59.757979	\N	\N	0	1	a-win	yes
1462	1384430	2025-07-30	Czech-Republic	FNL	Hanácká	Ústí nad Labem	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16	9	2025-11-20 04:13:59.938116	\N	\N	2	2	draw	yes
3659	1387170	2025-08-30	England	League One	Lincoln	Mansfield Town	draw	1	1	7	2	14	4	3	11	4	0	6	2	1	0	35.00	65.00	14	16	\N	\N	\N	2	9	2025-11-20 18:16:57.533048	\N	\N	1	0	h-win	yes
3660	1387178	2025-09-06	England	League One	Huddersfield	Peterborough	h-win	3	2	11	5	5	3	1	3	3	3	1	1	0	0	50.00	50.00	16	10	\N	\N	\N	10	23	2025-11-20 18:16:57.759791	\N	\N	0	0	draw	yes
3661	1387176	2025-09-06	England	League One	Bolton	AFC Wimbledon	h-win	3	0	24	8	9	2	8	2	3	3	2	3	0	2	62.00	38.00	14	18	\N	\N	\N	4	7	2025-11-20 18:16:57.930932	\N	\N	1	0	h-win	yes
3662	1387183	2025-09-06	England	League One	Rotherham	Exeter City	h-win	1	0	14	5	5	1	9	5	1	5	1	0	0	0	39.00	61.00	13	9	\N	\N	\N	11	20	2025-11-20 18:16:58.076478	\N	\N	1	0	h-win	yes
3663	1387181	2025-09-06	England	League One	Port Vale	Leyton Orient	a-win	2	3	15	8	10	4	5	2	1	2	1	3	0	0	43.00	57.00	7	6	\N	\N	\N	22	16	2025-11-20 18:16:58.239556	\N	\N	1	2	a-win	yes
3664	1387177	2025-09-06	England	League One	Doncaster	Bradford	h-win	3	1	15	5	7	1	3	7	2	2	0	2	0	0	41.00	59.00	9	12	\N	\N	\N	19	3	2025-11-20 18:16:58.441403	\N	\N	3	1	h-win	yes
3665	1387180	2025-09-06	England	League One	Plymouth	Stockport County	h-win	4	2	8	5	9	3	8	7	2	0	2	1	0	0	38.00	62.00	7	14	\N	\N	\N	24	1	2025-11-20 18:16:58.654935	\N	\N	2	1	h-win	yes
3666	1387185	2025-09-06	England	League One	Wycombe	Mansfield Town	h-win	2	0	10	3	11	2	7	5	1	2	3	3	0	0	42.00	58.00	13	12	\N	\N	\N	14	9	2025-11-20 18:16:58.85961	\N	\N	1	0	h-win	yes
3667	1387179	2025-09-06	England	League One	Lincoln	Wigan	draw	2	2	11	6	14	7	6	11	2	1	5	0	1	1	42.00	58.00	13	11	\N	\N	\N	2	17	2025-11-20 18:16:59.043269	\N	\N	2	1	h-win	yes
3668	1387195	2025-09-13	England	League One	Northampton	Blackpool	h-win	1	0	9	4	14	4	5	5	1	4	1	1	0	0	45.00	55.00	9	9	\N	\N	\N	15	21	2025-11-20 18:16:59.253542	\N	\N	0	0	draw	yes
3669	1387189	2025-09-13	England	League One	Bradford	Huddersfield	h-win	3	1	13	4	8	2	5	11	0	0	1	5	0	0	46.00	54.00	12	13	\N	\N	\N	3	10	2025-11-20 18:16:59.451708	\N	\N	3	0	h-win	yes
3670	1387197	2025-09-13	England	League One	Wigan	Doncaster	h-win	3	0	13	8	9	3	10	10	1	0	2	1	0	0	43.00	57.00	15	10	\N	\N	\N	17	19	2025-11-20 18:16:59.754426	\N	\N	2	0	h-win	yes
3671	1387188	2025-09-13	England	League One	Barnsley	Reading	h-win	3	2	15	5	14	5	5	4	1	0	3	5	0	0	54.00	46.00	19	15	\N	\N	\N	13	18	2025-11-20 18:16:59.988245	\N	\N	1	1	draw	yes
3672	1387190	2025-09-13	England	League One	Burton Albion	Lincoln	a-win	0	1	16	2	10	3	6	3	1	4	2	3	0	0	65.00	35.00	11	15	\N	\N	\N	12	2	2025-11-20 18:17:00.196398	\N	\N	0	1	a-win	yes
3673	1387187	2025-09-13	England	League One	AFC Wimbledon	Rotherham	h-win	2	1	10	5	7	3	5	5	3	1	2	3	0	0	47.00	53.00	16	10	\N	\N	\N	7	11	2025-11-20 18:17:00.379415	\N	\N	0	1	a-win	yes
1478	1379349	2025-07-18	Denmark	Superliga	Viborg	FC Copenhagen	a-win	2	3	10	4	21	6	6	5	0	2	1	1	0	0	46.00	54.00	4	11	\N	\N	\N	6	4	2025-11-20 04:14:05.059264	1.98	3.79	1	1	draw	yes
1479	1379351	2025-07-20	Denmark	Superliga	Vejle	Randers FC	draw	1	1	14	3	6	2	5	5	1	5	0	2	0	0	44.00	56.00	13	11	\N	\N	\N	12	10	2025-11-20 04:14:05.243249	0.73	1.02	0	0	draw	yes
1480	1379350	2025-07-20	Denmark	Superliga	FC Fredericia	FC Nordsjaelland	a-win	2	3	6	3	13	7	5	2	2	1	3	2	0	0	39.00	61.00	14	10	\N	\N	\N	11	9	2025-11-20 04:14:05.430663	1.25	1.21	1	3	a-win	yes
1481	1379352	2025-07-20	Denmark	Superliga	Sonderjyske	Aarhus	draw	1	1	12	3	11	3	4	3	3	2	0	2	0	0	44.00	56.00	11	6	\N	\N	\N	5	3	2025-11-20 04:14:05.619389	1.40	0.58	0	1	a-win	yes
1482	1379353	2025-07-20	Denmark	Superliga	FC Midtjylland	Odense	draw	3	3	17	7	11	3	6	7	6	2	2	3	0	0	58.00	42.00	9	18	\N	\N	\N	1	7	2025-11-20 04:14:05.796477	2.21	2.40	2	2	draw	yes
1483	1379354	2025-07-20	Denmark	Superliga	Brondby	Silkeborg	h-win	3	0	13	5	8	2	2	2	2	1	0	1	0	0	53.00	47.00	12	7	\N	\N	\N	2	8	2025-11-20 04:14:05.971411	1.63	0.60	1	0	h-win	yes
1484	1379355	2025-07-25	Denmark	Superliga	Aarhus	Randers FC	a-win	1	2	14	4	12	5	3	3	0	1	2	3	0	0	57.00	43.00	7	21	\N	\N	\N	3	10	2025-11-20 04:14:06.13386	1.93	1.42	1	0	h-win	yes
1485	1379356	2025-07-26	Denmark	Superliga	FC Copenhagen	Vejle	h-win	2	0	15	4	8	1	3	8	1	0	0	3	0	0	47.00	53.00	14	9	\N	\N	\N	4	12	2025-11-20 04:14:06.326991	2.37	0.82	2	0	h-win	yes
1486	1379357	2025-07-27	Denmark	Superliga	Odense	Viborg	h-win	3	1	13	6	15	5	5	4	0	2	2	1	0	0	45.00	55.00	15	8	\N	\N	\N	7	6	2025-11-20 04:14:06.507253	1.70	0.74	1	0	h-win	yes
1487	1379358	2025-07-27	Denmark	Superliga	Silkeborg	FC Fredericia	a-win	0	2	18	5	8	3	10	1	0	1	0	1	0	0	58.00	42.00	8	9	\N	\N	\N	8	11	2025-11-20 04:14:06.68406	1.94	1.26	0	2	a-win	yes
1488	1379359	2025-07-27	Denmark	Superliga	FC Nordsjaelland	Brondby	a-win	0	1	15	5	7	1	7	0	1	2	1	2	0	0	55.00	45.00	8	5	\N	\N	\N	9	2	2025-11-20 04:14:06.880025	0.89	0.62	0	1	a-win	yes
1489	1379360	2025-07-28	Denmark	Superliga	FC Midtjylland	Sonderjyske	h-win	6	2	21	9	20	7	5	3	3	0	0	1	0	0	55.00	45.00	6	14	\N	\N	\N	1	5	2025-11-20 04:14:07.060029	3.37	1.98	3	1	h-win	yes
1490	1379940	2025-07-18	Denmark	1. Division	HB Koge	Hobro	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	10	11	2025-11-20 04:14:08.414136	\N	\N	1	0	h-win	yes
1491	1379941	2025-07-18	Denmark	1. Division	Hvidovre	B 93	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	8	2025-11-20 04:14:08.594864	\N	\N	1	1	draw	yes
1492	1379942	2025-07-19	Denmark	1. Division	Kolding IF	Aalborg	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7	5	2025-11-20 04:14:08.765917	\N	\N	0	0	draw	yes
1493	1379943	2025-07-19	Denmark	1. Division	Hillerød	Middelfart	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	12	2025-11-20 04:14:08.949796	\N	\N	1	1	draw	yes
1494	1379944	2025-07-19	Denmark	1. Division	AC Horsens	Aarhus Fremad	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	9	2025-11-20 04:14:09.122509	\N	\N	0	0	draw	yes
1495	1379945	2025-07-20	Denmark	1. Division	Esbjerg	Lyngby	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	1	2025-11-20 04:14:09.306876	\N	\N	0	1	a-win	yes
1496	1379946	2025-07-25	Denmark	1. Division	HB Koge	Aarhus Fremad	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	10	9	2025-11-20 04:14:09.481063	\N	\N	1	0	h-win	yes
1497	1379947	2025-07-25	Denmark	1. Division	AC Horsens	Kolding IF	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	7	2025-11-20 04:14:09.656067	\N	\N	0	1	a-win	yes
1498	1379948	2025-07-25	Denmark	1. Division	Lyngby	B 93	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	8	2025-11-20 04:14:09.817545	\N	\N	0	1	a-win	yes
1499	1379949	2025-07-26	Denmark	1. Division	Esbjerg	Hvidovre	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	3	2025-11-20 04:14:09.981187	\N	\N	1	1	draw	yes
1500	1379950	2025-07-26	Denmark	1. Division	Hillerød	Aalborg	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	5	2025-11-20 04:14:10.15785	\N	\N	1	2	a-win	yes
1501	1379951	2025-07-27	Denmark	1. Division	Hobro	Middelfart	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	11	12	2025-11-20 04:14:10.260485	\N	\N	0	0	draw	yes
3674	1387196	2025-09-13	England	League One	Peterborough	Wycombe	h-win	2	1	16	6	12	5	3	4	1	2	3	1	0	0	46.00	54.00	12	14	\N	\N	\N	23	14	2025-11-20 18:17:00.57436	\N	\N	2	0	h-win	yes
3675	1387193	2025-09-13	England	League One	Luton	Plymouth	a-win	2	3	22	7	6	3	16	3	1	1	2	3	0	1	66.00	34.00	12	10	\N	\N	\N	8	24	2025-11-20 18:17:00.746632	\N	\N	1	2	a-win	yes
3676	1387191	2025-09-13	England	League One	Exeter City	Port Vale	a-win	0	2	11	4	5	2	8	2	2	3	1	2	0	0	70.00	30.00	6	14	\N	\N	\N	20	22	2025-11-20 18:17:00.935105	\N	\N	0	2	a-win	yes
3677	1387192	2025-09-13	England	League One	Leyton Orient	Bolton	draw	1	1	6	1	11	4	3	8	0	4	3	2	0	0	38.00	62.00	13	9	\N	\N	\N	16	4	2025-11-20 18:17:01.123787	\N	\N	0	0	draw	yes
3678	1387194	2025-09-13	England	League One	Mansfield Town	Stevenage	draw	1	1	7	2	9	4	3	9	3	2	2	4	0	0	50.00	50.00	8	8	\N	\N	\N	9	6	2025-11-20 18:17:01.33256	\N	\N	0	0	draw	yes
3679	1387198	2025-09-13	England	League One	Stockport County	Cardiff	draw	1	1	14	3	4	2	7	2	1	4	0	1	0	0	47.00	53.00	14	11	\N	\N	\N	1	5	2025-11-20 18:17:01.565641	\N	\N	1	0	h-win	yes
3680	1387200	2025-09-20	England	League One	Bolton	Wigan	h-win	4	1	13	7	9	1	3	16	1	0	0	1	0	0	52.00	48.00	9	10	\N	\N	\N	4	17	2025-11-20 18:17:01.764579	\N	\N	3	0	h-win	yes
3681	1387199	2025-09-20	England	League One	Blackpool	Barnsley	h-win	1	0	10	3	10	1	7	3	4	1	2	1	0	0	37.00	63.00	12	9	\N	\N	\N	21	13	2025-11-20 18:17:01.9351	\N	\N	0	0	draw	yes
3682	1387203	2025-09-20	England	League One	Lincoln	Luton	h-win	3	1	15	6	13	2	2	7	1	2	1	5	0	0	43.00	57.00	12	14	\N	\N	\N	2	8	2025-11-20 18:17:02.481971	\N	\N	1	0	h-win	yes
4000	1419327	2025-08-02	England	FA Cup	Boston Town	Kimberley Miners Welfare	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.97803	\N	\N	0	0	draw	yes
4001	1419502	2025-08-02	England	FA Cup	Coton Green	Rugby Town	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.986161	\N	\N	0	0	draw	yes
4002	1419453	2025-08-02	England	FA Cup	Eversley & Cal	Horndean	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.994973	\N	\N	0	0	draw	yes
4003	1419339	2025-08-02	England	FA Cup	Faversham SF	Glebe	a-win	0	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.003064	\N	\N	0	0	draw	yes
4004	1419457	2025-08-02	England	FA Cup	Horbury Town	Wombwell Town	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.011553	\N	\N	0	0	draw	yes
4005	1419371	2025-08-02	England	FA Cup	Newquay	Shepton Mallet	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.02145	\N	\N	0	0	draw	yes
4006	1419459	2025-08-02	England	FA Cup	Seaford Town	Sutton Athletic	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.029133	\N	\N	0	0	draw	yes
4007	1419481	2025-08-02	England	FA Cup	Sidmouth Town	Ivybridge Town	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.03886	\N	\N	0	0	draw	yes
4008	1419505	2025-08-02	England	FA Cup	Jersey Bulls	Erith & Belvedere	h-win	5	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.046618	\N	\N	0	0	draw	yes
4009	1419506	2025-08-03	England	FA Cup	Stansfeld	Harrow Borough	a-win	0	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.056401	\N	\N	0	0	draw	yes
4010	1419508	2025-08-03	England	FA Cup	Hallam	Lower Breck	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.064013	\N	\N	0	0	draw	yes
4011	1419507	2025-08-03	England	FA Cup	Little Common	Southall	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.073306	\N	\N	0	0	draw	yes
4012	1419509	2025-08-03	England	FA Cup	Hilltop	Deal Town	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.080845	\N	\N	0	0	draw	yes
4013	1419510	2025-08-03	England	FA Cup	Northwich Victoria	Campion	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.090173	\N	\N	0	0	draw	yes
4014	1423480	2025-08-04	England	FA Cup	Phoenix Sports	Leatherhead	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.097615	\N	\N	0	0	draw	yes
4015	1423479	2025-08-04	England	FA Cup	Sutton Common Rovers	Guildford City	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.108334	\N	\N	0	0	draw	yes
4016	1423761	2025-08-04	England	FA Cup	Studley	Sporting Club Inkberrow	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.115514	\N	\N	0	0	draw	yes
4017	1423491	2025-08-05	England	FA Cup	Harefield United	Peacehaven & Telscombe	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.12558	\N	\N	0	0	draw	yes
4018	1423500	2025-08-05	England	FA Cup	Shepton Mallet	Newquay	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.133151	\N	\N	0	0	draw	yes
4019	1423504	2025-08-05	England	FA Cup	Brixham	Street	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.143097	\N	\N	0	0	draw	yes
4020	1423762	2025-08-05	England	FA Cup	Laverstock & Ford	Cowes Sports	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.14996	\N	\N	0	0	draw	yes
4021	1423489	2025-08-05	England	FA Cup	Ashford Town (Middlesex)	Eastbourne Town	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.161955	\N	\N	0	0	draw	yes
4022	1423503	2025-08-05	England	FA Cup	Bristol Manor Farm	Mangotsfield United	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.172206	\N	\N	0	0	draw	yes
4023	1423497	2025-08-05	England	FA Cup	Faversham Town	Balham	h-win	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.180537	\N	\N	0	0	draw	yes
4024	1423508	2025-08-05	England	FA Cup	Harlow Town	Saffron Walden Town	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.190913	\N	\N	0	0	draw	yes
1535	1348777	2025-07-04	Estonia	Meistriliiga	Paide	FC Levadia Tallinn	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	2	2025-11-20 05:14:00.155969	\N	\N	0	2	a-win	yes
1536	1348778	2025-07-05	Estonia	Meistriliiga	Trans Narva	Kuressaare	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	9	2025-11-20 05:14:00.351369	\N	\N	2	2	draw	yes
1537	1348780	2025-07-06	Estonia	Meistriliiga	Tallinna Kalev	Tammeka	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	10	8	2025-11-20 05:14:00.521871	\N	\N	1	2	a-win	yes
1538	1348781	2025-07-06	Estonia	Meistriliiga	Flora Tallinn	Kalju Nomme	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	3	2025-11-20 05:14:00.706531	\N	\N	0	0	draw	yes
1539	1348785	2025-07-11	Estonia	Meistriliiga	Kuressaare	Tammeka	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	8	2025-11-20 05:14:00.903744	\N	\N	0	1	a-win	yes
1540	1348784	2025-07-12	Estonia	Meistriliiga	Vaprus	Trans Narva	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	5	2025-11-20 05:14:01.087942	\N	\N	0	0	draw	yes
1541	1348786	2025-07-13	Estonia	Meistriliiga	Tallinna Kalev	Laagri	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	10	7	2025-11-20 05:14:01.27775	\N	\N	2	0	h-win	yes
1542	1348862	2025-07-19	Estonia	Meistriliiga	FC Levadia Tallinn	Laagri	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	7	2025-11-20 05:14:01.461851	\N	\N	2	0	h-win	yes
1543	1348788	2025-07-20	Estonia	Meistriliiga	Kalju Nomme	Tallinna Kalev	h-win	6	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	10	2025-11-20 05:14:01.642772	\N	\N	3	0	h-win	yes
1544	1348789	2025-07-20	Estonia	Meistriliiga	Tammeka	Flora Tallinn	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8	1	2025-11-20 05:14:01.835915	\N	\N	1	2	a-win	yes
1545	1348790	2025-07-20	Estonia	Meistriliiga	Kuressaare	Vaprus	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	6	2025-11-20 05:14:02.021145	\N	\N	0	1	a-win	yes
1546	1348791	2025-07-20	Estonia	Meistriliiga	Paide	Trans Narva	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	5	2025-11-20 05:14:02.214941	\N	\N	1	0	h-win	yes
1547	1348833	2025-07-25	Estonia	Meistriliiga	Vaprus	Laagri	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	7	2025-11-20 05:14:02.398867	\N	\N	1	1	draw	yes
4025	1423493	2025-08-05	England	FA Cup	Soham Town Rangers	March Town United	a-win	1	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.199611	\N	\N	0	0	draw	yes
4026	1423494	2025-08-05	England	FA Cup	Welwyn Garden City	Biggleswade	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.211638	\N	\N	0	0	draw	yes
4027	1423495	2025-08-05	England	FA Cup	Kings Langley	Cockfosters	a-win	2	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.218787	\N	\N	0	0	draw	yes
4028	1423507	2025-08-05	England	FA Cup	Concord Rangers	Harpenden Town	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.226892	\N	\N	0	0	draw	yes
4029	1423499	2025-08-05	England	FA Cup	AFC Portchester	Melksham Town	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.233164	\N	\N	0	0	draw	yes
4030	1423509	2025-08-05	England	FA Cup	Abingdon United	Aylesbury Vale Dynamos	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.2473	\N	\N	0	0	draw	yes
4031	1423501	2025-08-05	England	FA Cup	Albion Sports	Sheffield	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.258192	\N	\N	0	0	draw	yes
4032	1423498	2025-08-05	England	FA Cup	Barton Town Old Boys	Loughborough University	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.26671	\N	\N	0	0	draw	yes
4033	1423490	2025-08-05	England	FA Cup	Brantham Athletic	Walthamstow	h-win	4	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.278521	\N	\N	0	0	draw	yes
4034	1423765	2025-08-05	England	FA Cup	Bridlington Town	Knaresborough Town	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.288296	\N	\N	0	0	draw	yes
4035	1423484	2025-08-05	England	FA Cup	Consett	Guisborough Town	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.295324	\N	\N	0	0	draw	yes
4036	1423488	2025-08-05	England	FA Cup	Corinthian	Horley Town	draw	3	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.304608	\N	\N	0	0	draw	yes
4037	1423496	2025-08-05	England	FA Cup	Crowborough Athletic	Punjab United	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.312054	\N	\N	0	0	draw	yes
4038	1423763	2025-08-05	England	FA Cup	Deal Town	Hilltop	h-win	4	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.322148	\N	\N	0	0	draw	yes
3683	1387202	2025-09-20	England	League One	Huddersfield	Burton Albion	draw	0	0	13	4	9	3	15	5	3	0	0	1	0	0	70.00	30.00	11	18	\N	\N	\N	10	12	2025-11-20 18:17:02.649252	\N	\N	0	0	draw	yes
3684	1387210	2025-09-20	England	League One	Cardiff	Bradford	a-win	1	3	15	5	16	6	4	7	1	2	4	4	0	0	61.00	39.00	15	13	\N	\N	\N	5	3	2025-11-20 18:17:02.833254	\N	\N	0	2	a-win	yes
3685	1387206	2025-09-20	England	League One	Reading	Leyton Orient	h-win	2	1	12	6	17	6	2	6	0	2	5	3	0	0	30.00	70.00	13	11	\N	\N	\N	18	16	2025-11-20 18:17:03.011348	\N	\N	1	0	h-win	yes
3686	1387207	2025-09-20	England	League One	Rotherham	Stockport County	a-win	0	1	7	1	11	5	1	4	3	2	3	2	0	0	46.00	54.00	12	17	\N	\N	\N	11	1	2025-11-20 18:17:03.506866	\N	\N	0	0	draw	yes
3687	1387205	2025-09-20	England	League One	Port Vale	Mansfield Town	h-win	2	1	19	8	2	1	7	0	3	1	2	1	0	1	75.00	25.00	14	7	\N	\N	\N	22	9	2025-11-20 18:17:03.7042	\N	\N	0	0	draw	yes
3688	1387201	2025-09-20	England	League One	Doncaster	AFC Wimbledon	a-win	1	2	12	1	9	4	2	6	2	2	1	2	0	0	57.00	43.00	7	12	\N	\N	\N	19	7	2025-11-20 18:17:03.933941	\N	\N	0	0	draw	yes
3689	1387204	2025-09-20	England	League One	Plymouth	Peterborough	a-win	0	1	19	4	8	4	7	1	0	4	3	2	0	0	66.00	34.00	8	11	\N	\N	\N	24	23	2025-11-20 18:17:04.15138	\N	\N	0	1	a-win	yes
3690	1387209	2025-09-20	England	League One	Wycombe	Northampton	h-win	2	0	20	6	7	1	6	3	6	1	1	1	0	0	54.00	46.00	9	12	\N	\N	\N	14	15	2025-11-20 18:17:04.406293	\N	\N	1	0	h-win	yes
3691	1387208	2025-09-20	England	League One	Stevenage	Exeter City	h-win	2	1	17	5	12	6	6	3	3	1	1	1	0	0	54.00	46.00	11	13	\N	\N	\N	6	20	2025-11-20 18:17:04.602548	\N	\N	1	1	draw	yes
3692	1387211	2025-09-27	England	League One	AFC Wimbledon	Wycombe	h-win	2	1	6	2	12	1	0	7	4	3	0	0	0	0	32.00	68.00	13	11	\N	\N	\N	7	14	2025-11-20 18:17:04.800522	\N	\N	2	0	h-win	yes
3693	1387216	2025-09-27	England	League One	Leyton Orient	Stevenage	a-win	2	3	5	2	11	8	6	7	0	5	0	1	0	0	62.00	38.00	9	10	\N	\N	\N	16	6	2025-11-20 18:17:05.008412	\N	\N	1	1	draw	yes
3694	1387222	2025-09-27	England	League One	Wigan	Cardiff	a-win	0	2	6	1	15	5	7	5	1	2	1	1	1	0	27.00	73.00	9	6	\N	\N	\N	17	5	2025-11-20 18:17:05.214618	\N	\N	0	1	a-win	yes
3695	1387212	2025-09-27	England	League One	Barnsley	Port Vale	a-win	0	2	13	0	14	8	4	3	3	3	1	2	0	0	69.00	31.00	6	11	\N	\N	\N	13	22	2025-11-20 18:17:05.412421	\N	\N	0	0	draw	yes
3696	1387214	2025-09-27	England	League One	Burton Albion	Plymouth	a-win	0	4	12	3	15	9	6	5	4	1	0	1	0	0	63.00	37.00	10	8	\N	\N	\N	12	24	2025-11-20 18:17:05.628609	\N	\N	0	2	a-win	yes
3697	1387219	2025-09-27	England	League One	Northampton	Bolton	h-win	2	0	10	3	19	6	4	10	0	1	2	1	0	0	37.00	63.00	11	8	\N	\N	\N	15	4	2025-11-20 18:17:05.819284	\N	\N	0	0	draw	yes
1570	1324001	2025-07-02	Japan	J1 League	Vissel Kobe	Sanfrecce Hiroshima	h-win	1	0	10	6	14	4	3	3	1	4	0	1	0	0	52.00	48.00	7	10	\N	\N	\N	3	5	2025-11-20 05:14:18.209991	1.11	1.63	0	0	draw	yes
1571	1324173	2025-07-05	Japan	J1 League	Machida Zelvia	Shimizu S-pulse	h-win	3	0	16	6	12	2	2	1	3	2	1	0	0	0	36.00	64.00	14	6	\N	\N	\N	7	13	2025-11-20 05:14:18.401347	3.14	0.93	1	0	h-win	yes
1572	1324180	2025-07-05	Japan	J1 League	Fagiano Okayama	Sanfrecce Hiroshima	a-win	0	1	7	3	16	4	5	13	1	1	2	0	0	0	35.00	65.00	12	7	\N	\N	\N	15	5	2025-11-20 05:14:18.58544	0.63	1.53	0	0	draw	yes
1573	1324172	2025-07-05	Japan	J1 League	Kashiwa Reysol	FC Tokyo	h-win	1	0	14	2	14	5	4	7	2	1	2	1	0	0	59.00	41.00	8	6	\N	\N	\N	2	11	2025-11-20 05:14:18.783195	0.97	1.55	0	0	draw	yes
1574	1324176	2025-07-05	Japan	J1 League	Nagoya Grampus	Tokyo Verdy	draw	0	0	7	1	8	4	4	4	1	1	0	2	0	0	52.00	48.00	7	16	\N	\N	\N	17	14	2025-11-20 05:14:18.966204	0.25	1.23	0	0	draw	yes
1575	1324179	2025-07-05	Japan	J1 League	Vissel Kobe	Shonan Bellmare	h-win	4	0	15	8	7	2	6	3	1	1	0	1	0	0	47.00	53.00	12	13	\N	\N	\N	3	19	2025-11-20 05:14:19.158834	1.21	0.70	1	0	h-win	yes
1576	1324178	2025-07-05	Japan	J1 League	Cerezo Osaka	Gamba Osaka	a-win	0	1	19	6	14	4	5	7	2	2	0	3	0	0	62.00	38.00	8	14	\N	\N	\N	10	8	2025-11-20 05:14:19.311388	2.53	2.12	0	0	draw	yes
1577	1324174	2025-07-05	Japan	J1 League	Kawasaki Frontale	Kashima	h-win	2	1	16	6	10	3	7	2	4	3	2	2	0	0	61.00	39.00	8	9	\N	\N	\N	6	1	2025-11-20 05:14:19.469014	1.98	1.01	1	1	draw	yes
1578	1324177	2025-07-05	Japan	J1 League	Kyoto Sanga	Albirex Niigata	h-win	2	1	14	6	12	3	6	7	0	1	0	3	0	0	42.00	58.00	6	8	\N	\N	\N	4	20	2025-11-20 05:14:19.620594	1.68	1.46	2	1	h-win	yes
1579	1324175	2025-07-05	Japan	J1 League	Yokohama FC	Yokohama F. Marinos	a-win	0	1	10	1	6	1	7	2	3	0	3	2	0	0	51.00	49.00	12	11	\N	\N	\N	18	16	2025-11-20 05:14:19.783305	0.47	1.20	0	0	draw	yes
1580	1324186	2025-07-19	Japan	J1 League	Shonan Bellmare	Cerezo Osaka	draw	3	3	14	6	22	6	4	7	4	1	0	1	0	0	41.00	59.00	13	11	\N	\N	\N	19	10	2025-11-20 05:14:19.932591	2.52	3.16	2	1	h-win	yes
1581	1324183	2025-07-19	Japan	J1 League	FC Tokyo	Urawa	h-win	3	2	19	5	13	4	6	4	2	1	2	1	0	0	49.00	51.00	13	16	\N	\N	\N	11	9	2025-11-20 05:14:20.095207	2.73	1.61	1	2	a-win	yes
1582	1324182	2025-07-20	Japan	J1 League	Kashima	Kashiwa Reysol	h-win	3	2	6	3	17	4	0	2	2	2	1	3	0	0	32.00	68.00	9	12	\N	\N	\N	1	2	2025-11-20 05:14:20.247411	0.92	2.90	2	1	h-win	yes
1583	1324184	2025-07-20	Japan	J1 League	Tokyo Verdy	Machida Zelvia	a-win	0	1	15	4	6	2	4	1	1	1	0	0	0	0	70.00	30.00	7	13	\N	\N	\N	14	7	2025-11-20 05:14:20.409177	1.21	0.45	0	0	draw	yes
1584	1324188	2025-07-20	Japan	J1 League	Shimizu S-pulse	Yokohama FC	h-win	2	0	14	2	6	5	8	2	0	2	1	1	0	1	65.00	35.00	8	10	\N	\N	\N	13	18	2025-11-20 05:14:20.562323	1.31	0.55	0	0	draw	yes
1585	1324189	2025-07-20	Japan	J1 League	Gamba Osaka	Kawasaki Frontale	h-win	2	1	18	4	14	8	9	8	0	1	2	0	0	0	57.00	43.00	10	8	\N	\N	\N	8	6	2025-11-20 05:14:20.728451	1.37	0.90	1	1	draw	yes
1586	1324185	2025-07-20	Japan	J1 League	Yokohama F. Marinos	Nagoya Grampus	h-win	3	0	16	5	16	4	7	6	0	2	3	1	0	0	44.00	56.00	14	5	\N	\N	\N	16	17	2025-11-20 05:14:20.890494	1.55	0.97	2	0	h-win	yes
1587	1324190	2025-07-20	Japan	J1 League	Fagiano Okayama	Vissel Kobe	a-win	1	2	5	1	18	9	6	4	1	2	1	0	0	0	49.00	51.00	14	4	\N	\N	\N	15	3	2025-11-20 05:14:21.049115	0.73	2.72	0	1	a-win	yes
1588	1324187	2025-07-20	Japan	J1 League	Albirex Niigata	Sanfrecce Hiroshima	a-win	0	2	12	1	19	8	5	2	1	3	2	0	0	0	55.00	45.00	10	13	\N	\N	\N	20	5	2025-11-20 05:14:21.224775	0.60	3.66	0	1	a-win	yes
1589	1324191	2025-07-21	Japan	J1 League	Avispa Fukuoka	Kyoto Sanga	draw	2	2	17	7	8	3	7	3	3	2	0	2	0	0	58.00	42.00	8	13	\N	\N	\N	12	4	2025-11-20 05:14:21.399702	2.32	1.30	0	0	draw	yes
1590	1324161	2025-07-23	Japan	J1 League	Urawa	Shonan Bellmare	h-win	4	1	11	5	12	3	5	7	1	0	0	0	0	0	50.00	50.00	11	11	\N	\N	\N	9	19	2025-11-20 05:14:21.570697	\N	\N	2	0	h-win	yes
1682	1340836	2025-07-23	South-Korea	K League 1	Ulsan Hyundai FC	Daejeon Citizen	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	2025-11-20 06:14:24.44491	\N	\N	1	1	draw	yes
1591	1324181	2025-07-27	Japan	J1 League	Urawa	Avispa Fukuoka	draw	0	0	12	4	8	2	4	4	0	0	1	0	0	0	52.00	48.00	6	8	\N	\N	\N	9	12	2025-11-20 05:14:21.747374	0.64	0.71	0	0	draw	yes
1592	1324722	2025-07-05	Japan	J2 League	Consadole Sapporo	Renofa Yamaguchi	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	18	2025-11-20 05:14:23.115786	\N	\N	1	0	h-win	yes
1593	1324730	2025-07-05	Japan	J2 League	V-varen Nagasaki	Oita Trinita	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	16	2025-11-20 05:14:23.300779	\N	\N	0	0	draw	yes
1594	1324724	2025-07-05	Japan	J2 League	Blaublitz Akita	Mito Hollyhock	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	14	1	2025-11-20 05:14:23.473297	\N	\N	0	1	a-win	yes
1595	1324723	2025-07-05	Japan	J2 League	Vegalta Sendai	Kataller Toyama	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	19	2025-11-20 05:14:23.635554	\N	\N	0	1	a-win	yes
1596	1324727	2025-07-05	Japan	J2 League	Tokushima Vortis	Fujieda MYFC	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	15	2025-11-20 05:14:23.825645	\N	\N	0	1	a-win	yes
1597	1324726	2025-07-05	Japan	J2 League	JEF United Chiba	Sagan Tosu	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	8	2025-11-20 05:14:24.006506	\N	\N	0	1	a-win	yes
1598	1324725	2025-07-05	Japan	J2 League	Omiya Ardija	Iwaki	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	9	2025-11-20 05:14:24.19637	\N	\N	1	0	h-win	yes
1599	1324729	2025-07-05	Japan	J2 League	Imabari	Ventforet Kofu	a-win	2	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	10	13	2025-11-20 05:14:24.37756	\N	\N	2	0	h-win	yes
1600	1324731	2025-07-06	Japan	J2 League	Roasso Kumamoto	Jubilo Iwata	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	17	7	2025-11-20 05:14:24.558774	\N	\N	0	0	draw	yes
1601	1324728	2025-07-06	Japan	J2 League	Ehime FC	Montedio Yamagata	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	20	11	2025-11-20 05:14:24.741961	\N	\N	0	1	a-win	yes
1602	1324735	2025-07-12	Japan	J2 League	Mito Hollyhock	Kataller Toyama	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	19	2025-11-20 05:14:24.93474	\N	\N	0	0	draw	yes
1603	1324732	2025-07-12	Japan	J2 League	Blaublitz Akita	Roasso Kumamoto	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	14	17	2025-11-20 05:14:25.11329	\N	\N	3	1	h-win	yes
1604	1324734	2025-07-12	Japan	J2 League	Iwaki	V-varen Nagasaki	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	2	2025-11-20 05:14:25.29444	\N	\N	0	0	draw	yes
1605	1324740	2025-07-12	Japan	J2 League	Imabari	Ehime FC	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	10	20	2025-11-20 05:14:25.486758	\N	\N	0	0	draw	yes
1606	1324736	2025-07-12	Japan	J2 League	Ventforet Kofu	Omiya Ardija	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	13	3	2025-11-20 05:14:25.51315	\N	\N	0	0	draw	yes
1607	1324741	2025-07-12	Japan	J2 League	Sagan Tosu	Oita Trinita	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8	16	2025-11-20 05:14:25.538837	\N	\N	1	1	draw	yes
1608	1324739	2025-07-12	Japan	J2 League	Renofa Yamaguchi	Tokushima Vortis	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	18	5	2025-11-20 05:14:25.55871	\N	\N	0	0	draw	yes
1609	1324733	2025-07-12	Japan	J2 League	Montedio Yamagata	JEF United Chiba	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	11	4	2025-11-20 05:14:25.570202	\N	\N	0	0	draw	yes
1610	1324738	2025-07-12	Japan	J2 League	Fujieda MYFC	Vegalta Sendai	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	15	6	2025-11-20 05:14:25.586931	\N	\N	1	0	h-win	yes
1611	1324737	2025-07-12	Japan	J2 League	Jubilo Iwata	Consadole Sapporo	h-win	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7	12	2025-11-20 05:14:25.602823	\N	\N	3	1	h-win	yes
1612	1395008	2025-07-13	Colombia	Primera B	Tigres FC	Real Santander	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8	11	2025-11-20 06:14:09.813193	\N	\N	2	0	h-win	yes
1613	1395009	2025-07-13	Colombia	Primera B	Cucuta	Patriotas	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	2	2025-11-20 06:14:09.99785	\N	\N	2	0	h-win	yes
1614	1395010	2025-07-14	Colombia	Primera B	Barranquilla	Depor FC	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16	15	2025-11-20 06:14:10.184367	\N	\N	1	0	h-win	yes
1615	1395011	2025-07-14	Colombia	Primera B	Popayan	Leones FC	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	10	14	2025-11-20 06:14:10.365129	\N	\N	1	0	h-win	yes
1616	1395012	2025-07-15	Colombia	Primera B	Huila	Quindio	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	9	2025-11-20 06:14:10.537332	\N	\N	2	0	h-win	yes
1617	1395013	2025-07-15	Colombia	Primera B	Real Cartagena	Internacional Palmira	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7	6	2025-11-20 06:14:10.721006	\N	\N	0	0	draw	yes
1618	1395014	2025-07-16	Colombia	Primera B	Orsomarso	Bogota FC	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	13	2025-11-20 06:14:10.909032	\N	\N	0	0	draw	yes
1619	1395015	2025-07-16	Colombia	Primera B	Real Soacha	Jaguares	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	1	2025-11-20 06:14:11.099074	\N	\N	0	1	a-win	yes
1620	1400302	2025-07-18	Colombia	Primera B	Depor FC	Tigres FC	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	15	8	2025-11-20 06:14:11.287926	\N	\N	1	0	h-win	yes
1621	1400304	2025-07-19	Colombia	Primera B	Quindio	Popayan	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	10	2025-11-20 06:14:11.472294	\N	\N	2	2	draw	yes
1622	1400303	2025-07-19	Colombia	Primera B	Real Santander	Barranquilla	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	11	16	2025-11-20 06:14:11.657082	\N	\N	1	0	h-win	yes
1623	1400305	2025-07-20	Colombia	Primera B	Leones FC	Orsomarso	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	14	12	2025-11-20 06:14:11.849918	\N	\N	0	1	a-win	yes
1624	1400306	2025-07-21	Colombia	Primera B	Jaguares	Huila	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	4	2025-11-20 06:14:12.026917	\N	\N	1	0	h-win	yes
1625	1400307	2025-07-21	Colombia	Primera B	Bogota FC	Real Cartagena	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	13	7	2025-11-20 06:14:12.215102	\N	\N	0	3	a-win	yes
1626	1400308	2025-07-22	Colombia	Primera B	Patriotas	Real Soacha	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	5	2025-11-20 06:14:12.40427	\N	\N	1	0	h-win	yes
1627	1400309	2025-07-22	Colombia	Primera B	Internacional Palmira	Cucuta	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	3	2025-11-20 06:14:12.576843	\N	\N	0	0	draw	yes
1628	1400310	2025-07-25	Colombia	Primera B	Popayan	Internacional Palmira	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	10	6	2025-11-20 06:14:12.748343	\N	\N	1	0	h-win	yes
1629	1400311	2025-07-26	Colombia	Primera B	Huila	Tigres FC	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	8	2025-11-20 06:14:12.931791	\N	\N	0	0	draw	yes
1630	1400312	2025-07-26	Colombia	Primera B	Real Soacha	Real Santander	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	11	2025-11-20 06:14:13.186846	\N	\N	1	0	h-win	yes
1631	1400314	2025-07-27	Colombia	Primera B	Barranquilla	Patriotas	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16	2	2025-11-20 06:14:13.363648	\N	\N	1	1	draw	yes
1632	1400315	2025-07-27	Colombia	Primera B	Orsomarso	Jaguares	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	1	2025-11-20 06:14:13.539238	\N	\N	0	0	draw	yes
1633	1400316	2025-07-27	Colombia	Primera B	Bogota FC	Depor FC	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	13	15	2025-11-20 06:14:13.729828	\N	\N	2	0	h-win	yes
1634	1392345	2025-07-12	Colombia	Primera A	Llaneros	America de Cali	draw	0	0	5	0	14	3	6	7	2	1	3	1	0	0	41.00	59.00	12	19	\N	\N	\N	13	8	2025-11-20 06:14:15.078113	0.06	0.53	0	0	draw	yes
1635	1392346	2025-07-12	Colombia	Primera A	Once Caldas	Atletico Nacional	a-win	1	3	11	2	17	7	2	7	3	1	5	2	0	0	39.00	61.00	10	9	\N	\N	\N	11	3	2025-11-20 06:14:15.264235	1.20	1.38	0	1	a-win	yes
1636	1392347	2025-07-12	Colombia	Primera A	Deportivo Pasto	Deportes Tolima	h-win	3	2	8	5	15	4	0	3	0	3	5	1	0	0	23.00	77.00	10	9	\N	\N	\N	17	2	2025-11-20 06:14:15.449113	0.92	1.52	2	0	h-win	yes
1637	1392348	2025-07-12	Colombia	Primera A	Envigado	Fortaleza FC	a-win	0	1	12	4	15	3	5	1	3	1	3	2	0	0	46.00	54.00	16	18	\N	\N	\N	16	6	2025-11-20 06:14:15.615168	0.81	1.77	0	0	draw	yes
1638	1392349	2025-07-13	Colombia	Primera A	Bucaramanga	Chico	draw	1	1	15	5	5	1	6	4	1	3	2	2	0	0	68.00	32.00	18	16	\N	\N	\N	4	19	2025-11-20 06:14:15.791234	2.26	0.27	1	1	draw	yes
1639	1392350	2025-07-13	Colombia	Primera A	Deportivo Cali	Junior	a-win	0	2	7	0	9	4	6	2	0	2	1	3	1	0	26.00	74.00	12	17	\N	\N	\N	14	5	2025-11-20 06:14:15.973237	0.68	1.96	0	1	a-win	yes
1640	1392351	2025-07-13	Colombia	Primera A	Independiente Medellin	Alianza Petrolera	draw	1	1	21	4	9	6	15	3	2	3	1	3	0	0	67.00	33.00	7	8	\N	\N	\N	1	9	2025-11-20 06:14:16.149688	0.98	1.03	0	1	a-win	yes
1641	1392352	2025-07-14	Colombia	Primera A	Deportivo Pereira	Santa Fe	draw	2	2	27	9	8	4	7	3	2	0	3	2	0	1	69.00	31.00	13	13	\N	\N	\N	18	7	2025-11-20 06:14:16.304758	2.52	1.33	0	2	a-win	yes
1642	1392353	2025-07-14	Colombia	Primera A	La Equidad	Rionegro Aguilas	draw	0	0	9	5	13	4	2	7	0	5	2	2	1	1	46.00	54.00	10	10	\N	\N	\N	20	10	2025-11-20 06:14:16.471612	0.59	0.57	0	0	draw	yes
1643	1392355	2025-07-19	Colombia	Primera A	Union Magdalena	Llaneros	draw	0	0	10	2	9	3	3	4	4	4	4	7	0	1	57.00	43.00	17	10	\N	\N	\N	15	13	2025-11-20 06:14:16.645533	0.59	1.47	0	0	draw	yes
1644	1392356	2025-07-19	Colombia	Primera A	Deportes Tolima	Santa Fe	a-win	0	1	17	5	6	2	7	0	1	5	2	4	0	0	70.00	30.00	9	11	\N	\N	\N	2	7	2025-11-20 06:14:16.797766	0.58	0.57	0	0	draw	yes
1645	1392357	2025-07-19	Colombia	Primera A	Rionegro Aguilas	Junior	a-win	2	3	12	5	15	6	4	8	3	1	2	0	1	1	34.00	66.00	14	11	\N	\N	\N	10	5	2025-11-20 06:14:16.950863	0.94	1.95	1	0	h-win	yes
1646	1392358	2025-07-19	Colombia	Primera A	Alianza Petrolera	Deportivo Pereira	h-win	1	0	10	4	14	4	5	7	8	2	2	3	0	0	47.00	53.00	10	10	\N	\N	\N	9	18	2025-11-20 06:14:17.135836	0.43	1.11	1	0	h-win	yes
1647	1392359	2025-07-20	Colombia	Primera A	Atletico Nacional	La Equidad	h-win	3	1	10	4	3	2	3	3	0	3	2	0	0	0	63.00	37.00	17	8	\N	\N	\N	3	20	2025-11-20 06:14:17.30624	1.30	0.22	2	0	h-win	yes
1648	1392360	2025-07-20	Colombia	Primera A	Chico	Independiente Medellin	h-win	2	0	11	4	13	3	0	8	3	1	4	5	1	0	41.00	59.00	12	15	\N	\N	\N	19	1	2025-11-20 06:14:17.481814	\N	\N	0	0	draw	yes
1649	1392361	2025-07-20	Colombia	Primera A	Envigado	Deportivo Cali	draw	0	0	9	2	7	0	2	9	1	1	3	3	0	0	45.00	55.00	15	12	\N	\N	\N	16	14	2025-11-20 06:14:17.666188	\N	\N	0	0	draw	yes
1650	1392362	2025-07-21	Colombia	Primera A	Fortaleza FC	Once Caldas	h-win	2	1	8	3	14	4	1	6	3	0	2	5	1	0	32.00	68.00	7	9	\N	\N	\N	6	11	2025-11-20 06:14:17.855402	\N	\N	2	1	h-win	yes
1651	1392366	2025-07-22	Colombia	Primera A	Alianza Petrolera	Deportes Tolima	a-win	0	1	15	2	11	7	7	1	7	1	2	4	0	0	60.00	40.00	8	14	\N	\N	\N	9	2	2025-11-20 06:14:18.035617	\N	\N	0	1	a-win	yes
1652	1392367	2025-07-23	Colombia	Primera A	Santa Fe	Rionegro Aguilas	draw	0	0	15	7	11	2	6	5	0	2	3	4	0	0	57.00	43.00	12	13	\N	\N	\N	7	10	2025-11-20 06:14:18.203132	\N	\N	0	0	draw	yes
1653	1392368	2025-07-23	Colombia	Primera A	Deportivo Pereira	Atletico Nacional	h-win	2	1	14	5	8	3	5	4	7	1	5	3	2	2	41.00	59.00	17	12	\N	\N	\N	18	3	2025-11-20 06:14:18.367973	\N	\N	2	1	h-win	yes
1654	1392369	2025-07-23	Colombia	Primera A	Llaneros	Chico	h-win	2	1	13	4	11	3	2	4	1	3	3	3	0	0	47.00	53.00	8	11	\N	\N	\N	13	19	2025-11-20 06:14:18.554761	\N	\N	1	0	h-win	yes
1655	1392370	2025-07-24	Colombia	Primera A	Junior	Union Magdalena	h-win	4	1	10	5	16	10	5	6	0	1	0	2	1	0	53.00	47.00	6	9	\N	\N	\N	5	15	2025-11-20 06:14:18.739819	\N	\N	2	1	h-win	yes
1656	1392371	2025-07-24	Colombia	Primera A	La Equidad	Millonarios	h-win	1	0	5	3	22	6	0	6	2	2	4	3	1	1	26.00	74.00	10	13	\N	\N	\N	20	12	2025-11-20 06:14:18.926556	\N	\N	0	0	draw	yes
1657	1392372	2025-07-25	Colombia	Primera A	Independiente Medellin	Envigado	a-win	3	4	25	7	10	5	12	3	0	0	4	5	3	1	76.00	24.00	11	17	\N	\N	\N	1	16	2025-11-20 06:14:19.112356	\N	\N	1	2	a-win	yes
1658	1392373	2025-07-25	Colombia	Primera A	Deportivo Cali	Fortaleza FC	draw	1	1	11	2	12	2	4	4	2	3	2	4	0	0	43.00	57.00	22	15	\N	\N	\N	14	6	2025-11-20 06:14:19.298467	\N	\N	1	0	h-win	yes
1659	1392374	2025-07-26	Colombia	Primera A	Deportes Tolima	Deportivo Pereira	h-win	1	0	17	5	5	0	9	0	1	3	3	2	1	2	60.00	40.00	4	10	\N	\N	\N	2	18	2025-11-20 06:14:19.460617	\N	\N	1	0	h-win	yes
1660	1392375	2025-07-26	Colombia	Primera A	Atletico Nacional	Santa Fe	draw	1	1	12	3	12	1	7	4	2	1	2	5	0	1	54.00	46.00	9	12	\N	\N	\N	3	7	2025-11-20 06:14:19.610419	\N	\N	1	0	h-win	yes
1661	1392376	2025-07-26	Colombia	Primera A	Chico	Deportivo Pasto	draw	2	2	16	6	6	3	10	0	0	1	3	5	0	1	73.00	27.00	15	19	\N	\N	\N	19	17	2025-11-20 06:14:19.766701	\N	\N	0	2	a-win	yes
1662	1392377	2025-07-27	Colombia	Primera A	Once Caldas	Junior	draw	2	2	21	4	17	6	4	7	5	4	3	2	0	0	51.00	49.00	11	12	\N	\N	\N	11	5	2025-11-20 06:14:19.928419	\N	\N	0	0	draw	yes
1663	1392378	2025-07-27	Colombia	Primera A	America de Cali	Rionegro Aguilas	h-win	2	1	8	4	16	4	3	4	2	2	4	3	1	0	56.00	44.00	10	16	\N	\N	\N	8	10	2025-11-20 06:14:20.096326	\N	\N	1	0	h-win	yes
1664	1392379	2025-07-27	Colombia	Primera A	Envigado	La Equidad	draw	1	1	15	3	12	4	6	2	2	1	0	1	0	0	64.00	36.00	13	7	\N	\N	\N	16	20	2025-11-20 06:14:20.249899	\N	\N	0	0	draw	yes
1665	1392380	2025-07-28	Colombia	Primera A	Union Magdalena	Independiente Medellin	a-win	0	2	17	4	9	4	4	2	0	1	4	2	0	1	70.00	30.00	14	12	\N	\N	\N	15	1	2025-11-20 06:14:20.408843	\N	\N	0	1	a-win	yes
1666	1392381	2025-07-28	Colombia	Primera A	Fortaleza FC	Alianza Petrolera	draw	2	2	9	4	7	3	7	3	2	2	1	3	0	0	49.00	51.00	7	16	\N	\N	\N	6	9	2025-11-20 06:14:20.568254	\N	\N	1	0	h-win	yes
1667	1392382	2025-07-29	Colombia	Primera A	Bucaramanga	Deportivo Cali	a-win	2	3	8	1	8	4	6	4	1	1	3	4	1	0	68.00	32.00	14	19	\N	\N	\N	4	14	2025-11-20 06:14:20.720417	\N	\N	0	2	a-win	yes
1668	1392383	2025-07-29	Colombia	Primera A	Millonarios	Llaneros	a-win	0	1	17	0	5	3	10	4	1	4	3	4	0	0	65.00	35.00	9	9	\N	\N	\N	12	13	2025-11-20 06:14:20.865058	\N	\N	0	0	draw	yes
1669	1410002	2025-07-21	Colombia	Primera A	Millonarios	Deportivo Pasto	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 06:14:21.03467	\N	\N	0	0	draw	no
1670	1340825	2025-07-12	South-Korea	K League 1	Ulsan Hyundai FC	Daegu FC	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 06:14:22.344015	\N	\N	0	1	a-win	yes
1671	1340828	2025-07-18	South-Korea	K League 1	Daegu FC	Gimcheon Sangmu FC	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	2025-11-20 06:14:22.49199	\N	\N	2	1	h-win	yes
1672	1340827	2025-07-18	South-Korea	K League 1	Suwon City FC	Gwangju FC	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 06:14:22.643312	\N	\N	0	0	draw	yes
1673	1340829	2025-07-19	South-Korea	K League 1	Gangwon FC	Daejeon Citizen	draw	2	2	16	8	12	7	6	8	4	0	1	0	0	0	52.00	48.00	6	5	\N	\N	\N	6	2	2025-11-20 06:14:22.795899	\N	\N	0	0	draw	yes
1674	1340831	2025-07-19	South-Korea	K League 1	Jeju United FC	FC Anyang	h-win	2	0	14	6	7	4	3	4	1	2	3	2	0	0	65.00	35.00	9	12	\N	\N	\N	\N	\N	2025-11-20 06:14:22.962929	\N	\N	0	0	draw	yes
1675	1340830	2025-07-19	South-Korea	K League 1	Pohang Steelers	Jeonbuk Motors	a-win	2	3	22	7	14	8	6	5	2	1	2	5	0	0	41.00	59.00	6	5	\N	\N	\N	4	1	2025-11-20 06:14:23.149926	\N	\N	2	0	h-win	yes
1676	1340832	2025-07-20	South-Korea	K League 1	FC Seoul	Ulsan Hyundai FC	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	\N	2025-11-20 06:14:23.329625	\N	\N	1	0	h-win	yes
1677	1340835	2025-07-22	South-Korea	K League 1	FC Anyang	Daegu FC	h-win	4	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 06:14:23.510965	\N	\N	2	0	h-win	yes
1678	1340834	2025-07-22	South-Korea	K League 1	Gwangju FC	Gimcheon Sangmu FC	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	2025-11-20 06:14:23.689319	\N	\N	1	0	h-win	yes
1679	1340833	2025-07-22	South-Korea	K League 1	Pohang Steelers	Suwon City FC	a-win	1	5	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	\N	2025-11-20 06:14:23.880053	\N	\N	1	2	a-win	yes
1680	1340837	2025-07-23	South-Korea	K League 1	Jeju United FC	FC Seoul	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	2025-11-20 06:14:24.063277	\N	\N	1	1	draw	yes
1681	1340838	2025-07-23	South-Korea	K League 1	Jeonbuk Motors	Gangwon FC	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	6	2025-11-20 06:14:24.251794	\N	\N	2	0	h-win	yes
1683	1340840	2025-07-26	South-Korea	K League 1	Suwon City FC	FC Anyang	h-win	2	1	21	9	19	5	6	3	0	0	1	2	0	0	38.00	62.00	7	11	\N	\N	\N	\N	\N	2025-11-20 06:14:24.609728	\N	\N	2	1	h-win	yes
1684	1340841	2025-07-26	South-Korea	K League 1	Gwangju FC	Jeonbuk Motors	a-win	1	2	15	3	7	3	6	1	3	0	2	3	0	0	59.00	41.00	5	16	\N	\N	\N	\N	1	2025-11-20 06:14:24.779864	\N	\N	0	1	a-win	yes
1685	1340839	2025-07-26	South-Korea	K League 1	Gimcheon Sangmu FC	Jeju United FC	h-win	3	1	21	9	9	1	5	3	2	2	1	2	0	0	52.00	48.00	13	8	\N	\N	\N	3	\N	2025-11-20 06:14:24.949818	\N	\N	0	0	draw	yes
1686	1340842	2025-07-27	South-Korea	K League 1	Gangwon FC	Ulsan Hyundai FC	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	\N	2025-11-20 06:14:25.140392	\N	\N	0	1	a-win	yes
1687	1340844	2025-07-27	South-Korea	K League 1	Daegu FC	Pohang Steelers	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	2025-11-20 06:14:25.317363	\N	\N	0	0	draw	yes
1688	1340843	2025-07-27	South-Korea	K League 1	Daejeon Citizen	FC Seoul	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	5	2025-11-20 06:14:25.482341	\N	\N	0	0	draw	yes
1689	1337681	2025-07-05	South-Korea	K League 2	Gyeongnam FC	Ansan Greeners	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	11	14	2025-11-20 06:14:26.835504	\N	\N	1	1	draw	yes
1690	1337678	2025-07-05	South-Korea	K League 2	Asan Mugunghwa	Suwon Bluewings	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	2	2025-11-20 06:14:27.004367	\N	\N	0	2	a-win	yes
1691	1337679	2025-07-05	South-Korea	K League 2	Jeonnam Dragons	Incheon United	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	1	2025-11-20 06:14:27.189271	\N	\N	1	1	draw	yes
1692	1337680	2025-07-05	South-Korea	K League 2	Cheongju	Seoul E-Land FC	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	13	4	2025-11-20 06:14:27.381394	\N	\N	0	1	a-win	yes
1693	1337682	2025-07-06	South-Korea	K League 2	Seongnam FC	Cheonan City	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	12	2025-11-20 06:14:27.556288	\N	\N	0	0	draw	yes
1694	1337684	2025-07-06	South-Korea	K League 2	Gimpo Citizen	Busan I Park	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8	7	2025-11-20 06:14:27.727793	\N	\N	1	0	h-win	yes
1695	1337683	2025-07-06	South-Korea	K League 2	Hwaseong	Bucheon FC 1995	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	10	3	2025-11-20 06:14:27.915477	\N	\N	0	0	draw	yes
1696	1337686	2025-07-12	South-Korea	K League 2	Busan I Park	Seongnam FC	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7	6	2025-11-20 06:14:28.115301	\N	\N	0	0	draw	yes
1697	1337685	2025-07-12	South-Korea	K League 2	Jeonnam Dragons	Gyeongnam FC	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	11	2025-11-20 06:14:28.290947	\N	\N	1	0	h-win	yes
1698	1337687	2025-07-12	South-Korea	K League 2	Suwon Bluewings	Cheongju	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	13	2025-11-20 06:14:28.48661	\N	\N	0	0	draw	yes
1699	1337688	2025-07-12	South-Korea	K League 2	Cheonan City	Hwaseong	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	10	2025-11-20 06:14:28.663731	\N	\N	0	1	a-win	yes
1700	1337690	2025-07-13	South-Korea	K League 2	Bucheon FC 1995	Gimpo Citizen	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	8	2025-11-20 06:14:28.843184	\N	\N	1	0	h-win	yes
1701	1337691	2025-07-13	South-Korea	K League 2	Ansan Greeners	Seoul E-Land FC	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	14	4	2025-11-20 06:14:29.024296	\N	\N	0	0	draw	yes
1702	1337689	2025-07-13	South-Korea	K League 2	Incheon United	Asan Mugunghwa	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	9	2025-11-20 06:14:29.201196	\N	\N	1	1	draw	yes
1703	1337694	2025-07-19	South-Korea	K League 2	Seoul E-Land FC	Seongnam FC	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	6	2025-11-20 06:14:29.37257	\N	\N	0	1	a-win	yes
1704	1337692	2025-07-19	South-Korea	K League 2	Jeonnam Dragons	Suwon Bluewings	a-win	3	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	2	2025-11-20 06:14:29.581026	\N	\N	0	2	a-win	yes
1705	1337693	2025-07-19	South-Korea	K League 2	Gimpo Citizen	Ansan Greeners	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8	14	2025-11-20 06:14:29.773126	\N	\N	1	1	draw	yes
1706	1337695	2025-07-19	South-Korea	K League 2	Hwaseong	Busan I Park	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	10	7	2025-11-20 06:14:29.945913	\N	\N	0	0	draw	yes
1707	1337696	2025-07-20	South-Korea	K League 2	Bucheon FC 1995	Asan Mugunghwa	h-win	5	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	9	2025-11-20 06:14:30.125211	\N	\N	2	1	h-win	yes
1708	1337698	2025-07-20	South-Korea	K League 2	Gyeongnam FC	Incheon United	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	11	1	2025-11-20 06:14:30.300223	\N	\N	0	0	draw	yes
1709	1337697	2025-07-20	South-Korea	K League 2	Cheongju	Cheonan City	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	13	12	2025-11-20 06:14:30.487373	\N	\N	1	1	draw	yes
1710	1337699	2025-07-26	South-Korea	K League 2	Busan I Park	Bucheon FC 1995	h-win	4	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7	3	2025-11-20 06:14:30.65697	\N	\N	1	0	h-win	yes
1711	1337702	2025-07-26	South-Korea	K League 2	Asan Mugunghwa	Hwaseong	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	10	2025-11-20 06:14:30.850899	\N	\N	0	0	draw	yes
1712	1337700	2025-07-26	South-Korea	K League 2	Cheonan City	Gyeongnam FC	h-win	4	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	11	2025-11-20 06:14:31.034508	\N	\N	2	0	h-win	yes
1713	1337701	2025-07-26	South-Korea	K League 2	Cheongju	Gimpo Citizen	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	13	8	2025-11-20 06:14:31.210151	\N	\N	0	0	draw	yes
1714	1337705	2025-07-27	South-Korea	K League 2	Seongnam FC	Jeonnam Dragons	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	5	2025-11-20 06:14:31.314197	\N	\N	0	0	draw	yes
1715	1337703	2025-07-27	South-Korea	K League 2	Incheon United	Ansan Greeners	h-win	4	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	14	2025-11-20 06:14:31.331161	\N	\N	2	0	h-win	yes
1716	1337704	2025-07-27	South-Korea	K League 2	Suwon Bluewings	Seoul E-Land FC	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	4	2025-11-20 06:14:31.347179	\N	\N	0	1	a-win	yes
1717	1392848	2025-07-25	Costa-Rica	Primera División	Guadalupe FC	CS Herediano	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	6	2025-11-20 07:14:15.044772	\N	\N	0	0	draw	yes
1718	1392847	2025-07-26	Costa-Rica	Primera División	Municipal Liberia	CS Cartagines	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	3	2025-11-20 07:14:15.244319	\N	\N	0	0	draw	yes
1719	1392849	2025-07-27	Costa-Rica	Primera División	Puntarenas FC	San Carlos	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7	10	2025-11-20 07:14:15.463154	\N	\N	1	0	h-win	yes
1720	1392850	2025-07-27	Costa-Rica	Primera División	Perez Zeledon	Deportivo Saprissa	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	2	2025-11-20 07:14:15.631287	\N	\N	0	0	draw	yes
1721	1392846	2025-07-28	Costa-Rica	Primera División	Sporting San Jose	LD Alajuelense	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8	1	2025-11-20 07:14:15.821847	\N	\N	0	1	a-win	yes
1722	1383669	2025-07-21	Lithuania	1 Lyga	Hegelmann II	Nevėžis	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	10	14	2025-11-20 07:14:17.194325	\N	\N	0	0	draw	yes
1723	1383670	2025-07-22	Lithuania	1 Lyga	Panevėžys II	Tauras	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16	3	2025-11-20 07:14:17.344229	\N	\N	0	1	a-win	yes
1724	1383671	2025-07-22	Lithuania	1 Lyga	Minija	Babrungas	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	4	2025-11-20 07:14:17.498535	\N	\N	0	0	draw	yes
1725	1383673	2025-07-22	Lithuania	1 Lyga	Kauno Žalgiris II	Atmosfera	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	13	6	2025-11-20 07:14:17.683366	\N	\N	0	2	a-win	yes
1726	1383672	2025-07-22	Lithuania	1 Lyga	FA Šiauliai II	Neptūną Klaipėda	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	15	2	2025-11-20 07:14:17.847544	\N	\N	1	0	h-win	yes
1727	1383674	2025-07-23	Lithuania	1 Lyga	BFA	Ekranas	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	12	2025-11-20 07:14:18.029046	\N	\N	1	0	h-win	yes
1728	1383675	2025-07-23	Lithuania	1 Lyga	Jonava	TransINVEST Vilnius	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8	1	2025-11-20 07:14:18.224004	\N	\N	0	2	a-win	yes
1729	1383676	2025-07-23	Lithuania	1 Lyga	Žalgiris II	Be1 NFA	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7	11	2025-11-20 07:14:18.433677	\N	\N	1	0	h-win	yes
1730	1383678	2025-07-25	Lithuania	1 Lyga	Nevėžis	Panevėžys II	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	14	16	2025-11-20 07:14:18.616714	\N	\N	0	1	a-win	yes
1731	1383677	2025-07-25	Lithuania	1 Lyga	Babrungas	Žalgiris II	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	7	2025-11-20 07:14:18.802373	\N	\N	2	1	h-win	yes
1732	1383679	2025-07-26	Lithuania	1 Lyga	Tauras	FA Šiauliai II	h-win	4	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	15	2025-11-20 07:14:19.003193	\N	\N	3	0	h-win	yes
1733	1383680	2025-07-26	Lithuania	1 Lyga	BFA	Jonava	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	8	2025-11-20 07:14:19.190353	\N	\N	0	0	draw	yes
1734	1383681	2025-07-27	Lithuania	1 Lyga	Neptūną Klaipėda	Minija	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	9	2025-11-20 07:14:19.345704	\N	\N	0	1	a-win	yes
1735	1381469	2025-07-27	Lithuania	1 Lyga	Atmosfera	Hegelmann II	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	10	2025-11-20 07:14:19.490987	\N	\N	1	0	h-win	yes
1736	1383682	2025-07-27	Lithuania	1 Lyga	Be1 NFA	TransINVEST Vilnius	a-win	1	5	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	11	1	2025-11-20 07:14:19.654521	\N	\N	0	2	a-win	yes
1737	1383683	2025-07-27	Lithuania	1 Lyga	Ekranas	Kauno Žalgiris II	a-win	1	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	13	2025-11-20 07:14:19.821436	\N	\N	1	3	a-win	yes
3698	1387213	2025-09-27	England	League One	Bradford	Blackpool	h-win	1	0	15	3	10	3	3	5	1	1	3	0	0	0	52.00	48.00	11	13	\N	\N	\N	3	21	2025-11-20 18:17:06.00177	\N	\N	0	0	draw	yes
3699	1387220	2025-09-27	England	League One	Peterborough	Lincoln	a-win	0	3	9	0	7	5	1	0	2	2	0	2	0	0	64.00	36.00	10	16	\N	\N	\N	23	2	2025-11-20 18:17:06.212884	\N	\N	0	1	a-win	yes
3700	1387217	2025-09-27	England	League One	Luton	Doncaster	h-win	1	0	8	3	10	1	6	3	2	2	2	1	0	0	50.00	50.00	14	8	\N	\N	\N	8	19	2025-11-20 18:17:06.401323	\N	\N	1	0	h-win	yes
3701	1387215	2025-09-27	England	League One	Exeter City	Huddersfield	a-win	0	1	13	3	23	1	5	8	3	1	3	1	0	0	50.00	50.00	15	8	\N	\N	\N	20	10	2025-11-20 18:17:06.584276	\N	\N	0	1	a-win	yes
3702	1387218	2025-09-27	England	League One	Mansfield Town	Rotherham	h-win	2	1	15	7	8	3	4	2	3	0	3	4	0	0	58.00	42.00	8	21	\N	\N	\N	9	11	2025-11-20 18:17:06.762774	\N	\N	0	1	a-win	yes
3703	1387221	2025-09-27	England	League One	Stockport County	Reading	draw	1	1	16	5	8	4	5	3	4	3	1	1	0	0	48.00	52.00	9	7	\N	\N	\N	1	18	2025-11-20 18:17:06.962893	\N	\N	1	0	h-win	yes
3704	1387186	2025-09-30	England	League One	Cardiff	Burton Albion	a-win	0	1	20	8	9	2	8	3	2	0	2	4	0	0	77.00	23.00	13	12	\N	\N	\N	5	12	2025-11-20 18:17:07.169159	\N	\N	0	0	draw	yes
3705	1387175	2025-09-30	England	League One	Blackpool	Luton	draw	2	2	11	3	15	3	3	8	2	2	2	1	0	0	39.00	61.00	8	9	\N	\N	\N	21	8	2025-11-20 18:17:07.337731	\N	\N	1	0	h-win	yes
3706	1387231	2025-10-02	England	League One	Rotherham	Bradford	draw	2	2	13	5	10	5	5	4	3	4	4	4	0	0	43.00	57.00	17	9	\N	\N	\N	11	3	2025-11-20 18:17:07.567725	\N	\N	1	0	h-win	yes
3707	1387225	2025-10-04	England	League One	Doncaster	Burton Albion	draw	1	1	16	3	14	5	5	10	2	2	1	1	0	0	64.00	36.00	7	11	\N	\N	\N	19	12	2025-11-20 18:17:07.773285	\N	\N	1	0	h-win	yes
3708	1387233	2025-10-04	England	League One	Wycombe	Barnsley	draw	2	2	12	2	8	4	11	4	4	0	1	2	0	0	48.00	52.00	9	9	\N	\N	\N	14	13	2025-11-20 18:17:07.973236	\N	\N	0	1	a-win	yes
3709	1387226	2025-10-04	England	League One	Huddersfield	Stockport County	a-win	1	2	16	5	13	7	10	2	3	1	2	3	0	1	54.00	46.00	16	12	\N	\N	\N	10	1	2025-11-20 18:17:08.168021	\N	\N	0	1	a-win	yes
3710	1387234	2025-10-04	England	League One	Cardiff	Leyton Orient	h-win	4	3	16	7	26	11	6	8	1	1	2	2	0	0	46.00	54.00	4	15	\N	\N	\N	5	16	2025-11-20 18:17:08.333582	\N	\N	1	1	draw	yes
3711	1387230	2025-10-04	England	League One	Reading	Mansfield Town	draw	1	1	16	3	14	2	4	5	0	2	2	1	0	0	61.00	39.00	13	13	\N	\N	\N	18	9	2025-11-20 18:17:08.498714	\N	\N	0	1	a-win	yes
3712	1387224	2025-10-04	England	League One	Bolton	Peterborough	h-win	2	1	19	6	9	2	7	1	0	5	2	3	0	0	51.00	49.00	9	7	\N	\N	\N	4	23	2025-11-20 18:17:08.678656	\N	\N	2	1	h-win	yes
3713	1387229	2025-10-04	England	League One	Port Vale	Northampton	draw	0	0	8	2	6	2	3	4	4	1	2	1	0	0	56.00	44.00	12	11	\N	\N	\N	22	15	2025-11-20 18:17:08.842077	\N	\N	0	0	draw	yes
3714	1387223	2025-10-04	England	League One	Blackpool	AFC Wimbledon	a-win	0	2	3	2	8	4	1	2	3	3	3	1	0	0	55.00	45.00	14	13	\N	\N	\N	21	7	2025-11-20 18:17:09.037528	\N	\N	0	1	a-win	yes
3715	1387228	2025-10-04	England	League One	Plymouth	Wigan	draw	1	1	10	2	9	4	7	5	0	0	2	5	0	0	60.00	40.00	15	13	\N	\N	\N	24	17	2025-11-20 18:17:09.27965	\N	\N	0	0	draw	yes
3716	1387232	2025-10-04	England	League One	Stevenage	Luton	h-win	2	0	6	5	9	3	1	5	2	1	3	1	0	0	44.00	56.00	10	15	\N	\N	\N	6	8	2025-11-20 18:17:09.535256	\N	\N	0	0	draw	yes
3717	1387227	2025-10-04	England	League One	Lincoln	Exeter City	a-win	0	1	16	3	7	2	7	2	0	1	0	2	0	0	53.00	47.00	10	10	\N	\N	\N	2	20	2025-11-20 18:17:09.724716	\N	\N	0	0	draw	yes
3718	1387242	2025-10-11	England	League One	Northampton	Rotherham	a-win	1	2	3	1	11	2	4	4	1	1	3	2	0	0	42.00	58.00	8	17	\N	\N	\N	15	11	2025-11-20 18:17:09.937256	\N	\N	1	0	h-win	yes
3719	1387245	2025-10-11	England	League One	Wigan	Wycombe	a-win	0	1	12	2	5	3	3	1	2	1	1	2	0	0	60.00	40.00	6	10	\N	\N	\N	17	14	2025-11-20 18:17:10.131443	\N	\N	0	1	a-win	yes
3720	1387237	2025-10-11	England	League One	Burton Albion	Bolton	h-win	3	0	12	6	18	7	3	5	1	2	1	2	0	0	35.00	65.00	11	13	\N	\N	\N	12	4	2025-11-20 18:17:10.328279	\N	\N	1	0	h-win	yes
3721	1387235	2025-10-11	England	League One	AFC Wimbledon	Port Vale	draw	1	1	6	4	16	3	5	11	0	2	2	2	0	0	45.00	55.00	10	13	\N	\N	\N	7	22	2025-11-20 18:17:10.554794	\N	\N	0	0	draw	yes
3722	1387238	2025-10-11	England	League One	Exeter City	Reading	draw	1	1	5	2	8	1	5	5	6	5	1	1	0	0	53.00	47.00	14	13	\N	\N	\N	20	18	2025-11-20 18:17:10.757739	\N	\N	1	1	draw	yes
3723	1387239	2025-10-11	England	League One	Leyton Orient	Doncaster	h-win	4	0	13	6	15	4	4	6	2	0	1	1	0	0	36.00	64.00	11	7	\N	\N	\N	16	19	2025-11-20 18:17:10.960691	\N	\N	2	0	h-win	yes
1764	1342274	2025-07-05	Norway	Eliteserien	Ham-Kam	Brann	draw	1	1	9	4	14	5	1	8	4	1	0	0	0	0	36.00	64.00	13	11	\N	\N	\N	12	3	2025-11-20 07:14:29.355709	1.33	2.89	1	0	h-win	yes
1765	1342280	2025-07-05	Norway	Eliteserien	Viking	Stromsgodset	h-win	1	0	20	5	2	1	16	2	1	4	0	0	0	0	66.00	34.00	11	8	\N	\N	\N	1	15	2025-11-20 07:14:29.541171	2.61	0.07	1	0	h-win	yes
1766	1342281	2025-07-05	Norway	Eliteserien	Valerenga	Fredrikstad	draw	1	1	16	5	16	7	5	5	0	0	0	3	0	0	57.00	43.00	6	15	\N	\N	\N	7	5	2025-11-20 07:14:29.721907	1.28	1.49	1	1	draw	yes
1767	1342276	2025-07-05	Norway	Eliteserien	Kristiansund BK	Bodo/Glimt	draw	1	1	8	2	20	6	4	7	1	0	1	3	0	1	41.00	59.00	8	12	\N	\N	\N	13	2	2025-11-20 07:14:29.940573	0.61	2.74	0	1	a-win	yes
1768	1342279	2025-07-05	Norway	Eliteserien	Tromso	Molde	h-win	1	0	16	3	2	0	2	2	2	1	3	2	0	1	56.00	44.00	15	10	\N	\N	\N	4	9	2025-11-20 07:14:30.129676	1.40	0.11	0	0	draw	yes
1769	1342277	2025-07-06	Norway	Eliteserien	Sandefjord	Rosenborg	h-win	2	0	14	6	12	3	2	3	2	1	2	3	0	0	55.00	45.00	11	13	\N	\N	\N	6	8	2025-11-20 07:14:30.306398	1.08	1.10	2	0	h-win	yes
1770	1342278	2025-07-06	Norway	Eliteserien	Sarpsborg 08 FF	Haugesund	h-win	3	1	19	6	12	6	19	1	3	1	1	1	0	0	61.00	39.00	11	19	\N	\N	\N	11	16	2025-11-20 07:14:30.495412	1.69	0.97	0	1	a-win	yes
1771	1342275	2025-07-06	Norway	Eliteserien	KFUM Oslo	Bryne	draw	1	1	14	3	7	3	7	2	1	0	2	0	0	1	69.00	31.00	12	4	\N	\N	\N	10	14	2025-11-20 07:14:30.674391	1.70	1.02	0	0	draw	yes
1772	1342282	2025-07-12	Norway	Eliteserien	Bodo/Glimt	Sandefjord	h-win	2	0	24	6	4	1	4	1	5	0	0	4	0	0	62.00	38.00	6	14	\N	\N	\N	2	6	2025-11-20 07:14:30.865268	3.86	0.07	0	0	draw	yes
1773	1342285	2025-07-12	Norway	Eliteserien	Fredrikstad	Molde	h-win	4	2	13	6	11	6	7	4	1	0	1	3	0	0	43.00	57.00	5	8	\N	\N	\N	5	9	2025-11-20 07:14:31.034539	1.61	1.05	0	1	a-win	yes
1774	1342284	2025-07-13	Norway	Eliteserien	Bryne	Valerenga	h-win	1	0	15	6	11	4	6	2	1	0	2	1	0	0	50.00	50.00	11	10	\N	\N	\N	14	7	2025-11-20 07:14:31.20545	1.57	1.12	0	0	draw	yes
1775	1342287	2025-07-13	Norway	Eliteserien	Kristiansund BK	Sarpsborg 08 FF	draw	0	0	6	3	32	9	4	12	1	2	1	3	1	0	31.00	69.00	3	6	\N	\N	\N	13	11	2025-11-20 07:14:31.384144	0.72	3.83	0	0	draw	yes
1776	1342289	2025-07-13	Norway	Eliteserien	Stromsgodset	Tromso	a-win	2	3	10	3	20	9	4	4	0	2	1	0	0	0	42.00	58.00	12	8	\N	\N	\N	15	4	2025-11-20 07:14:31.593546	1.22	2.76	1	2	a-win	yes
1777	1342286	2025-07-13	Norway	Eliteserien	Haugesund	KFUM Oslo	a-win	0	2	9	5	16	4	3	11	1	3	0	1	0	0	54.00	46.00	11	5	\N	\N	\N	16	10	2025-11-20 07:14:31.785061	1.02	1.22	0	1	a-win	yes
1778	1342288	2025-07-13	Norway	Eliteserien	Rosenborg	Ham-Kam	h-win	2	0	10	5	11	0	9	6	5	0	0	2	0	0	53.00	47.00	6	12	\N	\N	\N	8	12	2025-11-20 07:14:31.966152	2.41	0.90	2	0	h-win	yes
1779	1342283	2025-07-13	Norway	Eliteserien	Brann	Viking	h-win	3	1	16	4	8	3	5	2	4	4	2	4	1	0	44.00	56.00	12	14	\N	\N	\N	3	1	2025-11-20 07:14:32.148192	1.36	0.31	2	0	h-win	yes
1780	1342218	2025-07-16	Norway	Eliteserien	Fredrikstad	Bodo/Glimt	a-win	0	1	9	3	25	6	3	8	2	1	0	1	0	0	26.00	74.00	11	9	\N	\N	\N	5	2	2025-11-20 07:14:32.319523	0.75	3.36	0	0	draw	yes
1781	1342294	2025-07-18	Norway	Eliteserien	Sarpsborg 08 FF	Rosenborg	draw	2	2	16	7	12	4	4	1	1	1	2	5	0	0	52.00	48.00	15	15	\N	\N	\N	11	8	2025-11-20 07:14:32.509244	2.31	1.65	1	2	a-win	yes
1782	1342291	2025-07-19	Norway	Eliteserien	KFUM Oslo	Brann	h-win	2	0	10	3	14	0	4	11	1	0	2	5	1	1	45.00	55.00	9	14	\N	\N	\N	10	3	2025-11-20 07:14:32.702193	1.99	1.41	2	0	h-win	yes
1783	1342292	2025-07-19	Norway	Eliteserien	Molde	Stromsgodset	h-win	4	1	14	4	6	2	6	5	0	0	2	0	0	0	62.00	38.00	9	5	\N	\N	\N	9	15	2025-11-20 07:14:32.885623	2.14	0.54	3	1	h-win	yes
1784	1342296	2025-07-19	Norway	Eliteserien	Viking	Bodo/Glimt	a-win	2	4	13	5	16	8	4	4	4	1	0	3	0	0	36.00	64.00	14	15	\N	\N	\N	1	2	2025-11-20 07:14:33.071412	2.56	2.56	2	3	a-win	yes
1785	1342297	2025-07-20	Norway	Eliteserien	Valerenga	Haugesund	h-win	3	0	30	13	7	4	10	7	5	0	1	3	0	0	49.00	51.00	12	13	\N	\N	\N	7	16	2025-11-20 07:14:33.2422	3.01	0.44	0	0	draw	yes
1786	1342295	2025-07-20	Norway	Eliteserien	Tromso	Bryne	h-win	3	1	13	6	10	6	5	3	0	0	1	3	0	0	52.00	48.00	9	7	\N	\N	\N	4	14	2025-11-20 07:14:33.422052	2.31	0.70	1	0	h-win	yes
1787	1342293	2025-07-20	Norway	Eliteserien	Sandefjord	Kristiansund BK	h-win	6	0	16	6	9	2	6	7	0	3	1	0	0	0	70.00	30.00	9	5	\N	\N	\N	6	13	2025-11-20 07:14:33.604245	1.81	1.02	4	0	h-win	yes
1788	1342290	2025-07-20	Norway	Eliteserien	Ham-Kam	Fredrikstad	draw	1	1	12	2	11	5	9	4	0	3	0	1	0	0	43.00	57.00	13	11	\N	\N	\N	12	5	2025-11-20 07:14:33.779751	0.95	1.94	1	0	h-win	yes
1789	1342301	2025-07-25	Norway	Eliteserien	Fredrikstad	Stromsgodset	h-win	3	2	20	5	12	4	7	1	1	0	1	1	0	0	56.00	44.00	12	9	\N	\N	\N	5	15	2025-11-20 07:14:33.964344	2.37	0.89	2	1	h-win	yes
1790	1342303	2025-07-26	Norway	Eliteserien	Kristiansund BK	KFUM Oslo	a-win	0	5	6	1	14	7	3	3	2	0	3	1	0	0	55.00	45.00	15	12	\N	\N	\N	13	10	2025-11-20 07:14:34.140668	0.39	2.19	0	2	a-win	yes
1791	1342302	2025-07-26	Norway	Eliteserien	Haugesund	Ham-Kam	a-win	0	3	11	4	10	4	5	8	3	1	0	0	0	0	49.00	51.00	10	8	\N	\N	\N	16	12	2025-11-20 07:14:34.290763	0.81	1.28	0	2	a-win	yes
1792	1342305	2025-07-26	Norway	Eliteserien	Sandefjord	Sarpsborg 08 FF	h-win	3	2	23	10	13	7	4	5	1	1	4	4	0	0	56.00	44.00	11	10	\N	\N	\N	6	11	2025-11-20 07:14:34.441359	1.57	3.52	2	0	h-win	yes
1793	1342299	2025-07-26	Norway	Eliteserien	Bodo/Glimt	Valerenga	h-win	7	2	22	13	5	2	6	1	1	1	0	0	0	0	64.00	36.00	13	9	\N	\N	\N	2	7	2025-11-20 07:14:34.596086	4.33	0.49	2	1	h-win	yes
1794	1342304	2025-07-27	Norway	Eliteserien	Rosenborg	Tromso	h-win	4	1	11	5	8	2	4	7	2	0	2	3	0	1	48.00	52.00	12	20	\N	\N	\N	8	4	2025-11-20 07:14:34.753541	1.79	0.97	2	0	h-win	yes
1795	1342300	2025-07-27	Norway	Eliteserien	Bryne	Viking	a-win	1	3	13	5	9	5	2	5	2	3	3	3	0	0	49.00	51.00	15	16	\N	\N	\N	14	1	2025-11-20 07:14:34.938217	1.22	1.84	0	1	a-win	yes
1796	1342226	2025-07-30	Norway	Eliteserien	Bodo/Glimt	Stromsgodset	h-win	1	0	19	5	8	2	8	1	0	0	0	1	0	0	70.00	30.00	4	10	\N	\N	\N	2	15	2025-11-20 07:14:35.098398	2.18	0.24	1	0	h-win	yes
1797	1342466	2025-07-22	Norway	1. Division	Egersund	Aalesund	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	4	2025-11-20 07:14:36.44699	\N	\N	0	0	draw	yes
1798	1342532	2025-07-26	Norway	1. Division	Ranheim	ODD Ballklubb	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	9	2025-11-20 07:14:36.646996	\N	\N	2	0	h-win	yes
1799	1342535	2025-07-26	Norway	1. Division	Start	Lillestrom	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	1	2025-11-20 07:14:36.824751	\N	\N	0	1	a-win	yes
1800	1342536	2025-07-26	Norway	1. Division	Aalesund	Moss	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	14	2025-11-20 07:14:36.992516	\N	\N	1	0	h-win	yes
1801	1342534	2025-07-26	Norway	1. Division	Sogndal	Stabaek	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8	11	2025-11-20 07:14:37.177086	\N	\N	1	0	h-win	yes
1802	1342537	2025-07-26	Norway	1. Division	Asane	hodd	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	10	2025-11-20 07:14:37.352211	\N	\N	2	1	h-win	yes
1803	1342531	2025-07-26	Norway	1. Division	Mjondalen	Kongsvinger	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	15	3	2025-11-20 07:14:37.526695	\N	\N	0	0	draw	yes
1804	1342533	2025-07-26	Norway	1. Division	Raufoss	Skeid	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	13	16	2025-11-20 07:14:37.713124	\N	\N	0	1	a-win	yes
1805	1342530	2025-07-26	Norway	1. Division	Egersund	Lyn	a-win	0	5	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	7	2025-11-20 07:14:37.894412	\N	\N	0	1	a-win	yes
1806	1342544	2025-07-30	Norway	1. Division	ODD Ballklubb	Stabaek	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	11	2025-11-20 07:14:38.105129	\N	\N	0	0	draw	yes
1807	1342539	2025-07-30	Norway	1. Division	Kongsvinger	Start	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	2	2025-11-20 07:14:38.292104	\N	\N	0	2	a-win	yes
1808	1342538	2025-07-30	Norway	1. Division	hodd	Egersund	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	10	5	2025-11-20 07:14:38.473311	\N	\N	0	0	draw	yes
1809	1342542	2025-07-30	Norway	1. Division	Mjondalen	Asane	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	15	12	2025-11-20 07:14:38.666387	\N	\N	1	0	h-win	yes
1810	1342545	2025-07-30	Norway	1. Division	Skeid	Ranheim	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16	6	2025-11-20 07:14:38.83341	\N	\N	0	0	draw	yes
1811	1342541	2025-07-30	Norway	1. Division	Lyn	Aalesund	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7	4	2025-11-20 07:14:39.011594	\N	\N	0	2	a-win	yes
1812	1342543	2025-07-30	Norway	1. Division	Moss	Sogndal	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	14	8	2025-11-20 07:14:39.194456	\N	\N	2	0	h-win	yes
1813	1342540	2025-07-30	Norway	1. Division	Lillestrom	Raufoss	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	13	2025-11-20 07:14:39.364561	\N	\N	1	0	h-win	yes
3724	1387244	2025-10-11	England	League One	Stockport County	Blackpool	h-win	1	0	16	5	9	2	4	4	2	3	0	2	0	0	56.00	44.00	9	9	\N	\N	\N	1	21	2025-11-20 18:17:11.155063	\N	\N	0	0	draw	yes
3725	1387251	2025-10-16	England	League One	Huddersfield	Bolton	a-win	1	2	7	2	14	7	6	8	5	0	1	4	0	0	41.00	59.00	11	14	\N	\N	\N	10	4	2025-11-20 18:17:11.375296	\N	\N	1	0	h-win	yes
3726	1387249	2025-10-18	England	League One	Burton Albion	Peterborough	a-win	0	1	15	4	7	4	5	3	0	2	2	4	0	1	59.00	41.00	10	9	\N	\N	\N	12	23	2025-11-20 18:17:11.552901	\N	\N	0	0	draw	yes
3727	1387252	2025-10-18	England	League One	Lincoln	Stevenage	h-win	1	0	18	4	4	1	1	2	0	2	1	1	0	0	46.00	54.00	18	4	\N	\N	\N	2	6	2025-11-20 18:17:11.840572	\N	\N	0	0	draw	yes
3728	1387258	2025-10-18	England	League One	Cardiff	Reading	h-win	2	1	11	3	26	10	4	10	2	2	1	0	0	0	56.00	44.00	11	26	\N	\N	\N	5	18	2025-11-20 18:17:12.021019	\N	\N	0	1	a-win	yes
3729	1387257	2025-10-18	England	League One	Wigan	Port Vale	h-win	1	0	10	4	13	2	4	7	4	0	1	2	1	0	40.00	60.00	11	19	\N	\N	\N	17	22	2025-11-20 18:17:12.191956	\N	\N	0	0	draw	yes
3730	1387255	2025-10-18	England	League One	Rotherham	Leyton Orient	h-win	1	0	4	2	12	3	2	12	2	1	3	3	0	0	38.00	62.00	4	12	\N	\N	\N	11	16	2025-11-20 18:17:12.417241	\N	\N	0	0	draw	yes
3731	1387248	2025-10-18	England	League One	Bradford	Barnsley	draw	2	2	25	7	9	4	11	11	1	1	0	1	0	0	46.00	54.00	7	10	\N	\N	\N	3	13	2025-11-20 18:17:12.596641	\N	\N	2	1	h-win	yes
3732	1387250	2025-10-18	England	League One	Doncaster	Northampton	a-win	1	2	10	4	13	5	2	7	3	1	1	1	0	0	60.00	40.00	11	7	\N	\N	\N	19	15	2025-11-20 18:17:12.799227	\N	\N	1	0	h-win	yes
3733	1387247	2025-10-18	England	League One	Blackpool	Wycombe	draw	1	1	6	1	14	6	2	2	4	1	3	0	0	0	41.00	59.00	9	12	\N	\N	\N	21	14	2025-11-20 18:17:12.978802	\N	\N	1	0	h-win	yes
1826	1322131	2025-07-04	Paraguay	Division Profesional - Clausura	Deportivo Recoleta	Sportivo Trinidense	a-win	2	4	18	10	18	10	9	7	0	2	0	2	0	0	59.00	41.00	6	10	\N	\N	\N	6	5	2025-11-20 08:14:25.23972	4.27	3.26	1	4	a-win	yes
1827	1322127	2025-07-05	Paraguay	Division Profesional - Clausura	Cerro Porteno	General Caballero	h-win	3	1	13	6	11	4	4	2	1	1	2	2	0	0	64.00	36.00	16	17	\N	\N	\N	1	8	2025-11-20 08:14:25.440641	2.46	1.12	2	0	h-win	yes
1828	1322128	2025-07-05	Paraguay	Division Profesional - Clausura	Libertad Asuncion	Sportivo Luqueno	a-win	0	1	16	3	9	4	9	4	1	2	3	1	0	0	73.00	27.00	10	16	\N	\N	\N	9	7	2025-11-20 08:14:25.692088	2.51	0.96	0	1	a-win	yes
1829	1322130	2025-07-06	Paraguay	Division Profesional - Clausura	Olimpia	Nacional Asuncion	draw	1	1	15	6	6	3	3	2	2	0	1	2	0	0	67.00	33.00	11	17	\N	\N	\N	10	4	2025-11-20 08:14:25.944374	1.85	0.23	1	1	draw	yes
1830	1322129	2025-07-06	Paraguay	Division Profesional - Clausura	Club Guarani	2 de Mayo	h-win	3	1	6	4	8	2	4	4	2	4	2	2	0	0	42.00	58.00	15	6	\N	\N	\N	2	3	2025-11-20 08:14:26.118135	1.24	1.60	1	0	h-win	yes
1831	1322132	2025-07-07	Paraguay	Division Profesional - Clausura	Sportivo Ameliano	Atlético Tembetary	h-win	1	0	20	6	5	2	6	6	2	2	3	3	0	1	58.00	42.00	14	11	\N	\N	\N	11	12	2025-11-20 08:14:26.375453	1.89	1.13	1	0	h-win	yes
1832	1392238	2025-07-11	Paraguay	Division Profesional - Clausura	Sportivo Luqueno	General Caballero	h-win	2	0	9	4	15	3	6	7	2	1	1	2	0	0	46.00	54.00	8	14	\N	\N	\N	7	8	2025-11-20 08:14:26.573179	1.14	0.95	0	0	draw	yes
1833	1392239	2025-07-11	Paraguay	Division Profesional - Clausura	2 de Mayo	Libertad Asuncion	draw	0	0	3	1	12	1	1	4	1	7	3	2	1	0	34.00	66.00	10	13	\N	\N	\N	3	9	2025-11-20 08:14:26.772333	0.05	1.09	0	0	draw	yes
1834	1392240	2025-07-12	Paraguay	Division Profesional - Clausura	Sportivo Ameliano	Cerro Porteno	a-win	0	1	7	1	18	7	8	5	2	3	4	2	1	0	44.00	56.00	16	16	\N	\N	\N	11	1	2025-11-20 08:14:26.961135	0.08	1.16	0	0	draw	yes
1835	1392241	2025-07-12	Paraguay	Division Profesional - Clausura	Nacional Asuncion	Club Guarani	h-win	1	0	10	3	9	2	5	2	0	4	3	2	0	0	49.00	51.00	14	15	\N	\N	\N	4	2	2025-11-20 08:14:27.177176	0.76	0.52	0	0	draw	yes
1836	1392242	2025-07-13	Paraguay	Division Profesional - Clausura	Sportivo Trinidense	Olimpia	h-win	4	3	19	8	9	4	6	1	0	5	4	2	0	0	48.00	52.00	14	7	\N	\N	\N	5	10	2025-11-20 08:14:27.363386	4.00	0.64	0	2	a-win	yes
1837	1392243	2025-07-14	Paraguay	Division Profesional - Clausura	Atlético Tembetary	Deportivo Recoleta	a-win	2	3	11	4	17	6	2	6	3	0	1	1	1	0	41.00	59.00	10	7	\N	\N	\N	12	6	2025-11-20 08:14:27.51668	1.73	2.32	1	0	h-win	yes
1838	1392244	2025-07-18	Paraguay	Division Profesional - Clausura	General Caballero	2 de Mayo	a-win	0	1	9	1	11	5	3	4	7	3	5	2	0	0	47.00	53.00	12	9	\N	\N	\N	8	3	2025-11-20 08:14:27.669327	0.55	2.08	0	1	a-win	yes
1839	1392245	2025-07-19	Paraguay	Division Profesional - Clausura	Libertad Asuncion	Nacional Asuncion	a-win	0	1	12	2	13	2	7	5	1	1	6	1	1	0	71.00	29.00	12	9	\N	\N	\N	9	4	2025-11-20 08:14:27.847141	0.85	0.74	0	1	a-win	yes
1840	1392246	2025-07-19	Paraguay	Division Profesional - Clausura	Olimpia	Atlético Tembetary	h-win	3	1	16	9	8	4	8	1	0	2	1	3	0	0	71.00	29.00	11	17	\N	\N	\N	10	12	2025-11-20 08:14:28.018618	1.70	0.92	2	1	h-win	yes
1841	1392247	2025-07-20	Paraguay	Division Profesional - Clausura	Cerro Porteno	Sportivo Luqueno	draw	0	0	22	3	7	3	7	2	2	2	0	3	0	0	67.00	33.00	13	18	\N	\N	\N	1	7	2025-11-20 08:14:28.228701	1.90	0.98	0	0	draw	yes
1842	1392248	2025-07-20	Paraguay	Division Profesional - Clausura	Club Guarani	Sportivo Trinidense	draw	0	0	10	4	7	1	7	4	0	2	2	3	0	0	55.00	45.00	14	18	\N	\N	\N	2	5	2025-11-20 08:14:28.462232	0.84	0.38	0	0	draw	yes
1843	1392249	2025-07-21	Paraguay	Division Profesional - Clausura	Deportivo Recoleta	Sportivo Ameliano	h-win	3	1	14	5	8	3	3	3	3	3	5	4	0	2	72.00	28.00	15	9	\N	\N	\N	6	11	2025-11-20 08:14:28.666255	1.82	0.72	0	1	a-win	yes
1844	1392250	2025-07-25	Paraguay	Division Profesional - Clausura	Nacional Asuncion	General Caballero	h-win	3	0	10	5	9	0	2	8	2	1	3	2	0	0	39.00	61.00	15	12	\N	\N	\N	4	8	2025-11-20 08:14:28.890684	1.44	0.24	1	0	h-win	yes
1845	1392251	2025-07-25	Paraguay	Division Profesional - Clausura	2 de Mayo	Sportivo Luqueno	h-win	3	2	20	8	10	4	7	1	3	0	2	9	0	2	66.00	34.00	14	12	\N	\N	\N	3	7	2025-11-20 08:14:29.092076	2.63	2.03	1	2	a-win	yes
1846	1392252	2025-07-26	Paraguay	Division Profesional - Clausura	Sportivo Trinidense	Libertad Asuncion	a-win	0	2	15	5	15	8	7	5	0	3	1	2	0	0	57.00	43.00	6	10	\N	\N	\N	5	9	2025-11-20 08:14:29.277527	0.77	1.79	0	1	a-win	yes
1847	1392253	2025-07-26	Paraguay	Division Profesional - Clausura	Deportivo Recoleta	Cerro Porteno	a-win	1	3	11	4	14	4	6	4	0	4	3	2	0	0	44.00	56.00	11	12	\N	\N	\N	6	1	2025-11-20 08:14:29.471542	1.03	2.98	0	3	a-win	yes
1848	1392254	2025-07-27	Paraguay	Division Profesional - Clausura	Sportivo Ameliano	Olimpia	draw	1	1	8	2	13	3	1	3	4	1	3	5	0	0	32.00	68.00	13	20	\N	\N	\N	11	10	2025-11-20 08:14:29.638572	0.47	0.81	0	1	a-win	yes
1849	1392255	2025-07-27	Paraguay	Division Profesional - Clausura	Atlético Tembetary	Club Guarani	a-win	0	1	8	4	14	7	4	7	0	2	2	1	1	0	45.00	55.00	15	10	\N	\N	\N	12	2	2025-11-20 08:14:29.892368	0.27	2.22	0	1	a-win	yes
1850	1392256	2025-07-29	Paraguay	Division Profesional - Clausura	General Caballero	Sportivo Trinidense	draw	0	0	15	2	4	0	3	1	2	3	3	5	0	1	60.00	40.00	18	16	\N	\N	\N	8	5	2025-11-20 08:14:30.081788	0.36	0.19	0	0	draw	yes
1851	1392257	2025-07-29	Paraguay	Division Profesional - Clausura	Sportivo Luqueno	Nacional Asuncion	h-win	2	1	9	3	16	2	3	2	3	3	2	5	0	0	53.00	47.00	16	11	\N	\N	\N	7	4	2025-11-20 08:14:30.292126	0.75	0.70	0	0	draw	yes
1852	1392258	2025-07-30	Paraguay	Division Profesional - Clausura	Cerro Porteno	2 de Mayo	h-win	3	2	14	3	6	4	5	2	8	2	2	9	0	1	64.00	36.00	9	18	\N	\N	\N	1	3	2025-11-20 08:14:30.487171	1.99	1.22	1	1	draw	yes
1853	1392259	2025-07-31	Paraguay	Division Profesional - Clausura	Olimpia	Deportivo Recoleta	h-win	1	0	23	4	3	1	8	2	3	0	3	2	1	2	79.00	21.00	12	14	\N	\N	\N	10	6	2025-11-20 08:14:30.691201	1.40	0.07	0	0	draw	yes
1854	1392260	2025-07-31	Paraguay	Division Profesional - Clausura	Club Guarani	Sportivo Ameliano	h-win	4	1	13	5	7	1	4	2	2	3	3	2	0	1	60.00	40.00	20	18	\N	\N	\N	2	11	2025-11-20 08:14:30.878251	2.03	0.66	2	1	h-win	yes
1855	1392261	2025-07-31	Paraguay	Division Profesional - Clausura	Libertad Asuncion	Atlético Tembetary	h-win	3	1	15	5	10	3	8	4	1	3	1	2	0	0	73.00	27.00	14	13	\N	\N	\N	9	12	2025-11-20 08:14:31.077735	2.18	0.98	0	1	a-win	yes
1856	1340318	2025-07-02	Peru	Primera División	Juan Pablo II College	FBC Melgar	draw	1	1	11	3	10	4	4	6	2	0	2	3	0	0	49.00	51.00	13	10	\N	\N	\N	15	5	2025-11-20 08:14:32.547896	\N	\N	0	1	a-win	yes
1857	1340449	2025-07-04	Peru	Primera División	Sport Huancayo	UTC	h-win	1	0	13	2	14	3	5	4	5	1	2	1	0	0	48.00	52.00	12	18	\N	\N	\N	12	18	2025-11-20 08:14:32.77219	1.07	1.24	1	0	h-win	yes
1858	1340448	2025-07-04	Peru	Primera División	Cultural Santa Rosa	ADT	draw	1	1	11	4	15	4	1	10	1	0	2	2	0	0	33.00	67.00	13	11	\N	\N	\N	9	8	2025-11-20 08:14:32.972114	1.28	0.67	1	0	h-win	yes
1859	1340445	2025-07-05	Peru	Primera División	Comerciantes Unidos	Ayacucho FC	a-win	0	1	7	2	13	5	4	3	0	4	3	3	0	0	62.00	38.00	18	13	\N	\N	\N	11	16	2025-11-20 08:14:33.212978	0.43	2.42	0	0	draw	yes
1860	1340447	2025-07-05	Peru	Primera División	Cienciano	Sporting Cristal	draw	1	1	14	2	12	7	6	3	4	7	3	1	0	0	57.00	43.00	11	15	\N	\N	\N	7	3	2025-11-20 08:14:33.400039	1.12	1.45	0	0	draw	yes
1861	1340444	2025-07-06	Peru	Primera División	Alianza Universidad	Alianza Atletico	h-win	2	0	11	4	11	2	6	8	2	4	2	3	0	0	40.00	60.00	17	9	\N	\N	\N	17	10	2025-11-20 08:14:33.649319	1.75	0.69	1	0	h-win	yes
1862	1340441	2025-07-06	Peru	Primera División	Alianza Lima	Deportivo Binacional	h-win	5	1	19	8	6	1	5	0	3	2	0	2	0	0	62.00	38.00	17	8	\N	\N	\N	4	\N	2025-11-20 08:14:33.835919	4.07	0.53	4	1	h-win	yes
1863	1340443	2025-07-06	Peru	Primera División	Sport Boys	Cusco	a-win	1	2	7	1	4	2	3	4	1	0	7	6	1	0	42.00	58.00	25	15	\N	\N	\N	14	2	2025-11-20 08:14:33.999124	1.04	1.55	1	0	h-win	yes
1864	1340446	2025-07-06	Peru	Primera División	Atletico Grau	Juan Pablo II College	h-win	2	0	19	7	8	3	2	4	2	3	2	2	0	0	51.00	49.00	15	7	\N	\N	\N	13	15	2025-11-20 08:14:34.193876	2.53	0.23	0	0	draw	yes
1865	1340442	2025-07-07	Peru	Primera División	Deportivo Garcilaso	Universitario	a-win	0	1	9	3	17	4	4	2	0	3	2	0	2	1	45.00	55.00	15	9	\N	\N	\N	6	1	2025-11-20 08:14:34.400008	0.58	1.01	0	0	draw	yes
1866	1340453	2025-07-11	Peru	Primera División	ADT	Comerciantes Unidos	h-win	1	0	26	9	5	2	7	4	3	3	1	3	1	2	50.00	50.00	8	13	\N	\N	\N	8	11	2025-11-20 08:14:34.57413	3.47	0.52	0	0	draw	yes
1867	1340457	2025-07-12	Peru	Primera División	Deportivo Binacional	FBC Melgar	draw	1	1	13	6	17	6	3	3	0	3	3	0	0	0	35.00	65.00	12	10	\N	\N	\N	\N	5	2025-11-20 08:14:34.76854	1.00	1.08	0	0	draw	yes
1868	1340458	2025-07-12	Peru	Primera División	UTC	Alianza Lima	draw	0	0	13	3	18	7	4	9	1	2	4	2	0	0	31.00	69.00	13	6	\N	\N	\N	18	4	2025-11-20 08:14:34.968141	0.65	1.36	0	0	draw	yes
1869	1340455	2025-07-12	Peru	Primera División	Universitario	Cultural Santa Rosa	draw	0	0	17	1	4	1	5	0	1	0	1	3	0	0	70.00	30.00	10	16	\N	\N	\N	1	9	2025-11-20 08:14:35.152191	1.96	0.30	0	0	draw	yes
1870	1340450	2025-07-12	Peru	Primera División	Alianza Atletico	Sport Boys	h-win	1	0	24	7	2	1	9	3	5	2	5	1	1	3	75.00	25.00	12	8	\N	\N	\N	10	14	2025-11-20 08:14:35.360116	1.87	0.04	0	0	draw	yes
1871	1340451	2025-07-13	Peru	Primera División	Sporting Cristal	Atletico Grau	h-win	2	1	13	2	11	5	4	4	0	3	3	2	0	0	65.00	35.00	17	13	\N	\N	\N	3	13	2025-11-20 08:14:35.581039	0.74	1.22	1	1	draw	yes
1872	1340456	2025-07-13	Peru	Primera División	Ayacucho FC	Cienciano	h-win	1	0	12	5	7	0	7	4	5	1	3	3	0	1	46.00	54.00	13	13	\N	\N	\N	16	7	2025-11-20 08:14:35.848513	0.74	0.10	0	0	draw	yes
1873	1340452	2025-07-13	Peru	Primera División	Juan Pablo II College	Alianza Universidad	h-win	1	0	8	3	12	4	1	6	7	0	4	4	1	0	47.00	53.00	7	10	\N	\N	\N	15	17	2025-11-20 08:14:36.059877	1.23	0.89	0	0	draw	yes
1874	1340454	2025-07-14	Peru	Primera División	Cusco	Sport Huancayo	h-win	3	0	14	4	4	1	3	7	2	0	0	2	0	1	63.00	37.00	10	13	\N	\N	\N	2	12	2025-11-20 08:14:36.359555	2.17	0.22	2	0	h-win	yes
1875	1391870	2025-07-18	Peru	Primera División	Alianza Atletico	Sport Huancayo	draw	0	0	15	1	14	4	5	4	1	3	0	0	0	0	57.00	43.00	12	11	\N	\N	\N	10	12	2025-11-20 08:14:36.547925	\N	\N	0	0	draw	yes
1876	1405332	2025-07-19	Peru	Primera División	Deportivo Garcilaso	Cultural Santa Rosa	h-win	3	0	13	9	26	5	5	9	0	2	2	0	0	0	44.00	56.00	14	8	\N	\N	\N	6	9	2025-11-20 08:14:36.772315	1.40	1.38	1	0	h-win	yes
1877	1391871	2025-07-19	Peru	Primera División	Universitario	Comerciantes Unidos	h-win	3	1	14	7	2	2	6	2	2	1	0	2	0	0	59.00	41.00	8	8	\N	\N	\N	1	11	2025-11-20 08:14:36.963486	1.72	0.06	2	1	h-win	yes
1878	1391872	2025-07-19	Peru	Primera División	UTC	FBC Melgar	a-win	1	2	13	3	23	9	8	7	1	3	2	3	1	0	45.00	55.00	8	6	\N	\N	\N	18	5	2025-11-20 08:14:37.150535	1.11	3.10	0	1	a-win	yes
1879	1391873	2025-07-19	Peru	Primera División	ADT	Cienciano	h-win	1	0	9	3	19	3	3	11	5	3	3	3	0	0	47.00	53.00	16	6	\N	\N	\N	8	7	2025-11-20 08:14:37.359161	\N	\N	0	0	draw	yes
1880	1391874	2025-07-20	Peru	Primera División	Cusco	Alianza Lima	h-win	2	0	17	6	11	3	7	3	1	2	5	2	0	0	62.00	38.00	11	9	\N	\N	\N	2	4	2025-11-20 08:14:37.547281	1.89	0.70	0	0	draw	yes
1881	1391875	2025-07-20	Peru	Primera División	Sporting Cristal	Alianza Universidad	h-win	3	0	17	7	10	2	4	3	6	1	4	2	0	0	56.00	44.00	17	13	\N	\N	\N	3	17	2025-11-20 08:14:37.729321	\N	\N	2	0	h-win	yes
1882	1391876	2025-07-20	Peru	Primera División	Ayacucho FC	Atletico Grau	a-win	1	2	12	5	8	3	3	1	2	2	1	2	0	0	53.00	47.00	11	12	\N	\N	\N	16	13	2025-11-20 08:14:37.895348	\N	\N	0	0	draw	yes
1883	1391877	2025-07-20	Peru	Primera División	Juan Pablo II College	Sport Boys	h-win	3	0	9	5	13	3	1	6	3	0	1	2	0	1	43.00	57.00	13	11	\N	\N	\N	15	14	2025-11-20 08:14:38.047783	\N	\N	2	0	h-win	yes
1884	1391878	2025-07-25	Peru	Primera División	Sport Huancayo	Juan Pablo II College	h-win	5	1	25	10	10	3	8	7	2	0	2	1	0	1	55.00	45.00	4	6	\N	\N	\N	12	15	2025-11-20 08:14:38.292779	\N	\N	3	0	h-win	yes
1885	1413026	2025-07-26	Peru	Primera División	Deportivo Binacional	UTC	draw	0	0	24	5	9	4	10	3	1	0	2	0	0	0	63.00	37.00	10	6	\N	\N	\N	\N	18	2025-11-20 08:14:38.522752	\N	\N	0	0	draw	yes
1886	1413350	2025-07-26	Peru	Primera División	Alianza Universidad	Ayacucho FC	a-win	1	2	12	4	12	4	8	4	1	3	5	5	1	0	57.00	43.00	15	21	\N	\N	\N	17	16	2025-11-20 08:14:38.732253	2.47	0.77	1	0	h-win	yes
1887	1391880	2025-07-26	Peru	Primera División	Sport Boys	Sporting Cristal	a-win	0	2	17	6	13	6	11	6	3	2	3	2	1	1	44.00	56.00	14	13	\N	\N	\N	14	3	2025-11-20 08:14:38.919331	2.08	1.61	0	1	a-win	yes
1888	1391881	2025-07-27	Peru	Primera División	Cienciano	Universitario	draw	1	1	11	4	8	4	7	4	2	3	2	5	0	0	66.00	34.00	11	11	\N	\N	\N	7	1	2025-11-20 08:14:39.09425	0.59	1.23	0	0	draw	yes
1889	1391882	2025-07-27	Peru	Primera División	FBC Melgar	Cusco	a-win	0	2	18	3	13	8	7	5	1	1	3	0	0	0	47.00	53.00	14	7	\N	\N	\N	5	2	2025-11-20 08:14:39.278367	1.28	2.12	0	1	a-win	yes
1890	1391883	2025-07-27	Peru	Primera División	Comerciantes Unidos	Deportivo Garcilaso	draw	0	0	17	3	5	3	8	4	0	1	4	4	1	0	52.00	48.00	10	9	\N	\N	\N	11	6	2025-11-20 08:14:39.532319	1.70	0.52	0	0	draw	yes
1891	1391884	2025-07-28	Peru	Primera División	Alianza Lima	Alianza Atletico	draw	1	1	16	5	13	4	5	3	3	5	2	3	0	0	65.00	35.00	5	11	\N	\N	\N	4	10	2025-11-20 08:14:39.729875	1.44	1.09	0	0	draw	yes
1892	1399346	2025-07-30	Peru	Primera División	Ayacucho FC	Sport Boys	draw	0	0	10	1	4	1	5	1	2	0	4	1	0	0	50.00	50.00	15	5	\N	\N	\N	16	14	2025-11-20 08:14:39.911441	\N	\N	0	0	draw	yes
1893	1399347	2025-07-30	Peru	Primera División	Sporting Cristal	Sport Huancayo	h-win	5	0	19	7	11	1	4	4	1	1	2	5	1	1	66.00	34.00	18	13	\N	\N	\N	3	12	2025-11-20 08:14:40.093033	\N	\N	2	0	h-win	yes
1894	1399348	2025-07-31	Peru	Primera División	ADT	Alianza Universidad	a-win	0	3	10	4	8	5	5	3	3	0	3	3	0	0	57.00	43.00	17	16	\N	\N	\N	8	17	2025-11-20 08:14:40.272016	\N	\N	0	1	a-win	yes
1895	1399349	2025-07-31	Peru	Primera División	Cusco	Deportivo Binacional	h-win	2	0	9	3	7	1	2	5	2	0	1	4	0	0	61.00	39.00	8	11	\N	\N	\N	2	\N	2025-11-20 08:14:40.473112	\N	\N	1	0	h-win	yes
3734	1387254	2025-10-18	England	League One	Plymouth	AFC Wimbledon	a-win	1	2	9	4	8	2	10	2	1	3	0	3	0	0	64.00	36.00	13	19	\N	\N	\N	24	7	2025-11-20 18:17:13.174103	\N	\N	1	1	draw	yes
3735	1387253	2025-10-18	England	League One	Luton	Mansfield Town	a-win	0	2	16	4	10	4	5	1	0	0	0	0	0	0	66.00	34.00	12	12	\N	\N	\N	8	9	2025-11-20 18:17:13.373927	\N	\N	0	1	a-win	yes
3736	1387256	2025-10-18	England	League One	Stockport County	Exeter City	h-win	1	0	12	5	9	2	4	3	2	3	1	1	0	0	48.00	52.00	9	14	\N	\N	\N	1	20	2025-11-20 18:17:13.574521	\N	\N	1	0	h-win	yes
3737	1387182	2025-10-21	England	League One	Reading	Northampton	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	18	15	2025-11-20 18:17:13.60335	\N	\N	0	0	draw	yes
3738	1387261	2025-10-23	England	League One	Exeter City	Plymouth	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	20	24	2025-11-20 18:17:13.629296	\N	\N	1	0	h-win	yes
3739	1387270	2025-10-25	England	League One	Bolton	Cardiff	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	5	2025-11-20 18:17:13.642693	\N	\N	0	0	draw	yes
3740	1387263	2025-10-25	England	League One	Mansfield Town	Wigan	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	17	2025-11-20 18:17:13.657296	\N	\N	1	0	h-win	yes
3741	1387267	2025-10-25	England	League One	Reading	Doncaster	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	18	19	2025-11-20 18:17:13.67435	\N	\N	0	0	draw	yes
3742	1387260	2025-10-25	England	League One	Barnsley	Rotherham	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	13	11	2025-11-20 18:17:13.685746	\N	\N	0	0	draw	yes
3743	1387259	2025-10-25	England	League One	AFC Wimbledon	Burton Albion	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7	12	2025-11-20 18:17:13.692303	\N	\N	0	0	draw	yes
3744	1387264	2025-10-25	England	League One	Northampton	Luton	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	15	8	2025-11-20 18:17:13.701833	\N	\N	0	0	draw	yes
3745	1387265	2025-10-25	England	League One	Peterborough	Blackpool	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	23	21	2025-11-20 18:17:13.708574	\N	\N	1	1	draw	yes
3746	1387269	2025-10-25	England	League One	Wycombe	Huddersfield	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	14	10	2025-11-20 18:17:13.716919	\N	\N	1	0	h-win	yes
3747	1387268	2025-10-25	England	League One	Stevenage	Bradford	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	3	2025-11-20 18:17:13.722571	\N	\N	1	1	draw	yes
3748	1387262	2025-10-25	England	League One	Leyton Orient	Lincoln	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16	2	2025-11-20 18:17:13.730333	\N	\N	0	0	draw	yes
3749	1387266	2025-10-27	England	League One	Port Vale	Stockport County	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	22	1	2025-11-20 18:17:13.737415	\N	\N	0	3	a-win	yes
3750	1387236	2025-10-28	England	League One	Bradford	Lincoln	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	2	2025-11-20 18:17:13.746441	\N	\N	0	0	draw	yes
3751	1387241	2025-10-28	England	League One	Mansfield Town	Plymouth	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	24	2025-11-20 18:17:13.753641	\N	\N	1	0	h-win	yes
3752	1387147	2025-11-04	England	League One	Rotherham	Burton Albion	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	11	12	2025-11-20 18:17:13.759819	\N	\N	0	0	draw	yes
3753	1387278	2025-11-06	England	League One	Reading	Stevenage	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	18	6	2025-11-20 18:17:13.76801	\N	\N	1	0	h-win	yes
3754	1387276	2025-11-08	England	League One	Northampton	Mansfield Town	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	15	9	2025-11-20 18:17:13.784879	\N	\N	0	1	a-win	yes
3755	1387281	2025-11-08	England	League One	Wycombe	Leyton Orient	h-win	4	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	14	16	2025-11-20 18:17:13.790515	\N	\N	3	1	h-win	yes
3756	1387275	2025-11-08	England	League One	Huddersfield	Plymouth	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	10	24	2025-11-20 18:17:13.799178	\N	\N	1	0	h-win	yes
3757	1387271	2025-11-08	England	League One	Bolton	Port Vale	h-win	4	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	22	2025-11-20 18:17:13.804629	\N	\N	2	0	h-win	yes
3758	1387279	2025-11-08	England	League One	Rotherham	Lincoln	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	11	2	2025-11-20 18:17:13.812461	\N	\N	2	0	h-win	yes
3759	1387272	2025-11-08	England	League One	Bradford	Burton Albion	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	12	2025-11-20 18:17:13.818067	\N	\N	0	2	a-win	yes
3760	1387277	2025-11-08	England	League One	Peterborough	AFC Wimbledon	h-win	5	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	23	7	2025-11-20 18:17:13.823276	\N	\N	3	0	h-win	yes
3761	1387273	2025-11-08	England	League One	Doncaster	Barnsley	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	19	13	2025-11-20 18:17:13.831731	\N	\N	1	1	draw	yes
3762	1387282	2025-11-08	England	League One	Blackpool	Cardiff	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	21	5	2025-11-20 18:17:13.837259	\N	\N	0	0	draw	yes
3763	1387274	2025-11-08	England	League One	Exeter City	Wigan	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	20	17	2025-11-20 18:17:13.845722	\N	\N	0	1	a-win	yes
3764	1387280	2025-11-08	England	League One	Stockport County	Luton	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	8	2025-11-20 18:17:13.851214	\N	\N	0	2	a-win	yes
3765	1387285	2025-11-15	England	League One	Burton Albion	Blackpool	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	21	2025-11-20 18:17:13.856661	\N	\N	0	0	draw	yes
3766	1387291	2025-11-15	England	League One	Port Vale	Wycombe	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	22	14	2025-11-20 18:17:13.863117	\N	\N	0	0	draw	yes
3767	1387288	2025-11-15	England	League One	Luton	Rotherham	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8	11	2025-11-20 18:17:13.871745	\N	\N	0	0	draw	yes
3768	1387286	2025-11-15	England	League One	Leyton Orient	Exeter City	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16	20	2025-11-20 18:17:13.877466	\N	\N	0	1	a-win	yes
3769	1387287	2025-11-15	England	League One	Lincoln	Doncaster	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	19	2025-11-20 18:17:13.885457	\N	\N	1	0	h-win	yes
3770	1387184	2025-09-06	England	League One	Stevenage	Barnsley	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 18:17:13.891388	\N	\N	0	0	draw	no
3771	1387246	2025-10-11	England	League One	Barnsley	Cardiff	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 18:17:13.899131	\N	\N	0	0	draw	no
3772	1387293	2025-11-15	England	League One	Wigan	Reading	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 18:17:13.905186	\N	\N	0	0	draw	no
3773	1387284	2025-11-15	England	League One	Barnsley	Northampton	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 18:17:13.911205	\N	\N	0	0	draw	no
3774	1387283	2025-11-15	England	League One	AFC Wimbledon	Stockport County	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 18:17:13.918439	\N	\N	0	0	draw	no
3775	1387292	2025-11-15	England	League One	Stevenage	Bolton	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 18:17:13.924148	\N	\N	0	0	draw	no
3776	1387289	2025-11-15	England	League One	Mansfield Town	Peterborough	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 18:17:13.932671	\N	\N	0	0	draw	no
3777	1387301	2025-11-20	England	League One	Peterborough	Stockport County	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 18:17:13.938183	\N	\N	0	0	draw	no
3778	1387302	2025-11-22	England	League One	Port Vale	Plymouth	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 18:17:13.946111	\N	\N	0	0	draw	no
3779	1387298	2025-11-22	England	League One	Exeter City	Burton Albion	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 18:17:13.951844	\N	\N	0	0	draw	no
3780	1387303	2025-11-22	England	League One	Reading	Rotherham	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 18:17:13.957328	\N	\N	0	0	draw	no
3781	1387297	2025-11-22	England	League One	Bolton	Bradford	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 18:17:13.96339	\N	\N	0	0	draw	no
3782	1387296	2025-11-22	England	League One	Barnsley	Luton	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 18:17:13.972043	\N	\N	0	0	draw	no
3783	1387295	2025-11-22	England	League One	AFC Wimbledon	Wigan	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 18:17:13.977978	\N	\N	0	0	draw	no
1934	1410121	2025-07-25	Slovakia	2. liga	Dukla Banská Bystrica	Slávia TU Košice	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	13	2025-11-20 09:15:11.603481	\N	\N	1	0	h-win	yes
1935	1394743	2025-07-25	Slovakia	2. liga	Púchov	Slovan Bratislava II	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16	14	2025-11-20 09:15:11.834297	\N	\N	0	1	a-win	yes
1936	1394739	2025-07-25	Slovakia	2. liga	Pohronie	Malženice	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	11	2025-11-20 09:15:12.000344	\N	\N	0	0	draw	yes
1937	1410122	2025-07-26	Slovakia	2. liga	Liptovský Mikuláš	Baník Lehota p.Vtáčnikom	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	12	2025-11-20 09:15:12.188084	\N	\N	1	0	h-win	yes
1938	1394744	2025-07-26	Slovakia	2. liga	Šamorín	Žilina II	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	10	8	2025-11-20 09:15:12.372166	\N	\N	0	1	a-win	yes
1939	1394740	2025-07-26	Slovakia	2. liga	Inter Bratislava	Zlaté Moravce	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7	2	2025-11-20 09:15:12.557261	\N	\N	1	0	h-win	yes
1940	1410123	2025-07-26	Slovakia	2. liga	Lokomotíva Zvolen	Stará Ľubovňa	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	15	2025-11-20 09:15:12.743155	\N	\N	0	1	a-win	yes
3784	1387306	2025-11-22	England	League One	Northampton	Cardiff	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 18:17:13.985616	\N	\N	0	0	draw	no
3785	1387305	2025-11-22	England	League One	Wycombe	Lincoln	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 18:17:13.991334	\N	\N	0	0	draw	no
3786	1387304	2025-11-22	England	League One	Stevenage	Doncaster	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 18:17:13.999228	\N	\N	0	0	draw	no
3787	1387299	2025-11-22	England	League One	Leyton Orient	Blackpool	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 18:17:14.004931	\N	\N	0	0	draw	no
3788	1387300	2025-11-22	England	League One	Mansfield Town	Huddersfield	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 18:17:14.01085	\N	\N	0	0	draw	no
4039	1423506	2025-08-05	England	FA Cup	Gresley	Eastwood Community	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.328459	\N	\N	0	0	draw	yes
1947	1384233	2025-07-18	Slovenia	1. SNL	Radomlje	Aluminij	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7	6	2025-11-20 09:15:16.482249	\N	\N	1	1	draw	yes
1948	1384232	2025-07-19	Slovenia	1. SNL	Primorje	NK Domzale	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	10	2025-11-20 09:15:16.668973	\N	\N	0	1	a-win	yes
1949	1384231	2025-07-19	Slovenia	1. SNL	Olimpija Ljubljana	Mura	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	8	2025-11-20 09:15:16.878137	\N	\N	0	0	draw	yes
1950	1391240	2025-07-20	Slovenia	1. SNL	Maribor	Celje	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	1	2025-11-20 09:15:17.054116	\N	\N	1	0	h-win	yes
1951	1384234	2025-07-20	Slovenia	1. SNL	Koper	Bravo	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	3	2025-11-20 09:15:17.241469	\N	\N	0	0	draw	yes
1952	1384237	2025-07-26	Slovenia	1. SNL	Bravo	Mura	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	8	2025-11-20 09:15:17.432278	\N	\N	1	0	h-win	yes
1953	1384236	2025-07-26	Slovenia	1. SNL	Aluminij	Olimpija Ljubljana	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	5	2025-11-20 09:15:17.610354	\N	\N	0	3	a-win	yes
1954	1384239	2025-07-27	Slovenia	1. SNL	NK Domzale	Maribor	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	10	2	2025-11-20 09:15:17.795993	\N	\N	1	1	draw	yes
1955	1399970	2025-07-27	Slovenia	1. SNL	Celje	Radomlje	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	7	2025-11-20 09:15:18.032354	\N	\N	1	0	h-win	yes
1956	1384240	2025-07-28	Slovenia	1. SNL	Koper	Primorje	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	9	2025-11-20 09:15:18.229895	\N	\N	1	0	h-win	yes
1957	1382294	2025-07-25	Switzerland	Super League	FC Zurich	FC Sion	a-win	2	3	9	5	15	6	3	2	0	0	1	2	0	0	56.00	44.00	15	10	\N	\N	\N	9	5	2025-11-20 09:15:22.962345	0.78	1.21	1	0	h-win	yes
1958	1382296	2025-07-26	Switzerland	Super League	FC ST. Gallen	FC Basel 1893	h-win	2	1	18	8	20	5	8	5	1	2	2	3	0	0	39.00	61.00	15	11	\N	\N	\N	4	2	2025-11-20 09:15:23.137168	2.04	2.05	0	1	a-win	yes
1959	1382295	2025-07-26	Switzerland	Super League	Grasshoppers	FC Luzern	a-win	2	3	15	5	11	5	9	4	1	0	3	1	0	0	45.00	55.00	12	5	\N	\N	\N	11	7	2025-11-20 09:15:23.309681	1.59	2.05	2	2	draw	yes
1960	1382297	2025-07-26	Switzerland	Super League	BSC Young Boys	Servette FC	h-win	3	1	22	4	7	1	8	2	1	3	3	2	0	1	68.00	32.00	10	13	\N	\N	\N	3	10	2025-11-20 09:15:23.525079	2.73	0.81	2	1	h-win	yes
1961	1382299	2025-07-27	Switzerland	Super League	FC Lugano	FC Thun	a-win	1	2	9	6	21	2	5	2	2	2	2	1	0	0	54.00	46.00	15	15	\N	\N	\N	6	1	2025-11-20 09:15:23.732436	1.66	1.68	1	0	h-win	yes
1962	1382298	2025-07-27	Switzerland	Super League	Lausanne	FC Winterthur	h-win	3	2	23	6	6	2	12	2	1	2	2	5	0	1	63.00	37.00	11	19	\N	\N	\N	8	12	2025-11-20 09:15:23.924654	3.76	0.67	0	1	a-win	yes
1963	1381825	2025-07-25	Switzerland	Challenge League	Neuchatel Xamax FC	Stade Nyonnais	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	6	2025-11-20 09:15:25.292354	\N	\N	1	0	h-win	yes
1964	1381824	2025-07-25	Switzerland	Challenge League	Rapperswil	Étoile Carouge	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	7	2025-11-20 09:15:25.483832	\N	\N	0	0	draw	yes
1965	1381827	2025-07-26	Switzerland	Challenge League	Stade Lausanne-Ouchy	FC WIL 1900	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	8	2025-11-20 09:15:25.698862	\N	\N	1	1	draw	yes
1966	1381828	2025-07-27	Switzerland	Challenge League	FC Vaduz	Yverdon Sport	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	3	2025-11-20 09:15:25.89245	\N	\N	1	0	h-win	yes
1967	1341825	2025-07-19	Sweden	Superettan	Ostersunds FK	Falkenbergs FF	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	5	2025-11-20 09:15:27.32675	\N	\N	1	0	h-win	yes
1968	1341822	2025-07-19	Sweden	Superettan	Umeå FC	Orebro SK	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	14	2025-11-20 09:15:27.537789	\N	\N	1	0	h-win	yes
1969	1341818	2025-07-19	Sweden	Superettan	Oddevold	Orgryte IS	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	3	2025-11-20 09:15:27.732397	\N	\N	0	0	draw	yes
1970	1341821	2025-07-19	Sweden	Superettan	Sandviken	Vasteras SK FK	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	10	1	2025-11-20 09:15:27.922389	\N	\N	0	2	a-win	yes
1971	1341824	2025-07-20	Sweden	Superettan	Varbergs BoIS FC	GIF Sundsvall	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	11	2025-11-20 09:15:28.119406	\N	\N	0	0	draw	yes
1972	1341819	2025-07-20	Sweden	Superettan	Kalmar FF	IK brage	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	8	2025-11-20 09:15:28.31462	\N	\N	1	0	h-win	yes
1973	1341820	2025-07-21	Sweden	Superettan	Landskrona BoIS	trelleborgs FF	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	15	2025-11-20 09:15:28.512011	\N	\N	1	1	draw	yes
1974	1341823	2025-07-21	Sweden	Superettan	Utsikten	Helsingborg	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	13	7	2025-11-20 09:15:28.719116	\N	\N	0	0	draw	yes
1975	1341827	2025-07-26	Sweden	Superettan	GIF Sundsvall	Orebro SK	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	11	14	2025-11-20 09:15:28.930963	\N	\N	0	1	a-win	yes
4040	1423481	2025-08-05	England	FA Cup	Longridge Town	Pilkington	h-win	8	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.334473	\N	\N	0	0	draw	yes
4041	1424895	2025-08-05	England	FA Cup	Northallerton Town	West Allotment Celtic	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.343732	\N	\N	0	0	draw	yes
4042	1423485	2025-08-05	England	FA Cup	Reading City	Cirencester Town	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.350069	\N	\N	0	0	draw	yes
1976	1341830	2025-07-26	Sweden	Superettan	Oddevold	Sandviken	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	10	2025-11-20 09:15:29.131555	\N	\N	0	0	draw	yes
1977	1341829	2025-07-26	Sweden	Superettan	IK brage	Umeå FC	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8	\N	2025-11-20 09:15:29.321382	\N	\N	1	0	h-win	yes
1978	1341831	2025-07-27	Sweden	Superettan	Kalmar FF	Utsikten	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	13	2025-11-20 09:15:29.521717	\N	\N	0	0	draw	yes
1979	1341826	2025-07-27	Sweden	Superettan	Falkenbergs FF	Landskrona BoIS	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	9	2025-11-20 09:15:29.680634	\N	\N	0	0	draw	yes
1980	1341833	2025-07-27	Sweden	Superettan	Orgryte IS	Ostersunds FK	h-win	6	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	12	2025-11-20 09:15:29.881439	\N	\N	3	0	h-win	yes
1981	1341828	2025-07-28	Sweden	Superettan	Helsingborg	Varbergs BoIS FC	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7	6	2025-11-20 09:15:30.076408	\N	\N	0	0	draw	yes
1982	1341832	2025-07-28	Sweden	Superettan	Vasteras SK FK	trelleborgs FF	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	15	2025-11-20 09:15:30.293575	\N	\N	1	0	h-win	yes
1983	1342053	2025-07-05	Sweden	Allsvenskan	Gais	Malmo FF	draw	0	0	22	3	12	1	6	3	2	1	1	0	0	0	45.00	55.00	12	5	\N	\N	\N	3	6	2025-11-20 09:15:31.659602	1.55	1.42	0	0	draw	yes
1984	1342055	2025-07-05	Sweden	Allsvenskan	Osters IF	Mjallby AIF	a-win	0	1	9	2	24	6	3	7	2	2	3	3	0	0	47.00	53.00	18	11	\N	\N	\N	15	1	2025-11-20 09:15:31.850618	1.28	1.42	0	0	draw	yes
1985	1342051	2025-07-05	Sweden	Allsvenskan	Hammarby FF	IFK Varnamo	h-win	1	0	21	5	10	0	9	3	1	0	3	3	0	1	73.00	27.00	8	15	\N	\N	\N	2	16	2025-11-20 09:15:32.063779	1.62	0.80	0	0	draw	yes
1986	1342054	2025-07-06	Sweden	Allsvenskan	IFK Goteborg	Sirius	h-win	3	1	13	5	11	5	4	5	1	1	3	3	0	0	52.00	48.00	11	12	\N	\N	\N	4	9	2025-11-20 09:15:32.254099	1.19	1.61	1	1	draw	yes
1987	1342057	2025-07-06	Sweden	Allsvenskan	Halmstad	AIK Stockholm	h-win	2	0	7	2	13	4	2	8	0	6	0	1	0	0	30.00	70.00	8	8	\N	\N	\N	11	7	2025-11-20 09:15:32.428702	0.96	1.29	2	0	h-win	yes
1988	1342050	2025-07-06	Sweden	Allsvenskan	Djurgardens IF	Degerfors IF	h-win	5	1	20	8	13	4	7	4	0	0	2	3	0	0	57.00	43.00	8	14	\N	\N	\N	5	13	2025-11-20 09:15:32.604069	3.12	0.81	3	0	h-win	yes
1989	1342052	2025-07-06	Sweden	Allsvenskan	IF Elfsborg	BK Hacken	a-win	0	2	13	3	12	4	16	0	3	0	3	2	0	0	62.00	38.00	15	12	\N	\N	\N	8	10	2025-11-20 09:15:32.791099	1.03	1.85	0	1	a-win	yes
1990	1342056	2025-07-07	Sweden	Allsvenskan	IFK Norrkoping	IF Brommapojkarna	a-win	0	1	15	3	15	5	9	4	1	0	2	1	0	0	66.00	34.00	9	16	\N	\N	\N	14	12	2025-11-20 09:15:32.967339	0.79	1.30	0	0	draw	yes
1991	1342061	2025-07-12	Sweden	Allsvenskan	IFK Goteborg	IF Elfsborg	a-win	1	2	18	6	11	5	7	4	1	0	0	4	0	0	52.00	48.00	13	21	\N	\N	\N	4	8	2025-11-20 09:15:33.171339	1.91	1.35	1	2	a-win	yes
1992	1342063	2025-07-12	Sweden	Allsvenskan	Malmo FF	IFK Norrkoping	h-win	3	1	16	7	13	5	4	2	3	1	2	2	0	0	49.00	51.00	20	14	\N	\N	\N	6	14	2025-11-20 09:15:33.357194	2.26	1.14	1	0	h-win	yes
1993	1342059	2025-07-13	Sweden	Allsvenskan	IF Brommapojkarna	Osters IF	h-win	2	0	17	8	10	3	12	7	1	0	2	4	0	0	42.00	58.00	10	14	\N	\N	\N	12	15	2025-11-20 09:15:33.594215	1.69	0.85	0	0	draw	yes
1994	1342060	2025-07-13	Sweden	Allsvenskan	Gais	Hammarby FF	h-win	3	2	21	10	8	5	11	1	0	2	2	1	0	0	42.00	58.00	12	9	\N	\N	\N	3	2	2025-11-20 09:15:33.800429	\N	\N	1	0	h-win	yes
1995	1342058	2025-07-13	Sweden	Allsvenskan	AIK Stockholm	Degerfors IF	h-win	3	0	11	4	6	1	5	1	2	0	0	2	0	0	53.00	47.00	8	14	\N	\N	\N	7	13	2025-11-20 09:15:34.0014	\N	\N	1	0	h-win	yes
1996	1342065	2025-07-13	Sweden	Allsvenskan	IFK Varnamo	Djurgardens IF	h-win	1	0	10	4	21	5	8	8	3	1	4	3	0	0	39.00	61.00	17	14	\N	\N	\N	16	5	2025-11-20 09:15:34.245921	0.47	1.60	0	0	draw	yes
1997	1342062	2025-07-13	Sweden	Allsvenskan	BK Hacken	Halmstad	h-win	4	1	18	7	11	6	7	1	3	1	3	0	0	0	67.00	33.00	9	11	\N	\N	\N	10	11	2025-11-20 09:15:34.435961	2.74	1.15	3	0	h-win	yes
1998	1342064	2025-07-14	Sweden	Allsvenskan	Sirius	Mjallby AIF	a-win	1	2	15	6	9	4	6	3	1	0	0	1	0	0	53.00	47.00	9	12	\N	\N	\N	9	1	2025-11-20 09:15:34.629375	\N	\N	0	2	a-win	yes
1999	1342066	2025-07-19	Sweden	Allsvenskan	Djurgardens IF	IF Elfsborg	h-win	1	0	18	8	12	6	7	1	1	0	3	2	0	0	46.00	54.00	17	22	\N	\N	\N	5	8	2025-11-20 09:15:34.841347	1.80	0.87	1	0	h-win	yes
2000	1342068	2025-07-19	Sweden	Allsvenskan	Osters IF	Malmo FF	a-win	0	2	11	1	13	5	1	5	1	0	0	1	0	0	37.00	63.00	10	11	\N	\N	\N	15	6	2025-11-20 09:15:35.048755	1.82	1.56	0	1	a-win	yes
2001	1342073	2025-07-19	Sweden	Allsvenskan	Degerfors IF	Gais	a-win	0	3	16	9	11	5	6	1	2	2	1	1	0	0	53.00	47.00	10	15	\N	\N	\N	13	3	2025-11-20 09:15:35.270502	1.48	1.22	0	1	a-win	yes
2002	1342071	2025-07-20	Sweden	Allsvenskan	Sirius	IFK Goteborg	a-win	0	1	15	3	15	6	3	6	1	0	5	1	0	0	59.00	41.00	14	14	\N	\N	\N	9	4	2025-11-20 09:15:35.440228	1.33	1.77	0	0	draw	yes
2003	1342069	2025-07-20	Sweden	Allsvenskan	Mjallby AIF	AIK Stockholm	h-win	2	0	10	2	7	1	5	5	2	4	2	3	0	0	55.00	45.00	14	15	\N	\N	\N	1	7	2025-11-20 09:15:35.625679	0.79	0.39	0	0	draw	yes
2004	1342067	2025-07-20	Sweden	Allsvenskan	Hammarby FF	IF Brommapojkarna	h-win	3	2	20	8	11	3	8	6	0	1	1	1	0	0	70.00	30.00	10	20	\N	\N	\N	2	12	2025-11-20 09:15:35.809258	2.54	1.47	0	2	a-win	yes
2005	1342072	2025-07-20	Sweden	Allsvenskan	Halmstad	BK Hacken	draw	0	0	9	3	22	7	2	11	3	2	3	2	0	0	32.00	68.00	16	9	\N	\N	\N	11	10	2025-11-20 09:15:36.001197	1.39	1.57	0	0	draw	yes
2006	1342070	2025-07-21	Sweden	Allsvenskan	IFK Norrkoping	IFK Varnamo	h-win	3	1	18	6	16	4	4	7	2	1	2	1	0	0	51.00	49.00	13	13	\N	\N	\N	14	16	2025-11-20 09:15:36.241667	2.48	1.96	1	0	h-win	yes
2007	1342075	2025-07-26	Sweden	Allsvenskan	IF Brommapojkarna	Malmo FF	a-win	2	3	10	5	15	4	3	6	0	3	2	2	0	0	32.00	68.00	11	9	\N	\N	\N	12	6	2025-11-20 09:15:36.465628	0.78	1.34	1	1	draw	yes
2008	1342077	2025-07-26	Sweden	Allsvenskan	Gais	Halmstad	h-win	3	0	18	6	8	2	6	2	2	0	2	2	0	0	61.00	39.00	13	11	\N	\N	\N	3	11	2025-11-20 09:15:36.647014	2.00	0.79	2	0	h-win	yes
2009	1342080	2025-07-26	Sweden	Allsvenskan	Degerfors IF	IFK Norrkoping	draw	0	0	21	4	5	1	7	1	6	1	3	2	0	0	57.00	43.00	18	17	\N	\N	\N	13	14	2025-11-20 09:15:36.860611	\N	\N	0	0	draw	yes
2010	1342078	2025-07-27	Sweden	Allsvenskan	BK Hacken	Djurgardens IF	a-win	1	6	18	6	18	7	5	1	0	3	3	1	2	0	49.00	51.00	12	11	\N	\N	\N	10	5	2025-11-20 09:15:37.122272	1.40	3.02	0	4	a-win	yes
2011	1342074	2025-07-27	Sweden	Allsvenskan	AIK Stockholm	Osters IF	draw	0	0	15	4	6	1	9	1	0	1	1	0	0	0	54.00	46.00	17	9	\N	\N	\N	7	15	2025-11-20 09:15:37.33938	0.74	0.49	0	0	draw	yes
2012	1342081	2025-07-27	Sweden	Allsvenskan	IFK Varnamo	Hammarby FF	a-win	2	3	12	7	22	10	3	6	1	4	3	2	0	0	34.00	66.00	13	9	\N	\N	\N	16	2	2025-11-20 09:15:37.523119	1.62	2.63	2	1	h-win	yes
2013	1342079	2025-07-27	Sweden	Allsvenskan	Mjallby AIF	Sirius	h-win	2	1	19	7	10	2	10	2	1	2	0	0	0	0	57.00	43.00	13	13	\N	\N	\N	1	9	2025-11-20 09:15:37.723269	1.99	0.98	0	1	a-win	yes
2315	1451205	2025-10-23	World	UEFA Europa League	FCSB	Bologna	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	31	24	2025-11-20 11:02:23.025023	\N	\N	0	2	a-win	yes
2014	1342076	2025-07-28	Sweden	Allsvenskan	IF Elfsborg	IFK Goteborg	h-win	4	3	16	6	10	5	12	2	1	1	2	4	0	0	58.00	42.00	13	14	\N	\N	\N	8	4	2025-11-20 09:15:37.923995	1.42	2.38	1	3	a-win	yes
2015	1391199	2025-07-05	Uruguay	Segunda División	Colón	Uruguay Montevideo	h-win	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	14	2025-11-20 09:15:43.890535	\N	\N	4	0	h-win	yes
2016	1391374	2025-07-05	Uruguay	Segunda División	Rentistas	Rampla Juniors	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	11	2025-11-20 09:15:44.092965	\N	\N	0	0	draw	yes
2017	1391375	2025-07-05	Uruguay	Segunda División	Cerrito	Albion FC	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	1	2025-11-20 09:15:44.297633	\N	\N	0	0	draw	yes
2018	1391200	2025-07-05	Uruguay	Segunda División	Tacuarembo	Atenas	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7	4	2025-11-20 09:15:44.495511	\N	\N	0	0	draw	yes
2019	1391201	2025-07-05	Uruguay	Segunda División	Central Espanol	Artigas	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	13	2025-11-20 09:15:44.587186	\N	\N	0	0	draw	yes
2020	1391202	2025-07-06	Uruguay	Segunda División	La Luz	Fenix	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	10	8	2025-11-20 09:15:44.612377	\N	\N	1	1	draw	yes
2021	1391203	2025-07-06	Uruguay	Segunda División	Deportivo Maldonado	Oriental	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	6	2025-11-20 09:15:44.638058	\N	\N	2	0	h-win	yes
2022	1399339	2025-07-12	Uruguay	Segunda División	Uruguay Montevideo	Cerrito	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	14	12	2025-11-20 09:15:44.66102	\N	\N	0	0	draw	yes
2023	1399340	2025-07-12	Uruguay	Segunda División	Rampla Juniors	Tacuarembo	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	11	7	2025-11-20 09:15:44.674118	\N	\N	0	1	a-win	yes
2024	1399341	2025-07-12	Uruguay	Segunda División	Fenix	Rentistas	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8	9	2025-11-20 09:15:44.679984	\N	\N	0	0	draw	yes
2025	1399342	2025-07-12	Uruguay	Segunda División	Artigas	Deportivo Maldonado	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	13	5	2025-11-20 09:15:44.689079	\N	\N	0	1	a-win	yes
2026	1399343	2025-07-13	Uruguay	Segunda División	Albion FC	La Luz	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	10	2025-11-20 09:15:44.695058	\N	\N	1	0	h-win	yes
2027	1399344	2025-07-13	Uruguay	Segunda División	Oriental	Colón	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	2	2025-11-20 09:15:44.704716	\N	\N	0	0	draw	yes
2028	1399345	2025-07-14	Uruguay	Segunda División	Atenas	Central Espanol	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	3	2025-11-20 09:15:44.711297	\N	\N	0	1	a-win	yes
2029	1403878	2025-07-19	Uruguay	Segunda División	Rentistas	Albion FC	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	1	2025-11-20 09:15:44.720258	\N	\N	0	1	a-win	yes
2030	1403879	2025-07-19	Uruguay	Segunda División	La Luz	Uruguay Montevideo	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	10	14	2025-11-20 09:15:44.72616	\N	\N	0	0	draw	yes
2031	1403880	2025-07-20	Uruguay	Segunda División	Central Espanol	Rampla Juniors	h-win	4	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	11	2025-11-20 09:15:44.73514	\N	\N	2	0	h-win	yes
2032	1403882	2025-07-20	Uruguay	Segunda División	Atenas	Artigas	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	13	2025-11-20 09:15:44.741266	\N	\N	1	0	h-win	yes
2033	1403881	2025-07-20	Uruguay	Segunda División	Tacuarembo	Fenix	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7	8	2025-11-20 09:15:44.747105	\N	\N	0	0	draw	yes
2034	1403883	2025-07-20	Uruguay	Segunda División	Colón	Deportivo Maldonado	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	5	2025-11-20 09:15:44.755786	\N	\N	0	0	draw	yes
2035	1403884	2025-07-21	Uruguay	Segunda División	Oriental	Cerrito	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	12	2025-11-20 09:15:44.761742	\N	\N	0	0	draw	yes
2036	1412998	2025-07-26	Uruguay	Segunda División	Colón	Artigas	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	13	2025-11-20 09:15:44.770699	\N	\N	1	1	draw	yes
2037	1412999	2025-07-26	Uruguay	Segunda División	Uruguay Montevideo	Rentistas	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	14	9	2025-11-20 09:15:44.77658	\N	\N	0	2	a-win	yes
2038	1413000	2025-07-27	Uruguay	Segunda División	Oriental	La Luz	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	10	2025-11-20 09:15:44.785208	\N	\N	1	1	draw	yes
2039	1413001	2025-07-27	Uruguay	Segunda División	Fenix	Central Espanol	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8	3	2025-11-20 09:15:44.79127	\N	\N	1	0	h-win	yes
2040	1413002	2025-07-27	Uruguay	Segunda División	Deportivo Maldonado	Cerrito	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	12	2025-11-20 09:15:44.798114	\N	\N	0	0	draw	yes
2041	1413347	2025-07-27	Uruguay	Segunda División	Rampla Juniors	Atenas	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	11	4	2025-11-20 09:15:44.805958	\N	\N	1	1	draw	yes
2042	1413003	2025-07-27	Uruguay	Segunda División	Albion FC	Tacuarembo	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	7	2025-11-20 09:15:44.811773	\N	\N	1	0	h-win	yes
2060	1326465	2025-07-10	USA	Major League Soccer	Los Angeles FC	Colorado Rapids	h-win	3	0	21	5	6	2	2	0	1	1	0	0	0	1	73.00	27.00	20	8	\N	\N	\N	3	11	2025-11-20 10:20:03.50823	3.18	0.47	1	0	h-win	yes
2061	1326527	2025-07-13	USA	Major League Soccer	Orlando City SC	CF Montreal	draw	1	1	10	4	4	1	3	2	3	3	4	3	0	0	52.00	48.00	21	18	\N	\N	\N	\N	\N	2025-11-20 10:20:03.693516	0.48	0.85	1	0	h-win	yes
2062	1326528	2025-07-13	USA	Major League Soccer	Philadelphia Union	New York Red Bulls	h-win	2	0	17	5	8	1	8	5	2	1	2	2	0	0	52.00	48.00	13	11	\N	\N	\N	\N	\N	2025-11-20 10:20:03.884719	2.53	0.60	2	0	h-win	yes
2063	1326529	2025-07-13	USA	Major League Soccer	Toronto FC	Atlanta United FC	draw	1	1	13	5	10	3	3	3	0	2	5	1	0	0	37.00	63.00	14	9	\N	\N	\N	\N	\N	2025-11-20 10:20:04.078027	0.72	1.32	0	0	draw	yes
2064	1326525	2025-07-13	USA	Major League Soccer	FC Cincinnati	Columbus Crew	a-win	2	4	13	4	11	4	5	4	1	1	4	4	0	0	50.00	50.00	9	16	\N	\N	\N	\N	\N	2025-11-20 10:20:04.270903	0.64	1.10	2	2	draw	yes
2065	1326524	2025-07-13	USA	Major League Soccer	Charlotte	New York City FC	h-win	2	0	7	3	16	4	3	2	1	1	3	3	0	0	39.00	61.00	8	9	\N	\N	\N	\N	\N	2025-11-20 10:20:04.474552	1.39	1.44	1	0	h-win	yes
2066	1326526	2025-07-13	USA	Major League Soccer	Inter Miami	Nashville SC	h-win	2	1	9	5	8	2	0	4	2	4	2	2	0	0	53.00	47.00	11	14	\N	\N	\N	\N	\N	2025-11-20 10:20:04.662562	1.03	0.62	1	0	h-win	yes
2067	1326730	2025-07-13	USA	Major League Soccer	Chicago Fire	San Diego	a-win	1	2	18	4	7	4	7	0	0	0	2	2	0	0	43.00	57.00	17	11	\N	\N	\N	\N	1	2025-11-20 10:20:04.856524	1.90	1.15	0	2	a-win	yes
2068	1326531	2025-07-13	USA	Major League Soccer	Sporting Kansas City	Seattle Sounders	a-win	2	3	23	9	13	7	7	4	0	1	2	4	0	1	48.00	52.00	16	16	\N	\N	\N	15	5	2025-11-20 10:20:05.072723	3.43	2.32	0	3	a-win	yes
2069	1326532	2025-07-13	USA	Major League Soccer	Minnesota United FC	San Jose Earthquakes	h-win	4	1	12	6	10	4	5	8	1	1	0	5	0	0	36.00	64.00	18	13	\N	\N	\N	4	10	2025-11-20 10:20:05.282865	2.83	1.20	3	0	h-win	yes
2070	1326530	2025-07-13	USA	Major League Soccer	Austin	New England Revolution	draw	0	0	19	4	14	8	7	7	1	2	1	3	0	0	57.00	43.00	11	7	\N	\N	\N	6	\N	2025-11-20 10:20:05.489812	1.93	1.65	0	0	draw	yes
2071	1326534	2025-07-13	USA	Major League Soccer	Real Salt Lake	Houston Dynamo	h-win	1	0	17	5	19	4	5	4	1	2	3	2	0	0	41.00	59.00	15	8	\N	\N	\N	9	12	2025-11-20 10:20:05.663454	1.37	1.56	1	0	h-win	yes
2072	1326533	2025-07-13	USA	Major League Soccer	Colorado Rapids	Vancouver Whitecaps	h-win	3	0	16	7	14	2	7	10	3	1	2	1	0	0	41.00	59.00	8	16	\N	\N	\N	11	2	2025-11-20 10:20:05.826362	2.52	1.20	2	0	h-win	yes
2073	1326535	2025-07-13	USA	Major League Soccer	Los Angeles Galaxy	DC United	h-win	2	1	14	5	11	3	2	5	2	1	3	5	0	0	58.00	42.00	5	14	\N	\N	\N	14	\N	2025-11-20 10:20:06.022003	1.52	1.55	1	0	h-win	yes
2074	1326536	2025-07-13	USA	Major League Soccer	Los Angeles FC	FC Dallas	h-win	2	0	16	10	10	1	8	3	0	0	0	2	0	0	64.00	36.00	10	13	\N	\N	\N	3	7	2025-11-20 10:20:06.211669	2.26	0.86	2	0	h-win	yes
2316	1451202	2025-10-23	World	UEFA Europa League	Red Bull Salzburg	Ferencvarosi TC	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	28	3	2025-11-20 11:02:23.033239	\N	\N	1	0	h-win	yes
2075	1326537	2025-07-14	USA	Major League Soccer	St. Louis City	Portland Timbers	h-win	2	1	20	9	10	4	4	3	3	0	2	4	0	0	53.00	47.00	10	9	\N	\N	\N	13	8	2025-11-20 10:20:06.403697	2.08	1.15	0	1	a-win	yes
2076	1326543	2025-07-17	USA	Major League Soccer	Philadelphia Union	CF Montreal	h-win	2	1	17	6	11	4	9	4	0	2	2	2	0	0	59.00	41.00	17	8	\N	\N	\N	\N	\N	2025-11-20 10:20:06.584325	1.58	1.53	1	1	draw	yes
2077	1326541	2025-07-17	USA	Major League Soccer	New York Red Bulls	New England Revolution	h-win	5	3	21	8	13	6	3	4	0	0	2	4	0	0	58.00	42.00	17	13	\N	\N	\N	\N	\N	2025-11-20 10:20:06.774001	3.56	2.29	0	2	a-win	yes
2078	1326538	2025-07-17	USA	Major League Soccer	Atlanta United FC	Chicago Fire	draw	2	2	10	4	14	8	3	4	2	1	2	2	0	0	52.00	48.00	11	6	\N	\N	\N	\N	\N	2025-11-20 10:20:06.993403	1.30	2.17	0	1	a-win	yes
2079	1326540	2025-07-17	USA	Major League Soccer	FC Cincinnati	Inter Miami	h-win	3	0	11	6	10	2	1	4	0	2	1	0	0	0	44.00	56.00	6	9	\N	\N	\N	\N	\N	2025-11-20 10:20:07.154558	1.33	0.95	1	0	h-win	yes
2080	1326539	2025-07-17	USA	Major League Soccer	Charlotte	DC United	h-win	2	1	17	7	11	1	9	4	1	1	0	1	0	0	58.00	42.00	7	10	\N	\N	\N	\N	\N	2025-11-20 10:20:07.359945	2.59	0.45	1	0	h-win	yes
2081	1326542	2025-07-17	USA	Major League Soccer	Orlando City SC	New York City FC	a-win	1	2	26	7	11	4	9	4	3	1	1	2	0	0	46.00	54.00	11	10	\N	\N	\N	\N	\N	2025-11-20 10:20:07.544108	2.65	1.49	1	0	h-win	yes
2082	1326544	2025-07-17	USA	Major League Soccer	Houston Dynamo	Vancouver Whitecaps	a-win	0	3	11	2	12	7	6	1	0	1	5	4	0	0	59.00	41.00	19	10	\N	\N	\N	12	2	2025-11-20 10:20:07.736674	0.66	1.99	0	2	a-win	yes
2083	1326545	2025-07-17	USA	Major League Soccer	Minnesota United FC	Los Angeles FC	a-win	0	1	10	3	7	6	10	3	2	1	4	3	0	0	55.00	45.00	12	11	\N	\N	\N	4	3	2025-11-20 10:20:07.887958	0.45	2.03	0	1	a-win	yes
2084	1326546	2025-07-17	USA	Major League Soccer	Nashville SC	Columbus Crew	h-win	3	0	10	4	21	4	1	5	1	1	1	2	0	0	37.00	63.00	13	3	\N	\N	\N	\N	\N	2025-11-20 10:20:08.056912	2.48	1.23	2	0	h-win	yes
2085	1326547	2025-07-17	USA	Major League Soccer	Seattle Sounders	Colorado Rapids	draw	3	3	16	8	13	9	3	7	1	0	4	5	0	0	55.00	45.00	8	11	\N	\N	\N	5	11	2025-11-20 10:20:08.209273	1.90	2.47	2	0	h-win	yes
2086	1326550	2025-07-17	USA	Major League Soccer	San Jose Earthquakes	FC Dallas	draw	2	2	13	3	13	5	4	4	1	6	5	0	0	0	63.00	37.00	19	18	\N	\N	\N	10	7	2025-11-20 10:20:08.37673	1.23	2.64	1	1	draw	yes
2087	1326548	2025-07-17	USA	Major League Soccer	Los Angeles Galaxy	Austin	a-win	1	2	16	4	7	5	8	2	1	1	2	4	0	0	58.00	42.00	12	17	\N	\N	\N	14	6	2025-11-20 10:20:08.559835	2.02	1.36	0	1	a-win	yes
2088	1326549	2025-07-17	USA	Major League Soccer	Portland Timbers	Real Salt Lake	a-win	0	1	12	1	10	4	9	2	1	4	1	4	0	0	44.00	56.00	9	10	\N	\N	\N	8	9	2025-11-20 10:20:08.742879	0.95	0.86	0	0	draw	yes
2089	1326731	2025-07-17	USA	Major League Soccer	San Diego	Toronto FC	a-win	0	1	7	1	4	2	4	1	4	0	5	3	0	0	70.00	30.00	15	13	\N	\N	\N	1	\N	2025-11-20 10:20:08.938377	0.43	0.98	0	1	a-win	yes
2090	1326555	2025-07-20	USA	Major League Soccer	New York Red Bulls	Inter Miami	a-win	1	5	8	2	13	8	2	4	3	1	2	3	0	0	37.00	63.00	15	8	\N	\N	\N	\N	\N	2025-11-20 10:20:09.135759	0.76	3.07	1	3	a-win	yes
2091	1326551	2025-07-20	USA	Major League Soccer	Atlanta United FC	Charlotte	a-win	2	3	19	6	8	4	7	2	1	0	1	1	0	0	54.00	46.00	9	14	\N	\N	\N	\N	\N	2025-11-20 10:20:09.32944	1.54	1.46	1	0	h-win	yes
2092	1326554	2025-07-20	USA	Major League Soccer	New England Revolution	Orlando City SC	a-win	1	2	14	3	16	5	9	6	2	1	2	2	0	0	62.00	38.00	18	13	\N	\N	\N	\N	\N	2025-11-20 10:20:09.552725	1.17	1.74	0	1	a-win	yes
2093	1326552	2025-07-20	USA	Major League Soccer	Columbus Crew	DC United	h-win	2	1	18	5	6	1	7	0	1	1	1	2	0	1	64.00	36.00	6	14	\N	\N	\N	\N	\N	2025-11-20 10:20:09.79511	2.45	0.45	1	0	h-win	yes
2094	1326553	2025-07-20	USA	Major League Soccer	CF Montreal	Chicago Fire	a-win	0	2	17	4	10	4	5	3	4	0	5	3	0	0	51.00	49.00	16	13	\N	\N	\N	\N	\N	2025-11-20 10:20:09.999998	0.84	1.40	0	1	a-win	yes
2095	1326560	2025-07-20	USA	Major League Soccer	Seattle Sounders	San Jose Earthquakes	h-win	3	2	19	9	20	9	5	2	1	1	1	3	0	0	53.00	47.00	10	8	\N	\N	\N	5	10	2025-11-20 10:20:10.185771	2.25	2.21	1	1	draw	yes
2096	1326556	2025-07-20	USA	Major League Soccer	FC Dallas	St. Louis City	h-win	3	0	16	10	16	2	2	4	0	3	2	0	0	0	34.00	66.00	10	12	\N	\N	\N	7	13	2025-11-20 10:20:10.427866	2.13	0.67	1	0	h-win	yes
2097	1326557	2025-07-20	USA	Major League Soccer	Houston Dynamo	Philadelphia Union	draw	1	1	11	3	12	2	2	4	1	0	3	4	0	1	60.00	40.00	19	25	\N	\N	\N	12	\N	2025-11-20 10:20:10.621186	1.74	1.39	1	1	draw	yes
2098	1326558	2025-07-20	USA	Major League Soccer	Sporting Kansas City	New York City FC	draw	1	1	11	5	17	6	7	4	1	3	2	0	0	0	40.00	60.00	11	8	\N	\N	\N	15	\N	2025-11-20 10:20:10.844528	1.05	1.60	0	1	a-win	yes
2099	1326559	2025-07-20	USA	Major League Soccer	Nashville SC	Toronto FC	h-win	1	0	10	5	7	0	6	2	4	1	3	2	0	0	51.00	49.00	14	8	\N	\N	\N	\N	\N	2025-11-20 10:20:11.010466	2.03	0.46	1	0	h-win	yes
2100	1326561	2025-07-20	USA	Major League Soccer	Real Salt Lake	FC Cincinnati	a-win	0	1	17	7	14	4	3	5	1	0	2	4	0	0	57.00	43.00	11	14	\N	\N	\N	9	\N	2025-11-20 10:20:11.204084	0.95	0.54	0	0	draw	yes
2101	1326562	2025-07-20	USA	Major League Soccer	Los Angeles FC	Los Angeles Galaxy	draw	3	3	8	4	11	6	4	3	0	2	3	4	1	0	35.00	65.00	9	10	\N	\N	\N	3	14	2025-11-20 10:20:11.377892	1.41	1.88	2	1	h-win	yes
2102	1326563	2025-07-20	USA	Major League Soccer	Portland Timbers	Minnesota United FC	draw	1	1	14	4	16	4	6	3	0	1	1	3	0	0	64.00	36.00	13	15	\N	\N	\N	8	4	2025-11-20 10:20:11.591044	1.68	0.63	0	0	draw	yes
2103	1326732	2025-07-20	USA	Major League Soccer	San Diego	Vancouver Whitecaps	draw	1	1	17	6	8	3	10	2	5	4	1	4	0	0	62.00	38.00	2	20	\N	\N	\N	1	2	2025-11-20 10:20:11.772975	1.10	1.83	0	1	a-win	yes
2104	1485163	2025-07-24	USA	Major League Soccer	MLS All-Stars	Liga MX All-Stars	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 10:20:11.942488	\N	\N	1	0	h-win	yes
2105	1326565	2025-07-26	USA	Major League Soccer	New England Revolution	CF Montreal	a-win	1	3	19	4	11	5	3	3	2	0	5	2	0	0	62.00	38.00	10	10	\N	\N	\N	\N	\N	2025-11-20 10:20:12.131493	1.37	1.00	1	2	a-win	yes
2106	1326564	2025-07-26	USA	Major League Soccer	Columbus Crew	Orlando City SC	a-win	1	3	19	8	10	6	9	1	4	2	2	1	0	0	65.00	35.00	12	7	\N	\N	\N	\N	\N	2025-11-20 10:20:12.323032	2.22	2.53	0	0	draw	yes
2107	1326566	2025-07-26	USA	Major League Soccer	FC Dallas	New York City FC	a-win	3	4	10	6	9	5	2	2	2	2	2	2	0	0	41.00	59.00	15	11	\N	\N	\N	7	\N	2025-11-20 10:20:12.525152	1.65	1.28	3	2	h-win	yes
2108	1326568	2025-07-26	USA	Major League Soccer	Los Angeles FC	Portland Timbers	a-win	0	1	12	3	8	4	4	4	0	1	1	1	0	0	56.00	44.00	6	10	\N	\N	\N	3	8	2025-11-20 10:20:12.693597	1.10	0.38	0	1	a-win	yes
2109	1326733	2025-07-26	USA	Major League Soccer	San Diego	Nashville SC	h-win	1	0	9	3	8	4	2	2	0	0	2	3	0	0	59.00	41.00	12	19	\N	\N	\N	1	\N	2025-11-20 10:20:12.881678	1.47	0.45	0	0	draw	yes
2110	1326569	2025-07-27	USA	Major League Soccer	Inter Miami	FC Cincinnati	draw	0	0	13	3	8	4	5	2	2	1	4	0	0	0	56.00	44.00	14	4	\N	\N	\N	\N	\N	2025-11-20 10:20:13.065595	1.40	1.02	0	0	draw	yes
2111	1326573	2025-07-27	USA	Major League Soccer	Philadelphia Union	Colorado Rapids	h-win	3	1	27	11	5	1	11	1	1	3	1	3	0	0	61.00	39.00	14	9	\N	\N	\N	\N	11	2025-11-20 10:20:13.252202	4.00	0.58	0	1	a-win	yes
2112	1326570	2025-07-27	USA	Major League Soccer	Atlanta United FC	Seattle Sounders	draw	2	2	13	2	8	2	3	4	2	0	2	2	0	0	46.00	54.00	13	11	\N	\N	\N	\N	5	2025-11-20 10:20:13.43527	0.69	0.77	1	0	h-win	yes
2113	1326572	2025-07-27	USA	Major League Soccer	DC United	Austin	a-win	2	4	14	6	15	6	3	6	1	3	2	1	0	0	46.00	54.00	10	12	\N	\N	\N	\N	6	2025-11-20 10:20:13.621585	1.77	1.91	0	2	a-win	yes
2114	1326571	2025-07-27	USA	Major League Soccer	Charlotte	Toronto FC	h-win	2	0	10	4	13	3	2	4	0	0	1	1	0	0	43.00	57.00	16	6	\N	\N	\N	\N	\N	2025-11-20 10:20:13.825657	2.23	0.77	0	0	draw	yes
2115	1326574	2025-07-27	USA	Major League Soccer	Chicago Fire	New York Red Bulls	h-win	1	0	14	7	10	3	3	1	1	3	0	2	0	0	51.00	49.00	5	11	\N	\N	\N	\N	\N	2025-11-20 10:20:14.003923	2.17	0.38	1	0	h-win	yes
2116	1326575	2025-07-27	USA	Major League Soccer	St. Louis City	Minnesota United FC	a-win	1	2	14	5	8	4	10	0	2	2	1	1	1	0	51.00	49.00	13	12	\N	\N	\N	13	4	2025-11-20 10:20:14.18485	1.70	1.90	1	0	h-win	yes
2117	1326576	2025-07-27	USA	Major League Soccer	Real Salt Lake	San Jose Earthquakes	h-win	2	1	11	3	9	3	4	3	4	1	5	5	0	1	60.00	40.00	13	12	\N	\N	\N	9	10	2025-11-20 10:20:14.391339	1.16	1.30	0	0	draw	yes
2118	1326577	2025-07-27	USA	Major League Soccer	Vancouver Whitecaps	Sporting Kansas City	h-win	3	0	21	5	11	3	9	4	5	0	1	2	0	0	54.00	46.00	17	11	\N	\N	\N	2	15	2025-11-20 10:20:14.588678	2.58	1.54	2	0	h-win	yes
2119	1421137	2025-08-05	World	UEFA Champions League	Malmo FF	FC Copenhagen	draw	0	0	4	0	10	1	0	7	1	1	1	2	0	0	51.00	49.00	7	16	\N	\N	\N	\N	33	2025-11-20 11:01:52.869742	\N	\N	0	0	draw	yes
2120	1421138	2025-08-05	World	UEFA Champions League	Dynamo Kyiv	Pafos	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	20	2025-11-20 11:01:53.075606	\N	\N	0	0	draw	yes
2121	1421139	2025-08-05	World	UEFA Champions League	Shkendija	Qarabag	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	15	2025-11-20 11:01:53.278322	\N	\N	0	1	a-win	yes
2122	1421140	2025-08-05	World	UEFA Champions League	Rangers	Plzen	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 11:01:53.478007	\N	\N	2	0	h-win	yes
2123	1419568	2025-08-06	World	UEFA Champions League	Kairat Almaty	Slovan Bratislava	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	34	\N	2025-11-20 11:01:53.678559	\N	\N	0	0	draw	yes
2124	1421141	2025-08-06	World	UEFA Champions League	Red Bull Salzburg	Club Brugge KV	a-win	0	1	20	5	12	5	6	6	1	1	1	1	0	0	46.00	54.00	6	3	\N	\N	\N	\N	22	2025-11-20 11:01:53.892708	\N	\N	0	0	draw	yes
2125	1421142	2025-08-06	World	UEFA Champions League	Ludogorets	Ferencvarosi TC	draw	0	0	10	0	17	2	2	9	1	3	1	3	0	0	41.00	59.00	12	14	\N	\N	\N	\N	\N	2025-11-20 11:01:54.08991	\N	\N	0	0	draw	yes
2126	1421143	2025-08-06	World	UEFA Champions League	Lech Poznan	FK Crvena Zvezda	a-win	1	3	11	4	12	6	4	4	1	3	1	1	0	0	59.00	41.00	13	11	\N	\N	\N	\N	\N	2025-11-20 11:01:54.284401	\N	\N	1	1	draw	yes
2127	1414143	2025-08-06	World	UEFA Champions League	Nice	Benfica	a-win	0	2	12	2	14	6	4	5	1	3	3	1	0	0	47.00	53.00	9	14	\N	\N	\N	\N	35	2025-11-20 11:01:54.489913	\N	\N	0	0	draw	yes
2128	1414142	2025-08-06	World	UEFA Champions League	Feyenoord	Fenerbahce	h-win	2	1	13	3	8	2	3	5	0	4	2	0	0	0	44.00	56.00	16	15	\N	\N	\N	\N	\N	2025-11-20 11:01:54.67658	\N	\N	1	0	h-win	yes
2129	1421144	2025-08-12	World	UEFA Champions League	Qarabag	Shkendija	h-win	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	15	\N	2025-11-20 11:01:54.880328	\N	\N	4	1	h-win	yes
2130	1421148	2025-08-12	World	UEFA Champions League	FC Copenhagen	Malmo FF	h-win	5	0	12	8	7	3	2	1	3	1	0	2	0	0	53.00	47.00	15	6	\N	\N	\N	33	\N	2025-11-20 11:01:55.08979	\N	\N	2	0	h-win	yes
2131	1421146	2025-08-12	World	UEFA Champions League	Plzen	Rangers	h-win	2	1	27	10	9	2	6	3	2	0	1	2	0	0	41.00	59.00	15	11	\N	\N	\N	\N	\N	2025-11-20 11:01:55.317914	\N	\N	1	0	h-win	yes
2132	1414144	2025-08-12	World	UEFA Champions League	Fenerbahce	Feyenoord	h-win	5	2	14	8	16	8	5	7	1	0	2	2	0	0	47.00	53.00	18	14	\N	\N	\N	\N	\N	2025-11-20 11:01:55.513016	\N	\N	2	1	h-win	yes
2133	1421145	2025-08-12	World	UEFA Champions League	Pafos	Dynamo Kyiv	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	20	\N	2025-11-20 11:01:55.711908	\N	\N	1	0	h-win	yes
2134	1421147	2025-08-12	World	UEFA Champions League	Club Brugge KV	Red Bull Salzburg	h-win	3	2	23	9	12	3	8	3	1	1	1	0	0	0	55.00	45.00	7	4	\N	\N	\N	22	\N	2025-11-20 11:01:55.910205	\N	\N	0	2	a-win	yes
2135	1421149	2025-08-12	World	UEFA Champions League	Ferencvarosi TC	Ludogorets	h-win	3	0	15	6	11	4	5	4	0	1	3	4	0	0	41.00	59.00	15	14	\N	\N	\N	\N	\N	2025-11-20 11:01:56.127132	\N	\N	1	0	h-win	yes
2136	1419569	2025-08-12	World	UEFA Champions League	Slovan Bratislava	Kairat Almaty	h-win	1	0	16	2	14	6	6	5	1	3	7	4	0	0	55.00	45.00	29	23	\N	\N	\N	\N	34	2025-11-20 11:01:56.316305	\N	\N	1	0	h-win	yes
2137	1414145	2025-08-12	World	UEFA Champions League	Benfica	Nice	h-win	2	0	21	5	9	0	6	6	2	2	1	2	0	0	58.00	42.00	9	13	\N	\N	\N	35	\N	2025-11-20 11:01:56.484649	\N	\N	2	0	h-win	yes
2138	1421150	2025-08-12	World	UEFA Champions League	FK Crvena Zvezda	Lech Poznan	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 11:01:56.680128	\N	\N	1	0	h-win	yes
2139	1435547	2025-08-19	World	UEFA Champions League	Rangers	Club Brugge KV	a-win	1	3	15	1	10	7	9	9	0	2	3	1	0	0	53.00	47.00	11	9	\N	\N	\N	\N	22	2025-11-20 11:01:56.864592	\N	\N	0	3	a-win	yes
2140	1435546	2025-08-19	World	UEFA Champions League	FK Crvena Zvezda	Pafos	a-win	1	2	25	6	14	3	13	4	0	0	1	1	0	0	57.00	43.00	9	17	\N	\N	\N	\N	20	2025-11-20 11:01:57.06664	\N	\N	0	1	a-win	yes
2141	1435545	2025-08-19	World	UEFA Champions League	Ferencvarosi TC	Qarabag	a-win	1	3	12	4	11	4	4	3	0	2	2	1	0	0	44.00	56.00	20	8	\N	\N	\N	\N	15	2025-11-20 11:01:57.262981	\N	\N	1	0	h-win	yes
2142	1435549	2025-08-20	World	UEFA Champions League	Celtic	Kairat Almaty	draw	0	0	11	3	8	0	15	3	0	3	2	3	0	0	75.00	25.00	12	9	\N	\N	\N	\N	34	2025-11-20 11:01:57.454202	\N	\N	0	0	draw	yes
2143	1424397	2025-08-20	World	UEFA Champions League	Bodo/Glimt	Sturm Graz	h-win	5	0	17	6	8	1	5	1	2	0	1	2	0	0	58.00	42.00	12	12	\N	\N	\N	29	\N	2025-11-20 11:01:57.646104	\N	\N	3	0	h-win	yes
2144	1435548	2025-08-20	World	UEFA Champions League	FC Basel 1893	FC Copenhagen	draw	1	1	11	6	11	4	2	3	0	2	5	3	1	0	46.00	54.00	11	12	\N	\N	\N	\N	33	2025-11-20 11:01:57.831521	\N	\N	1	1	draw	yes
2145	1435550	2025-08-20	World	UEFA Champions League	Fenerbahce	Benfica	draw	0	0	13	6	9	3	4	4	2	0	3	5	0	1	54.00	46.00	16	18	\N	\N	\N	\N	35	2025-11-20 11:01:58.02703	\N	\N	0	0	draw	yes
2146	1435551	2025-08-26	World	UEFA Champions League	Kairat Almaty	Celtic	draw	0	0	12	4	11	5	5	7	3	0	0	1	0	0	33.00	67.00	12	19	\N	\N	\N	34	\N	2025-11-20 11:01:58.226838	\N	\N	0	0	draw	yes
2147	1424398	2025-08-26	World	UEFA Champions League	Sturm Graz	Bodo/Glimt	h-win	2	1	18	8	10	5	3	8	3	1	2	1	0	0	51.00	49.00	12	13	\N	\N	\N	\N	29	2025-11-20 11:01:58.419444	\N	\N	1	1	draw	yes
2311	1451203	2025-10-23	World	UEFA Europa League	Lyon	FC Basel 1893	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7	17	2025-11-20 11:02:22.996357	\N	\N	1	0	h-win	yes
2148	1435552	2025-08-26	World	UEFA Champions League	Pafos	FK Crvena Zvezda	draw	1	1	11	5	12	3	3	3	1	3	3	3	0	0	50.00	50.00	17	17	\N	\N	\N	20	\N	2025-11-20 11:01:58.61108	\N	\N	0	0	draw	yes
2149	1435553	2025-08-27	World	UEFA Champions League	Qarabag	Ferencvarosi TC	a-win	2	3	10	2	17	6	1	2	3	1	3	3	0	0	41.00	59.00	14	21	\N	\N	\N	15	\N	2025-11-20 11:01:58.803283	\N	\N	2	1	h-win	yes
2150	1435556	2025-08-27	World	UEFA Champions League	Benfica	Fenerbahce	h-win	1	0	15	3	6	0	4	1	4	4	2	4	0	1	53.00	47.00	11	20	\N	\N	\N	35	\N	2025-11-20 11:01:58.999222	\N	\N	1	0	h-win	yes
2151	1435554	2025-08-27	World	UEFA Champions League	FC Copenhagen	FC Basel 1893	h-win	2	0	11	7	20	5	3	6	1	3	1	0	0	0	43.00	57.00	25	15	\N	\N	\N	33	\N	2025-11-20 11:01:59.177603	\N	\N	0	0	draw	yes
2152	1435555	2025-08-27	World	UEFA Champions League	Club Brugge KV	Rangers	h-win	6	0	32	16	3	1	10	1	0	0	1	1	0	1	72.00	28.00	4	6	\N	\N	\N	22	\N	2025-11-20 11:01:59.367168	\N	\N	5	0	h-win	yes
2153	1451020	2025-09-16	World	UEFA Champions League	PSV Eindhoven	Union St. Gilloise	a-win	1	3	10	3	18	8	7	7	0	8	0	0	0	0	63.00	37.00	9	9	\N	\N	\N	18	28	2025-11-20 11:01:59.551313	2.52	3.34	0	2	a-win	yes
2154	1451021	2025-09-16	World	UEFA Champions League	Athletic Club	Arsenal	a-win	0	2	11	2	11	6	2	2	0	2	1	3	0	0	38.00	62.00	18	15	\N	\N	\N	27	2	2025-11-20 11:01:59.756768	0.35	1.28	0	0	draw	yes
2155	1451023	2025-09-16	World	UEFA Champions League	Tottenham	Villarreal	h-win	1	0	9	1	10	0	3	3	1	1	4	3	0	0	58.00	42.00	14	13	\N	\N	\N	10	32	2025-11-20 11:02:00.016464	0.54	0.48	1	0	h-win	yes
2156	1451025	2025-09-16	World	UEFA Champions League	Benfica	Qarabag	a-win	2	3	14	3	10	5	8	3	1	1	0	0	0	0	53.00	47.00	11	6	\N	\N	\N	35	15	2025-11-20 11:02:00.202564	1.38	1.52	2	1	h-win	yes
2157	1451022	2025-09-16	World	UEFA Champions League	Juventus	Borussia Dortmund	draw	4	4	19	7	10	5	4	2	4	0	0	1	0	0	52.00	48.00	13	8	\N	\N	\N	26	14	2025-11-20 11:02:00.388637	1.92	1.71	0	0	draw	yes
2158	1451024	2025-09-16	World	UEFA Champions League	Real Madrid	Marseille	h-win	2	1	28	15	15	5	9	4	1	3	3	2	1	0	43.00	57.00	9	14	\N	\N	\N	7	25	2025-11-20 11:02:00.580353	3.65	0.73	1	1	draw	yes
2159	1451026	2025-09-17	World	UEFA Champions League	Olympiakos Piraeus	Pafos	draw	0	0	18	3	6	1	9	0	2	1	3	3	0	1	69.00	31.00	15	14	\N	\N	\N	31	20	2025-11-20 11:02:00.78547	1.52	0.30	0	0	draw	yes
2160	1451027	2025-09-17	World	UEFA Champions League	Slavia Praha	Bodo/Glimt	draw	2	2	26	11	11	10	8	4	5	0	2	3	0	0	46.00	54.00	13	11	\N	\N	\N	30	29	2025-11-20 11:02:00.971645	3.98	2.52	1	0	h-win	yes
2161	1451030	2025-09-17	World	UEFA Champions League	Liverpool	Atletico Madrid	h-win	3	2	20	6	10	4	7	6	1	2	1	2	0	0	56.00	44.00	7	9	\N	\N	\N	8	17	2025-11-20 11:02:01.175268	2.60	0.61	2	1	h-win	yes
2162	1451029	2025-09-17	World	UEFA Champions League	Paris Saint Germain	Atalanta	h-win	4	0	22	13	7	2	6	1	3	2	0	1	0	0	67.00	33.00	5	11	\N	\N	\N	5	16	2025-11-20 11:02:01.369292	3.48	0.55	2	0	h-win	yes
2163	1451031	2025-09-17	World	UEFA Champions League	Bayern München	Chelsea	h-win	3	1	16	5	9	3	6	2	4	3	3	1	0	0	56.00	44.00	12	7	\N	\N	\N	1	12	2025-11-20 11:02:01.567879	2.07	0.73	2	1	h-win	yes
2164	1451028	2025-09-17	World	UEFA Champions League	Ajax	Inter	a-win	0	2	7	2	14	4	3	5	2	1	1	2	0	0	56.00	44.00	15	17	\N	\N	\N	36	3	2025-11-20 11:02:01.770271	1.26	1.24	0	1	a-win	yes
2165	1451033	2025-09-18	World	UEFA Champions League	FC Copenhagen	Bayer Leverkusen	draw	2	2	12	7	15	4	4	5	0	0	3	2	0	0	36.00	64.00	14	13	\N	\N	\N	33	21	2025-11-20 11:02:02.012391	1.89	1.21	1	0	h-win	yes
2166	1451032	2025-09-18	World	UEFA Champions League	Club Brugge KV	Monaco	h-win	4	1	26	10	13	5	4	5	0	1	2	2	0	0	49.00	51.00	11	9	\N	\N	\N	22	19	2025-11-20 11:02:02.2118	3.15	1.45	3	0	h-win	yes
2167	1451036	2025-09-18	World	UEFA Champions League	Newcastle	Barcelona	a-win	1	2	10	6	19	5	6	4	3	0	2	4	0	0	36.00	64.00	11	12	\N	\N	\N	6	11	2025-11-20 11:02:02.40242	1.46	1.31	0	0	draw	yes
2168	1451037	2025-09-18	World	UEFA Champions League	Manchester City	Napoli	h-win	2	0	23	8	1	1	9	2	1	1	0	1	0	1	74.00	26.00	3	4	\N	\N	\N	4	24	2025-11-20 11:02:02.599448	2.18	0.17	0	0	draw	yes
2169	1451034	2025-09-18	World	UEFA Champions League	Eintracht Frankfurt	Galatasaray	h-win	5	1	11	5	14	5	4	3	1	0	1	0	0	0	38.00	62.00	10	13	\N	\N	\N	23	9	2025-11-20 11:02:02.803578	1.21	1.09	3	1	h-win	yes
2170	1451035	2025-09-18	World	UEFA Champions League	Sporting CP	Kairat Almaty	h-win	4	1	21	8	9	4	8	3	0	1	4	2	0	0	64.00	36.00	14	11	\N	\N	\N	13	34	2025-11-20 11:02:03.017907	4.25	0.70	1	0	h-win	yes
2171	1451039	2025-09-30	World	UEFA Champions League	Atalanta	Club Brugge KV	h-win	2	1	20	3	7	2	7	1	1	0	2	0	0	0	48.00	52.00	8	10	\N	\N	\N	16	22	2025-11-20 11:02:03.21316	2.96	0.86	0	1	a-win	yes
2172	1451038	2025-09-30	World	UEFA Champions League	Kairat Almaty	Real Madrid	a-win	0	5	11	4	20	12	3	6	1	0	2	0	0	0	33.00	67.00	6	9	\N	\N	\N	34	7	2025-11-20 11:02:03.382304	0.43	3.54	0	1	a-win	yes
2173	1451042	2025-09-30	World	UEFA Champions League	Chelsea	Benfica	h-win	1	0	8	3	9	3	3	5	1	2	4	5	1	0	56.00	44.00	13	14	\N	\N	\N	12	35	2025-11-20 11:02:03.561931	0.93	0.85	1	0	h-win	yes
2174	1451041	2025-09-30	World	UEFA Champions League	Marseille	Ajax	h-win	4	0	9	6	13	2	0	7	0	2	2	3	0	0	48.00	52.00	18	12	\N	\N	\N	25	36	2025-11-20 11:02:03.741752	1.13	0.80	3	0	h-win	yes
2175	1451044	2025-09-30	World	UEFA Champions League	Bodo/Glimt	Tottenham	draw	2	2	18	4	8	3	4	5	3	2	2	2	0	0	52.00	48.00	11	7	\N	\N	\N	29	10	2025-11-20 11:02:03.948229	2.52	1.46	0	0	draw	yes
2176	1451043	2025-09-30	World	UEFA Champions League	Inter	Slavia Praha	h-win	3	0	21	6	3	1	5	0	0	0	2	1	0	0	57.00	43.00	13	17	\N	\N	\N	3	30	2025-11-20 11:02:04.155239	3.99	0.11	2	0	h-win	yes
2177	1451040	2025-09-30	World	UEFA Champions League	Atletico Madrid	Eintracht Frankfurt	h-win	5	1	18	12	6	2	5	2	2	0	1	1	0	0	51.00	49.00	11	6	\N	\N	\N	17	23	2025-11-20 11:02:04.324492	4.44	0.59	3	0	h-win	yes
2178	1451046	2025-09-30	World	UEFA Champions League	Galatasaray	Liverpool	h-win	1	0	9	4	16	4	3	7	2	1	5	3	0	0	33.00	67.00	12	14	\N	\N	\N	9	8	2025-11-20 11:02:04.512426	1.34	1.81	1	0	h-win	yes
2179	1451045	2025-09-30	World	UEFA Champions League	Pafos	Bayern München	a-win	1	5	6	2	26	15	2	6	0	0	1	0	0	0	33.00	67.00	11	9	\N	\N	\N	20	1	2025-11-20 11:02:04.704542	0.39	4.54	1	4	a-win	yes
2180	1451047	2025-10-01	World	UEFA Champions League	Qarabag	FC Copenhagen	h-win	2	0	10	6	12	4	4	7	2	4	3	1	0	0	49.00	51.00	10	20	\N	\N	\N	15	33	2025-11-20 11:02:04.927427	1.91	0.98	1	0	h-win	yes
2181	1451048	2025-10-01	World	UEFA Champions League	Union St. Gilloise	Newcastle	a-win	0	4	17	6	13	6	7	5	1	0	4	1	0	0	43.00	57.00	15	8	\N	\N	\N	28	6	2025-11-20 11:02:05.111792	0.88	2.76	0	2	a-win	yes
2182	1451052	2025-10-01	World	UEFA Champions League	Arsenal	Olympiakos Piraeus	h-win	2	0	16	5	10	3	3	5	2	4	3	1	0	0	61.00	39.00	14	17	\N	\N	\N	2	31	2025-11-20 11:02:05.320345	2.90	0.50	1	0	h-win	yes
2183	1451051	2025-10-01	World	UEFA Champions League	Monaco	Manchester City	draw	2	2	8	3	18	6	7	3	0	2	1	5	0	0	29.00	71.00	9	13	\N	\N	\N	19	4	2025-11-20 11:02:05.514434	1.45	1.54	1	2	a-win	yes
2184	1451049	2025-10-01	World	UEFA Champions League	Borussia Dortmund	Athletic Club	h-win	4	1	13	8	6	3	4	0	3	3	1	2	0	0	52.00	48.00	14	15	\N	\N	\N	14	27	2025-11-20 11:02:05.714063	1.18	0.95	1	0	h-win	yes
2185	1451054	2025-10-01	World	UEFA Champions League	Bayer Leverkusen	PSV Eindhoven	draw	1	1	14	4	6	1	7	4	2	2	0	2	0	0	46.00	54.00	8	11	\N	\N	\N	21	18	2025-11-20 11:02:05.903154	1.74	0.49	0	0	draw	yes
2186	1451053	2025-10-01	World	UEFA Champions League	Napoli	Sporting CP	h-win	2	1	12	3	8	4	7	2	1	0	0	0	0	0	51.00	49.00	16	9	\N	\N	\N	24	13	2025-11-20 11:02:06.095744	0.88	1.35	1	0	h-win	yes
2187	1451050	2025-10-01	World	UEFA Champions League	Barcelona	Paris Saint Germain	a-win	1	2	12	3	16	7	4	9	0	2	4	2	0	0	47.00	53.00	12	14	\N	\N	\N	11	5	2025-11-20 11:02:06.279893	1.27	1.67	1	1	draw	yes
2188	1451055	2025-10-01	World	UEFA Champions League	Villarreal	Juventus	draw	2	2	17	6	13	4	4	3	1	1	1	3	0	0	45.00	55.00	7	19	\N	\N	\N	32	26	2025-11-20 11:02:06.462759	1.72	1.60	1	0	h-win	yes
2189	1451057	2025-10-21	World	UEFA Champions League	Barcelona	Olympiakos Piraeus	h-win	6	1	14	7	5	2	7	2	2	1	1	4	0	1	73.00	27.00	7	10	\N	\N	\N	11	31	2025-11-20 11:02:06.654241	2.48	1.00	2	0	h-win	yes
2190	1451056	2025-10-21	World	UEFA Champions League	Kairat Almaty	Pafos	draw	0	0	22	2	9	6	6	4	1	3	3	1	0	1	69.00	31.00	11	9	\N	\N	\N	34	20	2025-11-20 11:02:06.844379	1.26	1.76	0	0	draw	yes
2191	1451064	2025-10-21	World	UEFA Champions League	Newcastle	Benfica	h-win	3	0	19	10	7	2	12	8	2	1	1	1	0	0	52.00	48.00	16	7	\N	\N	\N	6	35	2025-11-20 11:02:07.030578	2.63	0.33	1	0	h-win	yes
2192	1451061	2025-10-21	World	UEFA Champions League	Arsenal	Atletico Madrid	h-win	4	0	19	8	11	1	3	4	2	0	1	2	0	0	52.00	48.00	14	10	\N	\N	\N	2	17	2025-11-20 11:02:07.217627	2.19	0.67	0	0	draw	yes
2193	1451060	2025-10-21	World	UEFA Champions League	Bayer Leverkusen	Paris Saint Germain	a-win	2	7	6	3	24	8	3	4	3	0	2	1	1	1	29.00	71.00	8	6	\N	\N	\N	21	5	2025-11-20 11:02:07.409793	2.50	2.86	1	4	a-win	yes
2194	1451059	2025-10-21	World	UEFA Champions League	PSV Eindhoven	Napoli	h-win	6	2	19	8	10	2	4	8	2	1	4	1	0	1	59.00	41.00	11	9	\N	\N	\N	18	24	2025-11-20 11:02:07.602234	2.89	1.16	2	1	h-win	yes
2195	1451062	2025-10-21	World	UEFA Champions League	FC Copenhagen	Borussia Dortmund	a-win	2	4	11	4	9	5	4	7	0	0	2	1	0	0	36.00	64.00	10	7	\N	\N	\N	33	14	2025-11-20 11:02:07.791343	0.82	1.64	1	1	draw	yes
2196	1451063	2025-10-21	World	UEFA Champions League	Villarreal	Manchester City	a-win	0	2	11	2	10	6	1	3	0	0	4	2	0	0	34.00	66.00	17	15	\N	\N	\N	32	4	2025-11-20 11:02:07.984369	1.28	1.34	0	2	a-win	yes
2197	1451058	2025-10-21	World	UEFA Champions League	Union St. Gilloise	Inter	a-win	0	4	15	6	21	7	3	4	4	0	1	1	0	0	30.00	70.00	15	6	\N	\N	\N	28	3	2025-11-20 11:02:08.168128	0.95	4.54	0	2	a-win	yes
2198	1451066	2025-10-22	World	UEFA Champions League	Athletic Club	Qarabag	h-win	3	1	21	5	9	4	8	3	1	0	0	0	0	0	60.00	40.00	14	5	\N	\N	\N	27	15	2025-11-20 11:02:08.359032	3.47	0.52	1	1	draw	yes
2199	1451065	2025-10-22	World	UEFA Champions League	Galatasaray	Bodo/Glimt	h-win	3	1	23	11	8	2	7	4	3	1	1	1	0	0	38.00	62.00	10	7	\N	\N	\N	9	29	2025-11-20 11:02:08.572396	4.09	1.41	2	0	h-win	yes
2200	1451070	2025-10-22	World	UEFA Champions League	Chelsea	Ajax	h-win	5	1	22	10	2	1	11	0	3	1	2	1	0	1	66.00	34.00	15	6	\N	\N	\N	12	36	2025-11-20 11:02:08.727821	3.65	1.05	4	1	h-win	yes
2201	1451067	2025-10-22	World	UEFA Champions League	Monaco	Tottenham	draw	0	0	23	8	11	2	5	4	1	1	0	1	0	0	56.00	44.00	25	0	\N	\N	\N	19	10	2025-11-20 11:02:08.94033	2.45	0.88	0	0	draw	yes
2202	1451073	2025-10-22	World	UEFA Champions League	Bayern München	Club Brugge KV	h-win	4	0	26	13	5	2	9	1	1	0	1	0	0	0	63.00	37.00	14	3	\N	\N	\N	1	22	2025-11-20 11:02:09.105934	4.20	0.25	3	0	h-win	yes
2203	1451069	2025-10-22	World	UEFA Champions League	Eintracht Frankfurt	Liverpool	a-win	1	5	4	1	18	14	2	10	1	3	2	0	0	0	35.00	65.00	4	5	\N	\N	\N	23	8	2025-11-20 11:02:09.288932	0.23	3.26	1	3	a-win	yes
2204	1451072	2025-10-22	World	UEFA Champions League	Sporting CP	Marseille	h-win	2	1	14	7	10	3	3	1	2	0	2	4	0	1	53.00	47.00	11	16	\N	\N	\N	13	25	2025-11-20 11:02:09.464207	1.11	0.54	0	1	a-win	yes
2205	1451071	2025-10-22	World	UEFA Champions League	Atalanta	Slavia Praha	draw	0	0	22	5	16	4	6	3	5	3	3	2	0	0	56.00	44.00	8	15	\N	\N	\N	16	30	2025-11-20 11:02:09.640291	2.59	0.73	0	0	draw	yes
2206	1451068	2025-10-22	World	UEFA Champions League	Real Madrid	Juventus	h-win	1	0	28	10	13	4	13	7	1	2	1	0	0	0	66.00	34.00	10	18	\N	\N	\N	7	26	2025-11-20 11:02:09.844284	2.69	0.59	0	0	draw	yes
2207	1451074	2025-11-04	World	UEFA Champions League	Napoli	Eintracht Frankfurt	draw	0	0	18	3	7	3	5	3	1	0	2	1	0	0	64.00	36.00	12	10	\N	\N	\N	24	23	2025-11-20 11:02:10.047988	1.85	0.36	0	0	draw	yes
2208	1451075	2025-11-04	World	UEFA Champions League	Slavia Praha	Arsenal	a-win	0	3	9	1	14	8	4	7	5	0	3	4	0	0	43.00	57.00	31	0	\N	\N	\N	30	2	2025-11-20 11:02:10.242927	0.47	1.81	0	1	a-win	yes
2209	1451077	2025-11-04	World	UEFA Champions League	Liverpool	Real Madrid	h-win	1	0	17	9	8	2	4	2	2	0	1	4	0	0	39.00	61.00	16	11	\N	\N	\N	8	7	2025-11-20 11:02:10.434085	2.51	0.45	0	0	draw	yes
2210	1451076	2025-11-04	World	UEFA Champions League	Tottenham	FC Copenhagen	h-win	4	0	14	6	12	4	3	6	1	1	1	3	1	0	61.00	39.00	10	11	\N	\N	\N	10	33	2025-11-20 11:02:10.623412	3.32	0.35	1	0	h-win	yes
2211	1451081	2025-11-04	World	UEFA Champions League	Paris Saint Germain	Bayern München	a-win	1	2	25	9	9	5	9	1	3	3	1	3	0	1	71.00	29.00	7	9	\N	\N	\N	5	1	2025-11-20 11:02:10.815741	1.95	1.53	0	2	a-win	yes
2212	1451080	2025-11-04	World	UEFA Champions League	Bodo/Glimt	Monaco	a-win	0	1	17	4	9	2	4	4	0	0	1	4	1	0	64.00	36.00	14	16	\N	\N	\N	29	19	2025-11-20 11:02:11.000253	1.67	1.29	0	1	a-win	yes
2213	1451082	2025-11-04	World	UEFA Champions League	Juventus	Sporting CP	draw	1	1	18	9	4	1	6	0	0	1	2	3	0	0	50.00	50.00	15	14	\N	\N	\N	26	13	2025-11-20 11:02:11.183834	1.53	0.21	1	1	draw	yes
2214	1451079	2025-11-04	World	UEFA Champions League	Atletico Madrid	Union St. Gilloise	h-win	3	1	14	6	8	3	9	1	1	1	1	3	0	0	67.00	33.00	10	13	\N	\N	\N	17	28	2025-11-20 11:02:11.365413	2.30	1.11	1	0	h-win	yes
2215	1451078	2025-11-04	World	UEFA Champions League	Olympiakos Piraeus	PSV Eindhoven	draw	1	1	18	4	10	2	3	6	1	3	1	1	0	0	40.00	60.00	7	9	\N	\N	\N	31	18	2025-11-20 11:02:11.561663	0.92	0.35	1	0	h-win	yes
2216	1451083	2025-11-05	World	UEFA Champions League	Qarabag	Chelsea	draw	2	2	9	3	16	4	2	8	1	1	2	3	0	0	39.00	61.00	9	19	\N	\N	\N	15	12	2025-11-20 11:02:11.735799	1.63	1.26	2	1	h-win	yes
2312	1451204	2025-10-23	World	UEFA Europa League	SC Braga	FK Crvena Zvezda	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	26	2025-11-20 11:02:23.001954	\N	\N	1	0	h-win	yes
2217	1451084	2025-11-05	World	UEFA Champions League	Pafos	Villarreal	h-win	1	0	5	2	18	5	2	3	1	1	1	2	0	0	41.00	59.00	12	13	\N	\N	\N	20	32	2025-11-20 11:02:11.897418	0.75	1.77	0	0	draw	yes
2218	1451088	2025-11-05	World	UEFA Champions League	Newcastle	Athletic Club	h-win	2	0	8	4	12	5	2	5	3	0	0	2	0	0	59.00	41.00	11	13	\N	\N	\N	6	27	2025-11-20 11:02:12.044857	1.20	0.58	1	0	h-win	yes
2219	1451085	2025-11-05	World	UEFA Champions League	Manchester City	Borussia Dortmund	h-win	4	1	18	11	12	4	4	4	3	0	2	1	0	0	50.00	50.00	11	17	\N	\N	\N	4	14	2025-11-20 11:02:12.21735	1.98	1.02	2	0	h-win	yes
2220	1451091	2025-11-05	World	UEFA Champions League	Marseille	Atalanta	a-win	0	1	15	4	8	3	6	3	3	4	2	3	0	0	53.00	47.00	13	17	\N	\N	\N	25	16	2025-11-20 11:02:12.430508	0.90	1.25	0	0	draw	yes
2221	1451087	2025-11-05	World	UEFA Champions League	Ajax	Galatasaray	a-win	0	3	8	2	14	7	3	2	1	3	4	0	0	0	48.00	52.00	12	15	\N	\N	\N	36	9	2025-11-20 11:02:12.630034	0.90	2.54	0	0	draw	yes
2222	1451089	2025-11-05	World	UEFA Champions League	Benfica	Bayer Leverkusen	a-win	0	1	21	6	7	3	6	0	0	2	2	3	0	0	53.00	47.00	7	9	\N	\N	\N	35	21	2025-11-20 11:02:12.817205	1.62	0.74	0	0	draw	yes
2223	1451090	2025-11-05	World	UEFA Champions League	Inter	Kairat Almaty	h-win	2	1	23	9	7	3	9	3	2	1	1	1	0	0	66.00	34.00	9	16	\N	\N	\N	3	34	2025-11-20 11:02:13.008054	2.38	0.15	1	0	h-win	yes
2224	1451086	2025-11-05	World	UEFA Champions League	Club Brugge KV	Barcelona	draw	3	3	10	6	23	6	0	3	1	1	2	3	0	0	24.00	76.00	11	6	\N	\N	\N	22	11	2025-11-20 11:02:13.190295	2.14	2.40	2	1	h-win	yes
2225	1421215	2025-08-05	World	UEFA Europa League	Hamrun Spartans	Maccabi Tel Aviv	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	3	3	0	0	\N	\N	\N	\N	\N	\N	\N	\N	34	2025-11-20 11:02:14.576215	\N	\N	0	0	draw	yes
2226	1421213	2025-08-06	World	UEFA Europa League	Rīgas FS	KuPS	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	1	0	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 11:02:14.761378	\N	\N	0	2	a-win	yes
2227	1421212	2025-08-06	World	UEFA Europa League	HNK Rijeka	Shelbourne	a-win	1	2	0	7	0	2	6	1	0	1	0	0	0	0	68.00	32.00	7	7	\N	\N	\N	\N	\N	2025-11-20 11:02:14.943692	\N	\N	0	0	draw	yes
2228	1421219	2025-08-07	World	UEFA Europa League	Lincoln Red Imps FC	FC Noah	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	1	7	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 11:02:15.141113	\N	\N	1	1	draw	yes
2229	1421210	2025-08-07	World	UEFA Europa League	Fredrikstad	FC Midtjylland	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	0	1	0	0	\N	\N	\N	\N	\N	\N	\N	\N	1	2025-11-20 11:02:15.328062	\N	\N	0	2	a-win	yes
2230	1421214	2025-08-07	World	UEFA Europa League	AEK Larnaca	Legia Warszawa	h-win	4	1	\N	\N	\N	\N	\N	\N	\N	\N	1	4	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 11:02:15.515499	\N	\N	1	1	draw	yes
2231	1421209	2025-08-07	World	UEFA Europa League	CFR 1907 Cluj	SC Braga	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	2	0	0	0	\N	\N	\N	\N	\N	\N	\N	\N	5	2025-11-20 11:02:15.704198	\N	\N	1	1	draw	yes
2232	1421211	2025-08-07	World	UEFA Europa League	BK Hacken	Brann	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	1	3	0	0	\N	\N	\N	\N	\N	\N	\N	\N	11	2025-11-20 11:02:15.907831	\N	\N	0	1	a-win	yes
2233	1413127	2025-08-07	World	UEFA Europa League	PAOK	Wolfsberger AC	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	4	1	0	0	\N	\N	\N	\N	\N	\N	\N	10	\N	2025-11-20 11:02:16.085563	\N	\N	0	0	draw	yes
2234	1421220	2025-08-07	World	UEFA Europa League	Zrinjski	Breidablik	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	1	0	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 11:02:16.277817	\N	\N	0	1	a-win	yes
2235	1421218	2025-08-07	World	UEFA Europa League	Panathinaikos	Shakhtar Donetsk	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	2	1	0	0	\N	\N	\N	\N	\N	\N	\N	16	\N	2025-11-20 11:02:16.462022	\N	\N	0	0	draw	yes
2236	1421217	2025-08-07	World	UEFA Europa League	FCSB	Drita	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	1	3	0	0	\N	\N	\N	\N	\N	\N	\N	31	\N	2025-11-20 11:02:16.672617	\N	\N	0	1	a-win	yes
2237	1421216	2025-08-07	World	UEFA Europa League	Servette FC	Utrecht	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	2	2	0	0	\N	\N	\N	\N	\N	\N	\N	\N	32	2025-11-20 11:02:16.84891	\N	\N	1	0	h-win	yes
2238	1421222	2025-08-12	World	UEFA Europa League	Shelbourne	HNK Rijeka	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	0	1	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 11:02:17.022937	\N	\N	0	1	a-win	yes
2239	1421228	2025-08-14	World	UEFA Europa League	KuPS	Rīgas FS	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	3	3	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 11:02:17.223308	\N	\N	0	0	draw	yes
2240	1423465	2025-08-14	World	UEFA Europa League	FC Midtjylland	Fredrikstad	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	1	1	0	0	\N	\N	\N	\N	\N	\N	\N	1	\N	2025-11-20 11:02:17.426807	\N	\N	2	0	h-win	yes
2241	1421225	2025-08-14	World	UEFA Europa League	Brann	BK Hacken	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	2	5	0	0	\N	\N	\N	\N	\N	\N	\N	11	\N	2025-11-20 11:02:17.620619	\N	\N	0	1	a-win	yes
2242	1413128	2025-08-14	World	UEFA Europa League	Wolfsberger AC	PAOK	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	5	2	0	0	\N	\N	\N	\N	\N	\N	\N	\N	10	2025-11-20 11:02:17.847953	\N	\N	0	0	draw	yes
2243	1421224	2025-08-14	World	UEFA Europa League	FC Noah	Lincoln Red Imps FC	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	2	3	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 11:02:18.051136	\N	\N	0	0	draw	yes
2244	1421229	2025-08-14	World	UEFA Europa League	Breidablik	Zrinjski	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	4	1	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 11:02:18.328753	\N	\N	0	1	a-win	yes
2245	1421230	2025-08-14	World	UEFA Europa League	Utrecht	Servette FC	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	4	4	0	0	\N	\N	\N	\N	\N	\N	\N	32	\N	2025-11-20 11:02:18.549751	\N	\N	0	0	draw	yes
2246	1421227	2025-08-14	World	UEFA Europa League	Shakhtar Donetsk	Panathinaikos	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	4	6	1	0	\N	\N	\N	\N	\N	\N	\N	\N	16	2025-11-20 11:02:18.766492	\N	\N	0	0	draw	yes
2247	1421226	2025-08-14	World	UEFA Europa League	Maccabi Tel Aviv	Hamrun Spartans	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	1	3	0	0	\N	\N	\N	\N	\N	\N	\N	34	\N	2025-11-20 11:02:18.951025	\N	\N	2	1	h-win	yes
2248	1421221	2025-08-14	World	UEFA Europa League	Drita	FCSB	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	2	2	1	0	\N	\N	\N	\N	\N	\N	\N	\N	31	2025-11-20 11:02:19.146624	\N	\N	0	2	a-win	yes
2249	1421223	2025-08-14	World	UEFA Europa League	SC Braga	CFR 1907 Cluj	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	0	1	0	0	\N	\N	\N	\N	\N	\N	\N	5	\N	2025-11-20 11:02:19.339928	\N	\N	2	0	h-win	yes
2250	1421231	2025-08-14	World	UEFA Europa League	Legia Warszawa	AEK Larnaca	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	4	6	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 11:02:19.558508	\N	\N	2	0	h-win	yes
2251	1437226	2025-08-21	World	UEFA Europa League	FC Midtjylland	KuPS	h-win	4	0	13	9	4	2	4	5	0	1	1	2	0	0	48.00	52.00	11	10	\N	\N	\N	1	\N	2025-11-20 11:02:19.764048	\N	\N	2	0	h-win	yes
2252	1437228	2025-08-21	World	UEFA Europa League	Brann	AEK Larnaca	h-win	2	1	15	10	8	3	6	5	0	0	2	3	0	0	60.00	40.00	16	11	\N	\N	\N	11	\N	2025-11-20 11:02:19.946013	\N	\N	1	1	draw	yes
2253	1437227	2025-08-21	World	UEFA Europa League	Malmo FF	Sigma Olomouc	h-win	3	0	12	4	8	2	9	3	1	4	2	3	0	0	50.00	50.00	11	10	\N	\N	\N	33	\N	2025-11-20 11:02:20.130905	\N	\N	2	0	h-win	yes
2254	1437229	2025-08-21	World	UEFA Europa League	Zrinjski	Utrecht	a-win	0	2	12	3	12	7	6	2	1	0	5	3	1	0	52.00	48.00	10	9	\N	\N	\N	\N	32	2025-11-20 11:02:20.353072	\N	\N	0	1	a-win	yes
2255	1436776	2025-08-21	World	UEFA Europa League	Maccabi Tel Aviv	Dynamo Kyiv	h-win	3	1	21	11	11	3	6	5	2	2	1	4	0	1	63.00	37.00	12	11	\N	\N	\N	34	\N	2025-11-20 11:02:20.549442	\N	\N	1	1	draw	yes
2256	1436778	2025-08-21	World	UEFA Europa League	Shkendija	Ludogorets	h-win	2	1	14	4	14	4	4	2	4	2	2	1	0	0	\N	\N	8	17	\N	\N	\N	\N	30	2025-11-20 11:02:20.748296	\N	\N	1	1	draw	yes
2257	1436779	2025-08-21	World	UEFA Europa League	Panathinaikos	Samsunspor	h-win	2	1	10	5	7	3	8	4	0	4	2	2	0	0	49.00	51.00	10	9	\N	\N	\N	16	\N	2025-11-20 11:02:20.920435	\N	\N	0	0	draw	yes
2258	1436777	2025-08-21	World	UEFA Europa League	Slovan Bratislava	BSC Young Boys	a-win	0	1	6	0	4	2	9	5	3	2	3	2	0	0	48.00	52.00	14	23	\N	\N	\N	\N	22	2025-11-20 11:02:21.084428	\N	\N	0	1	a-win	yes
2259	1436775	2025-08-21	World	UEFA Europa League	Lech Poznan	Genk	a-win	1	5	14	7	19	11	3	5	0	1	1	3	0	0	40.00	60.00	5	5	\N	\N	\N	\N	13	2025-11-20 11:02:21.259948	\N	\N	1	4	a-win	yes
2260	1436774	2025-08-21	World	UEFA Europa League	Aberdeen	FCSB	draw	2	2	29	9	11	6	4	3	1	0	4	2	0	1	49.00	51.00	14	9	\N	\N	\N	\N	31	2025-11-20 11:02:21.460941	\N	\N	0	1	a-win	yes
2261	1436773	2025-08-21	World	UEFA Europa League	HNK Rijeka	PAOK	h-win	1	0	15	7	11	3	4	2	3	1	2	5	0	0	60.00	40.00	13	16	\N	\N	\N	\N	10	2025-11-20 11:02:21.636704	\N	\N	1	0	h-win	yes
2262	1437230	2025-08-21	World	UEFA Europa League	Lincoln Red Imps FC	SC Braga	a-win	0	4	2	1	11	4	0	4	3	2	2	1	0	0	\N	\N	12	12	\N	\N	\N	\N	5	2025-11-20 11:02:21.828668	\N	\N	0	2	a-win	yes
2263	1437231	2025-08-27	World	UEFA Europa League	AEK Larnaca	Brann	a-win	0	4	9	0	11	6	4	3	4	3	0	2	1	0	51.00	49.00	9	13	\N	\N	\N	\N	11	2025-11-20 11:02:22.007432	\N	\N	0	1	a-win	yes
2264	1437233	2025-08-28	World	UEFA Europa League	KuPS	FC Midtjylland	a-win	0	2	8	6	30	8	1	10	1	1	0	0	1	0	40.00	60.00	8	7	\N	\N	\N	\N	1	2025-11-20 11:02:22.256481	\N	\N	0	0	draw	yes
2265	1436780	2025-08-28	World	UEFA Europa League	Sigma Olomouc	Malmo FF	a-win	0	2	13	2	12	7	10	2	0	2	2	3	0	0	58.00	42.00	19	18	\N	\N	\N	\N	33	2025-11-20 11:02:22.424812	\N	\N	0	0	draw	yes
2266	1437234	2025-08-28	World	UEFA Europa League	Samsunspor	Panathinaikos	draw	0	0	10	3	7	2	7	3	3	0	3	3	0	0	56.00	44.00	16	11	\N	\N	\N	\N	16	2025-11-20 11:02:22.60652	\N	\N	0	0	draw	yes
2267	1436783	2025-08-28	World	UEFA Europa League	Ludogorets	Shkendija	h-win	4	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	30	\N	2025-11-20 11:02:22.630674	\N	\N	2	0	h-win	yes
2268	1437235	2025-08-28	World	UEFA Europa League	PAOK	HNK Rijeka	h-win	5	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	10	\N	2025-11-20 11:02:22.657873	\N	\N	2	0	h-win	yes
2269	1437232	2025-08-28	World	UEFA Europa League	Utrecht	Zrinjski	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	32	\N	2025-11-20 11:02:22.684346	\N	\N	0	0	draw	yes
2270	1436785	2025-08-28	World	UEFA Europa League	BSC Young Boys	Slovan Bratislava	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	22	\N	2025-11-20 11:02:22.698836	\N	\N	2	1	h-win	yes
2271	1436784	2025-08-28	World	UEFA Europa League	Dynamo Kyiv	Maccabi Tel Aviv	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	34	2025-11-20 11:02:22.712288	\N	\N	1	0	h-win	yes
2272	1436781	2025-08-28	World	UEFA Europa League	Genk	Lech Poznan	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	13	\N	2025-11-20 11:02:22.719969	\N	\N	1	1	draw	yes
2273	1436782	2025-08-28	World	UEFA Europa League	FCSB	Aberdeen	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	31	\N	2025-11-20 11:02:22.730827	\N	\N	1	0	h-win	yes
2274	1437236	2025-08-28	World	UEFA Europa League	SC Braga	Lincoln Red Imps FC	h-win	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	\N	2025-11-20 11:02:22.738703	\N	\N	3	0	h-win	yes
2275	1451164	2025-09-24	World	UEFA Europa League	FC Midtjylland	Sturm Graz	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	25	2025-11-20 11:02:22.746173	\N	\N	1	0	h-win	yes
2276	1451165	2025-09-24	World	UEFA Europa League	PAOK	Maccabi Tel Aviv	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	10	34	2025-11-20 11:02:22.752374	\N	\N	0	0	draw	yes
2277	1451171	2025-09-24	World	UEFA Europa League	Nice	AS Roma	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	35	18	2025-11-20 11:02:22.76044	\N	\N	0	0	draw	yes
2278	1451166	2025-09-24	World	UEFA Europa League	SC Freiburg	FC Basel 1893	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	17	2025-11-20 11:02:22.766499	\N	\N	1	0	h-win	yes
2279	1451172	2025-09-24	World	UEFA Europa League	SC Braga	Feyenoord	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	29	2025-11-20 11:02:22.772195	\N	\N	0	0	draw	yes
2280	1451168	2025-09-24	World	UEFA Europa League	Malmo FF	Ludogorets	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	33	30	2025-11-20 11:02:22.779653	\N	\N	0	2	a-win	yes
2281	1451170	2025-09-24	World	UEFA Europa League	Real Betis	Nottingham Forest	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	23	2025-11-20 11:02:22.785934	\N	\N	1	2	a-win	yes
2282	1451167	2025-09-24	World	UEFA Europa League	FK Crvena Zvezda	Celtic	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	26	27	2025-11-20 11:02:22.794562	\N	\N	0	0	draw	yes
2283	1451169	2025-09-24	World	UEFA Europa League	Dinamo Zagreb	Fenerbahce	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	15	2025-11-20 11:02:22.800363	\N	\N	1	1	draw	yes
2284	1451174	2025-09-25	World	UEFA Europa League	Lille	Brann	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	19	11	2025-11-20 11:02:22.807361	\N	\N	0	0	draw	yes
2285	1451173	2025-09-25	World	UEFA Europa League	GO Ahead Eagles	FCSB	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	21	31	2025-11-20 11:02:22.813192	\N	\N	0	1	a-win	yes
2286	1451176	2025-09-25	World	UEFA Europa League	Aston Villa	Bologna	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	24	2025-11-20 11:02:22.819155	\N	\N	1	0	h-win	yes
2287	1452153	2025-09-25	World	UEFA Europa League	VfB Stuttgart	Celta Vigo	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	20	4	2025-11-20 11:02:22.826609	\N	\N	0	0	draw	yes
2288	1452154	2025-09-25	World	UEFA Europa League	Utrecht	Lyon	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	32	7	2025-11-20 11:02:22.832588	\N	\N	0	0	draw	yes
2289	1451179	2025-09-25	World	UEFA Europa League	Rangers	Genk	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	36	13	2025-11-20 11:02:22.840461	\N	\N	0	0	draw	yes
2290	1451177	2025-09-25	World	UEFA Europa League	BSC Young Boys	Panathinaikos	a-win	1	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	22	16	2025-11-20 11:02:22.846059	\N	\N	1	3	a-win	yes
2291	1451175	2025-09-25	World	UEFA Europa League	Red Bull Salzburg	FC Porto	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	28	14	2025-11-20 11:02:22.8524	\N	\N	0	0	draw	yes
2292	1451178	2025-09-25	World	UEFA Europa League	Ferencvarosi TC	Plzen	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	8	2025-11-20 11:02:22.858213	\N	\N	0	1	a-win	yes
2293	1451180	2025-10-02	World	UEFA Europa League	Celtic	SC Braga	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	27	5	2025-11-20 11:02:22.865213	\N	\N	0	1	a-win	yes
2294	1451185	2025-10-02	World	UEFA Europa League	Brann	Utrecht	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	11	32	2025-11-20 11:02:22.871067	\N	\N	1	0	h-win	yes
2295	1451188	2025-10-02	World	UEFA Europa League	AS Roma	Lille	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	18	19	2025-11-20 11:02:22.878909	\N	\N	0	1	a-win	yes
2296	1451183	2025-10-02	World	UEFA Europa League	Bologna	SC Freiburg	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	24	2	2025-11-20 11:02:22.885093	\N	\N	1	0	h-win	yes
2297	1451186	2025-10-02	World	UEFA Europa League	FCSB	BSC Young Boys	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	31	22	2025-11-20 11:02:22.892132	\N	\N	0	2	a-win	yes
2298	1451182	2025-10-02	World	UEFA Europa League	Ludogorets	Real Betis	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	30	9	2025-11-20 11:02:22.897866	\N	\N	0	1	a-win	yes
2299	1451187	2025-10-02	World	UEFA Europa League	Plzen	Malmo FF	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8	33	2025-11-20 11:02:22.904301	\N	\N	2	0	h-win	yes
2300	1451184	2025-10-02	World	UEFA Europa League	Fenerbahce	Nice	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	15	35	2025-11-20 11:02:22.912298	\N	\N	2	1	h-win	yes
2301	1451181	2025-10-02	World	UEFA Europa League	Panathinaikos	GO Ahead Eagles	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16	21	2025-11-20 11:02:22.92636	\N	\N	0	0	draw	yes
2302	1451194	2025-10-02	World	UEFA Europa League	Nottingham Forest	FC Midtjylland	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	23	1	2025-11-20 11:02:22.9322	\N	\N	1	2	a-win	yes
2303	1451191	2025-10-02	World	UEFA Europa League	Lyon	Red Bull Salzburg	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7	28	2025-11-20 11:02:22.93931	\N	\N	1	0	h-win	yes
2304	1452155	2025-10-02	World	UEFA Europa League	Feyenoord	Aston Villa	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	29	6	2025-11-20 11:02:22.944715	\N	\N	0	0	draw	yes
2305	1451192	2025-10-02	World	UEFA Europa League	FC Porto	FK Crvena Zvezda	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	14	26	2025-11-20 11:02:22.950438	\N	\N	1	1	draw	yes
2306	1451196	2025-10-02	World	UEFA Europa League	Celta Vigo	PAOK	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	10	2025-11-20 11:02:22.955693	\N	\N	1	1	draw	yes
2307	1451189	2025-10-02	World	UEFA Europa League	FC Basel 1893	VfB Stuttgart	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	17	20	2025-11-20 11:02:22.963934	\N	\N	1	0	h-win	yes
2308	1451193	2025-10-02	World	UEFA Europa League	Maccabi Tel Aviv	Dinamo Zagreb	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	34	12	2025-11-20 11:02:22.972152	\N	\N	1	2	a-win	yes
2309	1451195	2025-10-02	World	UEFA Europa League	Sturm Graz	Rangers	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	25	36	2025-11-20 11:02:22.982504	\N	\N	2	0	h-win	yes
2310	1451190	2025-10-02	World	UEFA Europa League	Genk	Ferencvarosi TC	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	13	3	2025-11-20 11:02:22.989417	\N	\N	0	1	a-win	yes
2317	1451197	2025-10-23	World	UEFA Europa League	Fenerbahce	VfB Stuttgart	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	15	20	2025-11-20 11:02:23.040599	\N	\N	1	0	h-win	yes
2318	1451200	2025-10-23	World	UEFA Europa League	Genk	Real Betis	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	13	9	2025-11-20 11:02:23.045688	\N	\N	0	0	draw	yes
2319	1451210	2025-10-23	World	UEFA Europa League	Nottingham Forest	FC Porto	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	23	14	2025-11-20 11:02:23.050519	\N	\N	1	0	h-win	yes
2320	1451212	2025-10-23	World	UEFA Europa League	Lille	PAOK	a-win	3	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	19	10	2025-11-20 11:02:23.055274	\N	\N	0	3	a-win	yes
2321	1452156	2025-10-23	World	UEFA Europa League	SC Freiburg	Utrecht	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	32	2025-11-20 11:02:23.063277	\N	\N	2	0	h-win	yes
2322	1451201	2025-10-23	World	UEFA Europa League	Feyenoord	Panathinaikos	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	29	16	2025-11-20 11:02:23.068484	\N	\N	1	1	draw	yes
2323	1451208	2025-10-23	World	UEFA Europa League	Celtic	Sturm Graz	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	27	25	2025-11-20 11:02:23.073667	\N	\N	0	1	a-win	yes
2324	1451213	2025-10-23	World	UEFA Europa League	Malmo FF	Dinamo Zagreb	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	33	12	2025-11-20 11:02:23.080365	\N	\N	1	0	h-win	yes
2325	1451209	2025-10-23	World	UEFA Europa League	AS Roma	Plzen	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	18	8	2025-11-20 11:02:23.086023	\N	\N	0	2	a-win	yes
2326	1451206	2025-10-23	World	UEFA Europa League	Celta Vigo	Nice	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	35	2025-11-20 11:02:23.093675	\N	\N	1	1	draw	yes
2327	1451207	2025-10-23	World	UEFA Europa League	BSC Young Boys	Ludogorets	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	22	30	2025-11-20 11:02:23.099324	\N	\N	1	1	draw	yes
2328	1451211	2025-10-23	World	UEFA Europa League	Maccabi Tel Aviv	FC Midtjylland	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	34	1	2025-11-20 11:02:23.104942	\N	\N	0	1	a-win	yes
2329	1451214	2025-11-06	World	UEFA Europa League	Nice	SC Freiburg	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	35	2	2025-11-20 11:02:23.111755	\N	\N	1	3	a-win	yes
2330	1451217	2025-11-06	World	UEFA Europa League	Utrecht	FC Porto	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	32	14	2025-11-20 11:02:23.117498	\N	\N	0	0	draw	yes
2331	1451221	2025-11-06	World	UEFA Europa League	Malmo FF	Panathinaikos	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	33	16	2025-11-20 11:02:23.125385	\N	\N	0	0	draw	yes
2332	1452157	2025-11-06	World	UEFA Europa League	FC Midtjylland	Celtic	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	27	2025-11-20 11:02:23.130913	\N	\N	3	0	h-win	yes
2333	1451220	2025-11-06	World	UEFA Europa League	FC Basel 1893	FCSB	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	17	31	2025-11-20 11:02:23.139291	\N	\N	1	0	h-win	yes
2334	1451216	2025-11-06	World	UEFA Europa League	Red Bull Salzburg	GO Ahead Eagles	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	28	21	2025-11-20 11:02:23.144949	\N	\N	0	0	draw	yes
2335	1451219	2025-11-06	World	UEFA Europa League	FK Crvena Zvezda	Lille	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	26	19	2025-11-20 11:02:23.150654	\N	\N	0	0	draw	yes
2336	1451218	2025-11-06	World	UEFA Europa League	Dinamo Zagreb	Celta Vigo	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	4	2025-11-20 11:02:23.156048	\N	\N	0	3	a-win	yes
2337	1451215	2025-11-06	World	UEFA Europa League	Sturm Graz	Nottingham Forest	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	25	23	2025-11-20 11:02:23.163808	\N	\N	0	0	draw	yes
2338	1451230	2025-11-06	World	UEFA Europa League	Aston Villa	Maccabi Tel Aviv	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	34	2025-11-20 11:02:23.169487	\N	\N	1	0	h-win	yes
2339	1451228	2025-11-06	World	UEFA Europa League	VfB Stuttgart	Feyenoord	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	20	29	2025-11-20 11:02:23.176839	\N	\N	0	0	draw	yes
2340	1451226	2025-11-06	World	UEFA Europa League	SC Braga	Genk	a-win	3	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	13	2025-11-20 11:02:23.182911	\N	\N	1	1	draw	yes
2341	1451222	2025-11-06	World	UEFA Europa League	Rangers	AS Roma	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	36	18	2025-11-20 11:02:23.188876	\N	\N	0	2	a-win	yes
2342	1451225	2025-11-06	World	UEFA Europa League	Bologna	Brann	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	24	11	2025-11-20 11:02:23.196259	\N	\N	0	0	draw	yes
2343	1451227	2025-11-06	World	UEFA Europa League	Real Betis	Lyon	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	7	2025-11-20 11:02:23.202076	\N	\N	2	0	h-win	yes
2344	1451223	2025-11-06	World	UEFA Europa League	Plzen	Fenerbahce	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8	15	2025-11-20 11:02:23.209686	\N	\N	0	0	draw	yes
2345	1451229	2025-11-06	World	UEFA Europa League	PAOK	BSC Young Boys	h-win	4	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	10	22	2025-11-20 11:02:23.215642	\N	\N	0	0	draw	yes
2346	1451224	2025-11-06	World	UEFA Europa League	Ferencvarosi TC	Ludogorets	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	30	2025-11-20 11:02:23.223412	\N	\N	1	0	h-win	yes
2347	1377400	2025-08-13	World	UEFA Super Cup	Paris Saint Germain	Tottenham	draw	2	2	12	3	13	5	7	2	2	4	3	2	0	0	74.00	26.00	12	12	\N	\N	\N	\N	\N	2025-11-20 12:03:25.950987	\N	\N	0	1	a-win	yes
2348	1421174	2025-08-05	World	UEFA Europa Conference League	KI Klaksvik	Neman	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 12:03:27.390399	\N	\N	2	0	h-win	yes
2349	1423750	2025-08-07	World	UEFA Europa Conference League	Rosenborg	Hammarby FF	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 12:03:27.563227	\N	\N	0	0	draw	yes
2350	1421160	2025-08-07	World	UEFA Europa Conference League	Milsami Orhei	Virtus	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 12:03:27.738648	\N	\N	1	0	h-win	yes
2351	1421172	2025-08-07	World	UEFA Europa Conference League	Aris	AEK Athens FC	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	15	2025-11-20 12:03:27.932092	\N	\N	2	2	draw	yes
2352	1421167	2025-08-07	World	UEFA Europa Conference League	Kauno Žalgiris	Arda Kardzhali	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 12:03:28.111643	\N	\N	0	0	draw	yes
2353	1421175	2025-08-07	World	UEFA Europa Conference League	Araz	Omonia Nicosia	a-win	0	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	29	2025-11-20 12:03:28.300462	\N	\N	0	2	a-win	yes
2354	1421169	2025-08-07	World	UEFA Europa Conference League	Baník Ostrava	Austria Vienna	h-win	4	3	19	7	19	7	4	9	1	2	1	3	0	0	42.00	58.00	5	12	\N	\N	\N	\N	\N	2025-11-20 12:03:28.483086	\N	\N	2	1	h-win	yes
2355	1421155	2025-08-07	World	UEFA Europa Conference League	AIK Stockholm	Gyori ETO FC	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 12:03:28.701455	\N	\N	2	0	h-win	yes
2356	1421163	2025-08-07	World	UEFA Europa Conference League	Viking	Istanbul Basaksehir	a-win	1	3	16	4	8	3	10	2	2	2	1	1	0	0	56.00	44.00	15	6	\N	\N	\N	\N	\N	2025-11-20 12:03:28.901689	\N	\N	1	0	h-win	yes
2357	1421162	2025-08-07	World	UEFA Europa Conference League	Silkeborg	Jagiellonia	a-win	0	1	11	4	11	4	7	6	0	3	2	3	0	0	51.00	49.00	15	12	\N	\N	\N	\N	14	2025-11-20 12:03:29.079444	\N	\N	0	1	a-win	yes
2358	1421156	2025-08-07	World	UEFA Europa Conference League	Riga	Beitar Jerusalem	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 12:03:29.262096	\N	\N	0	0	draw	yes
2359	1421158	2025-08-07	World	UEFA Europa Conference League	AZ Alkmaar	FC Vaduz	h-win	3	0	14	8	7	0	6	2	3	1	3	1	0	0	57.00	43.00	15	10	\N	\N	\N	27	\N	2025-11-20 12:03:29.455157	\N	\N	1	0	h-win	yes
2360	1421178	2025-08-07	World	UEFA Europa Conference League	Anderlecht	Sheriff Tiraspol	h-win	3	0	12	6	6	2	6	5	2	0	2	1	0	0	53.00	47.00	15	9	\N	\N	\N	\N	\N	2025-11-20 12:03:29.661706	\N	\N	1	0	h-win	yes
2361	1421170	2025-08-07	World	UEFA Europa Conference League	Vikingur Gota	Linfield	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 12:03:29.8512	\N	\N	1	1	draw	yes
2362	1421168	2025-08-07	World	UEFA Europa Conference League	Sparta Praha	Ararat-Armenia	h-win	4	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16	\N	2025-11-20 12:03:30.036554	\N	\N	2	1	h-win	yes
2363	1421173	2025-08-07	World	UEFA Europa Conference League	Levski Sofia	Sabah FA	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 12:03:30.214623	\N	\N	0	0	draw	yes
2364	1421179	2025-08-07	World	UEFA Europa Conference League	Olimpija Ljubljana	Egnatia Rrogozhinë	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 12:03:30.402467	\N	\N	0	0	draw	yes
2365	1419570	2025-08-07	World	UEFA Europa Conference League	FC Differdange 03	FC Levadia Tallinn	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 12:03:30.590837	\N	\N	1	2	a-win	yes
2366	1421153	2025-08-07	World	UEFA Europa Conference League	Polessya	Paks	h-win	3	0	14	8	10	2	5	6	3	2	2	1	1	0	57.00	43.00	12	11	\N	\N	\N	\N	\N	2025-11-20 12:03:30.77677	\N	\N	2	0	h-win	yes
2367	1421159	2025-08-07	World	UEFA Europa Conference League	Lausanne	FC Astana	h-win	3	1	15	6	13	4	3	5	1	4	2	2	0	0	49.00	51.00	10	16	\N	\N	\N	5	\N	2025-11-20 12:03:30.978067	\N	\N	2	0	h-win	yes
2368	1421157	2025-08-07	World	UEFA Europa Conference League	FC Lugano	Celje	a-win	0	5	15	4	16	10	2	2	1	3	2	0	0	0	51.00	49.00	14	12	\N	\N	\N	\N	2	2025-11-20 12:03:31.147488	\N	\N	0	2	a-win	yes
2369	1421154	2025-08-07	World	UEFA Europa Conference League	Universitatea Craiova	Spartak Trnava	h-win	3	0	18	8	6	1	3	3	2	5	1	1	0	1	55.00	45.00	12	11	\N	\N	\N	20	\N	2025-11-20 12:03:31.325777	\N	\N	0	0	draw	yes
2370	1421161	2025-08-07	World	UEFA Europa Conference League	Ballkani	Shamrock Rovers	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	31	2025-11-20 12:03:31.488515	\N	\N	0	0	draw	yes
2371	1421164	2025-08-07	World	UEFA Europa Conference League	Vikingur Reykjavik	Brondby	h-win	3	0	13	4	14	5	5	6	1	0	1	2	0	0	38.00	62.00	11	16	\N	\N	\N	\N	\N	2025-11-20 12:03:31.660031	\N	\N	1	0	h-win	yes
2372	1421176	2025-08-07	World	UEFA Europa Conference League	St Patrick's Athl.	Besiktas	a-win	1	4	4	3	16	8	2	3	0	0	1	1	0	0	33.00	67.00	5	15	\N	\N	\N	\N	\N	2025-11-20 12:03:31.840521	\N	\N	0	4	a-win	yes
2373	1421171	2025-08-07	World	UEFA Europa Conference League	FK Partizan	Hibernian	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 12:03:32.019583	\N	\N	0	1	a-win	yes
2374	1421180	2025-08-07	World	UEFA Europa Conference League	HNK Hajduk Split	Dinamo Tirana	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 12:03:32.192895	\N	\N	0	1	a-win	yes
2375	1421177	2025-08-07	World	UEFA Europa Conference League	Rapid Vienna	Dundee Utd	draw	2	2	21	7	7	3	10	3	1	0	1	0	0	0	62.00	38.00	5	3	\N	\N	\N	36	\N	2025-11-20 12:03:32.362619	\N	\N	2	1	h-win	yes
2376	1421166	2025-08-07	World	UEFA Europa Conference League	Raków Częstochowa	Maccabi Haifa	a-win	0	1	14	4	6	5	8	2	2	0	0	6	0	0	55.00	45.00	6	20	\N	\N	\N	12	\N	2025-11-20 12:03:32.53268	\N	\N	0	0	draw	yes
2377	1421165	2025-08-07	World	UEFA Europa Conference League	Larne	Santa Clara	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 12:03:32.715528	\N	\N	0	3	a-win	yes
2378	1421208	2025-08-13	World	UEFA Europa Conference League	Istanbul Basaksehir	Viking	draw	1	1	8	3	13	4	2	3	2	1	5	2	0	0	45.00	55.00	14	15	\N	\N	\N	\N	\N	2025-11-20 12:03:32.896155	\N	\N	1	1	draw	yes
2379	1421188	2025-08-14	World	UEFA Europa Conference League	FC Astana	Lausanne	a-win	0	2	14	5	24	7	6	4	2	1	5	1	1	0	67.00	33.00	18	9	\N	\N	\N	\N	5	2025-11-20 12:03:33.074758	\N	\N	0	0	draw	yes
2380	1421197	2025-08-14	World	UEFA Europa Conference League	Ararat-Armenia	Sparta Praha	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16	2025-11-20 12:03:33.249193	\N	\N	1	1	draw	yes
2381	1421207	2025-08-14	World	UEFA Europa Conference League	Sabah FA	Levski Sofia	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 12:03:33.433943	\N	\N	0	1	a-win	yes
2382	1419571	2025-08-14	World	UEFA Europa Conference League	FC Levadia Tallinn	FC Differdange 03	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 12:03:33.613113	\N	\N	0	0	draw	yes
2383	1421204	2025-08-14	World	UEFA Europa Conference League	Hammarby FF	Rosenborg	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 12:03:33.800268	\N	\N	0	0	draw	yes
2384	1421198	2025-08-14	World	UEFA Europa Conference League	Sheriff Tiraspol	Anderlecht	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 12:03:34.000322	\N	\N	0	0	draw	yes
2385	1421185	2025-08-14	World	UEFA Europa Conference League	Paks	Polessya	h-win	2	1	15	4	21	9	13	5	1	1	2	3	0	0	43.00	57.00	9	11	\N	\N	\N	\N	\N	2025-11-20 12:03:34.172511	\N	\N	1	0	h-win	yes
2386	1421201	2025-08-14	World	UEFA Europa Conference League	Gyori ETO FC	AIK Stockholm	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 12:03:34.349554	\N	\N	1	0	h-win	yes
2387	1421202	2025-08-14	World	UEFA Europa Conference League	Omonia Nicosia	Araz	h-win	5	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	29	\N	2025-11-20 12:03:34.528232	\N	\N	4	0	h-win	yes
2388	1421187	2025-08-14	World	UEFA Europa Conference League	Brondby	Vikingur Reykjavik	h-win	4	0	13	7	4	1	3	2	6	2	3	2	1	0	48.00	52.00	14	13	\N	\N	\N	\N	\N	2025-11-20 12:03:34.710459	\N	\N	1	0	h-win	yes
2389	1421196	2025-08-14	World	UEFA Europa Conference League	Beitar Jerusalem	Riga	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 12:03:34.890574	\N	\N	2	0	h-win	yes
2390	1421186	2025-08-14	World	UEFA Europa Conference League	FC Vaduz	AZ Alkmaar	a-win	0	1	22	5	5	1	5	1	1	1	5	3	0	1	81.00	19.00	14	10	\N	\N	\N	\N	27	2025-11-20 12:03:35.048347	\N	\N	0	0	draw	yes
2391	1421192	2025-08-14	World	UEFA Europa Conference League	Arda Kardzhali	Kauno Žalgiris	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 12:03:35.216168	\N	\N	2	0	h-win	yes
2392	1421189	2025-08-14	World	UEFA Europa Conference League	Neman	KI Klaksvik	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 12:03:35.40593	\N	\N	0	0	draw	yes
2393	1421184	2025-08-14	World	UEFA Europa Conference League	Besiktas	St Patrick's Athl.	h-win	3	2	16	7	5	2	1	1	2	0	1	1	0	0	70.00	30.00	11	9	\N	\N	\N	\N	\N	2025-11-20 12:03:35.591139	\N	\N	1	2	a-win	yes
2394	1421203	2025-08-14	World	UEFA Europa Conference League	AEK Athens FC	Aris	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	15	\N	2025-11-20 12:03:35.774187	\N	\N	0	0	draw	yes
2395	1421182	2025-08-14	World	UEFA Europa Conference League	Maccabi Haifa	Raków Częstochowa	a-win	0	2	7	4	15	6	3	4	3	0	5	0	1	0	53.00	47.00	21	11	\N	\N	\N	\N	12	2025-11-20 12:03:35.989831	\N	\N	0	1	a-win	yes
2396	1421181	2025-08-14	World	UEFA Europa Conference League	Celje	FC Lugano	a-win	2	4	22	5	15	6	2	2	2	1	1	3	0	0	53.00	47.00	17	14	\N	\N	\N	2	\N	2025-11-20 12:03:36.170661	\N	\N	1	1	draw	yes
2397	1421183	2025-08-14	World	UEFA Europa Conference League	Jagiellonia	Silkeborg	draw	2	2	15	6	11	4	5	1	1	0	2	1	0	0	46.00	54.00	8	9	\N	\N	\N	14	\N	2025-11-20 12:03:36.35817	\N	\N	2	0	h-win	yes
2398	1421199	2025-08-14	World	UEFA Europa Conference League	Spartak Trnava	Universitatea Craiova	h-win	4	3	26	9	16	6	10	6	0	3	2	3	0	0	62.00	38.00	23	23	\N	\N	\N	\N	20	2025-11-20 12:03:36.537551	\N	\N	1	1	draw	yes
2399	1423751	2025-08-14	World	UEFA Europa Conference League	Linfield	Vikingur Gota	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 12:03:36.735554	\N	\N	2	0	h-win	yes
2400	1421195	2025-08-14	World	UEFA Europa Conference League	Dundee Utd	Rapid Vienna	draw	2	2	17	6	21	7	3	11	1	0	2	5	0	0	39.00	61.00	9	15	\N	\N	\N	\N	36	2025-11-20 12:03:36.93031	\N	\N	2	0	h-win	yes
2401	1421205	2025-08-14	World	UEFA Europa Conference League	Dinamo Tirana	HNK Hajduk Split	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 12:03:37.11941	\N	\N	1	0	h-win	yes
2402	1421191	2025-08-14	World	UEFA Europa Conference League	Santa Clara	Larne	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 12:03:37.295285	\N	\N	0	0	draw	yes
2403	1421200	2025-08-14	World	UEFA Europa Conference League	Hibernian	FK Partizan	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 12:03:37.467568	\N	\N	0	2	a-win	yes
2404	1421193	2025-08-14	World	UEFA Europa Conference League	Austria Vienna	Baník Ostrava	draw	1	1	5	1	3	2	2	3	0	1	1	1	0	0	58.00	42.00	4	6	\N	\N	\N	\N	\N	2025-11-20 12:03:37.661807	\N	\N	0	1	a-win	yes
2405	1421190	2025-08-14	World	UEFA Europa Conference League	Shamrock Rovers	Ballkani	h-win	4	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	31	\N	2025-11-20 12:03:37.824054	\N	\N	1	0	h-win	yes
2406	1421206	2025-08-14	World	UEFA Europa Conference League	Egnatia Rrogozhinë	Olimpija Ljubljana	a-win	2	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 12:03:38.00832	\N	\N	1	1	draw	yes
2407	1421194	2025-08-14	World	UEFA Europa Conference League	Virtus	Milsami Orhei	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 12:03:38.187798	\N	\N	0	0	draw	yes
2408	1438686	2025-08-21	World	UEFA Europa Conference League	Rosenborg	FSV Mainz 05	h-win	2	1	13	8	13	4	5	5	0	2	0	2	0	0	40.00	60.00	7	10	\N	\N	\N	\N	3	2025-11-20 12:03:38.371256	\N	\N	1	1	draw	yes
2409	1438687	2025-08-21	World	UEFA Europa Conference League	BK Hacken	CFR 1907 Cluj	h-win	7	2	18	9	10	6	8	3	1	4	0	1	0	0	65.00	35.00	9	9	\N	\N	\N	28	\N	2025-11-20 12:03:38.531085	\N	\N	4	1	h-win	yes
2410	1438688	2025-08-21	World	UEFA Europa Conference League	Wolfsberger AC	Omonia Nicosia	h-win	2	1	18	6	15	6	7	5	3	4	2	2	0	0	50.00	50.00	13	9	\N	\N	\N	\N	29	2025-11-20 12:03:38.697231	\N	\N	1	1	draw	yes
2411	1438690	2025-08-21	World	UEFA Europa Conference League	Gyori ETO FC	Rapid Vienna	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	36	2025-11-20 12:03:38.880002	\N	\N	0	0	draw	yes
2412	1438689	2025-08-21	World	UEFA Europa Conference League	Hamrun Spartans	Rīgas FS	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	35	\N	2025-11-20 12:03:39.037398	\N	\N	0	0	draw	yes
2413	1438691	2025-08-21	World	UEFA Europa Conference League	Istanbul Basaksehir	Universitatea Craiova	a-win	1	2	14	3	15	5	7	6	0	1	2	4	0	0	72.00	28.00	8	16	\N	\N	\N	\N	20	2025-11-20 12:03:39.228722	\N	\N	0	1	a-win	yes
2414	1438698	2025-08-21	World	UEFA Europa Conference League	Strasbourg	Brondby	draw	0	0	20	8	6	0	9	4	2	2	1	2	0	0	65.00	35.00	9	9	\N	\N	\N	7	\N	2025-11-20 12:03:39.416882	\N	\N	0	0	draw	yes
2415	1438701	2025-08-21	World	UEFA Europa Conference League	Breidablik	Virtus	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	32	\N	2025-11-20 12:03:39.618159	\N	\N	1	1	draw	yes
2416	1438696	2025-08-21	World	UEFA Europa Conference League	Neman	Rayo Vallecano	a-win	0	1	6	4	18	6	3	10	1	3	2	0	0	0	25.00	75.00	13	12	\N	\N	\N	\N	6	2025-11-20 12:03:39.804835	\N	\N	0	0	draw	yes
2417	1438695	2025-08-21	World	UEFA Europa Conference League	Shakhtar Donetsk	Servette FC	draw	1	1	23	6	2	2	14	4	2	2	1	1	0	0	71.00	29.00	8	12	\N	\N	\N	10	\N	2025-11-20 12:03:39.974323	\N	\N	0	1	a-win	yes
2418	1438693	2025-08-21	World	UEFA Europa Conference League	Anderlecht	AEK Athens FC	draw	1	1	20	10	10	5	7	0	1	2	2	3	0	1	56.00	44.00	20	8	\N	\N	\N	\N	15	2025-11-20 12:03:40.155631	\N	\N	1	0	h-win	yes
2419	1438697	2025-08-21	World	UEFA Europa Conference League	Sparta Praha	Riga	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16	\N	2025-11-20 12:03:40.329144	\N	\N	1	0	h-win	yes
2420	1438694	2025-08-21	World	UEFA Europa Conference League	Levski Sofia	AZ Alkmaar	a-win	0	2	14	2	12	5	9	2	0	0	2	3	0	0	54.00	46.00	10	14	\N	\N	\N	\N	27	2025-11-20 12:03:40.518196	\N	\N	0	0	draw	yes
2421	1438699	2025-08-21	World	UEFA Europa Conference League	Olimpija Ljubljana	FC Noah	a-win	1	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	17	2025-11-20 12:03:40.693972	\N	\N	0	2	a-win	yes
2422	1438700	2025-08-21	World	UEFA Europa Conference League	Celje	Baník Ostrava	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	\N	2025-11-20 12:03:40.841568	\N	\N	1	0	h-win	yes
2423	1438692	2025-08-21	World	UEFA Europa Conference League	Polessya	Fiorentina	a-win	0	3	20	3	15	3	5	3	2	1	1	1	0	1	64.00	36.00	8	5	\N	\N	\N	\N	8	2025-11-20 12:03:41.002276	\N	\N	0	2	a-win	yes
2424	1438702	2025-08-21	World	UEFA Europa Conference League	Drita	FC Differdange 03	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	13	\N	2025-11-20 12:03:41.175816	\N	\N	1	0	h-win	yes
2425	1438704	2025-08-21	World	UEFA Europa Conference League	Jagiellonia	Dinamo Tirana	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	14	\N	2025-11-20 12:03:41.331407	\N	\N	2	0	h-win	yes
2426	1438703	2025-08-21	World	UEFA Europa Conference League	Lausanne	Besiktas	draw	1	1	20	6	9	2	6	2	1	3	0	3	0	0	37.00	63.00	14	9	\N	\N	\N	5	\N	2025-11-20 12:03:41.51458	\N	\N	0	1	a-win	yes
2427	1438705	2025-08-21	World	UEFA Europa Conference League	Shelbourne	Linfield	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	30	\N	2025-11-20 12:03:41.723719	\N	\N	1	0	h-win	yes
2428	1438706	2025-08-21	World	UEFA Europa Conference League	Crystal Palace	Fredrikstad	h-win	1	0	25	5	5	0	7	3	0	2	0	2	0	0	74.00	26.00	4	11	\N	\N	\N	9	\N	2025-11-20 12:03:41.9025	\N	\N	0	0	draw	yes
2429	1438708	2025-08-21	World	UEFA Europa Conference League	Santa Clara	Shamrock Rovers	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	31	2025-11-20 12:03:42.078269	\N	\N	1	1	draw	yes
2430	1438707	2025-08-21	World	UEFA Europa Conference League	Hibernian	Legia Warszawa	a-win	1	2	11	2	13	4	5	3	3	3	4	3	0	0	44.00	56.00	8	14	\N	\N	\N	\N	25	2025-11-20 12:03:42.259431	\N	\N	0	2	a-win	yes
2431	1438709	2025-08-21	World	UEFA Europa Conference League	Raków Częstochowa	Arda Kardzhali	h-win	1	0	13	6	7	2	1	0	1	2	0	0	0	0	45.00	55.00	14	8	\N	\N	\N	12	\N	2025-11-20 12:03:42.432813	\N	\N	1	0	h-win	yes
2432	1438710	2025-08-27	World	UEFA Europa Conference League	Riga	Sparta Praha	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16	2025-11-20 12:03:42.613017	\N	\N	0	0	draw	yes
2433	1438711	2025-08-28	World	UEFA Europa Conference League	Fredrikstad	Crystal Palace	draw	0	0	8	1	10	4	2	3	0	0	3	2	0	0	40.00	60.00	7	7	\N	\N	\N	\N	9	2025-11-20 12:03:42.793749	\N	\N	0	0	draw	yes
2434	1438713	2025-08-28	World	UEFA Europa Conference League	Omonia Nicosia	Wolfsberger AC	h-win	1	0	15	6	22	6	9	5	3	1	2	3	1	0	51.00	49.00	11	19	\N	\N	\N	29	\N	2025-11-20 12:03:42.960817	\N	\N	1	0	h-win	yes
2435	1438712	2025-08-28	World	UEFA Europa Conference League	FC Noah	Olimpija Ljubljana	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	17	\N	2025-11-20 12:03:43.13706	\N	\N	2	0	h-win	yes
2436	1438714	2025-08-28	World	UEFA Europa Conference League	Besiktas	Lausanne	a-win	0	1	12	3	19	8	4	8	3	2	4	2	1	0	55.00	45.00	12	19	\N	\N	\N	\N	5	2025-11-20 12:03:43.305936	\N	\N	0	1	a-win	yes
2437	1438815	2025-08-28	World	UEFA Europa Conference League	Rapid Vienna	Gyori ETO FC	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	36	\N	2025-11-20 12:03:43.488798	\N	\N	1	0	h-win	yes
2438	1438715	2025-08-28	World	UEFA Europa Conference League	Rīgas FS	Hamrun Spartans	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	35	2025-11-20 12:03:43.669877	\N	\N	1	1	draw	yes
2439	1438816	2025-08-28	World	UEFA Europa Conference League	AZ Alkmaar	Levski Sofia	h-win	4	1	13	8	7	4	3	4	4	0	1	3	0	0	46.00	54.00	5	14	\N	\N	\N	27	\N	2025-11-20 12:03:43.852627	\N	\N	3	0	h-win	yes
2440	1438818	2025-08-28	World	UEFA Europa Conference League	Universitatea Craiova	Istanbul Basaksehir	h-win	3	1	14	6	10	3	4	5	2	0	3	6	0	1	43.00	57.00	15	17	\N	\N	\N	20	\N	2025-11-20 12:03:44.011662	\N	\N	2	1	h-win	yes
2441	1438817	2025-08-28	World	UEFA Europa Conference League	CFR 1907 Cluj	BK Hacken	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	28	2025-11-20 12:03:44.178221	\N	\N	0	0	draw	yes
2442	1438822	2025-08-28	World	UEFA Europa Conference League	Brondby	Strasbourg	a-win	2	3	17	3	9	4	5	3	0	1	5	6	0	0	47.00	53.00	15	15	\N	\N	\N	\N	7	2025-11-20 12:03:44.382426	\N	\N	1	2	a-win	yes
2443	1438819	2025-08-28	World	UEFA Europa Conference League	Fiorentina	Polessya	h-win	3	2	14	6	5	5	6	1	3	2	0	2	0	0	62.00	38.00	3	15	\N	\N	\N	8	\N	2025-11-20 12:03:44.551989	\N	\N	0	2	a-win	yes
2444	1438820	2025-08-28	World	UEFA Europa Conference League	AEK Athens FC	Anderlecht	h-win	2	0	19	6	13	4	7	4	1	1	1	5	0	0	42.00	58.00	5	22	\N	\N	\N	15	\N	2025-11-20 12:03:44.713111	\N	\N	1	0	h-win	yes
2445	1438825	2025-08-28	World	UEFA Europa Conference League	FC Differdange 03	Drita	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	13	2025-11-20 12:03:44.876968	\N	\N	0	0	draw	yes
2446	1438821	2025-08-28	World	UEFA Europa Conference League	Rayo Vallecano	Neman	h-win	4	0	13	7	3	0	7	0	5	2	1	2	0	0	69.00	31.00	5	11	\N	\N	\N	6	\N	2025-11-20 12:03:45.059889	\N	\N	0	0	draw	yes
2447	1438823	2025-08-28	World	UEFA Europa Conference League	Arda Kardzhali	Raków Częstochowa	a-win	1	2	8	3	12	7	3	2	0	2	4	3	2	0	52.00	48.00	15	15	\N	\N	\N	\N	12	2025-11-20 12:03:45.224981	\N	\N	0	1	a-win	yes
2448	1438824	2025-08-28	World	UEFA Europa Conference League	Baník Ostrava	Celje	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	2025-11-20 12:03:45.391299	\N	\N	0	2	a-win	yes
2449	1438827	2025-08-28	World	UEFA Europa Conference League	Linfield	Shelbourne	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	30	2025-11-20 12:03:45.576695	\N	\N	0	2	a-win	yes
2450	1438826	2025-08-28	World	UEFA Europa Conference League	Dinamo Tirana	Jagiellonia	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	14	2025-11-20 12:03:45.762131	\N	\N	0	0	draw	yes
2451	1438829	2025-08-28	World	UEFA Europa Conference League	FSV Mainz 05	Rosenborg	h-win	4	1	22	8	5	2	9	2	6	2	1	1	0	0	52.00	48.00	12	7	\N	\N	\N	3	\N	2025-11-20 12:03:45.944108	\N	\N	3	1	h-win	yes
2452	1438830	2025-08-28	World	UEFA Europa Conference League	Legia Warszawa	Hibernian	draw	3	3	11	7	23	11	5	8	6	1	6	6	1	0	55.00	45.00	16	15	\N	\N	\N	25	\N	2025-11-20 12:03:46.121718	\N	\N	1	0	h-win	yes
2453	1438831	2025-08-28	World	UEFA Europa Conference League	Shamrock Rovers	Santa Clara	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	31	\N	2025-11-20 12:03:46.304266	\N	\N	0	0	draw	yes
2454	1438828	2025-08-28	World	UEFA Europa Conference League	Servette FC	Shakhtar Donetsk	a-win	1	2	12	3	23	7	3	6	1	0	4	3	0	0	37.00	63.00	13	11	\N	\N	\N	\N	10	2025-11-20 12:03:46.484068	\N	\N	0	0	draw	yes
2455	1438832	2025-08-28	World	UEFA Europa Conference League	Virtus	Breidablik	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	32	2025-11-20 12:03:46.673977	\N	\N	1	1	draw	yes
2456	1451357	2025-10-02	World	UEFA Europa Conference League	Jagiellonia	Hamrun Spartans	h-win	1	0	19	7	8	3	7	5	3	0	2	2	0	1	63.00	37.00	16	11	\N	\N	\N	14	35	2025-11-20 12:03:46.852755	1.56	0.58	0	0	draw	yes
2457	1451356	2025-10-02	World	UEFA Europa Conference League	Lech Poznan	Rapid Vienna	h-win	4	1	18	9	9	2	2	4	0	3	3	1	0	0	52.00	48.00	9	18	\N	\N	\N	23	36	2025-11-20 12:03:47.021053	2.85	0.66	3	0	h-win	yes
2458	1451358	2025-10-02	World	UEFA Europa Conference League	Dynamo Kyiv	Crystal Palace	a-win	0	2	9	1	14	7	3	4	2	2	1	3	0	1	46.00	54.00	7	14	\N	\N	\N	24	9	2025-11-20 12:03:47.197907	0.53	1.96	0	1	a-win	yes
2459	1451354	2025-10-02	World	UEFA Europa Conference League	Zrinjski	Lincoln Red Imps FC	h-win	5	0	24	10	8	0	4	4	0	0	3	2	0	0	51.00	49.00	16	11	\N	\N	\N	26	22	2025-11-20 12:03:47.374131	3.37	0.46	3	0	h-win	yes
2460	1451361	2025-10-02	World	UEFA Europa Conference League	Rayo Vallecano	Shkendija	h-win	2	0	20	10	1	1	12	0	5	2	1	2	0	0	69.00	31.00	20	6	\N	\N	\N	6	21	2025-11-20 12:03:47.558903	2.01	0.02	2	0	h-win	yes
2461	1452158	2025-10-02	World	UEFA Europa Conference League	Lausanne	Breidablik	h-win	3	0	16	8	13	2	2	7	2	1	1	1	0	0	56.00	44.00	12	6	\N	\N	\N	5	32	2025-11-20 12:03:47.732765	1.93	0.97	3	0	h-win	yes
2462	1451359	2025-10-02	World	UEFA Europa Conference League	KuPS	Drita	draw	1	1	6	3	12	4	1	2	0	2	4	0	0	0	65.00	35.00	16	10	\N	\N	\N	11	13	2025-11-20 12:03:47.936039	0.64	0.90	0	0	draw	yes
2463	1451355	2025-10-02	World	UEFA Europa Conference League	Omonia Nicosia	FSV Mainz 05	a-win	0	1	8	3	17	2	4	8	3	3	1	1	0	0	44.00	56.00	8	9	\N	\N	\N	29	3	2025-11-20 12:03:48.121872	0.24	1.59	0	0	draw	yes
2464	1451360	2025-10-02	World	UEFA Europa Conference League	FC Noah	HNK Rijeka	h-win	1	0	15	3	2	1	1	1	0	1	2	3	0	1	59.00	41.00	15	16	\N	\N	\N	17	18	2025-11-20 12:03:48.287086	1.18	0.15	1	0	h-win	yes
2465	1451363	2025-10-02	World	UEFA Europa Conference League	Aberdeen	Shakhtar Donetsk	a-win	2	3	12	5	11	4	4	6	1	0	4	4	0	0	28.00	72.00	12	9	\N	\N	\N	33	10	2025-11-20 12:03:48.473271	1.97	1.32	1	1	draw	yes
2466	1451364	2025-10-02	World	UEFA Europa Conference League	Legia Warszawa	Samsunspor	a-win	0	1	19	2	6	2	8	2	3	0	3	4	0	0	63.00	37.00	7	10	\N	\N	\N	25	1	2025-11-20 12:03:48.639393	1.13	0.76	0	1	a-win	yes
2467	1451365	2025-10-02	World	UEFA Europa Conference League	Fiorentina	Sigma Olomouc	h-win	2	0	14	4	7	4	8	0	7	1	3	1	0	0	54.00	46.00	19	18	\N	\N	\N	8	19	2025-11-20 12:03:48.813457	1.77	0.36	1	0	h-win	yes
2468	1451367	2025-10-02	World	UEFA Europa Conference League	AEK Larnaca	AZ Alkmaar	h-win	4	0	23	10	6	2	6	2	1	1	2	3	0	1	69.00	31.00	13	8	\N	\N	\N	4	27	2025-11-20 12:03:48.967519	2.90	0.48	1	0	h-win	yes
2469	1451369	2025-10-02	World	UEFA Europa Conference League	Sparta Praha	Shamrock Rovers	h-win	4	1	19	8	2	1	7	2	3	2	3	4	0	0	75.00	25.00	10	11	\N	\N	\N	16	31	2025-11-20 12:03:49.126586	3.21	0.09	2	0	h-win	yes
2470	1452159	2025-10-02	World	UEFA Europa Conference League	Slovan Bratislava	Strasbourg	a-win	1	2	22	6	5	4	5	1	3	3	1	3	0	0	57.00	43.00	9	10	\N	\N	\N	34	7	2025-11-20 12:03:49.282118	2.13	1.14	0	2	a-win	yes
2471	1451366	2025-10-02	World	UEFA Europa Conference League	Raków Częstochowa	Universitatea Craiova	h-win	2	0	22	10	4	0	10	1	2	0	0	2	0	1	57.00	43.00	7	16	\N	\N	\N	12	20	2025-11-20 12:03:49.461187	1.60	0.14	0	0	draw	yes
2472	1451362	2025-10-02	World	UEFA Europa Conference League	Shelbourne	BK Hacken	draw	0	0	7	1	11	3	3	5	1	2	1	2	0	0	35.00	65.00	10	8	\N	\N	\N	30	28	2025-11-20 12:03:49.639336	0.32	0.94	0	0	draw	yes
2473	1451368	2025-10-02	World	UEFA Europa Conference League	Celje	AEK Athens FC	h-win	3	1	21	9	9	5	9	4	0	3	3	4	0	0	60.00	40.00	15	11	\N	\N	\N	2	15	2025-11-20 12:03:49.831887	2.94	1.10	1	1	draw	yes
2474	1451373	2025-10-23	World	UEFA Europa Conference League	Strasbourg	Jagiellonia	draw	1	1	25	7	3	2	8	0	1	0	3	4	0	0	67.00	33.00	15	9	\N	\N	\N	7	14	2025-11-20 12:03:50.016707	2.57	0.85	0	0	draw	yes
2475	1451378	2025-10-23	World	UEFA Europa Conference League	AZ Alkmaar	Slovan Bratislava	h-win	1	0	30	11	3	1	12	0	4	0	1	4	0	1	62.00	38.00	16	12	\N	\N	\N	27	34	2025-11-20 12:03:50.199599	3.34	0.17	1	0	h-win	yes
2476	1451370	2025-10-23	World	UEFA Europa Conference League	Breidablik	KuPS	draw	0	0	16	3	8	2	10	6	2	1	1	0	0	1	44.00	56.00	6	11	\N	\N	\N	32	11	2025-11-20 12:03:50.38966	1.86	1.05	0	0	draw	yes
2477	1451371	2025-10-23	World	UEFA Europa Conference League	BK Hacken	Rayo Vallecano	draw	2	2	10	4	11	4	10	5	1	3	5	5	0	1	40.00	60.00	11	13	\N	\N	\N	28	6	2025-11-20 12:03:50.618843	1.97	1.66	1	1	draw	yes
2478	1451376	2025-10-23	World	UEFA Europa Conference League	Shakhtar Donetsk	Legia Warszawa	a-win	1	2	11	3	11	3	3	3	2	3	3	1	0	0	70.00	30.00	9	8	\N	\N	\N	10	25	2025-11-20 12:03:50.812755	0.49	0.97	0	1	a-win	yes
2479	1452160	2025-10-23	World	UEFA Europa Conference League	AEK Athens FC	Aberdeen	h-win	6	0	27	10	8	2	5	2	1	1	1	1	0	0	73.00	27.00	11	13	\N	\N	\N	15	33	2025-11-20 12:03:50.982828	5.13	0.45	3	0	h-win	yes
2480	1451375	2025-10-23	World	UEFA Europa Conference League	Shkendija	Shelbourne	h-win	1	0	13	1	9	2	4	1	0	1	3	2	0	0	58.00	42.00	14	16	\N	\N	\N	21	30	2025-11-20 12:03:51.159456	0.46	0.51	0	0	draw	yes
2481	1451374	2025-10-23	World	UEFA Europa Conference League	Rapid Vienna	Fiorentina	a-win	0	3	13	3	17	7	2	5	0	1	2	1	0	0	42.00	58.00	15	14	\N	\N	\N	36	8	2025-11-20 12:03:51.312686	0.66	1.64	0	1	a-win	yes
2482	1451377	2025-10-23	World	UEFA Europa Conference League	Drita	Omonia Nicosia	draw	1	1	4	2	14	5	2	8	3	3	3	4	0	0	39.00	61.00	15	20	\N	\N	\N	13	29	2025-11-20 12:03:51.463538	0.24	1.15	1	1	draw	yes
2483	1451385	2025-10-23	World	UEFA Europa Conference League	Crystal Palace	AEK Larnaca	a-win	0	1	15	1	4	2	8	2	3	1	2	2	0	0	67.00	33.00	16	16	\N	\N	\N	9	4	2025-11-20 12:03:51.638899	1.66	0.17	0	0	draw	yes
3789	1423487	2025-08-05	England	FA Cup	Bedfont Sports	Guernsey	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:16:42.486685	\N	\N	0	0	draw	no
2484	1451383	2025-10-23	World	UEFA Europa Conference League	FSV Mainz 05	Zrinjski	h-win	1	0	15	4	2	0	7	2	2	1	1	4	0	1	61.00	39.00	13	13	\N	\N	\N	3	26	2025-11-20 12:03:51.821333	2.62	0.05	1	0	h-win	yes
2485	1451381	2025-10-23	World	UEFA Europa Conference League	Universitatea Craiova	FC Noah	draw	1	1	6	2	16	4	2	4	2	3	2	1	0	0	48.00	52.00	23	8	\N	\N	\N	20	17	2025-11-20 12:03:52.012161	0.64	1.37	1	0	h-win	yes
2486	1451386	2025-10-23	World	UEFA Europa Conference League	Shamrock Rovers	Celje	a-win	0	2	11	3	14	4	4	3	1	2	3	2	0	0	43.00	57.00	14	14	\N	\N	\N	31	2	2025-11-20 12:03:52.193195	0.83	2.08	0	2	a-win	yes
2487	1451379	2025-10-23	World	UEFA Europa Conference League	Lincoln Red Imps FC	Lech Poznan	h-win	2	1	12	3	20	5	4	6	2	0	2	1	0	0	38.00	62.00	15	17	\N	\N	\N	22	23	2025-11-20 12:03:52.366894	1.03	2.89	1	0	h-win	yes
2488	1451380	2025-10-23	World	UEFA Europa Conference League	Sigma Olomouc	Raków Częstochowa	draw	1	1	8	1	14	6	3	2	1	1	3	3	0	0	47.00	53.00	14	9	\N	\N	\N	19	12	2025-11-20 12:03:52.556947	0.28	1.19	0	0	draw	yes
2489	1451382	2025-10-23	World	UEFA Europa Conference League	Samsunspor	Dynamo Kyiv	h-win	3	0	14	5	5	0	4	6	1	1	0	2	0	0	48.00	52.00	6	10	\N	\N	\N	1	24	2025-11-20 12:03:52.731994	2.50	0.73	2	0	h-win	yes
2490	1451384	2025-10-23	World	UEFA Europa Conference League	Hamrun Spartans	Lausanne	a-win	0	1	15	1	10	5	6	4	5	2	3	4	0	0	52.00	48.00	13	17	\N	\N	\N	35	5	2025-11-20 12:03:52.911994	1.83	1.03	0	1	a-win	yes
2491	1451372	2025-10-24	World	UEFA Europa Conference League	HNK Rijeka	Sparta Praha	h-win	1	0	8	2	10	3	4	3	3	1	2	5	0	0	43.00	57.00	8	16	\N	\N	\N	18	16	2025-11-20 12:03:53.088174	0.60	0.72	0	0	draw	yes
2492	1451394	2025-11-06	World	UEFA Europa Conference League	FSV Mainz 05	Fiorentina	h-win	2	1	13	4	12	4	3	2	1	1	3	3	0	0	44.00	56.00	19	12	\N	\N	\N	3	8	2025-11-20 12:03:53.250555	1.97	1.76	0	1	a-win	yes
2493	1451388	2025-11-06	World	UEFA Europa Conference League	Shakhtar Donetsk	Breidablik	h-win	2	0	16	4	5	0	8	2	3	0	0	2	0	0	74.00	26.00	7	8	\N	\N	\N	10	32	2025-11-20 12:03:53.42162	1.21	0.45	1	0	h-win	yes
2494	1451387	2025-11-06	World	UEFA Europa Conference League	AEK Athens FC	Shamrock Rovers	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	15	31	2025-11-20 12:03:53.451342	\N	\N	0	1	a-win	yes
2495	1451392	2025-11-06	World	UEFA Europa Conference League	AEK Larnaca	Aberdeen	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	33	2025-11-20 12:03:53.471119	\N	\N	0	0	draw	yes
2496	1451390	2025-11-06	World	UEFA Europa Conference League	Sparta Praha	Raków Częstochowa	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16	12	2025-11-20 12:03:53.484988	\N	\N	0	0	draw	yes
2497	1452161	2025-11-06	World	UEFA Europa Conference League	KuPS	Slovan Bratislava	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	11	34	2025-11-20 12:03:53.502398	\N	\N	1	1	draw	yes
2498	1451393	2025-11-06	World	UEFA Europa Conference League	Samsunspor	Hamrun Spartans	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	35	2025-11-20 12:03:53.51537	\N	\N	1	0	h-win	yes
2499	1451389	2025-11-06	World	UEFA Europa Conference League	FC Noah	Sigma Olomouc	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	17	19	2025-11-20 12:03:53.527913	\N	\N	1	2	a-win	yes
2500	1451391	2025-11-06	World	UEFA Europa Conference League	Celje	Legia Warszawa	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	25	2025-11-20 12:03:53.535079	\N	\N	0	1	a-win	yes
2501	1451401	2025-11-06	World	UEFA Europa Conference League	Crystal Palace	AZ Alkmaar	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	27	2025-11-20 12:03:53.544505	\N	\N	2	0	h-win	yes
2502	1451399	2025-11-06	World	UEFA Europa Conference League	BK Hacken	Strasbourg	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	28	7	2025-11-20 12:03:53.554272	\N	\N	0	1	a-win	yes
2503	1451397	2025-11-06	World	UEFA Europa Conference League	Dynamo Kyiv	Zrinjski	h-win	6	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	24	26	2025-11-20 12:03:53.56059	\N	\N	1	0	h-win	yes
2504	1451396	2025-11-06	World	UEFA Europa Conference League	Shkendija	Jagiellonia	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	21	14	2025-11-20 12:03:53.566273	\N	\N	0	0	draw	yes
2505	1451398	2025-11-06	World	UEFA Europa Conference League	Lincoln Red Imps FC	HNK Rijeka	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	22	18	2025-11-20 12:03:53.573494	\N	\N	0	1	a-win	yes
2506	1451402	2025-11-06	World	UEFA Europa Conference League	Rayo Vallecano	Lech Poznan	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	23	2025-11-20 12:03:53.579275	\N	\N	0	2	a-win	yes
2507	1451403	2025-11-06	World	UEFA Europa Conference League	Rapid Vienna	Universitatea Craiova	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	36	20	2025-11-20 12:03:53.587482	\N	\N	0	1	a-win	yes
2508	1451395	2025-11-06	World	UEFA Europa Conference League	Lausanne	Omonia Nicosia	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	29	2025-11-20 12:03:53.59396	\N	\N	1	1	draw	yes
2509	1451400	2025-11-06	World	UEFA Europa Conference League	Shelbourne	Drita	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	30	13	2025-11-20 12:03:53.600556	\N	\N	0	0	draw	yes
3790	1423511	2025-08-05	England	FA Cup	Welwyn	Ware	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:16:42.654705	\N	\N	0	0	draw	no
3791	1449968	2025-08-30	England	FA Cup	Widnes	Congleton Town	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:16:42.82212	\N	\N	0	0	draw	no
3792	1419291	2025-08-01	England	FA Cup	Pickering Town	Penrith AFC	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:16:43.080618	\N	\N	0	0	draw	yes
3793	1419290	2025-08-01	England	FA Cup	Bootle	1874 Northwich	h-win	4	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:16:43.341283	\N	\N	0	0	draw	yes
3794	1419292	2025-08-01	England	FA Cup	Enfield 1893	Wormley Rovers	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:16:43.587613	\N	\N	0	0	draw	yes
3795	1419293	2025-08-01	England	FA Cup	Roman Glass St George	Nailsea & Tickenham	h-win	7	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:16:43.825116	\N	\N	0	0	draw	yes
3796	1419480	2025-08-01	England	FA Cup	Stone Old Alleynians	Sutton Coldfield Town	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:16:44.075234	\N	\N	0	0	draw	yes
3797	1419363	2025-08-01	England	FA Cup	Belper United	Uttoxeter Town	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:16:44.309075	\N	\N	0	0	draw	yes
3798	1419445	2025-08-01	England	FA Cup	Wokingham Town	Brislington	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:16:44.549777	\N	\N	0	0	draw	yes
3799	1419294	2025-08-02	England	FA Cup	Hamworthy Recreation	Hartley Wintney	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:16:44.798559	\N	\N	0	0	draw	yes
3800	1419295	2025-08-02	England	FA Cup	Guernsey	Bedfont Sports	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:16:45.05918	\N	\N	0	0	draw	yes
3801	1419407	2025-08-02	England	FA Cup	Bury	South Liverpool	h-win	6	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:16:45.302725	\N	\N	0	0	draw	yes
3802	1419357	2025-08-02	England	FA Cup	Haringey Borough	Halstead Town	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:16:45.561283	\N	\N	0	0	draw	yes
3803	1419497	2025-08-02	England	FA Cup	Leatherhead	Phoenix Sports	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:16:45.806333	\N	\N	0	0	draw	yes
3804	1419440	2025-08-02	England	FA Cup	Westfields	Atherstone Town	a-win	2	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:16:46.068061	\N	\N	0	0	draw	yes
3805	1419313	2025-08-02	England	FA Cup	Barking	Grays Athletic	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:16:46.346583	\N	\N	0	0	draw	yes
3806	1419366	2025-08-02	England	FA Cup	Bedworth United	Brocton	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:16:46.610829	\N	\N	0	0	draw	yes
3807	1419398	2025-08-02	England	FA Cup	Bideford	Wellington AFC	h-win	4	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:16:46.851225	\N	\N	0	0	draw	yes
3808	1419492	2025-08-02	England	FA Cup	Cinderford Town	Amersham Town	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:16:47.137029	\N	\N	0	0	draw	yes
3809	1419312	2025-08-02	England	FA Cup	East Grinstead Town	Eastbourne United	a-win	1	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:16:47.384703	\N	\N	0	0	draw	yes
3810	1419306	2025-08-02	England	FA Cup	Glossop North End	St Helens	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:16:47.633476	\N	\N	0	0	draw	yes
3811	1419351	2025-08-02	England	FA Cup	Histon	Thetford Town	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:16:47.892011	\N	\N	0	0	draw	yes
3812	1419349	2025-08-02	England	FA Cup	Hythe Town	Littlehampton Town	a-win	2	5	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:16:48.133359	\N	\N	0	0	draw	yes
3813	1419387	2025-08-02	England	FA Cup	Melksham Town	AFC Portchester	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:16:48.381385	\N	\N	0	0	draw	yes
3814	1419308	2025-08-02	England	FA Cup	Newcastle Town	Stourport Swifts	h-win	4	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:16:48.654242	\N	\N	0	0	draw	yes
3815	1419330	2025-08-02	England	FA Cup	Northwood	Egham Town	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:16:48.88342	\N	\N	0	0	draw	yes
3816	1419486	2025-08-02	England	FA Cup	Paulton Rovers	Hamble Club	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:16:49.136067	\N	\N	0	0	draw	yes
3817	1419296	2025-08-02	England	FA Cup	South Park	Newhaven	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:16:49.448675	\N	\N	0	0	draw	yes
3818	1419386	2025-08-02	England	FA Cup	Thatcham Town	Petersfield Town	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:16:49.732161	\N	\N	0	0	draw	yes
3819	1419309	2025-08-02	England	FA Cup	Willand Rovers	Barnstaple Town	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:16:50.010254	\N	\N	0	0	draw	yes
3820	1419432	2025-08-02	England	FA Cup	Witham Town	Frenford	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:16:50.277928	\N	\N	0	0	draw	yes
3821	1419392	2025-08-02	England	FA Cup	AFC Kempston Rovers	Arlesey Town	a-win	1	5	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:16:50.546014	\N	\N	0	0	draw	yes
3822	1419469	2025-08-02	England	FA Cup	Biggleswade	Welwyn Garden City	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:16:50.81677	\N	\N	0	0	draw	yes
3823	1419503	2025-08-02	England	FA Cup	Brighouse Town	Frickley Athletic	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:16:51.06343	\N	\N	0	0	draw	yes
3824	1419350	2025-08-02	England	FA Cup	Cirencester Town	Reading City	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:16:51.293534	\N	\N	0	0	draw	yes
3825	1419452	2025-08-02	England	FA Cup	City of Liverpool	Euxton Villa	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:16:51.540681	\N	\N	0	0	draw	yes
3826	1419447	2025-08-02	England	FA Cup	Coleshill Town	Nuneaton Town	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:16:51.815212	\N	\N	0	0	draw	yes
3827	1419331	2025-08-02	England	FA Cup	Daventry Town	Leicester Nirvana	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:16:52.066536	\N	\N	0	0	draw	yes
3828	1419320	2025-08-02	England	FA Cup	Haywards Heath Town	Ashford United	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:16:52.306817	\N	\N	0	0	draw	yes
3829	1419352	2025-08-02	England	FA Cup	Hertford Town	London Lions	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:16:52.552625	\N	\N	0	0	draw	yes
3830	1419377	2025-08-02	England	FA Cup	Hullbridge Sports	Basildon United	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:16:52.807676	\N	\N	0	0	draw	yes
3831	1419498	2025-08-02	England	FA Cup	Kidlington	Clevedon Town	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:16:53.093395	\N	\N	0	0	draw	yes
3832	1419364	2025-08-02	England	FA Cup	Kidsgrove Athletic	Rugby Borough	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:16:53.35413	\N	\N	0	0	draw	yes
3833	1419348	2025-08-02	England	FA Cup	Lincoln United	Northampton ON Chenecks	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:16:53.610266	\N	\N	0	0	draw	yes
3834	1419422	2025-08-02	England	FA Cup	Maldon & Tiptree	Buckhurst Hill	h-win	5	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:16:53.862317	\N	\N	0	0	draw	yes
3835	1419499	2025-08-02	England	FA Cup	Mangotsfield United	Bristol Manor Farm	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:16:54.129515	\N	\N	0	0	draw	yes
3836	1419467	2025-08-02	England	FA Cup	Marske United	Carlisle City	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:16:54.398361	\N	\N	0	0	draw	yes
3837	1419399	2025-08-02	England	FA Cup	Moneyfields	Brockenhurst	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:16:54.669953	\N	\N	0	0	draw	yes
3838	1419382	2025-08-02	England	FA Cup	North Leigh	Risborough Rangers	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:16:54.931132	\N	\N	0	0	draw	yes
3839	1419389	2025-08-02	England	FA Cup	Runcorn Linnets	Clitheroe	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:16:55.171509	\N	\N	0	0	draw	yes
3840	1419329	2025-08-02	England	FA Cup	Sheffield	Albion Sports	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:16:55.427904	\N	\N	0	0	draw	yes
3841	1419464	2025-08-02	England	FA Cup	St Neots Town	Great Yarmouth Town	h-win	7	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:16:55.697588	\N	\N	0	0	draw	yes
3842	1419450	2025-08-02	England	FA Cup	Three Bridges	Shoreham	h-win	5	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:16:55.938539	\N	\N	0	0	draw	yes
3843	1419322	2025-08-02	England	FA Cup	Trafford	Barnoldswick Town	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:16:56.190035	\N	\N	0	0	draw	yes
3844	1419443	2025-08-02	England	FA Cup	Ware	Welwyn	h-win	5	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:16:56.460871	\N	\N	0	0	draw	yes
3845	1419362	2025-08-02	England	FA Cup	AFC Rushden & Diamonds	Grimsby Borough	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:16:56.716379	\N	\N	0	0	draw	yes
3846	1419493	2025-08-02	England	FA Cup	Beaconsfield Town	Larkhall Athletic	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:16:56.979736	\N	\N	0	0	draw	yes
3847	1419370	2025-08-02	England	FA Cup	Grantham Town	Newark Town	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:16:57.2431	\N	\N	0	0	draw	yes
3848	1419434	2025-08-02	England	FA Cup	Stafford Rangers	Lutterworth Town	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:16:57.508364	\N	\N	0	0	draw	yes
3849	1419302	2025-08-02	England	FA Cup	Witton Albion	Cheadle Town	h-win	4	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:16:57.761204	\N	\N	0	0	draw	yes
3850	1419423	2025-08-02	England	FA Cup	Bradford (Park Avenue)	Mossley	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:16:58.018826	\N	\N	0	0	draw	yes
3851	1419337	2025-08-02	England	FA Cup	AFC Croydon Athletic	Roffey	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:16:58.274942	\N	\N	0	0	draw	yes
3852	1419466	2025-08-02	England	FA Cup	AFC Stoneham	Fleet Town	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:16:58.524714	\N	\N	0	0	draw	yes
3853	1419451	2025-08-02	England	FA Cup	AFC Wulfrunians	Shepshed Dynamo	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:16:58.775106	\N	\N	0	0	draw	yes
3854	1419441	2025-08-02	England	FA Cup	Abbey Hey	AFC Liverpool	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:16:59.022985	\N	\N	0	0	draw	yes
3855	1419416	2025-08-02	England	FA Cup	Abbey Rangers	Corinthian-Casuals	a-win	2	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:16:59.263642	\N	\N	0	0	draw	yes
3856	1419437	2025-08-02	England	FA Cup	Andover New Street	New Milton Town	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:16:59.546967	\N	\N	0	0	draw	yes
3857	1419375	2025-08-02	England	FA Cup	Ardley United	Aylesbury United	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:16:59.815054	\N	\N	0	0	draw	yes
3858	1419485	2025-08-02	England	FA Cup	Aylesbury Vale Dynamos	Abingdon United	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:00.101267	\N	\N	0	0	draw	yes
3859	1419401	2025-08-02	England	FA Cup	Badshot Lea	Steyning Town	a-win	3	6	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:00.375741	\N	\N	0	0	draw	yes
3860	1419489	2025-08-02	England	FA Cup	Baffins Milton Rovers	Shaftesbury Town	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:00.62858	\N	\N	0	0	draw	yes
3861	1419411	2025-08-02	England	FA Cup	Baldock Town	Little Oakley	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:00.901915	\N	\N	0	0	draw	yes
3862	1419391	2025-08-02	England	FA Cup	Balham	Faversham Town	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:01.157953	\N	\N	0	0	draw	yes
3863	1419460	2025-08-02	England	FA Cup	Bashley	East Cowes Victoria	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:01.430472	\N	\N	0	0	draw	yes
3864	1419381	2025-08-02	England	FA Cup	Bearsted	Hackney Wick	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:01.684677	\N	\N	0	0	draw	yes
3865	1419491	2025-08-02	England	FA Cup	Bexhill United	Sheerwater	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:01.926708	\N	\N	0	0	draw	yes
3866	1419410	2025-08-02	England	FA Cup	Biggleswade United	Newport Pagnell Town	h-win	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:02.182752	\N	\N	0	0	draw	yes
3867	1419424	2025-08-02	England	FA Cup	Binfield	Winslow United	h-win	4	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:02.430562	\N	\N	0	0	draw	yes
3868	1419328	2025-08-02	England	FA Cup	Bishop Auckland	Whickham	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:02.669905	\N	\N	0	0	draw	yes
3869	1419482	2025-08-02	England	FA Cup	Boldmere St. Michaels	Abbey Hulton	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:02.91862	\N	\N	0	0	draw	yes
3870	1419449	2025-08-02	England	FA Cup	Bottesford Town	Melton Town	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:03.17921	\N	\N	0	0	draw	yes
3871	1419435	2025-08-02	England	FA Cup	Bradford Town	Bournemouth FC	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:03.452131	\N	\N	0	0	draw	yes
3872	1419496	2025-08-02	England	FA Cup	Broadbridge Heath	Cobham	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:03.697819	\N	\N	0	0	draw	yes
3873	1419332	2025-08-02	England	FA Cup	Burnham	Holyport	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:03.940681	\N	\N	0	0	draw	yes
3874	1419365	2025-08-02	England	FA Cup	Charnock Richard	Burscough	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:04.177609	\N	\N	0	0	draw	yes
3875	1419444	2025-08-02	England	FA Cup	Christchurch	Bemerton Heath Harleq.	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:04.447661	\N	\N	0	0	draw	yes
3876	1419347	2025-08-02	England	FA Cup	Cockfosters	Kings Langley	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:04.711938	\N	\N	0	0	draw	yes
3877	1419307	2025-08-02	England	FA Cup	Colney Heath	Woodford Town	a-win	0	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:04.978624	\N	\N	0	0	draw	yes
3878	1419488	2025-08-02	England	FA Cup	Cowes Sports	Laverstock & Ford	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:05.226498	\N	\N	0	0	draw	yes
3879	1419323	2025-08-02	England	FA Cup	Cribbs	Easington Sports	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:05.518157	\N	\N	0	0	draw	yes
3880	1419359	2025-08-02	England	FA Cup	Deeping Rangers	Wellingborough Town	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:05.755024	\N	\N	0	0	draw	yes
3881	1419315	2025-08-02	England	FA Cup	Dunstable Town	Great Wakering Rovers	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:06.025624	\N	\N	0	0	draw	yes
3882	1419301	2025-08-02	England	FA Cup	Eastbourne Town	Ashford Town (Middlesex)	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:06.268082	\N	\N	0	0	draw	yes
3883	1419298	2025-08-02	England	FA Cup	Edgware Town	British Airways	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:06.534796	\N	\N	0	0	draw	yes
3884	1419342	2025-08-02	England	FA Cup	Erith Town	Sporting Bengal United	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:06.785481	\N	\N	0	0	draw	yes
3885	1419318	2025-08-02	England	FA Cup	Eynesbury Rovers	Potton United	h-win	4	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:07.035713	\N	\N	0	0	draw	yes
3886	1419374	2025-08-02	England	FA Cup	Fakenham Town	Wroxham	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:07.290851	\N	\N	0	0	draw	yes
3887	1419500	2025-08-02	England	FA Cup	Fisher	Camberley Town	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:07.624827	\N	\N	0	0	draw	yes
3888	1419361	2025-08-02	England	FA Cup	Garforth Town	West Auckland Town	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:07.885247	\N	\N	0	0	draw	yes
3889	1419487	2025-08-02	England	FA Cup	Gorleston	Hadleigh United	h-win	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:07.983527	\N	\N	0	0	draw	yes
3890	1419335	2025-08-02	England	FA Cup	Guildford City	Sutton Common Rovers	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:07.995196	\N	\N	0	0	draw	yes
3891	1419425	2025-08-02	England	FA Cup	Guisborough Town	Consett	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.008372	\N	\N	0	0	draw	yes
3892	1419346	2025-08-02	England	FA Cup	Hallen	Highworth Town	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.016187	\N	\N	0	0	draw	yes
3893	1419456	2025-08-02	England	FA Cup	Handsworth Parramore	Silsden	a-win	1	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.027408	\N	\N	0	0	draw	yes
3894	1419419	2025-08-02	England	FA Cup	Hanley Town	Lichfield City	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.034922	\N	\N	0	0	draw	yes
3895	1419439	2025-08-02	England	FA Cup	Harpenden Town	Concord Rangers	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.044977	\N	\N	0	0	draw	yes
3896	1419442	2025-08-02	England	FA Cup	Harwich & Parkeston	AFC Dunstable	a-win	2	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.05548	\N	\N	0	0	draw	yes
3897	1419436	2025-08-02	England	FA Cup	Hassocks	Rayners Lane	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.062923	\N	\N	0	0	draw	yes
3898	1419316	2025-08-02	England	FA Cup	Haverhill Rovers	Wisbech Town	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.07331	\N	\N	0	0	draw	yes
3899	1419417	2025-08-02	England	FA Cup	Heanor Town	Dudley Town	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.080816	\N	\N	0	0	draw	yes
3900	1419324	2025-08-02	England	FA Cup	Hollands & Blair	Herne Bay	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.090408	\N	\N	0	0	draw	yes
3901	1419384	2025-08-02	England	FA Cup	Horley Town	Corinthian	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.098031	\N	\N	0	0	draw	yes
3902	1419372	2025-08-02	England	FA Cup	Hythe & Dibden	Portland United	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.108513	\N	\N	0	0	draw	yes
3903	1419461	2025-08-02	England	FA Cup	Irlam	Thackley	h-win	4	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.116015	\N	\N	0	0	draw	yes
3904	1419319	2025-08-02	England	FA Cup	Kirkley & Pakefield	Cambridge City	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.126301	\N	\N	0	0	draw	yes
3905	1419314	2025-08-02	England	FA Cup	Knaresborough Town	Bridlington Town	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.13426	\N	\N	0	0	draw	yes
3906	1419475	2025-08-02	England	FA Cup	Lancing	Crawley Down Gatwick	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.145308	\N	\N	0	0	draw	yes
3907	1419353	2025-08-02	England	FA Cup	Leighton Town	Benfleet	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.153442	\N	\N	0	0	draw	yes
3908	1419380	2025-08-02	England	FA Cup	Leverstock Green	Ilford	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.162799	\N	\N	0	0	draw	yes
3909	1419317	2025-08-02	England	FA Cup	Lingfield	Whitstable Town	a-win	2	7	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.172515	\N	\N	0	0	draw	yes
3910	1419462	2025-08-02	England	FA Cup	Liversedge	Wythenshawe Amateurs	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.180218	\N	\N	0	0	draw	yes
3911	1419344	2025-08-02	England	FA Cup	Longlevens	Fairford Town	a-win	1	5	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.190167	\N	\N	0	0	draw	yes
3912	1419304	2025-08-02	England	FA Cup	Loughborough University	Barton Town Old Boys	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.197799	\N	\N	0	0	draw	yes
3913	1419299	2025-08-02	England	FA Cup	Lydney Town	Royal Wootton	draw	3	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.207313	\N	\N	0	0	draw	yes
3914	1419448	2025-08-02	England	FA Cup	March Town United	Soham Town Rangers	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.214907	\N	\N	0	0	draw	yes
3915	1419415	2025-08-02	England	FA Cup	Mildenhall Town	Downham Town	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.226505	\N	\N	0	0	draw	yes
3916	1419325	2025-08-02	England	FA Cup	Mulbarton Wanderers	Dereham Town	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.234076	\N	\N	0	0	draw	yes
3917	1419472	2025-08-02	England	FA Cup	Newcastle Benfield	Pontefract Collieries	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.244545	\N	\N	0	0	draw	yes
3918	1419341	2025-08-02	England	FA Cup	North Shields	Newcastle Blue Star	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.254507	\N	\N	0	0	draw	yes
3919	1419409	2025-08-02	England	FA Cup	Oadby Town	Newark Flowserve	a-win	1	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.26211	\N	\N	0	0	draw	yes
3920	1419420	2025-08-02	England	FA Cup	Pagham	Horsham YMCA	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.273134	\N	\N	0	0	draw	yes
3921	1419321	2025-08-02	England	FA Cup	Peacehaven & Telscombe	Harefield United	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.280652	\N	\N	0	0	draw	yes
3922	1419404	2025-08-02	England	FA Cup	Penistone Church	Padiham	a-win	1	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.290344	\N	\N	0	0	draw	yes
3923	1419383	2025-08-02	England	FA Cup	Punjab United	Crowborough Athletic	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.300883	\N	\N	0	0	draw	yes
3924	1419405	2025-08-02	England	FA Cup	Racing Club Warwick	Droitwich Spa	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.309173	\N	\N	0	0	draw	yes
3925	1419494	2025-08-02	England	FA Cup	Raynes Park Vale	Forest Row	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.316777	\N	\N	0	0	draw	yes
3926	1419369	2025-08-02	England	FA Cup	Redhill	North Greenford United	a-win	0	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.327451	\N	\N	0	0	draw	yes
3927	1419400	2025-08-02	England	FA Cup	Romulus	Coventry Sphinx	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.335043	\N	\N	0	0	draw	yes
3928	1419360	2025-08-02	England	FA Cup	Rusthall	Westfield (Surrey)	a-win	2	5	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.345078	\N	\N	0	0	draw	yes
3929	1419490	2025-08-02	England	FA Cup	Saffron Walden Town	Harlow Town	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.356244	\N	\N	0	0	draw	yes
3930	1419428	2025-08-02	England	FA Cup	Saltash United	Torpoint Athletic	a-win	1	6	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.364684	\N	\N	0	0	draw	yes
3931	1419333	2025-08-02	England	FA Cup	Sheppey United	Metropolitan Police	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.374346	\N	\N	0	0	draw	yes
3932	1419403	2025-08-02	England	FA Cup	Sherwood Colliery	Bugbrooke St Michaels	h-win	4	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.382041	\N	\N	0	0	draw	yes
3933	1419426	2025-08-02	England	FA Cup	Shildon AFC	Ashington AFC	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.392861	\N	\N	0	0	draw	yes
3934	1419311	2025-08-02	England	FA Cup	Stanway Rovers	Romford	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.400481	\N	\N	0	0	draw	yes
3935	1419408	2025-08-02	England	FA Cup	Stotfold	Redbridge	a-win	0	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.410943	\N	\N	0	0	draw	yes
3936	1419373	2025-08-02	England	FA Cup	Stowmarket Town	Ely City	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.420678	\N	\N	0	0	draw	yes
3937	1419334	2025-08-02	England	FA Cup	Street	Brixham	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.428253	\N	\N	0	0	draw	yes
3938	1419355	2025-08-02	England	FA Cup	Tadley Calleva	Millbrook FC	h-win	4	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.437502	\N	\N	0	0	draw	yes
3939	1419406	2025-08-02	England	FA Cup	Takeley	Crawley Green	h-win	5	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.445624	\N	\N	0	0	draw	yes
3940	1419354	2025-08-02	England	FA Cup	Tavistock	St Austell	h-win	5	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.455072	\N	\N	0	0	draw	yes
3941	1419479	2025-08-02	England	FA Cup	Thornaby	Tadcaster Albion	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.46259	\N	\N	0	0	draw	yes
3942	1419378	2025-08-02	England	FA Cup	Thornbury Town	Virginia Water	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.471328	\N	\N	0	0	draw	yes
3943	1419390	2025-08-02	England	FA Cup	Tividale	Clay Cross	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.47875	\N	\N	0	0	draw	yes
3944	1419421	2025-08-02	England	FA Cup	Tring Athletic	West Essex	h-win	5	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.486684	\N	\N	0	0	draw	yes
3945	1419431	2025-08-02	England	FA Cup	Tunbridge Wells	Holmesdale	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.495537	\N	\N	0	0	draw	yes
3946	1419473	2025-08-02	England	FA Cup	Varndeanians	Tooting & Mitcham United	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.504746	\N	\N	0	0	draw	yes
3947	1419326	2025-08-02	England	FA Cup	Walthamstow	Brantham Athletic	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.512294	\N	\N	0	0	draw	yes
3948	1419358	2025-08-02	England	FA Cup	Westbury United	Sherborne Town	h-win	7	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.521685	\N	\N	0	0	draw	yes
3949	1419395	2025-08-02	England	FA Cup	Whitchurch Alport	Litherland Remyca	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.529603	\N	\N	0	0	draw	yes
3950	1419477	2025-08-02	England	FA Cup	White Ensign	Sawbridgeworth Town	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.53906	\N	\N	0	0	draw	yes
3951	1419338	2025-08-02	England	FA Cup	Whitley Bay	Heaton Stannington	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.546681	\N	\N	0	0	draw	yes
3952	1419478	2025-08-02	England	FA Cup	Winsford United	West Didsbury & Chorlton	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.556701	\N	\N	0	0	draw	yes
3953	1419433	2025-08-02	England	FA Cup	Chadderton	Stockport Town	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.564114	\N	\N	0	0	draw	yes
3954	1419476	2025-08-02	England	FA Cup	Crook Town AFC	Kendal Town	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.573139	\N	\N	0	0	draw	yes
3955	1419310	2025-08-02	England	FA Cup	Harrowby United	Bourne Town	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.580539	\N	\N	0	0	draw	yes
3956	1419305	2025-08-02	England	FA Cup	Hinckley AFC	Highgate United	h-win	4	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.589914	\N	\N	0	0	draw	yes
3957	1419297	2025-08-02	England	FA Cup	Ipswich Wanderers	Lakenheath	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.597434	\N	\N	0	0	draw	yes
3958	1419414	2025-08-02	England	FA Cup	Milton United	Didcot Town	a-win	0	6	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.60655	\N	\N	0	0	draw	yes
2663	1386551	2025-08-08	England	Championship	Birmingham	Ipswich	draw	1	1	11	3	7	1	1	4	1	0	2	3	0	0	51.00	49.00	16	22	\N	\N	\N	11	7	2025-11-20 14:03:37.480015	1.38	1.31	0	0	draw	yes
2664	1386553	2025-08-09	England	Championship	Southampton	Wrexham	h-win	2	1	27	10	10	2	7	3	1	2	2	2	0	0	75.00	25.00	12	13	\N	\N	\N	17	13	2025-11-20 14:03:37.646539	4.14	1.88	0	1	a-win	yes
2665	1386554	2025-08-09	England	Championship	Charlton	Watford	h-win	1	0	12	5	10	1	3	2	0	0	1	2	0	0	42.00	58.00	6	16	\N	\N	\N	9	15	2025-11-20 14:03:37.829439	1.16	0.72	0	0	draw	yes
2666	1386552	2025-08-09	England	Championship	Coventry	Hull City	draw	0	0	18	3	7	3	8	2	1	2	3	3	0	0	58.00	42.00	7	11	\N	\N	\N	1	5	2025-11-20 14:03:38.012066	1.43	0.43	0	0	draw	yes
2667	1386555	2025-08-09	England	Championship	West Brom	Blackburn	h-win	1	0	13	5	10	1	3	7	0	0	4	0	1	0	44.00	56.00	13	13	\N	\N	\N	14	19	2025-11-20 14:03:38.180933	1.19	1.25	1	0	h-win	yes
2668	1386557	2025-08-09	England	Championship	Middlesbrough	Swansea	h-win	1	0	6	3	3	1	7	2	0	6	2	5	0	0	54.00	46.00	15	15	\N	\N	\N	2	18	2025-11-20 14:03:38.346913	0.35	0.10	0	0	draw	yes
2669	1386560	2025-08-09	England	Championship	Norwich	Millwall	a-win	1	2	15	3	15	3	6	5	1	1	1	4	0	0	59.00	41.00	5	15	\N	\N	\N	23	6	2025-11-20 14:03:38.510279	1.04	2.09	0	0	draw	yes
2670	1386558	2025-08-09	England	Championship	QPR	Preston	draw	1	1	13	3	11	3	5	4	4	4	0	3	0	0	58.00	42.00	7	9	\N	\N	\N	16	4	2025-11-20 14:03:38.680797	0.94	0.84	1	0	h-win	yes
2671	1386556	2025-08-09	England	Championship	Stoke City	Derby	h-win	3	1	12	7	3	2	7	3	2	2	1	2	0	0	68.00	32.00	12	14	\N	\N	\N	3	10	2025-11-20 14:03:38.863948	1.09	0.39	0	0	draw	yes
2672	1386559	2025-08-09	England	Championship	Oxford United	Portsmouth	a-win	0	1	18	4	9	4	8	4	3	2	1	2	0	0	49.00	51.00	15	10	\N	\N	\N	21	20	2025-11-20 14:03:39.027984	1.37	1.21	0	1	a-win	yes
2673	1386561	2025-08-09	England	Championship	Sheffield Utd	Bristol City	a-win	1	4	20	6	9	5	14	3	2	2	0	0	0	0	74.00	26.00	10	10	\N	\N	\N	22	8	2025-11-20 14:03:39.19591	2.30	1.30	1	2	a-win	yes
2674	1386562	2025-08-10	England	Championship	Leicester	Sheffield Wednesday	h-win	2	1	27	13	7	3	13	3	0	1	0	2	0	1	75.00	25.00	6	13	\N	\N	\N	12	24	2025-11-20 14:03:39.366437	2.54	0.62	0	1	a-win	yes
2675	1386568	2025-08-16	England	Championship	Derby	Coventry	a-win	3	5	13	4	20	10	6	5	2	1	2	5	0	0	48.00	52.00	14	11	\N	\N	\N	10	1	2025-11-20 14:03:39.556495	1.43	3.24	2	2	draw	yes
2825	1386709	2025-11-04	England	Championship	Coventry	Sheffield Utd	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	22	2025-11-20 14:04:04.134081	\N	\N	0	1	a-win	yes
3959	1419340	2025-08-02	England	FA Cup	Parkgate	Eccleshill United	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.61457	\N	\N	0	0	draw	yes
3960	1419393	2025-08-02	England	FA Cup	West Allotment Celtic	Northallerton Town	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.623472	\N	\N	0	0	draw	yes
3961	1419468	2025-08-02	England	FA Cup	Alton Town	Wincanton Town	h-win	5	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.630786	\N	\N	0	0	draw	yes
3962	1419418	2025-08-02	England	FA Cup	Corsham Town	Slimbridge	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.639932	\N	\N	0	0	draw	yes
3963	1419455	2025-08-02	England	FA Cup	Downton	Fareham Town	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.647468	\N	\N	0	0	draw	yes
2676	1386565	2025-08-16	England	Championship	Portsmouth	Norwich	a-win	1	2	19	3	11	5	9	0	3	1	3	3	0	0	58.00	42.00	8	13	\N	\N	\N	20	23	2025-11-20 14:03:39.739526	1.76	1.96	0	2	a-win	yes
2677	1386564	2025-08-16	England	Championship	Wrexham	West Brom	a-win	2	3	15	3	17	5	5	5	2	1	2	0	0	0	51.00	49.00	5	7	\N	\N	\N	13	14	2025-11-20 14:03:39.937788	2.01	2.37	1	1	draw	yes
2678	1386571	2025-08-16	England	Championship	Watford	QPR	h-win	2	1	17	4	13	3	2	4	4	2	1	2	1	0	46.00	54.00	9	9	\N	\N	\N	15	16	2025-11-20 14:03:40.134221	2.06	0.50	2	1	h-win	yes
2679	1386566	2025-08-16	England	Championship	Bristol City	Charlton	draw	0	0	14	1	8	2	4	6	1	1	0	1	0	0	58.00	42.00	9	13	\N	\N	\N	8	9	2025-11-20 14:03:40.305665	0.73	0.96	0	0	draw	yes
2680	1386563	2025-08-16	England	Championship	Millwall	Middlesbrough	a-win	0	3	11	1	12	5	5	10	4	2	4	5	0	0	45.00	55.00	16	11	\N	\N	\N	6	2	2025-11-20 14:03:40.473868	0.60	0.99	0	0	draw	yes
2681	1386567	2025-08-16	England	Championship	Preston	Leicester	h-win	2	1	14	4	14	2	6	4	2	0	2	0	0	0	40.00	60.00	11	7	\N	\N	\N	4	12	2025-11-20 14:03:40.668362	2.48	0.92	1	0	h-win	yes
2682	1386569	2025-08-16	England	Championship	Blackburn	Birmingham	a-win	1	2	5	2	8	4	3	5	3	0	1	2	0	0	41.00	59.00	14	13	\N	\N	\N	19	11	2025-11-20 14:03:40.885747	0.43	2.00	0	0	draw	yes
2683	1386573	2025-08-16	England	Championship	Sheffield Wednesday	Stoke City	a-win	0	3	15	5	12	6	6	7	1	6	0	3	0	0	54.00	46.00	12	10	\N	\N	\N	24	3	2025-11-20 14:03:41.048944	1.50	2.06	0	1	a-win	yes
2684	1386574	2025-08-16	England	Championship	Swansea	Sheffield Utd	h-win	1	0	13	4	8	0	4	8	3	0	1	3	0	0	56.00	44.00	13	14	\N	\N	\N	18	22	2025-11-20 14:03:41.230843	1.34	0.58	0	0	draw	yes
2685	1386572	2025-08-17	England	Championship	Ipswich	Southampton	draw	1	1	14	1	11	3	4	5	3	0	2	2	0	0	50.00	50.00	7	20	\N	\N	\N	7	17	2025-11-20 14:03:41.416948	1.64	0.75	1	1	draw	yes
2686	1386570	2025-08-17	England	Championship	Hull City	Oxford United	h-win	3	2	19	7	11	6	10	4	2	2	1	1	0	0	75.00	25.00	7	8	\N	\N	\N	5	21	2025-11-20 14:03:41.580644	1.91	1.02	2	2	draw	yes
2687	1386580	2025-08-22	England	Championship	Derby	Bristol City	draw	1	1	5	2	11	3	4	5	2	1	3	0	0	0	52.00	48.00	15	5	\N	\N	\N	10	8	2025-11-20 14:03:41.767906	0.47	0.76	0	1	a-win	yes
2688	1386579	2025-08-23	England	Championship	Hull City	Blackburn	a-win	0	3	8	2	14	6	2	1	1	2	3	3	0	0	50.00	50.00	18	19	\N	\N	\N	5	19	2025-11-20 14:03:41.972211	0.52	3.03	0	1	a-win	yes
2689	1386575	2025-08-23	England	Championship	Swansea	Watford	draw	1	1	11	2	9	4	7	2	6	1	3	5	0	0	58.00	42.00	11	17	\N	\N	\N	18	15	2025-11-20 14:03:42.131597	0.68	0.41	0	1	a-win	yes
2690	1386577	2025-08-23	England	Championship	Charlton	Leicester	a-win	0	1	20	7	6	2	13	4	2	0	2	1	0	0	45.00	55.00	18	9	\N	\N	\N	9	12	2025-11-20 14:03:42.315994	1.63	0.49	0	0	draw	yes
2691	1386578	2025-08-23	England	Championship	Southampton	Stoke City	a-win	1	2	18	2	12	4	7	3	2	1	1	5	0	1	65.00	35.00	6	12	\N	\N	\N	17	3	2025-11-20 14:03:42.513766	2.59	1.50	0	0	draw	yes
2692	1386584	2025-08-23	England	Championship	Birmingham	Oxford United	h-win	1	0	16	1	6	1	4	1	2	5	0	0	0	0	66.00	34.00	11	17	\N	\N	\N	11	21	2025-11-20 14:03:42.715276	1.65	0.38	1	0	h-win	yes
2693	1386581	2025-08-23	England	Championship	Preston	Ipswich	h-win	1	0	2	1	15	2	3	6	2	5	6	2	0	0	28.00	72.00	14	5	\N	\N	\N	4	7	2025-11-20 14:03:42.889486	0.84	1.39	1	0	h-win	yes
2694	1386576	2025-08-23	England	Championship	West Brom	Portsmouth	draw	1	1	13	3	8	4	2	3	3	2	2	5	0	0	64.00	36.00	10	16	\N	\N	\N	14	20	2025-11-20 14:03:43.053345	0.59	0.94	1	0	h-win	yes
2695	1386582	2025-08-23	England	Championship	Sheffield Utd	Millwall	a-win	0	1	14	4	17	6	8	7	0	5	3	2	0	0	62.00	38.00	11	16	\N	\N	\N	22	6	2025-11-20 14:03:43.22162	1.30	1.40	0	1	a-win	yes
2696	1386583	2025-08-23	England	Championship	Norwich	Middlesbrough	a-win	1	2	14	3	11	4	5	3	6	3	0	3	1	0	59.00	41.00	11	14	\N	\N	\N	23	2	2025-11-20 14:03:43.378219	1.18	1.51	0	2	a-win	yes
2697	1386586	2025-08-23	England	Championship	Coventry	QPR	h-win	7	1	19	8	10	1	9	4	2	4	1	2	0	0	53.00	47.00	15	8	\N	\N	\N	1	16	2025-11-20 14:03:43.548327	1.27	0.61	5	0	h-win	yes
2698	1386585	2025-08-23	England	Championship	Wrexham	Sheffield Wednesday	draw	2	2	11	4	21	7	3	9	4	0	0	0	0	0	47.00	53.00	7	8	\N	\N	\N	13	24	2025-11-20 14:03:43.710618	1.30	2.67	2	0	h-win	yes
2699	1386587	2025-08-29	England	Championship	Leicester	Birmingham	h-win	2	0	5	2	11	1	1	7	0	1	3	3	0	0	45.00	55.00	11	16	\N	\N	\N	12	11	2025-11-20 14:03:43.898999	0.56	0.83	1	0	h-win	yes
2700	1386595	2025-08-30	England	Championship	Middlesbrough	Sheffield Utd	h-win	1	0	15	6	8	0	5	8	0	1	0	3	0	0	47.00	53.00	5	13	\N	\N	\N	2	22	2025-11-20 14:03:44.06903	1.09	0.44	0	0	draw	yes
2701	1386592	2025-08-30	England	Championship	QPR	Charlton	h-win	3	1	13	6	13	3	1	2	2	2	2	2	0	0	45.00	55.00	16	7	\N	\N	\N	16	9	2025-11-20 14:03:44.254956	1.43	0.84	1	0	h-win	yes
2702	1386594	2025-08-30	England	Championship	Stoke City	West Brom	a-win	0	1	13	3	12	3	5	5	3	0	1	2	0	0	52.00	48.00	7	11	\N	\N	\N	3	14	2025-11-20 14:03:44.437555	0.95	0.66	0	1	a-win	yes
2703	1386596	2025-08-30	England	Championship	Watford	Southampton	draw	2	2	10	4	12	7	4	5	1	5	2	5	0	0	55.00	45.00	14	12	\N	\N	\N	15	17	2025-11-20 14:03:44.619574	0.55	1.81	0	1	a-win	yes
2704	1386591	2025-08-30	England	Championship	Bristol City	Hull City	h-win	4	2	29	5	20	9	8	5	1	3	1	1	0	0	56.00	44.00	7	8	\N	\N	\N	8	5	2025-11-20 14:03:44.811514	3.49	2.60	3	1	h-win	yes
2705	1386597	2025-08-30	England	Championship	Ipswich	Derby	draw	2	2	18	5	10	2	6	3	0	0	2	7	0	0	69.00	31.00	14	14	\N	\N	\N	7	10	2025-11-20 14:03:45.003739	2.91	1.48	1	0	h-win	yes
2706	1386588	2025-08-30	England	Championship	Millwall	Wrexham	a-win	0	2	21	2	6	3	5	2	0	0	1	3	0	0	60.00	40.00	10	13	\N	\N	\N	6	13	2025-11-20 14:03:45.199616	1.76	0.55	0	0	draw	yes
2707	1386593	2025-08-30	England	Championship	Blackburn	Norwich	a-win	0	2	12	3	15	4	3	9	6	1	2	0	1	0	46.00	54.00	9	7	\N	\N	\N	19	23	2025-11-20 14:03:45.396963	1.92	2.09	0	1	a-win	yes
2708	1386598	2025-08-30	England	Championship	Sheffield Wednesday	Swansea	a-win	0	2	9	1	17	8	2	7	1	1	0	2	0	0	36.00	64.00	14	10	\N	\N	\N	24	18	2025-11-20 14:03:45.578133	0.45	1.31	0	0	draw	yes
2709	1386589	2025-08-30	England	Championship	Oxford United	Coventry	draw	2	2	14	3	15	6	0	5	5	4	1	2	0	0	37.00	63.00	13	10	\N	\N	\N	21	1	2025-11-20 14:03:45.784213	1.04	1.74	1	2	a-win	yes
2710	1386590	2025-08-30	England	Championship	Portsmouth	Preston	h-win	1	0	10	2	13	2	6	4	5	3	1	2	0	0	39.00	61.00	11	7	\N	\N	\N	20	4	2025-11-20 14:03:45.971348	1.58	1.01	1	0	h-win	yes
2711	1386603	2025-09-12	England	Championship	Ipswich	Sheffield Utd	h-win	5	0	21	11	10	2	3	5	1	0	0	2	0	0	47.00	53.00	11	15	\N	\N	\N	7	22	2025-11-20 14:03:46.160328	2.33	0.42	1	0	h-win	yes
2712	1386607	2025-09-13	England	Championship	Preston	Middlesbrough	draw	2	2	7	2	14	3	3	4	0	2	1	3	0	0	39.00	61.00	13	7	\N	\N	\N	4	2	2025-11-20 14:03:46.355598	0.75	1.52	1	0	h-win	yes
2713	1386601	2025-09-13	England	Championship	Charlton	Millwall	draw	1	1	14	3	15	3	3	4	1	0	3	1	1	0	36.00	64.00	12	18	\N	\N	\N	9	6	2025-11-20 14:03:46.514423	0.73	1.03	1	0	h-win	yes
2714	1386609	2025-09-13	England	Championship	Oxford United	Leicester	draw	2	2	19	2	8	5	4	4	2	4	1	2	0	1	55.00	45.00	10	11	\N	\N	\N	21	12	2025-11-20 14:03:46.673272	2.10	0.84	2	1	h-win	yes
2715	1386606	2025-09-13	England	Championship	Watford	Blackburn	a-win	0	1	14	1	14	5	5	7	4	0	1	2	0	0	51.00	49.00	12	14	\N	\N	\N	15	19	2025-11-20 14:03:46.869886	0.75	1.45	0	0	draw	yes
2716	1386602	2025-09-13	England	Championship	West Brom	Derby	a-win	0	1	18	4	4	1	11	0	2	0	1	2	0	0	68.00	32.00	8	10	\N	\N	\N	14	10	2025-11-20 14:03:47.072244	1.15	0.32	0	0	draw	yes
2717	1386599	2025-09-13	England	Championship	Sheffield Wednesday	Bristol City	a-win	0	3	6	0	9	4	4	1	1	3	2	0	0	0	50.00	50.00	19	9	\N	\N	\N	24	8	2025-11-20 14:03:47.262012	0.83	1.39	0	3	a-win	yes
2718	1386605	2025-09-13	England	Championship	Stoke City	Birmingham	h-win	1	0	8	3	7	0	5	3	6	1	3	1	0	0	42.00	58.00	11	11	\N	\N	\N	3	11	2025-11-20 14:03:47.454756	0.49	0.52	1	0	h-win	yes
2719	1386600	2025-09-13	England	Championship	Swansea	Hull City	draw	2	2	9	2	15	6	5	2	2	1	1	1	0	0	65.00	35.00	8	5	\N	\N	\N	18	5	2025-11-20 14:03:47.648424	1.00	1.61	1	1	draw	yes
2720	1386608	2025-09-13	England	Championship	Coventry	Norwich	draw	1	1	28	4	4	1	11	2	3	4	2	6	0	0	64.00	36.00	12	7	\N	\N	\N	1	23	2025-11-20 14:03:47.816852	3.68	0.18	0	1	a-win	yes
2721	1386610	2025-09-13	England	Championship	Wrexham	QPR	a-win	1	3	21	8	15	6	12	9	3	2	1	0	0	0	61.00	39.00	5	10	\N	\N	\N	13	16	2025-11-20 14:03:47.997102	2.02	1.43	0	2	a-win	yes
2722	1386604	2025-09-14	England	Championship	Southampton	Portsmouth	draw	0	0	9	1	10	1	7	5	1	1	4	2	0	0	60.00	40.00	16	14	\N	\N	\N	17	20	2025-11-20 14:03:48.18843	1.18	0.94	0	0	draw	yes
2723	1386618	2025-09-19	England	Championship	Middlesbrough	West Brom	h-win	2	1	9	4	15	3	2	3	1	5	0	0	0	0	41.00	59.00	3	7	\N	\N	\N	2	14	2025-11-20 14:03:48.360973	0.96	0.89	1	0	h-win	yes
2724	1386611	2025-09-20	England	Championship	Leicester	Coventry	draw	0	0	17	9	11	3	10	3	2	1	0	3	0	0	59.00	41.00	8	11	\N	\N	\N	12	1	2025-11-20 14:03:48.570404	1.22	0.41	0	0	draw	yes
2725	1386616	2025-09-20	England	Championship	Birmingham	Swansea	h-win	1	0	23	7	9	2	7	2	3	3	5	4	0	0	50.00	50.00	13	11	\N	\N	\N	11	18	2025-11-20 14:03:48.753777	2.41	1.43	0	0	draw	yes
2726	1386621	2025-09-20	England	Championship	QPR	Stoke City	h-win	1	0	14	7	7	1	3	6	1	1	5	3	0	0	35.00	65.00	8	13	\N	\N	\N	16	3	2025-11-20 14:03:48.931323	1.33	1.09	0	0	draw	yes
2727	1386614	2025-09-20	England	Championship	Sheffield Utd	Charlton	a-win	0	1	13	1	13	4	6	1	1	2	1	3	0	0	63.00	37.00	14	18	\N	\N	\N	22	9	2025-11-20 14:03:49.115451	0.60	0.77	0	0	draw	yes
2728	1386619	2025-09-20	England	Championship	Hull City	Southampton	h-win	3	1	11	4	14	4	1	6	1	2	5	3	0	0	29.00	71.00	15	10	\N	\N	\N	5	17	2025-11-20 14:03:49.281625	2.13	1.07	1	0	h-win	yes
2729	1386622	2025-09-20	England	Championship	Derby	Preston	a-win	0	1	7	2	10	6	3	4	4	1	2	2	0	0	48.00	52.00	10	7	\N	\N	\N	10	4	2025-11-20 14:03:49.430021	0.34	0.90	0	1	a-win	yes
2730	1386617	2025-09-20	England	Championship	Norwich	Wrexham	a-win	2	3	14	5	11	8	2	3	1	2	1	3	0	0	62.00	38.00	6	9	\N	\N	\N	23	13	2025-11-20 14:03:49.586979	2.34	1.30	1	0	h-win	yes
2731	1386615	2025-09-20	England	Championship	Portsmouth	Sheffield Wednesday	a-win	0	2	25	5	13	8	11	5	3	1	1	5	0	0	70.00	30.00	5	10	\N	\N	\N	20	24	2025-11-20 14:03:49.750461	1.74	1.07	0	1	a-win	yes
2732	1386613	2025-09-21	England	Championship	Bristol City	Oxford United	a-win	1	3	12	2	18	6	8	5	5	3	4	1	0	0	59.00	41.00	15	14	\N	\N	\N	8	21	2025-11-20 14:03:49.92074	1.18	1.72	0	2	a-win	yes
2733	1386612	2025-09-22	England	Championship	Millwall	Watford	h-win	1	0	9	2	11	4	7	4	1	1	1	0	0	0	39.00	61.00	11	9	\N	\N	\N	6	15	2025-11-20 14:03:50.116417	0.70	0.76	1	0	h-win	yes
2734	1386627	2025-09-26	England	Championship	West Brom	Leicester	draw	1	1	11	5	13	1	3	3	4	1	2	5	0	0	41.00	59.00	13	16	\N	\N	\N	14	12	2025-11-20 14:03:50.292916	1.64	0.94	1	0	h-win	yes
2735	1386629	2025-09-27	England	Championship	Swansea	Millwall	draw	1	1	13	2	11	4	6	4	0	2	1	2	0	0	64.00	36.00	7	20	\N	\N	\N	18	6	2025-11-20 14:03:50.448897	1.34	0.88	1	1	draw	yes
2736	1386632	2025-09-27	England	Championship	Coventry	Birmingham	h-win	3	0	14	5	5	0	3	4	4	2	1	4	0	1	63.00	37.00	11	12	\N	\N	\N	1	11	2025-11-20 14:03:50.609617	2.13	0.19	1	0	h-win	yes
2737	1386633	2025-09-27	England	Championship	Wrexham	Derby	draw	1	1	10	5	5	3	4	3	2	1	1	5	0	0	55.00	45.00	9	16	\N	\N	\N	13	10	2025-11-20 14:03:50.774965	0.89	0.64	0	0	draw	yes
2738	1386624	2025-09-27	England	Championship	Watford	Hull City	h-win	2	1	21	8	11	4	6	6	2	3	1	5	0	0	55.00	45.00	7	16	\N	\N	\N	15	5	2025-11-20 14:03:50.960761	2.82	0.86	0	1	a-win	yes
2739	1386625	2025-09-27	England	Championship	Southampton	Middlesbrough	draw	1	1	14	2	7	1	6	3	1	2	1	6	0	0	55.00	45.00	11	17	\N	\N	\N	17	2	2025-11-20 14:03:51.180277	0.85	0.29	0	0	draw	yes
2740	1386626	2025-09-27	England	Championship	Ipswich	Portsmouth	h-win	2	1	14	5	7	3	5	4	4	1	1	2	0	0	50.00	50.00	15	11	\N	\N	\N	7	20	2025-11-20 14:03:51.333788	1.53	0.89	2	0	h-win	yes
2741	1386631	2025-09-27	England	Championship	Preston	Bristol City	draw	0	0	7	2	19	7	2	8	1	3	4	1	0	0	47.00	53.00	9	10	\N	\N	\N	4	8	2025-11-20 14:03:51.510309	0.42	2.32	0	0	draw	yes
2742	1386630	2025-09-27	England	Championship	Sheffield Wednesday	QPR	draw	1	1	14	5	14	5	5	4	0	1	2	2	0	0	50.00	50.00	12	19	\N	\N	\N	24	16	2025-11-20 14:03:51.70019	1.41	2.17	1	0	h-win	yes
2743	1386623	2025-09-27	England	Championship	Stoke City	Norwich	draw	1	1	23	6	6	3	12	1	3	1	0	3	0	0	58.00	42.00	11	9	\N	\N	\N	3	23	2025-11-20 14:03:51.884277	1.85	1.32	0	1	a-win	yes
2744	1386628	2025-09-27	England	Championship	Charlton	Blackburn	h-win	3	0	16	7	9	2	3	3	4	2	4	2	0	0	46.00	54.00	15	11	\N	\N	\N	9	19	2025-11-20 14:03:52.066786	1.47	0.55	1	0	h-win	yes
2745	1386634	2025-09-27	England	Championship	Oxford United	Sheffield Utd	a-win	0	1	14	3	6	2	3	5	1	1	1	1	0	0	56.00	44.00	10	13	\N	\N	\N	21	22	2025-11-20 14:03:52.241839	1.14	0.48	0	0	draw	yes
2746	1386635	2025-09-30	England	Championship	Leicester	Wrexham	draw	1	1	16	1	9	1	7	1	0	2	3	1	0	0	68.00	32.00	9	7	\N	\N	\N	12	13	2025-11-20 14:03:52.41735	1.07	0.91	1	0	h-win	yes
2747	1386637	2025-09-30	England	Championship	Birmingham	Sheffield Wednesday	draw	2	2	20	5	5	3	10	4	1	1	3	2	0	0	71.00	29.00	15	11	\N	\N	\N	11	24	2025-11-20 14:03:52.60212	1.33	0.42	1	1	draw	yes
2748	1386638	2025-09-30	England	Championship	Bristol City	Ipswich	draw	1	1	13	3	15	3	3	6	0	3	4	2	0	0	36.00	64.00	14	11	\N	\N	\N	8	7	2025-11-20 14:03:52.805079	1.38	1.38	1	0	h-win	yes
2749	1386636	2025-09-30	England	Championship	Sheffield Utd	Southampton	a-win	1	2	8	3	12	5	4	5	3	2	3	4	0	0	48.00	52.00	14	19	\N	\N	\N	22	17	2025-11-20 14:03:52.999023	0.90	2.02	1	0	h-win	yes
2750	1386639	2025-09-30	England	Championship	Hull City	Preston	draw	2	2	10	5	13	5	5	3	3	3	0	1	0	0	59.00	41.00	11	9	\N	\N	\N	5	4	2025-11-20 14:03:53.181236	1.82	1.43	0	2	a-win	yes
2751	1386641	2025-09-30	England	Championship	Blackburn	Swansea	a-win	1	2	14	3	7	4	7	3	4	2	3	2	0	0	51.00	49.00	15	13	\N	\N	\N	19	18	2025-11-20 14:03:53.386204	0.61	0.46	1	1	draw	yes
2752	1386640	2025-09-30	England	Championship	Middlesbrough	Stoke City	draw	0	0	12	4	18	5	5	8	0	3	2	0	0	0	55.00	45.00	8	5	\N	\N	\N	2	3	2025-11-20 14:03:53.544119	0.61	1.20	0	0	draw	yes
2753	1386642	2025-09-30	England	Championship	Derby	Charlton	draw	1	1	18	3	11	3	5	2	1	0	2	0	0	0	60.00	40.00	11	10	\N	\N	\N	10	9	2025-11-20 14:03:53.705008	1.81	0.60	0	1	a-win	yes
2754	1386646	2025-10-01	England	Championship	Millwall	Coventry	a-win	0	4	13	3	13	5	3	3	6	1	2	2	0	0	63.00	37.00	9	9	\N	\N	\N	6	1	2025-11-20 14:03:53.912507	1.33	3.60	0	1	a-win	yes
2755	1386644	2025-10-01	England	Championship	Norwich	West Brom	a-win	0	1	16	5	5	1	4	3	0	3	1	4	0	0	59.00	41.00	8	9	\N	\N	\N	23	14	2025-11-20 14:03:54.100016	1.62	0.96	0	1	a-win	yes
2756	1386645	2025-10-01	England	Championship	Portsmouth	Watford	draw	2	2	15	5	12	6	3	3	3	0	2	5	0	0	63.00	37.00	9	15	\N	\N	\N	20	15	2025-11-20 14:03:54.266012	1.12	1.88	1	0	h-win	yes
2757	1386643	2025-10-01	England	Championship	QPR	Oxford United	draw	0	0	13	1	9	0	9	1	4	2	3	1	0	0	56.00	44.00	12	11	\N	\N	\N	16	21	2025-11-20 14:03:54.423624	0.77	0.37	0	0	draw	yes
2758	1386648	2025-10-03	England	Championship	Wrexham	Birmingham	draw	1	1	12	4	8	3	5	5	3	2	0	2	0	0	42.00	58.00	4	8	\N	\N	\N	13	11	2025-11-20 14:03:54.587057	1.74	1.36	1	0	h-win	yes
2759	1386654	2025-10-04	England	Championship	Hull City	Sheffield Utd	h-win	1	0	5	2	13	4	4	9	1	2	2	2	0	0	38.00	62.00	13	13	\N	\N	\N	5	22	2025-11-20 14:03:54.741927	0.45	2.52	1	0	h-win	yes
2760	1386653	2025-10-04	England	Championship	Blackburn	Stoke City	draw	1	1	17	5	11	6	7	6	3	3	1	1	0	0	48.00	52.00	5	9	\N	\N	\N	19	3	2025-11-20 14:03:54.906076	1.88	0.81	0	0	draw	yes
2761	1386656	2025-10-04	England	Championship	Sheffield Wednesday	Coventry	a-win	0	5	9	0	21	10	13	8	1	3	1	1	0	0	52.00	48.00	9	3	\N	\N	\N	24	1	2025-11-20 14:03:55.069961	1.05	4.94	0	3	a-win	yes
2762	1386655	2025-10-04	England	Championship	Watford	Oxford United	h-win	2	1	27	10	15	5	9	3	1	0	3	4	0	0	57.00	43.00	6	9	\N	\N	\N	15	21	2025-11-20 14:03:55.255764	2.65	1.38	2	1	h-win	yes
2763	1386651	2025-10-04	England	Championship	Bristol City	QPR	a-win	1	2	11	1	8	2	4	1	1	0	5	1	0	0	58.00	42.00	9	8	\N	\N	\N	8	16	2025-11-20 14:03:55.440797	1.21	0.48	1	0	h-win	yes
2764	1386647	2025-10-04	England	Championship	Millwall	West Brom	h-win	3	0	11	4	10	1	4	5	2	2	1	2	0	0	39.00	61.00	17	8	\N	\N	\N	6	14	2025-11-20 14:03:55.651288	0.77	0.42	1	0	h-win	yes
2765	1386650	2025-10-04	England	Championship	Preston	Charlton	h-win	2	0	15	3	8	0	3	4	1	7	0	2	0	0	57.00	43.00	6	9	\N	\N	\N	4	9	2025-11-20 14:03:55.837972	1.81	0.54	0	0	draw	yes
2766	1386652	2025-10-04	England	Championship	Derby	Southampton	draw	1	1	9	5	13	6	3	5	1	2	4	2	0	0	37.00	63.00	11	9	\N	\N	\N	10	17	2025-11-20 14:03:56.030157	1.36	1.06	1	1	draw	yes
2767	1386657	2025-10-04	England	Championship	Swansea	Leicester	a-win	1	3	13	7	17	7	2	5	2	3	2	1	0	0	55.00	45.00	10	11	\N	\N	\N	18	12	2025-11-20 14:03:56.221006	1.84	1.65	0	1	a-win	yes
2768	1386649	2025-10-04	England	Championship	Portsmouth	Middlesbrough	h-win	1	0	8	1	12	1	2	8	0	2	2	1	0	0	38.00	62.00	13	6	\N	\N	\N	20	2	2025-11-20 14:03:56.438955	0.48	1.00	1	0	h-win	yes
2769	1386658	2025-10-05	England	Championship	Ipswich	Norwich	h-win	3	1	19	9	12	4	8	8	4	1	1	3	0	0	53.00	47.00	9	15	\N	\N	\N	7	23	2025-11-20 14:03:56.632037	1.80	0.46	2	1	h-win	yes
2770	1386662	2025-10-17	England	Championship	Middlesbrough	Ipswich	h-win	2	1	15	5	17	5	5	9	2	3	3	1	0	0	48.00	52.00	12	14	\N	\N	\N	2	7	2025-11-20 14:03:56.824211	1.86	1.97	1	0	h-win	yes
2771	1386659	2025-10-18	England	Championship	Southampton	Swansea	draw	0	0	21	8	6	1	5	3	2	3	0	4	0	0	58.00	42.00	21	6	\N	\N	\N	17	18	2025-11-20 14:03:56.988796	3.10	0.20	0	0	draw	yes
2772	1386664	2025-10-18	England	Championship	QPR	Millwall	a-win	1	2	20	3	5	5	8	3	3	2	2	4	0	0	58.00	42.00	20	5	\N	\N	\N	16	6	2025-11-20 14:03:57.153796	1.87	1.64	0	2	a-win	yes
2773	1386668	2025-10-18	England	Championship	Oxford United	Derby	h-win	1	0	19	7	6	1	4	12	1	3	4	1	0	0	49.00	51.00	19	6	\N	\N	\N	21	10	2025-11-20 14:03:57.332038	2.17	0.25	1	0	h-win	yes
2774	1386666	2025-10-18	England	Championship	Birmingham	Hull City	a-win	2	3	29	8	14	7	9	7	4	1	4	7	1	0	65.00	35.00	7	14	\N	\N	\N	11	5	2025-11-20 14:03:57.509813	2.85	1.15	1	2	a-win	yes
2775	1386661	2025-10-18	England	Championship	West Brom	Preston	h-win	2	1	16	6	17	5	8	4	3	1	2	1	0	0	49.00	51.00	10	0	\N	\N	\N	14	4	2025-11-20 14:03:57.706849	1.30	1.39	1	0	h-win	yes
2776	1386667	2025-10-18	England	Championship	Sheffield Utd	Watford	h-win	1	0	18	6	13	1	7	3	3	0	0	1	0	0	40.00	60.00	18	13	\N	\N	\N	22	15	2025-11-20 14:03:57.88533	2.11	1.09	0	0	draw	yes
2777	1386665	2025-10-18	England	Championship	Norwich	Bristol City	a-win	0	1	11	4	21	6	3	9	2	5	2	3	0	0	61.00	39.00	11	14	\N	\N	\N	23	8	2025-11-20 14:03:58.05029	0.58	2.06	0	0	draw	yes
2778	1386663	2025-10-18	England	Championship	Stoke City	Wrexham	h-win	1	0	12	3	5	3	6	4	2	1	2	0	0	0	56.00	44.00	12	5	\N	\N	\N	3	13	2025-11-20 14:03:58.214364	0.61	0.59	1	0	h-win	yes
2779	1386660	2025-10-18	England	Championship	Charlton	Sheffield Wednesday	h-win	2	1	12	5	12	4	2	4	2	2	1	2	0	1	40.00	60.00	12	12	\N	\N	\N	9	24	2025-11-20 14:03:58.380332	1.56	1.64	2	0	h-win	yes
2780	1386670	2025-10-18	England	Championship	Coventry	Blackburn	h-win	2	0	14	5	17	3	2	7	2	5	0	2	0	0	53.00	47.00	7	15	\N	\N	\N	1	19	2025-11-20 14:03:58.533343	0.88	1.14	0	0	draw	yes
2781	1386669	2025-10-18	England	Championship	Leicester	Portsmouth	draw	1	1	19	6	8	3	14	4	0	2	1	2	0	0	56.00	44.00	15	9	\N	\N	\N	12	20	2025-11-20 14:03:58.707241	1.53	0.87	1	0	h-win	yes
2782	1386678	2025-10-21	England	Championship	Ipswich	Charlton	a-win	0	3	30	5	15	8	16	3	2	2	0	3	0	0	67.00	33.00	7	11	\N	\N	\N	7	9	2025-11-20 14:03:58.884788	2.19	1.43	0	0	draw	yes
2783	1386671	2025-10-21	England	Championship	Millwall	Stoke City	h-win	2	0	15	7	10	3	3	2	1	2	2	1	0	0	41.00	59.00	13	7	\N	\N	\N	6	3	2025-11-20 14:03:59.044219	1.48	0.44	2	0	h-win	yes
2784	1386673	2025-10-21	England	Championship	Preston	Birmingham	a-win	0	1	17	6	9	2	9	3	2	1	2	5	0	0	62.00	38.00	8	14	\N	\N	\N	4	11	2025-11-20 14:03:59.209993	1.34	0.83	0	1	a-win	yes
2785	1386677	2025-10-21	England	Championship	Hull City	Leicester	h-win	2	1	9	6	18	4	1	7	0	0	1	2	0	0	36.00	64.00	8	12	\N	\N	\N	5	12	2025-11-20 14:03:59.355374	1.52	1.48	2	0	h-win	yes
2786	1386676	2025-10-21	England	Championship	Blackburn	Sheffield Utd	a-win	1	3	12	3	11	5	5	5	3	2	1	1	0	0	51.00	49.00	6	10	\N	\N	\N	19	22	2025-11-20 14:03:59.509804	0.79	1.13	1	0	h-win	yes
2787	1386675	2025-10-21	England	Championship	Derby	Norwich	h-win	1	0	8	3	17	3	5	13	3	3	2	1	0	0	34.00	66.00	13	7	\N	\N	\N	10	23	2025-11-20 14:03:59.66212	0.95	1.11	0	0	draw	yes
2788	1386672	2025-10-21	England	Championship	Portsmouth	Coventry	a-win	1	2	15	5	19	7	6	5	2	4	1	1	0	0	57.00	43.00	5	12	\N	\N	\N	20	1	2025-11-20 14:03:59.82567	0.63	2.41	0	1	a-win	yes
2789	1386674	2025-10-21	England	Championship	Bristol City	Southampton	h-win	3	1	13	4	14	7	2	3	0	3	1	2	0	0	33.00	67.00	10	11	\N	\N	\N	8	17	2025-11-20 14:03:59.990086	1.63	2.18	1	1	draw	yes
2790	1386681	2025-10-22	England	Championship	Watford	West Brom	h-win	2	1	19	5	9	4	4	4	1	0	0	2	0	0	40.00	60.00	12	8	\N	\N	\N	15	14	2025-11-20 14:04:00.176806	0.86	0.63	1	1	draw	yes
2791	1386679	2025-10-22	England	Championship	Swansea	QPR	a-win	0	1	11	2	15	4	6	3	1	4	1	4	1	0	53.00	47.00	8	9	\N	\N	\N	18	16	2025-11-20 14:04:00.367973	0.44	2.24	0	1	a-win	yes
2792	1386682	2025-10-22	England	Championship	Wrexham	Oxford United	h-win	1	0	11	6	6	2	6	3	1	1	3	1	1	0	48.00	52.00	12	12	\N	\N	\N	13	21	2025-11-20 14:04:00.551466	0.77	0.15	1	0	h-win	yes
2793	1386680	2025-10-22	England	Championship	Sheffield Wednesday	Middlesbrough	a-win	0	1	11	3	19	7	6	5	0	4	3	1	0	0	52.00	48.00	8	4	\N	\N	\N	24	2	2025-11-20 14:04:00.769386	0.70	1.57	0	1	a-win	yes
2794	1386686	2025-10-24	England	Championship	Preston	Sheffield Utd	h-win	3	2	15	3	12	3	2	4	0	3	4	1	0	0	47.00	53.00	14	11	\N	\N	\N	4	22	2025-11-20 14:04:00.930639	1.57	2.37	1	2	a-win	yes
2795	1386694	2025-10-25	England	Championship	Ipswich	West Brom	h-win	1	0	15	4	10	1	4	5	0	1	1	1	0	0	54.00	46.00	12	8	\N	\N	\N	7	14	2025-11-20 14:04:01.119327	2.22	0.39	0	0	draw	yes
2796	1386684	2025-10-25	England	Championship	Coventry	Watford	h-win	3	1	12	3	13	8	5	6	3	4	3	2	0	1	55.00	45.00	10	8	\N	\N	\N	1	15	2025-11-20 14:04:01.295468	1.31	2.61	3	0	h-win	yes
2797	1386687	2025-10-25	England	Championship	Portsmouth	Stoke City	a-win	0	1	14	3	11	2	6	2	4	3	2	3	0	0	48.00	52.00	8	15	\N	\N	\N	20	3	2025-11-20 14:04:01.479538	1.83	0.90	0	0	draw	yes
2798	1386685	2025-10-25	England	Championship	Bristol City	Birmingham	h-win	1	0	5	1	13	1	0	6	1	1	2	1	0	0	29.00	71.00	9	6	\N	\N	\N	8	11	2025-11-20 14:04:01.664789	0.27	0.69	1	0	h-win	yes
2799	1386683	2025-10-25	England	Championship	Millwall	Leicester	h-win	1	0	9	4	12	3	5	9	1	2	1	2	0	0	47.00	53.00	12	8	\N	\N	\N	6	12	2025-11-20 14:04:01.909426	1.51	0.76	1	0	h-win	yes
2800	1386688	2025-10-25	England	Championship	Hull City	Charlton	draw	1	1	15	4	11	5	6	2	0	0	2	1	0	0	48.00	52.00	8	9	\N	\N	\N	5	9	2025-11-20 14:04:02.100946	1.11	1.95	0	0	draw	yes
2801	1386690	2025-10-25	England	Championship	Blackburn	Southampton	h-win	2	1	18	6	12	5	6	5	1	3	3	1	0	1	51.00	49.00	13	7	\N	\N	\N	19	17	2025-11-20 14:04:02.278949	3.20	1.67	0	1	a-win	yes
2802	1386691	2025-10-25	England	Championship	Derby	QPR	h-win	1	0	12	4	6	1	5	2	1	1	2	2	0	0	38.00	62.00	13	10	\N	\N	\N	10	16	2025-11-20 14:04:02.437974	1.67	0.38	1	0	h-win	yes
2803	1386689	2025-10-25	England	Championship	Middlesbrough	Wrexham	draw	1	1	14	4	6	2	4	4	0	3	0	5	0	0	69.00	31.00	8	17	\N	\N	\N	2	13	2025-11-20 14:04:02.600534	0.77	0.68	0	1	a-win	yes
2804	1386692	2025-10-25	England	Championship	Sheffield Wednesday	Oxford United	a-win	1	2	17	5	11	4	8	3	2	4	0	0	0	0	67.00	33.00	11	11	\N	\N	\N	24	21	2025-11-20 14:04:02.796497	1.16	0.99	0	2	a-win	yes
2805	1386693	2025-10-25	England	Championship	Swansea	Norwich	h-win	2	1	9	3	7	3	2	3	1	1	3	1	0	0	42.00	58.00	13	12	\N	\N	\N	18	23	2025-11-20 14:04:02.969766	0.43	1.17	1	1	draw	yes
2806	1386706	2025-10-31	England	Championship	Wrexham	Coventry	h-win	3	2	13	7	18	5	3	6	1	2	2	1	0	0	46.00	54.00	19	0	\N	\N	\N	13	1	2025-11-20 14:04:03.123196	1.41	1.56	0	1	a-win	yes
2807	1386705	2025-11-01	England	Championship	Leicester	Blackburn	a-win	0	2	12	1	9	5	6	4	3	2	0	1	0	0	62.00	38.00	9	12	\N	\N	\N	12	19	2025-11-20 14:04:03.311926	1.24	1.91	0	1	a-win	yes
2808	1386696	2025-11-01	England	Championship	West Brom	Sheffield Wednesday	draw	0	0	13	6	5	2	8	3	1	0	1	1	0	0	62.00	38.00	17	14	\N	\N	\N	14	24	2025-11-20 14:04:03.495006	1.16	0.33	0	0	draw	yes
2809	1386703	2025-11-01	England	Championship	Norwich	Hull City	a-win	0	2	15	3	9	4	6	4	1	4	1	2	0	0	60.00	40.00	8	12	\N	\N	\N	23	5	2025-11-20 14:04:03.682465	2.90	1.72	0	0	draw	yes
2810	1386700	2025-11-01	England	Championship	Watford	Middlesbrough	h-win	3	0	8	4	14	4	1	7	0	2	2	1	0	0	45.00	55.00	15	11	\N	\N	\N	15	2	2025-11-20 14:04:03.857873	0.76	0.79	2	0	h-win	yes
2811	1386695	2025-11-01	England	Championship	Southampton	Preston	a-win	0	2	10	2	12	3	8	2	2	1	1	3	0	0	64.00	36.00	11	18	\N	\N	\N	17	4	2025-11-20 14:04:04.035387	0.53	2.24	0	1	a-win	yes
2812	1386702	2025-11-01	England	Championship	Birmingham	Portsmouth	h-win	4	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	11	20	2025-11-20 14:04:04.044313	\N	\N	1	0	h-win	yes
2813	1386701	2025-11-01	England	Championship	Sheffield Utd	Derby	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	22	10	2025-11-20 14:04:04.050047	\N	\N	0	1	a-win	yes
2814	1386698	2025-11-01	England	Championship	QPR	Ipswich	a-win	1	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16	7	2025-11-20 14:04:04.056786	\N	\N	1	1	draw	yes
2815	1386699	2025-11-01	England	Championship	Stoke City	Bristol City	h-win	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	8	2025-11-20 14:04:04.063698	\N	\N	3	0	h-win	yes
2816	1386697	2025-11-01	England	Championship	Charlton	Swansea	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	18	2025-11-20 14:04:04.069393	\N	\N	0	0	draw	yes
2817	1386704	2025-11-01	England	Championship	Oxford United	Millwall	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	21	6	2025-11-20 14:04:04.078601	\N	\N	1	1	draw	yes
2818	1386707	2025-11-04	England	Championship	Leicester	Middlesbrough	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	2	2025-11-20 14:04:04.084877	\N	\N	1	0	h-win	yes
2819	1386710	2025-11-04	England	Championship	Birmingham	Millwall	h-win	4	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	11	6	2025-11-20 14:04:04.093669	\N	\N	2	0	h-win	yes
2820	1386711	2025-11-04	England	Championship	Bristol City	Blackburn	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8	19	2025-11-20 14:04:04.099167	\N	\N	0	1	a-win	yes
2821	1386714	2025-11-04	England	Championship	Ipswich	Watford	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7	15	2025-11-20 14:04:04.104704	\N	\N	1	1	draw	yes
2822	1386712	2025-11-04	England	Championship	Derby	Hull City	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	10	5	2025-11-20 14:04:04.113481	\N	\N	1	0	h-win	yes
2823	1386713	2025-11-04	England	Championship	Charlton	West Brom	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	14	2025-11-20 14:04:04.119952	\N	\N	0	0	draw	yes
2824	1386708	2025-11-04	England	Championship	Oxford United	Stoke City	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	21	3	2025-11-20 14:04:04.128473	\N	\N	0	2	a-win	yes
2826	1386718	2025-11-05	England	Championship	Preston	Swansea	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	18	2025-11-20 14:04:04.140066	\N	\N	1	0	h-win	yes
2827	1386716	2025-11-05	England	Championship	QPR	Southampton	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16	17	2025-11-20 14:04:04.147635	\N	\N	0	0	draw	yes
2828	1386715	2025-11-05	England	Championship	Sheffield Wednesday	Norwich	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	24	23	2025-11-20 14:04:04.153336	\N	\N	1	0	h-win	yes
2829	1386717	2025-11-05	England	Championship	Portsmouth	Wrexham	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	20	13	2025-11-20 14:04:04.16063	\N	\N	0	0	draw	yes
2830	1386725	2025-11-07	England	Championship	Watford	Bristol City	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	15	8	2025-11-20 14:04:04.166344	\N	\N	1	1	draw	yes
2831	1386721	2025-11-08	England	Championship	Millwall	Preston	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	4	2025-11-20 14:04:04.17186	\N	\N	1	1	draw	yes
2832	1386727	2025-11-08	England	Championship	Hull City	Portsmouth	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	20	2025-11-20 14:04:04.180383	\N	\N	2	2	draw	yes
2833	1386724	2025-11-08	England	Championship	Blackburn	Derby	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	19	10	2025-11-20 14:04:04.186207	\N	\N	0	2	a-win	yes
2834	1386730	2025-11-08	England	Championship	Southampton	Sheffield Wednesday	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	17	24	2025-11-20 14:04:04.193345	\N	\N	2	1	h-win	yes
2835	1386729	2025-11-08	England	Championship	West Brom	Oxford United	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	14	21	2025-11-20 14:04:04.198957	\N	\N	0	0	draw	yes
2836	1386719	2025-11-08	England	Championship	Sheffield Utd	QPR	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	22	16	2025-11-20 14:04:04.204442	\N	\N	0	0	draw	yes
2837	1386726	2025-11-08	England	Championship	Middlesbrough	Birmingham	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	11	2025-11-20 14:04:04.21293	\N	\N	2	1	h-win	yes
2838	1386720	2025-11-08	England	Championship	Norwich	Leicester	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	23	12	2025-11-20 14:04:04.218501	\N	\N	0	0	draw	yes
2839	1386723	2025-11-08	England	Championship	Stoke City	Coventry	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	1	2025-11-20 14:04:04.226491	\N	\N	0	0	draw	yes
2840	1386728	2025-11-08	England	Championship	Swansea	Ipswich	a-win	1	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	18	7	2025-11-20 14:04:04.232297	\N	\N	0	1	a-win	yes
2841	1386722	2025-11-08	England	Championship	Wrexham	Charlton	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	13	9	2025-11-20 14:04:04.237827	\N	\N	0	0	draw	yes
2842	1386742	2025-11-21	England	Championship	Preston	Blackburn	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 14:04:04.246977	\N	\N	0	0	draw	no
2843	1386740	2025-11-22	England	Championship	Bristol City	Swansea	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 14:04:04.252742	\N	\N	0	0	draw	no
2844	1386732	2025-11-22	England	Championship	Charlton	Southampton	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 14:04:04.261328	\N	\N	0	0	draw	no
2845	1386737	2025-11-22	England	Championship	Coventry	West Brom	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 14:04:04.267179	\N	\N	0	0	draw	no
2846	1386736	2025-11-22	England	Championship	Leicester	Stoke City	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 14:04:04.272863	\N	\N	0	0	draw	no
2847	1386739	2025-11-22	England	Championship	Birmingham	Norwich	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 14:04:04.280714	\N	\N	0	0	draw	no
2848	1386731	2025-11-22	England	Championship	Ipswich	Wrexham	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 14:04:04.286402	\N	\N	0	0	draw	no
2849	1386735	2025-11-22	England	Championship	Derby	Watford	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 14:04:04.294801	\N	\N	0	0	draw	no
2850	1386734	2025-11-22	England	Championship	QPR	Hull City	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 14:04:04.300408	\N	\N	0	0	draw	no
2851	1386738	2025-11-22	England	Championship	Oxford United	Middlesbrough	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 14:04:04.305802	\N	\N	0	0	draw	no
2852	1386741	2025-11-22	England	Championship	Portsmouth	Millwall	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 14:04:04.313963	\N	\N	0	0	draw	no
2853	1386733	2025-11-23	England	Championship	Sheffield Wednesday	Sheffield Utd	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 14:04:04.319521	\N	\N	0	0	draw	no
2854	1380410	2025-08-01	Poland	Ekstraklasa	Zaglebie Lubin	Korona Kielce	draw	1	1	8	2	17	5	7	8	1	2	2	2	0	0	46.00	54.00	15	19	\N	\N	\N	7	9	2025-11-20 15:02:06.301251	1.11	1.86	0	0	draw	yes
2855	1380409	2025-08-01	Poland	Ekstraklasa	Wisla Plock	Piast Gliwice	h-win	2	0	10	3	6	1	8	6	4	0	2	4	0	0	30.00	70.00	10	11	\N	\N	\N	3	18	2025-11-20 15:02:06.490443	1.43	0.66	1	0	h-win	yes
2856	1380407	2025-08-02	Poland	Ekstraklasa	Nieciecza	Pogon Szczecin	draw	1	1	16	7	12	2	6	9	2	0	0	2	0	0	42.00	58.00	8	14	\N	\N	\N	17	13	2025-11-20 15:02:06.673454	1.64	1.26	1	0	h-win	yes
2857	1380408	2025-08-02	Poland	Ekstraklasa	Widzew Łódź	GKS Katowice	h-win	3	0	21	4	8	3	8	6	0	2	4	2	0	0	43.00	57.00	6	7	\N	\N	\N	12	14	2025-11-20 15:02:06.884092	2.18	1.02	1	0	h-win	yes
2858	1380403	2025-08-02	Poland	Ekstraklasa	Lech Poznan	Gornik Zabrze	h-win	2	1	12	5	12	1	6	8	0	1	2	1	0	0	56.00	44.00	9	5	\N	\N	\N	8	1	2025-11-20 15:02:07.061683	1.99	0.42	0	0	draw	yes
2859	1380402	2025-08-03	Poland	Ekstraklasa	Cracovia Krakow	Lechia Gdansk	draw	2	2	19	6	11	2	5	4	0	0	3	2	0	0	56.00	44.00	13	13	\N	\N	\N	6	16	2025-11-20 15:02:07.262655	\N	\N	1	1	draw	yes
2860	1380406	2025-08-03	Poland	Ekstraklasa	Radomiak Radom	Raków Częstochowa	h-win	3	1	12	6	12	5	1	7	0	3	3	3	0	0	36.00	64.00	20	14	\N	\N	\N	5	4	2025-11-20 15:02:07.453674	\N	\N	0	0	draw	yes
2861	1380404	2025-08-03	Poland	Ekstraklasa	Legia Warszawa	Arka Gdynia	draw	0	0	20	3	6	0	13	4	1	1	3	3	0	0	63.00	37.00	19	13	\N	\N	\N	11	10	2025-11-20 15:02:07.65016	\N	\N	0	0	draw	yes
2862	1380414	2025-08-08	Poland	Ekstraklasa	Korona Kielce	Radomiak Radom	h-win	3	0	13	3	7	3	2	5	3	2	5	3	0	0	43.00	57.00	15	16	\N	\N	\N	9	5	2025-11-20 15:02:07.84414	1.88	0.59	2	0	h-win	yes
2863	1380412	2025-08-08	Poland	Ekstraklasa	Gornik Zabrze	Nieciecza	a-win	0	1	25	5	7	2	7	2	1	0	3	3	0	0	62.00	38.00	12	15	\N	\N	\N	1	17	2025-11-20 15:02:08.037281	1.87	0.66	0	1	a-win	yes
2864	1380411	2025-08-09	Poland	Ekstraklasa	Arka Gdynia	Pogon Szczecin	h-win	2	1	11	5	13	3	6	5	1	0	3	3	0	0	44.00	56.00	13	14	\N	\N	\N	10	13	2025-11-20 15:02:08.222225	\N	\N	1	1	draw	yes
2865	1380419	2025-08-09	Poland	Ekstraklasa	Widzew Łódź	Wisla Plock	draw	1	1	15	6	5	1	5	0	1	1	2	3	0	0	61.00	39.00	7	12	\N	\N	\N	12	3	2025-11-20 15:02:08.414797	\N	\N	1	1	draw	yes
2866	1380413	2025-08-10	Poland	Ekstraklasa	Jagiellonia	Cracovia Krakow	h-win	5	2	15	8	12	4	10	5	1	1	2	3	0	1	63.00	37.00	14	17	\N	\N	\N	2	6	2025-11-20 15:02:08.608975	\N	\N	1	2	a-win	yes
2867	1380416	2025-08-10	Poland	Ekstraklasa	Legia Warszawa	GKS Katowice	h-win	3	1	20	7	7	6	5	7	1	1	3	1	0	0	58.00	42.00	11	13	\N	\N	\N	11	14	2025-11-20 15:02:08.804006	\N	\N	1	0	h-win	yes
2868	1380415	2025-08-11	Poland	Ekstraklasa	Lechia Gdansk	Motor Lublin	draw	3	3	18	9	14	4	3	8	0	2	2	2	0	0	53.00	47.00	11	12	\N	\N	\N	16	15	2025-11-20 15:02:09.007834	2.60	0.99	2	2	draw	yes
2869	1380428	2025-08-15	Poland	Ekstraklasa	Zaglebie Lubin	Lechia Gdansk	h-win	6	2	22	9	7	2	5	4	1	0	0	0	0	0	41.00	59.00	6	9	\N	\N	\N	7	16	2025-11-20 15:02:09.187124	\N	\N	2	1	h-win	yes
2870	1380420	2025-08-15	Poland	Ekstraklasa	Cracovia Krakow	Widzew Łódź	h-win	1	0	10	2	12	3	7	8	1	0	2	1	0	0	44.00	56.00	16	11	\N	\N	\N	6	12	2025-11-20 15:02:09.385035	\N	\N	0	0	draw	yes
2871	1380423	2025-08-16	Poland	Ekstraklasa	Motor Lublin	Piast Gliwice	draw	0	0	8	1	17	4	7	6	4	5	4	2	1	0	41.00	59.00	17	16	\N	\N	\N	15	18	2025-11-20 15:02:09.575087	\N	\N	0	0	draw	yes
2872	1380421	2025-08-16	Poland	Ekstraklasa	GKS Katowice	Arka Gdynia	h-win	4	1	24	10	12	3	8	5	1	0	1	4	0	0	42.00	58.00	19	12	\N	\N	\N	14	10	2025-11-20 15:02:09.773929	\N	\N	2	1	h-win	yes
2873	1380422	2025-08-16	Poland	Ekstraklasa	Lech Poznan	Korona Kielce	draw	1	1	18	8	16	2	6	0	2	2	1	1	0	0	65.00	35.00	12	10	\N	\N	\N	8	9	2025-11-20 15:02:09.959983	\N	\N	0	0	draw	yes
2874	1380424	2025-08-17	Poland	Ekstraklasa	Pogon Szczecin	Gornik Zabrze	a-win	0	3	14	3	20	6	6	9	1	1	2	0	0	0	53.00	47.00	11	16	\N	\N	\N	13	1	2025-11-20 15:02:10.154851	\N	\N	0	0	draw	yes
2875	1380425	2025-08-17	Poland	Ekstraklasa	Radomiak Radom	Jagiellonia	a-win	1	2	11	5	15	5	6	7	3	3	6	1	0	0	40.00	60.00	21	12	\N	\N	\N	5	2	2025-11-20 15:02:10.363397	\N	\N	1	1	draw	yes
2876	1380427	2025-08-17	Poland	Ekstraklasa	Wisla Plock	Legia Warszawa	h-win	1	0	10	4	23	3	3	9	1	1	0	1	0	0	34.00	66.00	5	9	\N	\N	\N	3	11	2025-11-20 15:02:10.581792	\N	\N	1	0	h-win	yes
2877	1380426	2025-08-17	Poland	Ekstraklasa	Nieciecza	Raków Częstochowa	a-win	2	3	9	3	17	10	6	2	1	0	2	4	0	0	47.00	53.00	17	14	\N	\N	\N	17	4	2025-11-20 15:02:10.753463	\N	\N	1	1	draw	yes
2878	1380434	2025-08-22	Poland	Ekstraklasa	Radomiak Radom	Nieciecza	draw	1	1	17	4	13	2	2	5	3	3	1	2	0	0	62.00	38.00	12	11	\N	\N	\N	5	17	2025-11-20 15:02:10.937231	\N	\N	1	1	draw	yes
2879	1380436	2025-08-22	Poland	Ekstraklasa	Widzew Łódź	Pogon Szczecin	a-win	1	2	13	4	8	4	2	0	2	2	1	4	1	0	55.00	45.00	5	16	\N	\N	\N	12	13	2025-11-20 15:02:11.126696	\N	\N	1	1	draw	yes
2880	1380430	2025-08-23	Poland	Ekstraklasa	Korona Kielce	Motor Lublin	h-win	2	0	17	8	13	2	5	6	1	1	4	5	0	0	32.00	68.00	15	13	\N	\N	\N	9	15	2025-11-20 15:02:11.299411	\N	\N	0	0	draw	yes
2881	1380429	2025-08-23	Poland	Ekstraklasa	Gornik Zabrze	GKS Katowice	h-win	3	0	18	6	10	1	2	4	0	0	0	1	0	0	51.00	49.00	9	11	\N	\N	\N	1	14	2025-11-20 15:02:11.46347	\N	\N	1	0	h-win	yes
2882	1380433	2025-08-24	Poland	Ekstraklasa	Piast Gliwice	Cracovia Krakow	draw	0	0	14	1	8	2	4	2	1	0	1	0	0	0	60.00	40.00	20	17	\N	\N	\N	18	6	2025-11-20 15:02:11.64062	\N	\N	0	0	draw	yes
2883	1380431	2025-08-24	Poland	Ekstraklasa	Lechia Gdansk	Arka Gdynia	h-win	1	0	12	3	7	1	4	4	2	0	2	3	0	0	53.00	47.00	10	12	\N	\N	\N	16	10	2025-11-20 15:02:11.816869	\N	\N	0	0	draw	yes
2884	1380437	2025-08-25	Poland	Ekstraklasa	Wisla Plock	Zaglebie Lubin	h-win	2	1	15	4	8	3	4	3	2	1	1	0	0	0	58.00	42.00	15	9	\N	\N	\N	3	7	2025-11-20 15:02:12.011063	1.81	0.39	0	1	a-win	yes
2885	1380438	2025-08-29	Poland	Ekstraklasa	Arka Gdynia	Wisla Plock	h-win	1	0	8	2	18	4	0	5	1	1	1	2	0	0	51.00	49.00	12	10	\N	\N	\N	10	3	2025-11-20 15:02:12.199446	\N	\N	0	0	draw	yes
2886	1380440	2025-08-29	Poland	Ekstraklasa	GKS Katowice	Radomiak Radom	h-win	3	2	18	8	9	4	8	4	3	1	3	6	0	0	47.00	53.00	16	21	\N	\N	\N	14	5	2025-11-20 15:02:12.369838	\N	\N	2	2	draw	yes
2887	1380445	2025-08-30	Poland	Ekstraklasa	Nieciecza	Korona Kielce	a-win	1	3	8	5	24	9	3	1	2	1	0	2	0	0	46.00	54.00	13	12	\N	\N	\N	17	9	2025-11-20 15:02:12.533694	\N	\N	1	0	h-win	yes
2888	1380446	2025-08-30	Poland	Ekstraklasa	Zaglebie Lubin	Piast Gliwice	draw	2	2	11	2	15	5	3	5	2	3	3	3	0	0	30.00	70.00	15	9	\N	\N	\N	7	18	2025-11-20 15:02:12.728099	\N	\N	1	1	draw	yes
2889	1380441	2025-08-30	Poland	Ekstraklasa	Gornik Zabrze	Motor Lublin	a-win	0	1	18	3	10	3	10	5	2	1	5	4	0	0	58.00	42.00	9	14	\N	\N	\N	1	15	2025-11-20 15:02:12.918966	\N	\N	0	0	draw	yes
2890	1380442	2025-08-31	Poland	Ekstraklasa	Jagiellonia	Lechia Gdansk	h-win	2	0	12	4	14	3	1	5	2	0	4	4	0	0	52.00	48.00	13	20	\N	\N	\N	2	16	2025-11-20 15:02:13.102984	\N	\N	2	0	h-win	yes
2891	1380443	2025-08-31	Poland	Ekstraklasa	Lech Poznan	Widzew Łódź	h-win	2	1	13	5	15	3	5	7	1	6	3	0	0	0	51.00	49.00	10	8	\N	\N	\N	8	12	2025-11-20 15:02:13.279979	\N	\N	1	0	h-win	yes
2892	1380444	2025-08-31	Poland	Ekstraklasa	Pogon Szczecin	Raków Częstochowa	h-win	2	0	8	3	18	3	1	14	3	2	4	3	0	0	45.00	55.00	16	10	\N	\N	\N	13	4	2025-11-20 15:02:13.468818	\N	\N	0	0	draw	yes
2893	1380439	2025-08-31	Poland	Ekstraklasa	Cracovia Krakow	Legia Warszawa	h-win	2	1	2	2	13	5	2	5	1	1	4	2	0	0	56.00	44.00	13	17	\N	\N	\N	6	11	2025-11-20 15:02:13.644402	\N	\N	1	0	h-win	yes
2894	1380448	2025-09-12	Poland	Ekstraklasa	Lechia Gdansk	GKS Katowice	h-win	2	0	13	3	11	3	2	5	0	0	3	1	0	0	42.00	58.00	8	10	\N	\N	\N	16	14	2025-11-20 15:02:13.850878	1.77	0.32	1	0	h-win	yes
2895	1380449	2025-09-12	Poland	Ekstraklasa	Lech Poznan	Zaglebie Lubin	a-win	1	2	26	6	10	4	7	6	0	4	3	3	0	0	64.00	36.00	11	9	\N	\N	\N	8	7	2025-11-20 15:02:14.047041	3.34	0.78	1	1	draw	yes
2896	1380447	2025-09-13	Poland	Ekstraklasa	Korona Kielce	Pogon Szczecin	h-win	1	0	17	6	21	10	12	7	5	2	1	1	0	0	45.00	55.00	9	11	\N	\N	\N	9	13	2025-11-20 15:02:14.241744	\N	\N	1	0	h-win	yes
2897	1380452	2025-09-13	Poland	Ekstraklasa	Piast Gliwice	Jagiellonia	draw	1	1	15	4	11	6	4	1	2	1	6	3	1	0	53.00	47.00	11	13	\N	\N	\N	18	2	2025-11-20 15:02:14.433	\N	\N	0	0	draw	yes
2898	1380451	2025-09-14	Poland	Ekstraklasa	Motor Lublin	Nieciecza	draw	1	1	14	2	10	6	5	4	4	1	2	4	0	0	51.00	49.00	16	13	\N	\N	\N	15	17	2025-11-20 15:02:14.630323	\N	\N	1	0	h-win	yes
2899	1380450	2025-09-14	Poland	Ekstraklasa	Legia Warszawa	Radomiak Radom	h-win	4	1	13	6	12	4	5	5	0	0	1	2	0	0	55.00	45.00	17	15	\N	\N	\N	11	5	2025-11-20 15:02:14.844834	\N	\N	1	0	h-win	yes
2900	1380454	2025-09-14	Poland	Ekstraklasa	Widzew Łódź	Arka Gdynia	h-win	2	0	14	8	13	5	1	2	1	3	0	1	0	0	49.00	51.00	4	16	\N	\N	\N	12	10	2025-11-20 15:02:15.03639	\N	\N	1	0	h-win	yes
2901	1380453	2025-09-15	Poland	Ekstraklasa	Raków Częstochowa	Gornik Zabrze	a-win	0	1	9	1	16	7	3	6	2	0	1	6	0	0	67.00	33.00	7	16	\N	\N	\N	4	1	2025-11-20 15:02:15.223412	\N	\N	0	1	a-win	yes
2902	1380457	2025-09-19	Poland	Ekstraklasa	GKS Katowice	Cracovia Krakow	a-win	0	3	16	5	13	6	11	3	0	0	2	1	0	0	58.00	42.00	6	13	\N	\N	\N	14	6	2025-11-20 15:02:15.457157	\N	\N	0	2	a-win	yes
2903	1380459	2025-09-19	Poland	Ekstraklasa	Wisla Plock	Jagiellonia	a-win	0	1	17	4	12	9	4	5	3	3	0	2	0	0	41.00	59.00	13	8	\N	\N	\N	3	2	2025-11-20 15:02:15.629822	\N	\N	0	0	draw	yes
2904	1380461	2025-09-20	Poland	Ekstraklasa	Radomiak Radom	Piast Gliwice	h-win	1	0	16	4	11	2	3	2	1	1	0	1	0	0	40.00	60.00	21	13	\N	\N	\N	5	18	2025-11-20 15:02:15.79677	\N	\N	0	0	draw	yes
2905	1380456	2025-09-20	Poland	Ekstraklasa	Arka Gdynia	Korona Kielce	draw	0	0	11	3	9	0	4	6	1	0	3	2	0	0	49.00	51.00	12	15	\N	\N	\N	10	9	2025-11-20 15:02:15.991406	\N	\N	0	0	draw	yes
2906	1380463	2025-09-20	Poland	Ekstraklasa	Nieciecza	Lech Poznan	a-win	0	2	13	2	18	9	3	10	0	2	1	1	0	0	54.00	46.00	7	7	\N	\N	\N	17	8	2025-11-20 15:02:16.182046	\N	\N	0	1	a-win	yes
2907	1380462	2025-09-20	Poland	Ekstraklasa	Raków Częstochowa	Legia Warszawa	draw	1	1	7	3	16	2	1	2	2	0	1	3	0	0	40.00	60.00	15	18	\N	\N	\N	4	11	2025-11-20 15:02:16.391598	\N	\N	1	1	draw	yes
2908	1380464	2025-09-21	Poland	Ekstraklasa	Zaglebie Lubin	Motor Lublin	draw	2	2	10	3	15	6	6	5	2	3	3	4	0	0	44.00	56.00	14	15	\N	\N	\N	7	15	2025-11-20 15:02:16.586997	\N	\N	1	0	h-win	yes
2909	1380460	2025-09-21	Poland	Ekstraklasa	Pogon Szczecin	Lechia Gdansk	a-win	3	4	22	10	12	9	4	4	1	0	3	3	0	0	59.00	41.00	9	11	\N	\N	\N	13	16	2025-11-20 15:02:16.800299	\N	\N	2	1	h-win	yes
2910	1380458	2025-09-21	Poland	Ekstraklasa	Gornik Zabrze	Widzew Łódź	h-win	3	2	17	7	11	5	6	4	2	0	4	1	0	0	50.00	50.00	16	11	\N	\N	\N	1	12	2025-11-20 15:02:16.987817	\N	\N	2	1	h-win	yes
2911	1380435	2025-09-24	Poland	Ekstraklasa	Raków Częstochowa	Lech Poznan	draw	2	2	16	7	10	3	6	2	4	1	3	1	0	1	64.00	36.00	10	15	\N	\N	\N	4	8	2025-11-20 15:02:17.186694	\N	\N	0	2	a-win	yes
2912	1380432	2025-09-24	Poland	Ekstraklasa	Legia Warszawa	Jagiellonia	draw	0	0	20	7	4	1	2	2	0	6	1	3	0	0	51.00	49.00	19	16	\N	\N	\N	11	2	2025-11-20 15:02:17.37973	\N	\N	0	0	draw	yes
2913	1380472	2025-09-26	Poland	Ekstraklasa	Wisla Plock	GKS Katowice	draw	1	1	11	5	10	5	4	2	1	2	1	1	0	0	46.00	54.00	14	11	\N	\N	\N	3	14	2025-11-20 15:02:17.571537	\N	\N	1	0	h-win	yes
2914	1380466	2025-09-27	Poland	Ekstraklasa	Korona Kielce	Lechia Gdansk	h-win	3	0	17	7	10	3	6	5	1	0	2	1	0	1	44.00	56.00	12	13	\N	\N	\N	9	16	2025-11-20 15:02:17.76308	\N	\N	1	0	h-win	yes
2915	1380470	2025-09-27	Poland	Ekstraklasa	Piast Gliwice	Nieciecza	h-win	4	2	20	7	22	7	2	7	1	2	1	3	1	0	48.00	52.00	7	15	\N	\N	\N	18	17	2025-11-20 15:02:17.946858	\N	\N	1	2	a-win	yes
2916	1380465	2025-09-27	Poland	Ekstraklasa	Cracovia Krakow	Gornik Zabrze	draw	1	1	13	3	10	2	6	7	1	0	1	2	0	0	64.00	36.00	4	10	\N	\N	\N	6	1	2025-11-20 15:02:18.133788	\N	\N	0	0	draw	yes
2917	1380471	2025-09-28	Poland	Ekstraklasa	Widzew Łódź	Raków Częstochowa	a-win	0	1	6	1	21	6	3	3	3	0	3	4	0	0	38.00	62.00	11	17	\N	\N	\N	12	4	2025-11-20 15:02:18.326969	\N	\N	0	0	draw	yes
2918	1380467	2025-09-28	Poland	Ekstraklasa	Lech Poznan	Jagiellonia	draw	2	2	13	6	15	3	5	10	0	1	1	4	0	0	53.00	47.00	10	13	\N	\N	\N	8	2	2025-11-20 15:02:18.509616	\N	\N	0	1	a-win	yes
2919	1380468	2025-09-28	Poland	Ekstraklasa	Legia Warszawa	Pogon Szczecin	h-win	1	0	14	6	6	1	6	1	3	2	2	3	0	0	55.00	45.00	17	15	\N	\N	\N	11	13	2025-11-20 15:02:18.707338	\N	\N	1	0	h-win	yes
2920	1380473	2025-09-29	Poland	Ekstraklasa	Zaglebie Lubin	Arka Gdynia	h-win	4	0	9	6	9	2	2	2	0	2	0	3	0	0	40.00	60.00	15	16	\N	\N	\N	7	10	2025-11-20 15:02:18.886498	\N	\N	4	0	h-win	yes
2921	1380469	2025-09-29	Poland	Ekstraklasa	Motor Lublin	Radomiak Radom	draw	2	2	11	4	20	5	5	3	2	0	1	3	0	0	55.00	45.00	10	14	\N	\N	\N	15	5	2025-11-20 15:02:19.047767	\N	\N	0	1	a-win	yes
2922	1380478	2025-10-03	Poland	Ekstraklasa	Lechia Gdansk	Wisla Plock	draw	1	1	12	5	9	1	3	4	2	0	1	3	0	0	56.00	44.00	7	11	\N	\N	\N	16	3	2025-11-20 15:02:19.198855	0.82	0.96	1	0	h-win	yes
2923	1380479	2025-10-03	Poland	Ekstraklasa	Pogon Szczecin	Piast Gliwice	h-win	2	1	28	10	8	2	6	1	2	1	2	1	0	0	48.00	52.00	11	16	\N	\N	\N	13	18	2025-11-20 15:02:19.379548	5.25	1.06	1	1	draw	yes
2924	1380482	2025-10-04	Poland	Ekstraklasa	Nieciecza	Widzew Łódź	a-win	2	4	9	4	14	10	3	4	0	1	1	2	0	0	53.00	47.00	15	16	\N	\N	\N	17	12	2025-11-20 15:02:19.565097	0.91	1.88	1	1	draw	yes
2925	1380480	2025-10-04	Poland	Ekstraklasa	Radomiak Radom	Zaglebie Lubin	h-win	3	1	17	5	18	7	5	6	1	4	0	3	0	0	50.00	50.00	11	13	\N	\N	\N	5	7	2025-11-20 15:02:19.743394	1.86	1.60	2	0	h-win	yes
2926	1380474	2025-10-04	Poland	Ekstraklasa	Arka Gdynia	Cracovia Krakow	h-win	2	1	8	3	13	1	4	6	2	2	0	2	0	0	37.00	63.00	20	17	\N	\N	\N	10	6	2025-11-20 15:02:19.930429	0.72	1.07	1	0	h-win	yes
2927	1380477	2025-10-05	Poland	Ekstraklasa	Jagiellonia	Korona Kielce	h-win	3	1	18	6	14	3	7	7	1	3	1	1	0	0	69.00	31.00	9	10	\N	\N	\N	2	9	2025-11-20 15:02:20.124464	2.13	0.93	1	0	h-win	yes
2928	1380481	2025-10-05	Poland	Ekstraklasa	Raków Częstochowa	Motor Lublin	h-win	2	0	22	8	5	2	4	5	2	2	1	3	1	0	54.00	46.00	12	15	\N	\N	\N	4	15	2025-11-20 15:02:20.316498	3.02	0.36	1	0	h-win	yes
2929	1380475	2025-10-05	Poland	Ekstraklasa	GKS Katowice	Lech Poznan	a-win	0	1	14	5	11	3	6	2	4	0	1	3	0	0	43.00	57.00	15	17	\N	\N	\N	14	8	2025-11-20 15:02:20.493146	1.82	1.98	0	1	a-win	yes
2930	1380476	2025-10-05	Poland	Ekstraklasa	Gornik Zabrze	Legia Warszawa	h-win	3	1	9	6	15	3	0	6	2	0	1	1	0	0	39.00	61.00	10	10	\N	\N	\N	1	11	2025-11-20 15:02:20.654853	1.33	1.05	2	0	h-win	yes
2931	1380487	2025-10-17	Poland	Ekstraklasa	Motor Lublin	GKS Katowice	a-win	2	5	18	6	15	4	10	2	0	2	2	3	1	0	51.00	49.00	10	14	\N	\N	\N	15	14	2025-11-20 15:02:20.849902	1.79	1.83	2	2	draw	yes
2932	1380489	2025-10-17	Poland	Ekstraklasa	Widzew Łódź	Radomiak Radom	h-win	3	2	18	6	19	6	2	4	1	4	2	2	0	0	48.00	52.00	18	19	\N	\N	\N	12	5	2025-11-20 15:02:21.049324	2.74	1.73	2	1	h-win	yes
2933	1380485	2025-10-18	Poland	Ekstraklasa	Korona Kielce	Gornik Zabrze	draw	1	1	12	4	16	3	9	7	3	1	2	0	0	0	43.00	57.00	7	12	\N	\N	\N	9	1	2025-11-20 15:02:21.251322	2.35	1.06	1	0	h-win	yes
2934	1380484	2025-10-18	Poland	Ekstraklasa	Jagiellonia	Arka Gdynia	h-win	4	0	18	7	8	1	3	5	2	1	1	1	0	0	55.00	45.00	8	10	\N	\N	\N	2	10	2025-11-20 15:02:21.441394	2.65	0.78	1	0	h-win	yes
2935	1380483	2025-10-18	Poland	Ekstraklasa	Cracovia Krakow	Raków Częstochowa	h-win	2	0	17	4	3	1	5	2	2	2	3	4	0	0	42.00	58.00	17	3	\N	\N	\N	6	4	2025-11-20 15:02:21.624192	1.74	0.12	1	0	h-win	yes
2936	1380488	2025-10-19	Poland	Ekstraklasa	Piast Gliwice	Lechia Gdansk	a-win	1	2	15	3	9	3	9	6	2	0	2	3	0	0	62.00	38.00	15	9	\N	\N	\N	18	16	2025-11-20 15:02:21.815869	\N	\N	0	1	a-win	yes
2937	1380486	2025-10-19	Poland	Ekstraklasa	Lech Poznan	Pogon Szczecin	draw	2	2	26	12	16	6	9	4	6	5	1	0	0	0	66.00	34.00	26	16	\N	\N	\N	8	13	2025-11-20 15:02:21.979082	2.52	1.78	0	1	a-win	yes
2938	1380491	2025-10-19	Poland	Ekstraklasa	Zaglebie Lubin	Legia Warszawa	h-win	3	1	16	5	12	2	3	4	3	1	1	1	0	1	35.00	65.00	16	12	\N	\N	\N	7	11	2025-11-20 15:02:22.173224	1.64	0.94	2	0	h-win	yes
2939	1380490	2025-10-20	Poland	Ekstraklasa	Wisla Plock	Nieciecza	h-win	3	1	20	7	14	2	6	5	1	2	0	1	0	0	55.00	45.00	6	9	\N	\N	\N	3	17	2025-11-20 15:02:22.359338	2.18	2.08	3	0	h-win	yes
2940	1380500	2025-10-24	Poland	Ekstraklasa	Nieciecza	Zaglebie Lubin	draw	1	1	14	3	13	6	7	5	1	0	3	2	0	1	54.00	46.00	9	12	\N	\N	\N	17	7	2025-11-20 15:02:22.541187	1.12	1.51	0	0	draw	yes
2941	1380496	2025-10-24	Poland	Ekstraklasa	Motor Lublin	Widzew Łódź	h-win	3	0	16	5	13	4	5	4	6	1	1	2	0	0	46.00	54.00	8	12	\N	\N	\N	15	12	2025-11-20 15:02:22.707409	2.18	0.92	1	0	h-win	yes
2942	1380492	2025-10-25	Poland	Ekstraklasa	Arka Gdynia	Piast Gliwice	h-win	2	1	6	3	23	4	4	10	1	0	2	4	0	0	37.00	63.00	17	13	\N	\N	\N	10	18	2025-11-20 15:02:22.89952	\N	\N	2	1	h-win	yes
2943	1380497	2025-10-25	Poland	Ekstraklasa	Pogon Szczecin	Cracovia Krakow	h-win	2	1	11	3	17	7	8	3	2	0	2	4	0	0	56.00	44.00	10	13	\N	\N	\N	13	6	2025-11-20 15:02:23.08336	\N	\N	0	1	a-win	yes
2944	1380493	2025-10-25	Poland	Ekstraklasa	GKS Katowice	Korona Kielce	h-win	1	0	14	4	14	3	3	3	2	1	4	3	0	0	40.00	60.00	16	8	\N	\N	\N	14	9	2025-11-20 15:02:23.277328	\N	\N	0	0	draw	yes
2945	1380499	2025-10-26	Poland	Ekstraklasa	Raków Częstochowa	Lechia Gdansk	h-win	2	1	10	4	10	5	4	4	4	0	2	3	1	0	43.00	57.00	3	17	\N	\N	\N	4	16	2025-11-20 15:02:23.4774	\N	\N	1	1	draw	yes
2946	1380494	2025-10-26	Poland	Ekstraklasa	Gornik Zabrze	Jagiellonia	h-win	2	1	22	6	15	3	5	4	1	1	0	1	0	0	41.00	59.00	8	6	\N	\N	\N	1	2	2025-11-20 15:02:23.657632	\N	\N	1	1	draw	yes
2947	1380495	2025-10-26	Poland	Ekstraklasa	Legia Warszawa	Lech Poznan	draw	0	0	13	4	12	2	8	5	1	4	1	2	0	0	48.00	52.00	16	13	\N	\N	\N	11	8	2025-11-20 15:02:23.8534	\N	\N	0	0	draw	yes
2948	1380498	2025-10-27	Poland	Ekstraklasa	Radomiak Radom	Wisla Plock	draw	1	1	19	2	9	3	4	5	2	1	1	1	0	0	55.00	45.00	16	13	\N	\N	\N	5	3	2025-11-20 15:02:24.034155	\N	\N	1	1	draw	yes
2949	1380507	2025-10-31	Poland	Ekstraklasa	Nieciecza	GKS Katowice	a-win	0	3	18	7	11	7	7	2	1	4	1	2	0	0	66.00	34.00	13	18	\N	\N	\N	17	14	2025-11-20 15:02:24.218596	2.08	2.15	0	1	a-win	yes
2950	1380506	2025-10-31	Poland	Ekstraklasa	Piast Gliwice	Korona Kielce	draw	0	0	10	2	20	4	7	9	0	1	2	1	1	0	49.00	51.00	13	8	\N	\N	\N	18	9	2025-11-20 15:02:24.40739	0.44	1.74	0	0	draw	yes
2951	1380502	2025-11-02	Poland	Ekstraklasa	Gornik Zabrze	Arka Gdynia	h-win	5	1	29	11	8	2	10	2	0	1	1	3	0	0	53.00	47.00	9	10	\N	\N	\N	1	10	2025-11-20 15:02:24.594968	\N	\N	1	0	h-win	yes
2952	1380505	2025-11-02	Poland	Ekstraklasa	Lech Poznan	Motor Lublin	draw	2	2	18	3	8	2	6	2	1	2	2	1	0	0	60.00	40.00	10	15	\N	\N	\N	8	15	2025-11-20 15:02:24.752273	\N	\N	2	2	draw	yes
2953	1380503	2025-11-02	Poland	Ekstraklasa	Jagiellonia	Raków Częstochowa	a-win	1	2	26	6	10	5	5	4	0	1	5	2	0	0	67.00	33.00	19	17	\N	\N	\N	2	4	2025-11-20 15:02:24.93892	\N	\N	0	1	a-win	yes
2954	1380508	2025-11-02	Poland	Ekstraklasa	Widzew Łódź	Legia Warszawa	draw	1	1	10	3	20	3	3	8	3	0	3	3	0	0	42.00	58.00	10	13	\N	\N	\N	12	11	2025-11-20 15:02:25.088267	\N	\N	0	0	draw	yes
2955	1380509	2025-11-03	Poland	Ekstraklasa	Wisla Plock	Pogon Szczecin	h-win	2	0	15	5	22	9	6	8	0	1	1	1	0	0	32.00	68.00	5	7	\N	\N	\N	3	13	2025-11-20 15:02:25.246687	2.20	1.28	1	0	h-win	yes
2956	1380504	2025-11-03	Poland	Ekstraklasa	Lechia Gdansk	Radomiak Radom	a-win	1	2	14	4	11	5	8	4	2	1	2	4	0	0	47.00	53.00	11	12	\N	\N	\N	16	5	2025-11-20 15:02:25.429756	1.27	1.36	0	1	a-win	yes
2957	1380501	2025-11-03	Poland	Ekstraklasa	Cracovia Krakow	Zaglebie Lubin	draw	0	0	14	3	8	3	2	0	3	0	0	0	0	0	68.00	32.00	11	11	\N	\N	\N	6	7	2025-11-20 15:02:25.61594	1.18	0.28	0	0	draw	yes
2958	1380517	2025-11-07	Poland	Ekstraklasa	Radomiak Radom	Cracovia Krakow	h-win	3	0	12	8	4	2	5	3	1	2	2	3	0	0	51.00	49.00	12	17	\N	\N	\N	5	6	2025-11-20 15:02:25.800389	2.43	0.56	0	0	draw	yes
2959	1380518	2025-11-07	Poland	Ekstraklasa	Zaglebie Lubin	Gornik Zabrze	h-win	2	0	6	3	15	2	1	12	1	1	4	1	0	0	30.00	70.00	12	12	\N	\N	\N	7	1	2025-11-20 15:02:25.993565	1.54	0.83	1	0	h-win	yes
2960	1380513	2025-11-08	Poland	Ekstraklasa	Lechia Gdansk	Widzew Łódź	h-win	2	1	14	3	9	3	5	3	2	1	2	4	0	0	52.00	48.00	14	11	\N	\N	\N	16	12	2025-11-20 15:02:26.184255	1.29	1.29	0	0	draw	yes
2961	1380515	2025-11-08	Poland	Ekstraklasa	Motor Lublin	Wisla Plock	draw	1	1	14	4	10	2	5	1	2	0	3	6	0	0	64.00	36.00	18	14	\N	\N	\N	15	3	2025-11-20 15:02:26.365298	3.36	0.79	1	0	h-win	yes
2962	1380511	2025-11-08	Poland	Ekstraklasa	GKS Katowice	Piast Gliwice	a-win	1	3	9	3	17	6	3	3	2	0	2	2	0	0	54.00	46.00	10	16	\N	\N	\N	14	18	2025-11-20 15:02:26.553405	0.83	1.51	0	2	a-win	yes
2963	1380514	2025-11-09	Poland	Ekstraklasa	Legia Warszawa	Nieciecza	a-win	1	2	23	6	13	7	11	2	2	3	1	4	0	0	70.00	30.00	13	17	\N	\N	\N	11	17	2025-11-20 15:02:26.784224	1.38	1.48	0	1	a-win	yes
2964	1380512	2025-11-09	Poland	Ekstraklasa	Korona Kielce	Raków Częstochowa	a-win	1	4	12	2	7	5	5	0	2	0	3	2	0	0	49.00	51.00	15	9	\N	\N	\N	9	4	2025-11-20 15:02:26.94716	1.18	2.13	1	2	a-win	yes
2965	1380516	2025-11-09	Poland	Ekstraklasa	Pogon Szczecin	Jagiellonia	a-win	1	2	35	10	11	5	10	1	0	1	2	1	0	0	39.00	61.00	8	9	\N	\N	\N	13	2	2025-11-20 15:02:27.13533	4.00	2.11	1	1	draw	yes
2966	1380510	2025-11-09	Poland	Ekstraklasa	Arka Gdynia	Lech Poznan	h-win	3	1	19	7	13	6	3	3	2	1	3	3	0	1	44.00	56.00	19	16	\N	\N	\N	10	8	2025-11-20 15:02:27.312862	1.34	2.67	0	1	a-win	yes
2967	1380417	2025-08-09	Poland	Ekstraklasa	Piast Gliwice	Lech Poznan	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 15:02:27.482514	\N	\N	0	0	draw	no
2968	1380526	2025-11-21	Poland	Ekstraklasa	Nieciecza	Arka Gdynia	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2.10	3.40	3.50	\N	\N	2025-11-20 15:02:27.707799	\N	\N	0	0	draw	no
2969	1380520	2025-11-21	Poland	Ekstraklasa	Gornik Zabrze	Wisla Plock	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.63	3.75	5.60	\N	\N	2025-11-20 15:02:27.932821	\N	\N	0	0	draw	no
2970	1380519	2025-11-22	Poland	Ekstraklasa	Cracovia Krakow	Motor Lublin	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.85	3.55	4.20	\N	\N	2025-11-20 15:02:28.142042	\N	\N	0	0	draw	no
2971	1380525	2025-11-22	Poland	Ekstraklasa	Raków Częstochowa	Piast Gliwice	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.81	3.40	4.65	\N	\N	2025-11-20 15:02:28.351152	\N	\N	0	0	draw	no
2972	1380523	2025-11-22	Poland	Ekstraklasa	Legia Warszawa	Lechia Gdansk	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.58	4.20	5.40	\N	\N	2025-11-20 15:02:28.576841	\N	\N	0	0	draw	no
2973	1380521	2025-11-23	Poland	Ekstraklasa	Jagiellonia	GKS Katowice	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.81	3.80	3.95	\N	\N	2025-11-20 15:02:28.805169	\N	\N	0	0	draw	no
2974	1380522	2025-11-23	Poland	Ekstraklasa	Lech Poznan	Radomiak Radom	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.59	3.95	5.40	\N	\N	2025-11-20 15:02:29.022177	\N	\N	0	0	draw	no
2975	1380527	2025-11-23	Poland	Ekstraklasa	Widzew Łódź	Korona Kielce	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2.28	3.25	3.10	\N	\N	2025-11-20 15:02:29.238219	\N	\N	0	0	draw	no
2976	1380524	2025-11-24	Poland	Ekstraklasa	Pogon Szczecin	Zaglebie Lubin	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.84	3.60	4.00	\N	\N	2025-11-20 15:02:29.459189	\N	\N	0	0	draw	no
2977	1381537	2025-08-01	Poland	I Liga	Wieczysta Kraków	Znicz Pruszków	h-win	4	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8	18	2025-11-20 15:02:30.944583	\N	\N	1	0	h-win	yes
2978	1381539	2025-08-01	Poland	I Liga	ŁKS Łódź	Polonia Bytom	h-win	5	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	13	4	2025-11-20 15:02:31.133754	\N	\N	1	0	h-win	yes
2979	1381536	2025-08-02	Poland	I Liga	Pogoń Grod. Mazowiecki	Miedz Legnica	h-win	4	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	12	2025-11-20 15:02:31.299776	\N	\N	2	0	h-win	yes
2980	1381542	2025-08-02	Poland	I Liga	Stal Rzeszów	Chrobry Głogów	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7	3	2025-11-20 15:02:31.465991	\N	\N	0	1	a-win	yes
2981	1381543	2025-08-02	Poland	I Liga	Stal Mielec	Polonia Warszawa	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	15	9	2025-11-20 15:02:31.643783	\N	\N	0	2	a-win	yes
2982	1381541	2025-08-03	Poland	I Liga	Slask Wroclaw	Ruch Chorzów	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	6	2025-11-20 15:02:31.829688	\N	\N	3	1	h-win	yes
2983	1381540	2025-08-03	Poland	I Liga	Pogoń Siedlce	Odra Opole	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	11	10	2025-11-20 15:02:32.020931	\N	\N	0	0	draw	yes
2984	1381538	2025-08-03	Poland	I Liga	Górnik Łęczna	Puszcza Niepołomice	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	17	14	2025-11-20 15:02:32.210678	\N	\N	2	1	h-win	yes
2985	1381544	2025-08-04	Poland	I Liga	Tychy 71	Wisla Krakow	a-win	3	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16	1	2025-11-20 15:02:32.411603	\N	\N	1	1	draw	yes
2986	1381550	2025-08-08	Poland	I Liga	Ruch Chorzów	Pogoń Siedlce	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	11	2025-11-20 15:02:32.59334	\N	\N	0	2	a-win	yes
2987	1381551	2025-08-08	Poland	I Liga	Slask Wroclaw	Miedz Legnica	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	12	2025-11-20 15:02:32.769938	\N	\N	1	1	draw	yes
2988	1381545	2025-08-09	Poland	I Liga	Chrobry Głogów	ŁKS Łódź	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	13	2025-11-20 15:02:32.961786	\N	\N	0	0	draw	yes
2989	1381552	2025-08-09	Poland	I Liga	Stal Mielec	Górnik Łęczna	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	15	17	2025-11-20 15:02:33.144134	\N	\N	0	1	a-win	yes
2990	1381547	2025-08-09	Poland	I Liga	Polonia Bytom	Stal Rzeszów	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	7	2025-11-20 15:02:33.323768	\N	\N	0	1	a-win	yes
2991	1381553	2025-08-10	Poland	I Liga	Wisla Krakow	Pogoń Grod. Mazowiecki	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	2	2025-11-20 15:02:33.521948	\N	\N	3	1	h-win	yes
2992	1381546	2025-08-10	Poland	I Liga	Odra Opole	Tychy 71	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	10	16	2025-11-20 15:02:33.698544	\N	\N	0	0	draw	yes
2993	1381548	2025-08-10	Poland	I Liga	Znicz Pruszków	Polonia Warszawa	a-win	1	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	18	9	2025-11-20 15:02:33.9112	\N	\N	0	1	a-win	yes
2994	1381549	2025-08-11	Poland	I Liga	Puszcza Niepołomice	Wieczysta Kraków	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	14	8	2025-11-20 15:02:34.097973	\N	\N	0	0	draw	yes
2995	1381557	2025-08-15	Poland	I Liga	ŁKS Łódź	Stal Mielec	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	13	15	2025-11-20 15:02:34.277914	\N	\N	1	0	h-win	yes
2996	1381560	2025-08-15	Poland	I Liga	Polonia Warszawa	Ruch Chorzów	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	6	2025-11-20 15:02:34.462624	\N	\N	0	0	draw	yes
2997	1381556	2025-08-16	Poland	I Liga	Chrobry Głogów	Miedz Legnica	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	12	2025-11-20 15:02:34.638693	\N	\N	1	0	h-win	yes
2998	1381561	2025-08-16	Poland	I Liga	Stal Rzeszów	Puszcza Niepołomice	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7	14	2025-11-20 15:02:34.828124	\N	\N	1	2	a-win	yes
2999	1381554	2025-08-16	Poland	I Liga	Pogoń Grod. Mazowiecki	Znicz Pruszków	h-win	4	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	18	2025-11-20 15:02:34.937084	\N	\N	3	1	h-win	yes
3000	1381558	2025-08-17	Poland	I Liga	Odra Opole	Slask Wroclaw	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	10	5	2025-11-20 15:02:34.950741	\N	\N	0	0	draw	yes
3001	1381562	2025-08-17	Poland	I Liga	Tychy 71	Górnik Łęczna	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16	17	2025-11-20 15:02:34.973465	\N	\N	2	1	h-win	yes
3002	1381559	2025-08-17	Poland	I Liga	Pogoń Siedlce	Polonia Bytom	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	11	4	2025-11-20 15:02:34.987896	\N	\N	0	0	draw	yes
3003	1381565	2025-08-19	Poland	I Liga	Miedz Legnica	ŁKS Łódź	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	13	2025-11-20 15:02:35.009651	\N	\N	2	0	h-win	yes
3004	1381567	2025-08-19	Poland	I Liga	Polonia Warszawa	Wieczysta Kraków	a-win	1	6	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	8	2025-11-20 15:02:35.023339	\N	\N	0	2	a-win	yes
3005	1381568	2025-08-19	Poland	I Liga	Znicz Pruszków	Wisla Krakow	a-win	0	7	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	18	1	2025-11-20 15:02:35.032125	\N	\N	0	3	a-win	yes
3006	1381563	2025-08-20	Poland	I Liga	Chrobry Głogów	Slask Wroclaw	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	5	2025-11-20 15:02:35.043392	\N	\N	0	2	a-win	yes
3007	1381566	2025-08-20	Poland	I Liga	Polonia Bytom	Pogoń Grod. Mazowiecki	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	2	2025-11-20 15:02:35.054542	\N	\N	1	0	h-win	yes
3008	1381570	2025-08-20	Poland	I Liga	Ruch Chorzów	Stal Rzeszów	h-win	4	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	7	2025-11-20 15:02:35.062654	\N	\N	2	0	h-win	yes
3009	1381569	2025-08-21	Poland	I Liga	Puszcza Niepołomice	Tychy 71	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	14	16	2025-11-20 15:02:35.07395	\N	\N	1	0	h-win	yes
3010	1381571	2025-08-21	Poland	I Liga	Stal Mielec	Odra Opole	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	15	10	2025-11-20 15:02:35.082972	\N	\N	0	0	draw	yes
3011	1381564	2025-08-21	Poland	I Liga	Górnik Łęczna	Pogoń Siedlce	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	17	11	2025-11-20 15:02:35.094257	\N	\N	0	1	a-win	yes
3012	1381574	2025-08-23	Poland	I Liga	ŁKS Łódź	Polonia Warszawa	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	13	9	2025-11-20 15:02:35.102489	\N	\N	0	2	a-win	yes
3013	1381578	2025-08-23	Poland	I Liga	Stal Rzeszów	Miedz Legnica	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7	12	2025-11-20 15:02:35.114202	\N	\N	0	0	draw	yes
3014	1381572	2025-08-23	Poland	I Liga	Pogoń Grod. Mazowiecki	Chrobry Głogów	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	3	2025-11-20 15:02:35.124288	\N	\N	0	0	draw	yes
3015	1381575	2025-08-24	Poland	I Liga	Odra Opole	Znicz Pruszków	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	10	18	2025-11-20 15:02:35.130638	\N	\N	0	1	a-win	yes
3016	1381580	2025-08-24	Poland	I Liga	Wisla Krakow	Slask Wroclaw	h-win	5	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	5	2025-11-20 15:02:35.13642	\N	\N	2	0	h-win	yes
3017	1381577	2025-08-24	Poland	I Liga	Ruch Chorzów	Polonia Bytom	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	4	2025-11-20 15:02:35.144261	\N	\N	0	0	draw	yes
3018	1381576	2025-08-24	Poland	I Liga	Pogoń Siedlce	Puszcza Niepołomice	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	11	14	2025-11-20 15:02:35.150412	\N	\N	0	0	draw	yes
3019	1421941	2025-08-25	Poland	I Liga	Wieczysta Kraków	Górnik Łęczna	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8	17	2025-11-20 15:02:35.159152	\N	\N	1	0	h-win	yes
3020	1421942	2025-08-25	Poland	I Liga	Tychy 71	Stal Mielec	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16	15	2025-11-20 15:02:35.165707	\N	\N	0	1	a-win	yes
3021	1381588	2025-08-29	Poland	I Liga	Slask Wroclaw	Tychy 71	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	16	2025-11-20 15:02:35.173789	\N	\N	0	0	draw	yes
3022	1381582	2025-08-29	Poland	I Liga	Miedz Legnica	Wisla Krakow	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	1	2025-11-20 15:02:35.179856	\N	\N	1	0	h-win	yes
3023	1381584	2025-08-30	Poland	I Liga	Polonia Bytom	Wieczysta Kraków	h-win	4	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	8	2025-11-20 15:02:35.185901	\N	\N	3	1	h-win	yes
3024	1381581	2025-08-30	Poland	I Liga	Górnik Łęczna	Stal Rzeszów	a-win	0	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	17	7	2025-11-20 15:02:35.194082	\N	\N	0	2	a-win	yes
3025	1381586	2025-08-30	Poland	I Liga	Znicz Pruszków	Pogoń Siedlce	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	18	11	2025-11-20 15:02:35.200292	\N	\N	0	0	draw	yes
3026	1381585	2025-08-30	Poland	I Liga	Polonia Warszawa	Pogoń Grod. Mazowiecki	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	2	2025-11-20 15:02:35.208147	\N	\N	2	1	h-win	yes
3027	1381589	2025-08-31	Poland	I Liga	Stal Mielec	Ruch Chorzów	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	15	6	2025-11-20 15:02:35.213988	\N	\N	1	0	h-win	yes
3028	1381583	2025-08-31	Poland	I Liga	Odra Opole	ŁKS Łódź	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	10	13	2025-11-20 15:02:35.222463	\N	\N	0	0	draw	yes
3029	1381587	2025-08-31	Poland	I Liga	Puszcza Niepołomice	Chrobry Głogów	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	14	3	2025-11-20 15:02:35.228209	\N	\N	0	0	draw	yes
3030	1381597	2025-09-12	Poland	I Liga	Tychy 71	Polonia Bytom	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16	4	2025-11-20 15:02:35.234291	\N	\N	1	1	draw	yes
3031	1381590	2025-09-12	Poland	I Liga	Chrobry Głogów	Pogoń Siedlce	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	11	2025-11-20 15:02:35.241799	\N	\N	0	0	draw	yes
3032	1381595	2025-09-13	Poland	I Liga	Slask Wroclaw	Puszcza Niepołomice	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	14	2025-11-20 15:02:35.248395	\N	\N	0	0	draw	yes
3033	1381598	2025-09-13	Poland	I Liga	Wisla Krakow	Odra Opole	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	10	2025-11-20 15:02:35.256505	\N	\N	1	1	draw	yes
3034	1381596	2025-09-13	Poland	I Liga	Stal Rzeszów	Znicz Pruszków	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7	18	2025-11-20 15:02:35.262765	\N	\N	1	0	h-win	yes
3035	1381593	2025-09-14	Poland	I Liga	Miedz Legnica	Polonia Warszawa	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	9	2025-11-20 15:02:35.270591	\N	\N	0	1	a-win	yes
3036	1381594	2025-09-14	Poland	I Liga	Ruch Chorzów	ŁKS Łódź	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	13	2025-11-20 15:02:35.276397	\N	\N	2	0	h-win	yes
3037	1381591	2025-09-14	Poland	I Liga	Pogoń Grod. Mazowiecki	Górnik Łęczna	draw	3	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	17	2025-11-20 15:02:35.282795	\N	\N	1	2	a-win	yes
3038	1381592	2025-09-15	Poland	I Liga	Wieczysta Kraków	Stal Mielec	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8	15	2025-11-20 15:02:35.288672	\N	\N	2	0	h-win	yes
3039	1381601	2025-09-19	Poland	I Liga	Odra Opole	Stal Rzeszów	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	10	7	2025-11-20 15:02:35.295209	\N	\N	2	1	h-win	yes
3040	1381607	2025-09-19	Poland	I Liga	Stal Mielec	Pogoń Grod. Mazowiecki	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	15	2	2025-11-20 15:02:35.301085	\N	\N	1	1	draw	yes
3041	1381602	2025-09-20	Poland	I Liga	Pogoń Siedlce	Slask Wroclaw	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	11	5	2025-11-20 15:02:35.30902	\N	\N	2	1	h-win	yes
3042	1381603	2025-09-20	Poland	I Liga	Polonia Bytom	Miedz Legnica	h-win	4	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	12	2025-11-20 15:02:35.31547	\N	\N	3	0	h-win	yes
3043	1381604	2025-09-20	Poland	I Liga	Polonia Warszawa	Puszcza Niepołomice	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	14	2025-11-20 15:02:35.322984	\N	\N	0	2	a-win	yes
3044	1381599	2025-09-21	Poland	I Liga	Górnik Łęczna	Wisla Krakow	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	17	1	2025-11-20 15:02:35.32875	\N	\N	1	0	h-win	yes
3045	1381605	2025-09-21	Poland	I Liga	Znicz Pruszków	Tychy 71	h-win	4	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	18	16	2025-11-20 15:02:35.334734	\N	\N	2	0	h-win	yes
3046	1381600	2025-09-21	Poland	I Liga	ŁKS Łódź	Wieczysta Kraków	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	13	8	2025-11-20 15:02:35.342231	\N	\N	0	0	draw	yes
3047	1381606	2025-09-22	Poland	I Liga	Ruch Chorzów	Chrobry Głogów	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	3	2025-11-20 15:02:35.348277	\N	\N	1	1	draw	yes
3048	1381613	2025-09-26	Poland	I Liga	Slask Wroclaw	Polonia Warszawa	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	9	2025-11-20 15:02:35.353914	\N	\N	1	0	h-win	yes
3049	1381612	2025-09-27	Poland	I Liga	Puszcza Niepołomice	Odra Opole	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	14	10	2025-11-20 15:02:35.362343	\N	\N	0	0	draw	yes
3050	1381615	2025-09-27	Poland	I Liga	Tychy 71	Pogoń Siedlce	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16	11	2025-11-20 15:02:35.368241	\N	\N	0	1	a-win	yes
3051	1381614	2025-09-27	Poland	I Liga	Stal Rzeszów	Stal Mielec	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7	15	2025-11-20 15:02:35.374973	\N	\N	1	0	h-win	yes
3052	1381611	2025-09-28	Poland	I Liga	Miedz Legnica	Znicz Pruszków	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	18	2025-11-20 15:02:35.381689	\N	\N	1	1	draw	yes
3053	1381610	2025-09-28	Poland	I Liga	Wieczysta Kraków	Ruch Chorzów	h-win	4	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8	6	2025-11-20 15:02:35.387459	\N	\N	1	1	draw	yes
3054	1381608	2025-09-28	Poland	I Liga	Chrobry Głogów	Górnik Łęczna	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	17	2025-11-20 15:02:35.39568	\N	\N	0	0	draw	yes
3055	1381609	2025-09-29	Poland	I Liga	Pogoń Grod. Mazowiecki	ŁKS Łódź	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	13	2025-11-20 15:02:35.401745	\N	\N	2	0	h-win	yes
3056	1381616	2025-09-29	Poland	I Liga	Wisla Krakow	Polonia Bytom	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	4	2025-11-20 15:02:35.409742	\N	\N	0	0	draw	yes
3057	1381555	2025-10-02	Poland	I Liga	Wieczysta Kraków	Wisla Krakow	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8	1	2025-11-20 15:02:35.416456	\N	\N	1	0	h-win	yes
3058	1381624	2025-10-03	Poland	I Liga	Stal Mielec	Chrobry Głogów	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	15	3	2025-11-20 15:02:35.425177	\N	\N	0	0	draw	yes
3059	1381622	2025-10-03	Poland	I Liga	Polonia Warszawa	Stal Rzeszów	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	7	2025-11-20 15:02:35.431114	\N	\N	0	2	a-win	yes
3060	1381620	2025-10-04	Poland	I Liga	Pogoń Siedlce	Pogoń Grod. Mazowiecki	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	11	2	2025-11-20 15:02:35.43869	\N	\N	1	2	a-win	yes
3061	1381623	2025-10-04	Poland	I Liga	Znicz Pruszków	Slask Wroclaw	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	18	5	2025-11-20 15:02:35.44442	\N	\N	2	0	h-win	yes
3062	1381621	2025-10-04	Poland	I Liga	Polonia Bytom	Puszcza Niepołomice	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	14	2025-11-20 15:02:35.450912	\N	\N	1	1	draw	yes
3063	1381619	2025-10-05	Poland	I Liga	Odra Opole	Wieczysta Kraków	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	10	8	2025-11-20 15:02:35.458923	\N	\N	0	0	draw	yes
3064	1381618	2025-10-05	Poland	I Liga	ŁKS Łódź	Tychy 71	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	13	16	2025-11-20 15:02:35.465451	\N	\N	1	0	h-win	yes
3065	1381617	2025-10-05	Poland	I Liga	Górnik Łęczna	Miedz Legnica	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	17	12	2025-11-20 15:02:35.471227	\N	\N	0	0	draw	yes
3066	1381625	2025-10-05	Poland	I Liga	Wisla Krakow	Ruch Chorzów	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	6	2025-11-20 15:02:35.479736	\N	\N	1	0	h-win	yes
3067	1381627	2025-10-17	Poland	I Liga	Pogoń Grod. Mazowiecki	Ruch Chorzów	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	6	2025-11-20 15:02:35.487047	\N	\N	1	1	draw	yes
3068	1381629	2025-10-17	Poland	I Liga	Miedz Legnica	Pogoń Siedlce	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	11	2025-11-20 15:02:35.493134	\N	\N	1	2	a-win	yes
3069	1381626	2025-10-18	Poland	I Liga	Chrobry Głogów	Polonia Warszawa	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	9	2025-11-20 15:02:35.502289	\N	\N	0	0	draw	yes
3070	1381634	2025-10-18	Poland	I Liga	Tychy 71	Wieczysta Kraków	draw	3	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16	8	2025-11-20 15:02:35.509528	\N	\N	1	2	a-win	yes
3071	1381633	2025-10-18	Poland	I Liga	Stal Rzeszów	ŁKS Łódź	a-win	1	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7	13	2025-11-20 15:02:35.519461	\N	\N	0	3	a-win	yes
3072	1381630	2025-10-19	Poland	I Liga	Polonia Bytom	Odra Opole	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	10	2025-11-20 15:02:35.53224	\N	\N	0	0	draw	yes
3073	1381632	2025-10-19	Poland	I Liga	Slask Wroclaw	Stal Mielec	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	15	2025-11-20 15:02:35.539648	\N	\N	2	0	h-win	yes
3074	1381628	2025-10-19	Poland	I Liga	Górnik Łęczna	Znicz Pruszków	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	17	18	2025-11-20 15:02:35.547955	\N	\N	0	0	draw	yes
3075	1381631	2025-10-20	Poland	I Liga	Puszcza Niepołomice	Wisla Krakow	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	14	1	2025-11-20 15:02:35.553114	\N	\N	0	3	a-win	yes
3076	1381639	2025-10-24	Poland	I Liga	Znicz Pruszków	Puszcza Niepołomice	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	18	14	2025-11-20 15:02:35.558578	\N	\N	0	1	a-win	yes
3077	1381636	2025-10-24	Poland	I Liga	Odra Opole	Ruch Chorzów	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	10	6	2025-11-20 15:02:35.565322	\N	\N	0	1	a-win	yes
3078	1381640	2025-10-25	Poland	I Liga	Slask Wroclaw	Górnik Łęczna	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	17	2025-11-20 15:02:35.570434	\N	\N	1	0	h-win	yes
3079	1381637	2025-10-25	Poland	I Liga	Pogoń Siedlce	ŁKS Łódź	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	11	13	2025-11-20 15:02:35.575645	\N	\N	1	1	draw	yes
3080	1381638	2025-10-25	Poland	I Liga	Polonia Warszawa	Polonia Bytom	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	4	2025-11-20 15:02:35.581079	\N	\N	0	0	draw	yes
3081	1381642	2025-10-26	Poland	I Liga	Tychy 71	Chrobry Głogów	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16	3	2025-11-20 15:02:35.586214	\N	\N	0	1	a-win	yes
3082	1381643	2025-10-26	Poland	I Liga	Wisla Krakow	Stal Rzeszów	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	7	2025-11-20 15:02:35.594353	\N	\N	1	0	h-win	yes
3083	1381641	2025-10-26	Poland	I Liga	Stal Mielec	Miedz Legnica	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	15	12	2025-11-20 15:02:35.600407	\N	\N	1	0	h-win	yes
3084	1381635	2025-10-27	Poland	I Liga	Wieczysta Kraków	Pogoń Grod. Mazowiecki	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8	2	2025-11-20 15:02:35.605958	\N	\N	2	1	h-win	yes
3085	1381652	2025-10-31	Poland	I Liga	Górnik Łęczna	Polonia Warszawa	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	17	9	2025-11-20 15:02:35.613955	\N	\N	1	2	a-win	yes
3086	1381650	2025-10-31	Poland	I Liga	Ruch Chorzów	Tychy 71	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	16	2025-11-20 15:02:35.61986	\N	\N	2	0	h-win	yes
3087	1381651	2025-11-02	Poland	I Liga	Stal Rzeszów	Pogoń Siedlce	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7	11	2025-11-20 15:02:35.627917	\N	\N	0	0	draw	yes
3088	1381644	2025-11-02	Poland	I Liga	Chrobry Głogów	Wisla Krakow	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	1	2025-11-20 15:02:35.634032	\N	\N	0	1	a-win	yes
3089	1381648	2025-11-02	Poland	I Liga	Polonia Bytom	Znicz Pruszków	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	18	2025-11-20 15:02:35.641263	\N	\N	1	0	h-win	yes
3090	1381646	2025-11-02	Poland	I Liga	Miedz Legnica	Wieczysta Kraków	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	8	2025-11-20 15:02:35.647319	\N	\N	1	0	h-win	yes
3091	1381647	2025-11-03	Poland	I Liga	ŁKS Łódź	Slask Wroclaw	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	13	5	2025-11-20 15:02:35.653858	\N	\N	0	0	draw	yes
3092	1381645	2025-11-03	Poland	I Liga	Pogoń Grod. Mazowiecki	Odra Opole	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	10	2025-11-20 15:02:35.660683	\N	\N	1	1	draw	yes
3093	1381649	2025-11-05	Poland	I Liga	Puszcza Niepołomice	Stal Mielec	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	14	15	2025-11-20 15:02:35.666699	\N	\N	1	0	h-win	yes
3094	1381654	2025-11-07	Poland	I Liga	Ruch Chorzów	Miedz Legnica	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	12	2025-11-20 15:02:35.674863	\N	\N	2	1	h-win	yes
3095	1381657	2025-11-07	Poland	I Liga	Znicz Pruszków	Chrobry Głogów	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	18	3	2025-11-20 15:02:35.680851	\N	\N	0	0	draw	yes
3096	1381661	2025-11-08	Poland	I Liga	Wisla Krakow	Polonia Warszawa	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	9	2025-11-20 15:02:35.686566	\N	\N	1	1	draw	yes
3097	1381659	2025-11-08	Poland	I Liga	Stal Mielec	Pogoń Siedlce	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	15	11	2025-11-20 15:02:35.695272	\N	\N	0	0	draw	yes
3098	1381655	2025-11-08	Poland	I Liga	ŁKS Łódź	Puszcza Niepołomice	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	13	14	2025-11-20 15:02:35.701379	\N	\N	0	1	a-win	yes
3099	1381653	2025-11-08	Poland	I Liga	Wieczysta Kraków	Stal Rzeszów	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8	7	2025-11-20 15:02:35.708095	\N	\N	0	0	draw	yes
3100	1381656	2025-11-09	Poland	I Liga	Odra Opole	Górnik Łęczna	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	10	17	2025-11-20 15:02:35.714753	\N	\N	1	1	draw	yes
3101	1381658	2025-11-09	Poland	I Liga	Slask Wroclaw	Polonia Bytom	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	4	2025-11-20 15:02:35.723549	\N	\N	0	2	a-win	yes
3102	1381660	2025-11-09	Poland	I Liga	Tychy 71	Pogoń Grod. Mazowiecki	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16	2	2025-11-20 15:02:35.729482	\N	\N	1	2	a-win	yes
3103	1381668	2025-11-21	Poland	I Liga	Puszcza Niepołomice	Miedz Legnica	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 15:02:35.735019	\N	\N	0	0	draw	no
3104	1381663	2025-11-21	Poland	I Liga	Pogoń Grod. Mazowiecki	Slask Wroclaw	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 15:02:35.743105	\N	\N	0	0	draw	no
3105	1381662	2025-11-22	Poland	I Liga	Chrobry Głogów	Wieczysta Kraków	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 15:02:35.749325	\N	\N	0	0	draw	no
3106	1381670	2025-11-22	Poland	I Liga	Stal Rzeszów	Tychy 71	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 15:02:35.757562	\N	\N	0	0	draw	no
3107	1381666	2025-11-22	Poland	I Liga	Polonia Bytom	Stal Mielec	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 15:02:35.763543	\N	\N	0	0	draw	no
3108	1381669	2025-11-23	Poland	I Liga	Ruch Chorzów	Znicz Pruszków	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 15:02:35.770267	\N	\N	0	0	draw	no
3109	1381665	2025-11-23	Poland	I Liga	Pogoń Siedlce	Wisla Krakow	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 15:02:35.776015	\N	\N	0	0	draw	no
3110	1381664	2025-11-23	Poland	I Liga	Górnik Łęczna	ŁKS Łódź	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 15:02:35.782143	\N	\N	0	0	draw	no
3111	1381667	2025-11-23	Poland	I Liga	Polonia Warszawa	Odra Opole	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 15:02:35.789095	\N	\N	0	0	draw	no
3112	1395820	2025-08-01	Poland	II Liga - East	Rekord Bielsko-Biała	Podhale Nowy Targ	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	13	4	2025-11-20 16:17:39.269931	\N	\N	0	1	a-win	yes
3113	1395827	2025-08-01	Poland	II Liga - East	Stal Stalowa Wola	Podbeskidzie	h-win	5	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	12	2025-11-20 16:17:39.47086	\N	\N	3	0	h-win	yes
3114	1395826	2025-08-02	Poland	II Liga - East	Śląsk Wrocław II	Hutnik Kraków	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7	15	2025-11-20 16:17:39.650976	\N	\N	0	0	draw	yes
3115	1395824	2025-08-02	Poland	II Liga - East	Sandecja Nowy Sącz	Świt Skolwin	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8	5	2025-11-20 16:17:39.848722	\N	\N	2	1	h-win	yes
3116	1395828	2025-08-02	Poland	II Liga - East	Zaglebie Sosnowiec	Resovia Rzeszów	a-win	1	5	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	10	2025-11-20 16:17:40.014995	\N	\N	1	2	a-win	yes
3117	1395822	2025-08-02	Poland	II Liga - East	Jastrzębie	ŁKS Łódź II	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	18	17	2025-11-20 16:17:40.204438	\N	\N	0	1	a-win	yes
3118	1395825	2025-08-02	Poland	II Liga - East	Unia Skierniewice	Olimpia Grudziądz	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	3	2025-11-20 16:17:40.394784	\N	\N	1	1	draw	yes
3119	1395823	2025-08-03	Poland	II Liga - East	Kalisz	Sokół Kleczew	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16	14	2025-11-20 16:17:40.57474	\N	\N	0	0	draw	yes
3120	1395821	2025-08-03	Poland	II Liga - East	Chojniczanka Chojnice	Warta Poznań	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	11	2	2025-11-20 16:17:40.765579	\N	\N	1	0	h-win	yes
3121	1395833	2025-08-08	Poland	II Liga - East	Podbeskidzie	Śląsk Wrocław II	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	7	2025-11-20 16:17:40.953223	\N	\N	0	0	draw	yes
3122	1395829	2025-08-09	Poland	II Liga - East	Hutnik Kraków	Resovia Rzeszów	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	15	10	2025-11-20 16:17:41.142292	\N	\N	1	1	draw	yes
3123	1395834	2025-08-09	Poland	II Liga - East	Sandecja Nowy Sącz	Rekord Bielsko-Biała	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8	13	2025-11-20 16:17:41.330327	\N	\N	1	0	h-win	yes
3124	1395830	2025-08-09	Poland	II Liga - East	Sokół Kleczew	Jastrzębie	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	14	18	2025-11-20 16:17:41.514943	\N	\N	2	0	h-win	yes
3125	1395836	2025-08-09	Poland	II Liga - East	Stal Stalowa Wola	Kalisz	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	16	2025-11-20 16:17:41.69151	\N	\N	1	0	h-win	yes
3126	1395831	2025-08-10	Poland	II Liga - East	ŁKS Łódź II	Chojniczanka Chojnice	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	17	11	2025-11-20 16:17:41.891995	\N	\N	0	0	draw	yes
3127	1395835	2025-08-10	Poland	II Liga - East	Świt Skolwin	Warta Poznań	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	2	2025-11-20 16:17:42.124277	\N	\N	1	1	draw	yes
3128	1395832	2025-08-10	Poland	II Liga - East	Olimpia Grudziądz	Podhale Nowy Targ	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	4	2025-11-20 16:17:42.314126	\N	\N	0	1	a-win	yes
3129	1395837	2025-08-10	Poland	II Liga - East	Zaglebie Sosnowiec	Unia Skierniewice	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	1	2025-11-20 16:17:42.509744	\N	\N	0	1	a-win	yes
3130	1395840	2025-08-15	Poland	II Liga - East	Jastrzębie	Sandecja Nowy Sącz	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	18	8	2025-11-20 16:17:42.697008	\N	\N	2	2	draw	yes
3131	1395839	2025-08-15	Poland	II Liga - East	Chojniczanka Chojnice	Podbeskidzie	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	11	12	2025-11-20 16:17:42.897269	\N	\N	0	0	draw	yes
3132	1395838	2025-08-15	Poland	II Liga - East	Rekord Bielsko-Biała	Sokół Kleczew	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	13	14	2025-11-20 16:17:43.097374	\N	\N	2	0	h-win	yes
3133	1395844	2025-08-15	Poland	II Liga - East	Resovia Rzeszów	Olimpia Grudziądz	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	10	3	2025-11-20 16:17:43.273232	\N	\N	1	1	draw	yes
3134	1395845	2025-08-15	Poland	II Liga - East	Unia Skierniewice	Świt Skolwin	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	5	2025-11-20 16:17:43.477876	\N	\N	0	1	a-win	yes
3135	1395846	2025-08-16	Poland	II Liga - East	Śląsk Wrocław II	Zaglebie Sosnowiec	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7	9	2025-11-20 16:17:43.672116	\N	\N	0	1	a-win	yes
3136	1395842	2025-08-17	Poland	II Liga - East	ŁKS Łódź II	Warta Poznań	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	17	2	2025-11-20 16:17:43.846293	\N	\N	0	0	draw	yes
3137	1395843	2025-08-17	Poland	II Liga - East	Podhale Nowy Targ	Stal Stalowa Wola	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	6	2025-11-20 16:17:44.055031	\N	\N	0	1	a-win	yes
3138	1395841	2025-08-17	Poland	II Liga - East	Kalisz	Hutnik Kraków	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16	15	2025-11-20 16:17:44.249958	\N	\N	0	0	draw	yes
3139	1395855	2025-08-22	Poland	II Liga - East	Rekord Bielsko-Biała	Warta Poznań	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	13	2	2025-11-20 16:17:44.466048	\N	\N	1	0	h-win	yes
3140	1396000	2025-08-22	Poland	II Liga - East	Rekord Bielsko-Biała	Warta Poznań	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	13	2	2025-11-20 16:17:44.666922	\N	\N	1	0	h-win	yes
3141	1395849	2025-08-22	Poland	II Liga - East	Sokół Kleczew	Resovia Rzeszów	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	14	10	2025-11-20 16:17:44.846948	\N	\N	1	0	h-win	yes
3142	1395854	2025-08-22	Poland	II Liga - East	Stal Stalowa Wola	Unia Skierniewice	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	1	2025-11-20 16:17:45.024593	\N	\N	1	1	draw	yes
3143	1395852	2025-08-23	Poland	II Liga - East	Podhale Nowy Targ	Zaglebie Sosnowiec	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	9	2025-11-20 16:17:45.211613	\N	\N	1	1	draw	yes
3144	1395848	2025-08-23	Poland	II Liga - East	Hutnik Kraków	Sandecja Nowy Sącz	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	15	8	2025-11-20 16:17:45.398362	\N	\N	0	0	draw	yes
3145	1395853	2025-08-23	Poland	II Liga - East	Świt Skolwin	Jastrzębie	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	18	2025-11-20 16:17:45.590936	\N	\N	2	0	h-win	yes
3146	1395847	2025-08-23	Poland	II Liga - East	Chojniczanka Chojnice	Kalisz	draw	3	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	11	16	2025-11-20 16:17:45.777956	\N	\N	1	0	h-win	yes
3147	1395851	2025-08-23	Poland	II Liga - East	Podbeskidzie	ŁKS Łódź II	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	17	2025-11-20 16:17:45.966962	\N	\N	0	0	draw	yes
3148	1395850	2025-08-24	Poland	II Liga - East	Olimpia Grudziądz	Śląsk Wrocław II	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	7	2025-11-20 16:17:46.156976	\N	\N	2	0	h-win	yes
3149	1395859	2025-08-29	Poland	II Liga - East	Resovia Rzeszów	Podhale Nowy Targ	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	10	4	2025-11-20 16:17:46.360543	\N	\N	0	0	draw	yes
3150	1395861	2025-08-29	Poland	II Liga - East	Unia Skierniewice	Rekord Bielsko-Biała	h-win	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	13	2025-11-20 16:17:46.543934	\N	\N	2	0	h-win	yes
4449	1469186	2025-09-17	England	FA Cup	Woodford Town	Bury Town	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.882348	\N	\N	0	0	draw	yes
3151	1395858	2025-08-30	Poland	II Liga - East	Podbeskidzie	Hutnik Kraków	draw	3	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	15	2025-11-20 16:17:46.736966	\N	\N	2	2	draw	yes
3152	1395857	2025-08-30	Poland	II Liga - East	Kalisz	ŁKS Łódź II	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16	17	2025-11-20 16:17:46.917554	\N	\N	0	0	draw	yes
3153	1395862	2025-08-30	Poland	II Liga - East	Śląsk Wrocław II	Stal Stalowa Wola	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7	6	2025-11-20 16:17:47.107974	\N	\N	2	2	draw	yes
3154	1395856	2025-08-30	Poland	II Liga - East	Jastrzębie	Warta Poznań	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	18	2	2025-11-20 16:17:47.312091	\N	\N	1	0	h-win	yes
3155	1395864	2025-08-31	Poland	II Liga - East	Zaglebie Sosnowiec	Olimpia Grudziądz	draw	3	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	3	2025-11-20 16:17:47.508104	\N	\N	1	2	a-win	yes
3156	1395860	2025-08-31	Poland	II Liga - East	Sandecja Nowy Sącz	Chojniczanka Chojnice	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8	11	2025-11-20 16:17:47.704151	\N	\N	1	1	draw	yes
3157	1395863	2025-09-03	Poland	II Liga - East	Świt Skolwin	Sokół Kleczew	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	14	2025-11-20 16:17:47.896961	\N	\N	1	1	draw	yes
3158	1395871	2025-09-05	Poland	II Liga - East	Resovia Rzeszów	Śląsk Wrocław II	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	10	7	2025-11-20 16:17:48.073673	\N	\N	1	1	draw	yes
3159	1395870	2025-09-06	Poland	II Liga - East	Podhale Nowy Targ	Unia Skierniewice	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	1	2025-11-20 16:17:48.265922	\N	\N	1	0	h-win	yes
3160	1395865	2025-09-06	Poland	II Liga - East	Rekord Bielsko-Biała	Kalisz	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	13	16	2025-11-20 16:17:48.457233	\N	\N	0	1	a-win	yes
3161	1395873	2025-09-07	Poland	II Liga - East	Warta Poznań	Zaglebie Sosnowiec	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	9	2025-11-20 16:17:48.639261	\N	\N	0	0	draw	yes
3162	1395872	2025-09-07	Poland	II Liga - East	Stal Stalowa Wola	Świt Skolwin	h-win	5	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	5	2025-11-20 16:17:48.799191	\N	\N	2	2	draw	yes
3163	1395877	2025-09-12	Poland	II Liga - East	Sokół Kleczew	Podhale Nowy Targ	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	14	4	2025-11-20 16:17:48.95564	\N	\N	0	1	a-win	yes
3164	1395878	2025-09-12	Poland	II Liga - East	ŁKS Łódź II	Olimpia Grudziądz	a-win	2	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	17	3	2025-11-20 16:17:49.116444	\N	\N	1	2	a-win	yes
3165	1395880	2025-09-12	Poland	II Liga - East	Unia Skierniewice	Hutnik Kraków	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	15	2025-11-20 16:17:49.278572	\N	\N	1	0	h-win	yes
3166	1395875	2025-09-13	Poland	II Liga - East	Jastrzębie	Chojniczanka Chojnice	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	18	11	2025-11-20 16:17:49.445752	\N	\N	0	0	draw	yes
3167	1395874	2025-09-13	Poland	II Liga - East	Rekord Bielsko-Biała	Zaglebie Sosnowiec	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	13	9	2025-11-20 16:17:49.602234	\N	\N	1	2	a-win	yes
3168	1395879	2025-09-13	Poland	II Liga - East	Sandecja Nowy Sącz	Stal Stalowa Wola	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8	6	2025-11-20 16:17:49.753657	\N	\N	1	1	draw	yes
3169	1395882	2025-09-14	Poland	II Liga - East	Świt Skolwin	Resovia Rzeszów	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	10	2025-11-20 16:17:49.910188	\N	\N	1	1	draw	yes
3170	1395881	2025-09-14	Poland	II Liga - East	Śląsk Wrocław II	Warta Poznań	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7	2	2025-11-20 16:17:50.067351	\N	\N	0	0	draw	yes
3171	1395876	2025-09-14	Poland	II Liga - East	Kalisz	Podbeskidzie	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16	12	2025-11-20 16:17:50.234353	\N	\N	0	1	a-win	yes
3172	1395868	2025-09-16	Poland	II Liga - East	ŁKS Łódź II	Sandecja Nowy Sącz	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	17	8	2025-11-20 16:17:50.386392	\N	\N	1	0	h-win	yes
3173	1395867	2025-09-17	Poland	II Liga - East	Hutnik Kraków	Jastrzębie	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	15	18	2025-11-20 16:17:50.54411	\N	\N	0	0	draw	yes
3174	1395866	2025-09-17	Poland	II Liga - East	Chojniczanka Chojnice	Sokół Kleczew	a-win	1	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	11	14	2025-11-20 16:17:50.713436	\N	\N	0	1	a-win	yes
3175	1395869	2025-09-17	Poland	II Liga - East	Olimpia Grudziądz	Podbeskidzie	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	12	2025-11-20 16:17:50.88688	\N	\N	0	0	draw	yes
3176	1395891	2025-09-19	Poland	II Liga - East	Zaglebie Sosnowiec	Świt Skolwin	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	5	2025-11-20 16:17:51.081237	\N	\N	0	0	draw	yes
3177	1395889	2025-09-19	Poland	II Liga - East	Stal Stalowa Wola	ŁKS Łódź II	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	17	2025-11-20 16:17:51.261492	\N	\N	1	1	draw	yes
3178	1395890	2025-09-20	Poland	II Liga - East	Warta Poznań	Sokół Kleczew	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	14	2025-11-20 16:17:51.446123	\N	\N	2	1	h-win	yes
3179	1395884	2025-09-20	Poland	II Liga - East	Hutnik Kraków	Rekord Bielsko-Biała	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	15	13	2025-11-20 16:17:51.634209	\N	\N	0	0	draw	yes
3180	1395883	2025-09-20	Poland	II Liga - East	Chojniczanka Chojnice	Śląsk Wrocław II	a-win	2	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	11	7	2025-11-20 16:17:51.829543	\N	\N	1	0	h-win	yes
3181	1395886	2025-09-20	Poland	II Liga - East	Podbeskidzie	Unia Skierniewice	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	1	2025-11-20 16:17:52.013684	\N	\N	2	0	h-win	yes
3182	1395885	2025-09-20	Poland	II Liga - East	Olimpia Grudziądz	Jastrzębie	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	18	2025-11-20 16:17:52.212779	\N	\N	1	0	h-win	yes
3183	1395887	2025-09-21	Poland	II Liga - East	Podhale Nowy Targ	Kalisz	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	16	2025-11-20 16:17:52.409767	\N	\N	1	1	draw	yes
3184	1395888	2025-09-21	Poland	II Liga - East	Resovia Rzeszów	Sandecja Nowy Sącz	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	10	8	2025-11-20 16:17:52.581454	\N	\N	0	1	a-win	yes
3185	1395900	2025-09-26	Poland	II Liga - East	Warta Poznań	Stal Stalowa Wola	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	6	2025-11-20 16:17:52.741869	\N	\N	1	0	h-win	yes
3186	1395894	2025-09-27	Poland	II Liga - East	Kalisz	Olimpia Grudziądz	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16	3	2025-11-20 16:17:52.900866	\N	\N	0	0	draw	yes
3187	1395898	2025-09-27	Poland	II Liga - East	Śląsk Wrocław II	Podhale Nowy Targ	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7	4	2025-11-20 16:17:53.083446	\N	\N	0	0	draw	yes
3188	1395899	2025-09-27	Poland	II Liga - East	Świt Skolwin	Chojniczanka Chojnice	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	11	2025-11-20 16:17:53.272824	\N	\N	1	1	draw	yes
3189	1395897	2025-09-27	Poland	II Liga - East	Sandecja Nowy Sącz	Unia Skierniewice	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8	1	2025-11-20 16:17:53.464763	\N	\N	1	1	draw	yes
3190	1395895	2025-09-28	Poland	II Liga - East	Sokół Kleczew	Hutnik Kraków	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	14	15	2025-11-20 16:17:53.63351	\N	\N	2	0	h-win	yes
3191	1395893	2025-09-28	Poland	II Liga - East	Jastrzębie	Resovia Rzeszów	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	18	10	2025-11-20 16:17:53.790922	\N	\N	0	0	draw	yes
3192	1396048	2025-09-28	Poland	II Liga - East	Podbeskidzie	Rekord Bielsko-Biała	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	13	2025-11-20 16:17:53.965669	\N	\N	1	2	a-win	yes
3193	1395896	2025-09-29	Poland	II Liga - East	ŁKS Łódź II	Zaglebie Sosnowiec	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	17	9	2025-11-20 16:17:54.161977	\N	\N	1	2	a-win	yes
3194	1395902	2025-10-03	Poland	II Liga - East	Kalisz	Sandecja Nowy Sącz	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16	8	2025-11-20 16:17:54.345793	\N	\N	1	0	h-win	yes
3195	1395905	2025-10-04	Poland	II Liga - East	Podhale Nowy Targ	ŁKS Łódź II	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	17	2025-11-20 16:17:54.546099	\N	\N	1	0	h-win	yes
3196	1395904	2025-10-04	Poland	II Liga - East	Podbeskidzie	Warta Poznań	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	2	2025-11-20 16:17:54.737241	\N	\N	0	1	a-win	yes
3197	1395907	2025-10-04	Poland	II Liga - East	Unia Skierniewice	Śląsk Wrocław II	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	7	2025-11-20 16:17:54.904875	\N	\N	0	1	a-win	yes
3198	1395908	2025-10-05	Poland	II Liga - East	Stal Stalowa Wola	Chojniczanka Chojnice	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	11	2025-11-20 16:17:55.093529	\N	\N	1	1	draw	yes
3199	1395901	2025-10-05	Poland	II Liga - East	Hutnik Kraków	Świt Skolwin	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	15	5	2025-11-20 16:17:55.282167	\N	\N	1	1	draw	yes
3200	1395906	2025-10-05	Poland	II Liga - East	Resovia Rzeszów	Rekord Bielsko-Biała	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	10	13	2025-11-20 16:17:55.465279	\N	\N	1	0	h-win	yes
3201	1395909	2025-10-05	Poland	II Liga - East	Zaglebie Sosnowiec	Jastrzębie	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	18	2025-11-20 16:17:55.626414	\N	\N	0	0	draw	yes
3202	1395903	2025-10-05	Poland	II Liga - East	Olimpia Grudziądz	Sokół Kleczew	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	14	2025-11-20 16:17:55.825919	\N	\N	0	0	draw	yes
3203	1395914	2025-10-10	Poland	II Liga - East	ŁKS Łódź II	Resovia Rzeszów	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	17	10	2025-11-20 16:17:56.017727	\N	\N	0	0	draw	yes
3204	1395917	2025-10-11	Poland	II Liga - East	Warta Poznań	Olimpia Grudziądz	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	3	2025-11-20 16:17:56.204416	\N	\N	1	1	draw	yes
3205	1395916	2025-10-11	Poland	II Liga - East	Świt Skolwin	Podhale Nowy Targ	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	4	2025-11-20 16:17:56.384241	\N	\N	2	0	h-win	yes
3206	1395913	2025-10-11	Poland	II Liga - East	Sokół Kleczew	Unia Skierniewice	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	14	1	2025-11-20 16:17:56.550845	\N	\N	0	2	a-win	yes
3207	1395912	2025-10-11	Poland	II Liga - East	Jastrzębie	Kalisz	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	18	16	2025-11-20 16:17:56.728225	\N	\N	0	0	draw	yes
3208	1395910	2025-10-12	Poland	II Liga - East	Rekord Bielsko-Biała	Stal Stalowa Wola	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	13	6	2025-11-20 16:17:56.922035	\N	\N	1	0	h-win	yes
3209	1395927	2025-10-17	Poland	II Liga - East	Warta Poznań	Hutnik Kraków	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	15	2025-11-20 16:17:57.116788	\N	\N	1	0	h-win	yes
3210	1395924	2025-10-17	Poland	II Liga - East	Unia Skierniewice	Jastrzębie	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	18	2025-11-20 16:17:57.305792	\N	\N	1	0	h-win	yes
3211	1395923	2025-10-18	Poland	II Liga - East	Podhale Nowy Targ	Sandecja Nowy Sącz	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	8	2025-11-20 16:17:57.500763	\N	\N	1	0	h-win	yes
3212	1395925	2025-10-18	Poland	II Liga - East	Śląsk Wrocław II	Sokół Kleczew	a-win	2	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7	14	2025-11-20 16:17:57.692824	\N	\N	0	3	a-win	yes
3213	1395919	2025-10-18	Poland	II Liga - East	Kalisz	Resovia Rzeszów	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16	10	2025-11-20 16:17:57.881856	\N	\N	0	0	draw	yes
3214	1395921	2025-10-19	Poland	II Liga - East	Olimpia Grudziądz	Chojniczanka Chojnice	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	11	2025-11-20 16:17:58.078423	\N	\N	1	1	draw	yes
3215	1395922	2025-10-19	Poland	II Liga - East	Podbeskidzie	Świt Skolwin	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	5	2025-11-20 16:17:58.272726	\N	\N	0	0	draw	yes
3216	1395920	2025-10-19	Poland	II Liga - East	ŁKS Łódź II	Rekord Bielsko-Biała	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	17	13	2025-11-20 16:17:58.451607	\N	\N	0	2	a-win	yes
3217	1395926	2025-10-19	Poland	II Liga - East	Stal Stalowa Wola	Zaglebie Sosnowiec	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	9	2025-11-20 16:17:58.641006	\N	\N	0	0	draw	yes
3218	1395915	2025-10-21	Poland	II Liga - East	Sandecja Nowy Sącz	Śląsk Wrocław II	a-win	0	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8	7	2025-11-20 16:17:58.821082	\N	\N	0	2	a-win	yes
3219	1395911	2025-10-22	Poland	II Liga - East	Chojniczanka Chojnice	Hutnik Kraków	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	11	15	2025-11-20 16:17:59.012143	\N	\N	1	1	draw	yes
3220	1395918	2025-10-22	Poland	II Liga - East	Zaglebie Sosnowiec	Podbeskidzie	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	12	2025-11-20 16:17:59.200466	\N	\N	1	0	h-win	yes
3221	1395936	2025-10-24	Poland	II Liga - East	Świt Skolwin	ŁKS Łódź II	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	17	2025-11-20 16:17:59.392115	\N	\N	2	0	h-win	yes
3222	1395932	2025-10-24	Poland	II Liga - East	Kalisz	Śląsk Wrocław II	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16	7	2025-11-20 16:17:59.584551	\N	\N	0	0	draw	yes
3223	1395931	2025-10-25	Poland	II Liga - East	Hutnik Kraków	Zaglebie Sosnowiec	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	15	9	2025-11-20 16:17:59.770939	\N	\N	0	0	draw	yes
3224	1395930	2025-10-25	Poland	II Liga - East	Jastrzębie	Podbeskidzie	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	18	12	2025-11-20 16:17:59.971792	\N	\N	1	1	draw	yes
3225	1395928	2025-10-25	Poland	II Liga - East	Rekord Bielsko-Biała	Olimpia Grudziądz	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	13	3	2025-11-20 16:18:00.161855	\N	\N	0	2	a-win	yes
3226	1395929	2025-10-25	Poland	II Liga - East	Chojniczanka Chojnice	Podhale Nowy Targ	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	11	4	2025-11-20 16:18:00.342687	\N	\N	0	0	draw	yes
3227	1395933	2025-10-26	Poland	II Liga - East	Sokół Kleczew	Stal Stalowa Wola	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	14	6	2025-11-20 16:18:00.533158	\N	\N	1	0	h-win	yes
3228	1395935	2025-10-26	Poland	II Liga - East	Sandecja Nowy Sącz	Warta Poznań	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8	2	2025-11-20 16:18:00.710473	\N	\N	0	0	draw	yes
3229	1395934	2025-10-26	Poland	II Liga - East	Resovia Rzeszów	Unia Skierniewice	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	10	1	2025-11-20 16:18:00.891679	\N	\N	0	1	a-win	yes
3230	1395938	2025-10-31	Poland	II Liga - East	Sokół Kleczew	Podbeskidzie	h-win	5	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	14	12	2025-11-20 16:18:01.085871	\N	\N	3	1	h-win	yes
3231	1395937	2025-10-31	Poland	II Liga - East	Rekord Bielsko-Biała	Jastrzębie	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	13	18	2025-11-20 16:18:01.283575	\N	\N	1	2	a-win	yes
3232	1395942	2025-10-31	Poland	II Liga - East	Śląsk Wrocław II	Świt Skolwin	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7	5	2025-11-20 16:18:01.482682	\N	\N	2	1	h-win	yes
3233	1395943	2025-10-31	Poland	II Liga - East	Stal Stalowa Wola	Resovia Rzeszów	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	10	2025-11-20 16:18:01.676709	\N	\N	0	0	draw	yes
3234	1395944	2025-10-31	Poland	II Liga - East	Warta Poznań	Kalisz	h-win	4	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	16	2025-11-20 16:18:01.868036	\N	\N	0	1	a-win	yes
3235	1395941	2025-10-31	Poland	II Liga - East	Unia Skierniewice	ŁKS Łódź II	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	17	2025-11-20 16:18:02.066405	\N	\N	2	0	h-win	yes
3236	1395945	2025-10-31	Poland	II Liga - East	Zaglebie Sosnowiec	Chojniczanka Chojnice	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	11	2025-11-20 16:18:02.260753	\N	\N	0	0	draw	yes
3237	1395940	2025-11-02	Poland	II Liga - East	Podhale Nowy Targ	Hutnik Kraków	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	15	2025-11-20 16:18:02.46273	\N	\N	0	0	draw	yes
3238	1395939	2025-11-02	Poland	II Liga - East	Olimpia Grudziądz	Sandecja Nowy Sącz	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	8	2025-11-20 16:18:02.661138	\N	\N	1	0	h-win	yes
3239	1395946	2025-11-07	Poland	II Liga - East	Chojniczanka Chojnice	Unia Skierniewice	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	11	1	2025-11-20 16:18:02.854746	\N	\N	0	1	a-win	yes
3240	1395952	2025-11-07	Poland	II Liga - East	Sandecja Nowy Sącz	Sokół Kleczew	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8	14	2025-11-20 16:18:03.014054	\N	\N	0	1	a-win	yes
3241	1395947	2025-11-08	Poland	II Liga - East	Jastrzębie	Stal Stalowa Wola	a-win	1	5	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	18	6	2025-11-20 16:18:03.178521	\N	\N	0	2	a-win	yes
3242	1395953	2025-11-08	Poland	II Liga - East	Świt Skolwin	Rekord Bielsko-Biała	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	13	2025-11-20 16:18:03.351918	\N	\N	1	2	a-win	yes
3243	1395954	2025-11-08	Poland	II Liga - East	Warta Poznań	Podhale Nowy Targ	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	4	2025-11-20 16:18:03.55049	\N	\N	0	0	draw	yes
3244	1395948	2025-11-09	Poland	II Liga - East	Hutnik Kraków	Olimpia Grudziądz	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	15	3	2025-11-20 16:18:03.722871	\N	\N	1	1	draw	yes
3245	1395951	2025-11-09	Poland	II Liga - East	Podbeskidzie	Resovia Rzeszów	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	10	2025-11-20 16:18:03.927773	\N	\N	1	0	h-win	yes
3246	1395949	2025-11-09	Poland	II Liga - East	Kalisz	Zaglebie Sosnowiec	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16	9	2025-11-20 16:18:04.112823	\N	\N	1	0	h-win	yes
3247	1395950	2025-11-10	Poland	II Liga - East	ŁKS Łódź II	Śląsk Wrocław II	a-win	1	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	17	7	2025-11-20 16:18:04.30917	\N	\N	0	2	a-win	yes
3248	1395962	2025-11-14	Poland	II Liga - East	Stal Stalowa Wola	Hutnik Kraków	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.75	3.50	3.75	6	15	2025-11-20 16:18:04.521196	\N	\N	1	1	draw	yes
3249	1395957	2025-11-15	Poland	II Liga - East	Olimpia Grudziądz	Świt Skolwin	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.50	3.85	5.00	3	5	2025-11-20 16:18:04.740486	\N	\N	0	1	a-win	yes
3250	1395958	2025-11-16	Poland	II Liga - East	Podhale Nowy Targ	Podbeskidzie	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2.05	3.20	3.10	4	12	2025-11-20 16:18:04.934012	\N	\N	1	0	h-win	yes
3251	1395961	2025-11-16	Poland	II Liga - East	Śląsk Wrocław II	Jastrzębie	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.50	4.20	4.50	7	18	2025-11-20 16:18:05.151276	\N	\N	1	2	a-win	yes
4450	1470095	2025-09-23	England	FA Cup	Sporting Khalsa	Hereford	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.893096	\N	\N	0	0	draw	yes
3252	1395955	2025-11-16	Poland	II Liga - East	Rekord Bielsko-Biała	Chojniczanka Chojnice	a-win	0	5	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2.55	3.30	2.33	13	11	2025-11-20 16:18:05.370166	\N	\N	0	3	a-win	yes
3253	1395960	2025-11-16	Poland	II Liga - East	Unia Skierniewice	Kalisz	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.40	3.95	6.80	1	16	2025-11-20 16:18:05.678184	\N	\N	1	1	draw	yes
3254	1395959	2025-11-16	Poland	II Liga - East	Resovia Rzeszów	Warta Poznań	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2.25	3.20	2.80	10	2	2025-11-20 16:18:05.885371	\N	\N	0	1	a-win	yes
3255	1395963	2025-11-15	Poland	II Liga - East	Zaglebie Sosnowiec	Sandecja Nowy Sącz	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 16:18:06.064669	\N	\N	0	0	draw	no
3256	1395968	2025-11-21	Poland	II Liga - East	ŁKS Łódź II	Hutnik Kraków	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3.10	3.25	2.05	\N	\N	2025-11-20 16:18:06.252485	\N	\N	0	0	draw	no
3257	1395972	2025-11-21	Poland	II Liga - East	Zaglebie Sosnowiec	Sokół Kleczew	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.75	3.30	3.90	\N	\N	2025-11-20 16:18:06.468094	\N	\N	0	0	draw	no
3258	1395967	2025-11-22	Poland	II Liga - East	Kalisz	Świt Skolwin	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2.20	3.40	2.70	\N	\N	2025-11-20 16:18:06.663637	\N	\N	0	0	draw	no
3259	1395966	2025-11-22	Poland	II Liga - East	Jastrzębie	Podhale Nowy Targ	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4.75	3.70	1.57	\N	\N	2025-11-20 16:18:06.828534	\N	\N	0	0	draw	no
3260	1395964	2025-11-22	Poland	II Liga - East	Rekord Bielsko-Biała	Śląsk Wrocław II	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 16:18:06.910353	\N	\N	0	0	draw	no
3261	1395971	2025-11-22	Poland	II Liga - East	Warta Poznań	Unia Skierniewice	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 16:18:06.915919	\N	\N	0	0	draw	no
3262	1395965	2025-11-22	Poland	II Liga - East	Chojniczanka Chojnice	Resovia Rzeszów	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 16:18:06.920953	\N	\N	0	0	draw	no
3263	1395969	2025-11-23	Poland	II Liga - East	Sandecja Nowy Sącz	Podbeskidzie	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 16:18:06.926446	\N	\N	0	0	draw	no
3264	1395970	2025-11-23	Poland	II Liga - East	Stal Stalowa Wola	Olimpia Grudziądz	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 16:18:06.93586	\N	\N	0	0	draw	no
3265	1378969	2025-08-15	England	Premier League	Liverpool	Bournemouth	h-win	4	2	19	10	10	3	6	7	2	2	1	2	0	0	61.00	39.00	7	10	\N	\N	\N	8	9	2025-11-20 17:16:41.938208	2.21	1.70	1	0	h-win	yes
3266	1378970	2025-08-16	England	Premier League	Aston Villa	Newcastle	draw	0	0	3	3	16	3	3	6	2	1	1	1	1	0	40.00	60.00	13	11	\N	\N	\N	6	14	2025-11-20 17:16:42.113338	0.20	1.43	0	0	draw	yes
3267	1378974	2025-08-16	England	Premier League	Tottenham	Burnley	h-win	3	0	16	6	14	4	6	5	0	4	0	0	0	0	67.00	33.00	14	8	\N	\N	\N	5	17	2025-11-20 17:16:42.308681	2.32	0.94	1	0	h-win	yes
3268	1378971	2025-08-16	England	Premier League	Brighton	Fulham	draw	1	1	10	4	7	2	4	3	3	2	3	3	0	0	50.00	50.00	16	15	\N	\N	\N	11	15	2025-11-20 17:16:42.48999	1.48	0.76	0	0	draw	yes
3269	1378973	2025-08-16	England	Premier League	Sunderland	West Ham	h-win	3	0	10	5	12	4	5	7	0	0	0	1	0	0	37.00	63.00	8	10	\N	\N	\N	4	18	2025-11-20 17:16:42.658115	0.68	0.56	0	0	draw	yes
3270	1378975	2025-08-16	England	Premier League	Wolves	Manchester City	a-win	0	4	9	3	15	4	4	5	4	0	1	2	0	0	42.00	58.00	13	7	\N	\N	\N	20	2	2025-11-20 17:16:42.874584	0.56	2.47	0	2	a-win	yes
3271	1378976	2025-08-17	England	Premier League	Chelsea	Crystal Palace	draw	0	0	19	3	11	4	11	2	0	0	2	3	0	0	72.00	28.00	10	12	\N	\N	\N	3	10	2025-11-20 17:16:43.060969	1.60	0.66	0	0	draw	yes
3272	1378972	2025-08-17	England	Premier League	Nottingham Forest	Brentford	h-win	3	1	11	5	10	3	5	5	2	0	1	2	0	0	55.00	45.00	7	15	\N	\N	\N	19	12	2025-11-20 17:16:43.246017	1.86	1.50	3	0	h-win	yes
3273	1378977	2025-08-17	England	Premier League	Manchester United	Arsenal	a-win	0	1	22	7	9	3	3	4	1	2	1	4	0	0	61.00	39.00	10	19	\N	\N	\N	7	1	2025-11-20 17:16:43.429532	1.52	1.31	0	1	a-win	yes
3274	1378978	2025-08-18	England	Premier League	Leeds	Everton	h-win	1	0	21	3	7	1	7	2	1	2	0	2	0	0	54.00	46.00	6	8	\N	\N	\N	16	13	2025-11-20 17:16:43.63718	2.13	0.80	0	0	draw	yes
3275	1378988	2025-08-22	England	Premier League	West Ham	Chelsea	a-win	1	5	12	4	12	7	7	5	4	2	0	1	0	0	41.00	59.00	7	10	\N	\N	\N	18	3	2025-11-20 17:16:43.82153	0.73	2.74	1	3	a-win	yes
3276	1378986	2025-08-23	England	Premier League	Manchester City	Tottenham	a-win	0	2	10	4	12	5	7	2	0	1	1	4	0	0	61.00	39.00	7	12	\N	\N	\N	2	5	2025-11-20 17:16:44.010799	1.55	1.11	0	2	a-win	yes
3277	1378980	2025-08-23	England	Premier League	Bournemouth	Wolves	h-win	1	0	14	4	6	1	8	3	2	2	2	4	0	1	59.00	41.00	13	16	\N	\N	\N	9	20	2025-11-20 17:16:44.192302	1.29	0.46	1	0	h-win	yes
3278	1378982	2025-08-23	England	Premier League	Burnley	Sunderland	h-win	2	0	7	2	9	1	4	3	0	2	0	1	0	0	42.00	58.00	9	5	\N	\N	\N	17	4	2025-11-20 17:16:44.384637	1.00	0.77	0	0	draw	yes
3279	1378981	2025-08-23	England	Premier League	Brentford	Aston Villa	h-win	1	0	9	2	17	2	2	9	1	0	1	2	0	0	24.00	76.00	11	9	\N	\N	\N	12	6	2025-11-20 17:16:44.568264	1.27	1.23	1	0	h-win	yes
3280	1378979	2025-08-23	England	Premier League	Arsenal	Leeds	h-win	5	0	18	5	3	1	2	2	0	0	0	2	0	0	68.00	32.00	8	11	\N	\N	\N	1	16	2025-11-20 17:16:44.753261	2.88	0.17	2	0	h-win	yes
3281	1378984	2025-08-24	England	Premier League	Everton	Brighton	h-win	2	0	11	3	13	4	2	2	0	6	4	3	0	0	42.00	58.00	7	15	\N	\N	\N	13	11	2025-11-20 17:16:44.96773	1.60	2.43	1	0	h-win	yes
3282	1378983	2025-08-24	England	Premier League	Crystal Palace	Nottingham Forest	draw	1	1	8	4	9	1	1	3	2	2	3	3	0	0	42.00	58.00	11	11	\N	\N	\N	10	19	2025-11-20 17:16:45.162892	1.10	0.93	1	0	h-win	yes
3283	1378985	2025-08-24	England	Premier League	Fulham	Manchester United	draw	1	1	13	4	10	3	9	6	2	1	1	1	0	0	52.00	48.00	12	10	\N	\N	\N	15	7	2025-11-20 17:16:45.352165	1.76	1.63	0	0	draw	yes
3284	1378987	2025-08-25	England	Premier League	Newcastle	Liverpool	a-win	2	3	10	3	5	4	7	1	0	0	2	3	1	0	38.00	62.00	17	15	\N	\N	\N	14	8	2025-11-20 17:16:45.526974	0.98	0.69	0	1	a-win	yes
3285	1378991	2025-08-30	England	Premier League	Chelsea	Fulham	h-win	2	0	13	6	11	3	6	4	3	1	2	2	0	0	54.00	46.00	11	17	\N	\N	\N	3	15	2025-11-20 17:16:45.682041	2.35	1.02	1	0	h-win	yes
3286	1378994	2025-08-30	England	Premier League	Manchester United	Burnley	h-win	3	2	26	6	6	3	7	1	1	1	1	5	0	0	62.00	38.00	9	9	\N	\N	\N	7	17	2025-11-20 17:16:45.834464	3.54	1.20	1	0	h-win	yes
3287	1378998	2025-08-30	England	Premier League	Wolves	Everton	a-win	2	3	12	4	10	4	2	2	2	1	0	1	0	0	59.00	41.00	15	10	\N	\N	\N	20	13	2025-11-20 17:16:46.00021	1.11	1.93	1	2	a-win	yes
3288	1378997	2025-08-30	England	Premier League	Tottenham	Bournemouth	a-win	0	1	5	1	20	6	0	8	2	3	2	4	0	0	61.00	39.00	17	13	\N	\N	\N	5	9	2025-11-20 17:16:46.181885	0.19	1.59	0	1	a-win	yes
3289	1378996	2025-08-30	England	Premier League	Sunderland	Brentford	h-win	2	1	12	3	7	4	3	4	0	3	3	2	0	0	54.00	46.00	11	12	\N	\N	\N	4	12	2025-11-20 17:16:46.37845	1.54	1.20	0	0	draw	yes
3290	1378992	2025-08-30	England	Premier League	Leeds	Newcastle	draw	0	0	10	1	8	2	5	5	1	0	1	1	0	0	43.00	57.00	10	15	\N	\N	\N	16	14	2025-11-20 17:16:46.582674	0.69	0.46	0	0	draw	yes
3454	1386066	2025-08-30	England	League Two	Tranmere	Notts County	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16	4	2025-11-20 17:17:10.785636	\N	\N	1	0	h-win	yes
3291	1378990	2025-08-31	England	Premier League	Brighton	Manchester City	h-win	2	1	12	7	12	3	3	2	1	0	2	2	0	0	37.00	63.00	16	14	\N	\N	\N	11	2	2025-11-20 17:16:46.784767	2.29	1.84	0	1	a-win	yes
3292	1378995	2025-08-31	England	Premier League	Nottingham Forest	West Ham	a-win	0	3	11	3	12	8	9	7	0	0	0	0	0	0	58.00	42.00	14	6	\N	\N	\N	19	18	2025-11-20 17:16:46.981406	0.73	2.42	0	0	draw	yes
3293	1378993	2025-08-31	England	Premier League	Liverpool	Arsenal	h-win	1	0	9	3	11	1	3	8	1	0	2	2	0	0	53.00	47.00	7	10	\N	\N	\N	8	1	2025-11-20 17:16:47.168833	0.52	0.49	0	0	draw	yes
3294	1378989	2025-08-31	England	Premier League	Aston Villa	Crystal Palace	a-win	0	3	13	4	6	4	10	1	0	2	2	3	0	0	58.00	42.00	7	14	\N	\N	\N	6	10	2025-11-20 17:16:47.357579	1.14	2.65	0	1	a-win	yes
3295	1378999	2025-09-13	England	Premier League	Arsenal	Nottingham Forest	h-win	3	0	16	5	5	1	8	3	2	0	1	1	0	0	54.00	46.00	8	11	\N	\N	\N	1	19	2025-11-20 17:16:47.54549	1.84	0.20	1	0	h-win	yes
3296	1379007	2025-09-13	England	Premier League	Newcastle	Wolves	h-win	1	0	16	4	8	3	9	4	1	0	1	4	0	0	57.00	43.00	10	17	\N	\N	\N	14	20	2025-11-20 17:16:47.728555	1.55	0.50	1	0	h-win	yes
3297	1379000	2025-09-13	England	Premier League	Bournemouth	Brighton	h-win	2	1	13	5	6	2	4	4	1	0	4	4	0	0	51.00	49.00	16	10	\N	\N	\N	9	11	2025-11-20 17:16:47.922294	1.45	0.62	1	0	h-win	yes
3298	1379005	2025-09-13	England	Premier League	Fulham	Leeds	h-win	1	0	5	3	10	3	3	3	1	3	1	2	0	0	54.00	46.00	20	15	\N	\N	\N	15	16	2025-11-20 17:16:48.106055	0.85	0.79	0	0	draw	yes
3299	1379004	2025-09-13	England	Premier League	Everton	Aston Villa	draw	0	0	20	2	7	1	10	3	2	2	3	3	0	0	48.00	52.00	17	15	\N	\N	\N	13	6	2025-11-20 17:16:48.299308	2.08	0.54	0	0	draw	yes
3300	1379003	2025-09-13	England	Premier League	Crystal Palace	Sunderland	draw	0	0	14	6	6	0	5	3	0	2	1	1	0	0	56.00	44.00	10	8	\N	\N	\N	10	4	2025-11-20 17:16:48.500133	1.77	0.36	0	0	draw	yes
3301	1379008	2025-09-13	England	Premier League	West Ham	Tottenham	a-win	0	3	7	4	14	5	2	13	0	4	0	1	1	0	36.00	64.00	8	7	\N	\N	\N	18	5	2025-11-20 17:16:48.675913	0.60	1.29	0	0	draw	yes
3302	1379001	2025-09-13	England	Premier League	Brentford	Chelsea	draw	2	2	7	4	16	6	5	6	0	4	3	2	0	0	34.00	66.00	13	9	\N	\N	\N	12	3	2025-11-20 17:16:48.863251	1.43	1.25	1	0	h-win	yes
3303	1379002	2025-09-14	England	Premier League	Burnley	Liverpool	a-win	0	1	3	0	27	4	1	13	3	1	2	2	1	0	19.00	81.00	9	9	\N	\N	\N	17	8	2025-11-20 17:16:49.039813	0.13	2.65	0	0	draw	yes
3304	1379006	2025-09-14	England	Premier League	Manchester City	Manchester United	h-win	3	0	13	6	12	2	2	4	2	3	0	0	0	0	45.00	55.00	8	8	\N	\N	\N	2	7	2025-11-20 17:16:49.208047	2.63	1.52	1	0	h-win	yes
3305	1379014	2025-09-20	England	Premier League	Liverpool	Everton	h-win	2	1	11	3	9	2	5	4	1	1	2	3	0	0	57.00	43.00	11	10	\N	\N	\N	8	13	2025-11-20 17:16:49.396467	0.90	0.70	2	0	h-win	yes
3306	1379018	2025-09-20	England	Premier League	Wolves	Leeds	a-win	1	3	16	6	6	4	4	0	0	2	1	1	0	0	56.00	44.00	11	9	\N	\N	\N	20	16	2025-11-20 17:16:49.576621	1.78	0.48	1	3	a-win	yes
3307	1379012	2025-09-20	England	Premier League	Burnley	Nottingham Forest	draw	1	1	12	5	17	8	4	5	1	2	1	1	0	0	37.00	63.00	12	11	\N	\N	\N	17	19	2025-11-20 17:16:49.764643	0.85	1.10	1	1	draw	yes
3308	1379017	2025-09-20	England	Premier League	West Ham	Crystal Palace	a-win	1	2	8	3	18	3	8	8	1	2	3	3	0	0	57.00	43.00	15	5	\N	\N	\N	18	10	2025-11-20 17:16:49.957737	0.66	2.31	0	1	a-win	yes
3309	1379011	2025-09-20	England	Premier League	Brighton	Tottenham	draw	2	2	12	4	11	3	2	10	0	1	1	2	0	0	36.00	64.00	10	13	\N	\N	\N	11	5	2025-11-20 17:16:50.14118	1.32	1.22	2	1	h-win	yes
3310	1379015	2025-09-20	England	Premier League	Manchester United	Chelsea	h-win	2	1	11	4	5	1	5	5	3	2	2	5	1	1	41.00	59.00	13	14	\N	\N	\N	7	3	2025-11-20 17:16:50.340376	1.84	0.43	2	0	h-win	yes
3311	1379013	2025-09-20	England	Premier League	Fulham	Brentford	h-win	3	1	14	3	8	3	2	10	2	2	4	1	0	0	53.00	47.00	11	13	\N	\N	\N	15	12	2025-11-20 17:16:50.525022	1.01	0.60	2	1	h-win	yes
3312	1379010	2025-09-21	England	Premier League	Bournemouth	Newcastle	draw	0	0	11	2	4	1	5	2	3	2	2	1	0	0	56.00	44.00	7	10	\N	\N	\N	9	14	2025-11-20 17:16:50.71791	0.46	0.14	0	0	draw	yes
3313	1379016	2025-09-21	England	Premier League	Sunderland	Aston Villa	draw	1	1	14	4	12	2	6	5	0	3	2	1	1	0	29.00	71.00	14	8	\N	\N	\N	4	6	2025-11-20 17:16:50.906316	1.04	0.78	0	0	draw	yes
3314	1379009	2025-09-21	England	Premier League	Arsenal	Manchester City	draw	1	1	12	3	5	3	11	1	4	2	1	2	0	0	67.00	33.00	11	10	\N	\N	\N	1	2	2025-11-20 17:16:51.099584	0.89	0.87	0	1	a-win	yes
3315	1379020	2025-09-27	England	Premier League	Brentford	Manchester United	h-win	3	1	10	8	14	6	4	2	2	1	2	2	0	0	44.00	56.00	14	10	\N	\N	\N	12	7	2025-11-20 17:16:51.286505	1.99	2.03	2	1	h-win	yes
3316	1379021	2025-09-27	England	Premier League	Chelsea	Brighton	a-win	1	3	13	3	12	3	5	7	2	2	3	5	1	0	60.00	40.00	9	16	\N	\N	\N	3	11	2025-11-20 17:16:51.468987	1.81	2.28	1	0	h-win	yes
3317	1379025	2025-09-27	England	Premier League	Manchester City	Burnley	h-win	5	1	21	8	9	2	10	2	1	1	1	3	0	0	69.00	31.00	5	7	\N	\N	\N	2	17	2025-11-20 17:16:51.68119	2.03	0.41	1	1	draw	yes
3318	1379022	2025-09-27	England	Premier League	Crystal Palace	Liverpool	h-win	2	1	16	7	20	4	2	6	2	1	1	3	0	0	28.00	72.00	10	8	\N	\N	\N	10	8	2025-11-20 17:16:51.863111	2.92	2.14	1	0	h-win	yes
3319	1379024	2025-09-27	England	Premier League	Leeds	Bournemouth	draw	2	2	19	8	12	5	7	4	0	2	2	2	0	0	41.00	59.00	12	13	\N	\N	\N	16	9	2025-11-20 17:16:52.030645	1.84	0.82	1	1	draw	yes
3320	1379027	2025-09-27	England	Premier League	Nottingham Forest	Sunderland	a-win	0	1	22	6	11	3	7	4	0	1	4	2	0	0	65.00	35.00	11	6	\N	\N	\N	19	4	2025-11-20 17:16:52.220043	1.65	1.19	0	1	a-win	yes
3321	1379028	2025-09-27	England	Premier League	Tottenham	Wolves	draw	1	1	10	3	9	3	10	9	2	0	3	2	0	0	51.00	49.00	9	11	\N	\N	\N	5	20	2025-11-20 17:16:52.418392	0.87	1.15	0	0	draw	yes
3322	1379019	2025-09-28	England	Premier League	Aston Villa	Fulham	h-win	3	1	9	4	11	4	2	8	2	4	1	4	0	0	48.00	52.00	10	13	\N	\N	\N	6	15	2025-11-20 17:16:52.609192	1.11	0.92	1	1	draw	yes
3323	1379026	2025-09-28	England	Premier League	Newcastle	Arsenal	a-win	1	2	8	3	20	7	7	12	1	0	2	1	0	0	37.00	63.00	8	9	\N	\N	\N	14	1	2025-11-20 17:16:52.820433	0.61	2.04	1	0	h-win	yes
3324	1379023	2025-09-29	England	Premier League	Everton	West Ham	draw	1	1	12	6	14	3	3	5	0	2	3	4	0	0	52.00	48.00	7	16	\N	\N	\N	13	18	2025-11-20 17:16:53.026082	0.73	1.19	1	0	h-win	yes
3325	1379031	2025-10-03	England	Premier League	Bournemouth	Fulham	h-win	3	1	11	6	12	4	4	3	2	2	0	1	0	0	54.00	46.00	8	10	\N	\N	\N	9	15	2025-11-20 17:16:53.202716	1.12	0.88	0	0	draw	yes
3326	1379035	2025-10-04	England	Premier League	Leeds	Tottenham	a-win	1	2	16	4	9	3	4	1	1	2	2	3	0	0	57.00	43.00	10	12	\N	\N	\N	16	5	2025-11-20 17:16:53.371781	1.68	0.53	1	1	draw	yes
3327	1379036	2025-10-04	England	Premier League	Manchester United	Sunderland	h-win	2	0	15	6	8	3	2	3	1	2	1	4	0	0	51.00	49.00	10	12	\N	\N	\N	7	4	2025-11-20 17:16:53.567048	1.88	0.71	2	0	h-win	yes
3328	1379029	2025-10-04	England	Premier League	Arsenal	West Ham	h-win	2	0	21	5	4	0	8	3	1	1	0	2	0	0	68.00	32.00	14	14	\N	\N	\N	1	18	2025-11-20 17:16:53.748335	2.77	0.49	1	0	h-win	yes
3329	1379033	2025-10-04	England	Premier League	Chelsea	Liverpool	h-win	2	1	12	6	12	2	7	2	2	2	0	2	0	0	53.00	47.00	9	8	\N	\N	\N	3	8	2025-11-20 17:16:53.933227	1.00	1.95	1	0	h-win	yes
3330	1379037	2025-10-05	England	Premier League	Newcastle	Nottingham Forest	h-win	2	0	18	9	5	4	8	1	0	2	0	4	0	0	52.00	48.00	16	15	\N	\N	\N	14	19	2025-11-20 17:16:54.129713	3.28	0.29	0	0	draw	yes
3331	1379038	2025-10-05	England	Premier League	Wolves	Brighton	draw	1	1	6	3	17	6	2	8	1	3	2	4	0	0	42.00	58.00	13	9	\N	\N	\N	20	11	2025-11-20 17:16:54.296987	0.56	0.92	1	0	h-win	yes
3332	1379034	2025-10-05	England	Premier League	Everton	Crystal Palace	h-win	2	1	14	7	15	8	2	4	0	1	2	3	0	0	50.00	50.00	13	16	\N	\N	\N	13	10	2025-11-20 17:16:54.46591	2.03	1.53	0	1	a-win	yes
3333	1379030	2025-10-05	England	Premier League	Aston Villa	Burnley	h-win	2	1	15	7	5	2	6	4	3	5	3	1	0	0	55.00	45.00	9	15	\N	\N	\N	6	17	2025-11-20 17:16:54.64512	1.16	0.40	1	0	h-win	yes
3334	1379032	2025-10-05	England	Premier League	Brentford	Manchester City	a-win	0	1	6	1	10	4	3	2	1	1	3	2	0	0	30.00	70.00	10	6	\N	\N	\N	12	2	2025-11-20 17:16:54.823268	0.70	0.85	0	1	a-win	yes
3335	1379045	2025-10-18	England	Premier League	Nottingham Forest	Chelsea	a-win	0	3	12	2	17	6	5	2	1	2	2	4	0	1	50.00	50.00	12	17	\N	\N	\N	19	3	2025-11-20 17:16:55.00185	2.35	1.67	0	0	draw	yes
3336	1379040	2025-10-18	England	Premier League	Burnley	Leeds	h-win	2	0	4	3	19	4	1	5	1	0	2	1	0	0	31.00	69.00	10	7	\N	\N	\N	17	16	2025-11-20 17:16:55.200921	0.45	2.63	1	0	h-win	yes
3337	1379044	2025-10-18	England	Premier League	Manchester City	Everton	h-win	2	0	19	7	5	1	11	3	0	1	0	2	0	0	71.00	29.00	8	14	\N	\N	\N	2	13	2025-11-20 17:16:55.37934	2.38	0.81	0	0	draw	yes
3338	1379039	2025-10-18	England	Premier League	Brighton	Newcastle	h-win	2	1	13	5	16	3	8	4	3	1	0	1	0	0	46.00	54.00	13	16	\N	\N	\N	11	14	2025-11-20 17:16:55.578356	0.91	1.45	1	0	h-win	yes
3339	1379041	2025-10-18	England	Premier League	Crystal Palace	Bournemouth	draw	3	3	20	7	8	5	6	5	3	3	1	4	0	0	52.00	48.00	8	16	\N	\N	\N	10	9	2025-11-20 17:16:55.754422	4.44	2.03	0	2	a-win	yes
3340	1379046	2025-10-18	England	Premier League	Sunderland	Wolves	h-win	2	0	8	2	16	3	2	2	2	2	0	0	0	0	41.00	59.00	5	12	\N	\N	\N	4	20	2025-11-20 17:16:55.940704	0.65	0.83	1	0	h-win	yes
3341	1379042	2025-10-18	England	Premier League	Fulham	Arsenal	a-win	0	1	9	0	16	5	6	10	0	2	0	0	0	0	37.00	63.00	11	4	\N	\N	\N	15	1	2025-11-20 17:16:56.130503	0.44	1.87	0	0	draw	yes
3342	1379047	2025-10-19	England	Premier League	Tottenham	Aston Villa	a-win	1	2	9	3	8	2	6	6	6	1	2	0	0	0	53.00	47.00	11	7	\N	\N	\N	5	6	2025-11-20 17:16:56.317892	0.75	0.32	1	1	draw	yes
3343	1379043	2025-10-19	England	Premier League	Liverpool	Manchester United	a-win	1	2	19	6	12	4	9	4	1	1	0	2	0	0	64.00	36.00	19	12	\N	\N	\N	8	7	2025-11-20 17:16:56.498351	2.75	1.34	0	1	a-win	yes
3344	1379048	2025-10-20	England	Premier League	West Ham	Brentford	a-win	0	2	7	1	22	7	6	10	3	2	1	1	0	0	43.00	57.00	10	10	\N	\N	\N	18	12	2025-11-20 17:16:56.686686	0.33	2.31	0	1	a-win	yes
3345	1379055	2025-10-24	England	Premier League	Leeds	West Ham	h-win	2	1	13	5	9	3	3	4	1	1	3	3	0	0	41.00	59.00	12	11	\N	\N	\N	16	18	2025-11-20 17:16:56.868736	1.49	0.65	2	0	h-win	yes
3346	1379057	2025-10-25	England	Premier League	Newcastle	Fulham	h-win	2	1	18	7	12	5	4	3	0	1	0	2	0	0	51.00	49.00	11	18	\N	\N	\N	14	15	2025-11-20 17:16:57.048221	2.14	1.53	1	0	h-win	yes
3347	1379053	2025-10-25	England	Premier League	Chelsea	Sunderland	a-win	1	2	16	7	10	4	9	1	3	2	1	1	0	0	68.00	32.00	15	13	\N	\N	\N	3	4	2025-11-20 17:16:57.211639	0.90	1.31	1	1	draw	yes
3348	1379056	2025-10-25	England	Premier League	Manchester United	Brighton	h-win	4	2	13	9	17	5	1	6	2	2	2	2	0	0	44.00	56.00	4	13	\N	\N	\N	7	11	2025-11-20 17:16:57.395156	1.29	1.12	2	0	h-win	yes
3349	1379052	2025-10-25	England	Premier League	Brentford	Liverpool	h-win	3	2	17	8	18	5	5	4	2	0	3	2	0	0	34.00	66.00	7	10	\N	\N	\N	12	8	2025-11-20 17:16:57.572963	2.75	2.30	2	1	h-win	yes
3350	1379051	2025-10-26	England	Premier League	Bournemouth	Nottingham Forest	h-win	2	0	13	5	8	4	6	4	3	0	3	1	0	0	52.00	48.00	17	7	\N	\N	\N	9	19	2025-11-20 17:16:57.763481	0.59	0.35	2	0	h-win	yes
3351	1379058	2025-10-26	England	Premier League	Wolves	Burnley	a-win	2	3	15	7	11	7	4	3	2	2	1	0	0	0	57.00	43.00	12	7	\N	\N	\N	20	17	2025-11-20 17:16:57.931266	2.28	1.43	2	2	draw	yes
3352	1379049	2025-10-26	England	Premier League	Arsenal	Crystal Palace	h-win	1	0	10	3	7	1	4	3	2	1	0	0	0	0	60.00	40.00	6	11	\N	\N	\N	1	10	2025-11-20 17:16:58.136078	0.92	0.45	1	0	h-win	yes
3353	1379050	2025-10-26	England	Premier League	Aston Villa	Manchester City	h-win	1	0	9	3	18	4	5	6	1	3	1	4	0	0	47.00	53.00	8	16	\N	\N	\N	6	2	2025-11-20 17:16:58.32594	0.81	1.18	1	0	h-win	yes
3354	1379054	2025-10-26	England	Premier League	Everton	Tottenham	a-win	0	3	12	2	7	4	9	8	2	2	2	0	0	0	53.00	47.00	9	8	\N	\N	\N	13	5	2025-11-20 17:16:58.495416	1.53	2.08	0	2	a-win	yes
3355	1379062	2025-11-01	England	Premier League	Fulham	Wolves	h-win	3	0	19	6	5	2	10	1	3	0	1	3	0	1	63.00	37.00	13	14	\N	\N	\N	15	20	2025-11-20 17:16:58.663057	1.39	0.24	1	0	h-win	yes
3356	1379060	2025-11-01	England	Premier League	Burnley	Arsenal	a-win	0	2	3	0	12	8	1	6	0	1	2	1	0	0	46.00	54.00	10	13	\N	\N	\N	17	1	2025-11-20 17:16:58.827619	0.42	2.42	0	2	a-win	yes
3357	1379059	2025-11-01	England	Premier League	Brighton	Leeds	h-win	3	0	14	7	5	2	4	7	3	1	0	1	0	0	50.00	50.00	10	7	\N	\N	\N	11	16	2025-11-20 17:16:59.0044	3.07	0.50	1	0	h-win	yes
3358	1379061	2025-11-01	England	Premier League	Crystal Palace	Brentford	h-win	2	0	10	3	6	2	6	5	1	3	0	3	0	0	36.00	64.00	7	11	\N	\N	\N	10	12	2025-11-20 17:16:59.191202	0.70	0.54	1	0	h-win	yes
3359	1379065	2025-11-01	England	Premier League	Nottingham Forest	Manchester United	draw	2	2	17	3	18	7	8	5	2	1	1	1	0	0	41.00	59.00	17	0	\N	\N	\N	19	7	2025-11-20 17:16:59.378835	1.93	1.12	0	1	a-win	yes
3360	1379067	2025-11-01	England	Premier League	Tottenham	Chelsea	a-win	0	1	3	1	15	9	6	5	1	1	4	2	0	0	48.00	52.00	14	12	\N	\N	\N	5	3	2025-11-20 17:16:59.58428	0.10	3.68	0	1	a-win	yes
3361	1379063	2025-11-01	England	Premier League	Liverpool	Aston Villa	h-win	2	0	16	4	10	3	1	4	8	0	2	3	0	0	53.00	47.00	13	11	\N	\N	\N	8	6	2025-11-20 17:16:59.736103	1.19	0.41	1	0	h-win	yes
3362	1379068	2025-11-02	England	Premier League	West Ham	Newcastle	h-win	3	1	15	9	12	4	7	6	4	0	1	2	0	0	37.00	63.00	5	10	\N	\N	\N	18	14	2025-11-20 17:16:59.927461	1.75	0.52	2	1	h-win	yes
3363	1379064	2025-11-02	England	Premier League	Manchester City	Bournemouth	h-win	3	1	15	8	8	5	9	4	0	3	2	2	0	0	48.00	52.00	8	11	\N	\N	\N	2	9	2025-11-20 17:17:00.087294	2.22	0.72	2	1	h-win	yes
3364	1379066	2025-11-03	England	Premier League	Sunderland	Everton	draw	1	1	17	3	8	2	4	1	2	0	3	2	0	0	61.00	39.00	10	12	\N	\N	\N	4	13	2025-11-20 17:17:00.238816	1.22	0.89	0	1	a-win	yes
3365	1379077	2025-11-08	England	Premier League	Tottenham	Manchester United	draw	2	2	10	4	5	2	5	3	2	3	5	1	0	0	55.00	45.00	10	8	\N	\N	\N	5	7	2025-11-20 17:17:00.403808	0.92	0.63	0	1	a-win	yes
3366	1379073	2025-11-08	England	Premier League	Everton	Fulham	h-win	2	0	14	5	8	4	7	5	5	1	2	2	0	0	50.00	50.00	11	14	\N	\N	\N	13	15	2025-11-20 17:17:00.579617	1.44	0.40	1	0	h-win	yes
3367	1379078	2025-11-08	England	Premier League	West Ham	Burnley	h-win	3	2	15	6	16	7	7	4	2	1	2	2	0	0	43.00	57.00	15	13	\N	\N	\N	18	17	2025-11-20 17:17:00.781637	3.02	1.06	1	1	draw	yes
3368	1379076	2025-11-08	England	Premier League	Sunderland	Arsenal	draw	2	2	6	2	17	7	2	2	2	0	2	1	0	0	35.00	65.00	13	13	\N	\N	\N	4	1	2025-11-20 17:17:00.977199	0.44	1.91	1	0	h-win	yes
3369	1379071	2025-11-08	England	Premier League	Chelsea	Wolves	h-win	3	0	20	8	3	0	10	1	0	0	1	2	0	0	64.00	36.00	12	14	\N	\N	\N	3	20	2025-11-20 17:17:01.155398	3.31	0.17	0	0	draw	yes
3370	1379072	2025-11-09	England	Premier League	Crystal Palace	Brighton	draw	0	0	10	2	7	3	4	8	2	1	1	4	0	0	42.00	58.00	10	12	\N	\N	\N	10	11	2025-11-20 17:17:01.342671	0.75	0.39	0	0	draw	yes
3371	1379070	2025-11-09	England	Premier League	Brentford	Newcastle	h-win	3	1	15	7	5	1	6	2	2	0	2	3	0	1	49.00	51.00	23	0	\N	\N	\N	12	14	2025-11-20 17:17:01.539193	2.35	0.44	0	1	a-win	yes
3372	1379075	2025-11-09	England	Premier League	Nottingham Forest	Leeds	h-win	3	1	14	6	10	3	6	4	2	1	2	1	0	0	46.00	54.00	10	11	\N	\N	\N	19	16	2025-11-20 17:17:01.736232	2.55	0.69	1	1	draw	yes
3373	1379069	2025-11-09	England	Premier League	Aston Villa	Bournemouth	h-win	4	0	16	8	12	3	6	9	0	2	2	2	0	0	52.00	48.00	8	20	\N	\N	\N	6	9	2025-11-20 17:17:01.912846	1.70	1.61	2	0	h-win	yes
3374	1379074	2025-11-09	England	Premier League	Manchester City	Liverpool	h-win	3	0	14	6	7	1	7	7	1	7	2	4	0	0	49.00	51.00	14	15	\N	\N	\N	2	8	2025-11-20 17:17:02.094781	1.51	0.61	2	0	h-win	yes
3375	1379082	2025-11-22	England	Premier League	Burnley	Chelsea	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6.40	4.30	1.49	\N	\N	2025-11-20 17:17:02.312806	\N	\N	0	0	draw	no
3376	1379080	2025-11-22	England	Premier League	Bournemouth	West Ham	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.59	4.00	5.50	\N	\N	2025-11-20 17:17:02.503498	\N	\N	0	0	draw	no
3377	1379083	2025-11-22	England	Premier League	Fulham	Sunderland	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2.10	3.20	3.65	\N	\N	2025-11-20 17:17:02.689048	\N	\N	0	0	draw	no
3378	1379088	2025-11-22	England	Premier League	Wolves	Crystal Palace	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3.95	3.45	1.94	\N	\N	2025-11-20 17:17:02.91259	\N	\N	0	0	draw	no
3379	1379085	2025-11-22	England	Premier League	Liverpool	Nottingham Forest	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.42	4.65	7.10	\N	\N	2025-11-20 17:17:03.120438	\N	\N	0	0	draw	no
3380	1379081	2025-11-22	England	Premier League	Brighton	Brentford	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.92	3.55	3.85	\N	\N	2025-11-20 17:17:03.316408	\N	\N	0	0	draw	no
3381	1379087	2025-11-22	England	Premier League	Newcastle	Manchester City	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3.50	3.70	1.97	\N	\N	2025-11-20 17:17:03.509593	\N	\N	0	0	draw	no
3382	1379084	2025-11-23	England	Premier League	Leeds	Aston Villa	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3.05	3.15	2.35	\N	\N	2025-11-20 17:17:03.683853	\N	\N	0	0	draw	no
3383	1379079	2025-11-23	England	Premier League	Arsenal	Tottenham	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.38	4.65	7.60	\N	\N	2025-11-20 17:17:03.871135	\N	\N	0	0	draw	no
3384	1379086	2025-11-24	England	Premier League	Manchester United	Everton	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.74	3.65	4.55	\N	\N	2025-11-20 17:17:04.061324	\N	\N	0	0	draw	no
3385	1385998	2025-08-02	England	League Two	Bristol Rovers	Harrogate Town	a-win	0	1	18	2	6	2	13	4	0	4	1	3	0	0	59.00	41.00	10	11	\N	\N	\N	19	22	2025-11-20 17:17:05.540396	\N	\N	0	0	draw	yes
3386	1386006	2025-08-02	England	League Two	Walsall	Swindon Town	h-win	2	1	6	4	16	5	1	5	1	2	2	1	1	0	27.00	73.00	13	18	\N	\N	\N	2	1	2025-11-20 17:17:05.720497	\N	\N	1	0	h-win	yes
3387	1386000	2025-08-02	England	League Two	Chesterfield	Barrow	h-win	1	0	7	3	10	1	4	3	2	0	1	1	0	0	63.00	37.00	9	9	\N	\N	\N	6	17	2025-11-20 17:17:05.903859	\N	\N	1	0	h-win	yes
3388	1386003	2025-08-02	England	League Two	Milton Keynes Dons	Oldham	draw	0	0	5	0	5	1	7	3	2	0	1	3	0	0	63.00	37.00	17	16	\N	\N	\N	3	15	2025-11-20 17:17:06.099929	\N	\N	0	0	draw	yes
3389	1386005	2025-08-02	England	League Two	Shrewsbury	Bromley	draw	0	0	6	2	17	2	4	5	2	1	3	1	0	0	59.00	41.00	13	14	\N	\N	\N	21	5	2025-11-20 17:17:06.293634	\N	\N	0	0	draw	yes
3390	1385996	2025-08-02	England	League Two	Accrington ST	Gillingham	draw	1	1	10	3	8	0	3	3	2	1	2	2	0	0	55.00	45.00	12	15	\N	\N	\N	18	7	2025-11-20 17:17:06.485612	\N	\N	0	0	draw	yes
3391	1386001	2025-08-02	England	League Two	Colchester	Tranmere	draw	1	1	10	2	10	2	4	5	0	1	2	2	0	0	66.00	34.00	10	17	\N	\N	\N	14	16	2025-11-20 17:17:06.682992	\N	\N	0	1	a-win	yes
3392	1386002	2025-08-02	England	League Two	Grimsby	Crawley Town	h-win	3	0	20	6	5	1	10	3	5	3	0	2	0	0	48.00	52.00	13	14	\N	\N	\N	10	20	2025-11-20 17:17:06.880572	\N	\N	2	0	h-win	yes
3393	1385997	2025-08-02	England	League Two	Barnet	Fleetwood Town	a-win	0	2	19	6	12	7	8	2	4	2	0	0	0	0	67.00	33.00	11	15	\N	\N	\N	11	13	2025-11-20 17:17:07.059589	\N	\N	0	1	a-win	yes
3394	1385999	2025-08-02	England	League Two	Cambridge United	Cheltenham	h-win	1	0	13	4	7	2	4	2	0	2	0	2	0	0	51.00	49.00	11	22	\N	\N	\N	12	23	2025-11-20 17:17:07.259028	\N	\N	0	0	draw	yes
3395	1386004	2025-08-02	England	League Two	Salford City	Crewe	a-win	1	3	11	5	22	10	7	10	2	2	4	2	0	0	51.00	49.00	15	17	\N	\N	\N	9	8	2025-11-20 17:17:07.441708	\N	\N	1	3	a-win	yes
3396	1386007	2025-08-02	England	League Two	Newport County	Notts County	draw	1	1	6	1	13	5	2	6	0	1	1	1	0	0	31.00	69.00	18	11	\N	\N	\N	24	4	2025-11-20 17:17:07.634045	\N	\N	0	0	draw	yes
3397	1386015	2025-08-09	England	League Two	Notts County	Salford City	a-win	1	2	9	3	11	5	1	7	0	1	3	3	0	0	58.00	42.00	11	18	\N	\N	\N	4	9	2025-11-20 17:17:07.804381	\N	\N	0	1	a-win	yes
3398	1386018	2025-08-09	England	League Two	Tranmere	Shrewsbury	h-win	4	0	10	6	12	3	2	5	3	1	1	3	0	1	58.00	42.00	13	11	\N	\N	\N	16	21	2025-11-20 17:17:07.993365	\N	\N	2	0	h-win	yes
3399	1386012	2025-08-09	England	League Two	Fleetwood Town	Bristol Rovers	h-win	2	1	7	3	14	2	1	6	2	3	1	3	0	0	39.00	61.00	15	16	\N	\N	\N	13	19	2025-11-20 17:17:08.174572	\N	\N	2	0	h-win	yes
3400	1386013	2025-08-09	England	League Two	Gillingham	Walsall	h-win	1	0	8	2	6	2	5	2	0	0	3	3	0	0	56.00	44.00	14	17	\N	\N	\N	7	2	2025-11-20 17:17:08.372413	\N	\N	0	0	draw	yes
3401	1386016	2025-08-09	England	League Two	Oldham	Colchester	draw	1	1	21	7	8	3	8	7	1	2	1	1	0	0	50.00	50.00	19	13	\N	\N	\N	15	14	2025-11-20 17:17:08.554491	\N	\N	1	1	draw	yes
3402	1386017	2025-08-09	England	League Two	Swindon Town	Cambridge United	h-win	3	2	9	5	10	4	2	7	2	3	2	1	0	0	40.00	60.00	11	10	\N	\N	\N	1	12	2025-11-20 17:17:08.728703	\N	\N	2	1	h-win	yes
3403	1386019	2025-08-09	England	League Two	Crawley Town	Newport County	a-win	1	2	18	6	8	3	6	3	0	2	1	2	0	0	61.00	39.00	11	18	\N	\N	\N	20	24	2025-11-20 17:17:08.916082	\N	\N	0	0	draw	yes
3404	1386011	2025-08-09	England	League Two	Crewe	Accrington ST	h-win	2	0	15	4	9	3	8	2	0	2	1	2	0	0	56.00	44.00	13	19	\N	\N	\N	8	18	2025-11-20 17:17:09.100326	\N	\N	2	0	h-win	yes
3405	1386010	2025-08-09	England	League Two	Cheltenham	Chesterfield	a-win	0	2	6	2	16	8	2	5	2	2	7	1	0	0	44.00	56.00	19	16	\N	\N	\N	23	6	2025-11-20 17:17:09.29384	\N	\N	0	0	draw	yes
3406	1386008	2025-08-09	England	League Two	Barrow	Milton Keynes Dons	a-win	0	2	7	0	12	5	1	5	3	2	3	2	0	0	47.00	53.00	19	12	\N	\N	\N	17	3	2025-11-20 17:17:09.494809	\N	\N	0	0	draw	yes
3407	1386009	2025-08-09	England	League Two	Bromley	Barnet	h-win	2	0	9	3	10	2	6	6	1	2	3	1	0	0	37.00	63.00	15	12	\N	\N	\N	5	11	2025-11-20 17:17:09.671369	\N	\N	1	0	h-win	yes
3408	1386014	2025-08-09	England	League Two	Harrogate Town	Grimsby	draw	3	3	8	3	13	4	3	4	2	1	5	3	0	0	39.00	61.00	12	9	\N	\N	\N	22	10	2025-11-20 17:17:09.852872	\N	\N	0	0	draw	yes
3409	1386024	2025-08-16	England	League Two	Chesterfield	Bristol Rovers	h-win	3	1	20	10	7	3	4	4	5	2	3	3	0	1	70.00	30.00	9	11	\N	\N	\N	6	19	2025-11-20 17:17:10.060429	\N	\N	1	0	h-win	yes
3410	1386027	2025-08-16	England	League Two	Oldham	Swindon Town	a-win	1	2	13	5	13	3	4	2	5	1	0	3	0	0	54.00	46.00	9	11	\N	\N	\N	15	1	2025-11-20 17:17:10.244477	\N	\N	1	2	a-win	yes
3411	1386026	2025-08-16	England	League Two	Milton Keynes Dons	Cheltenham	h-win	5	0	16	8	9	2	3	1	4	1	1	4	0	0	53.00	47.00	10	13	\N	\N	\N	3	23	2025-11-20 17:17:10.42611	\N	\N	3	0	h-win	yes
3412	1386029	2025-08-16	England	League Two	Shrewsbury	Colchester	a-win	0	2	8	1	9	4	6	1	2	5	2	1	1	0	46.00	54.00	16	9	\N	\N	\N	21	14	2025-11-20 17:17:10.508841	\N	\N	0	0	draw	yes
3413	1386025	2025-08-16	England	League Two	Crewe	Crawley Town	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8	20	2025-11-20 17:17:10.515272	\N	\N	1	0	h-win	yes
3414	1386031	2025-08-16	England	League Two	Grimsby	Newport County	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	10	24	2025-11-20 17:17:10.521099	\N	\N	1	0	h-win	yes
3415	1386020	2025-08-16	England	League Two	Barnet	Walsall	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	11	2	2025-11-20 17:17:10.526992	\N	\N	1	2	a-win	yes
3416	1386023	2025-08-16	England	League Two	Cambridge United	Harrogate Town	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	22	2025-11-20 17:17:10.534897	\N	\N	1	0	h-win	yes
3417	1386030	2025-08-16	England	League Two	Tranmere	Gillingham	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16	7	2025-11-20 17:17:10.540726	\N	\N	0	0	draw	yes
3418	1386021	2025-08-16	England	League Two	Barrow	Notts County	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	17	4	2025-11-20 17:17:10.548653	\N	\N	1	0	h-win	yes
3419	1386022	2025-08-16	England	League Two	Bromley	Fleetwood Town	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	13	2025-11-20 17:17:10.554502	\N	\N	1	1	draw	yes
3420	1386028	2025-08-16	England	League Two	Salford City	Accrington ST	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	18	2025-11-20 17:17:10.562537	\N	\N	2	0	h-win	yes
3421	1386032	2025-08-19	England	League Two	Newport County	Salford City	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	24	9	2025-11-20 17:17:10.569248	\N	\N	0	0	draw	yes
3422	1386034	2025-08-19	England	League Two	Bristol Rovers	Oldham	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	19	15	2025-11-20 17:17:10.574805	\N	\N	0	0	draw	yes
3423	1386038	2025-08-19	England	League Two	Fleetwood Town	Crewe	a-win	1	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	13	8	2025-11-20 17:17:10.580371	\N	\N	0	2	a-win	yes
3424	1386039	2025-08-19	England	League Two	Gillingham	Chesterfield	h-win	4	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7	6	2025-11-20 17:17:10.588795	\N	\N	1	0	h-win	yes
3425	1386042	2025-08-19	England	League Two	Swindon Town	Barnet	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	11	2025-11-20 17:17:10.593929	\N	\N	0	0	draw	yes
3426	1386036	2025-08-19	England	League Two	Colchester	Cambridge United	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	14	12	2025-11-20 17:17:10.599246	\N	\N	1	2	a-win	yes
3427	1386037	2025-08-19	England	League Two	Crawley Town	Milton Keynes Dons	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	20	3	2025-11-20 17:17:10.605057	\N	\N	1	0	h-win	yes
3428	1386035	2025-08-19	England	League Two	Cheltenham	Bromley	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	23	5	2025-11-20 17:17:10.612648	\N	\N	0	1	a-win	yes
3429	1386040	2025-08-19	England	League Two	Harrogate Town	Barrow	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	22	17	2025-11-20 17:17:10.61808	\N	\N	1	0	h-win	yes
3430	1386043	2025-08-19	England	League Two	Walsall	Grimsby	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	10	2025-11-20 17:17:10.626121	\N	\N	0	0	draw	yes
3431	1386041	2025-08-20	England	League Two	Notts County	Shrewsbury	h-win	4	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	21	2025-11-20 17:17:10.631622	\N	\N	2	1	h-win	yes
3432	1386054	2025-08-23	England	League Two	Walsall	Salford City	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	9	2025-11-20 17:17:10.637462	\N	\N	1	0	h-win	yes
3433	1386055	2025-08-23	England	League Two	Newport County	Milton Keynes Dons	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	24	3	2025-11-20 17:17:10.646169	\N	\N	1	1	draw	yes
3434	1386045	2025-08-23	England	League Two	Bristol Rovers	Cambridge United	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	19	12	2025-11-20 17:17:10.652939	\N	\N	1	0	h-win	yes
3435	1386049	2025-08-23	England	League Two	Fleetwood Town	Oldham	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	13	15	2025-11-20 17:17:10.660604	\N	\N	1	1	draw	yes
3436	1386050	2025-08-23	England	League Two	Gillingham	Crewe	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7	8	2025-11-20 17:17:10.665829	\N	\N	0	0	draw	yes
3437	1386053	2025-08-23	England	League Two	Swindon Town	Shrewsbury	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	21	2025-11-20 17:17:10.671935	\N	\N	1	0	h-win	yes
3438	1386044	2025-08-23	England	League Two	Accrington ST	Grimsby	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	18	10	2025-11-20 17:17:10.677235	\N	\N	0	1	a-win	yes
3439	1386047	2025-08-23	England	League Two	Colchester	Barrow	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	14	17	2025-11-20 17:17:10.684549	\N	\N	0	1	a-win	yes
3440	1386048	2025-08-23	England	League Two	Crawley Town	Tranmere	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	20	16	2025-11-20 17:17:10.690619	\N	\N	0	0	draw	yes
3441	1386046	2025-08-23	England	League Two	Cheltenham	Barnet	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	23	11	2025-11-20 17:17:10.696281	\N	\N	0	0	draw	yes
3442	1386052	2025-08-23	England	League Two	Notts County	Bromley	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	5	2025-11-20 17:17:10.705063	\N	\N	2	1	h-win	yes
3443	1386051	2025-08-23	England	League Two	Harrogate Town	Chesterfield	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	22	6	2025-11-20 17:17:10.710928	\N	\N	0	1	a-win	yes
3444	1386064	2025-08-29	England	League Two	Salford City	Cheltenham	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	23	2025-11-20 17:17:10.720465	\N	\N	0	0	draw	yes
3445	1386060	2025-08-30	England	League Two	Crewe	Swindon Town	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8	1	2025-11-20 17:17:10.726388	\N	\N	0	3	a-win	yes
3446	1386057	2025-08-30	England	League Two	Barrow	Fleetwood Town	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	17	13	2025-11-20 17:17:10.734269	\N	\N	0	1	a-win	yes
3447	1386059	2025-08-30	England	League Two	Chesterfield	Crawley Town	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	20	2025-11-20 17:17:10.740212	\N	\N	0	2	a-win	yes
3448	1386062	2025-08-30	England	League Two	Milton Keynes Dons	Walsall	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	2	2025-11-20 17:17:10.748021	\N	\N	0	0	draw	yes
3449	1386063	2025-08-30	England	League Two	Oldham	Gillingham	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	15	7	2025-11-20 17:17:10.754229	\N	\N	0	0	draw	yes
3450	1386065	2025-08-30	England	League Two	Shrewsbury	Accrington ST	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	21	18	2025-11-20 17:17:10.759874	\N	\N	0	0	draw	yes
3451	1386061	2025-08-30	England	League Two	Grimsby	Bristol Rovers	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	10	19	2025-11-20 17:17:10.767014	\N	\N	0	1	a-win	yes
3452	1386056	2025-08-30	England	League Two	Barnet	Colchester	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	11	14	2025-11-20 17:17:10.772846	\N	\N	0	1	a-win	yes
3453	1386067	2025-08-30	England	League Two	Cambridge United	Newport County	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	24	2025-11-20 17:17:10.778382	\N	\N	1	0	h-win	yes
3455	1386058	2025-08-30	England	League Two	Bromley	Harrogate Town	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	22	2025-11-20 17:17:10.791384	\N	\N	0	0	draw	yes
3456	1386078	2025-09-06	England	League Two	Newport County	Bristol Rovers	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	24	19	2025-11-20 17:17:10.797193	\N	\N	0	0	draw	yes
3457	1386077	2025-09-06	England	League Two	Walsall	Chesterfield	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	6	2025-11-20 17:17:10.804932	\N	\N	1	0	h-win	yes
3458	1386074	2025-09-06	England	League Two	Milton Keynes Dons	Grimsby	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	10	2025-11-20 17:17:10.810554	\N	\N	0	3	a-win	yes
3459	1386072	2025-09-06	England	League Two	Colchester	Crewe	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	14	8	2025-11-20 17:17:10.818702	\N	\N	0	1	a-win	yes
3460	1386079	2025-09-06	England	League Two	Barnet	Shrewsbury	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	11	21	2025-11-20 17:17:10.824443	\N	\N	1	3	a-win	yes
3461	1386070	2025-09-06	England	League Two	Cambridge United	Oldham	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	15	2025-11-20 17:17:10.832069	\N	\N	0	1	a-win	yes
3462	1386071	2025-09-06	England	League Two	Cheltenham	Accrington ST	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	23	18	2025-11-20 17:17:10.838132	\N	\N	1	0	h-win	yes
3463	1386075	2025-09-06	England	League Two	Notts County	Fleetwood Town	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	13	2025-11-20 17:17:10.843847	\N	\N	0	0	draw	yes
3464	1386068	2025-09-06	England	League Two	Barrow	Swindon Town	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	17	1	2025-11-20 17:17:10.849378	\N	\N	0	2	a-win	yes
3465	1386073	2025-09-06	England	League Two	Harrogate Town	Crawley Town	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	22	20	2025-11-20 17:17:10.855141	\N	\N	0	1	a-win	yes
3466	1386076	2025-09-06	England	League Two	Salford City	Tranmere	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	16	2025-11-20 17:17:10.863325	\N	\N	0	0	draw	yes
3467	1386069	2025-09-06	England	League Two	Bromley	Gillingham	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	7	2025-11-20 17:17:10.86914	\N	\N	2	0	h-win	yes
3468	1386080	2025-09-13	England	League Two	Accrington ST	Colchester	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	18	14	2025-11-20 17:17:10.874873	\N	\N	1	0	h-win	yes
3469	1386083	2025-09-13	England	League Two	Crawley Town	Cheltenham	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	20	23	2025-11-20 17:17:10.880368	\N	\N	0	0	draw	yes
3470	1386081	2025-09-13	England	League Two	Bristol Rovers	Barrow	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	19	17	2025-11-20 17:17:10.888828	\N	\N	2	0	h-win	yes
3471	1386085	2025-09-13	England	League Two	Fleetwood Town	Walsall	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	13	2	2025-11-20 17:17:10.894444	\N	\N	1	1	draw	yes
3472	1386082	2025-09-13	England	League Two	Chesterfield	Milton Keynes Dons	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	3	2025-11-20 17:17:10.901342	\N	\N	0	1	a-win	yes
3473	1386086	2025-09-13	England	League Two	Gillingham	Notts County	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7	4	2025-11-20 17:17:10.907847	\N	\N	0	0	draw	yes
3474	1386088	2025-09-13	England	League Two	Oldham	Bromley	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	15	5	2025-11-20 17:17:10.913403	\N	\N	0	0	draw	yes
3475	1386089	2025-09-13	England	League Two	Shrewsbury	Salford City	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	21	9	2025-11-20 17:17:10.920891	\N	\N	0	1	a-win	yes
3476	1386090	2025-09-13	England	League Two	Swindon Town	Harrogate Town	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	22	2025-11-20 17:17:10.92647	\N	\N	1	1	draw	yes
3477	1386084	2025-09-13	England	League Two	Crewe	Barnet	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8	11	2025-11-20 17:17:10.934499	\N	\N	0	0	draw	yes
3478	1386087	2025-09-13	England	League Two	Grimsby	Cambridge United	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	10	12	2025-11-20 17:17:10.940535	\N	\N	0	1	a-win	yes
3479	1386091	2025-09-13	England	League Two	Tranmere	Newport County	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16	24	2025-11-20 17:17:10.948458	\N	\N	1	0	h-win	yes
3480	1386095	2025-09-20	England	League Two	Cambridge United	Fleetwood Town	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	13	2025-11-20 17:17:10.954814	\N	\N	0	0	draw	yes
3481	1386098	2025-09-20	England	League Two	Harrogate Town	Shrewsbury	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	22	21	2025-11-20 17:17:10.960428	\N	\N	0	0	draw	yes
3482	1386102	2025-09-20	England	League Two	Walsall	Tranmere	h-win	4	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	16	2025-11-20 17:17:10.967652	\N	\N	2	1	h-win	yes
3483	1386099	2025-09-20	England	League Two	Milton Keynes Dons	Accrington ST	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	18	2025-11-20 17:17:10.973827	\N	\N	0	1	a-win	yes
3484	1386097	2025-09-20	England	League Two	Colchester	Bristol Rovers	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	14	19	2025-11-20 17:17:10.979477	\N	\N	0	1	a-win	yes
3485	1386103	2025-09-20	England	League Two	Newport County	Gillingham	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	24	7	2025-11-20 17:17:10.98798	\N	\N	1	3	a-win	yes
3486	1386092	2025-09-20	England	League Two	Barnet	Grimsby	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	11	10	2025-11-20 17:17:10.993726	\N	\N	1	0	h-win	yes
3487	1386096	2025-09-20	England	League Two	Cheltenham	Oldham	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	23	15	2025-11-20 17:17:11.001616	\N	\N	0	1	a-win	yes
3488	1386100	2025-09-20	England	League Two	Notts County	Crawley Town	h-win	4	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	20	2025-11-20 17:17:11.007819	\N	\N	1	0	h-win	yes
3489	1386093	2025-09-20	England	League Two	Barrow	Crewe	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	17	8	2025-11-20 17:17:11.01341	\N	\N	0	0	draw	yes
3490	1386094	2025-09-20	England	League Two	Bromley	Chesterfield	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	6	2025-11-20 17:17:11.021618	\N	\N	1	1	draw	yes
3491	1386101	2025-09-20	England	League Two	Salford City	Swindon Town	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	1	2025-11-20 17:17:11.027245	\N	\N	2	0	h-win	yes
3492	1386111	2025-09-27	England	League Two	Oldham	Barnet	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	15	11	2025-11-20 17:17:11.035345	\N	\N	0	1	a-win	yes
3493	1386107	2025-09-27	England	League Two	Crewe	Notts County	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8	4	2025-11-20 17:17:11.041355	\N	\N	1	1	draw	yes
3494	1386105	2025-09-27	England	League Two	Bristol Rovers	Salford City	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	19	9	2025-11-20 17:17:11.048804	\N	\N	1	1	draw	yes
3495	1386108	2025-09-27	England	League Two	Fleetwood Town	Colchester	h-win	4	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	13	14	2025-11-20 17:17:11.05501	\N	\N	1	2	a-win	yes
3496	1386115	2025-09-27	England	League Two	Chesterfield	Newport County	h-win	4	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	24	2025-11-20 17:17:11.060653	\N	\N	2	0	h-win	yes
3497	1386109	2025-09-27	England	League Two	Gillingham	Harrogate Town	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7	22	2025-11-20 17:17:11.068232	\N	\N	0	1	a-win	yes
3498	1386112	2025-09-27	England	League Two	Shrewsbury	Milton Keynes Dons	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	21	3	2025-11-20 17:17:11.074204	\N	\N	0	2	a-win	yes
3499	1386113	2025-09-27	England	League Two	Swindon Town	Bromley	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	5	2025-11-20 17:17:11.0799	\N	\N	2	0	h-win	yes
3500	1386104	2025-09-27	England	League Two	Accrington ST	Walsall	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	18	2	2025-11-20 17:17:11.088524	\N	\N	0	0	draw	yes
3501	1386106	2025-09-27	England	League Two	Crawley Town	Barrow	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	20	17	2025-11-20 17:17:11.09426	\N	\N	0	2	a-win	yes
3502	1386110	2025-09-27	England	League Two	Grimsby	Cheltenham	h-win	7	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	10	23	2025-11-20 17:17:11.099698	\N	\N	2	1	h-win	yes
3503	1386114	2025-09-27	England	League Two	Tranmere	Cambridge United	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16	12	2025-11-20 17:17:11.105739	\N	\N	0	0	draw	yes
3504	1386123	2025-10-04	England	League Two	Milton Keynes Dons	Gillingham	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	7	2025-11-20 17:17:11.113819	\N	\N	1	0	h-win	yes
3505	1386127	2025-10-04	England	League Two	Newport County	Swindon Town	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	24	1	2025-11-20 17:17:11.11989	\N	\N	0	1	a-win	yes
3506	1386126	2025-10-04	England	League Two	Walsall	Bristol Rovers	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	19	2025-11-20 17:17:11.126906	\N	\N	0	1	a-win	yes
3507	1386121	2025-10-04	England	League Two	Colchester	Chesterfield	h-win	6	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	14	6	2025-11-20 17:17:11.132728	\N	\N	4	1	h-win	yes
3508	1386116	2025-10-04	England	League Two	Barnet	Accrington ST	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	11	18	2025-11-20 17:17:11.138953	\N	\N	1	0	h-win	yes
3509	1386119	2025-10-04	England	League Two	Cambridge United	Crawley Town	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	20	2025-11-20 17:17:11.146599	\N	\N	1	0	h-win	yes
4570	1481712	2025-11-01	England	FA Cup	Buxton	Chatham Town	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.951355	\N	\N	0	0	draw	yes
3510	1386120	2025-10-04	England	League Two	Cheltenham	Fleetwood Town	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	23	13	2025-11-20 17:17:11.152412	\N	\N	0	0	draw	yes
3511	1386124	2025-10-04	England	League Two	Notts County	Oldham	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	15	2025-11-20 17:17:11.160607	\N	\N	2	0	h-win	yes
3512	1386117	2025-10-04	England	League Two	Barrow	Shrewsbury	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	17	21	2025-11-20 17:17:11.166127	\N	\N	0	0	draw	yes
3513	1386118	2025-10-04	England	League Two	Bromley	Tranmere	draw	3	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	16	2025-11-20 17:17:11.172203	\N	\N	2	1	h-win	yes
3514	1386125	2025-10-04	England	League Two	Salford City	Grimsby	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	10	2025-11-20 17:17:11.177676	\N	\N	0	2	a-win	yes
3515	1386122	2025-10-06	England	League Two	Harrogate Town	Crewe	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	22	8	2025-11-20 17:17:11.18327	\N	\N	1	1	draw	yes
3516	1386128	2025-10-11	England	League Two	Bristol Rovers	Milton Keynes Dons	a-win	0	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	19	3	2025-11-20 17:17:11.190636	\N	\N	0	1	a-win	yes
3517	1386132	2025-10-11	England	League Two	Fleetwood Town	Harrogate Town	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	13	22	2025-11-20 17:17:11.196324	\N	\N	1	1	draw	yes
3518	1386129	2025-10-11	England	League Two	Chesterfield	Salford City	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	9	2025-11-20 17:17:11.204709	\N	\N	0	0	draw	yes
3519	1386133	2025-10-11	England	League Two	Gillingham	Cheltenham	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7	23	2025-11-20 17:17:11.210393	\N	\N	0	0	draw	yes
3520	1386136	2025-10-11	England	League Two	Shrewsbury	Cambridge United	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	21	12	2025-11-20 17:17:11.21787	\N	\N	2	0	h-win	yes
3521	1386139	2025-10-11	England	League Two	Accrington ST	Newport County	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	18	24	2025-11-20 17:17:11.224076	\N	\N	0	1	a-win	yes
3522	1386130	2025-10-11	England	League Two	Crawley Town	Walsall	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	20	2	2025-11-20 17:17:11.229737	\N	\N	1	0	h-win	yes
3523	1386131	2025-10-11	England	League Two	Crewe	Bromley	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8	5	2025-11-20 17:17:11.237574	\N	\N	0	0	draw	yes
3524	1386134	2025-10-11	England	League Two	Grimsby	Colchester	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	10	14	2025-11-20 17:17:11.243227	\N	\N	1	1	draw	yes
3525	1386138	2025-10-11	England	League Two	Tranmere	Barnet	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16	11	2025-11-20 17:17:11.25144	\N	\N	0	2	a-win	yes
3526	1386135	2025-10-11	England	League Two	Oldham	Barrow	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	15	17	2025-11-20 17:17:11.257676	\N	\N	0	0	draw	yes
3527	1386143	2025-10-18	England	League Two	Cambridge United	Bromley	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	5	2025-11-20 17:17:11.264258	\N	\N	2	0	h-win	yes
3528	1386148	2025-10-18	England	League Two	Salford City	Oldham	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	15	2025-11-20 17:17:11.270652	\N	\N	1	0	h-win	yes
3529	1386142	2025-10-18	England	League Two	Bristol Rovers	Tranmere	a-win	1	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	19	16	2025-11-20 17:17:11.27637	\N	\N	0	1	a-win	yes
3530	1386150	2025-10-18	England	League Two	Walsall	Barrow	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	17	2025-11-20 17:17:11.282022	\N	\N	0	1	a-win	yes
3531	1386144	2025-10-18	England	League Two	Chesterfield	Fleetwood Town	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	13	2025-11-20 17:17:11.290376	\N	\N	1	1	draw	yes
3532	1386147	2025-10-18	England	League Two	Milton Keynes Dons	Crewe	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	8	2025-11-20 17:17:11.296011	\N	\N	2	0	h-win	yes
3533	1386149	2025-10-18	England	League Two	Shrewsbury	Crawley Town	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	21	20	2025-11-20 17:17:11.304045	\N	\N	0	0	draw	yes
3534	1386140	2025-10-18	England	League Two	Accrington ST	Swindon Town	h-win	4	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	18	1	2025-11-20 17:17:11.309857	\N	\N	1	0	h-win	yes
3535	1386145	2025-10-18	England	League Two	Colchester	Harrogate Town	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	14	22	2025-11-20 17:17:11.317808	\N	\N	3	1	h-win	yes
3536	1386146	2025-10-18	England	League Two	Grimsby	Gillingham	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	10	7	2025-11-20 17:17:11.323874	\N	\N	0	0	draw	yes
3537	1386151	2025-10-18	England	League Two	Newport County	Cheltenham	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	24	23	2025-11-20 17:17:11.329438	\N	\N	0	1	a-win	yes
3538	1386141	2025-10-18	England	League Two	Barnet	Notts County	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	11	4	2025-11-20 17:17:11.337233	\N	\N	0	0	draw	yes
3539	1386137	2025-10-21	England	League Two	Swindon Town	Notts County	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	4	2025-11-20 17:17:11.342938	\N	\N	1	1	draw	yes
3540	1386157	2025-10-25	England	League Two	Fleetwood Town	Accrington ST	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	13	18	2025-11-20 17:17:11.348434	\N	\N	0	1	a-win	yes
3541	1386154	2025-10-25	England	League Two	Cheltenham	Walsall	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	23	2	2025-11-20 17:17:11.354087	\N	\N	0	0	draw	yes
3542	1386158	2025-10-25	England	League Two	Gillingham	Salford City	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7	9	2025-11-20 17:17:11.362021	\N	\N	1	2	a-win	yes
3543	1386160	2025-10-25	England	League Two	Oldham	Shrewsbury	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	15	21	2025-11-20 17:17:11.367476	\N	\N	0	0	draw	yes
3544	1386161	2025-10-25	England	League Two	Swindon Town	Colchester	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	14	2025-11-20 17:17:11.373433	\N	\N	0	0	draw	yes
3545	1386155	2025-10-25	England	League Two	Crawley Town	Bristol Rovers	h-win	4	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	20	19	2025-11-20 17:17:11.379045	\N	\N	1	0	h-win	yes
3546	1386156	2025-10-25	England	League Two	Crewe	Grimsby	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8	10	2025-11-20 17:17:11.387537	\N	\N	2	2	draw	yes
3547	1386159	2025-10-25	England	League Two	Notts County	Cambridge United	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	12	2025-11-20 17:17:11.393393	\N	\N	0	0	draw	yes
3548	1386162	2025-10-25	England	League Two	Tranmere	Chesterfield	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16	6	2025-11-20 17:17:11.399101	\N	\N	0	1	a-win	yes
3549	1386152	2025-10-25	England	League Two	Barrow	Barnet	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	17	11	2025-11-20 17:17:11.406737	\N	\N	1	0	h-win	yes
3550	1386153	2025-10-25	England	League Two	Bromley	Milton Keynes Dons	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	3	2025-11-20 17:17:11.413838	\N	\N	0	1	a-win	yes
3551	1386163	2025-10-25	England	League Two	Harrogate Town	Newport County	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	22	24	2025-11-20 17:17:11.421999	\N	\N	0	1	a-win	yes
3552	1386033	2025-10-28	England	League Two	Accrington ST	Tranmere	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	18	16	2025-11-20 17:17:11.427625	\N	\N	1	0	h-win	yes
3553	1386169	2025-11-08	England	League Two	Colchester	Bromley	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	14	5	2025-11-20 17:17:11.435726	\N	\N	0	0	draw	yes
3554	1386171	2025-11-08	England	League Two	Crewe	Shrewsbury	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8	21	2025-11-20 17:17:11.441597	\N	\N	1	1	draw	yes
3555	1386166	2025-11-08	England	League Two	Bristol Rovers	Gillingham	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	19	7	2025-11-20 17:17:11.4494	\N	\N	0	0	draw	yes
3556	1386168	2025-11-08	England	League Two	Chesterfield	Accrington ST	draw	3	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	18	2025-11-20 17:17:11.455523	\N	\N	1	2	a-win	yes
3557	1386174	2025-11-08	England	League Two	Swindon Town	Tranmere	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	16	2025-11-20 17:17:11.461124	\N	\N	0	0	draw	yes
3558	1386170	2025-11-08	England	League Two	Crawley Town	Fleetwood Town	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	20	13	2025-11-20 17:17:11.468698	\N	\N	1	0	h-win	yes
3559	1386175	2025-11-08	England	League Two	Newport County	Walsall	a-win	2	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	24	2	2025-11-20 17:17:11.474562	\N	\N	2	3	a-win	yes
3560	1386164	2025-11-08	England	League Two	Barnet	Milton Keynes Dons	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	11	3	2025-11-20 17:17:11.4802	\N	\N	2	1	h-win	yes
3561	1386165	2025-11-08	England	League Two	Barrow	Grimsby	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	17	10	2025-11-20 17:17:11.487856	\N	\N	1	2	a-win	yes
3562	1386172	2025-11-08	England	League Two	Harrogate Town	Oldham	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	22	15	2025-11-20 17:17:11.493563	\N	\N	0	1	a-win	yes
3563	1386173	2025-11-08	England	League Two	Salford City	Cambridge United	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	12	2025-11-20 17:17:11.499112	\N	\N	0	0	draw	yes
3564	1386167	2025-11-10	England	League Two	Cheltenham	Notts County	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	23	4	2025-11-20 17:17:11.507065	\N	\N	0	2	a-win	yes
3565	1386179	2025-11-15	England	League Two	Fleetwood Town	Swindon Town	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	13	1	2025-11-20 17:17:11.512686	\N	\N	1	1	draw	yes
3566	1386186	2025-11-15	England	League Two	Walsall	Colchester	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	14	2025-11-20 17:17:11.521247	\N	\N	0	2	a-win	yes
3567	1386182	2025-11-15	England	League Two	Milton Keynes Dons	Salford City	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	9	2025-11-20 17:17:11.527048	\N	\N	1	0	h-win	yes
3568	1386184	2025-11-15	England	League Two	Oldham	Crewe	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	15	8	2025-11-20 17:17:11.534168	\N	\N	0	0	draw	yes
3569	1386187	2025-11-15	England	League Two	Shrewsbury	Newport County	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	21	24	2025-11-20 17:17:11.540324	\N	\N	0	0	draw	yes
3570	1386176	2025-11-15	England	League Two	Accrington ST	Bristol Rovers	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	18	19	2025-11-20 17:17:11.545887	\N	\N	1	0	h-win	yes
3571	1386181	2025-11-15	England	League Two	Grimsby	Chesterfield	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	10	6	2025-11-20 17:17:11.553855	\N	\N	0	0	draw	yes
3572	1386178	2025-11-15	England	League Two	Cambridge United	Barnet	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	11	2025-11-20 17:17:11.560823	\N	\N	0	0	draw	yes
3573	1386183	2025-11-15	England	League Two	Notts County	Harrogate Town	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	22	2025-11-20 17:17:11.568704	\N	\N	0	1	a-win	yes
3574	1386185	2025-11-15	England	League Two	Tranmere	Cheltenham	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16	23	2025-11-20 17:17:11.574504	\N	\N	2	1	h-win	yes
3575	1386177	2025-11-15	England	League Two	Bromley	Barrow	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	17	2025-11-20 17:17:11.579946	\N	\N	1	0	h-win	yes
3576	1386180	2025-11-15	England	League Two	Gillingham	Crawley Town	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7	20	2025-11-20 17:17:11.58771	\N	\N	1	0	h-win	yes
3577	1386194	2025-11-22	England	League Two	Gillingham	Barnet	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 17:17:11.593931	\N	\N	0	0	draw	no
3578	1386195	2025-11-22	England	League Two	Harrogate Town	Walsall	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 17:17:11.599549	\N	\N	0	0	draw	no
3579	1386193	2025-11-22	England	League Two	Fleetwood Town	Shrewsbury	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 17:17:11.605612	\N	\N	0	0	draw	no
3580	1386199	2025-11-22	England	League Two	Oldham	Newport County	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 17:17:11.614302	\N	\N	0	0	draw	no
3581	1386197	2025-11-22	England	League Two	Swindon Town	Grimsby	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 17:17:11.620339	\N	\N	0	0	draw	no
3582	1386191	2025-11-22	England	League Two	Crawley Town	Accrington ST	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 17:17:11.627621	\N	\N	0	0	draw	no
3583	1386192	2025-11-22	England	League Two	Crewe	Chesterfield	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 17:17:11.633504	\N	\N	0	0	draw	no
3584	1386190	2025-11-22	England	League Two	Cheltenham	Bristol Rovers	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 17:17:11.639391	\N	\N	0	0	draw	no
3585	1386196	2025-11-22	England	League Two	Notts County	Colchester	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 17:17:11.647482	\N	\N	0	0	draw	no
3586	1386198	2025-11-22	England	League Two	Tranmere	Milton Keynes Dons	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 17:17:11.653689	\N	\N	0	0	draw	no
3587	1386188	2025-11-22	England	League Two	Barrow	Cambridge United	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 17:17:11.661255	\N	\N	0	0	draw	no
3588	1386189	2025-11-22	England	League Two	Bromley	Salford City	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 17:17:11.666914	\N	\N	0	0	draw	no
3964	1419368	2025-08-02	England	FA Cup	Blackstones	AFC Mansfield	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.656851	\N	\N	0	0	draw	yes
3965	1419394	2025-08-02	England	FA Cup	Hucknall Town	Yaxley	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.665599	\N	\N	0	0	draw	yes
3966	1419446	2025-08-02	England	FA Cup	Oldland Abbotonians	Wallingford & Crowmarsh	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.676664	\N	\N	0	0	draw	yes
3967	1419303	2025-08-02	England	FA Cup	St Blazey	Buckland Athletic	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.684105	\N	\N	0	0	draw	yes
3968	1419343	2025-08-02	England	FA Cup	Atherton Laburnum Rovers	Ossett United	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.694679	\N	\N	0	0	draw	yes
3969	1419438	2025-08-02	England	FA Cup	Birtley Town	Beverley Town	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.702934	\N	\N	0	0	draw	yes
3970	1419483	2025-08-02	England	FA Cup	Rossington Main	Moulton	h-win	4	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.715513	\N	\N	0	0	draw	yes
3971	1419465	2025-08-02	England	FA Cup	Shifnal Town FC	Coventry United	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.726735	\N	\N	0	0	draw	yes
3972	1419501	2025-08-02	England	FA Cup	Kennington	Tower Hamlets	a-win	0	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.73364	\N	\N	0	0	draw	yes
3973	1419504	2025-08-02	England	FA Cup	Athletic Newham	Sevenoaks Town	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.742971	\N	\N	0	0	draw	yes
3974	1419458	2025-08-02	England	FA Cup	Eastwood Community	Gresley	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.751874	\N	\N	0	0	draw	yes
3975	1419463	2025-08-02	England	FA Cup	Milton Keynes Irish	Heybridge Swifts	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.759272	\N	\N	0	0	draw	yes
3976	1419412	2025-08-02	England	FA Cup	Mousehole	Bridgwater Town	h-win	4	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.768975	\N	\N	0	0	draw	yes
3977	1419402	2025-08-02	England	FA Cup	Redcar Athletic	North Ferriby	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.77635	\N	\N	0	0	draw	yes
3978	1419376	2025-08-02	England	FA Cup	Skegness Town	Godmanchester Rovers	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.785773	\N	\N	0	0	draw	yes
3979	1419430	2025-08-02	England	FA Cup	Wythenshawe Town	Prestwich Heys	a-win	2	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.793386	\N	\N	0	0	draw	yes
3980	1419474	2025-08-02	England	FA Cup	Golcar United	Ramsbottom United	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.803277	\N	\N	0	0	draw	yes
3981	1419379	2025-08-02	England	FA Cup	Falmouth Town	Helston Athletic	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.810655	\N	\N	0	0	draw	yes
3982	1419397	2025-08-02	England	FA Cup	Hereford Pegasus	Lye Town	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.817957	\N	\N	0	0	draw	yes
3983	1419345	2025-08-02	England	FA Cup	Midhurst & Easebourne	Knaphill	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.827743	\N	\N	0	0	draw	yes
3984	1419300	2025-08-02	England	FA Cup	Worcester Raiders	Ashby Ivanhoe	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.835033	\N	\N	0	0	draw	yes
3985	1419367	2025-08-02	England	FA Cup	Aylestone Park	Sileby Rangers	a-win	1	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.844816	\N	\N	0	0	draw	yes
3986	1419470	2025-08-02	England	FA Cup	Harleston Town	Walsham Le Willows	a-win	2	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.85252	\N	\N	0	0	draw	yes
3987	1419396	2025-08-02	England	FA Cup	Hartpury University	Tuffley Rovers	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.862041	\N	\N	0	0	draw	yes
3988	1419413	2025-08-02	England	FA Cup	Heacham	Newmarket Town	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.871634	\N	\N	0	0	draw	yes
3989	1419429	2025-08-02	England	FA Cup	Pilkington	Longridge Town	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.879435	\N	\N	0	0	draw	yes
3990	1419484	2025-08-02	England	FA Cup	Snodland Town	Broadfields United	h-win	4	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.8892	\N	\N	0	0	draw	yes
3991	1419427	2025-08-02	England	FA Cup	Blyth Town	Horden CW	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.897133	\N	\N	0	0	draw	yes
3992	1419454	2025-08-02	England	FA Cup	Cornard United	Woodbridge Town	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.907598	\N	\N	0	0	draw	yes
3993	1419356	2025-08-02	England	FA Cup	Easington Colliery	Boro Rangers	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.915	\N	\N	0	0	draw	yes
3994	1419388	2025-08-02	England	FA Cup	Larkfield & New Hythe	Epsom & Ewell FC	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.925392	\N	\N	0	0	draw	yes
3995	1419336	2025-08-02	England	FA Cup	Pershore Town	Darlaston Town	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.93271	\N	\N	0	0	draw	yes
3996	1419537	2025-08-02	England	FA Cup	Portishead Town	Windsor & Eton	h-win	4	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.943066	\N	\N	0	0	draw	yes
3997	1419495	2025-08-02	England	FA Cup	Sporting Club Inkberrow	Studley	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.950799	\N	\N	0	0	draw	yes
3998	1419385	2025-08-02	England	FA Cup	Wick	VCD Athletic	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:08.960547	\N	\N	0	0	draw	yes
4043	1423492	2025-08-05	England	FA Cup	Shaftesbury Town	Baffins Milton Rovers	h-win	5	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.363041	\N	\N	0	0	draw	yes
4044	1423516	2025-08-05	England	FA Cup	Thetford Town	Histon	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.371312	\N	\N	0	0	draw	yes
4045	1423483	2025-08-05	England	FA Cup	Virginia Water	Thornbury Town	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.378246	\N	\N	0	0	draw	yes
4046	1423764	2025-08-05	England	FA Cup	Woodbridge Town	Cornard United	h-win	4	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.385278	\N	\N	0	0	draw	yes
4047	1423766	2025-08-05	England	FA Cup	Wroxham	Fakenham Town	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.393871	\N	\N	0	0	draw	yes
4048	1423502	2025-08-05	England	FA Cup	Benfleet	Leighton Town	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.400313	\N	\N	0	0	draw	yes
4049	1423505	2025-08-05	England	FA Cup	Little Oakley	Baldock Town	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.409891	\N	\N	0	0	draw	yes
4050	1423482	2025-08-05	England	FA Cup	Downham Town	Mildenhall Town	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.416473	\N	\N	0	0	draw	yes
4051	1423767	2025-08-05	England	FA Cup	Frenford	Witham Town	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.425959	\N	\N	0	0	draw	yes
4052	1423486	2025-08-05	England	FA Cup	St Helens	Glossop North End	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.432729	\N	\N	0	0	draw	yes
4053	1421946	2025-08-05	England	FA Cup	Wormley Rovers	Enfield 1893	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.442604	\N	\N	0	0	draw	yes
4054	1423510	2025-08-05	England	FA Cup	Wombwell Town	Horbury Town	h-win	4	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.449811	\N	\N	0	0	draw	yes
4055	1423515	2025-08-06	England	FA Cup	Clevedon Town	Kidlington	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.460406	\N	\N	0	0	draw	yes
4056	1429770	2025-08-06	England	FA Cup	AFC Liverpool	Abbey Hey	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.470929	\N	\N	0	0	draw	yes
4057	1423513	2025-08-06	England	FA Cup	Royal Wootton	Lydney Town	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.478522	\N	\N	0	0	draw	yes
4058	1424303	2025-08-06	England	FA Cup	Southall	Little Common	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.489047	\N	\N	0	0	draw	yes
4059	1423512	2025-08-06	England	FA Cup	Sporting Bengal United	Erith Town	a-win	2	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.496873	\N	\N	0	0	draw	yes
4060	1423768	2025-08-06	England	FA Cup	West Didsbury & Chorlton	Winsford United	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.506113	\N	\N	0	0	draw	yes
4061	1423514	2025-08-06	England	FA Cup	Whickham	Bishop Auckland	a-win	0	5	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.513586	\N	\N	0	0	draw	yes
4062	1423769	2025-08-06	England	FA Cup	Holmesdale	Tunbridge Wells	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.523122	\N	\N	0	0	draw	yes
4063	1423537	2025-08-15	England	FA Cup	Pickering Town	Easington Colliery	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.530478	\N	\N	0	0	draw	yes
4064	1423811	2025-08-15	England	FA Cup	Atherton Collieries	Prestwich Heys	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.539644	\N	\N	0	0	draw	yes
4065	1423785	2025-08-15	England	FA Cup	Christchurch	Tadley Calleva	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.546604	\N	\N	0	0	draw	yes
4066	1424310	2025-08-15	England	FA Cup	Lye Town	Racing Club Warwick	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.556313	\N	\N	0	0	draw	yes
4067	1423799	2025-08-15	England	FA Cup	Epsom & Ewell FC	South Park	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.562849	\N	\N	0	0	draw	yes
4068	1423543	2025-08-16	England	FA Cup	Jersey Bulls	Fisher	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.571967	\N	\N	0	0	draw	yes
4069	1423783	2025-08-16	England	FA Cup	Haringey Borough	Stanway Rovers	a-win	1	5	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.578923	\N	\N	0	0	draw	yes
4070	1423814	2025-08-16	England	FA Cup	Hitchin Town	Grays Athletic	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.588181	\N	\N	0	0	draw	yes
4071	1424897	2025-08-16	England	FA Cup	Leatherhead	Westfield (Surrey)	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.595143	\N	\N	0	0	draw	yes
4072	1423541	2025-08-16	England	FA Cup	Nantwich Town	Charnock Richard	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.602378	\N	\N	0	0	draw	yes
4073	1429722	2025-08-16	England	FA Cup	Merstham	Faversham Town	a-win	2	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.61127	\N	\N	0	0	draw	yes
4074	1429758	2025-08-16	England	FA Cup	Ashford United	Holmesdale	h-win	4	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.61925	\N	\N	0	0	draw	yes
4075	1423809	2025-08-16	England	FA Cup	Barnstaple Town	Tavistock	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.627589	\N	\N	0	0	draw	yes
4076	1429744	2025-08-16	England	FA Cup	Bedfont Sports	Kingstonian	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.635616	\N	\N	0	0	draw	yes
4077	1424314	2025-08-16	England	FA Cup	Bedworth United	Atherstone Town	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.644604	\N	\N	0	0	draw	yes
4078	1429741	2025-08-16	England	FA Cup	Frome Town	Newquay	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.652322	\N	\N	0	0	draw	yes
4079	1423772	2025-08-16	England	FA Cup	Great Wakering Rovers	Redbridge	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.661414	\N	\N	0	0	draw	yes
4080	1423815	2025-08-16	England	FA Cup	Hastings United	Harrow Borough	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.670423	\N	\N	0	0	draw	yes
4081	1429757	2025-08-16	England	FA Cup	Histon	Woodbridge Town	h-win	5	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.679519	\N	\N	0	0	draw	yes
4082	1423528	2025-08-16	England	FA Cup	Pontefract Collieries	Blyth Spartans	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.688676	\N	\N	0	0	draw	yes
4083	1424311	2025-08-16	England	FA Cup	Sutton Coldfield Town	Newcastle Town	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.696418	\N	\N	0	0	draw	yes
4084	1423773	2025-08-16	England	FA Cup	Tilbury	AFC Dunstable	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.706087	\N	\N	0	0	draw	yes
4085	1423533	2025-08-16	England	FA Cup	Tooting & Mitcham United	AFC Croydon Athletic	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.713713	\N	\N	0	0	draw	yes
4086	1423525	2025-08-16	England	FA Cup	VCD Athletic	Sittingbourne	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.722908	\N	\N	0	0	draw	yes
4087	1429730	2025-08-16	England	FA Cup	Witham Town	Tring Athletic	h-win	4	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.730494	\N	\N	0	0	draw	yes
4088	1429719	2025-08-16	England	FA Cup	Ashford Town (Middlesex)	Snodland Town	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.741804	\N	\N	0	0	draw	yes
4089	1429751	2025-08-16	England	FA Cup	Barton Rovers	Brantham Athletic	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.749481	\N	\N	0	0	draw	yes
4090	1424307	2025-08-16	England	FA Cup	Belper Town	Kidsgrove Athletic	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.759368	\N	\N	0	0	draw	yes
4091	1423812	2025-08-16	England	FA Cup	Daventry Town	Bottesford Town	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.769269	\N	\N	0	0	draw	yes
4092	1429726	2025-08-16	England	FA Cup	Harlow Town	Woodford Town	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.777205	\N	\N	0	0	draw	yes
4093	1429723	2025-08-16	England	FA Cup	Hertford Town	Harpenden Town	h-win	5	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.787223	\N	\N	0	0	draw	yes
4094	1429721	2025-08-16	England	FA Cup	Mangotsfield United	Cribbs	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.794779	\N	\N	0	0	draw	yes
4095	1423531	2025-08-16	England	FA Cup	Marlow	Binfield	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.804816	\N	\N	0	0	draw	yes
4096	1429740	2025-08-16	England	FA Cup	Moneyfields	AFC Portchester	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.812546	\N	\N	0	0	draw	yes
4097	1429746	2025-08-16	England	FA Cup	Sheffield	Bootle	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.82141	\N	\N	0	0	draw	yes
4098	1423526	2025-08-16	England	FA Cup	Three Bridges	Horsham YMCA	h-win	4	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.83119	\N	\N	0	0	draw	yes
4099	1423807	2025-08-16	England	FA Cup	Trafford	Campion	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.839605	\N	\N	0	0	draw	yes
4100	1423802	2025-08-16	England	FA Cup	Ware	Ilford	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.846847	\N	\N	0	0	draw	yes
4571	1481735	2025-11-01	England	FA Cup	Wealdstone	Southend	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.960159	\N	\N	1	0	h-win	yes
4101	1429724	2025-08-16	England	FA Cup	Welwyn Garden City	Waltham Abbey	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.85621	\N	\N	0	0	draw	yes
4102	1423779	2025-08-16	England	FA Cup	Winchester City	Bashley	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.863771	\N	\N	0	0	draw	yes
4103	1423780	2025-08-16	England	FA Cup	Basford United	Hucknall Town	h-win	5	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.873195	\N	\N	0	0	draw	yes
4104	1423770	2025-08-16	England	FA Cup	Brightlingsea Regent	Hullbridge Sports	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.880665	\N	\N	0	0	draw	yes
4105	1423517	2025-08-16	England	FA Cup	Corinthian-Casuals	Sevenoaks Town	a-win	3	5	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.890066	\N	\N	0	0	draw	yes
4106	1424898	2025-08-16	England	FA Cup	Hayes & Yeading United	Sutton Common Rovers	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.897639	\N	\N	0	0	draw	yes
4107	1423797	2025-08-16	England	FA Cup	Lowestoft Town	St Neots Town	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.906849	\N	\N	0	0	draw	yes
4108	1419511	2025-08-16	England	FA Cup	Mickleover Sports	Matlock Town	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.914499	\N	\N	0	0	draw	yes
4109	1423801	2025-08-16	England	FA Cup	Stalybridge Celtic	Bury	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.925174	\N	\N	0	0	draw	yes
4110	1429736	2025-08-16	England	FA Cup	Witton Albion	AFC Liverpool	h-win	4	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.93251	\N	\N	0	0	draw	yes
4111	1423542	2025-08-16	England	FA Cup	Bradford (Park Avenue)	Avro	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.943105	\N	\N	0	0	draw	yes
4112	1423781	2025-08-16	England	FA Cup	AFC Stoneham	Paulton Rovers	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.950419	\N	\N	0	0	draw	yes
4113	1423535	2025-08-16	England	FA Cup	Ardley United	Burnham	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.960476	\N	\N	0	0	draw	yes
4114	1423524	2025-08-16	England	FA Cup	Ascot United	Glebe	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.970069	\N	\N	0	0	draw	yes
4115	1429742	2025-08-16	England	FA Cup	Aylesbury Vale Dynamos	Oldland Abbotonians	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.977756	\N	\N	0	0	draw	yes
4116	1429754	2025-08-16	England	FA Cup	Barton Town Old Boys	Carlton Town	a-win	1	6	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.986717	\N	\N	0	0	draw	yes
4117	1423520	2025-08-16	England	FA Cup	Bexhill United	Raynes Park Vale	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:09.994513	\N	\N	0	0	draw	yes
4118	1429739	2025-08-16	England	FA Cup	Bishop Auckland	Horden CW	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.004976	\N	\N	0	0	draw	yes
4119	1423805	2025-08-16	England	FA Cup	Bradford Town	Westbury United	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.012894	\N	\N	0	0	draw	yes
4120	1429733	2025-08-16	England	FA Cup	Clevedon Town	Thame United	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.023428	\N	\N	0	0	draw	yes
4121	1423798	2025-08-16	England	FA Cup	Cobham	Margate	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.032696	\N	\N	0	0	draw	yes
4122	1429729	2025-08-16	England	FA Cup	Cockfosters	Little Oakley	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.040706	\N	\N	0	0	draw	yes
4123	1424312	2025-08-16	England	FA Cup	Congleton Town	Padiham	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.050484	\N	\N	0	0	draw	yes
4124	1429749	2025-08-16	England	FA Cup	Corinthian	Egham Town	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.060274	\N	\N	0	0	draw	yes
4125	1424306	2025-08-16	England	FA Cup	Coventry Sphinx	Dudley Town	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.067537	\N	\N	0	0	draw	yes
4126	1429745	2025-08-16	England	FA Cup	Crowborough Athletic	Deal Town	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.077846	\N	\N	0	0	draw	yes
4127	1423788	2025-08-16	England	FA Cup	Edgware Town	Whitstable Town	a-win	0	9	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.087682	\N	\N	0	0	draw	yes
4128	1423816	2025-08-16	England	FA Cup	Ely City	Haverhill Rovers	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.095248	\N	\N	0	0	draw	yes
4129	1429735	2025-08-16	England	FA Cup	Erith Town	Southall	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.105331	\N	\N	0	0	draw	yes
4130	1423775	2025-08-16	England	FA Cup	Exmouth	Buckland Athletic	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.112944	\N	\N	0	0	draw	yes
4131	1423804	2025-08-16	England	FA Cup	Fairford Town	Roman Glass St George	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.123169	\N	\N	0	0	draw	yes
4132	1423787	2025-08-16	England	FA Cup	Fareham Town	Hartley Wintney	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.130882	\N	\N	0	0	draw	yes
4133	1423794	2025-08-16	England	FA Cup	Flackwell Heath	Tuffley Rovers	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.140188	\N	\N	0	0	draw	yes
4134	1423793	2025-08-16	England	FA Cup	Gorleston	Walsham Le Willows	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.147738	\N	\N	0	0	draw	yes
4135	1429760	2025-08-16	England	FA Cup	Guisborough Town	Redcar Athletic	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.156727	\N	\N	0	0	draw	yes
4136	1423789	2025-08-16	England	FA Cup	Hadley	Maldon & Tiptree	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.164235	\N	\N	0	0	draw	yes
4137	1423534	2025-08-16	England	FA Cup	Hallen	Bishop's Cleeve	a-win	0	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.173342	\N	\N	0	0	draw	yes
4138	1423519	2025-08-16	England	FA Cup	Hassocks	Beckenham Town	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.180847	\N	\N	0	0	draw	yes
4139	1429738	2025-08-16	England	FA Cup	Horndean	Laverstock & Ford	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.191539	\N	\N	0	0	draw	yes
4140	1423806	2025-08-16	England	FA Cup	Hythe & Dibden	New Milton Town	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.198892	\N	\N	0	0	draw	yes
4141	1423527	2025-08-16	England	FA Cup	Irlam	Chadderton	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.209195	\N	\N	0	0	draw	yes
4142	1423522	2025-08-16	England	FA Cup	Knaphill	Hollands & Blair	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.216495	\N	\N	0	0	draw	yes
4143	1429720	2025-08-16	England	FA Cup	Lancing	Harefield United	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.227151	\N	\N	0	0	draw	yes
4144	1429756	2025-08-16	England	FA Cup	Leighton Town	Biggleswade United	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.236848	\N	\N	0	0	draw	yes
4145	1429748	2025-08-16	England	FA Cup	Longridge Town	AFC Emley	h-win	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.244523	\N	\N	0	0	draw	yes
4146	1424317	2025-08-16	England	FA Cup	Lutterworth Town	Chasetown	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.256605	\N	\N	0	0	draw	yes
4147	1424309	2025-08-16	England	FA Cup	Malvern Town	Worcester Raiders	a-win	2	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.264006	\N	\N	0	0	draw	yes
4148	1429753	2025-08-16	England	FA Cup	March Town United	Ipswich Wanderers	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.274021	\N	\N	0	0	draw	yes
4149	1429734	2025-08-16	England	FA Cup	Mildenhall Town	Wroxham	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.283052	\N	\N	0	0	draw	yes
4150	1423803	2025-08-16	England	FA Cup	Mulbarton Wanderers	Cambridge City	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.291309	\N	\N	0	0	draw	yes
4151	1423536	2025-08-16	England	FA Cup	Newmarket Town	Felixstowe & Walton Utd	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.300116	\N	\N	0	0	draw	yes
4152	1423523	2025-08-16	England	FA Cup	Newton Aycliffe	Newcastle Blue Star	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.308645	\N	\N	0	0	draw	yes
4153	1429725	2025-08-16	England	FA Cup	Northallerton Town	Kendal Town	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.315943	\N	\N	0	0	draw	yes
4154	1429752	2025-08-16	England	FA Cup	Reading City	Didcot Town	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.325972	\N	\N	0	0	draw	yes
4155	1429728	2025-08-16	England	FA Cup	Royal Wootton	Amersham Town	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.333265	\N	\N	0	0	draw	yes
4156	1423778	2025-08-16	England	FA Cup	Sawbridgeworth Town	Eynesbury Rovers	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.343635	\N	\N	0	0	draw	yes
4157	1429732	2025-08-16	England	FA Cup	Shaftesbury Town	Thatcham Town	h-win	4	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.351014	\N	\N	0	0	draw	yes
4158	1423518	2025-08-16	England	FA Cup	Sheppey United	Eastbourne United	h-win	9	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.360764	\N	\N	0	0	draw	yes
4159	1424304	2025-08-16	England	FA Cup	Shepshed Dynamo	Clay Cross	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.3683	\N	\N	0	0	draw	yes
4160	1423786	2025-08-16	England	FA Cup	Sherwood Colliery	Anstey Nomads	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.377599	\N	\N	0	0	draw	yes
4161	1424318	2025-08-16	England	FA Cup	Silsden	Ramsbottom United	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.38536	\N	\N	0	0	draw	yes
4162	1424896	2025-08-16	England	FA Cup	Sporting Khalsa	Sporting Club Inkberrow	h-win	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.394242	\N	\N	0	0	draw	yes
4163	1423532	2025-08-16	England	FA Cup	Steyning Town	Hendon	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.401842	\N	\N	0	0	draw	yes
4164	1424308	2025-08-16	England	FA Cup	Takeley	Bowers & Pitsea	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.411207	\N	\N	0	0	draw	yes
4165	1423540	2025-08-16	England	FA Cup	Thornaby	Dunston UTS	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.420806	\N	\N	0	0	draw	yes
4166	1423529	2025-08-16	England	FA Cup	Tower Hamlets	Hanworth Villa	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.428982	\N	\N	0	0	draw	yes
4167	1423782	2025-08-16	England	FA Cup	Wellingborough Town	Bourne Town	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.438859	\N	\N	0	0	draw	yes
4168	1429727	2025-08-16	England	FA Cup	West Auckland Town	Bridlington Town	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.446377	\N	\N	0	0	draw	yes
4169	1429747	2025-08-16	England	FA Cup	West Didsbury & Chorlton	Brighouse Town	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.455564	\N	\N	0	0	draw	yes
4170	1423774	2025-08-16	England	FA Cup	Whitchurch Alport	Runcorn Linnets	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.463032	\N	\N	0	0	draw	yes
4171	1423800	2025-08-16	England	FA Cup	Heaton Stannington	Marske United	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.472658	\N	\N	0	0	draw	yes
4172	1424305	2025-08-16	England	FA Cup	Hinckley AFC	Long Eaton United	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.480301	\N	\N	0	0	draw	yes
4173	1429750	2025-08-16	England	FA Cup	Risborough Rangers	Virginia Water	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.489382	\N	\N	0	0	draw	yes
4174	1423808	2025-08-16	England	FA Cup	Sileby Rangers	Corby Town	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.496859	\N	\N	0	0	draw	yes
4175	1423795	2025-08-16	England	FA Cup	Alton Town	Swindon Supermarine	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.50835	\N	\N	0	0	draw	yes
4176	1423776	2025-08-16	England	FA Cup	Blackstones	Grimsby Borough	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.51495	\N	\N	0	0	draw	yes
4177	1423539	2025-08-16	England	FA Cup	Birtley Town	Shildon AFC	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.524961	\N	\N	0	0	draw	yes
4178	1423790	2025-08-16	England	FA Cup	Rossington Main	Newark Town	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.534084	\N	\N	0	0	draw	yes
4179	1423817	2025-08-16	England	FA Cup	Newark Flowserve	Boston Town	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.541707	\N	\N	0	0	draw	yes
4180	1429755	2025-08-16	England	FA Cup	Brixham	Mousehole	h-win	4	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.551245	\N	\N	0	0	draw	yes
4181	1423796	2025-08-16	England	FA Cup	Milton Keynes Irish	Arlesey Town	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.559078	\N	\N	0	0	draw	yes
4182	1423792	2025-08-16	England	FA Cup	Skegness Town	Lincoln United	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.56994	\N	\N	0	0	draw	yes
4183	1423784	2025-08-16	England	FA Cup	Belper United	Hanley Town	a-win	2	5	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.577421	\N	\N	0	0	draw	yes
4184	1423771	2025-08-16	England	FA Cup	Falmouth Town	Bideford	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.585202	\N	\N	0	0	draw	yes
4185	1424316	2025-08-16	England	FA Cup	Pershore Town	Coleshill Town	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.593765	\N	\N	0	0	draw	yes
4186	1423813	2025-08-16	England	FA Cup	Portishead Town	Slimbridge	a-win	2	6	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.604199	\N	\N	0	0	draw	yes
4187	1429759	2025-08-16	England	FA Cup	St Helens	Atherton Laburnum Rovers	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.611801	\N	\N	0	0	draw	yes
4188	1424315	2025-08-16	England	FA Cup	Abbey Hulton	Coventry United	h-win	4	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.62129	\N	\N	0	0	draw	yes
4189	1429743	2025-08-16	England	FA Cup	Coton Green	Eastwood Community	a-win	0	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.62875	\N	\N	0	0	draw	yes
4190	1423538	2025-08-16	England	FA Cup	Seaford Town	AFC Whyteleafe	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.638089	\N	\N	0	0	draw	yes
4191	1423791	2025-08-16	England	FA Cup	Sidmouth Town	Torpoint Athletic	a-win	2	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.645616	\N	\N	0	0	draw	yes
4192	1429737	2025-08-16	England	FA Cup	Wombwell Town	Parkgate	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.65498	\N	\N	0	0	draw	yes
4193	1423530	2025-08-17	England	FA Cup	Hackney Wick	Bognor Regis Town	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.662519	\N	\N	0	0	draw	yes
4194	1424313	2025-08-17	England	FA Cup	Hallam	City of Liverpool	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.671685	\N	\N	0	0	draw	yes
4195	1429731	2025-08-17	England	FA Cup	Enfield 1893	Biggleswade Town	h-win	4	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.681482	\N	\N	0	0	draw	yes
4196	1423810	2025-08-17	England	FA Cup	Littlehampton Town	North Greenford United	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.691996	\N	\N	0	0	draw	yes
4197	1423777	2025-08-17	England	FA Cup	Wokingham Town	Larkhall Athletic	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.699523	\N	\N	0	0	draw	yes
4198	1440131	2025-08-18	England	FA Cup	Swindon Supermarine	Alton Town	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.709749	\N	\N	0	0	draw	yes
4199	1440135	2025-08-19	England	FA Cup	Shildon AFC	Birtley Town	h-win	5	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.717243	\N	\N	0	0	draw	yes
4200	1440140	2025-08-19	England	FA Cup	Bury	Stalybridge Celtic	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.727973	\N	\N	0	0	draw	yes
4201	1440137	2025-08-19	England	FA Cup	Kendal Town	Northallerton Town	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.737822	\N	\N	0	0	draw	yes
4202	1438768	2025-08-19	England	FA Cup	South Park	Epsom & Ewell FC	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.74537	\N	\N	0	0	draw	yes
4203	1440427	2025-08-19	England	FA Cup	Waltham Abbey	Welwyn Garden City	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.754775	\N	\N	0	0	draw	yes
4204	1440133	2025-08-19	England	FA Cup	Felixstowe & Walton Utd	Newmarket Town	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.76231	\N	\N	0	0	draw	yes
4205	1440143	2025-08-19	England	FA Cup	Lincoln United	Skegness Town	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.773092	\N	\N	0	0	draw	yes
4206	1440141	2025-08-19	England	FA Cup	Ramsbottom United	Silsden	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.781	\N	\N	0	0	draw	yes
4207	1440139	2025-08-19	England	FA Cup	Margate	Cobham	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.790809	\N	\N	0	0	draw	yes
4208	1440134	2025-08-19	England	FA Cup	Bowers & Pitsea	Takeley	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.799906	\N	\N	0	0	draw	yes
4209	1440132	2025-08-19	England	FA Cup	Bashley	Winchester City	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.807907	\N	\N	0	0	draw	yes
4210	1440426	2025-08-19	England	FA Cup	Redbridge	Great Wakering Rovers	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.81668	\N	\N	0	0	draw	yes
4211	1440142	2025-08-19	England	FA Cup	Walsham Le Willows	Gorleston	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.825058	\N	\N	0	0	draw	yes
4212	1423521	2025-08-19	England	FA Cup	Wythenshawe Amateurs	Vauxhall Motors	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.832363	\N	\N	0	0	draw	yes
4213	1440136	2025-08-19	England	FA Cup	Boston Town	Newark Flowserve	h-win	4	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.842595	\N	\N	0	0	draw	yes
4214	1440144	2025-08-19	England	FA Cup	Bridlington Town	West Auckland Town	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.84994	\N	\N	0	0	draw	yes
4215	1440145	2025-08-20	England	FA Cup	Redcar Athletic	Guisborough Town	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.86064	\N	\N	0	0	draw	yes
4216	1440147	2025-08-20	England	FA Cup	Grays Athletic	Hitchin Town	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.869115	\N	\N	0	0	draw	yes
4217	1440146	2025-08-20	England	FA Cup	Hollands & Blair	Knaphill	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.877501	\N	\N	0	0	draw	yes
4218	1440148	2025-08-20	England	FA Cup	Ilford	Ware	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.88683	\N	\N	0	0	draw	yes
4219	1445788	2025-08-20	England	FA Cup	Southall	Erith Town	a-win	1	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.894434	\N	\N	0	0	draw	yes
4220	1440149	2025-08-20	England	FA Cup	Woodford Town	Harlow Town	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.904309	\N	\N	0	0	draw	yes
4221	1438769	2025-08-20	England	FA Cup	Easington Colliery	Pickering Town	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.911908	\N	\N	0	0	draw	yes
4222	1440138	2025-08-26	England	FA Cup	Egham Town	Corinthian	h-win	4	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.921408	\N	\N	0	0	draw	yes
4223	1440347	2025-08-29	England	FA Cup	Aveley	Hashtag United	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.928767	\N	\N	3	0	h-win	yes
4224	1440401	2025-08-29	England	FA Cup	Faversham Town	Hastings United	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.938134	\N	\N	0	1	a-win	yes
4225	1445787	2025-08-29	England	FA Cup	Pickering Town	Redcar Athletic	h-win	5	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.945603	\N	\N	2	1	h-win	yes
4226	1440369	2025-08-30	England	FA Cup	Tadley Calleva	Weymouth	h-win	4	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.956431	\N	\N	2	1	h-win	yes
4227	1440346	2025-08-30	England	FA Cup	Burnham	Jersey Bulls	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.964431	\N	\N	0	1	a-win	yes
4228	1440404	2025-08-30	England	FA Cup	Havant & Wville	Chichester City	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.974245	\N	\N	0	0	draw	yes
4229	1440368	2025-08-30	England	FA Cup	Billericay Town	Barton Rovers	h-win	4	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.981319	\N	\N	1	1	draw	yes
4230	1440422	2025-08-30	England	FA Cup	Hyde United	Prescot Cables	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.991291	\N	\N	1	0	h-win	yes
4231	1440403	2025-08-30	England	FA Cup	Stamford	Coventry Sphinx	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:10.998608	\N	\N	1	0	h-win	yes
4232	1440395	2025-08-30	England	FA Cup	AFC Sudbury	Mildenhall Town	h-win	4	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.009413	\N	\N	1	0	h-win	yes
4233	1440348	2025-08-30	England	FA Cup	Bedfont Sports	Littlehampton Town	h-win	4	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.016735	\N	\N	2	1	h-win	yes
4234	1440339	2025-08-30	England	FA Cup	Berkhamsted	St Ives Town	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.027342	\N	\N	1	0	h-win	yes
4235	1440370	2025-08-30	England	FA Cup	Brentwood Town	Leighton Town	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.035022	\N	\N	1	1	draw	yes
4236	1440330	2025-08-30	England	FA Cup	Corby Town	Gainsborough Trinity	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.044345	\N	\N	1	1	draw	yes
4237	1440381	2025-08-30	England	FA Cup	Didcot Town	Poole Town	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.053889	\N	\N	1	1	draw	yes
4238	1440425	2025-08-30	England	FA Cup	Histon	Mulbarton Wanderers	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.061283	\N	\N	0	1	a-win	yes
4239	1440354	2025-08-30	England	FA Cup	Ilkeston Town	Spalding United	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.069805	\N	\N	1	1	draw	yes
4240	1440341	2025-08-30	England	FA Cup	Kendal Town	Dunston UTS	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.077341	\N	\N	0	1	a-win	yes
4241	1440362	2025-08-30	England	FA Cup	Sittingbourne	AFC Croydon Athletic	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.086444	\N	\N	0	0	draw	yes
4242	1440402	2025-08-30	England	FA Cup	Sutton Coldfield Town	Abbey Hulton	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.094022	\N	\N	1	0	h-win	yes
4243	1440340	2025-08-30	England	FA Cup	Uxbridge	Welling United	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.102004	\N	\N	0	1	a-win	yes
4244	1440396	2025-08-30	England	FA Cup	Westfield (Surrey)	Sheppey United	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.110851	\N	\N	1	0	h-win	yes
4245	1440413	2025-08-30	England	FA Cup	Witham Town	Lowestoft Town	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.119039	\N	\N	2	0	h-win	yes
4246	1440387	2025-08-30	England	FA Cup	Workington	Stalybridge Celtic	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.127613	\N	\N	0	2	a-win	yes
4247	1440386	2025-08-30	England	FA Cup	Ashford Town (Middlesex)	AFC Whyteleafe	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.135373	\N	\N	3	1	h-win	yes
4248	1440380	2025-08-30	England	FA Cup	Carlton Town	Cleethorpes Town	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.144096	\N	\N	2	0	h-win	yes
4249	1440327	2025-08-30	England	FA Cup	Chertsey Town	Thame United	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.15326	\N	\N	1	0	h-win	yes
4250	1440325	2025-08-30	England	FA Cup	Coleshill Town	Worcester Raiders	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.160714	\N	\N	0	0	draw	yes
4251	1440417	2025-08-30	England	FA Cup	Evesham United	Bromsgrove Sporting	h-win	5	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.168364	\N	\N	2	1	h-win	yes
4252	1440408	2025-08-30	England	FA Cup	Halesowen Town	Stratford Town	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.177526	\N	\N	1	1	draw	yes
4253	1440357	2025-08-30	England	FA Cup	Kidsgrove Athletic	Racing Club Warwick	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.187723	\N	\N	1	1	draw	yes
4254	1440351	2025-08-30	England	FA Cup	Maldon & Tiptree	Canvey Island	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.195325	\N	\N	1	0	h-win	yes
4255	1440365	2025-08-30	England	FA Cup	Mangotsfield United	Banbury United	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.205182	\N	\N	0	1	a-win	yes
4256	1440343	2025-08-30	England	FA Cup	Ramsgate	Cray Valley PM	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.213211	\N	\N	0	1	a-win	yes
4257	1440360	2025-08-30	England	FA Cup	Slimbridge	Dorchester Town	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.223916	\N	\N	0	0	draw	yes
4258	1440394	2025-08-30	England	FA Cup	Three Bridges	Walton & Hersham	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.231367	\N	\N	0	0	draw	yes
4259	1440393	2025-08-30	England	FA Cup	Trafford	Stockton Town	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.242054	\N	\N	1	0	h-win	yes
4260	1440355	2025-08-30	England	FA Cup	Winchester City	Fareham Town	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.251486	\N	\N	0	0	draw	yes
4261	1440367	2025-08-30	England	FA Cup	Alvechurch	Barwell	h-win	4	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.258696	\N	\N	2	0	h-win	yes
4262	1440377	2025-08-30	England	FA Cup	Brightlingsea Regent	Bury Town	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.268432	\N	\N	2	2	draw	yes
4263	1440412	2025-08-30	England	FA Cup	Carshalton Athletic	Wingate & Finchley	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.276058	\N	\N	0	0	draw	yes
4264	1440350	2025-08-30	England	FA Cup	Cheshunt	Leiston	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.286382	\N	\N	1	1	draw	yes
4265	1440416	2025-08-30	England	FA Cup	Cray Wanderers	Hanwell Town	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.293757	\N	\N	1	0	h-win	yes
4266	1440353	2025-08-30	England	FA Cup	Folkestone Invicta	Sevenoaks Town	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.305553	\N	\N	2	0	h-win	yes
4267	1440421	2025-08-30	England	FA Cup	Gosport Borough	Basingstoke Town	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.313236	\N	\N	1	0	h-win	yes
4268	1440373	2025-08-30	England	FA Cup	Hayes & Yeading United	Whitehawk	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.322498	\N	\N	0	1	a-win	yes
4269	1440410	2025-08-30	England	FA Cup	Hednesford Town	Basford United	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.329936	\N	\N	1	0	h-win	yes
4270	1440375	2025-08-30	England	FA Cup	Lancaster City	Whitby Town	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.339257	\N	\N	0	1	a-win	yes
4271	1440399	2025-08-30	England	FA Cup	Matlock Town	Bottesford Town	h-win	4	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.346787	\N	\N	1	1	draw	yes
4272	1440336	2025-08-30	England	FA Cup	Morpeth Town	Pontefract Collieries	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.356319	\N	\N	1	1	draw	yes
4273	1440414	2025-08-30	England	FA Cup	Needham Market	Tilbury	h-win	4	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.363829	\N	\N	2	0	h-win	yes
4274	1445786	2025-08-30	England	FA Cup	Potters Bar Town	Hitchin Town	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.372885	\N	\N	2	0	h-win	yes
4275	1440407	2025-08-30	England	FA Cup	Redditch United	Skegness Town	h-win	5	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.38022	\N	\N	3	0	h-win	yes
4276	1440388	2025-08-30	England	FA Cup	Rushall Olympic	Atherstone Town	h-win	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.39084	\N	\N	4	1	h-win	yes
4277	1440326	2025-08-30	England	FA Cup	Tiverton Town	Taunton Town	a-win	3	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.398176	\N	\N	1	1	draw	yes
4278	1440345	2025-08-30	England	FA Cup	Warrington Town	Bamber Bridge	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.408466	\N	\N	0	0	draw	yes
4279	1440405	2025-08-30	England	FA Cup	Witton Albion	Shildon AFC	draw	3	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.415776	\N	\N	2	1	h-win	yes
4280	1440378	2025-08-30	England	FA Cup	Bowers & Pitsea	Hertford Town	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.425529	\N	\N	0	0	draw	yes
4281	1440329	2025-08-30	England	FA Cup	Dulwich Hamlet	Whitstable Town	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.432832	\N	\N	0	2	a-win	yes
4282	1440352	2025-08-30	England	FA Cup	Gloucester City	AFC Portchester	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.442964	\N	\N	0	0	draw	yes
4283	1440415	2025-08-30	England	FA Cup	Hungerford Town	AFC Stoneham	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.450237	\N	\N	0	0	draw	yes
4284	1440372	2025-08-30	England	FA Cup	Avro	Nantwich Town	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.460109	\N	\N	0	1	a-win	yes
4285	1440384	2025-08-30	England	FA Cup	Aylesbury Vale Dynamos	St Albans City	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.469076	\N	\N	0	2	a-win	yes
4286	1449278	2025-08-30	England	FA Cup	Beckenham Town	Egham Town	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.477795	\N	\N	0	0	draw	yes
4287	1440397	2025-08-30	England	FA Cup	Bishop Auckland	Chadderton	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.485557	\N	\N	0	1	a-win	yes
4288	1440349	2025-08-30	England	FA Cup	Bishop's Cleeve	Wimborne Town	a-win	2	5	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.494096	\N	\N	0	2	a-win	yes
4289	1440400	2025-08-30	England	FA Cup	Chatham Town	Marlow	h-win	4	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.502001	\N	\N	0	0	draw	yes
4290	1440374	2025-08-30	England	FA Cup	Deal Town	Cobham	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.510638	\N	\N	0	0	draw	yes
4291	1442551	2025-08-30	England	FA Cup	Enfield 1893	Ilford	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.518459	\N	\N	1	1	draw	yes
4292	1445784	2025-08-30	England	FA Cup	Erith Town	Farnham Town	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.527148	\N	\N	0	2	a-win	yes
4293	1440383	2025-08-30	England	FA Cup	Eynesbury Rovers	Arlesey Town	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.534731	\N	\N	1	0	h-win	yes
4294	1440390	2025-08-30	England	FA Cup	Fairford Town	Sholing	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.544169	\N	\N	0	1	a-win	yes
4295	1440324	2025-08-30	England	FA Cup	Flackwell Heath	Lewes	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.554163	\N	\N	0	0	draw	yes
4296	1440419	2025-08-30	England	FA Cup	Hanley Town	Stourbridge	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.561862	\N	\N	0	1	a-win	yes
4297	1440411	2025-08-30	England	FA Cup	Harborough Town	Leek Town	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.571689	\N	\N	0	0	draw	yes
4298	1449969	2025-08-30	England	FA Cup	Haverhill Rovers	Waltham Abbey	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.579153	\N	\N	0	1	a-win	yes
4299	1440328	2025-08-30	England	FA Cup	Hebburn Town	Longridge Town	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.589858	\N	\N	1	0	h-win	yes
4300	1440420	2025-08-30	England	FA Cup	Hythe & Dibden	Laverstock & Ford	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.597157	\N	\N	0	0	draw	yes
4301	1445785	2025-08-30	England	FA Cup	Knaphill	Hackney Wick	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.607614	\N	\N	0	0	draw	yes
4302	1440342	2025-08-30	England	FA Cup	Long Eaton United	Kettering Town	a-win	1	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.614953	\N	\N	1	1	draw	yes
4303	1440391	2025-08-30	England	FA Cup	March Town United	Gorleston	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.624757	\N	\N	0	0	draw	yes
4304	1442552	2025-08-30	England	FA Cup	Newmarket Town	Woodford Town	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.632004	\N	\N	1	2	a-win	yes
4305	1440356	2025-08-30	England	FA Cup	Plymouth Parkway	Frome Town	a-win	0	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.642523	\N	\N	0	3	a-win	yes
4306	1440389	2025-08-30	England	FA Cup	Quorn	Sherwood Colliery	h-win	8	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.649838	\N	\N	3	0	h-win	yes
4307	1440424	2025-08-30	England	FA Cup	Raynes Park Vale	Ashford United	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.660404	\N	\N	0	1	a-win	yes
4308	1440335	2025-08-30	England	FA Cup	Redbridge	Royston Town	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.66809	\N	\N	1	1	draw	yes
4309	1440337	2025-08-30	England	FA Cup	Royal Wootton	Torpoint Athletic	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.677283	\N	\N	1	0	h-win	yes
4310	1440366	2025-08-30	England	FA Cup	Rylands	Guiseley AFC	a-win	1	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.685099	\N	\N	1	2	a-win	yes
4311	1440323	2025-08-30	England	FA Cup	Shaftesbury Town	Exmouth	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.69361	\N	\N	0	1	a-win	yes
4312	1440358	2025-08-30	England	FA Cup	Silsden	Bootle	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.701422	\N	\N	0	0	draw	yes
4313	1440406	2025-08-30	England	FA Cup	Stanway Rovers	Cockfosters	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.710332	\N	\N	1	0	h-win	yes
4314	1440382	2025-08-30	England	FA Cup	Steyning Town	Lancing	h-win	5	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.720368	\N	\N	4	0	h-win	yes
4315	1440376	2025-08-30	England	FA Cup	Tavistock	Swindon Supermarine	a-win	1	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.727704	\N	\N	1	1	draw	yes
4316	1440331	2025-08-30	England	FA Cup	Tower Hamlets	Ascot United	h-win	4	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.735735	\N	\N	3	0	h-win	yes
4317	1440398	2025-08-30	England	FA Cup	West Auckland Town	Wythenshawe Amateurs	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.744484	\N	\N	1	0	h-win	yes
4318	1440409	2025-08-30	England	FA Cup	West Didsbury & Chorlton	Runcorn Linnets	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.754449	\N	\N	0	1	a-win	yes
4319	1440392	2025-08-30	England	FA Cup	Westbury United	Yate Town	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.761975	\N	\N	2	1	h-win	yes
4320	1440371	2025-08-30	England	FA Cup	Worcester City	Chasetown	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.771185	\N	\N	1	0	h-win	yes
4321	1440333	2025-08-30	England	FA Cup	Epsom & Ewell FC	Risborough Rangers	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.779238	\N	\N	0	0	draw	yes
4322	1440385	2025-08-30	England	FA Cup	Atherton Laburnum Rovers	Atherton Collieries	h-win	5	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.789597	\N	\N	3	0	h-win	yes
4323	1440363	2025-08-30	England	FA Cup	Rossington Main	United of Manchester	a-win	0	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.796928	\N	\N	0	2	a-win	yes
4324	1440338	2025-08-30	England	FA Cup	Eastwood Community	Grimsby Borough	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.805613	\N	\N	0	1	a-win	yes
4325	1440332	2025-08-30	England	FA Cup	Falmouth Town	Brixham	a-win	0	5	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.812032	\N	\N	0	1	a-win	yes
4326	1440418	2025-08-30	England	FA Cup	Real Bedford	Bishop's Stortford	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.82186	\N	\N	1	0	h-win	yes
4327	1440364	2025-08-30	England	FA Cup	Bourne Town	Shepshed Dynamo	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.829402	\N	\N	0	0	draw	yes
4328	1440423	2025-08-30	England	FA Cup	Newcastle Blue Star	Heaton Stannington	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.838965	\N	\N	0	0	draw	yes
4329	1440344	2025-08-30	England	FA Cup	Boston Town	Sporting Khalsa	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.846469	\N	\N	0	0	draw	yes
4330	1440361	2025-08-30	England	FA Cup	Wombwell Town	Stocksbridge Park Steels	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.855338	\N	\N	0	1	a-win	yes
4331	1440359	2025-08-30	England	FA Cup	Bracknell Town	Dartford	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.863088	\N	\N	2	0	h-win	yes
4332	1440334	2025-08-31	England	FA Cup	Hallam	Ashton United	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.873321	\N	\N	1	2	a-win	yes
4743	1399576	2025-10-18	England	National League	York	Wealdstone	h-win	4	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.423031	\N	\N	2	0	h-win	yes
4333	1440379	2025-08-31	England	FA Cup	Wokingham Town	Burgess Hill Town	a-win	1	5	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.880355	\N	\N	0	4	a-win	yes
4334	1451305	2025-09-01	England	FA Cup	Abbey Hulton	Sutton Coldfield Town	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.890755	\N	\N	1	2	a-win	yes
4335	1451310	2025-09-02	England	FA Cup	Hitchin Town	Potters Bar Town	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.897634	\N	\N	0	0	draw	yes
4336	1451307	2025-09-02	England	FA Cup	Dartford	Bracknell Town	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.907384	\N	\N	0	1	a-win	yes
4337	1451314	2025-09-02	England	FA Cup	Nantwich Town	Avro	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.921582	\N	\N	0	0	draw	yes
4338	1450819	2025-09-02	England	FA Cup	Hastings United	Faversham Town	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.928666	\N	\N	0	0	draw	yes
4339	1451315	2025-09-02	England	FA Cup	Leek Town	Harborough Town	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.938837	\N	\N	0	1	a-win	yes
4340	1451313	2025-09-02	England	FA Cup	Chasetown	Worcester City	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.945805	\N	\N	1	0	h-win	yes
4341	1451687	2025-09-02	England	FA Cup	Hanwell Town	Cray Wanderers	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.955224	\N	\N	0	0	draw	yes
4342	1451318	2025-09-02	England	FA Cup	Prescot Cables	Hyde United	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.962532	\N	\N	0	0	draw	yes
4343	1451311	2025-09-02	England	FA Cup	Bishop's Stortford	Real Bedford	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.972565	\N	\N	0	0	draw	yes
4344	1451689	2025-09-02	England	FA Cup	Poole Town	Didcot Town	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.979894	\N	\N	1	1	draw	yes
4345	1451688	2025-09-02	England	FA Cup	Stratford Town	Halesowen Town	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.98892	\N	\N	0	1	a-win	yes
4346	1451312	2025-09-02	England	FA Cup	Wingate & Finchley	Carshalton Athletic	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:11.996364	\N	\N	2	0	h-win	yes
4347	1451690	2025-09-02	England	FA Cup	Yate Town	Westbury United	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.006448	\N	\N	1	1	draw	yes
4348	1451308	2025-09-02	England	FA Cup	AFC Portchester	Gloucester City	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.013444	\N	\N	0	2	a-win	yes
4349	1451317	2025-09-02	England	FA Cup	Bootle	Silsden	h-win	4	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.023346	\N	\N	1	1	draw	yes
4350	1451320	2025-09-02	England	FA Cup	Fareham Town	Winchester City	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.030501	\N	\N	1	0	h-win	yes
4351	1451306	2025-09-02	England	FA Cup	Shepshed Dynamo	Bourne Town	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.040493	\N	\N	1	0	h-win	yes
4352	1451319	2025-09-02	England	FA Cup	Shildon AFC	Witton Albion	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.047814	\N	\N	0	2	a-win	yes
4353	1451309	2025-09-02	England	FA Cup	Sporting Khalsa	Boston Town	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.057637	\N	\N	0	0	draw	yes
4354	1451316	2025-09-03	England	FA Cup	Whitehawk	Hayes & Yeading United	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.064362	\N	\N	2	1	h-win	yes
4355	1451692	2025-09-03	England	FA Cup	Ashton United	Hallam	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.074324	\N	\N	1	0	h-win	yes
4356	1451691	2025-09-03	England	FA Cup	Exmouth	Shaftesbury Town	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.081107	\N	\N	0	0	draw	yes
4357	1457569	2025-09-12	England	FA Cup	Folkestone Invicta	Maidstone Utd	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.090741	\N	\N	1	0	h-win	yes
4358	1457535	2025-09-13	England	FA Cup	Pickering Town	Runcorn Linnets	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.097558	\N	\N	0	1	a-win	yes
4359	1457592	2025-09-13	England	FA Cup	Macclesfield	Atherton Laburnum Rovers	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.106842	\N	\N	0	0	draw	yes
4360	1457581	2025-09-13	England	FA Cup	Maidenhead	Faversham Town	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.114417	\N	\N	0	1	a-win	yes
4361	1457554	2025-09-13	England	FA Cup	AFC Fylde	Bamber Bridge	h-win	4	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.124099	\N	\N	2	0	h-win	yes
4362	1457585	2025-09-13	England	FA Cup	Ebbsfleet United	Ashford Town (Middlesex)	h-win	5	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.131364	\N	\N	1	0	h-win	yes
4363	1457583	2025-09-13	England	FA Cup	Billericay Town	Berkhamsted	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.140772	\N	\N	1	0	h-win	yes
4364	1457526	2025-09-13	England	FA Cup	Hampton & Richmond	AFC Croydon Athletic	h-win	4	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.147279	\N	\N	2	1	h-win	yes
4365	1457523	2025-09-13	England	FA Cup	Hitchin Town	St Albans City	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.156906	\N	\N	0	0	draw	yes
4366	1457582	2025-09-13	England	FA Cup	AFC Telford United	Kidderminster Harriers	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.163818	\N	\N	1	0	h-win	yes
4367	1457518	2025-09-13	England	FA Cup	Chelmsford City	Hertford Town	h-win	6	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.172426	\N	\N	2	0	h-win	yes
4368	1457530	2025-09-13	England	FA Cup	Gainsborough Trinity	Rushall Olympic	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.17935	\N	\N	1	0	h-win	yes
4369	1457527	2025-09-13	England	FA Cup	Hyde United	Whitby Town	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.188406	\N	\N	1	0	h-win	yes
4370	1457544	2025-09-13	England	FA Cup	Nantwich Town	Trafford	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.196448	\N	\N	2	1	h-win	yes
4371	1457524	2025-09-13	England	FA Cup	Chesham United	King's Lynn Town	a-win	1	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.205676	\N	\N	1	2	a-win	yes
4372	1457537	2025-09-13	England	FA Cup	Curzon Ashton	Hebburn Town	h-win	4	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.213068	\N	\N	3	1	h-win	yes
4373	1457586	2025-09-13	England	FA Cup	Eastbourne Borough	Epsom & Ewell FC	h-win	4	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.223447	\N	\N	2	0	h-win	yes
4374	1457590	2025-09-13	England	FA Cup	Taunton Town	Weston-super-Mare	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.230671	\N	\N	1	1	draw	yes
4375	1457528	2025-09-13	England	FA Cup	Whitehawk	Walton & Hersham	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.240693	\N	\N	0	2	a-win	yes
4376	1457594	2025-09-13	England	FA Cup	AFC Sudbury	Aveley	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.250297	\N	\N	0	1	a-win	yes
4377	1457555	2025-09-13	England	FA Cup	Ashford United	Chatham Town	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.258392	\N	\N	0	2	a-win	yes
4378	1457564	2025-09-13	England	FA Cup	Burgess Hill Town	Farnham Town	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.266906	\N	\N	1	1	draw	yes
4379	1457553	2025-09-13	England	FA Cup	Sutton Coldfield Town	Stourbridge	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.27447	\N	\N	1	0	h-win	yes
4380	1468208	2025-09-13	England	FA Cup	Waltham Abbey	Gorleston	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.28516	\N	\N	2	0	h-win	yes
4381	1457531	2025-09-13	England	FA Cup	Westfield (Surrey)	Horsham	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.292662	\N	\N	0	1	a-win	yes
4382	1457573	2025-09-13	England	FA Cup	AFC Totton	Torquay	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.300022	\N	\N	1	0	h-win	yes
4383	1457574	2025-09-13	England	FA Cup	Bedford Town	Dagenham & Redbridge	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.309857	\N	\N	0	1	a-win	yes
4384	1457521	2025-09-13	England	FA Cup	Bracknell Town	Tadley Calleva	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.317189	\N	\N	0	0	draw	yes
4385	1457542	2025-09-13	England	FA Cup	Bury Town	Woodford Town	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.327111	\N	\N	0	0	draw	yes
4386	1457577	2025-09-13	England	FA Cup	Chasetown	Banbury United	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.334677	\N	\N	0	0	draw	yes
4387	1457584	2025-09-13	England	FA Cup	Chertsey Town	Cray Valley PM	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.343679	\N	\N	1	2	a-win	yes
4388	1457566	2025-09-13	England	FA Cup	Coleshill Town	Hednesford Town	a-win	0	7	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.351416	\N	\N	0	5	a-win	yes
4389	1457572	2025-09-13	England	FA Cup	Dunston UTS	Stocksbridge Park Steels	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.360796	\N	\N	0	0	draw	yes
4390	1457543	2025-09-13	England	FA Cup	Hanwell Town	Bedfont Sports	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.371459	\N	\N	0	1	a-win	yes
4391	1457534	2025-09-13	England	FA Cup	Maldon & Tiptree	Stanway Rovers	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.378977	\N	\N	2	0	h-win	yes
4392	1457563	2025-09-13	England	FA Cup	Spalding United	Alfreton Town	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.388785	\N	\N	2	0	h-win	yes
4393	1457549	2025-09-13	England	FA Cup	Whitstable Town	Chichester City	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.396383	\N	\N	1	0	h-win	yes
4394	1457540	2025-09-13	England	FA Cup	Alvechurch	Leamington	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.406042	\N	\N	0	0	draw	yes
4395	1457520	2025-09-13	England	FA Cup	Ashton United	Scarborough Athletic	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.413534	\N	\N	0	0	draw	yes
4396	1457576	2025-09-13	England	FA Cup	Buxton	Redditch United	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.423625	\N	\N	0	0	draw	yes
4397	1457562	2025-09-13	England	FA Cup	Farnborough	Dover	h-win	4	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.430915	\N	\N	2	1	h-win	yes
4398	1457547	2025-09-13	England	FA Cup	Gosport Borough	Poole Town	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.440633	\N	\N	0	1	a-win	yes
4399	1457548	2025-09-13	England	FA Cup	Leiston	Hackney Wick	h-win	4	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.447877	\N	\N	4	0	h-win	yes
4400	1457532	2025-09-13	England	FA Cup	Matlock Town	Carlton Town	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.458533	\N	\N	1	0	h-win	yes
4401	1457593	2025-09-13	England	FA Cup	Merthyr Town	Torpoint Athletic	h-win	4	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.465844	\N	\N	1	0	h-win	yes
4402	1457519	2025-09-13	England	FA Cup	Morpeth Town	Witton Albion	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.476222	\N	\N	1	1	draw	yes
4403	1457529	2025-09-13	England	FA Cup	Needham Market	Eynesbury Rovers	h-win	4	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.483521	\N	\N	3	0	h-win	yes
4404	1457575	2025-09-13	England	FA Cup	Peterborough Sports	AFC Hornchurch	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.493208	\N	\N	1	0	h-win	yes
4405	1468207	2025-09-13	England	FA Cup	Radcliffe	Southport	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.50055	\N	\N	0	0	draw	yes
4406	1457545	2025-09-13	England	FA Cup	Royston Town	Brentwood Town	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.510282	\N	\N	0	0	draw	yes
4407	1457538	2025-09-13	England	FA Cup	Salisbury	Laverstock & Ford	h-win	4	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.520199	\N	\N	4	0	h-win	yes
4408	1457559	2025-09-13	England	FA Cup	South Shields	Guiseley AFC	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.52787	\N	\N	1	0	h-win	yes
4409	1457522	2025-09-13	England	FA Cup	Stalybridge Celtic	Chester	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.537362	\N	\N	0	0	draw	yes
4410	1457587	2025-09-13	England	FA Cup	United of Manchester	Chadderton	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.544952	\N	\N	0	0	draw	yes
4411	1457580	2025-09-13	England	FA Cup	Wimborne Town	Bath City	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.554072	\N	\N	2	0	h-win	yes
4412	1457558	2025-09-13	England	FA Cup	Gloucester City	Chippenham Town	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.561786	\N	\N	0	1	a-win	yes
4413	1457560	2025-09-13	England	FA Cup	Dorking Wanderers	Wingate & Finchley	h-win	7	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.570884	\N	\N	3	1	h-win	yes
4414	1457525	2025-09-13	England	FA Cup	Hemel Hempstead Town	Bishop's Stortford	h-win	4	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.57855	\N	\N	2	0	h-win	yes
4415	1457550	2025-09-13	England	FA Cup	Hungerford Town	Swindon Supermarine	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.587593	\N	\N	1	0	h-win	yes
4416	1457552	2025-09-13	England	FA Cup	Welling United	Slough Town	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.59512	\N	\N	0	1	a-win	yes
4417	1457570	2025-09-13	England	FA Cup	Bootle	Darlington 1883	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.605257	\N	\N	0	1	a-win	yes
4418	1457557	2025-09-13	England	FA Cup	Congleton Town	Chorley	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.612769	\N	\N	0	0	draw	yes
4419	1457565	2025-09-13	England	FA Cup	Deal Town	Egham Town	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.623773	\N	\N	1	1	draw	yes
4420	1457541	2025-09-13	England	FA Cup	Enfield 1893	Enfield Town	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.631106	\N	\N	0	2	a-win	yes
4421	1457579	2025-09-13	England	FA Cup	Fareham Town	Sholing	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.641224	\N	\N	0	0	draw	yes
4422	1457568	2025-09-13	England	FA Cup	Grimsby Borough	Halesowen Town	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.650901	\N	\N	1	1	draw	yes
4423	1457567	2025-09-13	England	FA Cup	Harborough Town	Worksop Town	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.658364	\N	\N	2	1	h-win	yes
4424	1468206	2025-09-13	England	FA Cup	Mulbarton Wanderers	Witham Town	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.666919	\N	\N	0	0	draw	yes
4425	1457588	2025-09-13	England	FA Cup	Quorn	Kettering Town	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.674518	\N	\N	1	0	h-win	yes
4426	1457561	2025-09-13	England	FA Cup	Racing Club Warwick	Evesham United	draw	3	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.683301	\N	\N	3	1	h-win	yes
4427	1457589	2025-09-13	England	FA Cup	Shaftesbury Town	Frome Town	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.691428	\N	\N	1	0	h-win	yes
4428	1457536	2025-09-13	England	FA Cup	Shepshed Dynamo	Stamford	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.699113	\N	\N	0	0	draw	yes
4429	1457551	2025-09-13	England	FA Cup	Steyning Town	Tonbridge Angels	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.709023	\N	\N	0	1	a-win	yes
4430	1457578	2025-09-13	England	FA Cup	Tower Hamlets	Flackwell Heath	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.71644	\N	\N	0	0	draw	yes
4431	1457533	2025-09-13	England	FA Cup	West Auckland Town	Spennymoor Town	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.726565	\N	\N	0	1	a-win	yes
4432	1457591	2025-09-13	England	FA Cup	Westbury United	Oxford City	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.73646	\N	\N	2	1	h-win	yes
4433	1457571	2025-09-13	England	FA Cup	Brixham	Dorchester Town	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.744219	\N	\N	1	2	a-win	yes
4434	1457556	2025-09-13	England	FA Cup	Jersey Bulls	Worthing	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.753539	\N	\N	1	0	h-win	yes
4435	1457546	2025-09-13	England	FA Cup	Newcastle Blue Star	Marine	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.761104	\N	\N	0	0	draw	yes
4436	1469174	2025-09-16	England	FA Cup	Dagenham & Redbridge	Bedford Town	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.770435	\N	\N	1	0	h-win	yes
4437	1469173	2025-09-16	England	FA Cup	Southport	Radcliffe	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.778202	\N	\N	1	1	draw	yes
4438	1469177	2025-09-16	England	FA Cup	Slough Town	Welling United	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.787576	\N	\N	0	0	draw	yes
4439	1469175	2025-09-16	England	FA Cup	Weston-super-Mare	Taunton Town	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.79523	\N	\N	1	0	h-win	yes
4440	1469184	2025-09-16	England	FA Cup	Witham Town	Mulbarton Wanderers	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.805226	\N	\N	1	0	h-win	yes
4441	1469182	2025-09-16	England	FA Cup	Chichester City	Whitstable Town	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.812691	\N	\N	0	0	draw	yes
4442	1469183	2025-09-16	England	FA Cup	Evesham United	Racing Club Warwick	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.822127	\N	\N	0	0	draw	yes
4443	1469181	2025-09-16	England	FA Cup	Halesowen Town	Grimsby Borough	h-win	6	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.829704	\N	\N	3	1	h-win	yes
4444	1469180	2025-09-16	England	FA Cup	Banbury United	Chasetown	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.839068	\N	\N	1	1	draw	yes
4445	1469178	2025-09-16	England	FA Cup	Horsham	Westfield (Surrey)	h-win	6	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.846567	\N	\N	2	0	h-win	yes
4446	1469176	2025-09-16	England	FA Cup	Worthing	Jersey Bulls	h-win	5	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.857021	\N	\N	1	0	h-win	yes
4447	1469179	2025-09-16	England	FA Cup	Tonbridge Angels	Steyning Town	h-win	6	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.86443	\N	\N	3	0	h-win	yes
4448	1469185	2025-09-17	England	FA Cup	Frome Town	Shaftesbury Town	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.874848	\N	\N	1	1	draw	yes
4451	1470072	2025-09-27	England	FA Cup	Westbury United	Farnborough	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.901057	\N	\N	0	0	draw	yes
4452	1470085	2025-09-27	England	FA Cup	Macclesfield	Nantwich Town	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.90988	\N	\N	0	0	draw	yes
4453	1470076	2025-09-27	England	FA Cup	Chester	Curzon Ashton	h-win	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.917934	\N	\N	2	0	h-win	yes
4454	1470094	2025-09-27	England	FA Cup	AFC Fylde	Darlington 1883	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.926685	\N	\N	0	0	draw	yes
4455	1470079	2025-09-27	England	FA Cup	Ebbsfleet United	Faversham Town	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.936408	\N	\N	2	1	h-win	yes
4456	1471200	2025-09-27	England	FA Cup	AFC Telford United	Evesham United	h-win	4	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.94402	\N	\N	1	1	draw	yes
4457	1470084	2025-09-27	England	FA Cup	Hyde United	Matlock Town	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.954434	\N	\N	0	0	draw	yes
4458	1470087	2025-09-27	England	FA Cup	Spennymoor Town	Chadderton	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.961951	\N	\N	0	0	draw	yes
4459	1471203	2025-09-27	England	FA Cup	Bedfont Sports	Slough Town	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.972158	\N	\N	1	1	draw	yes
4460	1470088	2025-09-27	England	FA Cup	Sutton Coldfield Town	Stamford	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.979723	\N	\N	0	0	draw	yes
4461	1470074	2025-09-27	England	FA Cup	Waltham Abbey	Maldon & Tiptree	a-win	2	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.991364	\N	\N	0	2	a-win	yes
4462	1471201	2025-09-27	England	FA Cup	AFC Totton	Frome Town	h-win	4	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:12.999618	\N	\N	2	0	h-win	yes
4463	1471206	2025-09-27	England	FA Cup	Cray Valley PM	Tonbridge Angels	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.009609	\N	\N	0	0	draw	yes
4464	1470075	2025-09-27	England	FA Cup	Dunston UTS	Gainsborough Trinity	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.018638	\N	\N	0	1	a-win	yes
4465	1471207	2025-09-27	England	FA Cup	Halesowen Town	Aveley	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.026228	\N	\N	0	0	draw	yes
4466	1470086	2025-09-27	England	FA Cup	Marine	Buxton	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.036723	\N	\N	0	1	a-win	yes
4467	1470093	2025-09-27	England	FA Cup	Runcorn Linnets	Ashton United	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.044853	\N	\N	1	0	h-win	yes
4468	1470082	2025-09-27	England	FA Cup	Sholing	Eastbourne Borough	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.05496	\N	\N	1	1	draw	yes
4469	1471198	2025-09-27	England	FA Cup	Spalding United	Dagenham & Redbridge	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.062396	\N	\N	2	1	h-win	yes
4470	1471208	2025-09-27	England	FA Cup	Whitstable Town	Hungerford Town	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.071539	\N	\N	1	0	h-win	yes
4471	1470080	2025-09-27	England	FA Cup	Alvechurch	Chelmsford City	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.079154	\N	\N	1	2	a-win	yes
4472	1470077	2025-09-27	England	FA Cup	Enfield Town	Quorn	h-win	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.088988	\N	\N	2	0	h-win	yes
4473	1470089	2025-09-27	England	FA Cup	Hednesford Town	Billericay Town	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.096264	\N	\N	0	0	draw	yes
4474	1471202	2025-09-27	England	FA Cup	Horsham	Folkestone Invicta	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.106732	\N	\N	2	1	h-win	yes
4475	1471209	2025-09-27	England	FA Cup	Leiston	Banbury United	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.113986	\N	\N	0	2	a-win	yes
4476	1469915	2025-09-27	England	FA Cup	Merthyr Town	Hampton & Richmond	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.124383	\N	\N	0	0	draw	yes
4477	1471205	2025-09-27	England	FA Cup	Morpeth Town	Southport	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.132469	\N	\N	0	2	a-win	yes
4478	1471197	2025-09-27	England	FA Cup	Needham Market	Witham Town	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.142928	\N	\N	1	1	draw	yes
4479	1471196	2025-09-27	England	FA Cup	Poole Town	Weston-super-Mare	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.151165	\N	\N	0	2	a-win	yes
4480	1470078	2025-09-27	England	FA Cup	Royston Town	King's Lynn Town	a-win	1	5	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.160143	\N	\N	0	3	a-win	yes
4481	1470090	2025-09-27	England	FA Cup	Salisbury	Dorking Wanderers	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.170826	\N	\N	0	1	a-win	yes
4482	1469916	2025-09-27	England	FA Cup	South Shields	Chorley	h-win	4	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.178423	\N	\N	2	0	h-win	yes
4483	1471199	2025-09-27	England	FA Cup	Wimborne Town	Worthing	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.1886	\N	\N	0	1	a-win	yes
4484	1477513	2025-09-27	England	FA Cup	Hemel Hempstead Town	Hereford	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.195889	\N	\N	1	0	h-win	yes
4485	1470091	2025-09-27	England	FA Cup	Chatham Town	Deal Town	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.206546	\N	\N	3	1	h-win	yes
4486	1470092	2025-09-27	England	FA Cup	Farnham Town	Dorchester Town	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.213603	\N	\N	0	0	draw	yes
4487	1470073	2025-09-27	England	FA Cup	Flackwell Heath	Bracknell Town	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.224144	\N	\N	0	0	draw	yes
4488	1470083	2025-09-27	England	FA Cup	Harborough Town	Peterborough Sports	h-win	4	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.231467	\N	\N	1	0	h-win	yes
4489	1470081	2025-09-27	England	FA Cup	Walton & Hersham	Chippenham Town	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.241759	\N	\N	0	1	a-win	yes
4490	1471204	2025-09-27	England	FA Cup	Woodford Town	St Albans City	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.249171	\N	\N	0	1	a-win	yes
4491	1477637	2025-09-29	England	FA Cup	Aveley	Halesowen Town	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.258975	\N	\N	1	0	h-win	yes
4492	1477641	2025-09-30	England	FA Cup	Billericay Town	Hednesford Town	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.272316	\N	\N	1	0	h-win	yes
4493	1477640	2025-09-30	England	FA Cup	Hereford	Hemel Hempstead Town	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.279897	\N	\N	0	0	draw	yes
4494	1477644	2025-09-30	England	FA Cup	Bracknell Town	Flackwell Heath	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.290207	\N	\N	0	0	draw	yes
4495	1477643	2025-09-30	England	FA Cup	Ashton United	Runcorn Linnets	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.297397	\N	\N	1	2	a-win	yes
4496	1477639	2025-09-30	England	FA Cup	Dorking Wanderers	Salisbury	h-win	4	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.30718	\N	\N	2	0	h-win	yes
4497	1477642	2025-09-30	England	FA Cup	Tonbridge Angels	Cray Valley PM	h-win	5	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.315058	\N	\N	4	0	h-win	yes
4498	1477638	2025-09-30	England	FA Cup	Darlington 1883	AFC Fylde	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.325743	\N	\N	2	0	h-win	yes
4499	1478188	2025-10-11	England	FA Cup	Farnham Town	Sutton Utd	draw	3	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.332796	\N	\N	1	1	draw	yes
4500	1478193	2025-10-11	England	FA Cup	Rochdale	York	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.343306	\N	\N	0	0	draw	yes
4501	1478194	2025-10-11	England	FA Cup	Scunthorpe	King's Lynn Town	h-win	4	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.351073	\N	\N	0	2	a-win	yes
4502	1478196	2025-10-11	England	FA Cup	Southend	Folkestone Invicta	h-win	4	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.359793	\N	\N	3	0	h-win	yes
4503	1478184	2025-10-11	England	FA Cup	Carlisle	Boston United	h-win	5	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.367252	\N	\N	3	0	h-win	yes
4504	1478192	2025-10-11	England	FA Cup	Morecambe	Chester	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.376466	\N	\N	1	0	h-win	yes
4505	1478191	2025-10-11	England	FA Cup	Macclesfield	Stamford	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.384162	\N	\N	1	0	h-win	yes
4506	1478197	2025-10-11	England	FA Cup	Southport	FC Halifax Town	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.393054	\N	\N	1	2	a-win	yes
4507	1478183	2025-10-11	England	FA Cup	Braintree	Farnborough	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.4038	\N	\N	2	0	h-win	yes
4508	1478202	2025-10-11	England	FA Cup	Woking	Brackley Town	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.411309	\N	\N	0	1	a-win	yes
4509	1478187	2025-10-11	England	FA Cup	Ebbsfleet United	Solihull Moors	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.420582	\N	\N	1	0	h-win	yes
4510	1478190	2025-10-11	England	FA Cup	Hampton & Richmond	Eastleigh	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.428172	\N	\N	0	2	a-win	yes
4511	1478195	2025-10-11	England	FA Cup	Slough Town	Enfield Town	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.437107	\N	\N	1	2	a-win	yes
4512	1478201	2025-10-11	England	FA Cup	Weston-super-Mare	Needham Market	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.444599	\N	\N	0	0	draw	yes
4513	1478185	2025-10-11	England	FA Cup	Chelmsford City	Chippenham Town	h-win	4	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.454292	\N	\N	3	1	h-win	yes
4514	1478189	2025-10-11	England	FA Cup	Gainsborough Trinity	Hartlepool	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.461758	\N	\N	1	0	h-win	yes
4515	1478180	2025-10-11	England	FA Cup	Altrincham	Harborough Town	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.471635	\N	\N	1	0	h-win	yes
4516	1478186	2025-10-11	England	FA Cup	Eastbourne Borough	Boreham Wood	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.479023	\N	\N	0	0	draw	yes
4517	1479217	2025-10-11	England	FA Cup	Spennymoor Town	Billericay Town	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.48876	\N	\N	0	0	draw	yes
4518	1478181	2025-10-11	England	FA Cup	Aveley	Gateshead	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.496223	\N	\N	0	1	a-win	yes
4519	1478179	2025-10-11	England	FA Cup	AFC Totton	Truro City	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.507114	\N	\N	1	0	h-win	yes
4520	1479215	2025-10-11	England	FA Cup	Maldon & Tiptree	Flackwell Heath	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.514327	\N	\N	1	0	h-win	yes
4521	1479216	2025-10-11	England	FA Cup	Runcorn Linnets	Buxton	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.52453	\N	\N	0	0	draw	yes
4522	1478182	2025-10-11	England	FA Cup	Banbury United	St Albans City	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.531549	\N	\N	1	1	draw	yes
4523	1478198	2025-10-11	England	FA Cup	South Shields	Spalding United	h-win	4	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.539957	\N	\N	3	0	h-win	yes
4524	1478199	2025-10-11	England	FA Cup	Tamworth	Hyde United	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.546361	\N	\N	0	0	draw	yes
4525	1479213	2025-10-11	England	FA Cup	Dorking Wanderers	Aldershot Town	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.555911	\N	\N	1	2	a-win	yes
4526	1479214	2025-10-11	England	FA Cup	Hemel Hempstead Town	Yeovil Town	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.563189	\N	\N	1	0	h-win	yes
4527	1479218	2025-10-11	England	FA Cup	Tonbridge Angels	Chatham Town	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.573934	\N	\N	1	0	h-win	yes
4528	1478200	2025-10-11	England	FA Cup	Wealdstone	Whitstable Town	h-win	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.581248	\N	\N	5	0	h-win	yes
4529	1479212	2025-10-11	England	FA Cup	Darlington 1883	AFC Telford United	a-win	0	6	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.591574	\N	\N	0	4	a-win	yes
4530	1478203	2025-10-13	England	FA Cup	Worthing	Forest Green	a-win	1	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.598903	\N	\N	1	2	a-win	yes
4531	1481505	2025-10-14	England	FA Cup	Hartlepool	Gainsborough Trinity	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.608974	\N	\N	0	2	a-win	yes
4532	1481503	2025-10-14	England	FA Cup	Chester	Morecambe	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.616219	\N	\N	0	0	draw	yes
4533	1481507	2025-10-14	England	FA Cup	Sutton Utd	Farnham Town	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.626799	\N	\N	0	1	a-win	yes
4534	1481508	2025-10-14	England	FA Cup	Truro City	AFC Totton	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.636673	\N	\N	0	1	a-win	yes
4535	1481502	2025-10-14	England	FA Cup	Brackley Town	Woking	h-win	6	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.644274	\N	\N	2	2	draw	yes
4536	1481506	2025-10-14	England	FA Cup	St Albans City	Banbury United	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.653935	\N	\N	0	0	draw	yes
4537	1481504	2025-10-14	England	FA Cup	Harborough Town	Altrincham	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.661972	\N	\N	0	0	draw	yes
4538	1481721	2025-10-31	England	FA Cup	Luton	Forest Green	h-win	4	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.671343	\N	\N	2	0	h-win	yes
4539	1481713	2025-11-01	England	FA Cup	Chelmsford City	Braintree	h-win	4	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.678732	\N	\N	3	1	h-win	yes
4540	1481727	2025-11-01	England	FA Cup	Reading	Carlisle	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.689929	\N	\N	1	0	h-win	yes
4541	1481737	2025-11-01	England	FA Cup	Wigan	Hemel Hempstead Town	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.697192	\N	\N	1	0	h-win	yes
4542	1481709	2025-11-01	England	FA Cup	Bolton	Huddersfield	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.707302	\N	\N	1	0	h-win	yes
4543	1481728	2025-11-01	England	FA Cup	Rotherham	Swindon Town	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.716407	\N	\N	1	0	h-win	yes
4544	1481707	2025-11-01	England	FA Cup	Barnsley	York	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.724848	\N	\N	1	1	draw	yes
4545	1481794	2025-11-01	England	FA Cup	Burton Albion	St Albans City	h-win	6	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.733526	\N	\N	1	0	h-win	yes
4546	1481706	2025-11-01	England	FA Cup	AFC Wimbledon	Gateshead	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.741621	\N	\N	0	1	a-win	yes
4547	1481719	2025-11-01	England	FA Cup	Fleetwood Town	Barnet	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.74893	\N	\N	1	0	h-win	yes
4548	1481724	2025-11-01	England	FA Cup	Oldham	Northampton	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.759297	\N	\N	2	0	h-win	yes
4549	1481725	2025-11-01	England	FA Cup	Peterborough	Cardiff	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.766624	\N	\N	1	0	h-win	yes
4550	1481708	2025-11-01	England	FA Cup	Blackpool	Scunthorpe	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.776099	\N	\N	1	0	h-win	yes
4551	1481738	2025-11-01	England	FA Cup	Wycombe	Plymouth	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.786872	\N	\N	0	0	draw	yes
4552	1481715	2025-11-01	England	FA Cup	Colchester	Milton Keynes Dons	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.794437	\N	\N	1	1	draw	yes
4553	1481716	2025-11-01	England	FA Cup	Crewe	Doncaster	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.804451	\N	\N	1	0	h-win	yes
4554	1481720	2025-11-01	England	FA Cup	Grimsby	Ebbsfleet United	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.812078	\N	\N	0	1	a-win	yes
4555	1481723	2025-11-01	England	FA Cup	Newport County	Gillingham	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.82099	\N	\N	1	1	draw	yes
4556	1481732	2025-11-01	England	FA Cup	Stevenage	Chesterfield	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.828355	\N	\N	0	0	draw	yes
4557	1481795	2025-11-01	England	FA Cup	Cambridge United	Chester	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.838657	\N	\N	3	0	h-win	yes
4558	1481714	2025-11-01	England	FA Cup	Cheltenham	Bradford	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.846771	\N	\N	1	0	h-win	yes
4559	1481722	2025-11-01	England	FA Cup	Mansfield Town	Harrogate Town	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.857109	\N	\N	1	0	h-win	yes
4560	1481797	2025-11-01	England	FA Cup	Macclesfield	AFC Totton	h-win	6	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.864452	\N	\N	3	3	draw	yes
4561	1481734	2025-11-01	England	FA Cup	Tranmere	Stockport County	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.874418	\N	\N	0	0	draw	yes
4562	1481710	2025-11-01	England	FA Cup	Boreham Wood	Crawley Town	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.880975	\N	\N	2	0	h-win	yes
4563	1481711	2025-11-01	England	FA Cup	Bromley	Bristol Rovers	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.890301	\N	\N	0	0	draw	yes
4564	1481799	2025-11-01	England	FA Cup	Sutton Utd	AFC Telford United	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.897479	\N	\N	1	0	h-win	yes
4565	1481718	2025-11-01	England	FA Cup	FC Halifax Town	Exeter City	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.908395	\N	\N	0	2	a-win	yes
4566	1481729	2025-11-01	England	FA Cup	Salford City	Lincoln	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.915479	\N	\N	0	1	a-win	yes
4567	1481798	2025-11-01	England	FA Cup	Slough Town	Altrincham	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.926075	\N	\N	2	0	h-win	yes
4568	1481736	2025-11-01	England	FA Cup	Weston-super-Mare	Aldershot Town	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.933308	\N	\N	0	1	a-win	yes
4569	1481731	2025-11-01	England	FA Cup	Spennymoor Town	Barrow	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.943394	\N	\N	0	1	a-win	yes
4572	1481793	2025-11-01	England	FA Cup	Brackley Town	Notts County	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.971002	\N	\N	1	1	draw	yes
4573	1481730	2025-11-02	England	FA Cup	South Shields	Shrewsbury	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.97863	\N	\N	0	3	a-win	yes
4574	1481717	2025-11-02	England	FA Cup	Eastleigh	Walsall	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.988083	\N	\N	0	1	a-win	yes
4575	1481726	2025-11-02	England	FA Cup	Port Vale	Maldon & Tiptree	h-win	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:13.995465	\N	\N	4	1	h-win	yes
4576	1481796	2025-11-02	England	FA Cup	Gainsborough Trinity	Accrington ST	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:14.004556	\N	\N	0	1	a-win	yes
4577	1481733	2025-11-03	England	FA Cup	Tamworth	Leyton Orient	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 19:17:14.011907	\N	\N	0	0	draw	yes
4578	1399404	2025-08-09	England	National League	Yeovil Town	Hartlepool	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:39.455153	\N	\N	0	0	draw	yes
4579	1399407	2025-08-09	England	National League	Gateshead	Southend	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:39.633187	\N	\N	0	1	a-win	yes
4580	1399409	2025-08-09	England	National League	York	Sutton Utd	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:39.802102	\N	\N	1	1	draw	yes
4581	1399405	2025-08-09	England	National League	Boreham Wood	Rochdale	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:39.992333	\N	\N	0	0	draw	yes
4582	1399406	2025-08-09	England	National League	Braintree	FC Halifax Town	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:40.143308	\N	\N	2	0	h-win	yes
4583	1399401	2025-08-09	England	National League	Solihull Moors	Forest Green	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:40.305848	\N	\N	1	0	h-win	yes
4584	1399403	2025-08-09	England	National League	Woking	Carlisle	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:40.494857	\N	\N	0	0	draw	yes
4585	1399398	2025-08-09	England	National League	Altrincham	Aldershot Town	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:40.691755	\N	\N	2	0	h-win	yes
4586	1399400	2025-08-09	England	National League	Brackley Town	Eastleigh	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:40.872501	\N	\N	1	0	h-win	yes
4587	1399402	2025-08-09	England	National League	Tamworth	Scunthorpe	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:41.060472	\N	\N	1	2	a-win	yes
4588	1399408	2025-08-09	England	National League	Wealdstone	Truro City	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:41.22513	\N	\N	1	0	h-win	yes
4589	1399417	2025-08-16	England	National League	Rochdale	Altrincham	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:41.413383	\N	\N	1	1	draw	yes
4590	1399418	2025-08-16	England	National League	Scunthorpe	Woking	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:41.591615	\N	\N	2	0	h-win	yes
4591	1399419	2025-08-16	England	National League	Southend	Tamworth	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:41.770699	\N	\N	1	0	h-win	yes
4592	1399415	2025-08-16	England	National League	Hartlepool	Braintree	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:41.974534	\N	\N	1	0	h-win	yes
4593	1399411	2025-08-16	England	National League	Carlisle	Boreham Wood	draw	3	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:42.151544	\N	\N	0	1	a-win	yes
4594	1399414	2025-08-16	England	National League	Forest Green	Yeovil Town	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:42.345067	\N	\N	0	0	draw	yes
4595	1399410	2025-08-16	England	National League	Aldershot Town	Boston United	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:42.536508	\N	\N	0	1	a-win	yes
4596	1399412	2025-08-16	England	National League	Eastleigh	Gateshead	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:42.75823	\N	\N	0	2	a-win	yes
4597	1399420	2025-08-16	England	National League	Sutton Utd	Solihull Moors	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:42.9809	\N	\N	0	0	draw	yes
4598	1399413	2025-08-16	England	National League	Wealdstone	FC Halifax Town	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:43.175283	\N	\N	1	1	draw	yes
4599	1399421	2025-08-16	England	National League	Truro City	York	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:43.393402	\N	\N	0	0	draw	yes
4600	1399424	2025-08-19	England	National League	Carlisle	Solihull Moors	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:43.575473	\N	\N	0	0	draw	yes
4601	1399427	2025-08-19	England	National League	Woking	Wealdstone	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:43.76388	\N	\N	0	1	a-win	yes
4602	1399422	2025-08-19	England	National League	Altrincham	Hartlepool	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:43.928945	\N	\N	0	2	a-win	yes
4603	1399426	2025-08-19	England	National League	Tamworth	Truro City	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:44.096664	\N	\N	2	0	h-win	yes
4604	1399423	2025-08-19	England	National League	Boston United	FC Halifax Town	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:44.257646	\N	\N	0	1	a-win	yes
4605	1399431	2025-08-20	England	National League	Rochdale	Gateshead	h-win	4	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:44.412186	\N	\N	2	0	h-win	yes
4606	1399432	2025-08-20	England	National League	Southend	York	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:44.585726	\N	\N	0	0	draw	yes
4607	1399433	2025-08-20	England	National League	Yeovil Town	Brackley Town	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:44.788304	\N	\N	1	0	h-win	yes
4608	1399430	2025-08-20	England	National League	Forest Green	Sutton Utd	h-win	4	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:44.975851	\N	\N	2	0	h-win	yes
4609	1399428	2025-08-20	England	National League	Aldershot Town	Eastleigh	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:45.168547	\N	\N	0	1	a-win	yes
4610	1399429	2025-08-20	England	National League	Boreham Wood	Braintree	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:45.37072	\N	\N	1	1	draw	yes
4611	1399440	2025-08-23	England	National League	Morecambe	Altrincham	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:45.573485	\N	\N	1	1	draw	yes
4612	1399439	2025-08-23	England	National League	Hartlepool	Woking	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:45.740227	\N	\N	2	0	h-win	yes
4613	1399436	2025-08-23	England	National League	Eastleigh	Boston United	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:45.891988	\N	\N	0	0	draw	yes
4614	1399438	2025-08-23	England	National League	Gateshead	Tamworth	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:46.052908	\N	\N	1	0	h-win	yes
4615	1399435	2025-08-23	England	National League	Braintree	Yeovil Town	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:46.235366	\N	\N	0	0	draw	yes
4616	1399441	2025-08-23	England	National League	Solihull Moors	Aldershot Town	a-win	1	5	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:46.425568	\N	\N	0	2	a-win	yes
4617	1399442	2025-08-23	England	National League	Sutton Utd	Scunthorpe	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:46.609433	\N	\N	1	1	draw	yes
4618	1399437	2025-08-23	England	National League	FC Halifax Town	Forest Green	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:46.770253	\N	\N	1	1	draw	yes
4619	1399443	2025-08-23	England	National League	Truro City	Southend	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:46.934812	\N	\N	0	0	draw	yes
4620	1399434	2025-08-23	England	National League	Brackley Town	Rochdale	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:47.091425	\N	\N	1	0	h-win	yes
4621	1399444	2025-08-23	England	National League	Wealdstone	Carlisle	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:47.265957	\N	\N	0	1	a-win	yes
4622	1399451	2025-08-25	England	National League	Rochdale	Sutton Utd	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:47.449698	\N	\N	0	0	draw	yes
4623	1399452	2025-08-25	England	National League	Scunthorpe	FC Halifax Town	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:47.626117	\N	\N	0	0	draw	yes
4624	1399453	2025-08-25	England	National League	Southend	Hartlepool	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:47.878529	\N	\N	1	0	h-win	yes
4625	1399449	2025-08-25	England	National League	Carlisle	Braintree	h-win	5	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:48.058361	\N	\N	2	0	h-win	yes
4626	1399456	2025-08-25	England	National League	Yeovil Town	Gateshead	a-win	3	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:48.268423	\N	\N	3	0	h-win	yes
4627	1399450	2025-08-25	England	National League	Forest Green	Eastleigh	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:48.461537	\N	\N	0	0	draw	yes
4628	1399445	2025-08-25	England	National League	Aldershot Town	Morecambe	h-win	4	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:48.653373	\N	\N	0	0	draw	yes
4629	1399447	2025-08-25	England	National League	Boreham Wood	Truro City	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:48.810885	\N	\N	1	1	draw	yes
4630	1399455	2025-08-25	England	National League	Woking	York	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:48.977829	\N	\N	1	0	h-win	yes
4631	1399446	2025-08-25	England	National League	Altrincham	Solihull Moors	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:49.144232	\N	\N	1	0	h-win	yes
4632	1399454	2025-08-25	England	National League	Tamworth	Brackley Town	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:49.321106	\N	\N	1	0	h-win	yes
4633	1399448	2025-08-25	England	National League	Boston United	Wealdstone	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:49.479797	\N	\N	0	0	draw	yes
4634	1399464	2025-08-30	England	National League	Solihull Moors	Southend	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:49.644724	\N	\N	0	1	a-win	yes
4635	1399462	2025-08-30	England	National League	Hartlepool	Boreham Wood	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:49.843822	\N	\N	0	0	draw	yes
4636	1399463	2025-08-30	England	National League	Morecambe	Woking	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:50.014248	\N	\N	0	0	draw	yes
4637	1399459	2025-08-30	England	National League	Eastleigh	Altrincham	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:50.215541	\N	\N	0	1	a-win	yes
4638	1399461	2025-08-30	England	National League	Gateshead	Aldershot Town	draw	3	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:50.385567	\N	\N	1	2	a-win	yes
4639	1399458	2025-08-30	England	National League	Braintree	Forest Green	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:50.577802	\N	\N	0	0	draw	yes
4640	1399465	2025-08-30	England	National League	Sutton Utd	Carlisle	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:50.749612	\N	\N	0	0	draw	yes
4641	1399460	2025-08-30	England	National League	FC Halifax Town	Yeovil Town	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:50.917075	\N	\N	1	0	h-win	yes
4642	1399466	2025-08-30	England	National League	Truro City	Boston United	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:51.113906	\N	\N	1	0	h-win	yes
4643	1399467	2025-08-30	England	National League	Wealdstone	Rochdale	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:51.335493	\N	\N	0	2	a-win	yes
4644	1399457	2025-08-30	England	National League	Brackley Town	Scunthorpe	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:51.494356	\N	\N	0	0	draw	yes
4645	1399470	2025-09-02	England	National League	Morecambe	Forest Green	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:51.66898	\N	\N	1	2	a-win	yes
4646	1399468	2025-09-02	England	National League	Braintree	Tamworth	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:51.841961	\N	\N	0	1	a-win	yes
4647	1399471	2025-09-02	England	National League	Solihull Moors	Yeovil Town	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:52.012029	\N	\N	0	1	a-win	yes
4648	1399472	2025-09-02	England	National League	Wealdstone	Southend	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:52.194516	\N	\N	1	1	draw	yes
4649	1399477	2025-09-03	England	National League	Hartlepool	Boston United	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:52.364489	\N	\N	1	0	h-win	yes
4650	1399476	2025-09-03	England	National League	Gateshead	Altrincham	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:52.535148	\N	\N	0	2	a-win	yes
4651	1399478	2025-09-03	England	National League	Sutton Utd	Boreham Wood	a-win	3	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:52.703991	\N	\N	2	1	h-win	yes
4652	1399475	2025-09-03	England	National League	FC Halifax Town	Woking	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:52.881409	\N	\N	0	0	draw	yes
4653	1399479	2025-09-03	England	National League	Truro City	Aldershot Town	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:53.05576	\N	\N	0	1	a-win	yes
4654	1399474	2025-09-03	England	National League	Brackley Town	Carlisle	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:53.241139	\N	\N	0	0	draw	yes
4655	1399481	2025-09-06	England	National League	Altrincham	Sutton Utd	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:53.424771	\N	\N	0	1	a-win	yes
4656	1399486	2025-09-06	England	National League	Rochdale	Braintree	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:53.625931	\N	\N	2	0	h-win	yes
4657	1399488	2025-09-06	England	National League	Southend	FC Halifax Town	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:53.818999	\N	\N	1	0	h-win	yes
4658	1399484	2025-09-06	England	National League	Carlisle	Truro City	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:53.982368	\N	\N	2	0	h-win	yes
4659	1399491	2025-09-06	England	National League	Yeovil Town	York	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:54.183027	\N	\N	0	2	a-win	yes
4660	1399485	2025-09-06	England	National League	Forest Green	Hartlepool	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:54.353248	\N	\N	1	0	h-win	yes
4661	1399482	2025-09-06	England	National League	Boreham Wood	Morecambe	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:54.555825	\N	\N	2	0	h-win	yes
4662	1399490	2025-09-06	England	National League	Woking	Gateshead	h-win	5	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:54.734415	\N	\N	2	0	h-win	yes
4663	1399489	2025-09-06	England	National League	Tamworth	Eastleigh	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:54.929095	\N	\N	0	0	draw	yes
4664	1399483	2025-09-06	England	National League	Boston United	Solihull Moors	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:55.096951	\N	\N	1	1	draw	yes
4665	1399480	2025-09-06	England	National League	Aldershot Town	Brackley Town	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:55.260323	\N	\N	1	0	h-win	yes
4666	1399492	2025-09-09	England	National League	York	Tamworth	h-win	4	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:55.425733	\N	\N	0	0	draw	yes
4667	1399504	2025-09-13	England	National League	Yeovil Town	Woking	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:55.580927	\N	\N	0	0	draw	yes
4668	1399500	2025-09-13	England	National League	Southend	Boston United	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:55.74082	\N	\N	0	0	draw	yes
4669	1399498	2025-09-13	England	National League	Hartlepool	Brackley Town	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:55.933079	\N	\N	0	0	draw	yes
4670	1399495	2025-09-13	England	National League	Carlisle	Aldershot Town	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:56.148266	\N	\N	0	0	draw	yes
4671	1399497	2025-09-13	England	National League	Forest Green	Scunthorpe	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:56.314272	\N	\N	0	1	a-win	yes
4672	1399493	2025-09-13	England	National League	Boreham Wood	Altrincham	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:56.512216	\N	\N	3	0	h-win	yes
4673	1399494	2025-09-13	England	National League	Braintree	York	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:56.710597	\N	\N	1	0	h-win	yes
4674	1399499	2025-09-13	England	National League	Solihull Moors	Morecambe	draw	4	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:56.921224	\N	\N	2	1	h-win	yes
4675	1399501	2025-09-13	England	National League	Sutton Utd	Tamworth	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:57.115166	\N	\N	2	3	a-win	yes
4676	1399502	2025-09-13	England	National League	Truro City	Rochdale	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:57.286098	\N	\N	0	1	a-win	yes
4677	1399503	2025-09-13	England	National League	Wealdstone	Gateshead	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:57.459699	\N	\N	1	1	draw	yes
4678	1399496	2025-09-13	England	National League	FC Halifax Town	Eastleigh	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:57.609856	\N	\N	0	2	a-win	yes
4679	1399508	2025-09-20	England	National League	Brackley Town	Sutton Utd	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:57.769449	\N	\N	0	0	draw	yes
4680	1399513	2025-09-20	England	National League	Scunthorpe	Truro City	h-win	4	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:57.940031	\N	\N	1	0	h-win	yes
4681	1399511	2025-09-20	England	National League	Morecambe	Wealdstone	h-win	4	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:58.127857	\N	\N	3	1	h-win	yes
4682	1399505	2025-09-20	England	National League	Aldershot Town	Hartlepool	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:58.294698	\N	\N	1	0	h-win	yes
4683	1399509	2025-09-20	England	National League	Eastleigh	Braintree	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:58.484439	\N	\N	1	1	draw	yes
4684	1399510	2025-09-20	England	National League	Gateshead	FC Halifax Town	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:58.645232	\N	\N	1	1	draw	yes
4685	1399516	2025-09-20	England	National League	York	Solihull Moors	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:58.821192	\N	\N	0	0	draw	yes
4686	1399515	2025-09-20	England	National League	Woking	Forest Green	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:58.992749	\N	\N	0	1	a-win	yes
4687	1399506	2025-09-20	England	National League	Altrincham	Carlisle	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:59.152567	\N	\N	1	2	a-win	yes
4688	1399514	2025-09-20	England	National League	Tamworth	Yeovil Town	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:59.34306	\N	\N	0	0	draw	yes
4689	1399507	2025-09-20	England	National League	Boston United	Boreham Wood	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:59.534276	\N	\N	0	0	draw	yes
4690	1399520	2025-09-23	England	National League	Rochdale	Solihull Moors	h-win	4	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:59.714069	\N	\N	3	0	h-win	yes
4691	1399519	2025-09-23	England	National League	Gateshead	Hartlepool	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:07:59.906942	\N	\N	0	0	draw	yes
4692	1399522	2025-09-23	England	National League	York	Carlisle	h-win	5	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:00.06299	\N	\N	3	0	h-win	yes
4693	1399521	2025-09-23	England	National League	Woking	Sutton Utd	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:00.215765	\N	\N	1	0	h-win	yes
4694	1399517	2025-09-23	England	National League	Altrincham	Forest Green	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:00.386544	\N	\N	1	1	draw	yes
4695	1399518	2025-09-23	England	National League	Brackley Town	Truro City	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:00.556528	\N	\N	1	0	h-win	yes
4696	1399527	2025-09-24	England	National League	Scunthorpe	Boreham Wood	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:00.746296	\N	\N	0	1	a-win	yes
4697	1399526	2025-09-24	England	National League	Morecambe	FC Halifax Town	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:00.954822	\N	\N	1	0	h-win	yes
4698	1399523	2025-09-24	England	National League	Aldershot Town	Yeovil Town	a-win	1	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:01.131195	\N	\N	0	3	a-win	yes
4699	1399525	2025-09-24	England	National League	Eastleigh	Southend	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:01.307552	\N	\N	0	0	draw	yes
4700	1399528	2025-09-24	England	National League	Tamworth	Wealdstone	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:01.512118	\N	\N	0	0	draw	yes
4701	1399524	2025-09-24	England	National League	Boston United	Braintree	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:01.767731	\N	\N	0	0	draw	yes
4702	1399529	2025-09-27	England	National League	Boreham Wood	Woking	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:01.98011	\N	\N	1	0	h-win	yes
4703	1399536	2025-09-27	England	National League	Southend	Scunthorpe	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:02.194794	\N	\N	0	0	draw	yes
4704	1399534	2025-09-27	England	National League	Hartlepool	Tamworth	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:02.394866	\N	\N	0	0	draw	yes
4705	1399531	2025-09-27	England	National League	Carlisle	Rochdale	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:02.577423	\N	\N	0	1	a-win	yes
4706	1399540	2025-09-27	England	National League	Yeovil Town	Altrincham	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:02.756306	\N	\N	1	0	h-win	yes
4707	1399530	2025-09-27	England	National League	Braintree	Gateshead	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:02.947171	\N	\N	0	2	a-win	yes
4708	1399535	2025-09-27	England	National League	Solihull Moors	Brackley Town	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:03.126732	\N	\N	0	0	draw	yes
4709	1399537	2025-09-27	England	National League	Sutton Utd	Boston United	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:03.314308	\N	\N	0	1	a-win	yes
4710	1399532	2025-09-27	England	National League	FC Halifax Town	Aldershot Town	h-win	4	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:03.485739	\N	\N	2	1	h-win	yes
4711	1399538	2025-09-27	England	National League	Truro City	Morecambe	h-win	5	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:03.66637	\N	\N	1	0	h-win	yes
4712	1399539	2025-09-27	England	National League	Wealdstone	Eastleigh	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:03.839549	\N	\N	0	0	draw	yes
4713	1399533	2025-09-27	England	National League	Forest Green	York	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:04.013755	\N	\N	1	1	draw	yes
4714	1399543	2025-09-30	England	National League	Morecambe	Gateshead	a-win	2	5	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:04.182359	\N	\N	1	4	a-win	yes
4715	1399541	2025-09-30	England	National League	Aldershot Town	Braintree	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:04.362405	\N	\N	0	0	draw	yes
4716	1399542	2025-09-30	England	National League	Boreham Wood	Southend	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:04.522272	\N	\N	0	0	draw	yes
4717	1399544	2025-09-30	England	National League	Solihull Moors	Woking	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:04.690848	\N	\N	0	0	draw	yes
4718	1399545	2025-09-30	England	National League	Sutton Utd	Yeovil Town	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:04.872836	\N	\N	0	0	draw	yes
4719	1399546	2025-09-30	England	National League	Truro City	Eastleigh	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:05.057024	\N	\N	0	2	a-win	yes
4720	1399551	2025-10-01	England	National League	Rochdale	FC Halifax Town	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:05.234903	\N	\N	0	1	a-win	yes
4721	1399550	2025-10-01	England	National League	Carlisle	Hartlepool	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:05.400052	\N	\N	1	0	h-win	yes
4722	1399552	2025-10-01	England	National League	York	Scunthorpe	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:05.560624	\N	\N	0	1	a-win	yes
4723	1399547	2025-10-01	England	National League	Altrincham	Tamworth	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:05.726063	\N	\N	0	0	draw	yes
4724	1399549	2025-10-01	England	National League	Brackley Town	Wealdstone	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:05.901343	\N	\N	0	1	a-win	yes
4725	1399548	2025-10-01	England	National League	Boston United	Forest Green	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.080219	\N	\N	0	0	draw	yes
4726	1399558	2025-10-04	England	National League	Hartlepool	York	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.236151	\N	\N	0	1	a-win	yes
4727	1399557	2025-10-04	England	National League	Gateshead	Boston United	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.251947	\N	\N	1	1	draw	yes
4728	1399560	2025-10-04	England	National League	Southend	Aldershot Town	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.266704	\N	\N	1	0	h-win	yes
4729	1399564	2025-10-04	England	National League	Yeovil Town	Boreham Wood	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.293766	\N	\N	0	2	a-win	yes
4730	1399556	2025-10-04	England	National League	Forest Green	Rochdale	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.310569	\N	\N	0	1	a-win	yes
4731	1399554	2025-10-04	England	National League	Eastleigh	Solihull Moors	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.323419	\N	\N	0	0	draw	yes
4732	1399553	2025-10-04	England	National League	Braintree	Sutton Utd	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.331517	\N	\N	0	0	draw	yes
4733	1399563	2025-10-04	England	National League	Woking	Truro City	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.341059	\N	\N	1	0	h-win	yes
4734	1399555	2025-10-04	England	National League	FC Halifax Town	Brackley Town	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.347208	\N	\N	0	0	draw	yes
4735	1399561	2025-10-04	England	National League	Tamworth	Morecambe	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.35635	\N	\N	0	0	draw	yes
4736	1399562	2025-10-04	England	National League	Wealdstone	Altrincham	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.362472	\N	\N	1	1	draw	yes
4737	1399559	2025-10-04	England	National League	Scunthorpe	Carlisle	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.371925	\N	\N	0	1	a-win	yes
4738	1399425	2025-10-07	England	National League	Scunthorpe	Morecambe	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.380559	\N	\N	2	0	h-win	yes
4739	1399573	2025-10-18	England	National League	Solihull Moors	Braintree	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.391312	\N	\N	1	0	h-win	yes
4740	1399572	2025-10-18	England	National League	Rochdale	Yeovil Town	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.397539	\N	\N	3	0	h-win	yes
4741	1399571	2025-10-18	England	National League	Morecambe	Southend	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.407171	\N	\N	0	2	a-win	yes
4742	1399565	2025-10-18	England	National League	Aldershot Town	Tamworth	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.413249	\N	\N	1	1	draw	yes
4744	1399567	2025-10-18	England	National League	Boreham Wood	Eastleigh	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.429308	\N	\N	0	0	draw	yes
4745	1399575	2025-10-18	England	National League	Truro City	FC Halifax Town	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.440364	\N	\N	0	0	draw	yes
4746	1399566	2025-10-18	England	National League	Altrincham	Woking	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.451342	\N	\N	1	2	a-win	yes
4747	1399569	2025-10-18	England	National League	Brackley Town	Gateshead	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.458513	\N	\N	0	0	draw	yes
4748	1399568	2025-10-18	England	National League	Boston United	Scunthorpe	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.4721	\N	\N	0	0	draw	yes
4749	1399570	2025-10-18	England	National League	Carlisle	Forest Green	h-win	4	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.479238	\N	\N	2	1	h-win	yes
4750	1399574	2025-10-18	England	National League	Sutton Utd	Hartlepool	draw	3	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.48808	\N	\N	1	0	h-win	yes
4751	1399469	2025-10-21	England	National League	Eastleigh	Scunthorpe	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.494006	\N	\N	0	0	draw	yes
4752	1399577	2025-10-21	England	National League	York	Boreham Wood	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.500031	\N	\N	1	1	draw	yes
4753	1399399	2025-10-21	England	National League	Boston United	Morecambe	a-win	0	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.508522	\N	\N	0	2	a-win	yes
4754	1399580	2025-10-25	England	National League	FC Halifax Town	York	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.525578	\N	\N	1	0	h-win	yes
4755	1399584	2025-10-25	England	National League	Scunthorpe	Aldershot Town	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.53143	\N	\N	2	1	h-win	yes
4756	1399585	2025-10-25	England	National League	Southend	Brackley Town	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.54015	\N	\N	0	0	draw	yes
4757	1399583	2025-10-25	England	National League	Hartlepool	Solihull Moors	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.546628	\N	\N	1	0	h-win	yes
4758	1399589	2025-10-25	England	National League	Yeovil Town	Carlisle	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.554718	\N	\N	1	0	h-win	yes
4759	1399581	2025-10-25	England	National League	Forest Green	Boreham Wood	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.560817	\N	\N	1	0	h-win	yes
4760	1399579	2025-10-25	England	National League	Eastleigh	Morecambe	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.569644	\N	\N	0	0	draw	yes
4761	1399582	2025-10-25	England	National League	Gateshead	Truro City	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.576123	\N	\N	0	2	a-win	yes
4762	1399578	2025-10-25	England	National League	Braintree	Altrincham	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.584581	\N	\N	0	0	draw	yes
4763	1399588	2025-10-25	England	National League	Woking	Rochdale	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.591454	\N	\N	0	0	draw	yes
4764	1399587	2025-10-25	England	National League	Wealdstone	Sutton Utd	h-win	4	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.597269	\N	\N	1	2	a-win	yes
4765	1399586	2025-10-25	England	National League	Tamworth	Boston United	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.605793	\N	\N	0	1	a-win	yes
4766	1399593	2025-11-04	England	National League	Hartlepool	Morecambe	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.614229	\N	\N	1	0	h-win	yes
4767	1399591	2025-11-04	England	National League	Carlisle	FC Halifax Town	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.62386	\N	\N	1	0	h-win	yes
4768	1399595	2025-11-04	England	National League	Yeovil Town	Wealdstone	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.631639	\N	\N	0	0	draw	yes
4769	1399590	2025-11-04	England	National League	Boreham Wood	Aldershot Town	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.642515	\N	\N	1	0	h-win	yes
4770	1399601	2025-11-05	England	National League	York	Gateshead	h-win	4	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.65063	\N	\N	3	0	h-win	yes
4771	1399597	2025-11-05	England	National League	Braintree	Brackley Town	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.662548	\N	\N	0	0	draw	yes
4772	1399598	2025-11-05	England	National League	Solihull Moors	Truro City	h-win	4	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.673599	\N	\N	2	0	h-win	yes
4773	1399599	2025-11-05	England	National League	Sutton Utd	Eastleigh	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.681797	\N	\N	2	0	h-win	yes
4774	1399600	2025-11-05	England	National League	Woking	Southend	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.69266	\N	\N	0	0	draw	yes
4775	1399596	2025-11-05	England	National League	Altrincham	Boston United	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.700681	\N	\N	1	0	h-win	yes
4776	1399602	2025-11-08	England	National League	Aldershot Town	Forest Green	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.712423	\N	\N	0	2	a-win	yes
4777	1399609	2025-11-08	England	National League	Scunthorpe	Yeovil Town	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.722971	\N	\N	1	0	h-win	yes
4778	1399608	2025-11-08	England	National League	Morecambe	Sutton Utd	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.731192	\N	\N	1	0	h-win	yes
4779	1399605	2025-11-08	England	National League	Eastleigh	York	a-win	2	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.741151	\N	\N	2	1	h-win	yes
4780	1399607	2025-11-08	England	National League	Gateshead	Solihull Moors	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.7497	\N	\N	0	0	draw	yes
4781	1399606	2025-11-08	England	National League	FC Halifax Town	Hartlepool	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.761122	\N	\N	0	0	draw	yes
4782	1399612	2025-11-08	England	National League	Truro City	Altrincham	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.769995	\N	\N	0	0	draw	yes
4783	1399604	2025-11-08	England	National League	Brackley Town	Boreham Wood	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.780005	\N	\N	0	1	a-win	yes
4784	1399611	2025-11-08	England	National League	Tamworth	Woking	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.790192	\N	\N	0	1	a-win	yes
4785	1399603	2025-11-08	England	National League	Boston United	Rochdale	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.798347	\N	\N	0	1	a-win	yes
4786	1399613	2025-11-08	England	National League	Wealdstone	Braintree	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.809567	\N	\N	0	0	draw	yes
4787	1399610	2025-11-08	England	National League	Southend	Carlisle	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.817704	\N	\N	1	2	a-win	yes
4788	1399592	2025-11-11	England	National League	Forest Green	Tamworth	h-win	4	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.828918	\N	\N	2	1	h-win	yes
4789	1399473	2025-11-11	England	National League	York	Rochdale	h-win	4	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.840082	\N	\N	1	1	draw	yes
4790	1399620	2025-11-15	England	National League	Rochdale	Aldershot Town	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.849874	\N	\N	0	0	draw	yes
4791	1399619	2025-11-15	England	National League	Hartlepool	Wealdstone	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.861616	\N	\N	1	1	draw	yes
4792	1399617	2025-11-15	England	National League	Carlisle	Eastleigh	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.870475	\N	\N	0	0	draw	yes
4793	1399624	2025-11-15	England	National League	Yeovil Town	Southend	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.880319	\N	\N	0	0	draw	yes
4794	1399618	2025-11-15	England	National League	Forest Green	Gateshead	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.891426	\N	\N	3	0	h-win	yes
4795	1399625	2025-11-15	England	National League	York	Morecambe	h-win	4	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.89985	\N	\N	1	1	draw	yes
4796	1399615	2025-11-15	England	National League	Boreham Wood	Tamworth	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.911129	\N	\N	1	1	draw	yes
4797	1399616	2025-11-15	England	National League	Braintree	Truro City	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.922563	\N	\N	0	0	draw	yes
4798	1399621	2025-11-15	England	National League	Solihull Moors	Scunthorpe	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.930655	\N	\N	2	0	h-win	yes
4799	1399622	2025-11-15	England	National League	Sutton Utd	FC Halifax Town	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.942461	\N	\N	2	0	h-win	yes
4800	1399623	2025-11-15	England	National League	Woking	Boston United	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.953535	\N	\N	1	0	h-win	yes
4801	1399614	2025-11-15	England	National League	Altrincham	Brackley Town	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.962123	\N	\N	1	0	h-win	yes
4802	1399416	2025-11-18	England	National League	Morecambe	Brackley Town	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.974233	\N	\N	1	0	h-win	yes
4803	1399594	2025-11-04	England	National League	Rochdale	Scunthorpe	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.984628	\N	\N	0	0	draw	no
4804	1399626	2025-11-22	England	National League	Aldershot Town	Woking	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:06.993334	\N	\N	0	0	draw	no
4805	1399635	2025-11-22	England	National League	Tamworth	Rochdale	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:07.001324	\N	\N	0	0	draw	no
4806	1399633	2025-11-22	England	National League	Scunthorpe	Braintree	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:07.012655	\N	\N	0	0	draw	no
4807	1399634	2025-11-22	England	National League	Southend	Altrincham	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:07.023441	\N	\N	0	0	draw	no
4808	1399632	2025-11-22	England	National League	Morecambe	Yeovil Town	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:07.031707	\N	\N	0	0	draw	no
4809	1399629	2025-11-22	England	National League	Eastleigh	Hartlepool	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:07.042729	\N	\N	0	0	draw	no
4810	1399631	2025-11-22	England	National League	Gateshead	Boreham Wood	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:07.051189	\N	\N	0	0	draw	no
4811	1399630	2025-11-22	England	National League	FC Halifax Town	Solihull Moors	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:07.062305	\N	\N	0	0	draw	no
4812	1399636	2025-11-22	England	National League	Truro City	Sutton Utd	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:07.07234	\N	\N	0	0	draw	no
4813	1399628	2025-11-22	England	National League	Brackley Town	York	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:07.080396	\N	\N	0	0	draw	no
4814	1399637	2025-11-22	England	National League	Wealdstone	Forest Green	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:07.09213	\N	\N	0	0	draw	no
4815	1399627	2025-11-22	England	National League	Boston United	Carlisle	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:07.103549	\N	\N	0	0	draw	no
4816	1399487	2025-09-06	England	National League	Scunthorpe	Wealdstone	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 20:08:07.110203	\N	\N	2	1	h-win	no
\.


--
-- Name: import_jobs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.import_jobs_id_seq', 33, true);


--
-- Name: matches_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.matches_id_seq', 4816, true);


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

\unrestrict at3PF190QJfncTuMgoIwnligdJLNYB8qPeAvfb26DTM5OGVbnGmdNgvwD1pPpVw

