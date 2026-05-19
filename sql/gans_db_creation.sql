DROP DATABASE IF EXISTS gans_db;
CREATE DATABASE gans_db;

USE gans_db;

-- Cities: base reference table, populated once via web scraping
CREATE TABLE cities (
    city_id     INT AUTO_INCREMENT,
    city_name   VARCHAR(255) NOT NULL,
    country     VARCHAR(255) NOT NULL,
    latitude    FLOAT        NOT NULL,
    longitude   FLOAT        NOT NULL,
    PRIMARY KEY (city_id)
);

-- Airports: one city can have multiple nearby airports
CREATE TABLE airports (
    icao        VARCHAR(10)  NOT NULL,  -- ICAO code, unique airport identifier
    iata        VARCHAR(10),            -- IATA code (may be null for smaller airports)
    airport_name VARCHAR(255) NOT NULL,
    city_id     INT          NOT NULL,
    PRIMARY KEY (icao),
    FOREIGN KEY (city_id) REFERENCES cities(city_id)
);

-- Weather forecasts: refreshed regularly via OpenWeatherMap API
CREATE TABLE city_weather (
    forecast_time       DATETIME     NOT NULL,
    retrieved_at        DATETIME     NOT NULL,  -- when this forecast was fetched
    description         VARCHAR(255),
    temperature_C       FLOAT        NOT NULL,
    precipitation_prob  FLOAT        NOT NULL,  -- 0 to 1
    rain_mm             FLOAT        NOT NULL,  -- rain volume last 3h
    snow_mm             FLOAT        NOT NULL,  -- snow volume last 3h
    wind_speed_ms       FLOAT        NOT NULL,
    visibility_m        INT          NOT NULL,
    city_id             INT          NOT NULL,
    PRIMARY KEY (city_id, forecast_time),
    FOREIGN KEY (city_id) REFERENCES cities(city_id)
);

-- Flight arrivals: refreshed regularly via AeroDataBox API
CREATE TABLE flight_arrivals (
    arrival_id          INT AUTO_INCREMENT,
    flight_number       VARCHAR(20)  NOT NULL,
    scheduled_arrival   DATETIME     NOT NULL,
    origin_city         VARCHAR(255),
    origin_country      VARCHAR(255),
    terminal            VARCHAR(10),
    retrieved_at        DATETIME     NOT NULL,  -- when this data was fetched
    icao                VARCHAR(10)  NOT NULL,
    PRIMARY KEY (arrival_id),
    FOREIGN KEY (icao) REFERENCES airports(icao)
);
