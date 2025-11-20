--
-- PostgreSQL database dump
--

\restrict Qh2jMKXXJ6xK8LVcHRawB7jdM80rfdPJmdXwZVRbX0dudgrHdMduoSiFOMsIdt5

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
25	["2", "15", "531", "848"]	2025-08-01	2025-11-24	completed	{"completed_leagues": [2, 15, 531, 848]}	0	163	0	7500	2025-11-20 12:18:54.634+01	\N	\N	2025-11-20 12:18:54.941697+01	2025-11-20 12:01:34.924937+01	2025-11-20 12:18:54.941697+01	f
26	["106", "107", "109"]	2025-08-01	2025-11-24	completed	{"completed_leagues": [106, 107, 109]}	0	153	0	7500	2025-11-20 13:19:24.789+01	\N	\N	2025-11-20 13:23:54.940371+01	2025-11-20 12:04:55.307094+01	2025-11-20 13:23:54.940371+01	f
27	["39", "42", "40", "41", "45", "43"]	2025-08-01	2025-11-24	pending	{}	0	0	0	7500	\N	\N	\N	\N	2025-11-20 12:05:19.194847+01	2025-11-20 13:23:54.942533+01	f
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
1083	1381524	2025-07-18	Poland	I Liga	Slask Wroclaw	Wieczysta Kraków	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	8	2025-11-20 02:00:26.736268	\N	\N	1	0	h-win	yes
1084	1381521	2025-07-18	Poland	I Liga	ŁKS Łódź	Znicz Pruszków	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	13	18	2025-11-20 02:00:26.972933	\N	\N	1	0	h-win	yes
1085	1381519	2025-07-19	Poland	I Liga	Pogoń Grod. Mazowiecki	Stal Rzeszów	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	7	2025-11-20 02:00:27.183058	\N	\N	2	0	h-win	yes
1086	1381520	2025-07-19	Poland	I Liga	Górnik Łęczna	Polonia Bytom	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	17	4	2025-11-20 02:00:27.426685	\N	\N	0	1	a-win	yes
1087	1381526	2025-07-19	Poland	I Liga	Tychy 71	Miedz Legnica	h-win	4	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16	12	2025-11-20 02:00:27.636014	\N	\N	0	0	draw	yes
1088	1381525	2025-07-20	Poland	I Liga	Stal Mielec	Wisla Krakow	a-win	0	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	15	1	2025-11-20 02:00:27.84947	\N	\N	0	2	a-win	yes
1089	1381518	2025-07-20	Poland	I Liga	Chrobry Głogów	Odra Opole	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	10	2025-11-20 02:00:28.058872	\N	\N	1	0	h-win	yes
1090	1381522	2025-07-20	Poland	I Liga	Pogoń Siedlce	Polonia Warszawa	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	11	9	2025-11-20 02:00:28.256698	\N	\N	1	0	h-win	yes
1091	1381523	2025-07-21	Poland	I Liga	Puszcza Niepołomice	Ruch Chorzów	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	14	6	2025-11-20 02:00:28.515498	\N	\N	0	0	draw	yes
1092	1381531	2025-07-25	Poland	I Liga	Znicz Pruszków	Stal Mielec	a-win	4	5	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	18	15	2025-11-20 02:00:28.75232	\N	\N	1	2	a-win	yes
1093	1381534	2025-07-25	Poland	I Liga	Stal Rzeszów	Slask Wroclaw	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7	5	2025-11-20 02:00:28.935868	\N	\N	1	1	draw	yes
1094	1381535	2025-07-26	Poland	I Liga	Wisla Krakow	ŁKS Łódź	h-win	5	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	13	2025-11-20 02:00:29.154873	\N	\N	4	0	h-win	yes
1095	1381532	2025-07-26	Poland	I Liga	Puszcza Niepołomice	Pogoń Grod. Mazowiecki	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	14	2	2025-11-20 02:00:29.352768	\N	\N	1	1	draw	yes
1096	1381527	2025-07-26	Poland	I Liga	Chrobry Głogów	Polonia Bytom	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	4	2025-11-20 02:00:29.571753	\N	\N	0	1	a-win	yes
1097	1381528	2025-07-27	Poland	I Liga	Wieczysta Kraków	Pogoń Siedlce	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8	11	2025-11-20 02:00:29.794846	\N	\N	2	1	h-win	yes
1098	1381533	2025-07-27	Poland	I Liga	Ruch Chorzów	Górnik Łęczna	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	17	2025-11-20 02:00:30.130168	\N	\N	1	0	h-win	yes
1099	1381530	2025-07-27	Poland	I Liga	Polonia Warszawa	Tychy 71	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	16	2025-11-20 02:00:30.313713	\N	\N	1	1	draw	yes
1100	1381529	2025-07-28	Poland	I Liga	Odra Opole	Miedz Legnica	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	10	12	2025-11-20 02:00:30.511813	\N	\N	2	1	h-win	yes
1101	1395817	2025-07-25	Poland	II Liga - East	Świt Skolwin	Kalisz	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	16	2025-11-20 02:00:31.912944	\N	\N	0	0	draw	yes
1102	1395811	2025-07-25	Poland	II Liga - East	Podbeskidzie	Sandecja Nowy Sącz	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	8	2025-11-20 02:00:32.085086	\N	\N	0	1	a-win	yes
1103	1395812	2025-07-25	Poland	II Liga - East	Olimpia Grudziądz	Stal Stalowa Wola	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	6	2025-11-20 02:00:32.263089	\N	\N	0	0	draw	yes
1104	1395813	2025-07-26	Poland	II Liga - East	Podhale Nowy Targ	Jastrzębie	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	18	2025-11-20 02:00:32.443992	\N	\N	1	0	h-win	yes
1105	1395816	2025-07-26	Poland	II Liga - East	Śląsk Wrocław II	Rekord Bielsko-Biała	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7	13	2025-11-20 02:00:32.637106	\N	\N	0	0	draw	yes
1106	1395814	2025-07-26	Poland	II Liga - East	Hutnik Kraków	ŁKS Łódź II	h-win	4	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	15	17	2025-11-20 02:00:32.889119	\N	\N	3	0	h-win	yes
1107	1395818	2025-07-27	Poland	II Liga - East	Sokół Kleczew	Zaglebie Sosnowiec	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	14	9	2025-11-20 02:00:33.11395	\N	\N	1	1	draw	yes
1108	1395815	2025-07-27	Poland	II Liga - East	Resovia Rzeszów	Chojniczanka Chojnice	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	10	11	2025-11-20 02:00:33.310025	\N	\N	1	0	h-win	yes
1109	1395819	2025-07-27	Poland	II Liga - East	Unia Skierniewice	Warta Poznań	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	2	2025-11-20 02:00:33.540917	\N	\N	0	1	a-win	yes
1110	1382426	2025-07-25	Belgium	Jupiler Pro League	Antwerp	Union St. Gilloise	draw	1	1	8	4	17	8	2	5	5	1	3	3	0	0	43.00	57.00	9	16	\N	\N	\N	14	1	2025-11-20 02:01:10.479709	0.52	2.19	1	0	h-win	yes
1111	1382427	2025-07-26	Belgium	Jupiler Pro League	Dender	Cercle Brugge	draw	0	0	11	3	10	2	3	3	4	4	0	2	0	0	54.00	46.00	13	13	\N	\N	\N	16	15	2025-11-20 02:01:10.654619	1.21	1.25	0	0	draw	yes
1112	1382428	2025-07-26	Belgium	Jupiler Pro League	Zulte Waregem	KV Mechelen	draw	1	1	21	5	7	2	9	6	0	0	3	3	0	0	56.00	44.00	8	8	\N	\N	\N	8	6	2025-11-20 02:01:10.825889	2.08	0.50	0	1	a-win	yes
1113	1382429	2025-07-26	Belgium	Jupiler Pro League	RAAL La Louvière	Standard Liege	a-win	0	2	14	2	9	4	6	1	1	2	2	1	0	0	45.00	55.00	15	12	\N	\N	\N	11	10	2025-11-20 02:01:11.034702	0.84	1.73	0	2	a-win	yes
1114	1382430	2025-07-27	Belgium	Jupiler Pro League	Anderlecht	KVC Westerlo	h-win	5	2	25	10	10	4	8	3	5	0	4	2	0	0	48.00	52.00	14	14	\N	\N	\N	3	12	2025-11-20 02:01:11.228879	2.58	0.81	2	0	h-win	yes
1192	1331375	2025-07-13	Argentina	Primera Nacional	Colon Santa Fe	Almirante Brown	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 02:01:34.915	\N	\N	1	0	h-win	yes
1115	1382431	2025-07-27	Belgium	Jupiler Pro League	OH Leuven	Charleroi	draw	2	2	7	3	15	7	4	8	2	5	2	2	0	0	44.00	56.00	15	14	\N	\N	\N	13	9	2025-11-20 02:01:11.415138	1.20	1.31	1	0	h-win	yes
1116	1382432	2025-07-27	Belgium	Jupiler Pro League	Club Brugge KV	Genk	h-win	2	1	18	4	17	10	8	6	2	0	1	2	1	0	56.00	44.00	10	7	\N	\N	\N	2	7	2025-11-20 02:01:11.614602	2.00	0.88	0	1	a-win	yes
1117	1382433	2025-07-27	Belgium	Jupiler Pro League	St. Truiden	Gent	h-win	3	1	14	5	12	2	4	6	0	4	1	1	0	0	48.00	52.00	13	9	\N	\N	\N	4	5	2025-11-20 02:01:11.813908	1.26	1.58	0	0	draw	yes
1118	1374069	2025-07-11	Argentina	Liga Profesional Argentina	Aldosivi	Central Cordoba de Santiago	draw	0	0	14	2	5	1	5	2	0	0	4	2	0	0	55.00	45.00	13	12	\N	\N	\N	13	4	2025-11-20 02:01:23.134986	0.58	0.37	0	0	draw	yes
1119	1374073	2025-07-12	Argentina	Liga Profesional Argentina	Talleres Cordoba	San Lorenzo	a-win	1	2	9	2	8	2	1	5	0	2	3	2	0	0	57.00	43.00	17	13	\N	\N	\N	\N	\N	2025-11-20 02:01:23.750524	0.30	0.27	1	1	draw	yes
1120	1374075	2025-07-12	Argentina	Liga Profesional Argentina	Rosario Central	Godoy Cruz	draw	1	1	13	5	11	3	7	2	0	0	2	4	0	1	64.00	36.00	9	16	\N	\N	\N	\N	\N	2025-11-20 02:01:24.625259	1.52	0.87	0	0	draw	yes
1121	1374072	2025-07-12	Argentina	Liga Profesional Argentina	Gimnasia L.P.	Instituto Cordoba	a-win	0	1	15	6	17	5	7	8	1	2	3	4	0	0	52.00	48.00	18	6	\N	\N	\N	\N	\N	2025-11-20 02:01:24.790917	0.62	1.82	0	1	a-win	yes
1122	1374065	2025-07-12	Argentina	Liga Profesional Argentina	Huracan	Belgrano Cordoba	a-win	0	3	14	1	6	3	9	1	4	1	3	2	0	0	67.00	33.00	5	25	\N	\N	\N	11	10	2025-11-20 02:01:24.964482	1.65	1.07	0	1	a-win	yes
1123	1374066	2025-07-13	Argentina	Liga Profesional Argentina	Racing Club	Barracas Central	a-win	0	1	10	2	7	4	5	2	6	3	3	3	0	0	63.00	37.00	10	8	\N	\N	\N	3	6	2025-11-20 02:01:25.141642	0.73	1.29	0	0	draw	yes
1124	1374074	2025-07-13	Argentina	Liga Profesional Argentina	Sarmiento Junin	Independiente	draw	2	2	12	4	12	4	2	2	1	1	3	3	0	0	28.00	72.00	19	10	\N	\N	\N	\N	\N	2025-11-20 02:01:25.345261	0.72	1.09	1	0	h-win	yes
1125	1374077	2025-07-13	Argentina	Liga Profesional Argentina	Atletico Tucuman	San Martin S.J.	h-win	2	1	8	3	10	4	3	7	3	0	2	3	0	0	38.00	62.00	16	11	\N	\N	\N	\N	\N	2025-11-20 02:01:25.529043	0.75	0.92	1	0	h-win	yes
1126	1374067	2025-07-13	Argentina	Liga Profesional Argentina	Independ. Rivadavia	Newells Old Boys	a-win	1	2	15	6	13	7	5	4	3	2	4	2	1	0	55.00	45.00	16	9	\N	\N	\N	14	15	2025-11-20 02:01:25.714462	1.48	1.80	1	0	h-win	yes
1127	1374063	2025-07-13	Argentina	Liga Profesional Argentina	Argentinos JRS	Boca Juniors	draw	0	0	15	4	5	4	4	1	4	0	3	2	0	0	65.00	35.00	14	12	\N	\N	\N	5	1	2025-11-20 02:01:25.886407	1.07	0.77	0	0	draw	yes
1128	1374071	2025-07-14	Argentina	Liga Profesional Argentina	River Plate	Platense	h-win	3	1	11	6	9	3	2	4	3	0	3	3	0	1	66.00	34.00	17	15	\N	\N	\N	\N	\N	2025-11-20 02:01:26.080417	2.03	0.41	2	1	h-win	yes
1129	1374076	2025-07-14	Argentina	Liga Profesional Argentina	Deportivo Riestra	Lanus	h-win	1	0	6	3	14	5	2	8	1	0	3	2	0	0	35.00	65.00	22	9	\N	\N	\N	\N	\N	2025-11-20 02:01:26.264004	0.37	1.01	0	0	draw	yes
1130	1374068	2025-07-15	Argentina	Liga Profesional Argentina	Banfield	Defensa Y Justicia	draw	0	0	10	2	10	4	6	3	4	0	3	1	0	0	35.00	65.00	14	13	\N	\N	\N	9	12	2025-11-20 02:01:26.435732	0.76	0.36	0	0	draw	yes
1131	1374070	2025-07-15	Argentina	Liga Profesional Argentina	Velez Sarsfield	Tigre	h-win	2	1	9	4	16	4	2	4	0	1	2	1	0	1	52.00	48.00	9	13	\N	\N	\N	\N	7	2025-11-20 02:01:26.616667	2.09	1.59	2	0	h-win	yes
1132	1374064	2025-07-15	Argentina	Liga Profesional Argentina	Union Santa Fe	Estudiantes L.P.	h-win	1	0	17	8	5	1	4	1	1	1	4	2	0	0	33.00	67.00	11	12	\N	\N	\N	2	8	2025-11-20 02:01:26.798831	1.51	0.27	1	0	h-win	yes
1133	1374083	2025-07-19	Argentina	Liga Profesional Argentina	Boca Juniors	Union Santa Fe	draw	1	1	9	2	10	1	8	2	3	3	0	3	0	0	74.00	26.00	8	15	\N	\N	\N	1	2	2025-11-20 02:01:26.983765	0.80	1.02	0	0	draw	yes
1134	1374092	2025-07-19	Argentina	Liga Profesional Argentina	Atletico Tucuman	Central Cordoba de Santiago	draw	1	1	10	3	6	2	7	3	6	1	3	3	0	0	42.00	58.00	12	9	\N	\N	\N	\N	4	2025-11-20 02:01:27.165329	1.74	0.78	1	0	h-win	yes
1135	1374089	2025-07-19	Argentina	Liga Profesional Argentina	San Lorenzo	Gimnasia L.P.	draw	0	0	16	5	2	1	6	3	0	1	1	3	0	0	62.00	38.00	11	12	\N	\N	\N	\N	\N	2025-11-20 02:01:27.350001	1.38	0.21	0	0	draw	yes
1136	1374086	2025-07-19	Argentina	Liga Profesional Argentina	Lanus	Rosario Central	a-win	0	1	15	5	8	6	6	5	1	2	3	2	1	0	46.00	54.00	12	12	\N	\N	\N	\N	\N	2025-11-20 02:01:27.558224	1.33	1.51	0	0	draw	yes
1137	1374087	2025-07-19	Argentina	Liga Profesional Argentina	Godoy Cruz	Sarmiento Junin	draw	0	0	11	3	6	1	3	3	3	2	1	2	0	0	58.00	42.00	11	14	\N	\N	\N	\N	\N	2025-11-20 02:01:27.743307	0.94	0.22	0	0	draw	yes
1138	1374091	2025-07-19	Argentina	Liga Profesional Argentina	Platense	Velez Sarsfield	draw	0	0	13	4	9	4	2	3	1	3	2	5	1	0	40.00	60.00	12	17	\N	\N	\N	\N	\N	2025-11-20 02:01:27.926499	0.30	0.84	0	0	draw	yes
1139	1374090	2025-07-20	Argentina	Liga Profesional Argentina	Instituto Cordoba	River Plate	a-win	0	4	8	4	15	7	5	2	1	1	2	4	1	0	37.00	63.00	10	9	\N	\N	\N	\N	\N	2025-11-20 02:01:28.115763	0.44	1.21	0	2	a-win	yes
1140	1374080	2025-07-20	Argentina	Liga Profesional Argentina	Barracas Central	Independ. Rivadavia	a-win	0	3	6	3	9	4	1	2	0	7	3	4	0	0	50.00	50.00	12	15	\N	\N	\N	6	14	2025-11-20 02:01:28.309413	0.39	1.82	0	0	draw	yes
1141	1374084	2025-07-20	Argentina	Liga Profesional Argentina	Tigre	Argentinos JRS	h-win	2	1	9	5	13	6	1	1	0	0	2	4	0	0	29.00	71.00	11	15	\N	\N	\N	7	5	2025-11-20 02:01:28.501471	1.69	1.13	0	0	draw	yes
1142	1374079	2025-07-20	Argentina	Liga Profesional Argentina	Newells Old Boys	Banfield	a-win	1	2	12	5	17	7	4	5	0	1	1	2	0	0	57.00	43.00	11	25	\N	\N	\N	15	9	2025-11-20 02:01:28.684665	0.52	1.41	0	1	a-win	yes
1143	1374081	2025-07-21	Argentina	Liga Profesional Argentina	Belgrano Cordoba	Racing Club	a-win	0	1	16	3	14	4	5	4	1	2	3	5	0	0	50.00	50.00	7	14	\N	\N	\N	10	3	2025-11-20 02:01:28.839379	0.72	0.86	0	0	draw	yes
1144	1374088	2025-07-21	Argentina	Liga Profesional Argentina	Independiente	Talleres Cordoba	a-win	1	2	11	5	14	6	4	4	5	4	1	3	0	0	58.00	42.00	4	13	\N	\N	\N	\N	\N	2025-11-20 02:01:29.036441	0.85	1.22	0	1	a-win	yes
1145	1374082	2025-07-22	Argentina	Liga Profesional Argentina	Estudiantes L.P.	Huracan	h-win	2	1	9	6	18	3	5	5	1	1	6	4	0	0	56.00	44.00	15	14	\N	\N	\N	8	11	2025-11-20 02:01:29.191407	0.66	0.87	0	1	a-win	yes
1146	1374078	2025-07-22	Argentina	Liga Profesional Argentina	Defensa Y Justicia	Aldosivi	h-win	2	0	15	7	6	1	2	2	6	4	1	1	0	1	71.00	29.00	11	7	\N	\N	\N	12	13	2025-11-20 02:01:29.364538	2.25	0.32	0	0	draw	yes
1147	1374085	2025-07-22	Argentina	Liga Profesional Argentina	San Martin S.J.	Deportivo Riestra	h-win	3	2	11	4	3	2	6	2	2	0	2	4	0	0	49.00	51.00	12	21	\N	\N	\N	\N	\N	2025-11-20 02:01:29.530216	2.01	0.20	1	1	draw	yes
1193	1331363	2025-07-13	Argentina	Primera Nacional	Deportivo Madryn	Almagro	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	16	2025-11-20 02:01:34.920453	\N	\N	0	1	a-win	yes
1148	1374104	2025-07-26	Argentina	Liga Profesional Argentina	Sarmiento Junin	Lanus	a-win	0	2	14	6	9	3	8	8	1	0	3	2	0	0	53.00	47.00	13	10	\N	\N	\N	\N	\N	2025-11-20 02:01:29.696626	1.17	0.89	0	2	a-win	yes
1149	1374093	2025-07-26	Argentina	Liga Profesional Argentina	Union Santa Fe	Tigre	draw	0	0	10	4	9	2	10	0	2	2	5	5	1	0	49.00	51.00	9	15	\N	\N	\N	2	7	2025-11-20 02:01:29.868336	0.89	1.04	0	0	draw	yes
1150	1374096	2025-07-26	Argentina	Liga Profesional Argentina	Independ. Rivadavia	Belgrano Cordoba	draw	0	0	10	2	13	2	3	4	2	2	0	3	0	0	61.00	39.00	11	10	\N	\N	\N	14	10	2025-11-20 02:01:30.058971	0.64	0.49	0	0	draw	yes
1151	1374098	2025-07-26	Argentina	Liga Profesional Argentina	Aldosivi	Newells Old Boys	draw	0	0	17	6	11	2	6	6	1	3	2	2	0	0	56.00	44.00	17	12	\N	\N	\N	13	15	2025-11-20 02:01:30.233548	0.74	1.13	0	0	draw	yes
1152	1374105	2025-07-26	Argentina	Liga Profesional Argentina	Rosario Central	San Martin S.J.	draw	0	0	13	5	7	2	9	5	1	0	1	3	0	0	73.00	27.00	8	13	\N	\N	\N	\N	\N	2025-11-20 02:01:30.411167	1.28	0.47	0	0	draw	yes
1153	1374107	2025-07-27	Argentina	Liga Profesional Argentina	Platense	Argentinos JRS	draw	0	0	10	3	7	3	5	4	1	3	3	2	0	0	39.00	61.00	18	14	\N	\N	\N	\N	5	2025-11-20 02:01:30.584259	0.57	0.35	0	0	draw	yes
1154	1374100	2025-07-27	Argentina	Liga Profesional Argentina	Velez Sarsfield	Instituto Cordoba	draw	0	0	16	5	12	4	12	4	2	1	2	4	0	0	61.00	39.00	11	17	\N	\N	\N	\N	\N	2025-11-20 02:01:30.753512	0.77	0.48	0	0	draw	yes
1155	1374095	2025-07-27	Argentina	Liga Profesional Argentina	Racing Club	Estudiantes L.P.	a-win	0	1	18	5	5	2	9	2	3	1	2	4	0	1	60.00	40.00	9	13	\N	\N	\N	3	8	2025-11-20 02:01:30.939373	0.91	0.64	0	0	draw	yes
1156	1374102	2025-07-27	Argentina	Liga Profesional Argentina	Gimnasia L.P.	Independiente	h-win	1	0	8	3	14	3	4	7	4	3	6	2	0	0	24.00	76.00	19	16	\N	\N	\N	\N	\N	2025-11-20 02:01:31.129327	1.31	0.87	1	0	h-win	yes
1157	1374103	2025-07-27	Argentina	Liga Profesional Argentina	Talleres Cordoba	Godoy Cruz	draw	0	0	5	0	14	4	3	9	0	1	1	4	1	0	46.00	54.00	9	10	\N	\N	\N	\N	\N	2025-11-20 02:01:31.306107	0.41	1.06	0	0	draw	yes
1158	1374094	2025-07-27	Argentina	Liga Profesional Argentina	Huracan	Boca Juniors	h-win	1	0	12	8	5	1	4	2	1	1	1	5	0	0	38.00	62.00	16	17	\N	\N	\N	11	1	2025-11-20 02:01:31.490658	1.02	0.34	0	0	draw	yes
1159	1374101	2025-07-28	Argentina	Liga Profesional Argentina	River Plate	San Lorenzo	draw	0	0	11	2	5	0	7	6	2	1	5	2	0	0	70.00	30.00	12	14	\N	\N	\N	\N	\N	2025-11-20 02:01:31.700311	0.71	0.32	0	0	draw	yes
1160	1374106	2025-07-28	Argentina	Liga Profesional Argentina	Deportivo Riestra	Atletico Tucuman	h-win	1	0	11	3	12	3	3	3	0	0	2	4	0	0	41.00	59.00	11	10	\N	\N	\N	\N	\N	2025-11-20 02:01:31.895092	2.21	0.64	0	0	draw	yes
1161	1374099	2025-07-28	Argentina	Liga Profesional Argentina	Central Cordoba de Santiago	Defensa Y Justicia	h-win	2	1	21	8	13	4	5	3	5	4	1	5	0	1	39.00	61.00	5	12	\N	\N	\N	4	12	2025-11-20 02:01:32.096867	2.92	0.96	1	0	h-win	yes
1162	1374097	2025-07-29	Argentina	Liga Profesional Argentina	Banfield	Barracas Central	a-win	1	3	22	8	10	5	7	1	3	0	2	2	0	0	62.00	38.00	7	9	\N	\N	\N	9	6	2025-11-20 02:01:32.293838	2.13	1.12	1	3	a-win	yes
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
1463	1384652	2025-07-18	Czech-Republic	Czech Liga	Pardubice	Plzen	a-win	1	5	4	2	15	6	1	8	2	0	3	0	0	0	43.00	57.00	8	11	\N	\N	\N	13	5	2025-11-20 04:14:01.283251	0.41	1.85	1	3	a-win	yes
1464	1384651	2025-07-19	Czech-Republic	Czech Liga	Bohemians 1905	Baník Ostrava	h-win	1	0	15	4	19	5	5	3	1	0	3	1	0	0	31.00	69.00	7	6	\N	\N	\N	10	15	2025-11-20 04:14:01.476112	\N	\N	1	0	h-win	yes
1465	1384654	2025-07-19	Czech-Republic	Czech Liga	Karviná	Dukla Praha	h-win	2	0	15	4	10	2	5	4	2	1	1	3	0	0	57.00	43.00	14	15	\N	\N	\N	9	14	2025-11-20 04:14:01.663639	\N	\N	1	0	h-win	yes
1466	1384658	2025-07-19	Czech-Republic	Czech Liga	Teplice	Zlin	a-win	1	3	11	4	7	3	6	3	1	1	4	3	0	0	57.00	43.00	14	19	\N	\N	\N	12	8	2025-11-20 04:14:01.843992	\N	\N	1	0	h-win	yes
1467	1384653	2025-07-19	Czech-Republic	Czech Liga	FK Jablonec	Sparta Praha	draw	1	1	11	4	13	4	5	6	3	1	4	2	0	0	44.00	56.00	17	11	\N	\N	\N	3	2	2025-11-20 04:14:02.033643	\N	\N	1	0	h-win	yes
1468	1384657	2025-07-20	Czech-Republic	Czech Liga	Slovácko	Sigma Olomouc	a-win	0	1	18	3	9	3	4	4	4	0	1	3	0	0	54.00	46.00	7	18	\N	\N	\N	16	4	2025-11-20 04:14:02.192666	\N	\N	0	0	draw	yes
1469	1384655	2025-07-20	Czech-Republic	Czech Liga	Mlada Boleslav	Slovan Liberec	draw	3	3	13	6	12	4	8	6	1	3	1	3	0	0	62.00	38.00	10	16	\N	\N	\N	11	7	2025-11-20 04:14:02.345787	\N	\N	1	1	draw	yes
1470	1384656	2025-07-20	Czech-Republic	Czech Liga	Slavia Praha	Hradec Králové	draw	2	2	16	4	6	4	8	2	0	0	2	1	0	0	64.00	36.00	10	11	\N	\N	\N	1	6	2025-11-20 04:14:02.505546	\N	\N	0	1	a-win	yes
1471	1384663	2025-07-26	Czech-Republic	Czech Liga	Plzen	FK Jablonec	draw	1	1	14	3	12	6	2	3	0	1	1	2	0	0	44.00	56.00	14	13	\N	\N	\N	5	3	2025-11-20 04:14:02.669927	\N	\N	1	0	h-win	yes
1472	1384666	2025-07-26	Czech-Republic	Czech Liga	Zlin	Slovácko	draw	1	1	12	3	7	1	8	2	3	2	3	3	0	0	44.00	56.00	16	13	\N	\N	\N	8	16	2025-11-20 04:14:02.850216	\N	\N	1	1	draw	yes
1473	1384664	2025-07-26	Czech-Republic	Czech Liga	Sigma Olomouc	Dukla Praha	draw	0	0	8	1	3	1	9	3	0	0	1	3	0	0	59.00	41.00	13	13	\N	\N	\N	4	14	2025-11-20 04:14:03.001658	\N	\N	0	0	draw	yes
1474	1384660	2025-07-26	Czech-Republic	Czech Liga	Hradec Králové	Karviná	a-win	1	2	9	3	24	7	5	6	2	3	2	0	0	0	43.00	57.00	13	8	\N	\N	\N	6	9	2025-11-20 04:14:03.169791	\N	\N	1	1	draw	yes
1475	1384659	2025-07-26	Czech-Republic	Czech Liga	Bohemians 1905	Slavia Praha	a-win	0	2	5	1	14	6	3	11	2	4	2	4	0	0	40.00	60.00	15	17	\N	\N	\N	10	1	2025-11-20 04:14:03.345688	\N	\N	0	1	a-win	yes
1476	1384661	2025-07-27	Czech-Republic	Czech Liga	Slovan Liberec	Pardubice	h-win	2	1	14	5	4	2	4	4	1	0	0	1	0	0	51.00	49.00	13	17	\N	\N	\N	7	13	2025-11-20 04:14:03.533357	\N	\N	0	0	draw	yes
1477	1384665	2025-07-27	Czech-Republic	Czech Liga	Sparta Praha	Mlada Boleslav	h-win	3	2	16	6	11	7	5	5	5	5	1	3	0	0	51.00	49.00	7	10	\N	\N	\N	2	11	2025-11-20 04:14:03.714385	\N	\N	1	1	draw	yes
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
1502	1338435	2025-07-01	Ecuador	Liga Pro	Cuniburo	Aucas	a-win	0	1	6	1	10	3	1	5	0	0	0	3	0	0	54.00	46.00	6	15	\N	\N	\N	14	9	2025-11-20 05:13:52.956854	\N	\N	0	1	a-win	yes
1503	1338448	2025-07-05	Ecuador	Liga Pro	Libertad	Deportivo Cuenca	h-win	2	1	19	7	13	4	7	4	0	5	4	2	0	0	55.00	45.00	15	8	\N	\N	\N	6	7	2025-11-20 05:13:53.156019	\N	\N	0	1	a-win	yes
1504	1338443	2025-07-05	Ecuador	Liga Pro	Mushuc Runa SC	Universidad Catolica	draw	1	1	7	3	16	5	3	3	1	5	2	2	1	0	23.00	77.00	7	8	\N	\N	\N	15	4	2025-11-20 05:13:53.335272	\N	\N	1	1	draw	yes
1505	1338444	2025-07-05	Ecuador	Liga Pro	Emelec	Cuniburo	h-win	2	0	20	6	3	0	12	4	4	0	2	0	0	0	58.00	42.00	17	7	\N	\N	\N	8	14	2025-11-20 05:13:53.525663	\N	\N	0	0	draw	yes
1506	1338441	2025-07-06	Ecuador	Liga Pro	Independiente del Valle	Barcelona SC	draw	1	1	11	2	15	3	3	5	2	1	2	2	1	0	51.00	49.00	11	6	\N	\N	\N	1	2	2025-11-20 05:13:53.722699	\N	\N	0	0	draw	yes
1507	1338445	2025-07-06	Ecuador	Liga Pro	Aucas	Macara	a-win	1	4	11	4	12	5	10	3	2	0	1	2	0	0	62.00	38.00	13	15	\N	\N	\N	9	10	2025-11-20 05:13:53.914923	\N	\N	0	1	a-win	yes
1508	1338446	2025-07-06	Ecuador	Liga Pro	El Nacional	Manta FC	h-win	1	0	24	6	4	0	8	6	5	0	1	3	0	1	54.00	46.00	6	10	\N	\N	\N	11	16	2025-11-20 05:13:54.093943	\N	\N	0	0	draw	yes
1509	1338442	2025-07-07	Ecuador	Liga Pro	Delfin SC	LDU de Quito	a-win	0	4	16	5	8	5	5	2	1	2	2	1	1	0	51.00	49.00	12	16	\N	\N	\N	12	3	2025-11-20 05:13:54.273599	1.52	1.91	0	1	a-win	yes
1510	1338447	2025-07-08	Ecuador	Liga Pro	Tecnico Universitario	Orense SC	a-win	1	2	13	6	11	2	3	7	2	2	2	1	0	0	52.00	48.00	13	21	\N	\N	\N	13	5	2025-11-20 05:13:54.438258	\N	\N	0	0	draw	yes
1511	1338451	2025-07-12	Ecuador	Liga Pro	Macara	Independiente del Valle	a-win	1	2	11	1	11	4	4	4	3	1	5	1	0	0	33.00	67.00	20	9	\N	\N	\N	10	1	2025-11-20 05:13:54.62099	\N	\N	1	1	draw	yes
1512	1338450	2025-07-12	Ecuador	Liga Pro	Manta FC	Universidad Catolica	h-win	4	2	10	4	11	7	2	6	0	2	2	0	0	0	49.00	51.00	15	8	\N	\N	\N	16	4	2025-11-20 05:13:54.795476	\N	\N	2	1	h-win	yes
1513	1338449	2025-07-12	Ecuador	Liga Pro	LDU de Quito	Emelec	h-win	2	0	9	2	1	0	1	1	2	0	0	1	0	0	57.00	43.00	7	5	\N	\N	\N	3	8	2025-11-20 05:13:54.974656	\N	\N	1	0	h-win	yes
1514	1338453	2025-07-13	Ecuador	Liga Pro	Barcelona SC	Tecnico Universitario	draw	1	1	7	3	8	2	3	5	4	0	1	2	0	1	71.00	29.00	12	15	\N	\N	\N	2	13	2025-11-20 05:13:55.149576	\N	\N	1	1	draw	yes
1515	1338454	2025-07-13	Ecuador	Liga Pro	Cuniburo	Mushuc Runa SC	draw	1	1	12	5	14	3	11	5	1	1	1	1	0	0	65.00	35.00	12	10	\N	\N	\N	14	15	2025-11-20 05:13:55.336889	\N	\N	0	0	draw	yes
1516	1338456	2025-07-13	Ecuador	Liga Pro	Orense SC	Libertad	a-win	0	1	17	9	7	5	9	1	6	1	0	1	0	0	66.00	34.00	11	7	\N	\N	\N	5	6	2025-11-20 05:13:55.507277	\N	\N	0	1	a-win	yes
1517	1338455	2025-07-14	Ecuador	Liga Pro	Deportivo Cuenca	Delfin SC	draw	1	1	11	2	6	2	7	1	4	2	1	1	0	0	66.00	34.00	10	10	\N	\N	\N	7	12	2025-11-20 05:13:55.681854	\N	\N	0	0	draw	yes
1518	1338452	2025-07-15	Ecuador	Liga Pro	Aucas	El Nacional	h-win	1	0	20	7	16	4	5	2	1	1	4	3	1	0	58.00	42.00	13	9	\N	\N	\N	9	11	2025-11-20 05:13:55.863014	\N	\N	0	0	draw	yes
1519	1338458	2025-07-19	Ecuador	Liga Pro	Independiente del Valle	Aucas	h-win	2	1	13	5	11	2	2	4	2	4	2	2	1	0	52.00	48.00	15	9	\N	\N	\N	1	9	2025-11-20 05:13:56.041731	\N	\N	2	0	h-win	yes
1520	1338460	2025-07-19	Ecuador	Liga Pro	Universidad Catolica	Cuniburo	h-win	3	0	21	9	4	0	4	1	0	2	1	0	0	0	63.00	37.00	13	4	\N	\N	\N	4	14	2025-11-20 05:13:56.221115	\N	\N	1	0	h-win	yes
1521	1338459	2025-07-19	Ecuador	Liga Pro	Orense SC	El Nacional	draw	1	1	11	3	6	3	10	1	2	1	3	1	0	0	61.00	39.00	17	18	\N	\N	\N	5	11	2025-11-20 05:13:56.397831	\N	\N	0	0	draw	yes
1522	1338457	2025-07-20	Ecuador	Liga Pro	Delfin SC	Barcelona SC	a-win	0	1	14	3	11	4	4	3	1	1	4	2	0	0	55.00	45.00	15	17	\N	\N	\N	12	2	2025-11-20 05:13:56.57864	\N	\N	0	0	draw	yes
1523	1338461	2025-07-20	Ecuador	Liga Pro	Tecnico Universitario	Macara	h-win	1	0	11	5	7	3	4	4	0	2	2	4	0	0	34.00	66.00	22	11	\N	\N	\N	13	10	2025-11-20 05:13:56.758491	\N	\N	1	0	h-win	yes
1524	1338462	2025-07-20	Ecuador	Liga Pro	Emelec	Mushuc Runa SC	h-win	1	0	10	2	8	2	5	6	1	1	1	4	0	0	57.00	43.00	20	10	\N	\N	\N	8	15	2025-11-20 05:13:56.955675	\N	\N	1	0	h-win	yes
1525	1338464	2025-07-21	Ecuador	Liga Pro	LDU de Quito	Deportivo Cuenca	draw	2	2	7	0	5	2	0	1	0	2	1	1	0	0	59.00	41.00	5	4	\N	\N	\N	3	7	2025-11-20 05:13:57.165761	\N	\N	0	1	a-win	yes
1526	1338463	2025-07-22	Ecuador	Liga Pro	Libertad	Manta FC	h-win	1	0	13	3	5	1	6	3	2	5	3	1	0	0	51.00	49.00	12	7	\N	\N	\N	6	16	2025-11-20 05:13:57.364758	\N	\N	0	0	draw	yes
1527	1338466	2025-07-25	Ecuador	Liga Pro	Barcelona SC	LDU de Quito	a-win	0	1	7	3	10	5	3	1	2	1	1	4	0	0	55.00	45.00	11	24	\N	\N	\N	2	3	2025-11-20 05:13:57.553465	\N	\N	0	1	a-win	yes
1528	1338472	2025-07-26	Ecuador	Liga Pro	El Nacional	Libertad	draw	2	2	19	7	19	3	7	5	6	1	0	0	0	0	55.00	45.00	8	9	\N	\N	\N	11	6	2025-11-20 05:13:57.706956	\N	\N	1	1	draw	yes
1529	1338470	2025-07-26	Ecuador	Liga Pro	Aucas	Delfin SC	h-win	2	1	15	6	6	3	4	3	2	3	2	2	0	0	42.00	58.00	15	4	\N	\N	\N	9	12	2025-11-20 05:13:57.864915	\N	\N	2	0	h-win	yes
1530	1338465	2025-07-26	Ecuador	Liga Pro	Manta FC	Emelec	a-win	2	4	18	7	14	6	3	5	1	3	5	2	0	0	65.00	35.00	11	21	\N	\N	\N	16	8	2025-11-20 05:13:58.033059	\N	\N	0	4	a-win	yes
1531	1338471	2025-07-27	Ecuador	Liga Pro	Cuniburo	Orense SC	a-win	0	1	17	8	4	1	7	2	2	2	2	1	0	0	67.00	33.00	9	11	\N	\N	\N	14	5	2025-11-20 05:13:58.211394	\N	\N	0	0	draw	yes
1532	1338469	2025-07-27	Ecuador	Liga Pro	Mushuc Runa SC	Tecnico Universitario	a-win	0	1	11	3	14	4	7	2	5	3	2	3	0	0	70.00	30.00	11	16	\N	\N	\N	15	13	2025-11-20 05:13:58.399432	\N	\N	0	1	a-win	yes
1533	1338467	2025-07-27	Ecuador	Liga Pro	Macara	Universidad Catolica	a-win	1	4	15	6	18	10	6	4	1	3	2	1	0	0	49.00	51.00	13	15	\N	\N	\N	10	4	2025-11-20 05:13:58.582213	\N	\N	1	2	a-win	yes
1534	1338468	2025-07-28	Ecuador	Liga Pro	Deportivo Cuenca	Independiente del Valle	a-win	0	3	2	0	19	12	1	1	2	1	0	0	1	0	38.00	62.00	7	6	\N	\N	\N	7	1	2025-11-20 05:13:58.765639	\N	\N	0	1	a-win	yes
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
1548	1390647	2025-07-19	Guatemala	Liga Nacional	Cobán Imperial	Mixco	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	1	2025-11-20 05:14:07.113456	\N	\N	0	1	a-win	yes
1549	1390645	2025-07-20	Guatemala	Liga Nacional	Antigua GFC	Marquense	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	8	2025-11-20 05:14:07.326901	\N	\N	1	0	h-win	yes
1550	1390650	2025-07-20	Guatemala	Liga Nacional	Malacateco	Xelajú	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	7	2025-11-20 05:14:07.516895	\N	\N	0	0	draw	yes
1551	1390646	2025-07-20	Guatemala	Liga Nacional	Aurora	Guastatoya	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	12	2025-11-20 05:14:07.718798	\N	\N	0	0	draw	yes
1552	1390649	2025-07-20	Guatemala	Liga Nacional	Achuapa	Municipal	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	3	2025-11-20 05:14:07.895861	\N	\N	1	1	draw	yes
1553	1390648	2025-07-21	Guatemala	Liga Nacional	Comunicaciones	Mictlán	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	11	10	2025-11-20 05:14:08.055522	\N	\N	1	0	h-win	yes
1554	1390656	2025-07-25	Guatemala	Liga Nacional	Xelajú	Antigua GFC	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7	2	2025-11-20 05:14:08.215151	\N	\N	0	2	a-win	yes
1555	1390651	2025-07-26	Guatemala	Liga Nacional	Mixco	Comunicaciones	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	11	2025-11-20 05:14:08.397412	\N	\N	0	0	draw	yes
1556	1390655	2025-07-27	Guatemala	Liga Nacional	Municipal	Aurora	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	4	2025-11-20 05:14:08.577509	\N	\N	0	1	a-win	yes
1557	1390654	2025-07-27	Guatemala	Liga Nacional	Mictlán	Malacateco	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	10	5	2025-11-20 05:14:08.772853	\N	\N	0	1	a-win	yes
1558	1390653	2025-07-27	Guatemala	Liga Nacional	Marquense	Achuapa	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8	6	2025-11-20 05:14:08.961921	\N	\N	0	0	draw	yes
1559	1390652	2025-07-27	Guatemala	Liga Nacional	Guastatoya	Cobán Imperial	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	9	2025-11-20 05:14:09.155339	\N	\N	0	0	draw	yes
1560	1398277	2025-07-23	Honduras	Liga Nacional	Real Espana	Olancho	h-win	4	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	5	2025-11-20 05:14:10.51988	\N	\N	1	0	h-win	yes
1561	1411868	2025-07-24	Honduras	Liga Nacional	Lobos Upnfm	Génesis	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	9	2025-11-20 05:14:10.695207	\N	\N	2	0	h-win	yes
1562	1398275	2025-07-24	Honduras	Liga Nacional	Atlético Choloma	CD Olimpia	a-win	2	7	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	10	1	2025-11-20 05:14:10.87438	\N	\N	1	2	a-win	yes
1563	1398276	2025-07-25	Honduras	Liga Nacional	Victoria	CD Marathon	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	11	2	2025-11-20 05:14:11.058113	\N	\N	0	1	a-win	yes
1564	1412892	2025-07-26	Honduras	Liga Nacional	Génesis	CD Motagua	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	4	2025-11-20 05:14:11.234691	\N	\N	0	0	draw	yes
1565	1412893	2025-07-27	Honduras	Liga Nacional	Platense FC	Real Espana	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8	3	2025-11-20 05:14:11.417746	\N	\N	0	1	a-win	yes
1566	1412894	2025-07-27	Honduras	Liga Nacional	CD Olimpia	Lobos Upnfm	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	6	2025-11-20 05:14:11.60086	\N	\N	1	0	h-win	yes
1567	1412871	2025-07-27	Honduras	Liga Nacional	CD Marathon	Juticalpa	h-win	7	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	7	2025-11-20 05:14:11.787552	\N	\N	4	0	h-win	yes
1568	1412895	2025-07-28	Honduras	Liga Nacional	Olancho	Victoria	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	11	2025-11-20 05:14:11.967646	\N	\N	2	0	h-win	yes
1569	1412896	2025-07-30	Honduras	Liga Nacional	Juticalpa	Platense FC	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7	8	2025-11-20 05:14:12.156777	\N	\N	0	0	draw	yes
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
1738	1379481	2025-07-12	Mexico	Liga MX	Puebla	Atlas	a-win	2	3	16	4	8	4	4	3	2	3	4	2	0	0	67.00	33.00	16	12	\N	\N	\N	18	14	2025-11-20 07:14:22.464754	\N	\N	1	1	draw	yes
1739	1379483	2025-07-12	Mexico	Liga MX	FC Juarez	Club America	draw	1	1	9	3	6	2	3	4	1	0	2	1	0	1	55.00	45.00	15	11	\N	\N	\N	8	4	2025-11-20 07:14:22.608229	\N	\N	0	1	a-win	yes
1740	1379482	2025-07-12	Mexico	Liga MX	Club Tijuana	Club Queretaro	h-win	1	0	12	3	5	2	6	3	0	1	1	1	0	0	60.00	40.00	16	15	\N	\N	\N	7	12	2025-11-20 07:14:22.769344	\N	\N	1	0	h-win	yes
1741	1379485	2025-07-13	Mexico	Liga MX	Toluca	Necaxa	h-win	3	1	21	7	11	4	7	4	2	1	2	2	0	0	55.00	45.00	11	13	\N	\N	\N	1	13	2025-11-20 07:14:22.925731	\N	\N	2	1	h-win	yes
1742	1379484	2025-07-13	Mexico	Liga MX	Santos Laguna	U.N.A.M. - Pumas	h-win	3	0	8	4	10	2	1	5	2	7	2	5	0	0	45.00	55.00	16	16	\N	\N	\N	11	10	2025-11-20 07:14:23.113283	\N	\N	1	0	h-win	yes
1743	1379486	2025-07-13	Mexico	Liga MX	Cruz Azul	Mazatlán	draw	0	0	14	4	7	0	12	2	3	4	2	4	0	0	74.00	26.00	8	9	\N	\N	\N	3	16	2025-11-20 07:14:23.282349	\N	\N	0	0	draw	yes
1744	1379487	2025-07-14	Mexico	Liga MX	Pachuca	Monterrey	h-win	3	0	16	6	12	3	3	7	3	3	3	2	0	0	41.00	59.00	7	12	\N	\N	\N	9	5	2025-11-20 07:14:23.45113	\N	\N	0	0	draw	yes
1745	1379488	2025-07-14	Mexico	Liga MX	Leon	Atletico San Luis	a-win	0	1	11	4	12	4	4	7	5	1	3	3	0	0	47.00	53.00	13	11	\N	\N	\N	17	15	2025-11-20 07:14:23.621451	\N	\N	0	0	draw	yes
1746	1379489	2025-07-17	Mexico	Liga MX	Club America	Club Tijuana	h-win	3	1	18	10	8	2	6	1	1	2	3	0	0	0	65.00	35.00	11	10	\N	\N	\N	4	7	2025-11-20 07:14:23.775491	\N	\N	1	0	h-win	yes
1747	1379490	2025-07-17	Mexico	Liga MX	Santos Laguna	Toluca	a-win	2	4	2	2	0	0	0	0	0	0	0	2	0	0	0.00	100.00	2	0	\N	\N	\N	11	1	2025-11-20 07:14:23.932776	\N	\N	2	1	h-win	yes
1748	1379491	2025-07-19	Mexico	Liga MX	Necaxa	Club Queretaro	h-win	3	1	26	6	3	2	3	2	0	2	2	0	0	0	73.00	27.00	17	7	\N	\N	\N	13	12	2025-11-20 07:14:24.086303	\N	\N	2	1	h-win	yes
1749	1379492	2025-07-19	Mexico	Liga MX	Atletico San Luis	Monterrey	a-win	0	1	5	1	13	3	5	3	1	4	2	2	0	0	43.00	57.00	15	9	\N	\N	\N	15	5	2025-11-20 07:14:24.283535	\N	\N	0	1	a-win	yes
1750	1379493	2025-07-19	Mexico	Liga MX	Mazatlán	Puebla	h-win	2	1	7	4	11	5	3	4	1	3	3	3	0	0	42.00	58.00	17	12	\N	\N	\N	16	18	2025-11-20 07:14:24.465402	\N	\N	2	0	h-win	yes
1751	1379495	2025-07-20	Mexico	Liga MX	Tigres UANL	FC Juarez	h-win	1	0	22	10	5	1	5	2	1	1	3	3	0	1	65.00	35.00	16	14	\N	\N	\N	2	8	2025-11-20 07:14:24.667369	\N	\N	0	0	draw	yes
1752	1379494	2025-07-20	Mexico	Liga MX	Leon	Guadalajara Chivas	h-win	1	0	6	3	18	3	5	4	0	3	1	0	0	0	34.00	66.00	9	16	\N	\N	\N	17	6	2025-11-20 07:14:24.865314	\N	\N	0	0	draw	yes
1753	1379496	2025-07-20	Mexico	Liga MX	Atlas	Cruz Azul	draw	3	3	10	4	29	5	4	11	1	0	2	2	0	0	29.00	71.00	10	15	\N	\N	\N	14	3	2025-11-20 07:14:25.035073	\N	\N	2	0	h-win	yes
1754	1379497	2025-07-20	Mexico	Liga MX	U.N.A.M. - Pumas	Pachuca	a-win	2	3	8	4	10	3	4	1	2	5	3	1	0	0	63.00	37.00	15	12	\N	\N	\N	10	9	2025-11-20 07:14:25.216956	\N	\N	2	2	draw	yes
1755	1379499	2025-07-26	Mexico	Liga MX	Club Queretaro	U.N.A.M. - Pumas	a-win	0	2	6	1	7	3	4	3	2	2	3	4	0	1	56.00	44.00	21	17	\N	\N	\N	12	10	2025-11-20 07:14:25.397091	\N	\N	0	1	a-win	yes
1756	1379498	2025-07-26	Mexico	Liga MX	Puebla	Santos Laguna	h-win	1	0	19	4	6	1	6	2	4	0	1	3	0	0	59.00	41.00	7	17	\N	\N	\N	18	11	2025-11-20 07:14:25.58137	\N	\N	0	0	draw	yes
1757	1379500	2025-07-26	Mexico	Liga MX	Club Tijuana	FC Juarez	draw	1	1	11	3	12	5	4	5	5	1	5	4	0	0	37.00	63.00	16	15	\N	\N	\N	7	8	2025-11-20 07:14:25.757125	\N	\N	0	0	draw	yes
1758	1379502	2025-07-27	Mexico	Liga MX	Pachuca	Mazatlán	h-win	1	0	16	3	2	0	8	2	3	7	1	3	0	0	65.00	35.00	10	16	\N	\N	\N	9	16	2025-11-20 07:14:25.940583	\N	\N	0	0	draw	yes
1759	1379501	2025-07-27	Mexico	Liga MX	Guadalajara Chivas	Atletico San Luis	h-win	4	3	15	8	14	8	10	6	1	0	3	3	0	0	55.00	45.00	10	17	\N	\N	\N	6	15	2025-11-20 07:14:26.122913	\N	\N	2	0	h-win	yes
1760	1379504	2025-07-27	Mexico	Liga MX	Toluca	Tigres UANL	a-win	3	4	17	6	11	5	7	0	3	1	5	3	0	0	55.00	45.00	15	8	\N	\N	\N	1	2	2025-11-20 07:14:26.347332	\N	\N	1	3	a-win	yes
1761	1379506	2025-07-27	Mexico	Liga MX	Monterrey	Atlas	h-win	3	1	25	10	7	1	9	4	1	0	4	3	1	1	71.00	29.00	12	12	\N	\N	\N	5	14	2025-11-20 07:14:26.527369	\N	\N	1	1	draw	yes
1762	1379503	2025-07-27	Mexico	Liga MX	Cruz Azul	Leon	h-win	4	1	23	13	9	5	8	1	1	3	1	2	0	0	61.00	39.00	7	11	\N	\N	\N	3	17	2025-11-20 07:14:26.706185	\N	\N	0	0	draw	yes
1763	1379505	2025-07-27	Mexico	Liga MX	Necaxa	Club America	draw	1	1	18	2	13	3	7	4	1	1	3	3	0	0	34.00	66.00	8	10	\N	\N	\N	13	4	2025-11-20 07:14:26.885319	\N	\N	1	1	draw	yes
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
1814	1405347	2025-07-19	Panama	Liga Panameña de Fútbol	Veraguas	Herrera	h-win	4	1	13	11	8	3	6	7	0	0	4	4	0	0	61.00	39.00	12	5	\N	\N	\N	\N	\N	2025-11-20 07:14:41.671592	\N	\N	0	0	draw	yes
1815	1405348	2025-07-20	Panama	Liga Panameña de Fútbol	Deportivo Universitario	Independiente de La Chorrera	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 07:14:41.705032	\N	\N	3	2	h-win	yes
1816	1405349	2025-07-20	Panama	Liga Panameña de Fútbol	CD Arabe Unido	Plaza Amador	a-win	1	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 07:14:41.724942	\N	\N	0	1	a-win	yes
1817	1405427	2025-07-20	Panama	Liga Panameña de Fútbol	SD Atletico Nacional	San Francisco FC	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 07:14:41.738857	\N	\N	0	1	a-win	yes
1818	1405350	2025-07-21	Panama	Liga Panameña de Fútbol	Tauro FC	Alianza FC	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 07:14:41.752435	\N	\N	1	1	draw	yes
1819	1405351	2025-07-22	Panama	Liga Panameña de Fútbol	Sporting San Miguelito	UMECIT	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 07:14:41.764849	\N	\N	0	0	draw	yes
1820	1405352	2025-07-26	Panama	Liga Panameña de Fútbol	San Francisco FC	Deportivo Universitario	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 07:14:41.774259	\N	\N	1	2	a-win	yes
1821	1405353	2025-07-27	Panama	Liga Panameña de Fútbol	Independiente de La Chorrera	Herrera	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 07:14:41.785182	\N	\N	1	0	h-win	yes
1822	1405354	2025-07-27	Panama	Liga Panameña de Fútbol	Plaza Amador	Tauro FC	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 07:14:41.792718	\N	\N	0	1	a-win	yes
1823	1405428	2025-07-27	Panama	Liga Panameña de Fútbol	SD Atletico Nacional	Veraguas	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 07:14:41.802349	\N	\N	0	1	a-win	yes
1824	1405355	2025-07-28	Panama	Liga Panameña de Fútbol	Alianza FC	Sporting San Miguelito	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 07:14:41.809396	\N	\N	2	1	h-win	yes
1825	1405356	2025-07-29	Panama	Liga Panameña de Fútbol	UMECIT	CD Arabe Unido	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 07:14:41.819085	\N	\N	0	0	draw	yes
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
1896	1385757	2025-07-11	Romania	Liga I	Metaloglobus	Universitatea Cluj	a-win	1	4	11	2	14	6	1	7	2	0	3	1	0	0	43.00	57.00	8	9	\N	\N	\N	16	10	2025-11-20 08:14:42.932765	\N	\N	0	1	a-win	yes
1897	1385762	2025-07-11	Romania	Liga I	Arges Pitesti	Rapid	a-win	0	2	13	2	9	5	7	1	1	0	5	4	0	0	47.00	53.00	23	16	\N	\N	\N	5	1	2025-11-20 08:14:43.124696	\N	\N	0	2	a-win	yes
1898	1385756	2025-07-12	Romania	Liga I	Uta Arad	Universitatea Craiova	draw	3	3	21	6	13	4	4	3	0	2	3	3	0	0	48.00	52.00	11	12	\N	\N	\N	8	4	2025-11-20 08:14:43.359177	\N	\N	0	2	a-win	yes
1899	1385758	2025-07-12	Romania	Liga I	FCSB	AFC Hermannstadt	draw	1	1	24	6	8	3	13	1	1	0	0	1	0	0	65.00	35.00	9	8	\N	\N	\N	9	15	2025-11-20 08:14:43.610547	\N	\N	0	0	draw	yes
1900	1385759	2025-07-13	Romania	Liga I	Oţelul	Petrolul Ploiesti	draw	0	0	12	1	6	2	4	3	2	1	1	1	0	0	52.00	48.00	9	19	\N	\N	\N	7	13	2025-11-20 08:14:43.804836	\N	\N	0	0	draw	yes
1901	1385763	2025-07-13	Romania	Liga I	CFR 1907 Cluj	Unirea Slobozia	h-win	2	1	10	4	12	3	5	2	2	1	1	1	0	0	60.00	40.00	14	16	\N	\N	\N	12	11	2025-11-20 08:14:43.981983	\N	\N	1	1	draw	yes
1902	1385760	2025-07-14	Romania	Liga I	FC Botosani	Farul Constanta	draw	1	1	11	2	14	4	7	6	2	2	0	6	0	1	53.00	47.00	13	17	\N	\N	\N	2	6	2025-11-20 08:14:44.160765	\N	\N	0	0	draw	yes
1903	1385761	2025-07-14	Romania	Liga I	Csikszereda	Dinamo Bucuresti	draw	2	2	5	3	17	10	0	9	2	1	1	2	0	0	27.00	73.00	13	11	\N	\N	\N	14	3	2025-11-20 08:14:44.331997	\N	\N	2	2	draw	yes
1904	1385765	2025-07-18	Romania	Liga I	AFC Hermannstadt	Metaloglobus	draw	2	2	15	4	10	4	5	3	2	1	1	2	0	0	51.00	49.00	8	12	\N	\N	\N	15	16	2025-11-20 08:14:44.571939	0.99	0.69	2	0	h-win	yes
1905	1385770	2025-07-18	Romania	Liga I	Universitatea Craiova	Arges Pitesti	h-win	3	1	8	2	11	2	1	4	1	0	2	4	0	0	65.00	35.00	13	20	\N	\N	\N	4	5	2025-11-20 08:14:44.759197	1.46	0.80	2	1	h-win	yes
1906	1385764	2025-07-19	Romania	Liga I	Universitatea Cluj	Uta Arad	draw	1	1	25	5	15	6	4	2	1	0	2	2	0	0	70.00	30.00	8	9	\N	\N	\N	10	8	2025-11-20 08:14:44.951274	\N	\N	0	1	a-win	yes
1907	1385766	2025-07-19	Romania	Liga I	Petrolul Ploiesti	FCSB	a-win	0	1	14	1	13	5	5	6	5	2	3	4	0	0	49.00	51.00	19	15	\N	\N	\N	13	9	2025-11-20 08:14:45.127778	\N	\N	0	0	draw	yes
1908	1385767	2025-07-20	Romania	Liga I	Farul Constanta	Oţelul	h-win	3	2	9	3	20	6	5	7	4	0	0	2	1	0	50.00	50.00	8	9	\N	\N	\N	6	7	2025-11-20 08:14:45.359032	\N	\N	2	1	h-win	yes
1909	1385771	2025-07-20	Romania	Liga I	Rapid	CFR 1907 Cluj	draw	1	1	24	7	15	3	5	4	0	0	1	2	0	0	58.00	42.00	6	15	\N	\N	\N	1	12	2025-11-20 08:14:45.56442	\N	\N	0	1	a-win	yes
1910	1385769	2025-07-21	Romania	Liga I	Unirea Slobozia	Csikszereda	h-win	6	1	20	11	16	6	2	1	3	1	0	0	0	1	60.00	40.00	11	6	\N	\N	\N	11	14	2025-11-20 08:14:45.760071	\N	\N	2	1	h-win	yes
1911	1385768	2025-07-21	Romania	Liga I	Dinamo Bucuresti	FC Botosani	draw	0	0	12	3	7	1	7	5	4	1	0	2	0	0	55.00	45.00	10	20	\N	\N	\N	3	2	2025-11-20 08:14:46.061813	\N	\N	0	0	draw	yes
1912	1385773	2025-07-25	Romania	Liga I	Metaloglobus	Petrolul Ploiesti	a-win	0	3	17	8	10	5	10	0	0	0	2	1	0	0	61.00	39.00	13	14	\N	\N	\N	16	13	2025-11-20 08:14:46.23929	1.80	2.26	0	3	a-win	yes
1913	1385777	2025-07-25	Romania	Liga I	Csikszereda	Rapid	a-win	0	2	17	4	15	8	5	3	3	2	1	2	0	0	38.00	62.00	9	10	\N	\N	\N	14	1	2025-11-20 08:14:46.433492	1.66	2.86	0	2	a-win	yes
1914	1385772	2025-07-26	Romania	Liga I	Uta Arad	AFC Hermannstadt	h-win	1	0	10	3	10	1	5	5	1	2	1	1	0	0	52.00	48.00	13	5	\N	\N	\N	8	15	2025-11-20 08:14:46.641148	\N	\N	1	0	h-win	yes
1915	1385774	2025-07-26	Romania	Liga I	FCSB	Farul Constanta	a-win	1	2	8	3	21	8	2	8	4	1	5	1	1	0	55.00	45.00	17	12	\N	\N	\N	9	6	2025-11-20 08:14:46.845662	\N	\N	1	0	h-win	yes
1916	1385778	2025-07-27	Romania	Liga I	CFR 1907 Cluj	Arges Pitesti	a-win	0	2	12	1	11	4	8	4	2	1	2	3	0	0	63.00	37.00	13	9	\N	\N	\N	12	5	2025-11-20 08:14:47.048618	\N	\N	0	1	a-win	yes
1917	1385775	2025-07-27	Romania	Liga I	Oţelul	Dinamo Bucuresti	h-win	2	1	11	4	16	6	8	3	1	0	1	3	0	0	35.00	65.00	12	6	\N	\N	\N	7	3	2025-11-20 08:14:47.25227	\N	\N	1	0	h-win	yes
1918	1385776	2025-07-28	Romania	Liga I	FC Botosani	Unirea Slobozia	h-win	4	0	7	4	8	3	2	4	3	8	3	1	1	0	52.00	48.00	14	7	\N	\N	\N	2	11	2025-11-20 08:14:47.491998	\N	\N	2	0	h-win	yes
1919	1385779	2025-07-28	Romania	Liga I	Universitatea Craiova	Universitatea Cluj	h-win	2	1	23	5	12	6	5	5	2	0	0	2	0	0	62.00	38.00	7	14	\N	\N	\N	4	10	2025-11-20 08:14:47.695665	\N	\N	0	1	a-win	yes
1920	1384891	2025-07-19	Serbia	Super Liga	FK Crvena Zvezda	Javor	h-win	4	0	30	9	5	3	9	1	2	0	0	0	0	0	68.00	32.00	13	12	\N	\N	\N	2	10	2025-11-20 08:14:50.198682	\N	\N	2	0	h-win	yes
1921	1384892	2025-07-19	Serbia	Super Liga	Cukaricki	Napredak	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	16	2025-11-20 08:14:50.216746	\N	\N	0	0	draw	yes
1922	1384893	2025-07-20	Serbia	Super Liga	Mladost Lucani	IMT Novi Beograd	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	11	8	2025-11-20 08:14:50.223434	\N	\N	1	1	draw	yes
1923	1384897	2025-07-20	Serbia	Super Liga	Vojvodina	Radnik Surdulica	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	9	2025-11-20 08:14:50.22867	\N	\N	1	0	h-win	yes
1924	1384896	2025-07-20	Serbia	Super Liga	TSC Backa Topola	Radnicki NIS	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	13	14	2025-11-20 08:14:50.233963	\N	\N	1	1	draw	yes
1925	1384898	2025-07-20	Serbia	Super Liga	Železničar Pančevo	FK Partizan	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	1	2025-11-20 08:14:50.240821	\N	\N	0	0	draw	yes
1926	1384895	2025-07-21	Serbia	Super Liga	OFK Beograd	FK Spartak Zdrepceva KRV	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7	15	2025-11-20 08:14:50.246407	\N	\N	1	1	draw	yes
1927	1384899	2025-07-26	Serbia	Super Liga	FK Crvena Zvezda	OFK Beograd	h-win	7	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	7	2025-11-20 08:14:50.25307	\N	\N	2	0	h-win	yes
1928	1384904	2025-07-26	Serbia	Super Liga	Radnicki NIS	Mladost Lucani	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	14	11	2025-11-20 08:14:50.258243	\N	\N	1	0	h-win	yes
1929	1384905	2025-07-26	Serbia	Super Liga	Radnik Surdulica	TSC Backa Topola	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	13	2025-11-20 08:14:50.263301	\N	\N	0	0	draw	yes
1930	1384902	2025-07-27	Serbia	Super Liga	Napredak	Novi Pazar	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16	5	2025-11-20 08:14:50.270845	\N	\N	1	0	h-win	yes
1931	1384903	2025-07-27	Serbia	Super Liga	Radnicki 1923	Železničar Pančevo	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	4	2025-11-20 08:14:50.276038	\N	\N	1	0	h-win	yes
1932	1384900	2025-07-27	Serbia	Super Liga	IMT Novi Beograd	Cukaricki	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8	6	2025-11-20 08:14:50.28142	\N	\N	1	3	a-win	yes
1933	1384906	2025-07-27	Serbia	Super Liga	FK Spartak Zdrepceva KRV	Vojvodina	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	15	3	2025-11-20 08:14:50.289046	\N	\N	0	1	a-win	yes
1934	1410121	2025-07-25	Slovakia	2. liga	Dukla Banská Bystrica	Slávia TU Košice	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	13	2025-11-20 09:15:11.603481	\N	\N	1	0	h-win	yes
1935	1394743	2025-07-25	Slovakia	2. liga	Púchov	Slovan Bratislava II	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16	14	2025-11-20 09:15:11.834297	\N	\N	0	1	a-win	yes
1936	1394739	2025-07-25	Slovakia	2. liga	Pohronie	Malženice	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	11	2025-11-20 09:15:12.000344	\N	\N	0	0	draw	yes
1937	1410122	2025-07-26	Slovakia	2. liga	Liptovský Mikuláš	Baník Lehota p.Vtáčnikom	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	12	2025-11-20 09:15:12.188084	\N	\N	1	0	h-win	yes
1938	1394744	2025-07-26	Slovakia	2. liga	Šamorín	Žilina II	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	10	8	2025-11-20 09:15:12.372166	\N	\N	0	1	a-win	yes
1939	1394740	2025-07-26	Slovakia	2. liga	Inter Bratislava	Zlaté Moravce	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7	2	2025-11-20 09:15:12.557261	\N	\N	1	0	h-win	yes
1940	1410123	2025-07-26	Slovakia	2. liga	Lokomotíva Zvolen	Stará Ľubovňa	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	15	2025-11-20 09:15:12.743155	\N	\N	0	1	a-win	yes
1941	1384102	2025-07-26	Slovakia	Super Liga	Dunajska Streda	Zemplín Michalovce	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	5	2025-11-20 09:15:14.13221	\N	\N	0	1	a-win	yes
1942	1384099	2025-07-26	Slovakia	Super Liga	Komárno	AS Trencin	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	7	2025-11-20 09:15:14.333302	\N	\N	1	1	draw	yes
1943	1384101	2025-07-26	Slovakia	Super Liga	Tatran Prešov	Slovan Bratislava	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8	2	2025-11-20 09:15:14.531847	\N	\N	1	2	a-win	yes
1944	1384100	2025-07-27	Slovakia	Super Liga	Podbrezová	FK Košice	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	12	2025-11-20 09:15:14.748861	\N	\N	1	0	h-win	yes
1945	1384103	2025-07-27	Slovakia	Super Liga	Skalica	Žilina	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	10	1	2025-11-20 09:15:14.949044	\N	\N	0	0	draw	yes
1946	1384104	2025-07-27	Slovakia	Super Liga	Spartak Trnava	Ružomberok	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	11	2025-11-20 09:15:15.133112	\N	\N	1	0	h-win	yes
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
2529	1395839	2025-08-15	Poland	II Liga - East	Chojniczanka Chojnice	Podbeskidzie	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	11	12	2025-11-20 13:03:59.367057	\N	\N	0	0	draw	yes
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
2510	1395820	2025-08-01	Poland	II Liga - East	Rekord Bielsko-Biała	Podhale Nowy Targ	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	13	4	2025-11-20 13:03:55.624826	\N	\N	0	1	a-win	yes
2511	1395827	2025-08-01	Poland	II Liga - East	Stal Stalowa Wola	Podbeskidzie	h-win	5	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	12	2025-11-20 13:03:55.845525	\N	\N	3	0	h-win	yes
2512	1395826	2025-08-02	Poland	II Liga - East	Śląsk Wrocław II	Hutnik Kraków	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7	15	2025-11-20 13:03:56.053917	\N	\N	0	0	draw	yes
2513	1395824	2025-08-02	Poland	II Liga - East	Sandecja Nowy Sącz	Świt Skolwin	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8	5	2025-11-20 13:03:56.236773	\N	\N	2	1	h-win	yes
2514	1395828	2025-08-02	Poland	II Liga - East	Zaglebie Sosnowiec	Resovia Rzeszów	a-win	1	5	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	10	2025-11-20 13:03:56.432513	\N	\N	1	2	a-win	yes
2515	1395822	2025-08-02	Poland	II Liga - East	Jastrzębie	ŁKS Łódź II	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	18	17	2025-11-20 13:03:56.601697	\N	\N	0	1	a-win	yes
2516	1395825	2025-08-02	Poland	II Liga - East	Unia Skierniewice	Olimpia Grudziądz	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	3	2025-11-20 13:03:56.781066	\N	\N	1	1	draw	yes
2517	1395823	2025-08-03	Poland	II Liga - East	Kalisz	Sokół Kleczew	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16	14	2025-11-20 13:03:56.981826	\N	\N	0	0	draw	yes
2518	1395821	2025-08-03	Poland	II Liga - East	Chojniczanka Chojnice	Warta Poznań	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	11	2	2025-11-20 13:03:57.227258	\N	\N	1	0	h-win	yes
2519	1395833	2025-08-08	Poland	II Liga - East	Podbeskidzie	Śląsk Wrocław II	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	7	2025-11-20 13:03:57.426621	\N	\N	0	0	draw	yes
2520	1395829	2025-08-09	Poland	II Liga - East	Hutnik Kraków	Resovia Rzeszów	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	15	10	2025-11-20 13:03:57.63567	\N	\N	1	1	draw	yes
2521	1395834	2025-08-09	Poland	II Liga - East	Sandecja Nowy Sącz	Rekord Bielsko-Biała	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8	13	2025-11-20 13:03:57.823649	\N	\N	1	0	h-win	yes
2522	1395830	2025-08-09	Poland	II Liga - East	Sokół Kleczew	Jastrzębie	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	14	18	2025-11-20 13:03:58.00107	\N	\N	2	0	h-win	yes
2523	1395836	2025-08-09	Poland	II Liga - East	Stal Stalowa Wola	Kalisz	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	16	2025-11-20 13:03:58.184306	\N	\N	1	0	h-win	yes
2524	1395831	2025-08-10	Poland	II Liga - East	ŁKS Łódź II	Chojniczanka Chojnice	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	17	11	2025-11-20 13:03:58.375664	\N	\N	0	0	draw	yes
2525	1395835	2025-08-10	Poland	II Liga - East	Świt Skolwin	Warta Poznań	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	2	2025-11-20 13:03:58.564854	\N	\N	1	1	draw	yes
2526	1395832	2025-08-10	Poland	II Liga - East	Olimpia Grudziądz	Podhale Nowy Targ	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	4	2025-11-20 13:03:58.754716	\N	\N	0	1	a-win	yes
2527	1395837	2025-08-10	Poland	II Liga - East	Zaglebie Sosnowiec	Unia Skierniewice	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	1	2025-11-20 13:03:58.953635	\N	\N	0	1	a-win	yes
2528	1395840	2025-08-15	Poland	II Liga - East	Jastrzębie	Sandecja Nowy Sącz	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	18	8	2025-11-20 13:03:59.15601	\N	\N	2	2	draw	yes
2530	1395838	2025-08-15	Poland	II Liga - East	Rekord Bielsko-Biała	Sokół Kleczew	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	13	14	2025-11-20 13:03:59.557829	\N	\N	2	0	h-win	yes
2531	1395844	2025-08-15	Poland	II Liga - East	Resovia Rzeszów	Olimpia Grudziądz	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	10	3	2025-11-20 13:03:59.749151	\N	\N	1	1	draw	yes
2532	1395845	2025-08-15	Poland	II Liga - East	Unia Skierniewice	Świt Skolwin	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	5	2025-11-20 13:03:59.932022	\N	\N	0	1	a-win	yes
2533	1395846	2025-08-16	Poland	II Liga - East	Śląsk Wrocław II	Zaglebie Sosnowiec	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7	9	2025-11-20 13:04:00.124285	\N	\N	0	1	a-win	yes
2534	1395842	2025-08-17	Poland	II Liga - East	ŁKS Łódź II	Warta Poznań	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	17	2	2025-11-20 13:04:00.325113	\N	\N	0	0	draw	yes
2535	1395843	2025-08-17	Poland	II Liga - East	Podhale Nowy Targ	Stal Stalowa Wola	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	6	2025-11-20 13:04:00.541953	\N	\N	0	1	a-win	yes
2536	1395841	2025-08-17	Poland	II Liga - East	Kalisz	Hutnik Kraków	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16	15	2025-11-20 13:04:00.747766	\N	\N	0	0	draw	yes
2537	1395855	2025-08-22	Poland	II Liga - East	Rekord Bielsko-Biała	Warta Poznań	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	13	2	2025-11-20 13:04:00.94776	\N	\N	1	0	h-win	yes
2538	1396000	2025-08-22	Poland	II Liga - East	Rekord Bielsko-Biała	Warta Poznań	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	13	2	2025-11-20 13:04:01.137531	\N	\N	1	0	h-win	yes
2539	1395849	2025-08-22	Poland	II Liga - East	Sokół Kleczew	Resovia Rzeszów	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	14	10	2025-11-20 13:04:01.343359	\N	\N	1	0	h-win	yes
2540	1395854	2025-08-22	Poland	II Liga - East	Stal Stalowa Wola	Unia Skierniewice	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	1	2025-11-20 13:04:01.552496	\N	\N	1	1	draw	yes
2541	1395852	2025-08-23	Poland	II Liga - East	Podhale Nowy Targ	Zaglebie Sosnowiec	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	9	2025-11-20 13:04:01.75823	\N	\N	1	1	draw	yes
2542	1395848	2025-08-23	Poland	II Liga - East	Hutnik Kraków	Sandecja Nowy Sącz	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	15	8	2025-11-20 13:04:01.946431	\N	\N	0	0	draw	yes
2543	1395853	2025-08-23	Poland	II Liga - East	Świt Skolwin	Jastrzębie	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	18	2025-11-20 13:04:02.13654	\N	\N	2	0	h-win	yes
2544	1395847	2025-08-23	Poland	II Liga - East	Chojniczanka Chojnice	Kalisz	draw	3	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	11	16	2025-11-20 13:04:02.322752	\N	\N	1	0	h-win	yes
2545	1395851	2025-08-23	Poland	II Liga - East	Podbeskidzie	ŁKS Łódź II	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	17	2025-11-20 13:04:02.51241	\N	\N	0	0	draw	yes
2546	1395850	2025-08-24	Poland	II Liga - East	Olimpia Grudziądz	Śląsk Wrocław II	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	7	2025-11-20 13:04:02.705991	\N	\N	2	0	h-win	yes
2547	1395859	2025-08-29	Poland	II Liga - East	Resovia Rzeszów	Podhale Nowy Targ	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	10	4	2025-11-20 13:04:02.894903	\N	\N	0	0	draw	yes
2548	1395861	2025-08-29	Poland	II Liga - East	Unia Skierniewice	Rekord Bielsko-Biała	h-win	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	13	2025-11-20 13:04:03.082563	\N	\N	2	0	h-win	yes
2549	1395858	2025-08-30	Poland	II Liga - East	Podbeskidzie	Hutnik Kraków	draw	3	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	15	2025-11-20 13:04:03.276753	\N	\N	2	2	draw	yes
2550	1395857	2025-08-30	Poland	II Liga - East	Kalisz	ŁKS Łódź II	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16	17	2025-11-20 13:04:03.470721	\N	\N	0	0	draw	yes
2551	1395862	2025-08-30	Poland	II Liga - East	Śląsk Wrocław II	Stal Stalowa Wola	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7	6	2025-11-20 13:04:03.654513	\N	\N	2	2	draw	yes
2552	1395856	2025-08-30	Poland	II Liga - East	Jastrzębie	Warta Poznań	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	18	2	2025-11-20 13:04:03.841015	\N	\N	1	0	h-win	yes
2553	1395864	2025-08-31	Poland	II Liga - East	Zaglebie Sosnowiec	Olimpia Grudziądz	draw	3	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	3	2025-11-20 13:04:04.02264	\N	\N	1	2	a-win	yes
2554	1395860	2025-08-31	Poland	II Liga - East	Sandecja Nowy Sącz	Chojniczanka Chojnice	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8	11	2025-11-20 13:04:04.210794	\N	\N	1	1	draw	yes
2555	1395863	2025-09-03	Poland	II Liga - East	Świt Skolwin	Sokół Kleczew	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	14	2025-11-20 13:04:04.387757	\N	\N	1	1	draw	yes
2556	1395871	2025-09-05	Poland	II Liga - East	Resovia Rzeszów	Śląsk Wrocław II	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	10	7	2025-11-20 13:04:04.59438	\N	\N	1	1	draw	yes
2557	1395870	2025-09-06	Poland	II Liga - East	Podhale Nowy Targ	Unia Skierniewice	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	1	2025-11-20 13:04:04.763424	\N	\N	1	0	h-win	yes
2558	1395865	2025-09-06	Poland	II Liga - East	Rekord Bielsko-Biała	Kalisz	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	13	16	2025-11-20 13:04:04.948091	\N	\N	0	1	a-win	yes
2559	1395873	2025-09-07	Poland	II Liga - East	Warta Poznań	Zaglebie Sosnowiec	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	9	2025-11-20 13:04:05.134777	\N	\N	0	0	draw	yes
2560	1395872	2025-09-07	Poland	II Liga - East	Stal Stalowa Wola	Świt Skolwin	h-win	5	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	5	2025-11-20 13:04:05.330178	\N	\N	2	2	draw	yes
2561	1395877	2025-09-12	Poland	II Liga - East	Sokół Kleczew	Podhale Nowy Targ	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	14	4	2025-11-20 13:04:05.522842	\N	\N	0	1	a-win	yes
2562	1395878	2025-09-12	Poland	II Liga - East	ŁKS Łódź II	Olimpia Grudziądz	a-win	2	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	17	3	2025-11-20 13:04:05.71265	\N	\N	1	2	a-win	yes
2563	1395880	2025-09-12	Poland	II Liga - East	Unia Skierniewice	Hutnik Kraków	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	15	2025-11-20 13:04:05.878915	\N	\N	1	0	h-win	yes
2564	1395875	2025-09-13	Poland	II Liga - East	Jastrzębie	Chojniczanka Chojnice	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	18	11	2025-11-20 13:04:06.072877	\N	\N	0	0	draw	yes
2565	1395874	2025-09-13	Poland	II Liga - East	Rekord Bielsko-Biała	Zaglebie Sosnowiec	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	13	9	2025-11-20 13:04:06.271103	\N	\N	1	2	a-win	yes
2566	1395879	2025-09-13	Poland	II Liga - East	Sandecja Nowy Sącz	Stal Stalowa Wola	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8	6	2025-11-20 13:04:06.442041	\N	\N	1	1	draw	yes
2567	1395882	2025-09-14	Poland	II Liga - East	Świt Skolwin	Resovia Rzeszów	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	10	2025-11-20 13:04:06.613814	\N	\N	1	1	draw	yes
2568	1395881	2025-09-14	Poland	II Liga - East	Śląsk Wrocław II	Warta Poznań	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7	2	2025-11-20 13:04:06.810583	\N	\N	0	0	draw	yes
2569	1395876	2025-09-14	Poland	II Liga - East	Kalisz	Podbeskidzie	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16	12	2025-11-20 13:04:07.001082	\N	\N	0	1	a-win	yes
2570	1395868	2025-09-16	Poland	II Liga - East	ŁKS Łódź II	Sandecja Nowy Sącz	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	17	8	2025-11-20 13:04:07.18069	\N	\N	1	0	h-win	yes
2571	1395867	2025-09-17	Poland	II Liga - East	Hutnik Kraków	Jastrzębie	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	15	18	2025-11-20 13:04:07.367633	\N	\N	0	0	draw	yes
2572	1395866	2025-09-17	Poland	II Liga - East	Chojniczanka Chojnice	Sokół Kleczew	a-win	1	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	11	14	2025-11-20 13:04:07.553819	\N	\N	0	1	a-win	yes
2573	1395869	2025-09-17	Poland	II Liga - East	Olimpia Grudziądz	Podbeskidzie	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	12	2025-11-20 13:04:07.7323	\N	\N	0	0	draw	yes
2574	1395891	2025-09-19	Poland	II Liga - East	Zaglebie Sosnowiec	Świt Skolwin	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	5	2025-11-20 13:04:07.924486	\N	\N	0	0	draw	yes
2575	1395889	2025-09-19	Poland	II Liga - East	Stal Stalowa Wola	ŁKS Łódź II	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	17	2025-11-20 13:04:08.119175	\N	\N	1	1	draw	yes
2576	1395890	2025-09-20	Poland	II Liga - East	Warta Poznań	Sokół Kleczew	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	14	2025-11-20 13:04:08.29956	\N	\N	2	1	h-win	yes
2577	1395884	2025-09-20	Poland	II Liga - East	Hutnik Kraków	Rekord Bielsko-Biała	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	15	13	2025-11-20 13:04:08.48356	\N	\N	0	0	draw	yes
2578	1395883	2025-09-20	Poland	II Liga - East	Chojniczanka Chojnice	Śląsk Wrocław II	a-win	2	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	11	7	2025-11-20 13:04:08.668296	\N	\N	1	0	h-win	yes
2579	1395886	2025-09-20	Poland	II Liga - East	Podbeskidzie	Unia Skierniewice	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	1	2025-11-20 13:04:08.85413	\N	\N	2	0	h-win	yes
2580	1395885	2025-09-20	Poland	II Liga - East	Olimpia Grudziądz	Jastrzębie	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	18	2025-11-20 13:04:09.059323	\N	\N	1	0	h-win	yes
2581	1395887	2025-09-21	Poland	II Liga - East	Podhale Nowy Targ	Kalisz	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	16	2025-11-20 13:04:09.242527	\N	\N	1	1	draw	yes
2582	1395888	2025-09-21	Poland	II Liga - East	Resovia Rzeszów	Sandecja Nowy Sącz	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	10	8	2025-11-20 13:04:09.422775	\N	\N	0	1	a-win	yes
2583	1395900	2025-09-26	Poland	II Liga - East	Warta Poznań	Stal Stalowa Wola	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	6	2025-11-20 13:04:09.611912	\N	\N	1	0	h-win	yes
2584	1395894	2025-09-27	Poland	II Liga - East	Kalisz	Olimpia Grudziądz	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16	3	2025-11-20 13:04:09.806104	\N	\N	0	0	draw	yes
2585	1395898	2025-09-27	Poland	II Liga - East	Śląsk Wrocław II	Podhale Nowy Targ	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7	4	2025-11-20 13:04:10.016751	\N	\N	0	0	draw	yes
2586	1395899	2025-09-27	Poland	II Liga - East	Świt Skolwin	Chojniczanka Chojnice	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	11	2025-11-20 13:04:10.203752	\N	\N	1	1	draw	yes
2587	1395897	2025-09-27	Poland	II Liga - East	Sandecja Nowy Sącz	Unia Skierniewice	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8	1	2025-11-20 13:04:10.39053	\N	\N	1	1	draw	yes
2588	1395895	2025-09-28	Poland	II Liga - East	Sokół Kleczew	Hutnik Kraków	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	14	15	2025-11-20 13:04:10.57406	\N	\N	2	0	h-win	yes
2589	1395893	2025-09-28	Poland	II Liga - East	Jastrzębie	Resovia Rzeszów	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	18	10	2025-11-20 13:04:10.763598	\N	\N	0	0	draw	yes
2590	1396048	2025-09-28	Poland	II Liga - East	Podbeskidzie	Rekord Bielsko-Biała	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	13	2025-11-20 13:04:10.950581	\N	\N	1	2	a-win	yes
2591	1395896	2025-09-29	Poland	II Liga - East	ŁKS Łódź II	Zaglebie Sosnowiec	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	17	9	2025-11-20 13:04:11.180715	\N	\N	1	2	a-win	yes
2592	1395902	2025-10-03	Poland	II Liga - East	Kalisz	Sandecja Nowy Sącz	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16	8	2025-11-20 13:04:11.353853	\N	\N	1	0	h-win	yes
2593	1395905	2025-10-04	Poland	II Liga - East	Podhale Nowy Targ	ŁKS Łódź II	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	17	2025-11-20 13:04:11.538956	\N	\N	1	0	h-win	yes
2594	1395904	2025-10-04	Poland	II Liga - East	Podbeskidzie	Warta Poznań	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	2	2025-11-20 13:04:11.720864	\N	\N	0	1	a-win	yes
2595	1395907	2025-10-04	Poland	II Liga - East	Unia Skierniewice	Śląsk Wrocław II	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	7	2025-11-20 13:04:11.918232	\N	\N	0	1	a-win	yes
2596	1395908	2025-10-05	Poland	II Liga - East	Stal Stalowa Wola	Chojniczanka Chojnice	a-win	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	11	2025-11-20 13:04:12.098423	\N	\N	1	1	draw	yes
2597	1395901	2025-10-05	Poland	II Liga - East	Hutnik Kraków	Świt Skolwin	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	15	5	2025-11-20 13:04:12.283814	\N	\N	1	1	draw	yes
2598	1395906	2025-10-05	Poland	II Liga - East	Resovia Rzeszów	Rekord Bielsko-Biała	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	10	13	2025-11-20 13:04:12.471922	\N	\N	1	0	h-win	yes
2599	1395909	2025-10-05	Poland	II Liga - East	Zaglebie Sosnowiec	Jastrzębie	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	18	2025-11-20 13:04:12.654942	\N	\N	0	0	draw	yes
2600	1395903	2025-10-05	Poland	II Liga - East	Olimpia Grudziądz	Sokół Kleczew	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	14	2025-11-20 13:04:12.879985	\N	\N	0	0	draw	yes
2601	1395914	2025-10-10	Poland	II Liga - East	ŁKS Łódź II	Resovia Rzeszów	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	17	10	2025-11-20 13:04:13.064745	\N	\N	0	0	draw	yes
2602	1395917	2025-10-11	Poland	II Liga - East	Warta Poznań	Olimpia Grudziądz	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	3	2025-11-20 13:04:13.24064	\N	\N	1	1	draw	yes
2603	1395916	2025-10-11	Poland	II Liga - East	Świt Skolwin	Podhale Nowy Targ	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	4	2025-11-20 13:04:13.437933	\N	\N	2	0	h-win	yes
2604	1395913	2025-10-11	Poland	II Liga - East	Sokół Kleczew	Unia Skierniewice	a-win	1	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	14	1	2025-11-20 13:04:13.615744	\N	\N	0	2	a-win	yes
2605	1395912	2025-10-11	Poland	II Liga - East	Jastrzębie	Kalisz	a-win	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	18	16	2025-11-20 13:04:13.787645	\N	\N	0	0	draw	yes
2606	1395910	2025-10-12	Poland	II Liga - East	Rekord Bielsko-Biała	Stal Stalowa Wola	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	13	6	2025-11-20 13:04:13.949241	\N	\N	1	0	h-win	yes
2607	1395927	2025-10-17	Poland	II Liga - East	Warta Poznań	Hutnik Kraków	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	15	2025-11-20 13:04:14.103973	\N	\N	1	0	h-win	yes
2608	1395924	2025-10-17	Poland	II Liga - East	Unia Skierniewice	Jastrzębie	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	18	2025-11-20 13:04:14.26399	\N	\N	1	0	h-win	yes
2609	1395923	2025-10-18	Poland	II Liga - East	Podhale Nowy Targ	Sandecja Nowy Sącz	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	8	2025-11-20 13:04:14.448916	\N	\N	1	0	h-win	yes
2610	1395925	2025-10-18	Poland	II Liga - East	Śląsk Wrocław II	Sokół Kleczew	a-win	2	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7	14	2025-11-20 13:04:14.630021	\N	\N	0	3	a-win	yes
2611	1395919	2025-10-18	Poland	II Liga - East	Kalisz	Resovia Rzeszów	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16	10	2025-11-20 13:04:14.810886	\N	\N	0	0	draw	yes
2612	1395921	2025-10-19	Poland	II Liga - East	Olimpia Grudziądz	Chojniczanka Chojnice	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	11	2025-11-20 13:04:14.999804	\N	\N	1	1	draw	yes
2613	1395922	2025-10-19	Poland	II Liga - East	Podbeskidzie	Świt Skolwin	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	5	2025-11-20 13:04:15.187104	\N	\N	0	0	draw	yes
2614	1395920	2025-10-19	Poland	II Liga - East	ŁKS Łódź II	Rekord Bielsko-Biała	a-win	0	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	17	13	2025-11-20 13:04:15.385771	\N	\N	0	2	a-win	yes
2615	1395926	2025-10-19	Poland	II Liga - East	Stal Stalowa Wola	Zaglebie Sosnowiec	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	9	2025-11-20 13:04:15.581665	\N	\N	0	0	draw	yes
2616	1395915	2025-10-21	Poland	II Liga - East	Sandecja Nowy Sącz	Śląsk Wrocław II	a-win	0	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8	7	2025-11-20 13:04:15.775833	\N	\N	0	2	a-win	yes
2617	1395911	2025-10-22	Poland	II Liga - East	Chojniczanka Chojnice	Hutnik Kraków	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	11	15	2025-11-20 13:04:15.950373	\N	\N	1	1	draw	yes
2618	1395918	2025-10-22	Poland	II Liga - East	Zaglebie Sosnowiec	Podbeskidzie	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	12	2025-11-20 13:04:16.120481	\N	\N	1	0	h-win	yes
2619	1395936	2025-10-24	Poland	II Liga - East	Świt Skolwin	ŁKS Łódź II	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	17	2025-11-20 13:04:16.310054	\N	\N	2	0	h-win	yes
2620	1395932	2025-10-24	Poland	II Liga - East	Kalisz	Śląsk Wrocław II	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16	7	2025-11-20 13:04:16.487254	\N	\N	0	0	draw	yes
2621	1395931	2025-10-25	Poland	II Liga - East	Hutnik Kraków	Zaglebie Sosnowiec	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	15	9	2025-11-20 13:04:16.715115	\N	\N	0	0	draw	yes
2622	1395930	2025-10-25	Poland	II Liga - East	Jastrzębie	Podbeskidzie	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	18	12	2025-11-20 13:04:16.903527	\N	\N	1	1	draw	yes
2623	1395928	2025-10-25	Poland	II Liga - East	Rekord Bielsko-Biała	Olimpia Grudziądz	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	13	3	2025-11-20 13:04:17.100874	\N	\N	0	2	a-win	yes
2624	1395929	2025-10-25	Poland	II Liga - East	Chojniczanka Chojnice	Podhale Nowy Targ	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	11	4	2025-11-20 13:04:17.321442	\N	\N	0	0	draw	yes
2625	1395933	2025-10-26	Poland	II Liga - East	Sokół Kleczew	Stal Stalowa Wola	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	14	6	2025-11-20 13:04:17.501392	\N	\N	1	0	h-win	yes
2626	1395935	2025-10-26	Poland	II Liga - East	Sandecja Nowy Sącz	Warta Poznań	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8	2	2025-11-20 13:04:17.675605	\N	\N	0	0	draw	yes
2627	1395934	2025-10-26	Poland	II Liga - East	Resovia Rzeszów	Unia Skierniewice	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	10	1	2025-11-20 13:04:17.861396	\N	\N	0	1	a-win	yes
2628	1395938	2025-10-31	Poland	II Liga - East	Sokół Kleczew	Podbeskidzie	h-win	5	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	14	12	2025-11-20 13:04:18.046172	\N	\N	3	1	h-win	yes
2629	1395937	2025-10-31	Poland	II Liga - East	Rekord Bielsko-Biała	Jastrzębie	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	13	18	2025-11-20 13:04:18.238672	\N	\N	1	2	a-win	yes
2630	1395942	2025-10-31	Poland	II Liga - East	Śląsk Wrocław II	Świt Skolwin	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7	5	2025-11-20 13:04:18.424521	\N	\N	2	1	h-win	yes
2631	1395943	2025-10-31	Poland	II Liga - East	Stal Stalowa Wola	Resovia Rzeszów	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	10	2025-11-20 13:04:18.601543	\N	\N	0	0	draw	yes
2632	1395944	2025-10-31	Poland	II Liga - East	Warta Poznań	Kalisz	h-win	4	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	16	2025-11-20 13:04:18.781922	\N	\N	0	1	a-win	yes
2633	1395941	2025-10-31	Poland	II Liga - East	Unia Skierniewice	ŁKS Łódź II	h-win	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	17	2025-11-20 13:04:18.966423	\N	\N	2	0	h-win	yes
2634	1395945	2025-10-31	Poland	II Liga - East	Zaglebie Sosnowiec	Chojniczanka Chojnice	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	11	2025-11-20 13:04:19.151182	\N	\N	0	0	draw	yes
2635	1395940	2025-11-02	Poland	II Liga - East	Podhale Nowy Targ	Hutnik Kraków	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	15	2025-11-20 13:04:19.333398	\N	\N	0	0	draw	yes
2636	1395939	2025-11-02	Poland	II Liga - East	Olimpia Grudziądz	Sandecja Nowy Sącz	h-win	1	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	8	2025-11-20 13:04:19.518917	\N	\N	1	0	h-win	yes
2637	1395946	2025-11-07	Poland	II Liga - East	Chojniczanka Chojnice	Unia Skierniewice	a-win	1	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	11	1	2025-11-20 13:04:19.707591	\N	\N	0	1	a-win	yes
2638	1395952	2025-11-07	Poland	II Liga - East	Sandecja Nowy Sącz	Sokół Kleczew	h-win	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8	14	2025-11-20 13:04:19.885647	\N	\N	0	1	a-win	yes
2639	1395947	2025-11-08	Poland	II Liga - East	Jastrzębie	Stal Stalowa Wola	a-win	1	5	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	18	6	2025-11-20 13:04:20.084889	\N	\N	0	2	a-win	yes
2640	1395953	2025-11-08	Poland	II Liga - East	Świt Skolwin	Rekord Bielsko-Biała	h-win	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	13	2025-11-20 13:04:20.262166	\N	\N	1	2	a-win	yes
2641	1395954	2025-11-08	Poland	II Liga - East	Warta Poznań	Podhale Nowy Targ	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	4	2025-11-20 13:04:20.437252	\N	\N	0	0	draw	yes
2642	1395948	2025-11-09	Poland	II Liga - East	Hutnik Kraków	Olimpia Grudziądz	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	15	3	2025-11-20 13:04:20.62639	\N	\N	1	1	draw	yes
2643	1395951	2025-11-09	Poland	II Liga - East	Podbeskidzie	Resovia Rzeszów	h-win	3	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	10	2025-11-20 13:04:20.807234	\N	\N	1	0	h-win	yes
2644	1395949	2025-11-09	Poland	II Liga - East	Kalisz	Zaglebie Sosnowiec	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16	9	2025-11-20 13:04:20.989093	\N	\N	1	0	h-win	yes
2645	1395950	2025-11-10	Poland	II Liga - East	ŁKS Łódź II	Śląsk Wrocław II	a-win	1	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	17	7	2025-11-20 13:04:21.173195	\N	\N	0	2	a-win	yes
2646	1395962	2025-11-14	Poland	II Liga - East	Stal Stalowa Wola	Hutnik Kraków	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.75	3.50	3.75	6	15	2025-11-20 13:04:21.349679	\N	\N	1	1	draw	yes
2647	1395957	2025-11-15	Poland	II Liga - East	Olimpia Grudziądz	Świt Skolwin	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.50	3.85	5.00	3	5	2025-11-20 13:04:21.533533	\N	\N	0	1	a-win	yes
2648	1395958	2025-11-16	Poland	II Liga - East	Podhale Nowy Targ	Podbeskidzie	h-win	2	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2.05	3.20	3.10	4	12	2025-11-20 13:04:21.749682	\N	\N	1	0	h-win	yes
2649	1395961	2025-11-16	Poland	II Liga - East	Śląsk Wrocław II	Jastrzębie	draw	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.50	4.20	4.50	7	18	2025-11-20 13:04:21.959053	\N	\N	1	2	a-win	yes
2650	1395955	2025-11-16	Poland	II Liga - East	Rekord Bielsko-Biała	Chojniczanka Chojnice	a-win	0	5	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2.55	3.30	2.33	13	11	2025-11-20 13:04:22.140502	\N	\N	0	3	a-win	yes
2651	1395960	2025-11-16	Poland	II Liga - East	Unia Skierniewice	Kalisz	draw	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.40	3.95	6.80	1	16	2025-11-20 13:04:22.328365	\N	\N	1	1	draw	yes
2652	1395959	2025-11-16	Poland	II Liga - East	Resovia Rzeszów	Warta Poznań	a-win	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2.25	3.20	2.80	10	2	2025-11-20 13:04:22.508111	\N	\N	0	1	a-win	yes
2653	1395963	2025-11-15	Poland	II Liga - East	Zaglebie Sosnowiec	Sandecja Nowy Sącz	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 13:04:22.698674	\N	\N	0	0	draw	no
2654	1395968	2025-11-21	Poland	II Liga - East	ŁKS Łódź II	Hutnik Kraków	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2.90	3.10	2.15	\N	\N	2025-11-20 13:04:22.892725	\N	\N	0	0	draw	no
2655	1395972	2025-11-21	Poland	II Liga - East	Zaglebie Sosnowiec	Sokół Kleczew	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.75	3.30	3.90	\N	\N	2025-11-20 13:04:23.079295	\N	\N	0	0	draw	no
2656	1395967	2025-11-22	Poland	II Liga - East	Kalisz	Świt Skolwin	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2.20	3.40	2.70	\N	\N	2025-11-20 13:04:23.280022	\N	\N	0	0	draw	no
2657	1395966	2025-11-22	Poland	II Liga - East	Jastrzębie	Podhale Nowy Targ	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4.75	3.70	1.57	\N	\N	2025-11-20 13:04:23.494662	\N	\N	0	0	draw	no
2658	1395964	2025-11-22	Poland	II Liga - East	Rekord Bielsko-Biała	Śląsk Wrocław II	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2.30	3.40	2.60	\N	\N	2025-11-20 13:04:23.686968	\N	\N	0	0	draw	no
2659	1395971	2025-11-22	Poland	II Liga - East	Warta Poznań	Unia Skierniewice	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 13:04:23.709727	\N	\N	0	0	draw	no
2660	1395965	2025-11-22	Poland	II Liga - East	Chojniczanka Chojnice	Resovia Rzeszów	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 13:04:23.726118	\N	\N	0	0	draw	no
2661	1395969	2025-11-23	Poland	II Liga - East	Sandecja Nowy Sącz	Podbeskidzie	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 13:04:23.738694	\N	\N	0	0	draw	no
2662	1395970	2025-11-23	Poland	II Liga - East	Stal Stalowa Wola	Olimpia Grudziądz	draw	0	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-20 13:04:23.747217	\N	\N	0	0	draw	no
\.


--
-- Name: import_jobs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.import_jobs_id_seq', 27, true);


--
-- Name: matches_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.matches_id_seq', 2662, true);


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

\unrestrict Qh2jMKXXJ6xK8LVcHRawB7jdM80rfdPJmdXwZVRbX0dudgrHdMduoSiFOMsIdt5

