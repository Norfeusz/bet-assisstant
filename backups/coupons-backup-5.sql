--
-- PostgreSQL database dump
--

\restrict qOelSRmLLYHhmfkSBzw01jNL9K1c7eI5aKK1vFKCIisg8f9b7xzLqJLGa7Drz1S

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
INSERT INTO public.coupons VALUES (4, 'Auckland', 'Wellington Phoenix', 'bts', 'tak', '83,40%', 1.00, 1.00, '100%', '80%', '80%', 'za mało danych', '71%', '86%', 'za mało danych', 'za mało danych', 'za mało danych', 'za mało danych', 'za mało danych', 'za mało danych', NULL, NULL, NULL, NULL, 2, '7', NULL, 'Australia', '2025-12-06', 'A-League', 17094, 'K0003', 'https://flashscore.pl/pilka-nozna/australia/a-league/', 10.00, 46.12, '2025-12-09 12:14:14.462+01', '2025-12-09 12:14:14.462+01');
INSERT INTO public.coupons VALUES (5, 'Coquimbo Unido', 'Union Espanola', '1', '-', '81,90%', 1.00, 1.00, '80%', '80%', '100%', '60%', '90%', '70%', '100%', '75%', '93%', '60%', 'za mało danych', 'za mało danych', NULL, NULL, NULL, NULL, 1, '16', NULL, 'Chile', '2025-12-06', 'Primera División', 17176, 'K0003', 'https://flashscore.pl/pilka-nozna/chile/primera-division/', 10.00, 46.12, '2025-12-09 12:14:14.468+01', '2025-12-09 12:14:14.468+01');
INSERT INTO public.coupons VALUES (6, 'Erokspor', 'Sakaryaspor', 'bts', 'tak', '87,10%', 1.00, 1.00, '100%', '100%', '100%', '80%', '80%', '70%', '78%', '89%', '67%', '80%', 'za mało danych', 'za mało danych', NULL, NULL, NULL, NULL, 3, '14', NULL, 'Turkey', '2025-12-06', '1. Lig', 17068, 'K0003', 'https://flashscore.pl/pilka-nozna/turcja/1-lig/', 10.00, 46.12, '2025-12-09 12:14:14.47+01', '2025-12-09 12:14:14.47+01');
INSERT INTO public.coupons VALUES (7, 'Adama Kenema', 'Kedus Giorgis', 'goals_under', '2.5', '89,70%', 1.00, 1.00, '80%', '100%', '100%', '80%', '89%', '89%', 'za mało danych', 'za mało danych', 'za mało danych', 'za mało danych', 'za mało danych', 'za mało danych', NULL, NULL, 1, 0, 4, '5', NULL, 'Ethiopia', '2025-12-06', 'Premier League', 17223, 'K0004', 'https://flashscore.pl/pilka-nozna/etiopia/premier-league/', 10.00, 40.39, '2025-12-09 13:11:12.661+01', '2025-12-09 13:11:12.661+01');
INSERT INTO public.coupons VALUES (8, 'Estac Troyes', 'Rodez', 'bts', 'tak', '76,30%', 1.00, 1.00, '80%', '80%', '80%', '80%', '70%', '90%', '67%', '63%', '53%', '67%', 'za mało danych', 'za mało danych', NULL, NULL, 1, 1, 1, '13', NULL, 'France', '2025-12-06', 'Ligue 2', 16999, 'K0004', 'https://flashscore.pl/pilka-nozna/francja/ligue-2/', 10.00, 40.39, '2025-12-09 13:11:12.665+01', '2025-12-09 13:11:12.665+01');
INSERT INTO public.coupons VALUES (9, 'Grasshoppers', 'Servette FC', 'goals_over', '2.5', '58,50%', 1.00, 1.00, '20%', '60%', '40%', '80%', '50%', '80%', '63%', '75%', '53%', '73%', 'za mało danych', 'za mało danych', NULL, NULL, 0, 1, 11, '9', NULL, 'Switzerland', '2025-06-11', 'Super League', 17411, 'K0004', NULL, 10.00, 40.39, '2025-12-09 13:11:12.667+01', '2025-12-09 13:11:12.667+01');
INSERT INTO public.coupons VALUES (10, 'FK Crvena Zvezda', 'Vojvodina', 'corners_1_over', '5.5', '72,30%', 1.00, 1.00, '100%', '40%', '100%', '60%', '100%', '40%', '100%', '38%', '93%', '27%', 'za mało danych', 'za mało danych', NULL, NULL, NULL, NULL, 2, '3', NULL, 'Serbia', '2025-12-07', 'Super Liga', 17367, 'K0005', 'https://flashscore.pl/pilka-nozna/serbia/super-liga/', 10.00, 41.18, '2025-12-09 13:13:55.74+01', '2025-12-09 13:13:55.74+01');
INSERT INTO public.coupons VALUES (11, 'Górnik Łęczna', 'Ruch Chorzów', 'bts', 'tak', '80,30%', 1.00, 1.00, '100%', '80%', '80%', '80%', '80%', '80%', '67%', '75%', '80%', '67%', 'za mało danych', 'za mało danych', NULL, NULL, NULL, NULL, 18, '9', NULL, 'Poland', '2025-12-07', 'I Liga', 16651, 'K0005', 'https://flashscore.pl/pilka-nozna/polska/1liga/', 10.00, 41.18, '2025-12-09 13:13:55.742+01', '2025-12-09 13:13:55.742+01');
INSERT INTO public.coupons VALUES (12, 'Ruh Lviv', 'Polessya', '2', '-', '65,90%', 1.00, 1.00, '40%', '60%', '80%', '80%', '60%', '70%', '71%', 'za mało danych', '64%', '57%', 'za mało danych', 'za mało danych', NULL, NULL, NULL, NULL, 13, '3', NULL, 'Ukraine', '2025-12-07', 'Premier League', 17439, 'K0005', 'https://flashscore.pl/pilka-nozna/ukraina/premier-league/', 10.00, 41.18, '2025-12-09 13:13:55.744+01', '2025-12-09 13:13:55.744+01');


--
-- Name: coupons_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.coupons_id_seq', 12, true);


--
-- PostgreSQL database dump complete
--

\unrestrict qOelSRmLLYHhmfkSBzw01jNL9K1c7eI5aKK1vFKCIisg8f9b7xzLqJLGa7Drz1S

