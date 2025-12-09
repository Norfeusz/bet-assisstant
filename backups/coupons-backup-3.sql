--
-- PostgreSQL database dump
--

\restrict eZv66UxdlSwZzzajXdkuT7U4JYlfvhrYH3dSgcM0zVQJdfDgju56abVwbGi8LWo

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


--
-- Name: coupons_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.coupons_id_seq', 6, true);


--
-- PostgreSQL database dump complete
--

\unrestrict eZv66UxdlSwZzzajXdkuT7U4JYlfvhrYH3dSgcM0zVQJdfDgju56abVwbGi8LWo

