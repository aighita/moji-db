# Moji DB - Local Deployment Guide

Acest proiect utilizează Docker pentru a rula baza de date Oracle și aplicația Python.

## Cerințe
- Docker Desktop (sau Docker Engine pe Linux)
- Make (opțional, dar recomandat)

## Instalare și Rulare Rapidă

Dacă aveți `make` instalat, rulați o singură comandă în terminal, în rădăcina proiectului:

    make all

Această comandă va:
1. Porni containerul Oracle Database.
2. Crea tabelele și popula baza de date cu date de test.
3. Compila procedurile stocate și triggerele.
4. Porni aplicația web (Streamlit).

Aplicația va fi accesibilă la: http://localhost:8501

## Rulare Manuală (fără Make)

Dacă nu aveți `make`, rulați următoarele scripturi în ordine:

1. Pornire Bază de Date:
   ./scripts/db/install-oracle-container.sh

2. Creare Tabele:
   ./scripts/db/tables/create.sh

3. Încărcare Date (Fixtures):
   ./scripts/db/fixtures/load.sh

4. Încărcare Proceduri:
   ./scripts/db/procedures/load.sh

5. Pornire Aplicație:
   ./scripts/app/run.sh

## Credențiale
- Database User: system
- Database Password: password
- Port: 1521
- Service Name: XEPDB1
