--
-- PostgreSQL database dump
--

\restrict sZY3Wiv3atDHuH8eemJChlrQZoI5Cm6wfsMlJzw8WeG6rEzpxX8RMScCApnjmJI

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

--
-- Data for Name: coupons; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.coupons VALUES (1, 'FC Eindhoven', 'Jong PSV U21', 'corners_match_over', '10.5', '52,50%', 1.00, 0.00, '60%', '20%', '40%', '60%', '70%', '50%', '40%', '80%', '67%', '67%', 'za mało danych', 'za mało danych', NULL, NULL, NULL, NULL, 15, '4', NULL, 'Netherlands', '2025-12-06', 'Eerste Divisie', 17061, 'K0004', 'https://flashscore.pl/pilka-nozna/holandia/eerste-divisie/', 10.00, 45.00, '2025-12-08 21:26:12.244+01', '2025-12-08 21:26:12.244+01');
INSERT INTO public.coupons VALUES (2, 'Lechia Gdansk', 'Gornik Zabrze', 'bts', 'tak', '76,50%', 1.00, 1.00, '100%', '60%', '100%', '60%', '90%', '80%', '78%', '44%', '73%', '53%', 'za mało danych', 'za mało danych', NULL, NULL, NULL, NULL, 12, '1', NULL, 'Poland', '2025-12-06', 'Ekstraklasa', 16635, 'K0004', 'https://flashscore.pl/pilka-nozna/polska/ekstraklasa/', 10.00, 45.00, '2025-12-08 21:26:12.256+01', '2025-12-08 21:26:12.256+01');
INSERT INTO public.coupons VALUES (3, 'Tychy 71', 'Polonia Warszawa', '2', '-', '61,30%', 2.00, 1.00, '80%', '80%', '60%', '40%', '80%', '50%', '60%', '40%', '73%', '40%', 'za mało danych', 'za mało danych', NULL, NULL, NULL, NULL, 17, '6', NULL, 'Poland', '2025-12-06', 'I Liga', 16644, 'K0004', 'https://flashscore.pl/pilka-nozna/polska/1liga/', 10.00, 45.00, '2025-12-08 21:26:12.258+01', '2025-12-08 21:26:12.258+01');


--
-- Name: coupons_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.coupons_id_seq', 3, true);


--
-- PostgreSQL database dump complete
--

\unrestrict sZY3Wiv3atDHuH8eemJChlrQZoI5Cm6wfsMlJzw8WeG6rEzpxX8RMScCApnjmJI

