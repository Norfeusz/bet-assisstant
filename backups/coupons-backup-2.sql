--
-- PostgreSQL database dump
--

\restrict Dn1jljBqLpD9gcjAfBBMB7WIgR8djyilF52eRWL5bVxEfErs3aWdu1o6ui9ldre

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
INSERT INTO public.coupons VALUES (13, 'Extremadura 1924', 'Linares Deportivo', 'bts', 'tak', '75,30%', 1.00, 1.00, '80%', '80%', '100%', '60%', '70%', '80%', 'za mało danych', '57%', '69%', '77%', 'za mało danych', 'za mało danych', NULL, NULL, NULL, NULL, 5, '6', NULL, 'Spain', '2025-12-07', 'Segunda División RFEF - Group 4', 16795, 'K0006', 'https://flashscore.pl/pilka-nozna/hiszpania/segunda-federacion-gr4/', 10.00, 45.94, '2025-12-09 13:14:59.977+01', '2025-12-09 13:14:59.977+01');
INSERT INTO public.coupons VALUES (14, 'Hertha BSC', '1. FC Magdeburg', '1', '-', '74,80%', 1.00, 1.00, '100%', '60%', '80%', '80%', '80%', '70%', '57%', '71%', '57%', '71%', 'za mało danych', 'za mało danych', NULL, NULL, NULL, NULL, 6, '18', NULL, 'Germany', '2025-12-07', '2. Bundesliga', 16960, 'K0006', 'https://flashscore.pl/pilka-nozna/niemcy/bundesliga-2/', 10.00, 45.94, '2025-12-09 13:14:59.979+01', '2025-12-09 13:14:59.979+01');
INSERT INTO public.coupons VALUES (15, 'Sabadell', 'Ibiza', 'bts', 'nie', '85,10%', 1.00, 1.00, '60%', '80%', '100%', '100%', '80%', '90%', '100%', '71%', '71%', '64%', 'za mało danych', 'za mało danych', NULL, NULL, NULL, NULL, 3, '12', NULL, 'Spain', '2025-12-07', 'Primera División RFEF - Group 2', 16745, 'K0006', 'https://flashscore.pl/pilka-nozna/hiszpania/primera-federacion-gr2/', 10.00, 45.94, '2025-12-09 13:14:59.981+01', '2025-12-09 13:14:59.981+01');
INSERT INTO public.coupons VALUES (16, 'Lusitânia Lourosa', 'Portimonense', 'bts', 'tak', '71,70%', 1.00, 1.00, '80%', '40%', '80%', '80%', '80%', '70%', 'za mało danych', 'za mało danych', '75%', '75%', 'za mało danych', 'za mało danych', NULL, NULL, NULL, NULL, 10, '16', NULL, 'Portugal', '2025-12-07', 'Segunda Liga', 17025, 'K0007', 'https://flashscore.pl/pilka-nozna/portugalia/liga-2/', 10.00, 47.89, '2025-12-09 13:15:43.734+01', '2025-12-09 13:15:43.734+01');
INSERT INTO public.coupons VALUES (17, 'Manisa BBSK', 'Van BB', 'corners_match_under', '9.5', '76,00%', 1.00, 1.00, '100%', '60%', '80%', '80%', '80%', '80%', '71%', '57%', '67%', '67%', 'za mało danych', 'za mało danych', NULL, NULL, NULL, NULL, 18, '10', NULL, 'Turkey', '2025-12-07', '1. Lig', 17071, 'K0007', 'https://flashscore.pl/pilka-nozna/turcja/1-lig/', 10.00, 47.89, '2025-12-09 13:15:43.737+01', '2025-12-09 13:15:43.737+01');
INSERT INTO public.coupons VALUES (18, 'San Carlos', 'LD Alajuelense', '2', '-', '63,30%', 2.00, 1.00, '40%', '80%', '60%', '60%', '70%', '70%', '63%', '63%', '60%', '60%', 'za mało danych', 'za mało danych', NULL, NULL, NULL, NULL, 10, '1', NULL, 'Costa-Rica', '2025-12-07', 'Primera División', 17302, 'K0007', 'https://flashscore.pl/pilka-nozna/kostaryka/primera-division-apertura/', 10.00, 47.89, '2025-12-09 13:15:43.739+01', '2025-12-09 13:15:43.739+01');
INSERT INTO public.coupons VALUES (19, 'Lecco', 'Alcione', 'goals_under', '2.5', '83,50%', 1.00, 1.00, '80%', '100%', '80%', '100%', '80%', '90%', '50%', '88%', '73%', '87%', 'za mało danych', 'za mało danych', NULL, NULL, NULL, NULL, 3, '5', NULL, 'Italy', '2025-12-08', 'Serie C - Girone A', 16885, 'K0008', 'https://flashscore.pl/pilka-nozna/wlochy/serie-c-gra/', 10.00, 38.55, '2025-12-09 13:16:43.915+01', '2025-12-09 13:16:43.915+01');
INSERT INTO public.coupons VALUES (20, 'Jong Utrecht', 'De Graafschap', 'corners_match_over', '9.5', '83,30%', 1.00, 1.00, '60%', '100%', '80%', '100%', '70%', '100%', '67%', '89%', '67%', '80%', 'za mało danych', 'za mało danych', NULL, NULL, NULL, NULL, 13, '5', NULL, 'Netherlands', '2025-12-08', 'Eerste Divisie', 17065, 'K0008', 'https://flashscore.pl/pilka-nozna/holandia/eerste-divisie/', 10.00, 38.55, '2025-12-09 13:16:43.995+01', '2025-12-09 13:16:43.995+01');
INSERT INTO public.coupons VALUES (21, 'Wolves', 'Manchester United', 'corners_1_under', '4.5', '67,40%', 1.00, 1.00, '100%', '25%', '100%', '25%', '89%', '33%', '100%', 'za mało danych', '92%', '46%', 'za mało danych', 'za mało danych', NULL, NULL, NULL, NULL, 20, '9', NULL, 'England', '2025-12-08', 'Premier League', 16672, 'K0008', 'https://flashscore.pl/pilka-nozna/anglia/premier-league/', 10.00, 38.55, '2025-12-09 13:16:43.997+01', '2025-12-09 13:16:43.997+01');
INSERT INTO public.coupons VALUES (22, 'Notts County', 'Milton Keynes Dons', 'bts', 'tak', '70,60%', 1.00, 1.00, '60%', '80%', '60%', '80%', '60%', '80%', '67%', '78%', '60%', '80%', 'za mało danych', 'za mało danych', NULL, NULL, NULL, NULL, 4, '3', NULL, 'England', '2025-12-09', 'League Two', 17746, 'K0009', NULL, 11.00, 41.48, '2025-12-09 13:17:51.493+01', '2025-12-09 13:17:51.493+01');
INSERT INTO public.coupons VALUES (23, 'Bromley', 'Crawley Town', 'goals_over', '2.5', '70,50%', 1.00, 1.00, '60%', '80%', '80%', '80%', '60%', '70%', '67%', '67%', '60%', '53%', 'za mało danych', 'za mało danych', NULL, NULL, NULL, NULL, 5, '19', NULL, 'England', '2025-12-09', 'League Two', 17748, 'K0009', NULL, 11.00, 41.48, '2025-12-09 13:17:51.496+01', '2025-12-09 13:17:51.496+01');
INSERT INTO public.coupons VALUES (24, 'Northampton', 'Huddersfield', 'corners_2_over', '4.5', '56,40%', 1.00, 0.00, '40%', '80%', '40%', '60%', '40%', '80%', '33%', '78%', '40%', '80%', 'za mało danych', 'za mało danych', NULL, NULL, NULL, NULL, 15, '8', NULL, 'England', '2025-12-09', 'League One', 17765, 'K0009', NULL, 11.00, 41.48, '2025-12-09 13:17:51.498+01', '2025-12-09 13:17:51.498+01');
INSERT INTO public.coupons VALUES (25, 'Barrow', 'Tranmere', 'corners_match_under', '10.5', '76,80%', 1.00, 1.00, '80%', '100%', '80%', '80%', '60%', '80%', '78%', '56%', '53%', '60%', 'za mało danych', 'za mało danych', NULL, NULL, NULL, NULL, 18, '15', NULL, 'England', '2025-12-09', 'League Two', 17747, 'K0010', NULL, 10.00, 41.90, '2025-12-09 13:18:48.943+01', '2025-12-09 13:18:48.943+01');
INSERT INTO public.coupons VALUES (26, 'Doncaster', 'Stockport County', 'corners_1_under', '5.5', '76,00%', 1.00, 1.00, '80%', '80%', '100%', '60%', '80%', '80%', '78%', '50%', '67%', '60%', 'za mało danych', 'za mało danych', NULL, NULL, NULL, NULL, 18, '5', NULL, 'England', '2025-12-09', 'League One', 17767, 'K0010', NULL, 10.00, 41.90, '2025-12-09 13:18:48.946+01', '2025-12-09 13:18:48.946+01');
INSERT INTO public.coupons VALUES (27, 'Araz', 'Kapaz', 'goals_over', '2.5', '74,00%', 1.00, 1.00, '80%', '80%', '60%', '80%', '60%', '70%', 'za mało danych', '88%', '62%', '77%', 'za mało danych', 'za mało danych', NULL, NULL, NULL, NULL, 6, '11', NULL, 'Azerbaijan', '2025-12-09', 'Premyer Liqa', 17835, 'K0010', NULL, 10.00, 41.90, '2025-12-09 13:18:48.947+01', '2025-12-09 13:18:48.947+01');


--
-- Name: coupons_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.coupons_id_seq', 27, true);


--
-- PostgreSQL database dump complete
--

\unrestrict Dn1jljBqLpD9gcjAfBBMB7WIgR8djyilF52eRWL5bVxEfErs3aWdu1o6ui9ldre

