# Preliminary Analysis - Impact of age cap on Higher Education in Chile

- This script analyzes first-year undergraduate enrollment in Chilean higher education using publicly available MINEDUC data. It identifies first-year students (those whose initial enrollment year matches the file year), constructs indicators for students aged 30 or older and for female students, and merges enrollment records with financial aid assignment data to flag recipients of Gratuidad (Chile's free higher education program for the bottom 60% of household income).
- For each year, the script computes: the share of first-year students aged 30+, the gender composition of that group, and Gratuidad coverage rates across the full cohort and among 30+ students. For 2024 and 2025, it additionally reports Gratuidad uptake among women aged 30+.
- - All statistics are broken down by institutional type — universities versus technical and professional institutes (CFT+IP) — while also reporting aggregated totals.
- The analysis was developed to inform the policy debate around a proposed age cap that would restrict Gratuidad eligibility to students under 30 years old.

_Data sources: Matrícula en Educación Superior and Asignación de Becas y Créditos, MINEDUC (via [datos abiertos](https://datosabiertos.mineduc.cl/))_
