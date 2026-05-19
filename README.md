# Gans E-Scooter ETL Pipeline

A data engineering project building a local ETL pipeline for **Gans**, a fictional e-scooter sharing startup. The pipeline collects data from three external sources, transforms it using Python and pandas, and loads it into a relational MySQL database — providing the data foundation needed to predict scooter demand and movement across cities.

---

## The Business Problem

E-scooter companies face a core operational challenge: **scooters end up in the wrong places**. Users ride uphill but walk down. Morning commutes push scooters toward city centres. Rain kills demand instantly. Tourists cluster around landmarks.

To reposition scooters efficiently — whether by truck or user incentives — Gans needs to *anticipate* these movements. That requires external data: weather forecasts, flight arrivals, and city reference data.

---

## Pipeline Overview

```
┌─────────────────────────────────────────────────────┐
│                     EXTRACT                         │
│  Wikipedia        OpenWeatherMap      AeroDataBox   │
│  (web scraping)   (REST API)          (REST API)    │
└────────┬──────────────┬───────────────────┬─────────┘
         │              │                   │
         ▼              ▼                   ▼
┌─────────────────────────────────────────────────────┐
│                    TRANSFORM                        │
│         Python · pandas · data cleaning             │
└────────────────────────┬────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────┐
│                      LOAD                           │
│              MySQL (local)                          │
│   cities · airports · city_weather · flight_arrivals│
└─────────────────────────────────────────────────────┘
```

---

## Data Sources

| Notebook | Source | Data | Update Frequency |
|---|---|---|---|
| `01_web_scraping.ipynb` | Wikipedia | City name, country, coordinates | Once |
| `02_weather_api.ipynb` | OpenWeatherMap | 5-day / 3-hour forecast | Daily |
| `03_flights_api.ipynb` | AeroDataBox (RapidAPI) | Nearby airports + daily arrivals | Daily |

---

## Database Schema

```
cities
  city_id (PK) · city_name · country · latitude · longitude

airports
  icao (PK) · iata · airport_name · city_id (FK → cities)

city_weather
  (city_id, forecast_time) (PK) · retrieved_at · description
  temperature_C · precipitation_prob · rain_mm · snow_mm
  wind_speed_ms · visibility_m · city_id (FK → cities)

flight_arrivals
  arrival_id (PK) · flight_number · scheduled_arrival
  origin_city · origin_country · terminal · retrieved_at
  icao (FK → airports)
```

---

## Project Structure

```
gans-etl-pipeline/
│
├── notebooks/
│   ├── 01_web_scraping.ipynb   # Wikipedia scrape → cities table
│   ├── 02_weather_api.ipynb    # OpenWeatherMap → city_weather table
│   └── 03_flights_api.ipynb    # AeroDataBox → airports + flight_arrivals
│
├── sql/
│   └── gans_db_creation.sql    # Full schema — run this first
│
├── .gitignore
└── README.md
```

---

## How to Run

### Prerequisites

- Python 3.10+ with conda (or pip)
- MySQL Server running locally
- API keys for [OpenWeatherMap](https://openweathermap.org/api) (free tier) and [AeroDataBox via RapidAPI](https://rapidapi.com/aedbx-aedbx/api/aerodatabox) (free tier)

### Setup

```bash
# Install dependencies
conda install pandas requests beautifulsoup4 sqlalchemy pymysql

# Clone the repo
git clone https://github.com/YOUR_USERNAME/gans-etl-pipeline.git
cd gans-etl-pipeline
```

### Run in order

1. **Create the database** — open `sql/gans_db_creation.sql` in MySQL Workbench and execute it
2. **Run `01_web_scraping.ipynb`** — populates the `cities` table
3. **Run `02_weather_api.ipynb`** — populates `city_weather`
4. **Run `03_flights_api.ipynb`** — populates `airports` and `flight_arrivals`

> All API keys and the MySQL password are entered securely at runtime using `getpass` — **no credentials are ever stored in the notebooks.**

---

## Skills Demonstrated

- **Web scraping** with `requests` and `BeautifulSoup` — parsing Wikipedia infoboxes, handling coordinate formats
- **REST API integration** — OpenWeatherMap and AeroDataBox, including authentication, query parameters, and JSON parsing
- **Data transformation** with `pandas` — normalising nested JSON, type casting, handling missing values
- **Relational database design** — MySQL schema with primary keys, composite keys, and foreign key constraints
- **ETL pipeline thinking** — separation of extract / transform / load stages, `retrieved_at` timestamps for auditability, duplicate protection via composite PKs

---

## Challenges & Solutions

**Inconsistent Wikipedia structure** — City infoboxes vary significantly across pages. Coordinates were the most reliable field (always in a `<span class="geo-dec">` element), so the pipeline focuses on those rather than more variable fields like population.

**Credential security** — No secrets are hardcoded. All keys and passwords use Python's `getpass` for runtime entry, keeping the notebooks safe to share and commit.

**Duplicate forecast prevention** — The `(city_id, forecast_time)` composite primary key in `city_weather` prevents the same forecast window from being inserted twice, even if the pipeline is re-run on the same day.

---

## Future Improvements

- Move credentials to environment variables (`.env` + `python-dotenv`) for automation
- Schedule daily runs with Apache Airflow or a simple cron job
- Add a `city_events` table (concerts, festivals) as an additional demand signal
- Deploy to the cloud (AWS RDS + Lambda) to remove the local dependency
